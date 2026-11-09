import 'dart:async';
import 'dart:io';

import 'package:antigravity/antigravity.dart';
import 'package:path/path.dart' as p;

import '../../domain/models/chat_models.dart';

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
/// per-thread Google Antigravity SDK ([Agent] / [LocalAgentConfig]) sessions.
class ChatRepository {
  ChatRepository({
    AntigravitySessionBuilder? sessionBuilder,
    this.model,
    this.apiKey,
    this.binaryPath,
    this.workspaces,
    this.policies,
    this.commandApprovalHandler,
    this.systemInstructionText = defaultSystemInstructions,
  }) : _sessionBuilder = sessionBuilder ?? _defaultSessionBuilder;

  /// Default system instructions guiding the Antigravity agent to respond in
  /// well-structured GitHub-Flavored Markdown.
  static const String defaultSystemInstructions =
      'You are a helpful AI assistant inside a macOS desktop Markdown chat application. '
      'Format all responses using clean, well-structured GitHub-Flavored Markdown '
      '(headings, bulleted or numbered lists, inline code, fenced code blocks with '
      'language tags, blockquotes, and tables when appropriate).';

  final AntigravitySessionBuilder _sessionBuilder;
  final String? model;
  final String? apiKey;
  final String? binaryPath;
  final List<String>? workspaces;
  final List<Policy>? policies;
  final String systemInstructionText;

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
            'Active conversation thread: "$threadTitle" (id: $threadId).',
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
| Live Preview | Toolbar Toggle | Ready |''',
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

  /// Builds a structured Markdown response tailored to [userPrompt] for
  /// deterministic previews and simulated test sessions.
  String buildAssistantReply(String userPrompt, {required String threadTitle}) {
    final trimmed = userPrompt.trim();
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
