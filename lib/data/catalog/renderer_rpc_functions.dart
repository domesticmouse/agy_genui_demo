import 'dart:io';

import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:a2ui_flutter/basic_catalog.dart';
import 'package:json_schema_builder/json_schema_builder.dart'
    hide ValidationResult;
import 'package:path/path.dart' as p;

/// Snapshot of the active workspace, project, conversation thread, and theme
/// exposed to bidirectional A2UI v1.0 [FunctionImplementation]s.
class WorkspaceInfoSnapshot {
  const WorkspaceInfoSnapshot({
    required this.projectId,
    required this.projectName,
    required this.workingDirectory,
    required this.activeThreadId,
    required this.activeThreadTitle,
    required this.themeMode,
    this.surfaceIds = const [],
  });

  final String projectId;
  final String projectName;
  final String workingDirectory;
  final String activeThreadId;
  final String activeThreadTitle;
  final String themeMode;
  final List<String> surfaceIds;

  Map<String, Object?> toJson() => {
    'projectId': projectId,
    'projectName': projectName,
    'workingDirectory': workingDirectory,
    'activeThreadId': activeThreadId,
    'activeThreadTitle': activeThreadTitle,
    'themeMode': themeMode,
    'surfaceIds': surfaceIds,
  };
}

/// Callback providing the current [WorkspaceInfoSnapshot] to renderer RPC functions.
typedef WorkspaceInfoProvider = WorkspaceInfoSnapshot Function();

/// Builds the A2UI v1.0 [CatalogImplementation] combining [basicCatalog] with
/// bidirectional [FunctionImplementation]s (`AllowedCallers.rendererOrAgent`).
CatalogImplementation buildAppA2uiCatalog({
  String locale = 'en-US',
  OpenUrlCallback? openUrl,
  WorkspaceInfoProvider? workspaceInfoProvider,
}) {
  final base = basicCatalog(locale: locale, openUrl: openUrl);
  final customFunctions = buildRendererRpcFunctions(
    workspaceInfoProvider: workspaceInfoProvider,
  );
  return base.copyWith(
    functions: [...base.functions.values, ...customFunctions],
  );
}

/// Returns the custom A2UI v1.0 [FunctionImplementation]s registered with
/// [AllowedCallers.rendererOrAgent] so both the agent (`callRendererFunction`)
/// and renderer surfaces (`@call` expressions and `Button` `functionCall`
/// actions) can invoke them.
List<FunctionImplementation> buildRendererRpcFunctions({
  WorkspaceInfoProvider? workspaceInfoProvider,
}) => [
  GetWorkspaceInfoFunction(workspaceInfoProvider: workspaceInfoProvider),
  ListWorkspaceFilesFunction(workspaceInfoProvider: workspaceInfoProvider),
  SetSurfaceDataFunction(),
  FormatParameterSummaryFunction(),
];

/// Returns metadata about the active project workspace, thread, and surfaces.
///
/// Callable by both the agent (`callRendererFunction`) and renderer expressions
/// (`{"@call": "getWorkspaceInfo"}`).
class GetWorkspaceInfoFunction extends FunctionImplementation {
  GetWorkspaceInfoFunction({this.workspaceInfoProvider})
    : super(
        name: 'getWorkspaceInfo',
        description:
            'Returns metadata about the active macOS project workspace '
            '(projectId, projectName, workingDirectory, activeThreadId, '
            'activeThreadTitle, themeMode, and surfaceIds).',
        returnType: A2uiReturnType.object,
        allowedCallers: AllowedCallers.rendererOrAgent,
        argumentSchema: Schema.fromMap(const <String, Object?>{
          'type': 'object',
          'properties': <String, Object?>{},
          'unevaluatedProperties': false,
        }),
      );

  final WorkspaceInfoProvider? workspaceInfoProvider;

  @override
  Object? execute(
    Map<String, dynamic> args,
    DataContext context, [
    CancellationSignal? cancellationSignal,
  ]) {
    final snapshot =
        workspaceInfoProvider?.call() ??
        WorkspaceInfoSnapshot(
          projectId: 'project-default',
          projectName: 'Default Workspace',
          workingDirectory: Directory.current.absolute.path,
          activeThreadId: 'thread-showcase',
          activeThreadTitle: 'Markdown Showcase',
          themeMode: 'light',
        );
    return snapshot.toJson();
  }
}

/// Lists filenames inside the active project's working directory (optionally
/// filtered by file extension and capped by `limit`).
///
/// Confined strictly to the active workspace directory. Callable by both the
/// agent (`callRendererFunction`) and renderer surfaces (`@call`).
class ListWorkspaceFilesFunction extends FunctionImplementation {
  ListWorkspaceFilesFunction({this.workspaceInfoProvider})
    : super(
        name: 'listWorkspaceFiles',
        description:
            'Lists files in the active project working directory, optionally '
            'filtered by file extension (e.g. ".dart" or ".yaml") and capped '
            'at limit entries.',
        returnType: A2uiReturnType.array,
        allowedCallers: AllowedCallers.rendererOrAgent,
        argumentSchema: Schema.fromMap(const <String, Object?>{
          'type': 'object',
          'properties': <String, Object?>{
            'extension': <String, Object?>{
              r'$ref': r'common_types.json#/$defs/DynamicString',
              'description':
                  'Optional file extension filter (for example ".dart" or "yaml").',
            },
            'limit': <String, Object?>{
              r'$ref': r'common_types.json#/$defs/DynamicNumber',
              'description':
                  'Optional maximum number of filenames to return (default 20).',
            },
          },
          'unevaluatedProperties': false,
        }),
      );

  final WorkspaceInfoProvider? workspaceInfoProvider;

  @override
  Object? execute(
    Map<String, dynamic> args,
    DataContext context, [
    CancellationSignal? cancellationSignal,
  ]) {
    final rawExt = args['extension']?.toString().trim() ?? '';
    final normalizedExt = rawExt.isEmpty
        ? ''
        : (rawExt.startsWith('.')
              ? rawExt.toLowerCase()
              : '.${rawExt.toLowerCase()}');
    final rawLimit = args['limit'];
    final int limit = switch (rawLimit) {
      final int n => n.clamp(1, 100),
      final num n => n.toInt().clamp(1, 100),
      _ => 20,
    };

    final workingDir =
        workspaceInfoProvider?.call().workingDirectory ??
        Directory.current.absolute.path;
    final dir = Directory(workingDir);
    if (!dir.existsSync()) {
      return const <String>[];
    }

    try {
      final entries = <String>[];
      for (final entity in dir.listSync(followLinks: false)) {
        final name = p.basename(entity.path);
        if (name.startsWith('.')) continue;
        if (normalizedExt.isNotEmpty &&
            !name.toLowerCase().endsWith(normalizedExt)) {
          continue;
        }
        entries.add(entity is Directory ? '$name/' : name);
      }
      entries.sort();
      return entries.take(limit).toList();
    } on Object {
      return const <String>[];
    }
  }
}

/// Mutates a JSON Pointer `path` in the target surface's `DataContext` and
/// returns `true`.
///
/// Enables both local `Button` `action.functionCall`s (such as applying presets
/// or resetting clarifying question forms without a server round-trip) and
/// agent-initiated `callRendererFunction` mutations on an active surface.
class SetSurfaceDataFunction extends FunctionImplementation {
  SetSurfaceDataFunction()
    : super(
        name: 'setSurfaceData',
        description:
            'Writes value to the specified JSON Pointer path in the surface '
            'data model and returns true.',
        returnType: A2uiReturnType.boolean,
        allowedCallers: AllowedCallers.rendererOrAgent,
        argumentSchema: Schema.fromMap(const <String, Object?>{
          'type': 'object',
          'properties': <String, Object?>{
            'path': <String, Object?>{
              r'$ref': r'common_types.json#/$defs/DynamicString',
              'description':
                  'JSON Pointer path in the surface data model (e.g. "/form/target").',
            },
            'value': <String, Object?>{
              r'$ref': r'common_types.json#/$defs/DynamicValue',
              'description': 'The value to store at path.',
            },
          },
          'required': <Object?>['path', 'value'],
          'unevaluatedProperties': false,
        }),
      );

  @override
  Object? execute(
    Map<String, dynamic> args,
    DataContext context, [
    CancellationSignal? cancellationSignal,
  ]) {
    final rawPath = args['path']?.toString().trim() ?? '';
    if (rawPath.isEmpty) {
      return false;
    }
    context.set(rawPath, args['value']);
    return true;
  }
}

/// Formats a live human-readable parameter summary string from clarifying form
/// inputs (`scope`, `target`, `features`, `concurrency`, `sandboxed`).
///
/// Callable reactively inside `Text` components (`{"@call": "formatParameterSummary", ...}`)
/// as well as via `callRendererFunction`.
class FormatParameterSummaryFunction extends FunctionImplementation {
  FormatParameterSummaryFunction()
    : super(
        name: 'formatParameterSummary',
        description:
            'Formats a concise summary string from clarifying question and '
            'parameter form values (scope, target, features, concurrency, '
            'sandboxed).',
        returnType: A2uiReturnType.string,
        allowedCallers: AllowedCallers.rendererOrAgent,
        argumentSchema: Schema.fromMap(const <String, Object?>{
          'type': 'object',
          'properties': <String, Object?>{
            'scope': <String, Object?>{
              r'$ref': r'common_types.json#/$defs/DynamicString',
              'description': 'Goal or module scope entered by the user.',
            },
            'target': <String, Object?>{
              r'$ref': r'common_types.json#/$defs/DynamicValue',
              'description':
                  'Selected target platform(s) (string or array of strings).',
            },
            'features': <String, Object?>{
              r'$ref': r'common_types.json#/$defs/DynamicValue',
              'description':
                  'Selected feature flags or capabilities (array of strings).',
            },
            'concurrency': <String, Object?>{
              r'$ref': r'common_types.json#/$defs/DynamicNumber',
              'description': 'Numeric concurrency or worker count.',
            },
            'sandboxed': <String, Object?>{
              r'$ref': r'common_types.json#/$defs/DynamicBoolean',
              'description': 'Whether strict sandbox containment is enabled.',
            },
          },
          'unevaluatedProperties': false,
        }),
      );

  @override
  Object? execute(
    Map<String, dynamic> args,
    DataContext context, [
    CancellationSignal? cancellationSignal,
  ]) {
    final scope = args['scope']?.toString().trim() ?? '';
    final scopeDisplay = scope.isEmpty ? '(unset)' : scope;
    final targetDisplay = _joinSelection(args['target'], fallback: 'macos');
    final featuresDisplay = _joinSelection(args['features'], fallback: 'none');
    final rawConcurrency = args['concurrency'];
    final int concurrency = switch (rawConcurrency) {
      final int n => n,
      final num n => n.round(),
      _ => 4,
    };
    final bool sandboxed = args['sandboxed'] != false;
    final sandboxLabel = sandboxed ? 'sandboxed' : 'unrestricted';

    return 'Scope: $scopeDisplay | Target: $targetDisplay | '
        'Features: $featuresDisplay | Workers: $concurrency ($sandboxLabel)';
  }

  static String _joinSelection(Object? raw, {required String fallback}) {
    if (raw is List) {
      final items = raw
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
      return items.isEmpty ? fallback : items.join(', ');
    }
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    return fallback;
  }
}
