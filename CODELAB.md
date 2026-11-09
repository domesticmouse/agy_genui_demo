# Codelab: Building a macOS Agentic Markdown & A2UI Chat App with Flutter & Antigravity SDK

This codelab walks through building `agy_genui_demo` from scratch in **`agy`** (Google Antigravity CLI), starting from `flutter create` and progressing through 5 focused acts using `/clear` and Git tags at each milestone, followed by a live end-to-end test inside the compiled Flutter macOS desktop app. It is designed both for capturing an [`asciinema`](https://asciinema.org/) terminal recording and for live-demoing the Flutter macOS app at each tagged stage.

All per-session transcripts and conversation logs are archived in [`prompts/`](file:///Users/brett/tmp/agy_genui_demo/prompts/README.md).

---

## Recorded Session Overview

| Act / Stage | Session ID | Started | Duration | Steps | Tool Calls | Git Tag | Conversation Log |
| :--- | :--- | :--- | :---: | :---: | :---: | :--- | :--- |
| **Act 1**: macOS Markdown Chat UI | `6ee8f6c2` [↗](conversation://6ee8f6c2-c4f9-499a-8b15-c88156684819) | `21:10` | `0:09:54` | 49 | 25 | `step-01-markdown-chat` | [`01-6ee8f6c2-please-build-a-macos-desktop-markdown-chat.md`](file:///Users/brett/tmp/agy_genui_demo/prompts/01-6ee8f6c2-please-build-a-macos-desktop-markdown-chat.md) |
| **Act 2**: Antigravity Dart SDK Backend | `8f4aafaf` [↗](conversation://8f4aafaf-21d5-4f03-8317-baca71b7cb79) | `21:20` | `0:13:11` | 70 | 46 | `step-02-antigravity-sdk` | [`02-8f4aafaf-please-add-the-antigravity-package-dependency-and.md`](file:///Users/brett/tmp/agy_genui_demo/prompts/02-8f4aafaf-please-add-the-antigravity-package-dependency-and.md) |
| **Act 3**: Project Workspaces & Sandbox Review | `10ad2b6c` [↗](conversation://10ad2b6c-c2ee-4fed-aeae-d2940571099e) | `21:34` | `0:32:44` | 175 | 96 | `step-03-projects-sandbox` | [`03-10ad2b6c-please-review-this-program-i-m-interested.md`](file:///Users/brett/tmp/agy_genui_demo/prompts/03-10ad2b6c-please-review-this-program-i-m-interested.md) |
| **Act 4**: Generative UI with A2UI v1.0 | `ba34877d` [↗](conversation://ba34877d-c6c6-4956-96f2-c4975bb83956) | `22:07` | `1:16:47` | 507 | 290 | `step-04-a2ui` | [`04-ba34877d-please-add-a2ui-core-a2ui-agent-and.md`](file:///Users/brett/tmp/agy_genui_demo/prompts/04-ba34877d-please-add-a2ui-core-a2ui-agent-and.md) |
| **Act 5**: Codebase Review & Hardening Fixups | `7407df5f` [↗](conversation://7407df5f-c580-4c1c-bf09-c63c545df255) | `23:24` | `0:11:35` | 75 | 50 | `step-05-fixup` | [`05-7407df5f-please-review-this-codebase.md`](file:///Users/brett/tmp/agy_genui_demo/prompts/05-7407df5f-please-review-this-codebase.md) |
| **Live Run**: In-App A2UI Trivia & Repo Audit | `7e5e8534` [↗](conversation://7e5e8534a057467540d3cd248b229b19) | `23:37` | `0:01:22` | 10 | 2 | *(live app run)* | [`06-7e5e8534-please-ask-a-multiple-choice-question.md`](file:///Users/brett/tmp/agy_genui_demo/prompts/06-7e5e8534-please-ask-a-multiple-choice-question.md) |
| **Export**: Transcript Extraction | `fd1fed76` [↗](conversation://fd1fed76-7832-4fe5-87e3-7202f1e6fe72) | `23:58` | — | — | — | — | [`07-fd1fed76-please-extract-agy-brain-transcripts-for-this.md`](file:///Users/brett/tmp/agy_genui_demo/prompts/07-fd1fed76-please-extract-agy-brain-transcripts-for-this.md) |

---

## 0. Terminal & Recording Setup

Start `asciinema`:

```bash
asciinema rec -i 2 agy-genui-codelab.cast
```

Inside the recorded shell session, scaffold the macOS Flutter project, create the initial commit and `step-00-scaffold` tag, and launch `agy`:

```bash
flutter create agy_genui_demo --platforms=macos
cd agy_genui_demo
git init
git add .
git commit -m "Initial commit"
git tag step-00-scaffold
agy
```

---

## Act 1: Build the macOS Markdown Chat UI (`step-01-markdown-chat`)

- **Session**: `6ee8f6c2-c4f9-499a-8b15-c88156684819` (`0:09:54`, 49 steps, 25 tool calls)
- **Conversation Log**: [`prompts/01-6ee8f6c2-please-build-a-macos-desktop-markdown-chat.md`](file:///Users/brett/tmp/agy_genui_demo/prompts/01-6ee8f6c2-please-build-a-macos-desktop-markdown-chat.md)

Turn the default Flutter counter app into a desktop split-view Markdown chat application powered by `flutter_markdown_plus`.

### Prompt 1.1 — Build the Markdown Chat App (Step 0)
```text
Please build a macOS desktop Markdown chat application in this project using `flutter_markdown_plus` with the following features:
1. A collapsible macOS split-view conversation thread sidebar with per-thread typing state, automatic thread titling, and starter threads showcasing rich Markdown.
2. Markdown message rendering (headings, bold/italic/strikethrough, inline and fenced code blocks, blockquotes, lists, and GitHub-style tables) with a one-click Copy Markdown button on every message bubble.
3. A Markdown composer that restores focus after sending, with a formatting toolbar (Bold, Italic, Inline Code, Code Block, List, Blockquote), a live Markdown preview toggle, and desktop keyboard shortcuts (`Enter` or `Numpad Enter` to send, `Shift + Enter` for a newline with an IME composition guard).
4. A responsive top toolbar with Light and Dark Material 3 theme switching.
5. Widget tests in `test/widget_test.dart` and macOS build/run instructions in `README.md`.
```

#### What `agy` Investigated & Built
1. **Skill Consultation & Dependencies**: Read the Flutter architecture (`flutter-apply-architecture-best-practices`), widget testing (`flutter-add-widget-test`), and static analysis (`dart-run-static-analysis`) skills, then ran `flutter pub add flutter_markdown_plus markdown`.
2. **Layered Architecture**:
   - **Domain** ([`lib/domain/models/chat_models.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/domain/models/chat_models.dart)): Immutable `ChatMessage`, `ChatThread`, and `MessageSender` models with `isTyping` and `isAutoTitled` tracking.
   - **Data** ([`lib/data/repositories/chat_repository.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/data/repositories/chat_repository.dart)): Pre-populated starter threads demonstrating GitHub-Flavored Markdown (tables, fenced code blocks, blockquotes, task lists) and deterministic Markdown reply generation.
   - **Presentation** ([`lib/ui/features/chat/view_models/chat_view_model.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/features/chat/view_models/chat_view_model.dart)): `ChangeNotifier` managing threads, active selection, sidebar collapse state, Light/Dark `ThemeMode`, live preview toggle, automatic thread titling from the first user prompt (stripping Markdown syntax), and independent per-thread typing timers.
   - **Theme & Widgets**: Material 3 Light/Dark desktop themes and custom `MarkdownStyleSheet` builder in [`app_theme.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/core/theme/app_theme.dart), [`top_toolbar.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/features/chat/views/widgets/top_toolbar.dart), [`thread_sidebar.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/features/chat/views/widgets/thread_sidebar.dart), [`message_bubble.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/features/chat/views/widgets/message_bubble.dart) (`MarkdownBody` with `md.ExtensionSet.gitHubFlavored` and a one-click Copy Markdown button), [`markdown_composer.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/features/chat/views/widgets/markdown_composer.dart) (formatting toolbar, live preview pane, `Enter`/`NumpadEnter` send vs. `Shift+Enter` newline with macOS IME composition guard), and [`chat_screen.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/features/chat/views/chat_screen.dart).
3. **Self-Correction During Widget Testing (Step 38)**: Running `dart format . && dart analyze && flutter test` caught a horizontal `RenderFlex` overflow in `MessageBubble`'s header `Row` when the sidebar was open on an 800px test viewport. `agy` fixed the layout in [`message_bubble.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/features/chat/views/widgets/message_bubble.dart) and re-ran the suite to green.

### Prompt 1.2 — Commit & Tag `step-01-markdown-chat` (Step 43)
```text
git commit and tag as step-01-markdown-chat
```
- **Executed**: `git add -A && git commit -m "Build macOS desktop Markdown chat application with flutter_markdown_plus" && git tag step-01-markdown-chat`

### Reset Context for Act 2
```text
/clear
```

---

## Act 2: Integrate the Antigravity Dart SDK (`step-02-antigravity-sdk`)

- **Session**: `8f4aafaf-21d5-4f03-8317-baca71b7cb79` (`0:13:11`, 70 steps, 46 tool calls)
- **Conversation Log**: [`prompts/02-8f4aafaf-please-add-the-antigravity-package-dependency-and.md`](file:///Users/brett/tmp/agy_genui_demo/prompts/02-8f4aafaf-please-add-the-antigravity-package-dependency-and.md)

Replace the simulated canned assistant replies with live streaming responses from the Google Antigravity Dart SDK (`package:antigravity`).

### Prompt 2.1 — Add & Wire Up `package:antigravity` (Step 0)
```text
Please add the `antigravity` package dependency and integrate it as the backend for the Markdown chat in this app. Update the macOS entitlements so the app can spawn the local harness, and update README.md and the widget tests.
```

#### What `agy` Investigated & Built
1. **SDK Inspection (`antigravity 0.18.1`)**: Located `antigravity: ^0.18.1` in `.pub-cache` and inspected `Agent`, `LocalAgentConfig`, `CustomSystemInstructions`, `ChatResponse`, `BinaryDiscovery`, `HarnessDownloader`, and `LocalConnectionStrategy`.
2. **macOS Entitlements for `localharness` Spawning**:
   - Discovered that `LocalConnectionStrategy` spawns `~/.antigravity/bin/localharness` via `Process.start`, reads `~/.antigravity` and environment variables (`GEMINI_API_KEY`), and opens a local loopback WebSocket plus outbound HTTPS connections.
   - Updated both [`macos/Runner/DebugProfile.entitlements`](file:///Users/brett/tmp/agy_genui_demo/macos/Runner/DebugProfile.entitlements) and [`macos/Runner/Release.entitlements`](file:///Users/brett/tmp/agy_genui_demo/macos/Runner/Release.entitlements) to set `com.apple.security.app-sandbox` to `false` and enable both `com.apple.security.network.client` and `com.apple.security.network.server`.
3. **Testability vs. `FakeAsync` Discovery (Step 46)**:
   - While inspecting `package:antigravity`'s `ChatResponse.chunks`, `agy` noticed it polls internally with `await Future.delayed(const Duration(milliseconds: 5))` inside a `while` loop, and `Agent.start()` spawns an OS process—both of which would hang Flutter's `FakeAsync` widget test zone if invoked directly.
   - Designed [`AntigravityAgentSession`](file:///Users/brett/tmp/agy_genui_demo/lib/data/repositories/chat_repository.dart) (`start()`, `sendPrompt()`, `stop()`) with production implementation [`LocalAntigravityAgentSession`](file:///Users/brett/tmp/agy_genui_demo/lib/data/repositories/chat_repository.dart) wrapping `Agent` + `LocalAgentConfig` + `CustomSystemInstructions` + `response.textStream`, and an injectable `AntigravitySessionBuilder` factory for deterministic streaming/error widget tests.
4. **Per-Thread Streaming & Cancellation**:
   - Updated [`ChatViewModel`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/features/chat/view_models/chat_view_model.dart) to stream tokens incrementally into the active or background thread bubble via `_upsertAssistantMessage`, track `_activeRequestIds` to ignore stale events after cancellation, format SDK errors as Markdown alerts, and call `closeThreadSession` when a thread is deleted.

### Prompt 2.2 — Commit & Tag `step-02-antigravity-sdk` (Step 66)
```text
git commit and tag as step-02-antigravity-sdk
```
- **Executed**: `git add -A && git commit -m "Integrate antigravity SDK backend and update macOS entitlements" && git tag step-02-antigravity-sdk`

### Reset Context for Act 3
```text
/clear
```

---

## Act 3: Project Workspaces (`CWD`) & Sandbox Escape Review UI (`step-03-projects-sandbox`)

- **Session**: `10ad2b6c-c2ee-4fed-aeae-d2940571099e` (`0:32:44`, 175 steps, 96 tool calls)
- **Conversation Log**: [`prompts/03-10ad2b6c-please-review-this-program-i-m-interested.md`](file:///Users/brett/tmp/agy_genui_demo/prompts/03-10ad2b6c-please-review-this-program-i-m-interested.md)

Investigate how `localharness` determines its working directory when launched from a macOS `.app` bundle, add **Projects** to control the workspace directory, and add a human-in-the-loop **Sandbox Escape Review** gate.

### Prompt 3.1 — Investigate `localharness` Initial Working Directory (Step 0)
```text
Please review this program. I'm interested in which directory the Antigravity local harness has as its initial working directory
```

#### Findings from `agy`'s Investigation (Step 32)
`agy` traced the workspace initialization chain across `agy_genui_demo` and `antigravity-0.18.1`:
1. **`workspaces: null` Defaulting**: `ChatRepository.buildAgentConfig` passed `workspaces: null` to `LocalAgentConfig`, which called `normalizeWorkspacePaths(workspaces, defaultToCwd: true)` $\rightarrow$ `[Directory.current.absolute.path]` and sent `"filesystem_workspace": { "directory": "<Directory.current.absolute.path>" }` in the WebSocket handshake.
2. **Child Process Inheritance**: `LocalConnectionStrategy.start` called `Process.start(resolvedBinaryPath, [])` without a `workingDirectory`, so `localharness` also inherited `Directory.current`.
3. **CLI vs. Finder `.app` Bundle Difference**:
   - When launched via `flutter run -d macos`, `Directory.current` is the project folder (`/Users/brett/tmp/agy_genui_demo`).
   - When launched from Finder / Dock (`agy_genui_demo.app`), macOS `launchd` sets the process working directory to **`/`** (root), dangerously exposing `/` as the agent's workspace root.
4. **Additional Code Review Findings**:
   - *Thread Title Locked In at Session Creation*: `threadTitle` was only embedded into `CustomSystemInstructions` on initial session creation.
   - *Shared Composer Draft Across Threads*: `MarkdownComposer` used a single `TextEditingController`, so typing an unsent draft in Thread A leaked into Thread B on thread switch.

### Prompt 3.2 — Add Project Workspaces & Sandbox Escape Review UI (Step 33)
```text
1. Add a concept of projects that set a working directory for the Antigravity harness.
2. I'm guessing workspaceOnly enables commands that are inside the sandbox. We should add UI that allows programs to be run that want to escape the sandbox, but only after review by the user.
3. Update README.md and add `/skills/` to `.gitignore`.
```

#### Deep Dive into `package:antigravity` Policies & the `localharness` Binary (Steps 34–86)
Before asking a clarifying UI question, `agy` inspected both the Dart SDK (`policy.dart`, `capabilities.dart`, `safety_patterns.md`) and the compiled Go binary (`~/.antigravity/bin/localharness`) using `strings` and Python byte-slice inspection:
- Verified that `workspaceOnly` only sets `workspace_containment: true` for file manipulation tools (`view_file`, `write_to_file`, `file_edit`, `find`, `grep_search`, `list_dir`)—it does **not** by itself enable or sandbox `run_command`.
- Found that `CapabilitiesConfig(runCommand: RunCommandConfig(enableSandbox: true))` enables the OS-level `exebox` sandbox on `run_command` and exposes the `BypassSandbox` parameter (`TerminalSandboxSection`) to the model.
- Combined `CapabilitiesConfig(runCommand: RunCommandConfig(enableSandbox: true))` with a layered policy in `ChatRepository.buildDefaultPolicies`:
  1. `workspaceOnly` (confining file tools to the project's `workingDirectory`),
  2. `askUser(BuiltinTools.runCommand.value, predicate: isSandboxEscapeToolCall, handler: ...)` (intercepting any `run_command` that sets `BypassSandbox: true` / `disable_sandbox: true` or references paths outside the project workspace),
  3. `auto(handler: ...)` (auto-approving safe in-sandbox commands while routing risky commands to the user review handler), and
  4. `allowAll()` (permitting normal in-workspace file operations and in-sandbox commands).

#### Interactive Clarification (`ask_question` — Steps 88–89)
When `agy` asked **"How should projects and conversation threads be organized in the UI?"**, Option 1 was selected:
- `(Recommended) Projects group threads (project switcher + New Project dialog with a working directory path, filtering threads by active project)`

#### What `agy` Built (Steps 90–118)
- Added `ChatProject` and `PendingCommandReview` models in [`chat_models.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/domain/models/chat_models.dart).
- Added `ChatRepository.resolveDefaultWorkingDirectory()` (falling back to `$HOME` or `Directory.systemTemp` when `Directory.current` is `/`) and `isSandboxEscapeToolCall` / `describeSandboxEscapeReason` in [`chat_repository.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/data/repositories/chat_repository.dart).
- Created [`project_dialog.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/features/chat/views/widgets/project_dialog.dart) (create/edit project name and workspace path with quick-pick directory presets) and [`sandbox_review_banner.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/features/chat/views/widgets/sandbox_review_banner.dart) (amber human-in-the-loop review banner showing the command line, workspace directory, escape reason, and **Deny** / **Approve & Run** buttons backed by a `Completer<bool>`).
- Updated [`thread_sidebar.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/features/chat/views/widgets/thread_sidebar.dart) and [`top_toolbar.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/features/chat/views/widgets/top_toolbar.dart) with the project switcher, active `CWD` badge, and pending review counts.

### Prompt 3.3 — Fix Issues Highlighted in the Review (Step 121)
Address the observations surfaced during the Prompt 3.1 codebase review (per-thread composer draft isolation and session recreation on thread rename):
```text
Please fix issues highlighted in the review
```
- **What `agy` Fixed (Steps 122–164)**:
  1. Tracked `_SessionMetadata` (`threadTitle`, `projectId`, `workingDirectory`) in [`ChatRepository`](file:///Users/brett/tmp/agy_genui_demo/lib/data/repositories/chat_repository.dart) and added `ChatViewModel.renameThread` so renaming a thread or changing a project's working directory cleanly stops and refreshes the thread's `AntigravityAgentSession`.
  2. Added per-thread draft storage (`_threadDrafts` map, `draftForThread`, `updateThreadDraft`) in [`ChatViewModel`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/features/chat/view_models/chat_view_model.dart) and synchronized [`MarkdownComposer`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/features/chat/views/widgets/markdown_composer.dart) when `activeThreadId` changes.

### Prompt 3.4 — Commit & Tag `step-03-projects-sandbox` (Step 167)
```text
git commit and tag as step-03-projects-sandbox
```
- **Executed**: `git add .gitignore README.md pubspec.yaml pubspec.lock lib/ test/ && git commit -m "Add project workspaces, sandbox-escape review UI, and per-thread drafts" && git tag step-03-projects-sandbox`

### Reset Context for Act 4
```text
/clear
```

---

## Act 4: Generative UI with A2UI (`step-04-a2ui`)

- **Session**: `ba34877d-c6c6-4956-96f2-c4975bb83956` (`1:16:47`, 507 steps, 290 tool calls)
- **Conversation Log**: [`prompts/04-ba34877d-please-add-a2ui-core-a2ui-agent-and.md`](file:///Users/brett/tmp/agy_genui_demo/prompts/04-ba34877d-please-add-a2ui-core-a2ui-agent-and.md)

Add Agent-to-UI (A2UI v1.0) generative UI surfaces (`a2ui_core`, `a2ui_agent`, `a2ui_flutter`), explore the package seamlines, and implement interactive clarifying parameter forms plus bidirectional renderer RPC functions.

### Prompt 4.1 — Add `a2ui_core`, `a2ui_agent`, and `a2ui_flutter` (Step 0)
```text
Please add `a2ui_core`, `a2ui_agent`, and `a2ui_flutter` to this project and integrate A2UI v1.0 surface rendering into the chat UI so `<a2ui-json>` blocks stream live interactive `A2uiSurface` widgets inline alongside Markdown.
```

#### What `agy` Investigated, Built & Debugged (Steps 1–292)
1. **Added Dependencies**: Added `a2ui_core: ^0.5.0`, `a2ui_agent: ^0.1.0`, and `a2ui_flutter: ^0.1.0` to [`pubspec.yaml`](file:///Users/brett/tmp/agy_genui_demo/pubspec.yaml).
2. **Streaming A2UI v1.0 Pipeline**:
   - Configured `A2uiGenerator` and `A2uiRequestProcessor` in [`ChatRepository`](file:///Users/brett/tmp/agy_genui_demo/lib/data/repositories/chat_repository.dart) using `DirectJsonFormatFactory(progressiveKeys: {'text', 'label'})` and `CatalogConfig.fromCatalog(a2uiCatalog, version: A2uiProtocolVersion.v1_0)`, injecting `a2uiPromptSnippet` into the agent's `CustomSystemInstructions`.
   - Managed a persistent per-thread `MessageProcessor<ComponentImplementation>` in [`ChatViewModel`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/features/chat/view_models/chat_view_model.dart) wrapped by `StreamedAnswer<ComponentImplementation>` (`RendererState.of(renderer)`) so `<a2ui-json>` blocks (`createSurface`, `updateComponents`, `updateDataModel`, `deleteSurface`) mutate `SurfaceModel` signals reactively in real time as chunks arrive.
   - Updated [`MessageBubble`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/features/chat/views/widgets/message_bubble.dart) to render `AnswerTextPart` via `MarkdownBody`, `AnswerSurfacePart` via `_InlineA2uiSurfaceCard` (`A2uiSurface` + `A2uiMarkdown`), and `AnswerErrorPart` via `_InlineA2uiErrorBanner`, plus stripped `<a2ui-json>` blocks from sidebar preview snippets in [`ThreadSidebar`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/features/chat/views/widgets/thread_sidebar.dart).
3. **Three Subtle Bugs Diagnosed & Fixed During Testing**:
   - **A2UI v1.0 `Text.variant` Schema Constraint (Steps 145–151)**: `BasicCatalog.v1_0` restricts `Text.variant` to `'caption'` or `'body'` (unlike v0.8 which allowed `'h5'`). Using `'h5'` caused `PayloadValidator` to reject the `updateComponents` message; changing `variant` to `'body'` with Markdown headings resolved validation.
   - **Inline Backtick `<a2ui-json>` Tag Collision in `DirectJsonParser` (Steps 163–171)**: `a2ui_agent`'s `DirectJsonParser` intentionally strips surrounding backticks around `` `<a2ui-json>` `` to tolerate LLMs that wrap tags in inline code. Having prose text mention literal `` `<a2ui-json>` `` before the real block caused the parser to open the JSON block prematurely inside the sentence. `agy` updated the prose description to avoid literal unclosed tag tokens.
   - **`A2uiMarkdown` Gesture & Layout Inside `OutlinedButton` (Steps 194–286)**: Inside `_InlineA2uiSurfaceCard`, wrapping `A2uiSurface` with `A2uiMarkdown` caused `Button` child `Text` components to render via `MarkdownBody` with `selectable: true` and full-width column stretching, which intercepted pointer taps and left-aligned button labels so `tester.tap` at the button's center missed the text and failed to fire `OutlinedButton.onPressed`. Setting `selectable: false` and `fitContent: true` on `A2uiMarkdown`'s `MarkdownBody` in [`message_bubble.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/features/chat/views/widgets/message_bubble.dart) fixed button centering and tap propagation.

### Prompt 4.2 — Research Package Seamlines (Step 293)
```text
Please research the seamlines between a2ui_core, a2ui_agent and a2ui_flutter. Explain when to use each.
```

#### Architectural Summary Produced by `agy` (Step 303)
- **`a2ui_core` (Pure Dart — Headless Protocol, State & Expression Engine)**: Owns wire messages (`AgentToRendererMessage` / `RendererToAgentMessage`), `Catalog<T, F>`, `MessageProcessor<T>`, `SurfaceGroupModel<T>`, `SurfaceModel<T>`, `DataModel`, and `NodeResolver<T>` backed by `preact_signals`.
- **`a2ui_agent` (Pure Dart — Prompting, Stream Parsing & JSON Healing)**: Owns `A2uiGenerator`, `A2uiRequestProcessor`, `DirectJsonFormatFactory` / `ExpressFormatFactory`, `RendererState`, and `StreamedAnswer<T>`.
- **`a2ui_flutter` (Flutter SDK — Widget Builders & Reactive `A2uiSurface`)**: Owns `ComponentImplementation` (`ComponentProps` $\rightarrow$ `Widget`), `basicCatalog()`, `A2uiSurface`, `NodeView`, and `A2uiMarkdown`.
- **The 4 Seamlines**:
  1. `CatalogImplementation` $\leftrightarrow$ `CatalogConfig.fromCatalog` (`a2ui_flutter` $\rightarrow$ `a2ui_core` $\rightarrow$ `a2ui_agent`)
  2. `MessageProcessor<T>` $\leftrightarrow$ `RendererState` & `StreamedAnswer<T>` (`a2ui_core` $\leftrightarrow$ `a2ui_agent`)
  3. `SurfaceModel<ComponentImplementation>` $\leftrightarrow$ `A2uiSurface` (`a2ui_core` $\leftrightarrow$ `a2ui_flutter`)
  4. `onAction` & `outboundListener` $\leftrightarrow$ `ActionMessage` / `RendererFunctionResponseMessage` + `getRendererDataModel` (`a2ui_flutter` $\rightarrow$ `a2ui_core` $\rightarrow$ `a2ui_agent`)

### Prompt 4.3 — Explore Capabilities for This Codebase (Step 304)
```text
Give me some options for utilising this capability in the current codebase
```
- `agy` proposed 6 options (Step 305):
  1. Live Two-Way Action Loop (`Button` $\rightarrow$ Agent Turn + `a2uiRendererDataModel` Sync)
  2. Custom Workspace & Developer Catalog (`CatalogImplementation` Extensions)
  3. Persistent Split-Pane "Surface Canvas" Drawer
  4. Self-Healing Validation Loop (Automatic LLM Repair on `AnswerErrorPart`)
  5. Interactive Clarifying Questions & Parameter Forms (Basic Catalog)
  6. Bidirectional Renderer RPC Functions (`FunctionImplementation`) / A2UI Express Format Toggle

### Prompt 4.4 — Implement Clarifying Parameter Forms & Bidirectional Renderer RPC Functions (Step 306)
```text
Please implement:
- Interactive Clarifying Questions & Parameter Forms (Basic Catalog)
- Bidirectional Renderer RPC Functions (`FunctionImplementation`)
```

#### What `agy` Built (Steps 307–498)
1. **Bidirectional Renderer RPC Functions ([`lib/data/catalog/renderer_rpc_functions.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/data/catalog/renderer_rpc_functions.dart))**:
   - Extended `basicCatalog()` via `buildAppA2uiCatalog` with 4 custom `FunctionImplementation`s registered with `AllowedCallers.rendererOrAgent`:
     - `GetWorkspaceInfoFunction` (`getWorkspaceInfo`): Returns a `WorkspaceInfoSnapshot` map (`projectId`, `projectName`, `workingDirectory`, `activeThreadId`, `activeThreadTitle`, `themeMode`, `surfaceIds`).
     - `ListWorkspaceFilesFunction` (`listWorkspaceFiles`): Lists files in the active project's working directory with optional `extension` and `limit` filters.
     - `SetSurfaceDataFunction` (`setSurfaceData`): Mutates any JSON Pointer `path` in the surface's `DataContext` (`context.set(path, value)`) for instant local preset/reset `Button` `action.functionCall`s or agent-triggered `callRendererFunction` calls.
     - `FormatParameterSummaryFunction` (`formatParameterSummary`): Reactively formats form values (`scope`, `target`, `features`, `concurrency`, `sandboxed`) into a live preview string.
2. **Interactive Clarifying Parameter Form ([`chat_repository.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/data/repositories/chat_repository.dart) & [`chat_screen.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/features/chat/views/chat_screen.dart))**:
   - Added quick-prompt chips (`Clarifying parameter form` and `Run workspace RPC function`) and builders combining `Card`, `Column`, `TextField` (with `required` validation check), `ChoicePicker` (`mutuallyExclusive` chips and `multipleSelection` checkboxes), `Slider`, `CheckBox`, a live `formatParameterSummary` reactive `Text` binding, a `Use Audit Preset` `Button` invoking `setSurfaceData` locally, and a `Submit Parameters` `Button` gated by validation `checks`.
3. **ViewModel RPC Wiring ([`chat_view_model.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/features/chat/view_models/chat_view_model.dart))**:
   - Wired `outboundListener` on each thread's `MessageProcessor` to capture `RendererToAgentMessage`s (`RendererFunctionResponseMessage` and `CallAgentFunctionMessage`) and added `sendRpcMessageToAgent` and `callAgentFunction`.

### Prompt 4.5 — Commit & Tag `step-04-a2ui` (Step 499)
```text
git commit and tag as step-04-a2ui
```
- **Executed**: `git add -A && git commit -m "Add A2UI v1.0 streaming surfaces, clarifying forms, and bidirectional RPC functions" && git tag step-04-a2ui`

### Reset Context for Act 5
```text
/clear
```

---

## Act 5: Codebase Review & Hardening Fixups (`step-05-fixup`)

- **Session**: `7407df5f-c580-4c1c-bf09-c63c545df255` (`0:11:35`, 75 steps, 50 tool calls)
- **Conversation Log**: [`prompts/05-7407df5f-please-review-this-codebase.md`](file:///Users/brett/tmp/agy_genui_demo/prompts/05-7407df5f-please-review-this-codebase.md)

Start a fresh session to audit the full codebase and resolve the surfaced issues.

### Prompt 5.1 — Audit the Full Codebase (Step 0)
```text
please review this codebase
```

#### Issues Surfaced by `agy` (Step 33)
1. **A2UI Surface Actions & Outbound RPC Messages Disabled in Live App**: `ChatViewModel` defaulted `forwardSurfaceActionsToAgent: false` and `forwardRpcMessagesToAgent: false` to keep unit tests manual, and `main.dart` instantiated `ChatViewModel()` without enabling them—so clicking surface buttons in the live desktop app recorded the action locally without forwarding it to `localharness`.
2. **Stream Self-Cancellation on Multi-RPC Turns**: When `forwardRpcMessagesToAgent` was enabled, `_handleOutboundRpcMessage` synchronously called `sendRpcMessageToAgent` $\rightarrow$ `_streamAssistantTurn` while `StreamedAnswer.feed(chunk)` was still mid-stream (or when two `callRendererFunction` calls like `getWorkspaceInfo` + `listWorkspaceFiles` fired in one block), immediately cancelling the active stream subscription.
3. **Auto-Titling Overwrote Custom Titles on Empty Threads**: `shouldAutoTitle` checked `!current.isAutoTitled || current.messages.isEmpty`, overwriting a user's custom thread rename on the first message.
4. **Sandbox-Escape Path Heuristics Edge Cases**: `findOutsideWorkspacePathInCommand` missed `--flag=/outside/path`, `KEY=/outside/path`, `$HOME`/`$TMPDIR` variable expansions, and trailing `/..` segments, while flagging single-segment `/regex/` literals (e.g. `awk '/pattern/'`) as false-positive absolute paths.
5. **Unbounded Synchronous Directory Walk**: `ListWorkspaceFilesFunction.execute` ran `directory.listSync()` without an entry cap or cancellation check before sorting and slicing.

### Prompt 5.2 — Fix Surfaced Issues (Step 34)
```text
please fix issues
```

#### What `agy` Fixed (Steps 35–68)
- Enabled `forwardSurfaceActionsToAgent: true` and `forwardRpcMessagesToAgent: true` in [`lib/main.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/main.dart).
- Added `_enqueueOutboundRpcForForwarding`, `_flushPendingAutoForwardRpcMessages`, and batched `sendRpcMessagesToAgent` in [`chat_view_model.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/features/chat/view_models/chat_view_model.dart) so outbound RPC messages emitted during streaming are queued and flushed together as a single `RendererToAgentMessagePayload` turn once `onDone` fires.
- Fixed `shouldAutoTitle` in [`chat_view_model.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/features/chat/view_models/chat_view_model.dart) to check `!current.isAutoTitled`.
- Hardened `ChatRepository.findOutsideWorkspacePathInCommand` in [`chat_repository.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/data/repositories/chat_repository.dart) and added unit tests in [`test/widget_test.dart`](file:///Users/brett/tmp/agy_genui_demo/test/widget_test.dart) covering `--output=/etc/hosts`, `$HOME/.ssh/id_rsa`, `subdir/../..` vs. `subdir/..`, and `awk '/pattern/'`.
- Bounded `ListWorkspaceFilesFunction.execute` in [`renderer_rpc_functions.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/data/catalog/renderer_rpc_functions.dart) with `maxScannedEntries = 1000` and `cancellationSignal?.isCancelled` checks, and reset `_copied` state in [`message_bubble.dart`](file:///Users/brett/tmp/agy_genui_demo/lib/ui/features/chat/views/widgets/message_bubble.dart) when `widget.message.id` changes.

### Prompt 5.3 — Commit & Tag `step-05-fixup` (Step 69)
```text
git commit and tag as step-05-fixup
```
- **Executed**: `git add -A && git commit -m "Fix A2UI RPC batching, auto-forwarding, thread auto-titling, and sandbox path heuristics" && git tag step-05-fixup`

### Finish the CLI Recording
Exit `agy` (`Ctrl+D` twice or `/exit`) and stop `asciinema` (`Ctrl+D` or `exit`).

---

## Live Verification Session: Running the macOS App End-to-End

- **Session**: `7e5e8534a057467540d3cd248b229b19` (`0:01:22`, 10 steps, 2 tool calls, recorded under `~/.gemini/antigravity/brain/` by the app's spawned `localharness`)
- **Conversation Log**: [`prompts/06-7e5e8534-please-ask-a-multiple-choice-question.md`](file:///Users/brett/tmp/agy_genui_demo/prompts/06-7e5e8534-please-ask-a-multiple-choice-question.md)

When the completed Flutter macOS desktop app was launched (`flutter run -d macos`), it spawned `localharness` in the `/Users/brett/tmp/agy_genui_demo` project workspace and executed a live 3-turn verification conversation:

1. **Turn 1 — Interactive A2UI v1.0 Multiple-Choice Trivia Surface (Steps 0–1)**:
   - **User Prompt in App**: `Please ask a multiple choice question`
   - **Live Agent Response**: Streamed a Markdown header (`### 🧠 Computer Science Trivia`) followed by an inline `<a2ui-json>` v1.0 surface (`trivia-question-surface`) containing a `Card`, `ChoicePicker` (`variant: "mutuallyExclusive"` with 4 programming language options bound to `/trivia/answer`), and a `Submit Answer` `Button` gated by a `@call: "required"` validation check.
2. **Turn 2 — Automatic Two-Way A2UI Action & DataModel Round-Trip (Steps 2–3)**:
   - Selecting **Java** in the `A2uiSurface` `ChoicePicker` and clicking **Submit Answer** automatically dispatched the `ActionMessage` + `a2uiRendererDataModel` back to `localharness` (verifying the Act 5 `forwardSurfaceActionsToAgent: true` fix):
     ```json
     {
       "a2ui": {
         "messages": [{
           "version": "1.0",
           "action": {
             "name": "submitAnswer",
             "surfaceId": "trivia-question-surface",
             "sourceComponentId": "submitButton",
             "context": { "selected": ["java"] },
             "userMessage": "Submitting trivia answer"
           }
         }]
       },
       "metadata": {
         "a2uiRendererDataModel": {
           "version": "1.0",
           "surfaces": {
             "showcase-surface": { "streamInline": true },
             "trivia-question-surface": { "trivia": { "answer": ["java"] } }
           }
         }
       }
     }
     ```
   - **Live Agent Response**: Confirmed `### 🎉 Correct! That is right! **Java** is the correct answer!` and explained the history of Oak $\rightarrow$ Java (1991–1995).
3. **Turn 3 — Sandboxed Workspace Inspection & Live Clarifying Parameter Form (Steps 4–9)**:
   - **User Prompt in App**: `Please review this codebase`
   - **Live Agent Actions**: Executed `ls -la` and `find lib -maxdepth 3 -not -path '*/.*'` inside the `localharness` sandbox (auto-approved without requiring a sandbox-escape prompt because both commands stayed within the project workspace), summarized the `agy_genui_demo` architecture, and emitted an interactive `<a2ui-json>` v1.0 **Codebase Review Clarifying Parameter Form** (`TextField` for `/review/scope`, `ChoicePicker` chips for `/review/target` and `/review/features`, `Slider` for `/review/concurrency`, `CheckBox` for `/review/sandboxed`, a reactive `@call: "formatParameterSummary"` preview, and a `Start Codebase Review 🔍` `Button` gated by `@call: "required"`).

---

## Live-Demo Guide: Switching Between Tagged Milestones

Each milestone is tagged in Git so you can move the app forward or backward alongside your `asciinema` playback:

| Git Tag | Act | Session Log | What to Demo Live in the macOS App |
| :--- | :---: | :--- | :--- |
| `step-00-scaffold` | Setup | — | Default Flutter counter app (`flutter create --platforms=macos`) |
| `step-01-markdown-chat` | Act 1 | [`01-6ee8f6c2`](file:///Users/brett/tmp/agy_genui_demo/prompts/01-6ee8f6c2-please-build-a-macos-desktop-markdown-chat.md) | Split-view thread sidebar, Markdown composer toolbar, live preview, Light/Dark theme, simulated replies |
| `step-02-antigravity-sdk` | Act 2 | [`02-8f4aafaf`](file:///Users/brett/tmp/agy_genui_demo/prompts/02-8f4aafaf-please-add-the-antigravity-package-dependency-and.md) | Real streaming Gemini responses via `package:antigravity` (`localharness`) and macOS entitlement setup |
| `step-03-projects-sandbox` | Act 3 | [`03-10ad2b6c`](file:///Users/brett/tmp/agy_genui_demo/prompts/03-10ad2b6c-please-review-this-program-i-m-interested.md) | Grouping threads by **Projects** (`CWD`), per-thread composer drafts, and the **Approve & Run / Deny** sandbox-escape review card |
| `step-04-a2ui` | Act 4 | [`04-ba34877d`](file:///Users/brett/tmp/agy_genui_demo/prompts/04-ba34877d-please-add-a2ui-core-a2ui-agent-and.md) | Streaming inline `<a2ui-json>` v1.0 surfaces, interactive clarifying parameter forms (`ChoicePicker`, `CheckBox`, `TextField`), and bidirectional RPCs (`getWorkspaceInfo`, `listWorkspaceFiles`, `callAgentFunction`) |
| `step-05-fixup` | Act 5 | [`05-7407df5f`](file:///Users/brett/tmp/agy_genui_demo/prompts/05-7407df5f-please-review-this-codebase.md) | Automatic A2UI action & batched outbound RPC forwarding to the agent, hardened sandbox-escape path heuristics, preserved custom thread titles, and bounded workspace directory scans |

### Instant (<1s) Hot-Restart Trick During a Live Talk
Because `macos/Runner/*.entitlements` and all package dependencies are already configured when you launch `flutter run -d macos` from `HEAD` (`step-05-fixup`), you can switch the Dart code in `lib/` and `test/` to any tag **without** modifying `pubspec.yaml` or `macos/`—avoiding `flutter pub get` and Xcode rebuilds:

```bash
# 1. Start the app once from the latest commit in Terminal A:
flutter run -d macos

# 2. In Terminal B, load any milestone's Dart code into the working tree:
git clean -fd lib test && git checkout step-01-markdown-chat -- lib test
# Then press 'R' (Hot Restart) in Terminal A!

# Jump to Act 3 (Projects & Sandbox Escape Review UI):
git clean -fd lib test && git checkout step-03-projects-sandbox -- lib test
# Press 'R' in Terminal A!

# Return to the latest state (step-05-fixup):
git clean -fd lib test && git checkout main -- lib test
# Press 'R' in Terminal A!
```
