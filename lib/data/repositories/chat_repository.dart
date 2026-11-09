import 'dart:async';
import 'dart:io';

import 'package:a2ui_agent/a2ui_agent.dart';
import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:a2ui_flutter/basic_catalog.dart';
import 'package:antigravity/antigravity.dart';
import 'package:path/path.dart' as p;

import '../../domain/models/chat_models.dart';
import '../catalog/renderer_rpc_functions.dart';

/// Session contract for an Antigravity [Agent] backing a single conversation thread.
abstract class AntigravityAgentSession {
  /// Starts the underlying Antigravity agent session.
  Future<void> start();

  /// Sends [prompt] to the agent and yields Markdown response chunks as they stream.
  Stream<String> sendPrompt(String prompt);

  /// Stops the agent session and terminates its local harness connection.
  Future<void> stop();
}

/// Production [AntigravityAgentSession] backed by `package:antigravity`'s
/// [Agent] and [LocalAgentConfig] (spawning the local `localharness` binary).
class LocalAntigravityAgentSession implements AntigravityAgentSession {
  LocalAntigravityAgentSession({required this.config}) : _agent = Agent(config);

  final LocalAgentConfig config;
  final Agent _agent;

  /// The underlying Antigravity [Agent] instance.
  Agent get agent => _agent;

  /// Whether the underlying [Agent] session is currently active.
  bool get isStarted => _agent.isStarted;

  @override
  Future<void> start() async {
    if (!_agent.isStarted) {
      await _agent.start();
    }
  }

  @override
  Stream<String> sendPrompt(String prompt) async* {
    if (!_agent.isStarted) {
      await _agent.start();
    }
    final ChatResponse response = await _agent.chat(prompt);
    await for (final chunk in response.textStream) {
      if (chunk.isNotEmpty) {
        yield chunk;
      }
    }
  }

  @override
  Future<void> stop() async {
    if (_agent.isStarted) {
      await _agent.stop();
    }
  }
}

/// Factory signature for creating per-thread [AntigravityAgentSession] instances.
typedef AntigravitySessionBuilder = AntigravityAgentSession Function(
  LocalAgentConfig config, {
  required String threadId,
  required String threadTitle,
});

/// Callback invoked when a command or tool call wants to escape the sandbox
/// and requires explicit user review in the UI.
typedef CommandApprovalHandler = Future<bool> Function(
  ToolCall toolCall, {
  required String threadId,
  required String threadTitle,
  required String projectId,
  required String workingDirectory,
  required String reason,
});

/// Repository supplying starter projects and conversation threads, and managing
/// per-thread Google Antigravity SDK ([Agent] / [LocalAgentConfig]) sessions
/// alongside A2UI v1.0 catalog negotiation and `<a2ui-json>` prompt generation.
class ChatRepository {
  ChatRepository({
    AntigravitySessionBuilder? sessionBuilder,
    this.model,
    this.apiKey,
    this.binaryPath,
    this.workspaces,
    this.policies,
    this.commandApprovalHandler,
    this.workspaceInfoProvider,
    this.systemInstructionText = defaultSystemInstructions,
    CatalogImplementation? a2uiCatalog,
  }) : _sessionBuilder = sessionBuilder ?? _defaultSessionBuilder {
    this.a2uiCatalog =
        a2uiCatalog ??
        buildAppA2uiCatalog(
          workspaceInfoProvider: () =>
              workspaceInfoProvider?.call() ?? _defaultWorkspaceSnapshot(),
        );
  }

  /// Default A2UI v1.0 catalog combining [basicCatalog] with bidirectional
  /// renderer RPC [FunctionImplementation]s (`getWorkspaceInfo`,
  /// `listWorkspaceFiles`, `setSurfaceData`, `formatParameterSummary`).
  static final CatalogImplementation defaultA2uiCatalog = buildAppA2uiCatalog();

  /// Direct JSON format factory (`<a2ui-json>...</a2ui-json>`) with progressive
  /// string healing for `text` and `label` properties while streaming.
  static const DirectJsonFormatFactory defaultA2uiFormatFactory =
      DirectJsonFormatFactory(progressiveKeys: {'text', 'label'});

  /// Default system instructions guiding the Antigravity agent to respond in
  /// well-structured GitHub-Flavored Markdown, emit interactive A2UI v1.0
  /// clarifying question / parameter forms, and use bidirectional renderer RPC
  /// functions.
  static const String defaultSystemInstructions =
      'You are a helpful AI assistant inside a macOS desktop Markdown and A2UI v1.0 chat application. '
      'Format all responses using clean, well-structured GitHub-Flavored Markdown '
      '(headings, bulleted or numbered lists, inline code, fenced code blocks with '
      'language tags, blockquotes, and tables when appropriate). '
      'When presenting interactive forms, clarifying questions, parameter builders, cards, or controls, '
      'emit A2UI v1.0 JSON messages wrapped in literal `<a2ui-json>` and `</a2ui-json>` tags inline alongside your Markdown.\n\n'
      '### Interactive Clarifying Questions & Parameter Forms\n'
      '- When a request is ambiguous or benefits from structured parameters, emit an A2UI v1.0 surface '
      'with `sendDataModel: true` containing a `Card` and `Column` of controls:\n'
      '  - `ChoicePicker` (`variant`: `"mutuallyExclusive"` or `"multipleSelection"`, `displayStyle`: `"chips"` or `"checkbox"`)\n'
      '  - `TextField` with validation `checks` (`required`, `length`, `regex`, `numeric`)\n'
      '  - `Slider` and `CheckBox` for numeric thresholds and boolean flags\n'
      '  - `Text` bound to `{"@call": "formatParameterSummary", "args": {...}}` for a live summary preview\n'
      '  - Preset `Button`s using `action.functionCall` with `{"@call": "setSurfaceData", "args": {"path": "...", "value": ...}}`\n'
      '  - A primary submit `Button` (gated by `checks` so it is disabled until required fields are valid) '
      'whose `action.event` dispatches the bound parameter values back to you.\n\n'
      '### Bidirectional Renderer RPC Functions\n'
      '- You can invoke renderer-side functions (`getWorkspaceInfo`, `listWorkspaceFiles`, `setSurfaceData`, `formatParameterSummary`) '
      'either inside component expressions (`{"@call": "..."}`) or directly via an A2UI v1.0 `callRendererFunction` message '
      '(always include `"catalogId": "${BasicCatalog.v1_0Id}"` inside `callRendererFunction.callFunction`).\n'
      '- When the renderer sends a `callAgentFunction` message, reply with an `agentFunctionResponse` message '
      'matching its `functionCallId`.';

  final AntigravitySessionBuilder _sessionBuilder;
  final String? model;
  final String? apiKey;
  final String? binaryPath;
  final List<String>? workspaces;
  final List<Policy>? policies;
  final String systemInstructionText;

  /// Optional callback supplying live workspace/project/thread/theme state to
  /// renderer RPC functions (`getWorkspaceInfo`, `listWorkspaceFiles`).
  WorkspaceInfoProvider? workspaceInfoProvider;

  /// The A2UI v1.0 component and function catalog used by the renderer and agent.
  late final CatalogImplementation a2uiCatalog;

  /// Long-lived A2UI generator configured with [a2uiCatalog] and [defaultA2uiFormatFactory].
  late final A2uiGenerator a2uiGenerator = A2uiGenerator(
    catalogs: [CatalogConfig(a2uiCatalog)],
    inferenceFormatFactory: defaultA2uiFormatFactory,
  );

  /// Negotiated A2UI v1.0 request processor for generating `<a2ui-json>` prompt
  /// snippets and streaming [StreamedAnswer] responses.
  late final A2uiRequestProcessor a2uiRequestProcessor =
      a2uiGenerator.createProcessor(
        A2uiRendererCapabilities.forCatalogIds(
          [a2uiCatalog.id],
          version: A2uiProtocolVersion.v1_0,
        ),
      );

  /// The system prompt snippet teaching the model A2UI v1.0 `<a2ui-json>` syntax
  /// and the active catalog schemas.
  String get a2uiPromptSnippet => a2uiRequestProcessor.promptSnippet;

  /// Handler invoked when a command requests to escape the sandbox (`BypassSandbox`
  /// or accessing paths outside the project's working directory).
  CommandApprovalHandler? commandApprovalHandler;

  final Map<String, AntigravityAgentSession> _sessions = {};
  final Map<
    String,
    ({String threadTitle, String projectId, String workingDirectory})
  > _sessionMetadata = {};

  static AntigravityAgentSession _defaultSessionBuilder(
    LocalAgentConfig config, {
    required String threadId,
    required String threadTitle,
  }) {
    return LocalAntigravityAgentSession(config: config);
  }

  WorkspaceInfoSnapshot _defaultWorkspaceSnapshot() {
    final defaultDir =
        (workspaces != null && workspaces!.isNotEmpty)
            ? normalizeProjectDirectory(workspaces!.first)
            : resolveDefaultWorkingDirectory();
    return WorkspaceInfoSnapshot(
      projectId: ChatThread.defaultProjectId,
      projectName: p.basename(defaultDir).isEmpty
          ? 'Default Workspace'
          : p.basename(defaultDir),
      workingDirectory: defaultDir,
      activeThreadId: 'thread-showcase',
      activeThreadTitle: 'Markdown Showcase',
      themeMode: 'light',
    );
  }

  /// Active thread IDs that currently have an initialized [AntigravityAgentSession].
  Iterable<String> get activeSessionThreadIds => _sessions.keys;

  /// Resolves a safe default project working directory.
  ///
  /// When launched from a terminal (`flutter run -d macos`), uses
  /// `Directory.current.absolute.path`. When launched as a macOS `.app` bundle
  /// from Finder/LaunchServices (where `Directory.current` is `/`), falls back
  /// to the user's `HOME` directory or `Directory.systemTemp`.
  static String resolveDefaultWorkingDirectory() {
    final cwd = Directory.current.absolute.path;
    if (cwd != '/' && cwd.isNotEmpty) {
      return p.normalize(cwd);
    }
    final home = Platform.environment['HOME'];
    if (home != null && home.trim().isNotEmpty) {
      return p.normalize(Directory(home.trim()).absolute.path);
    }
    return p.normalize(Directory.systemTemp.absolute.path);
  }

  /// Normalizes a user-supplied project working directory path, expanding `~`
  /// and resolving relative paths.
  static String normalizeProjectDirectory(String rawPath) {
    final trimmed = rawPath.trim();
    if (trimmed.isEmpty) {
      return resolveDefaultWorkingDirectory();
    }
    final normalized = normalizeWorkspacePath(trimmed);
    return normalized.isEmpty ? resolveDefaultWorkingDirectory() : normalized;
  }

  /// Extracts the command line string from a `run_command` [ToolCall].
  static String extractCommandLine(ToolCall toolCall) {
    final args = toolCall.args;
    final raw =
        args['CommandLine'] ??
        args['command_line'] ??
        args['command'] ??
        args['cmd'];
    return raw?.toString().trim() ?? '';
  }

  /// Extracts an optional short summary from a `run_command` [ToolCall].
  static String? extractToolSummary(ToolCall toolCall) {
    final args = toolCall.args;
    final raw = args['toolSummary'] ?? args['tool_summary'];
    final summary = raw?.toString().trim();
    return (summary != null && summary.isNotEmpty) ? summary : null;
  }

  /// Returns `true` if [toolCall] explicitly sets `BypassSandbox: true` (or
  /// equivalent snake_case key).
  static bool requestsBypassSandboxFlag(ToolCall toolCall) {
    final args = toolCall.args;
    final val =
        args['BypassSandbox'] ??
        args['bypass_sandbox'] ??
        args['disable_sandbox'];
    if (val is bool) return val;
    if (val is String) return val.toLowerCase() == 'true';
    return false;
  }

  static const List<String> _standardSystemExecutablePrefixes = [
    '/bin/',
    '/usr/bin/',
    '/sbin/',
    '/usr/sbin/',
    '/dev/null',
  ];

  /// Finds the first path token in [commandLine] that resolves outside
  /// [workspaces], or returns `null` if all referenced paths remain inside the
  /// workspace.
  static String? findOutsideWorkspacePathInCommand(
    String commandLine,
    List<String> workspaces,
  ) {
    if (commandLine.isEmpty || workspaces.isEmpty) return null;
    final primaryWorkspace = workspaces.first;
    final tokens = commandLine
        .split(RegExp(r'''[\s"'`;|&><()]+'''))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty);

    for (final token in tokens) {
      String? candidatePath;
      if (token == '~' || token.startsWith('~/')) {
        candidatePath = normalizeWorkspacePath(token);
      } else if (token == '..' ||
          token.startsWith('../') ||
          token.contains('/../')) {
        candidatePath = p.normalize(p.join(primaryWorkspace, token));
      } else if (token.startsWith('/') && token.length > 1) {
        final isStandardBinary = _standardSystemExecutablePrefixes.any(
          (prefix) => token == prefix || token.startsWith(prefix),
        );
        if (!isStandardBinary) {
          candidatePath = p.normalize(token);
        }
      }

      if (candidatePath != null && candidatePath.isNotEmpty) {
        final insideAny = workspaces.any(
          (ws) => isPathInWorkspace(candidatePath!, ws),
        );
        if (!insideAny) {
          return token;
        }
      }
    }
    return null;
  }

  /// Returns `true` when a `run_command` [toolCall] wants to escape the
  /// sandbox — either by setting `BypassSandbox: true` or by targeting a path
  /// outside [workspaces].
  static bool isSandboxEscapeToolCall(
    ToolCall toolCall,
    List<String> workspaces,
  ) {
    if (requestsBypassSandboxFlag(toolCall)) {
      return true;
    }
    final cmd = extractCommandLine(toolCall);
    return findOutsideWorkspacePathInCommand(cmd, workspaces) != null;
  }

  /// Builds a human-readable explanation for why [toolCall] requires user
  /// sandbox-escape review.
  static String describeSandboxEscapeReason(
    ToolCall toolCall,
    List<String> workspaces, {
    String? harnessReason,
  }) {
    if (requestsBypassSandboxFlag(toolCall)) {
      return 'Program requested BypassSandbox: true to run outside the OS sandbox '
          '(grants full filesystem and network access).';
    }
    final cmd = extractCommandLine(toolCall);
    final outsidePath = findOutsideWorkspacePathInCommand(cmd, workspaces);
    if (outsidePath != null) {
      final wsDisplay = workspaces.isNotEmpty ? workspaces.first : 'workspace';
      return 'Command references "$outsidePath" outside the project working directory ($wsDisplay).';
    }
    if (harnessReason != null && harnessReason.trim().isNotEmpty) {
      return harnessReason.trim();
    }
    return 'Program requested to run outside the project sandbox and requires user review.';
  }

  /// Invokes the registered [commandApprovalHandler] for a sandbox-escaping
  /// [toolCall]. Fails closed (`false`) if no handler is registered.
  Future<bool> requestCommandApproval(
    ToolCall toolCall, {
    required String threadId,
    required String threadTitle,
    String projectId = ChatThread.defaultProjectId,
    String? workingDirectory,
    String? reason,
  }) async {
    final handler = commandApprovalHandler;
    if (handler == null) {
      return false;
    }
    final effectiveDir = normalizeProjectDirectory(
      workingDirectory ??
          (workspaces != null && workspaces!.isNotEmpty
              ? workspaces!.first
              : resolveDefaultWorkingDirectory()),
    );
    final resolvedReason = describeSandboxEscapeReason(
      toolCall,
      [effectiveDir],
      harnessReason: reason,
    );
    return await handler(
      toolCall,
      threadId: threadId,
      threadTitle: threadTitle,
      projectId: projectId,
      workingDirectory: effectiveDir,
      reason: resolvedReason,
    );
  }

  /// Builds the [LocalAgentConfig] used to initialize an Antigravity [Agent]
  /// for the specified conversation thread and project working directory.
  ///
  /// - Sets `workspaces: [resolvedWorkingDirectory]` so the local harness uses
  ///   the project's working directory.
  /// - Enables the OS-level command sandbox via
  ///   `RunCommandConfig(enableSandbox: true)`.
  /// - Combines `workspaceOnly(resolvedWorkspaces)` (confining file tools to
  ///   the project directory), an `askUser` policy on `run_command` for commands
  ///   that want to escape the sandbox (`BypassSandbox: true` or outside-workspace
  ///   paths), `auto(handler: ...)` for harness-flagged sandbox escapes, and
  ///   `allowAll()` so in-sandbox commands run smoothly.
  LocalAgentConfig buildAgentConfig({
    required String threadId,
    required String threadTitle,
    String projectId = ChatThread.defaultProjectId,
    String? workingDirectory,
  }) {
    const definedApiKey = String.fromEnvironment('GEMINI_API_KEY');
    final resolvedApiKey = apiKey ??
        (definedApiKey.isNotEmpty
            ? definedApiKey
            : Platform.environment['GEMINI_API_KEY']);

    final List<String> resolvedWorkspaces;
    if (workingDirectory != null && workingDirectory.trim().isNotEmpty) {
      resolvedWorkspaces = [normalizeProjectDirectory(workingDirectory)];
    } else if (workspaces != null && workspaces!.isNotEmpty) {
      resolvedWorkspaces = normalizeWorkspacePaths(workspaces);
    } else {
      resolvedWorkspaces = [resolveDefaultWorkingDirectory()];
    }
    final activeDir = resolvedWorkspaces.first;

    final effectivePolicies = policies ??
        <Policy>[
          ...workspaceOnly(resolvedWorkspaces),
          askUser(
            BuiltinTools.runCommand.value,
            name: 'review_sandbox_escape',
            reason:
                'Command wants to escape the project sandbox and requires user review.',
            when: (toolCall) =>
                isSandboxEscapeToolCall(toolCall, resolvedWorkspaces),
            handler: (toolCall) => requestCommandApproval(
              toolCall,
              threadId: threadId,
              threadTitle: threadTitle,
              projectId: projectId,
              workingDirectory: activeDir,
            ),
          ) as Policy,
          auto(
            name: 'auto_sandbox_guard',
            handler: (ToolCall toolCall, [String? reason]) =>
                requestCommandApproval(
                  toolCall,
                  threadId: threadId,
                  threadTitle: threadTitle,
                  projectId: projectId,
                  workingDirectory: activeDir,
                  reason: reason,
                ),
          ),
          allowAll(),
        ];

    return LocalAgentConfig(
      apiKey: (resolvedApiKey != null && resolvedApiKey.isNotEmpty)
          ? resolvedApiKey
          : null,
      model: model,
      binaryPath: binaryPath,
      workspaces: resolvedWorkspaces,
      capabilities: CapabilitiesConfig(
        runCommandConfig: RunCommandConfig(enableSandbox: true),
      ),
      policies: effectivePolicies,
      systemInstructions: CustomSystemInstructions(
        title: 'MarkdownChatAssistant',
        text:
            '$systemInstructionText\n'
            'Active project working directory: "$activeDir" (project id: $projectId).\n'
            'Active conversation thread: "$threadTitle" (id: $threadId).\n\n'
            '$a2uiPromptSnippet',
      ),
    );
  }

  /// Returns the existing [AntigravityAgentSession] for [threadId] if its
  /// [threadTitle], [projectId], and [workingDirectory] are unchanged, or stops
  /// the stale session and creates a new one configured with [buildAgentConfig].
  AntigravityAgentSession getOrCreateSession({
    required String threadId,
    required String threadTitle,
    String projectId = ChatThread.defaultProjectId,
    String? workingDirectory,
  }) {
    final resolvedDir = normalizeProjectDirectory(
      workingDirectory ??
          (workspaces != null && workspaces!.isNotEmpty
              ? workspaces!.first
              : resolveDefaultWorkingDirectory()),
    );
    final desiredMeta = (
      threadTitle: threadTitle,
      projectId: projectId,
      workingDirectory: resolvedDir,
    );

    final existingSession = _sessions[threadId];
    final existingMeta = _sessionMetadata[threadId];
    if (existingSession != null && existingMeta == desiredMeta) {
      return existingSession;
    }

    if (existingSession != null) {
      _sessions.remove(threadId);
      _sessionMetadata.remove(threadId);
      unawaited(existingSession.stop());
    }

    final config = buildAgentConfig(
      threadId: threadId,
      threadTitle: threadTitle,
      projectId: projectId,
      workingDirectory: resolvedDir,
    );
    final newSession = _sessionBuilder(
      config,
      threadId: threadId,
      threadTitle: threadTitle,
    );
    _sessions[threadId] = newSession;
    _sessionMetadata[threadId] = desiredMeta;
    return newSession;
  }

  /// Sends [userPrompt] to the thread's Antigravity [AntigravityAgentSession]
  /// and streams Markdown chunks as they arrive.
  Stream<String> streamAssistantReply(
    String userPrompt, {
    required String threadId,
    required String threadTitle,
    String projectId = ChatThread.defaultProjectId,
    String? workingDirectory,
  }) async* {
    final session = getOrCreateSession(
      threadId: threadId,
      threadTitle: threadTitle,
      projectId: projectId,
      workingDirectory: workingDirectory,
    );
    yield* session.sendPrompt(userPrompt);
  }

  /// Sends [userPrompt] to the thread's Antigravity session and awaits the
  /// complete accumulated Markdown response.
  Future<String> generateAssistantReply(
    String userPrompt, {
    required String threadId,
    required String threadTitle,
    String projectId = ChatThread.defaultProjectId,
    String? workingDirectory,
  }) async {
    final buffer = StringBuffer();
    await for (final chunk in streamAssistantReply(
      userPrompt,
      threadId: threadId,
      threadTitle: threadTitle,
      projectId: projectId,
      workingDirectory: workingDirectory,
    )) {
      buffer.write(chunk);
    }
    return buffer.toString();
  }

  /// Stops and removes the [AntigravityAgentSession] associated with [threadId].
  Future<void> closeThreadSession(String threadId) async {
    _sessionMetadata.remove(threadId);
    final session = _sessions.remove(threadId);
    if (session != null) {
      await session.stop();
    }
  }

  /// Stops all active [AntigravityAgentSession] instances managed by this repository.
  Future<void> dispose() async {
    final activeSessions = _sessions.values.toList();
    _sessions.clear();
    _sessionMetadata.clear();
    for (final session in activeSessions) {
      await session.stop();
    }
  }

  /// Returns starter projects with explicit working directories for the
  /// Antigravity local harness.
  List<ChatProject> getStarterProjects() {
    final now = DateTime(2026, 11, 9, 10, 0);
    final defaultDir =
        (workspaces != null && workspaces!.isNotEmpty)
            ? normalizeProjectDirectory(workspaces!.first)
            : resolveDefaultWorkingDirectory();
    final tempDir = p.normalize(Directory.systemTemp.absolute.path);

    return [
      ChatProject(
        id: ChatThread.defaultProjectId,
        name: p.basename(defaultDir).isEmpty
            ? 'Default Workspace'
            : p.basename(defaultDir),
        workingDirectory: defaultDir,
        createdAt: now,
      ),
      ChatProject(
        id: 'project-sandbox-lab',
        name: 'Sandbox Scratchpad',
        workingDirectory: tempDir,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
    ];
  }

  /// Returns starter threads showcasing rich GitHub-Flavored Markdown features,
  /// project working directories, and the Antigravity SDK sandbox architecture.
  List<ChatThread> getStarterThreads() {
    final now = DateTime(2026, 11, 9, 10, 0);
    return [
      ChatThread(
        id: 'thread-showcase',
        projectId: ChatThread.defaultProjectId,
        title: 'Markdown Showcase',
        updatedAt: now,
        isAutoTitled: true,
        messages: [
          ChatMessage(
            id: 'msg-showcase-1',
            role: MessageRole.user,
            timestamp: now.subtract(const Duration(minutes: 10)),
            content:
                'Can you show me all the **Markdown** features supported in this macOS chat app?',
          ),
          ChatMessage(
            id: 'msg-showcase-2',
            role: MessageRole.assistant,
            timestamp: now.subtract(const Duration(minutes: 9)),
            content: '''# Welcome to macOS Markdown Chat

This workspace renders **GitHub-Flavored Markdown** using `flutter_markdown_plus` and is powered by the **Google Antigravity SDK** (`package:antigravity`).

## Typography & Inline Styles

You can combine **bold text**, *italic emphasis*, ~~strikethrough corrections~~, and `inline code` spans seamlessly.

> **Tip:** Every message bubble includes a one-click **Copy Markdown** action in its header so you can copy the raw source at any time.

## Lists & Workflows

- Project-scoped working directories (`workspaces`) for the Antigravity `localharness`
- Sandboxed command execution (`RunCommandConfig(enableSandbox: true)`) with interactive user review for sandbox-escaping programs
- Collapsible macOS split-view conversation sidebar
- Per-thread Antigravity `Agent` sessions and typing indicators
- Automatic thread titling from your first message
  1. Select or create a project working directory
  2. Create a new thread and send a prompt
  3. Watch the sidebar title and streaming Markdown reply update automatically

## Fenced Code Blocks

```dart
void main() {
  final features = ['Headings', 'Tables', 'Code Blocks', 'Blockquotes'];
  for (final item in features) {
    print('Supported: \$item');
  }
}
```

## GitHub-Style Tables

| Feature | Shortcut / Syntax | Status |
| :--- | :--- | :--- |
| Send Message | `Enter` / `Numpad Enter` | Ready |
| Insert Newline | `Shift + Enter` | Ready |
| Bold Formatting | `**text**` | Ready |
| Live Preview | Toolbar Toggle | Ready |

## Interactive A2UI v1.0 Surfaces

A2UI v1.0 JSON payloads stream live interactive `A2uiSurface` widgets inline alongside Markdown:

<a2ui-json>
[
  {
    "version": "1.0",
    "createSurface": {
      "surfaceId": "showcase-surface",
      "catalogId": "${BasicCatalog.v1_0Id}",
      "sendDataModel": true
    }
  },
  {
    "version": "1.0",
    "updateComponents": {
      "surfaceId": "showcase-surface",
      "components": [
        {
          "id": "root",
          "component": "Card",
          "child": "card_body"
        },
        {
          "id": "card_body",
          "component": "Column",
          "children": ["surface_heading", "live_checkbox", "action_button"]
        },
        {
          "id": "surface_heading",
          "component": "Text",
          "text": "**Live Interactive A2UI v1.0 Widget**"
        },
        {
          "id": "live_checkbox",
          "component": "CheckBox",
          "label": "Stream A2UI v1.0 surfaces inline",
          "value": {"@path": "/streamInline"}
        },
        {
          "id": "action_button",
          "component": "Button",
          "child": "action_label",
          "action": {
            "event": {
              "name": "verify_a2ui_surface",
              "context": {
                "streamInline": {"@path": "/streamInline"}
              }
            }
          }
        },
        {
          "id": "action_label",
          "component": "Text",
          "text": "Test Surface Action"
        }
      ]
    }
  },
  {
    "version": "1.0",
    "updateDataModel": {
      "surfaceId": "showcase-surface",
      "value": {
        "streamInline": true
      }
    }
  }
]
</a2ui-json>''',
          ),
        ],
      ),
      ChatThread(
        id: 'thread-architecture',
        projectId: ChatThread.defaultProjectId,
        title: 'macOS Desktop Architecture',
        updatedAt: now.subtract(const Duration(hours: 2)),
        isAutoTitled: true,
        messages: [
          ChatMessage(
            id: 'msg-arch-1',
            role: MessageRole.user,
            timestamp: now.subtract(const Duration(hours: 2, minutes: 5)),
            content:
                'How is the Antigravity backend, keyboard handling, and theme system structured for desktop?',
          ),
          ChatMessage(
            id: 'msg-arch-2',
            role: MessageRole.assistant,
            timestamp: now.subtract(const Duration(hours: 2)),
            content: '''### Keyboard, Theme & Antigravity Backend Architecture

Each conversation thread manages an isolated Antigravity `Agent` configured via `LocalAgentConfig` with the active project's working directory (`workspaces`), OS-level command sandboxing (`RunCommandConfig(enableSandbox: true)`), `workspaceOnly` file containment, and user review gates for commands that request to escape the sandbox.

We also guard `Enter` key submission against active **IME composition** regions so international input methods work reliably on macOS:

```dart
final composing = controller.value.composing;
final isImeComposing = composing.isValid && !composing.isCollapsed;
```

> When `Shift + Enter` is pressed, a newline is inserted at the current cursor position without submitting the draft.

| Theme Mode | Surface Style | Accent |
| :--- | :--- | :--- |
| **Light M3** | Crisp Cool Gray | Indigo / Deep Blue |
| **Dark M3** | Slate Charcoal | Soft Periwinkle |''',
          ),
        ],
      ),
    ];
  }

  /// Builds an A2UI v1.0 clarifying questions & parameter form response for
  /// interactive parameter collection, validation checks, and local/RPC
  /// function evaluation.
  static String buildClarifyingQuestionsReply({
    String surfaceId = 'clarifying-form-surface',
    String initialScope = 'Auth & API Service',
  }) {
    return '''### Clarifying Questions & Parameter Form

Please review and customize the execution parameters below before running the task. Required fields are validated live on the client, and preset actions mutate the surface `DataModel` via the `setSurfaceData` RPC function:

<a2ui-json>
[
  {
    "version": "1.0",
    "createSurface": {
      "surfaceId": "$surfaceId",
      "catalogId": "${BasicCatalog.v1_0Id}",
      "sendDataModel": true
    }
  },
  {
    "version": "1.0",
    "updateComponents": {
      "surfaceId": "$surfaceId",
      "components": [
        {
          "id": "root",
          "component": "Card",
          "child": "form_column"
        },
        {
          "id": "form_column",
          "component": "Column",
          "children": [
            "form_title",
            "scope_field",
            "target_picker",
            "features_picker",
            "concurrency_slider",
            "sandbox_checkbox",
            "live_summary",
            "button_row"
          ]
        },
        {
          "id": "form_title",
          "component": "Text",
          "text": "**Configure Task Parameters**"
        },
        {
          "id": "scope_field",
          "component": "TextField",
          "label": "Task Scope / Module",
          "placeholder": "e.g. lib/data/repositories",
          "value": {"@path": "/form/scope"},
          "checks": [
            {
              "condition": {
                "@call": "required",
                "args": {"value": {"@path": "/form/scope"}}
              },
              "message": "Task scope is required."
            }
          ]
        },
        {
          "id": "target_picker",
          "component": "ChoicePicker",
          "label": "Target Platform",
          "variant": "mutuallyExclusive",
          "displayStyle": "chips",
          "options": [
            {"label": "macOS Desktop", "value": "macos"},
            {"label": "Web WASM", "value": "web"},
            {"label": "CLI Binary", "value": "cli"}
          ],
          "value": {"@path": "/form/target"}
        },
        {
          "id": "features_picker",
          "component": "ChoicePicker",
          "label": "Verification Capabilities",
          "variant": "multipleSelection",
          "displayStyle": "checkbox",
          "options": [
            {"label": "Unit & Widget Tests", "value": "tests"},
            {"label": "Static Analysis", "value": "analyze"},
            {"label": "Benchmarks", "value": "benchmarks"}
          ],
          "value": {"@path": "/form/features"}
        },
        {
          "id": "concurrency_slider",
          "component": "Slider",
          "label": "Worker Concurrency",
          "min": 1,
          "max": 8,
          "steps": 7,
          "value": {"@path": "/form/concurrency"}
        },
        {
          "id": "sandbox_checkbox",
          "component": "CheckBox",
          "label": "Enforce strict OS sandbox containment",
          "value": {"@path": "/form/sandboxed"}
        },
        {
          "id": "live_summary",
          "component": "Text",
          "variant": "caption",
          "text": {
            "@call": "formatParameterSummary",
            "args": {
              "scope": {"@path": "/form/scope"},
              "target": {"@path": "/form/target"},
              "features": {"@path": "/form/features"},
              "concurrency": {"@path": "/form/concurrency"},
              "sandboxed": {"@path": "/form/sandboxed"}
            }
          }
        },
        {
          "id": "button_row",
          "component": "Row",
          "children": ["preset_button", "submit_button"]
        },
        {
          "id": "preset_button",
          "component": "Button",
          "child": "preset_label",
          "action": {
            "functionCall": {
              "@call": "setSurfaceData",
              "args": {
                "path": "/form/scope",
                "value": "Full Workspace Audit"
              }
            }
          }
        },
        {
          "id": "preset_label",
          "component": "Text",
          "text": "Use Audit Preset"
        },
        {
          "id": "submit_button",
          "component": "Button",
          "variant": "primary",
          "child": "submit_label",
          "checks": [
            {
              "condition": {
                "@call": "required",
                "args": {"value": {"@path": "/form/scope"}}
              },
              "message": "Enter a task scope before submitting."
            }
          ],
          "action": {
            "event": {
              "name": "submit_clarifying_parameters",
              "context": {
                "scope": {"@path": "/form/scope"},
                "target": {"@path": "/form/target"},
                "features": {"@path": "/form/features"},
                "concurrency": {"@path": "/form/concurrency"},
                "sandboxed": {"@path": "/form/sandboxed"},
                "summary": {
                  "@call": "formatParameterSummary",
                  "args": {
                    "scope": {"@path": "/form/scope"},
                    "target": {"@path": "/form/target"},
                    "features": {"@path": "/form/features"},
                    "concurrency": {"@path": "/form/concurrency"},
                    "sandboxed": {"@path": "/form/sandboxed"}
                  }
                }
              }
            }
          }
        },
        {
          "id": "submit_label",
          "component": "Text",
          "text": "Submit Parameters"
        }
      ]
    }
  },
  {
    "version": "1.0",
    "updateDataModel": {
      "surfaceId": "$surfaceId",
      "value": {
        "form": {
          "scope": "$initialScope",
          "target": ["macos"],
          "features": ["tests", "analyze"],
          "concurrency": 4,
          "sandboxed": true
        }
      }
    }
  }
]
</a2ui-json>''';
  }

  /// Builds an A2UI v1.0 response that invokes renderer-side RPC functions
  /// (`getWorkspaceInfo` and `listWorkspaceFiles`) via `callRendererFunction`
  /// alongside an interactive surface.
  static String buildWorkspaceRpcReply({
    String surfaceId = 'workspace-rpc-surface',
    String infoCallId = 'rpc-workspace-info-1',
    String filesCallId = 'rpc-workspace-files-1',
  }) {
    return '''### Bidirectional Renderer RPC Inspection

Invoking renderer-hosted `getWorkspaceInfo` and `listWorkspaceFiles` functions via `callRendererFunction`:

<a2ui-json>
[
  {
    "version": "1.0",
    "createSurface": {
      "surfaceId": "$surfaceId",
      "catalogId": "${BasicCatalog.v1_0Id}",
      "sendDataModel": true
    }
  },
  {
    "version": "1.0",
    "updateComponents": {
      "surfaceId": "$surfaceId",
      "components": [
        {
          "id": "root",
          "component": "Card",
          "child": "rpc_column"
        },
        {
          "id": "rpc_column",
          "component": "Column",
          "children": ["rpc_heading", "rpc_files_text", "rpc_refresh_btn"]
        },
        {
          "id": "rpc_heading",
          "component": "Text",
          "text": "**Workspace RPC Diagnostics**"
        },
        {
          "id": "rpc_files_text",
          "component": "Text",
          "text": {
            "@call": "formatString",
            "args": {
              "value": "Status: \${/rpc/status}"
            }
          }
        },
        {
          "id": "rpc_refresh_btn",
          "component": "Button",
          "child": "rpc_refresh_label",
          "action": {
            "functionCall": {
              "@call": "setSurfaceData",
              "args": {
                "path": "/rpc/status",
                "value": "Refreshed via local FunctionImplementation"
              }
            }
          }
        },
        {
          "id": "rpc_refresh_label",
          "component": "Text",
          "text": "Run Local RPC Mutation"
        }
      ]
    }
  },
  {
    "version": "1.0",
    "updateDataModel": {
      "surfaceId": "$surfaceId",
      "value": {
        "rpc": {
          "status": "Awaiting RPC execution"
        }
      }
    }
  },
  {
    "version": "1.0",
    "callRendererFunction": {
      "functionCallId": "$infoCallId",
      "surfaceId": "$surfaceId",
      "callFunction": {
        "@call": "getWorkspaceInfo",
        "catalogId": "${BasicCatalog.v1_0Id}",
        "args": {}
      }
    }
  },
  {
    "version": "1.0",
    "callRendererFunction": {
      "functionCallId": "$filesCallId",
      "surfaceId": "$surfaceId",
      "callFunction": {
        "@call": "listWorkspaceFiles",
        "catalogId": "${BasicCatalog.v1_0Id}",
        "args": {
          "limit": 10
        }
      }
    }
  }
]
</a2ui-json>''';
  }

  /// Builds a structured Markdown response tailored to [userPrompt] for
  /// deterministic previews and simulated test sessions.
  String buildAssistantReply(String userPrompt, {required String threadTitle}) {
    final trimmed = userPrompt.trim();
    final lower = trimmed.toLowerCase();
    if (lower.contains('clarifying') ||
        lower.contains('parameter form') ||
        lower.contains('parameters form')) {
      return buildClarifyingQuestionsReply();
    }
    if (lower.contains('workspace rpc') ||
        lower.contains('callrendererfunction') ||
        lower.contains('rpc function')) {
      return buildWorkspaceRpcReply();
    }
    final firstLine = trimmed.split('\n').first;
    final cleanTopic = firstLine.length > 48
        ? '${firstLine.substring(0, 48)}...'
        : firstLine;

    return '''### Response: $cleanTopic

Here is a structured **Markdown** breakdown for your message in *$threadTitle*:

- **Original length:** `${trimmed.length}` characters
- **Formatting:** Rendered with *GitHub-Flavored Markdown* (~GFM~ **enabled**)

> "$firstLine"

```markdown
# Raw Snippet Preview
$trimmed
```

| Metric | Value |
| :--- | :--- |
| Thread | `$threadTitle` |
| Characters | `${trimmed.length}` |''';
  }
}
