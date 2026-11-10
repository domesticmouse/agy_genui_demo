# Flutter, Antigravity SDK, and A2UI (`agy_genui_demo`)

A macOS desktop Markdown and **A2UI v1.0** generative UI chat application built with Flutter, the [Google Antigravity SDK](https://pub.dev/packages/antigravity) (`localharness`), and the A2UI v1.0 packages (`a2ui_core`, `a2ui_agent`, `a2ui_flutter`). Built live across 5 acts using the `agy` CLI to explore streaming `<a2ui-json>` surfaces, interactive parameter forms, bidirectional renderer RPCs, and sandboxed project workspaces.

### Quick Links

- **Live Slidev Presentation Deck**: [`https://domesticmouse.github.io/agy_genui_demo/`](https://domesticmouse.github.io/agy_genui_demo/)
- **Interactive Terminal Recording (`.cast` Player)**: [`agy-genui-codelab-cast-player.html`](https://domesticmouse.github.io/agy_genui_demo/agy-genui-codelab-cast-player.html)
- **Step-by-Step Codelab**: [`CODELAB.md`](CODELAB.md)
- **Slide-by-Slide Presentation Outline**: [`PRESENTATION.md`](PRESENTATION.md)
- **Exported `agy` Session Transcripts (Sessions 01–07)**: [`prompts/README.md`](prompts/README.md)

---

## 5-Act Git Tag Milestones

Each milestone is tagged in Git so you can time-travel between acts during a live demo and press **`R`** (Hot Restart) in `flutter run -d macos`:

| Act | Git Tag | What It Adds | Live Hot-Restart Command |
| :---: | :--- | :--- | :--- |
| **0** | `step-00-scaffold` | Default `flutter create --platforms=macos` counter scaffold | `git clean -fd lib test && git checkout step-00-scaffold -- lib test` |
| **1** | `step-01-markdown-chat` | Split-view macOS Markdown chat UI, GFM tables/code blocks, composer toolbar & live preview (`flutter_markdown_plus`) | `git clean -fd lib test && git checkout step-01-markdown-chat -- lib test` |
| **2** | `step-02-antigravity-sdk` | Live streaming `package:antigravity` backend (`localharness`), macOS network/process entitlements, per-thread `Agent` lifecycle | `git clean -fd lib test && git checkout step-02-antigravity-sdk -- lib test` |
| **3** | `step-03-projects-sandbox` | Explicit `ChatProject` working directories (avoiding the macOS Finder `/` root trap), `exebox` command sandboxing, human-in-the-loop escape review banner, per-thread drafts | `git clean -fd lib test && git checkout step-03-projects-sandbox -- lib test` |
| **4** | `step-04-a2ui` | Live `<a2ui-json>` v1.0 surface streaming (`MessageProcessor`, `A2uiSurface`), clarifying parameter forms (`ChoicePicker`, validation `checks`), custom `FunctionImplementation` RPCs | `git clean -fd lib test && git checkout step-04-a2ui -- lib test` |
| **5** | `step-05-fixup` | Fresh-context audit fixes: live action & RPC forwarding (`forwardSurfaceActionsToAgent: true`, `forwardRpcMessagesToAgent: true`), batched multi-RPC flush, 21 widget tests | `git clean -fd lib test && git checkout step-05-fixup -- lib test` |

---

## Key Packages

- [`antigravity`](https://pub.dev/packages/antigravity) — Dart SDK for spawning and communicating with the Google Antigravity `localharness` agent (`Agent`, `LocalAgentConfig`, `CapabilitiesConfig`, `RunCommandConfig`).
- [`a2ui_core`](https://pub.dev/packages/a2ui_core) — Pure Dart A2UI v1.0 wire protocol, reactive JSON Pointer `DataModel`, JSON healing (`DirectJsonFormat`), and expression/validation evaluation (`BasicFunctions`, `FunctionImplementation`).
- [`a2ui_agent`](https://pub.dev/packages/a2ui_agent) — Agent-facing prompt schema generator (`A2uiRequestProcessor`), incremental `<a2ui-json>` stream splitter (`StreamedAnswer`), and bidirectional `RpcHandler` dispatcher (`MessageProcessor`).
- [`a2ui_flutter`](https://pub.dev/packages/a2ui_flutter) — Flutter widget catalog (`basicCatalog()`) and reactive `A2uiSurface` renderer bound to `SurfaceModel` and `DataModel`.
- [`flutter_markdown_plus`](https://pub.dev/packages/flutter_markdown_plus) — GitHub-Flavored Markdown rendering (`MarkdownBody`) for assistant prose and live composer previews.

---

## Quick Start

### 1. Run the macOS Desktop App

Ensure macOS desktop support is enabled (`flutter config --enable-macos-desktop`) and provide a `GEMINI_API_KEY`:

```bash
flutter pub get
export GEMINI_API_KEY="your_api_key_here"
flutter run -d macos
```

Run static analysis and the widget test suite:

```bash
dart analyze
flutter test
```

### 2. Preview & Build the Slidev Presentation Deck

Start the local Slidev development server (`http://localhost:3030/`):

```bash
.agents/skills/slidev-deck/scripts/slides-server.sh start
.agents/skills/slidev-deck/scripts/slides-server.sh status
```

Build the static production deck into `slides/dist/`:

```bash
npm --prefix slides run build
```
