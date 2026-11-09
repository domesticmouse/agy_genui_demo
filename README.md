# macOS Markdown & A2UI v1.0 Chat (`agy_genui_demo`)

A macOS desktop Markdown and A2UI v1.0 generative UI chat application built with Flutter, [`flutter_markdown_plus`](https://pub.dev/packages/flutter_markdown_plus), [`a2ui_core`](https://pub.dev/packages/a2ui_core), [`a2ui_agent`](https://pub.dev/packages/a2ui_agent), [`a2ui_flutter`](https://pub.dev/packages/a2ui_flutter), and the [`antigravity`](https://pub.dev/packages/antigravity) SDK.

## Features

1. **Google Antigravity SDK Backend (`package:antigravity`)**
   - **Per-thread `Agent` sessions**: Each conversation thread manages an isolated Antigravity [`Agent`](https://pub.dev/packages/antigravity) configured via `LocalAgentConfig` and `CustomSystemInstructions`.
   - **Streaming Markdown & A2UI v1.0 responses**: Assistant replies stream live from `ChatResponse.textStream` through `StreamedAnswer` into the active thread's message bubble while maintaining per-thread typing state.
   - **Lifecycle & error management**: Deleting a thread, changing a project's working directory, or disposing the view model cleanly stops the underlying `localharness` agent session (`agent.stop()`) and disposes per-thread A2UI renderers (`MessageProcessor.dispose()`).

2. **Live Streaming A2UI v1.0 Surfaces (`a2ui_core`, `a2ui_agent`, `a2ui_flutter`)**
   - **Catalog & Prompt Negotiation**: Configures the A2UI v1.0 basic catalog (`basicCatalog()`) extended with custom bidirectional `FunctionImplementation`s (`buildAppA2uiCatalog()`), `A2uiGenerator`, and `A2uiRequestProcessor` (`DirectJsonFormatFactory(progressiveKeys: {'text', 'label'})`) and injects `a2uiRequestProcessor.promptSnippet` into `CustomSystemInstructions`.
   - **Incremental `<a2ui-json>` Streaming**: Each thread owns a `MessageProcessor<ComponentImplementation>` (`A2uiProtocolVersion.v1_0`). As chunks arrive, `StreamedAnswer<ComponentImplementation>` splits responses into `AnswerTextPart`, `AnswerSurfacePart`, and `AnswerErrorPart`, healing incomplete JSON so `A2uiSurface` widgets mount and update live before `</a2ui-json>` even closes.
   - **Inline Rendering & Action Forwarding**: `MessageBubble` renders `AnswerTextPart` via `MarkdownBody`, `AnswerSurfacePart` via `A2uiMarkdown` + `A2uiSurface(key: ObjectKey(surface), surface: surface)`, and `AnswerErrorPart` as an inline diagnostic banner without halting subsequent surfaces. User actions emitted on `renderer.model.onAction` are captured per thread and can be forwarded to the agent as A2UI v1.0 `ActionMessage` payloads (with `a2uiRendererDataModel` metadata when `sendDataModel: true`).
   - **Interactive Clarifying Questions & Parameter Forms**: Supports interactive A2UI v1.0 parameter forms combining `Card`, `Column`, `ChoicePicker` (`mutuallyExclusive` chips and `multipleSelection` checkboxes), `TextField` with client-side validation `checks` (`required`, `length`, `regex`, `numeric`), `Slider`, `CheckBox`, reactive summary `Text` (`formatParameterSummary`), local preset `Button`s (`action.functionCall` -> `setSurfaceData`), and primary submit `Button`s (`action.event`) gated by validation `checks`.
   - **Bidirectional Renderer RPC Functions (`FunctionImplementation` & `RpcHandler`)**: Registers `GetWorkspaceInfoFunction` (`getWorkspaceInfo`), `ListWorkspaceFilesFunction` (`listWorkspaceFiles`), `SetSurfaceDataFunction` (`setSurfaceData`), and `FormatParameterSummaryFunction` (`formatParameterSummary`) with `AllowedCallers.rendererOrAgent` and wires `outboundListener` on each thread's `MessageProcessor` so the agent can call renderer functions (`callRendererFunction` -> `rendererFunctionResponse`) and the renderer can call agent functions (`callAgentFunction` -> `agentFunctionResponse`).

2. **Projects & Working Directory Management (`workspaces`)**
   - **Project-scoped threads**: Projects group conversation threads and set the explicit working directory (`workspaces: [project.workingDirectory]`) passed to `LocalAgentConfig` for the Antigravity `localharness`.
   - **Project switcher & workspace editor**: Switch between projects, create new projects with custom working directories, or update the active project's working directory from the sidebar (`New Project` / `Edit Project Working Directory`) or the top toolbar workspace badge.
   - **Safe macOS `.app` working directory fallback**: When launched from a terminal (`flutter run -d macos`), the default project uses `Directory.current.absolute.path`. When launched directly as a macOS `.app` bundle from Finder/LaunchServices (where the OS sets `Directory.current` to `/`), `ChatRepository.resolveDefaultWorkingDirectory()` safely falls back to `$HOME` (or `Directory.systemTemp`).

3. **Sandboxed Command Execution & Sandbox-Escape User Review UI**
   - **OS-level command sandboxing (`RunCommandConfig(enableSandbox: true)`)**: Enables the `localharness` OS-level command sandbox (`exebox`) so standard `run_command` invocations (`BypassSandbox: false`) run confined to the active project's working directory.
   - **Workspace file containment (`workspaceOnly`)**: Pairs `workspaceOnly(workspaces)` with `allowAll()` so file manipulation tools (`view_file`, `create_file`, `edit_file`) remain strictly confined to the project's working directory while in-sandbox commands are permitted.
   - **Interactive review for sandbox-escaping commands (`askUser` & `auto`)**: Commands that request to escape the sandbox (`BypassSandbox: true`, referencing paths outside the project working directory, or flagged by `auto(handler: ...)`) pause execution and present a **Sandbox Escape Review Required** banner above the composer. The user can inspect the exact command line, project workspace, and reason before choosing **Approve & Run** or **Deny**.

4. **Collapsible macOS Split-View Conversation Sidebar**
   - Toggleable conversation thread sidebar (`Hide Sidebar` / `Show Sidebar`) in the top toolbar.
   - **Per-thread typing & review state**: Each thread tracks its own assistant generation status (`Typing...`) and pending sandbox-escape review badges (`Review required`) independently in both the sidebar and the active conversation view.
   - **Automatic thread titling**: New threads start as `New Thread` and automatically derive a clean, readable title from the first user message (stripping Markdown formatting characters).
   - **Starter projects & threads**: Preloaded with starter projects and rich GitHub-Flavored Markdown conversations showcasing all supported formatting constructs.

5. **Rich Markdown Message Rendering & One-Click Copy**
   - Powered by `flutter_markdown_plus` with `md.ExtensionSet.gitHubFlavored`.
   - Supports headings (`#`–`######`), **bold**, *italic*, ~~strikethrough~~, `inline code`, fenced code blocks (` ``` `), blockquotes (`>`), ordered and unordered lists, and bordered GitHub-style tables.
   - Every message bubble includes a one-click **Copy Markdown** action that copies the raw Markdown source to the system clipboard.

6. **Desktop Markdown Composer**
   - **Formatting toolbar**: One-click insertion/wrapping for **Bold**, *Italic*, `Inline Code`, `Code Block`, `List`, and `Blockquote`.
   - **Live Markdown preview toggle**: Real-time `MarkdownBody` preview panel directly above the input field.
   - **Desktop keyboard shortcuts**:
     - `Enter` or `Numpad Enter` sends the message and automatically restores focus to the composer.
     - `Shift + Enter` inserts a newline at the cursor position.
     - **IME composition guard**: Ignores `Enter` key events while an active IME composition region (`TextEditingValue.composing`) is in progress.

7. **Responsive Top Toolbar & Material 3 Theme Switching**
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
