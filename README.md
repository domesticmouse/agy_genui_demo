# macOS Markdown Chat (`agy_genui_demo`)

A macOS desktop Markdown chat application built with Flutter, [`flutter_markdown_plus`](https://pub.dev/packages/flutter_markdown_plus), and the [`antigravity`](https://pub.dev/packages/antigravity) SDK.

## Features

1. **Google Antigravity SDK Backend (`package:antigravity`)**
   - **Per-thread `Agent` sessions**: Each conversation thread manages an isolated Antigravity [`Agent`](https://pub.dev/packages/antigravity) configured via `LocalAgentConfig` and `CustomSystemInstructions`.
   - **Streaming Markdown responses**: Assistant replies stream live from `ChatResponse.textStream` into the active thread's Markdown message bubble while maintaining per-thread typing state.
   - **Lifecycle & error management**: Deleting a thread or disposing the view model cleanly stops the underlying `localharness` agent session (`agent.stop()`), and any SDK/validation errors are rendered as structured Markdown diagnostics.

2. **Collapsible macOS Split-View Conversation Sidebar**
   - Toggleable conversation thread sidebar (`Hide Sidebar` / `Show Sidebar`) in the top toolbar.
   - **Per-thread typing state**: Each thread tracks its own assistant generation status independently, displaying a live `Typing...` indicator in both the sidebar and the active conversation view.
   - **Automatic thread titling**: New threads start as `New Thread` and automatically derive a clean, readable title from the first user message (stripping Markdown formatting characters).
   - **Starter threads**: Preloaded with rich GitHub-Flavored Markdown conversations showcasing all supported formatting constructs.

3. **Rich Markdown Message Rendering & One-Click Copy**
   - Powered by `flutter_markdown_plus` with `md.ExtensionSet.gitHubFlavored`.
   - Supports headings (`#`–`######`), **bold**, *italic*, ~~strikethrough~~, `inline code`, fenced code blocks (` ``` `), blockquotes (`>`), ordered and unordered lists, and bordered GitHub-style tables.
   - Every message bubble includes a one-click **Copy Markdown** action that copies the raw Markdown source to the system clipboard.

4. **Desktop Markdown Composer**
   - **Formatting toolbar**: One-click insertion/wrapping for **Bold**, *Italic*, `Inline Code`, `Code Block`, `List`, and `Blockquote`.
   - **Live Markdown preview toggle**: Real-time `MarkdownBody` preview panel directly above the input field.
   - **Desktop keyboard shortcuts**:
     - `Enter` or `Numpad Enter` sends the message and automatically restores focus to the composer.
     - `Shift + Enter` inserts a newline at the cursor position.
     - **IME composition guard**: Ignores `Enter` key events while an active IME composition region (`TextEditingValue.composing`) is in progress.

5. **Responsive Top Toolbar & Material 3 Theme Switching**
   - Adapts seamlessly between wide desktop split-view layouts and compact window widths.
   - One-click **Light / Dark Material 3 theme** toggle.

---

## macOS Entitlements for Local Harness Spawning

To allow the macOS application to discover/download and spawn the Antigravity `localharness` binary (`~/.antigravity/bin/localharness`) and communicate over local WebSockets and HTTPS, both `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements` are configured with:

- `com.apple.security.app-sandbox`: `false` (permits spawning the external `localharness` subprocess and accessing `~/.antigravity`)
- `com.apple.security.network.client`: `true` (permits outbound WebSocket and Gemini API connections)
- `com.apple.security.network.server`: `true` (permits local harness and VM service socket bindings)

---

## Prerequisites (macOS Desktop)

- **Flutter SDK** (`^3.13.7` or compatible channel with macOS desktop support enabled)
- **Xcode** (with macOS SDK and CocoaPods installed for macOS desktop builds)
- **Gemini API Key** (`GEMINI_API_KEY`) for live Antigravity agent responses

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

Export `GEMINI_API_KEY` in your shell environment (or pass `--dart-define=GEMINI_API_KEY=...`):

```bash
export GEMINI_API_KEY="your_api_key_here"
flutter run -d macos
```

Or using `--dart-define`:

```bash
flutter run -d macos --dart-define=GEMINI_API_KEY="your_api_key_here"
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
