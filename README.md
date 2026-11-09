# macOS Markdown Chat (`agy_genui_demo`)

A macOS desktop Markdown chat application built with Flutter and [`flutter_markdown_plus`](https://pub.dev/packages/flutter_markdown_plus).

## Features

1. **Collapsible macOS Split-View Conversation Sidebar**
   - Toggleable conversation thread sidebar (`Hide Sidebar` / `Show Sidebar`) in the top toolbar.
   - **Per-thread typing state**: Each thread tracks its own assistant generation status independently, displaying a live `Typing...` indicator in both the sidebar and the active conversation view.
   - **Automatic thread titling**: New threads start as `New Thread` and automatically derive a clean, readable title from the first user message (stripping Markdown formatting characters).
   - **Starter threads**: Preloaded with rich GitHub-Flavored Markdown conversations showcasing all supported formatting constructs.

2. **Rich Markdown Message Rendering & One-Click Copy**
   - Powered by `flutter_markdown_plus` with `md.ExtensionSet.gitHubFlavored`.
   - Supports headings (`#`–`######`), **bold**, *italic*, ~~strikethrough~~, `inline code`, fenced code blocks (` ``` `), blockquotes (`>`), ordered and unordered lists, and bordered GitHub-style tables.
   - Every message bubble includes a one-click **Copy Markdown** action that copies the raw Markdown source to the system clipboard.

3. **Desktop Markdown Composer**
   - **Formatting toolbar**: One-click insertion/wrapping for **Bold**, *Italic*, `Inline Code`, `Code Block`, `List`, and `Blockquote`.
   - **Live Markdown preview toggle**: Real-time `MarkdownBody` preview panel directly above the input field.
   - **Desktop keyboard shortcuts**:
     - `Enter` or `Numpad Enter` sends the message and automatically restores focus to the composer.
     - `Shift + Enter` inserts a newline at the cursor position.
     - **IME composition guard**: Ignores `Enter` key events while an active IME composition region (`TextEditingValue.composing`) is in progress.

4. **Responsive Top Toolbar & Material 3 Theme Switching**
   - Adapts seamlessly between wide desktop split-view layouts and compact window widths.
   - One-click **Light / Dark Material 3 theme** toggle.

---

## Prerequisites (macOS Desktop)

- **Flutter SDK** (`^3.13.7` or compatible stable/main channel with macOS desktop support enabled)
- **Xcode** (with macOS SDK and CocoaPods installed for macOS desktop builds)

Verify macOS desktop support is enabled:

```bash
flutter config --enable-macos-desktop
flutter doctor
```

---

## macOS Build & Run Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Run on macOS Desktop (Debug / Hot Reload)

```bash
flutter run -d macos
```

### 3. Build a Release macOS Application (`.app`)

```bash
flutter build macos --release
```

The compiled macOS application bundle will be generated at:

```text
build/macos/Build/Products/Release/agy_genui_demo.app
```

---

## Static Analysis & Widget Tests

Run static analysis:

```bash
dart analyze
```

Run the widget test suite:

```bash
flutter test test/widget_test.dart
```
