import '../../domain/models/chat_models.dart';

/// Repository supplying starter conversation threads and simulated Markdown replies.
class ChatRepository {
  const ChatRepository();

  /// Returns starter threads showcasing rich GitHub-Flavored Markdown features.
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
            content: 'Can you show me all the **Markdown** features supported in this macOS chat app?',
          ),
          ChatMessage(
            id: 'msg-showcase-2',
            role: MessageRole.assistant,
            timestamp: now.subtract(const Duration(minutes: 9)),
            content: '''# Welcome to macOS Markdown Chat

This workspace renders **GitHub-Flavored Markdown** using `flutter_markdown_plus`.

## Typography & Inline Styles

You can combine **bold text**, *italic emphasis*, ~~strikethrough corrections~~, and `inline code` spans seamlessly.

> **Tip:** Every message bubble includes a one-click **Copy Markdown** action in its header so you can copy the raw source at any time.

## Lists & Workflows

- Collapsible macOS split-view conversation sidebar
- Per-thread typing indicators and state isolation
- Automatic thread titling from your first message
  1. Create a new thread
  2. Send a prompt
  3. Watch the sidebar title update automatically

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
            content: 'How is the keyboard handling and theme system structured for desktop?',
          ),
          ChatMessage(
            id: 'msg-arch-2',
            role: MessageRole.assistant,
            timestamp: now.subtract(const Duration(hours: 2)),
            content: '''### Keyboard & Theme Architecture

We guard `Enter` key submission against active **IME composition** regions so international input methods work reliably on macOS:

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

  /// Builds a rich Markdown response tailored to the user's prompt.
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
