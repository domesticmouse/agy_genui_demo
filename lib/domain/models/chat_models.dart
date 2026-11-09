import 'package:a2ui_agent/a2ui_agent.dart';
import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/foundation.dart';

/// Role of the author of a [ChatMessage].
enum MessageRole { user, assistant }

/// An immutable project that defines the working directory (`workspaces`)
/// for Antigravity `localharness` sessions in its conversation threads.
@immutable
class ChatProject {
  const ChatProject({
    required this.id,
    required this.name,
    required this.workingDirectory,
    required this.createdAt,
  });

  final String id;
  final String name;

  /// Absolute filesystem path configured as the workspace directory for the
  /// Antigravity local harness.
  final String workingDirectory;

  final DateTime createdAt;

  ChatProject copyWith({
    String? id,
    String? name,
    String? workingDirectory,
    DateTime? createdAt,
  }) {
    return ChatProject(
      id: id ?? this.id,
      name: name ?? this.name,
      workingDirectory: workingDirectory ?? this.workingDirectory,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// An immutable chat message containing raw Markdown / `<a2ui-json>` content
/// and parsed inline [AnswerPart]s (Markdown text, live [SurfaceModel]s, and
/// A2UI error diagnostics).
@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.parts = const <AnswerPart<ComponentImplementation>>[],
    this.hasParsedParts = false,
  });

  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;

  /// Ordered inline parts produced by `package:a2ui_agent`'s [StreamedAnswer]
  /// ([AnswerTextPart], [AnswerSurfacePart], and [AnswerErrorPart]).
  final List<AnswerPart<ComponentImplementation>> parts;

  /// Whether [parts] was populated by a [StreamedAnswer] parser.
  final bool hasParsedParts;

  bool get isUser => role == MessageRole.user;

  /// All live A2UI v1.0 [SurfaceModel] instances embedded in this message.
  List<SurfaceModel<ComponentImplementation>> get surfaces => [
    for (final part in parts)
      if (part is AnswerSurfacePart<ComponentImplementation>) part.surface,
  ];

  /// All A2UI parse/validation errors encountered in `<a2ui-json>` blocks of
  /// this message.
  List<A2uiError> get a2uiErrors => [
    for (final part in parts)
      if (part is AnswerErrorPart<ComponentImplementation>) part.error,
  ];

  ChatMessage copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    List<AnswerPart<ComponentImplementation>>? parts,
    bool? hasParsedParts,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      parts: parts ?? this.parts,
      hasParsedParts: hasParsedParts ?? this.hasParsedParts,
    );
  }
}

/// An immutable conversation thread scoped to a [ChatProject] with its own
/// messages and typing state.
@immutable
class ChatThread {
  const ChatThread({
    required this.id,
    required this.title,
    required this.messages,
    required this.updatedAt,
    this.projectId = defaultProjectId,
    this.isTyping = false,
    this.isAutoTitled = false,
  });

  static const String defaultProjectId = 'project-default';

  final String id;
  final String projectId;
  final String title;
  final List<ChatMessage> messages;
  final DateTime updatedAt;
  final bool isTyping;
  final bool isAutoTitled;

  ChatThread copyWith({
    String? id,
    String? projectId,
    String? title,
    List<ChatMessage>? messages,
    DateTime? updatedAt,
    bool? isTyping,
    bool? isAutoTitled,
  }) {
    return ChatThread(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      updatedAt: updatedAt ?? this.updatedAt,
      isTyping: isTyping ?? this.isTyping,
      isAutoTitled: isAutoTitled ?? this.isAutoTitled,
    );
  }
}

/// Represents a pending command or tool execution that wants to escape the
/// Antigravity sandbox and requires explicit user review before running.
@immutable
class PendingCommandReview {
  const PendingCommandReview({
    required this.id,
    required this.threadId,
    required this.threadTitle,
    required this.projectId,
    required this.workingDirectory,
    required this.toolName,
    required this.commandLine,
    required this.reason,
    required this.timestamp,
    this.toolSummary,
    this.bypassSandbox = false,
    this.rawArgs = const <String, dynamic>{},
  });

  final String id;
  final String threadId;
  final String threadTitle;
  final String projectId;
  final String workingDirectory;
  final String toolName;
  final String commandLine;
  final String? toolSummary;
  final bool bypassSandbox;
  final String reason;
  final Map<String, dynamic> rawArgs;
  final DateTime timestamp;
}
