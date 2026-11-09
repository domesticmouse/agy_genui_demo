import 'dart:async';
import 'dart:io';

import 'package:antigravity/antigravity.dart';

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

/// Repository supplying starter conversation threads and managing per-thread
/// Google Antigravity SDK ([Agent] / [LocalAgentConfig]) sessions.
class ChatRepository {
  ChatRepository({
    AntigravitySessionBuilder? sessionBuilder,
    this.model,
    this.apiKey,
    this.binaryPath,
    this.workspaces,
    this.policies,
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

  final Map<String, AntigravityAgentSession> _sessions = {};

  static AntigravityAgentSession _defaultSessionBuilder(
    LocalAgentConfig config, {
    required String threadId,
    required String threadTitle,
  }) {
    return LocalAntigravityAgentSession(config: config);
  }

  /// Active thread IDs that currently have an initialized [AntigravityAgentSession].
  Iterable<String> get activeSessionThreadIds => _sessions.keys;

  /// Builds the [LocalAgentConfig] used to initialize an Antigravity [Agent]
  /// for the specified conversation thread.
  LocalAgentConfig buildAgentConfig({
    required String threadId,
    required String threadTitle,
  }) {
    const definedApiKey = String.fromEnvironment('GEMINI_API_KEY');
    final resolvedApiKey = apiKey ??
        (definedApiKey.isNotEmpty
            ? definedApiKey
            : Platform.environment['GEMINI_API_KEY']);

    return LocalAgentConfig(
      apiKey: (resolvedApiKey != null && resolvedApiKey.isNotEmpty)
          ? resolvedApiKey
          : null,
      model: model,
      binaryPath: binaryPath,
      workspaces: workspaces,
      policies: policies ?? confirmRunCommand(),
      systemInstructions: CustomSystemInstructions(
        title: 'MarkdownChatAssistant',
        text:
            '$systemInstructionText\n'
            'Active conversation thread: "$threadTitle" (id: $threadId).',
      ),
    );
  }

  /// Returns the existing [AntigravityAgentSession] for [threadId], or creates
  /// a new one configured with [buildAgentConfig].
  AntigravityAgentSession getOrCreateSession({
    required String threadId,
    required String threadTitle,
  }) {
    return _sessions.putIfAbsent(threadId, () {
      final config = buildAgentConfig(
        threadId: threadId,
        threadTitle: threadTitle,
      );
      return _sessionBuilder(
        config,
        threadId: threadId,
        threadTitle: threadTitle,
      );
    });
  }

  /// Sends [userPrompt] to the thread's Antigravity [AntigravityAgentSession]
  /// and streams Markdown chunks as they arrive.
  Stream<String> streamAssistantReply(
    String userPrompt, {
    required String threadId,
    required String threadTitle,
  }) async* {
    final session = getOrCreateSession(
      threadId: threadId,
      threadTitle: threadTitle,
    );
    yield* session.sendPrompt(userPrompt);
  }

  /// Sends [userPrompt] to the thread's Antigravity session and awaits the
  /// complete accumulated Markdown response.
  Future<String> generateAssistantReply(
    String userPrompt, {
    required String threadId,
    required String threadTitle,
  }) async {
    final buffer = StringBuffer();
    await for (final chunk in streamAssistantReply(
      userPrompt,
      threadId: threadId,
      threadTitle: threadTitle,
    )) {
      buffer.write(chunk);
    }
    return buffer.toString();
  }

  /// Stops and removes the [AntigravityAgentSession] associated with [threadId].
  Future<void> closeThreadSession(String threadId) async {
    final session = _sessions.remove(threadId);
    if (session != null) {
      await session.stop();
    }
  }

  /// Stops all active [AntigravityAgentSession] instances managed by this repository.
  Future<void> dispose() async {
    final activeSessions = _sessions.values.toList();
    _sessions.clear();
    for (final session in activeSessions) {
      await session.stop();
    }
  }

  /// Returns starter threads showcasing rich GitHub-Flavored Markdown features
  /// and the Antigravity SDK backend architecture.
  List<ChatThread> getStarterThreads() {
    final now = DateTime(2026, 11, 9, 10, 0);
    return [
      ChatThread(
        id: 'thread-showcase',
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

- Collapsible macOS split-view conversation sidebar
- Per-thread Antigravity `Agent` sessions and typing indicators
- Automatic thread titling from your first message
  1. Create a new thread
  2. Send a prompt
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

Each conversation thread manages an isolated Antigravity `Agent` configured via `LocalAgentConfig` and streams tokens from `ChatResponse.textStream`.

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
