# Flutter, Antigravity SDK, and GenUI, a vibe coding exploration

**Speaker**: Brett Morgan, Developer Relations Engineer, Google Cloud

## Presentation Pitch
Sometimes you look at a set of technologies and wonder "What happens if I glue them all together?" With the power of Google Antigravity we can find out together!

In this presentation we will find out that Flutter and GenUI, a framework for having agents generate user interface on the fly, works really well with Antigravity SDK, which is an easy way to bring the power of Google Antigravity into your applications.

## Notes
- The Dart GenUI package (`genui`) has just been deprecated and replaced by the **A2UI** packages (`a2ui_core`, `a2ui_agent`, `a2ui_flutter`).
- We collapse Setup (`step-00-scaffold`) and Act 1 (`step-01-markdown-chat`) into the first cast clip since everyone knows what the default Flutter counter app looks like; our first live demo happens at the end of Act 1.
- **Slide vs. `v-click` Rule**:
  - Distinct commands or prompts (e.g., **Shell Setup** vs. **Prompt 1.1** vs. **Tag & `/clear`**) each get their own **separate slide**.
  - Inside a slide that has multiple commands, numbered prompt items, or multiple sentences, each line/sentence is revealed step-by-step using Slidev **`v-click`** animations.
- In **Act 4**, we dedicate **7 slides** after Clip 4.2 to unpack the architecture and 4 seamlines between `a2ui_core`, `a2ui_agent`, and `a2ui_flutter`, and **3 slides** after Clip 4.3 to walk through the 6 A2UI capability options `agy` proposed for the codebase.
- At the end of each of the 5 Acts (where we create a Git tag), we show a **Screenshot & Live Demo Slide** (`layout: hardware-callout`) with the hot-restart checkout command to transition smoothly into the live macOS app.

---

## Cast Clips Breakdown (Split from `agy-genui-codelab.cast`)

| Clip File (`recordings/final/`) | Act / Prompt | Source Markers | Event Range | Warped Duration | Ends With |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `01-act1-markdown-chat.cast` | Setup + Prompt 1.1 & 1.2 | `[1]–[8]` | `#0..#6585` | ~58.6s | `git tag step-01-markdown-chat` + `/clear` |
| `02-act2-antigravity-sdk.cast` | Prompt 2.1 & 2.2 | `[8]–[14]` | `#6585..#13183` | ~45.7s | `git tag step-02-antigravity-sdk` + `/clear` |
| `03a-act3-cwd-review.cast` | Prompt 3.1 (CWD Review) | `[14]–[16]` | `#13183..#15294` | ~26.6s | Investigation report on `Directory.current` vs `/` |
| `03b-act3-projects-sandbox.cast` | Prompt 3.2 (Projects & Sandbox UI + Q1) | `[16]–[21]` | `#15294..#26607` | ~87.7s | Projects & Sandbox UI built (queued 3.3 at `[18]`) |
| `03c-act3-review-fixes.cast` | Prompt 3.3 & 3.4 (Review Fixes & Tag) | `[21]–[26]` | `#26607..#31705` | ~54.8s | `git tag step-03-projects-sandbox` + `/clear` |
| `04a-act4-a2ui-surfaces.cast` | Prompt 4.1 (A2UI v1.0 Integration) | `[26]–[28]` | `#31705..#60807` | ~30.5s | `<a2ui-json>` v1.0 streaming + 3 bugs fixed |
| `04b-act4-a2ui-seamlines.cast` | Prompt 4.2 (Package Seamlines) | `[28]–[30]` | `#60807..#64157` | ~27.6s | Architectural breakdown of the 3 A2UI packages |
| `04c-act4-a2ui-options.cast` | Prompt 4.3 (Capability Options) | `[30]–[32]` | `#64157..#65171` | ~19.0s | 6 concrete A2UI options proposed for this app |
| `04d-act4-forms-and-rpcs.cast` | Prompt 4.4 & 4.5 (Forms, RPCs & Tag) | `[32]–[38]` | `#65171..#80902` | ~54.8s | `git tag step-04-a2ui` + `/clear` |
| `05a-act5-codebase-audit.cast` | Prompt 5.1 (Full Codebase Review) | `[38]–[40]` | `#80902..#83628` | ~27.1s | 5 real-world bugs surfaced across the app |
| `05b-act5-fixups-and-tag.cast` | Prompt 5.2 & 5.3 (Fix Issues & Tag) | `[40]–[44]` | `#83628..#87984` | ~54.4s | `git tag step-05-fixup` |

---

## Slide-by-Slide Outline

### Act 0: Primer & Pitch (`slides/acts/01-primer.md`)

- **`S01` — Title Slide (Original Abstract)** (`layout: center`, `class: text-center`)
  - **Title**: Flutter, Antigravity SDK, and GenUI
  - **Subtitle**: A vibe coding exploration
  - **Speaker**: Brett Morgan · Developer Relations Engineer, Google Cloud
- **`S01a` — Title Slide (The Deprecation Twist)** (`layout: center`, `class: text-center`)
  - **Title**: Flutter, Antigravity SDK, and ~~GenUI~~ **A2UI**
  - **Subtitle**: A vibe coding exploration
  - **Speaker**: Brett Morgan · Developer Relations Engineer, Google Cloud
- **`S02` — The Pitch: What Happens If We Glue Them Together?** (`layout: default`)
  - Revealed with `v-click` (1 ingredient per click):
    1. `[v-click 1]` **Flutter (macOS Desktop)**: Fast, expressive multi-platform UI with instant hot-restart.
    2. `[v-click 2]` **Google Antigravity (`agy` CLI & `package:antigravity` SDK)**: Both the coding agent building our app *and* the embedded agent backend running inside our app via `localharness`.
    3. `[v-click 3]` **GenUI $\rightarrow$ A2UI v1.0 (`a2ui_core`, `a2ui_agent`, `a2ui_flutter`)**: `package:genui` was just deprecated and replaced by the modular A2UI v1.0 packages for streaming live interactive UI surfaces inline with Markdown.
- **`S03` — How We Built This: 5 Acts, `/clear`, and Git Tags** (`layout: default`)
  - Overview of the 5 tagged milestones (`step-01-markdown-chat` through `step-05-fixup`), showing how each stage resets context with `/clear` and ends with a Git tag we can hot-restart into in `<1s`.

---

### Act 1: Build the macOS Markdown Chat UI (`slides/acts/02-act1-markdown-chat.md`)

- **`S04` — Section Divider: Act 1 — macOS Markdown Chat UI** (`layout: center`)
  - `flutter_markdown_plus` · `step-01-markdown-chat`
- **`S05a` — Lead-in: Terminal & Project Scaffold Commands** (`layout: skill-breakdown`, `way: 1`)
  - Revealed line-by-line with `v-click`:
    1. `[v-click 1]` `flutter create agy_genui_demo --platforms=macos`
    2. `[v-click 2]` `cd agy_genui_demo && git init && git add . && git commit -m "Initial commit"`
    3. `[v-click 3]` `git tag step-00-scaffold`
    4. `[v-click 4]` `agy`
- **`S05b` — Lead-in: Prompt 1.1 (Build the Markdown Chat App)** (`layout: skill-breakdown`, `way: 1`)
  - Opening line visible initially; each numbered requirement revealed with `v-click`:
    - *Initial*: `Please build a macOS desktop Markdown chat application in this project using flutter_markdown_plus with the following features:`
    - `[v-click 1]` `1. A collapsible macOS split-view conversation thread sidebar with per-thread typing state, automatic thread titling, and starter threads showcasing rich Markdown.`
    - `[v-click 2]` `2. Markdown message rendering (headings, bold/italic/strikethrough, inline and fenced code blocks, blockquotes, lists, and GitHub-style tables) with a one-click Copy Markdown button on every message bubble.`
    - `[v-click 3]` `3. A Markdown composer that restores focus after sending, with a formatting toolbar (Bold, Italic, Inline Code, Code Block, List, Blockquote), a live Markdown preview toggle, and desktop keyboard shortcuts (Enter or Numpad Enter to send, Shift + Enter for a newline with an IME composition guard).`
    - `[v-click 4]` `4. A responsive top toolbar with Light and Dark Material 3 theme switching.`
    - `[v-click 5]` `5. Widget tests in test/widget_test.dart and macOS build/run instructions in README.md.`
- **`S05c` — Lead-in: Prompt 1.2 (Tag `step-01-markdown-chat` & Reset Context)** (`layout: skill-breakdown`, `way: 1`)
  - Revealed step-by-step with `v-click`:
    1. `[v-click 1]` Prompt: `git commit and tag as step-01-markdown-chat`
    2. `[v-click 2]` Slash command: `/clear`
- **`S06` — Cast Clip 1: Scaffolding & Building the Markdown Chat UI** (`layout: cast-full`)
  - `cast: /casts/01-act1-markdown-chat.cast`
  - **Talking Points During Playback**:
    - `agy` consults the Flutter architecture, widget test, and static analysis skills first.
    - Builds clean Domain / Data / Presentation layers (`ChatMessage`, `ChatThread`, `ChatRepository`, `ChatViewModel`).
    - When running `flutter test`, `agy` catches a horizontal `RenderFlex` overflow on an 800px test viewport in `MessageBubble` and self-corrects before committing `step-01-markdown-chat`.
- **`S07` — Screenshot & Live Demo: `step-01-markdown-chat`** (`layout: hardware-callout`)
  - `image: /images/step-01-markdown-chat.png`
  - **Live Demo Transition**:
    ```bash
    git clean -fd lib test && git checkout step-01-markdown-chat -- lib test
    # Press 'R' (Hot Restart) in flutter run!
    ```
  - **What to Show Live**: Collapsible thread sidebar, GitHub-Flavored Markdown tables/code blocks, Copy Markdown button, composer formatting toolbar + live preview pane, Light/Dark theme toggle, and simulated replies.

---

### Act 2: Integrate the Antigravity Dart SDK (`slides/acts/03-act2-antigravity-sdk.md`)

- **`S08` — Section Divider: Act 2 — Antigravity Dart SDK Backend** (`layout: center`)
  - `package:antigravity` · `localharness` · `step-02-antigravity-sdk`
- **`S09a` — Lead-in: Prompt 2.1 (Wire Up `package:antigravity`)** (`layout: skill-breakdown`, `way: 2`)
  - Each sentence revealed with `v-click`:
    1. `[v-click 1]` `Please add the antigravity package dependency and integrate it as the backend for the Markdown chat in this app.`
    2. `[v-click 2]` `Update the macOS entitlements so the app can spawn the local harness, and update README.md and the widget tests.`
- **`S09b` — Lead-in: Prompt 2.2 (Tag `step-02-antigravity-sdk` & Reset Context)** (`layout: skill-breakdown`, `way: 2`)
  - Revealed step-by-step with `v-click`:
    1. `[v-click 1]` Prompt: `git commit and tag as step-02-antigravity-sdk`
    2. `[v-click 2]` Slash command: `/clear`
- **`S10` — Cast Clip 2: Integrating `package:antigravity` & macOS Entitlements** (`layout: cast-full`)
  - `cast: /casts/02-act2-antigravity-sdk.cast`
  - **Talking Points During Playback**:
    - `agy` inspects `antigravity: ^0.18.1` in `.pub-cache` and discovers `LocalConnectionStrategy` spawns `~/.antigravity/bin/localharness` and opens a local WebSocket + outbound HTTPS.
    - Updates `DebugProfile.entitlements` and `Release.entitlements` (`app-sandbox: false`, `network.client: true`, `network.server: true`).
    - Spots that `ChatResponse.chunks` uses `Future.delayed(5ms)` polling and `Agent.start()` spawns an OS process (which would hang Flutter's `FakeAsync` widget tests), so it introduces an injectable `AntigravityAgentSession` abstraction.
- **`S11` — Screenshot & Live Demo: `step-02-antigravity-sdk`** (`layout: hardware-callout`)
  - `image: /images/step-02-antigravity-sdk.png`
  - **Live Demo Transition**:
    ```bash
    git clean -fd lib test && git checkout step-02-antigravity-sdk -- lib test
    # Press 'R' in flutter run!
    ```
  - **What to Show Live**: Send a real prompt in the macOS app and watch live streaming tokens arrive from `localharness` via `package:antigravity`.

---

### Act 3: Project Workspaces (`CWD`) & Sandbox Escape Review UI (`slides/acts/04-act3-projects-sandbox.md`)

- **`S12` — Section Divider: Act 3 — Project Workspaces & Sandbox Review** (`layout: center`)
  - `workspaces` · `exebox` · `askUser` · `step-03-projects-sandbox`
- **`S13` — Lead-in: Prompt 3.1 (Which Directory Is `localharness` Running In?)** (`layout: skill-breakdown`, `way: 1`)
  - Each sentence revealed with `v-click`:
    1. `[v-click 1]` `Please review this program.`
    2. `[v-click 2]` `I'm interested in which directory the Antigravity local harness has as its initial working directory`
- **`S14` — Cast Clip 3.1: Investigating Initial Working Directory** (`layout: cast-full`)
  - `cast: /casts/03a-act3-cwd-review.cast`
- **`S15` — What `agy` Found: The macOS `.app` Bundle Root (`/`) Trap** (`layout: default`)
  - 2-column comparison (`Anti-Pattern: Implicit Directory.current` vs. `Target Architecture: Explicit Project Workspaces`):
    - Passing `workspaces: null` to `LocalAgentConfig` defaults to `Directory.current.absolute.path`.
    - From `flutter run`, `Directory.current` is `./`. From Finder/Dock (`agy_genui_demo.app`), macOS `launchd` sets `Directory.current` to **`/` (root)!**
    - Plus 2 bonus review catches: `threadTitle` locked into `CustomSystemInstructions` at session start, and shared composer draft text leaking across threads.
- **`S16` — Lead-in: Prompt 3.2 (Add Projects & Sandbox Escape Review UI)** (`layout: skill-breakdown`, `way: 2`)
  - Each numbered item (and its sub-sentences) revealed with `v-click`:
    1. `[v-click 1]` `1. Add a concept of projects that set a working directory for the Antigravity harness.`
    2. `[v-click 2]` `2. I'm guessing workspaceOnly enables commands that are inside the sandbox.`
    3. `[v-click 3]` `We should add UI that allows programs to be run that want to escape the sandbox, but only after review by the user.`
    4. `[v-click 4]` `3. Update README.md and add /skills/ to .gitignore.`
- **`S17` — Cast Clip 3.2: Reverse-Engineering `localharness` Policies & Building the UI** (`layout: cast-full`)
  - `cast: /casts/03b-act3-projects-sandbox.cast`
  - **Talking Points During Playback**:
    - `agy` inspects `policy.dart`, `capabilities.dart`, and even runs `strings` on the `~/.antigravity/bin/localharness` Go binary!
    - Discovers `workspaceOnly` only confines file tools (`view_file`, `write_to_file`, etc.) — `CapabilitiesConfig(runCommand: RunCommandConfig(enableSandbox: true))` is what enables the OS-level `exebox` sandbox and exposes `BypassSandbox`.
    - Pauses at Marker `[19]` with `ask_question`: *"How should projects and conversation threads be organized in the UI?"* $\rightarrow$ we pick Option 1 (Projects group threads).
- **`S18a` — Lead-in: Prompt 3.3 (Fix Review Issues)** (`layout: skill-breakdown`, `way: 3`)
  - Single-sentence prompt:
    ```text
    Please fix issues highlighted in the review
    ```
    *(Addressing per-thread composer draft isolation and session recreation on thread rename / workspace change)*
- **`S18b` — Lead-in: Prompt 3.4 (Tag `step-03-projects-sandbox` & Reset Context)** (`layout: skill-breakdown`, `way: 3`)
  - Revealed step-by-step with `v-click`:
    1. `[v-click 1]` Prompt: `git commit and tag as step-03-projects-sandbox`
    2. `[v-click 2]` Slash command: `/clear`
- **`S19` — Cast Clip 3.3: Per-Thread Composer Drafts, Session Refresh & Tagging** (`layout: cast-full`)
  - `cast: /casts/03c-act3-review-fixes.cast`
- **`S20` — Screenshot & Live Demo: `step-03-projects-sandbox`** (`layout: hardware-callout`)
  - `image: /images/step-03-projects-sandbox.png`
  - **Live Demo Transition**:
    ```bash
    git clean -fd lib test && git checkout step-03-projects-sandbox -- lib test
    # Press 'R' in flutter run!
    ```
  - **What to Show Live**: Project switcher & New Project dialog (`CWD` badge in toolbar), per-thread isolated drafts, and the amber **Sandbox Escape Review** banner (`Deny` / `Approve & Run` backed by a `Completer<bool>`).

---

### Act 4: Generative UI with A2UI v1.0 (`slides/acts/05-act4-a2ui.md`)

- **`S21` — Section Divider: Act 4 — Generative UI with A2UI v1.0** (`layout: center`)
  - `a2ui_core` · `a2ui_agent` · `a2ui_flutter` · `step-04-a2ui`
- **`S22` — Lead-in: Prompt 4.1 (Add `a2ui_core`, `a2ui_agent`, and `a2ui_flutter`)** (`layout: skill-breakdown`, `way: 1`)
  - Revealed clause-by-clause with `v-click`:
    1. `[v-click 1]` `Please add a2ui_core, a2ui_agent, and a2ui_flutter to this project`
    2. `[v-click 2]` `and integrate A2UI v1.0 surface rendering into the chat UI so <a2ui-json> blocks stream live interactive A2uiSurface widgets inline alongside Markdown.`
- **`S23` — Cast Clip 4.1: Streaming `<a2ui-json>` Surfaces & Debugging 3 Subtle Bugs** (`layout: cast-full`)
  - `cast: /casts/04a-act4-a2ui-surfaces.cast`
- **`S24` — 3 Real-World A2UI v1.0 Bugs `agy` Diagnosed During Testing** (`layout: default`)
  - Revealed one bug at a time with `v-click`:
    1. `[v-click 1]` **A2UI v1.0 `Text.variant` Schema Constraint**: `BasicCatalog.v1_0` only allows `'caption'` or `'body'` (v0.8 allowed `'h5'`).
    2. `[v-click 2]` **Inline Backtick `<a2ui-json>` Tag Collision**: `DirectJsonParser` strips backticks around `` `<a2ui-json>` `` to forgive LLMs that wrap tags in inline code, so mentioning literal `` `<a2ui-json>` `` in prose opened the JSON block prematurely.
    3. `[v-click 3]` **`A2uiMarkdown` Inside `OutlinedButton` Intercepting Taps**: Wrapping `A2uiSurface` with `A2uiMarkdown` made button labels `selectable: true` and full-width, swallowing pointer taps until `selectable: false, fitContent: true` was set.

#### Deep Dive Part A: A2UI Package Architecture & Seamlines (7 Slides After Clip 4.2)

- **`S25` — Lead-in: Prompt 4.2 (Research the A2UI Package Seamlines)** (`layout: skill-breakdown`, `way: 2`)
  - Each sentence revealed with `v-click`:
    1. `[v-click 1]` `Please research the seamlines between a2ui_core, a2ui_agent and a2ui_flutter.`
    2. `[v-click 2]` `Explain when to use each.`
- **`S26` — Cast Clip 4.2: Researching A2UI Package Seamlines** (`layout: cast-full`)
  - `cast: /casts/04b-act4-a2ui-seamlines.cast`
- **`S27` — Overview (1 of 7): How the 3 A2UI Packages Layer Together** (`layout: default`)
  - High-level package dependency graph and separation of concerns:
    - **`a2ui_core`** (Pure Dart foundation): Zero dependency on Flutter or any LLM SDK.
    - **`a2ui_agent`** (Pure Dart agent bridge): Depends on `a2ui_core` (and `antlr4`), **never** on `flutter`.
    - **`a2ui_flutter`** (Flutter widget layer): Depends on `a2ui_core` and `flutter`, **never** on `a2ui_agent`.
- **`S28` — Package 1 (2 of 7): `a2ui_core` — Headless Protocol, State & Expression Engine** (`layout: default`)
  - Revealed with `v-click`:
    1. `[v-click 1]` **Wire Protocol & Envelopes**: `AgentToRendererMessage` (`CreateSurfaceMessage`, `UpdateComponentsMessage`, `UpdateDataModelMessage`, `DeleteSurfaceMessage`, `CallRendererFunctionMessage`) and `RendererToAgentMessage` (`ActionMessage`, `ErrorMessage`, `FunctionResponseMessage`).
    2. `[v-click 2]` **Catalog Specification**: `Catalog<T extends ComponentApi, F extends FunctionApi>` and `BasicCatalog.v1_0` (JSON Schemas for components + client-side functions like `formatString`, `required`, `regex`).
    3. `[v-click 3]` **Message Routing & Validation**: `MessageProcessor<T>` validates messages against catalog schemas (`PayloadValidator`) and component graph topology (`ValidationConfig`), applying them to `SurfaceGroupModel<T>`.
    4. `[v-click 4]` **Reactive Surface & Node Resolution**: `SurfaceModel<T>`, `DataModel`, `GenericBinder`, and `NodeResolver<T>` turn a surface's flat component map and JSON Pointer data model (`@path`, `@call`) into a reactive tree of `ComponentNode<T>` backed by `preact_signals`.
- **`S29` — Package 2 (3 of 7): `a2ui_agent` — Prompt Generation, Stream Parsing & JSON Healing** (`layout: default`)
  - Revealed with `v-click`:
    1. `[v-click 1]` **Capability Negotiation**: `A2uiGenerator` matches the client's `A2uiRendererCapabilities` against available `CatalogConfig`s (optionally pruning via `PruningTransformer`) to build an `A2uiRequestProcessor`.
    2. `[v-click 2]` **System Prompt Generation**: `a2uiRequestProcessor.promptSnippet` emits the system instructions and `---BEGIN A2UI JSON SCHEMA---` teaching the LLM to output `<a2ui-json>` (`DirectJsonFormatFactory`) or A2UI Express DSL (`ExpressFormatFactory`).
    3. `[v-click 3]` **Streaming LLM Parser & JSON Healer**: `DirectJsonParser` and `DirectJsonContinuingResponseStream` split raw LLM token streams into prose `TextPart`, healed incremental `A2uiPart` (`List<AgentToRendererMessage>`), and `ErrorPart` while validating against `RendererState` with transactional rollback on invalid blocks.
- **`S30` — Package 3 (4 of 7): `a2ui_flutter` — Flutter Widget Adapter (`package:flutter`)** (`layout: default`)
  - Revealed with `v-click`:
    1. `[v-click 1]` **Concrete Component Type (`ComponentImplementation`)**: Subclasses `a2ui_core`'s `ComponentApi`, attaching a `ComponentWidgetBuilder` (`Widget Function(BuildContext, ComponentNode, ComponentProps, ChildWidgetBuilder)`) to each component's JSON Schema.
    2. `[v-click 2]` **Flutter Basic Catalog (`basicCatalog()`)**: Returns a `CatalogImplementation` (`Catalog<ComponentImplementation, FunctionImplementation>`) implementing all 18 A2UI v1.0 basic components (`Card`, `Row`, `Column`, `List`, `Tabs`, `Modal`, `Text`, `Image`, `Icon`, `Video`, `AudioPlayer`, `Divider`, `Button`, `TextField`, `CheckBox`, `ChoicePicker`, `Slider`, `DateTimeInput`).
    3. `[v-click 3]` **Reactive Surface Widget (`A2uiSurface`)**: Takes a `SurfaceModel<ComponentImplementation>`, attaches a `NodeResolver<ComponentImplementation>`, and rebuilds only affected widget subtrees via `SignalState` as signals change.
- **`S31` — Seamlines 1 & 2 (5 of 7): Catalog Type Erasure & Stream Processing** (`layout: skill-breakdown`, `way: 1`)
  - **Seamline 1: `ComponentApi` $\leftrightarrow$ `ComponentImplementation` (`a2ui_core` $\leftrightarrow$ `a2ui_flutter` & `a2ui_agent`)**
    - `a2ui_core` is generic over `T extends ComponentApi`.
    - `a2ui_flutter` provides `basicCatalog()` (`Catalog<ComponentImplementation, FunctionImplementation>`).
    - `a2ui_agent`'s `CatalogConfig.fromCatalog(a2uiCatalog)` erases the Flutter widget builder down to `ComponentApi` JSON Schemas so prompt generation never imports Flutter.
  - **Seamline 2: `A2uiRequestProcessor` $\leftrightarrow$ `MessageProcessor<T>` (`a2ui_agent` $\leftrightarrow$ `a2ui_core`)**
    - `A2uiRequestProcessor` converts raw LLM text chunks (`<a2ui-json>`) $\rightarrow$ `List<AgentToRendererMessage>`.
    - `MessageProcessor<T>` consumes `List<AgentToRendererMessage>` $\rightarrow$ mutates `SurfaceGroupModel<T>` / `SurfaceModel<T>`.
    - Can run across a network wire (Server $\rightarrow$ Client) or fused in-process via `RendererState.of(renderer)` and `StreamedAnswer<ComponentImplementation>` (`AnswerTextPart`, `AnswerSurfacePart`, `AnswerErrorPart`).
- **`S32` — Seamlines 3 & 4 (6 of 7): Reactive Surface Mounting & Two-Way Actions** (`layout: skill-breakdown`, `way: 2`)
  - **Seamline 3: `SurfaceModel<ComponentImplementation>` $\leftrightarrow$ `A2uiSurface` (`a2ui_core` $\leftrightarrow$ `a2ui_flutter`)**
    - `MessageProcessor<ComponentImplementation>` (or `AnswerSurfacePart.surface`) produces a `SurfaceModel<ComponentImplementation>` passed directly to `A2uiSurface(key: ObjectKey(surface), surface: surface)`, wrapped in `A2uiMarkdown` for rich text.
  - **Seamline 4: `onAction` & `outboundListener` $\leftrightarrow$ `ActionMessage` + `getRendererDataModel` (`a2ui_flutter` $\rightarrow$ `a2ui_core` $\rightarrow$ `a2ui_agent`)**
    1. *Local Data Bindings (`WritableBinding`)*: Editing `TextField`, `CheckBox`, or `Slider` bound to `{"@path": "/..."}` mutates `SurfaceModel.dataModel` in-place in `a2ui_core` without round-tripping to the agent.
    2. *Agent Actions (`NodeAction`)*: Pressing a `Button` resolves `action.event.context` against `SurfaceModel.dataModel` and emits `A2uiRendererAction` on `renderer.model.onAction`.
    3. *Outbound Turn*: Wrapped in `a2ui_core`'s `ActionMessage` + `renderer.getRendererDataModel(version: A2uiProtocolVersion.v1_0)` (plus `outboundListener` for `RendererFunctionResponseMessage` / `CallAgentFunctionMessage`) and sent back to the agent.
- **`S33` — When to Use Each Package (7 of 7): 4 Architecture Topologies** (`layout: default`)
  - Revealed one topology at a time with `v-click`:
    1. `[v-click 1]` **Full-Stack / Local Agent Flutter App (`agy_genui_demo`)** — `a2ui_core` + `a2ui_agent` + `a2ui_flutter`: App both prompts/streams from the LLM (`StreamedAnswer`) and renders interactive `A2uiSurface` widgets over shared `SurfaceModel` state.
    2. `[v-click 2]` **Thin Flutter Client + Remote Backend Agent** — `a2ui_core` + `a2ui_flutter` (No `a2ui_agent` on client): Backend server parses LLM output and streams `AgentToRendererMessage`s over WebSockets/SSE/gRPC directly into the client's `MessageProcessor<ComponentImplementation>`.
    3. `[v-click 3]` **Dart Backend Agent Server / CLI (`shelf`, `dart_frog`, CLI)** — `a2ui_core` + `a2ui_agent` (No `a2ui_flutter`): Pure Dart server cannot depend on `flutter`; uses `BasicCatalog.v1_0()` + `A2uiRequestProcessor` + `RendererState` to prompt the LLM, heal/validate `<a2ui-json>`, and forward messages to clients.
    4. `[v-click 4]` **Custom Non-Flutter Dart Renderer / Headless Testing** — `a2ui_core` (+ optional `a2ui_agent`): Subclass `ComponentApi` and mount `NodeResolver<MyComponent>` to target Jaspr, terminal UI, or headless unit tests.

#### Deep Dive Part B: Options `agy` Suggested for Utilizing A2UI (3 Slides After Clip 4.3)

- **`S34` — Lead-in: Prompt 4.3 (Explore Capabilities for This Codebase)** (`layout: skill-breakdown`, `way: 3`)
  - **Prompt 4.3**:
    ```text
    Give me some options for utilising this capability in the current codebase
    ```
- **`S35` — Cast Clip 4.3: Brainstorming 6 A2UI Enhancements** (`layout: cast-full`)
  - `cast: /casts/04c-act4-a2ui-options.cast`
- **`S36` — `agy`'s Suggestions (1 of 3): Action Loops & Custom Developer Catalog** (`layout: default`)
  - Revealed with `v-click`:
    - `[v-click 1]` **Option 1: Live Two-Way Action Loop (`Button` $\rightarrow$ Agent Turn + `a2uiRendererDataModel` Sync)**
      - Automatically dispatch `ActionMessage` + `a2uiRendererDataModel` to the thread's Antigravity `Agent` when a user clicks an `A2uiSurface` `Button`.
      - Show a compact user "Action Pill" in the chat feed (e.g., `⚡ Action: book_flight (destination: Kyoto)`) and let the agent mutate the existing surface in-place via `updateDataModel` / `updateComponents` or stream a follow-up surface.
      - Attach `renderer.getRendererDataModel(version: A2uiProtocolVersion.v1_0)` to regular text prompts when active surfaces have `sendDataModel: true`.
    - `[v-click 2]` **Option 2: Custom Workspace & Developer Catalog (`CatalogImplementation` Extensions)**
      - Pair custom JSON Schemas with Flutter `ComponentWidgetBuilder`s tailored to an Antigravity coding assistant:
        - `CodeDiffCard`: Side-by-side or unified diff preview with **Apply Patch** / **Discard** action buttons.
        - `FileTreeCard` / `WorkspaceFileCard`: Clickable file badges (`path`, `lineStart`, `lineEnd`, `summary`) for files in `ChatProject.workingDirectory`.
        - `CommandRunnerCard`: Proposes a shell command with editable flags (`TextField` / `CheckBox` bound to data model) and a **Run in Workspace** button.
- **`S37` — `agy`'s Suggestions (2 of 3): Persistent Canvas & Self-Healing Validation** (`layout: default`)
  - Revealed with `v-click`:
    - `[v-click 1]` **Option 3: Persistent Split-Pane "Surface Canvas" Drawer (Alongside Inline Chat Surfaces)**
      - `RendererState` supports two UX modes over the same `MessageProcessor`: inline chat turns and a persistent canvas where multi-turn prompts iteratively evolve a single surface.
      - Add a toggleable right-hand **A2UI Inspector / Canvas** pane in `ChatScreen` and `TopToolbar`.
      - Pin any active surface from `renderer.model.allSurfaces` with a live **Data Model JSON Inspector** (`surface.dataModel`) and **Component Tree Viewer** to watch `@path` bindings mutate in real time.
    - `[v-click 2]` **Option 4: Self-Healing Validation Loop (Automatic LLM Repair on `AnswerErrorPart`)**
      - When the LLM emits a malformed `<a2ui-json>` block or violates a component schema, `StreamedAnswer` rolls back that block and `MessageBubble` displays `_InlineA2uiErrorBanner`.
      - Add a **Fix Surface** button on `_InlineA2uiErrorBanner` (or an automatic 1-retry self-repair option in `ChatViewModel`) that sends `ErrorMessage(version: '1.0', error: ...)` back to the thread's Antigravity session so the agent repairs the surface automatically.
- **`S38` — `agy`'s Suggestions (3 of 3): Clarification Forms, Express DSL & Bidirectional RPCs** (`layout: default`)
  - Revealed with `v-click`:
    - `[v-click 1]` **Option 5: Agent-Driven Clarification Forms ("Ask Question" Surface Pattern)**
      - Instead of asking plain-text clarifying questions before writing code or running tools, the agent streams an interactive A2UI v1.0 parameter form (`ChoicePicker` chips/checkboxes, `TextField` with validation `checks`, `CheckBox`, `Slider`, and a validation-gated `Submit` `Button`).
      - Submitting the form sends the resolved JSON context + data model straight back to the agent.
    - `[v-click 2]` **Option 6: A2UI Express Format Toggle (`DirectJsonFormatFactory` vs. `ExpressFormatFactory`) & Bidirectional RPCs (`FunctionImplementation`)**
      - Switch between `<a2ui-json>` (`DirectJsonFormatFactory`) and the compact token-saving `<a2ui-express>` DSL (`ExpressFormatFactory`) over the exact same `StreamedAnswer` and `MessageProcessor` pipeline.
      - Register custom `FunctionImplementation`s (`AllowedCallers.rendererOrAgent`) so the agent and renderer can invoke functions (`callRendererFunction` / `callAgentFunction`) across the wire.

#### Implementing Our Chosen Options (`4.4` & `4.5`)

- **`S39a` — Lead-in: Prompt 4.4 (Clarifying Parameter Forms & Bidirectional RPCs)** (`layout: skill-breakdown`, `way: mashup`)
  - Opening line visible initially; each bullet revealed with `v-click`:
    - *Initial*: `Please implement:`
    - `[v-click 1]` `- Interactive Clarifying Questions & Parameter Forms (Basic Catalog)`
    - `[v-click 2]` `- Bidirectional Renderer RPC Functions (FunctionImplementation)`
- **`S39b` — Lead-in: Prompt 4.5 (Tag `step-04-a2ui` & Reset Context)** (`layout: skill-breakdown`, `way: mashup`)
  - Revealed step-by-step with `v-click`:
    1. `[v-click 1]` Prompt: `git commit and tag as step-04-a2ui`
    2. `[v-click 2]` Slash command: `/clear`
- **`S40` — Cast Clip 4.4: Implementing Parameter Forms & Custom `FunctionImplementation`s** (`layout: cast-full`)
  - `cast: /casts/04d-act4-forms-and-rpcs.cast`
  - **Talking Points**: `getWorkspaceInfo`, `listWorkspaceFiles`, `setSurfaceData`, and `formatParameterSummary` registered with `AllowedCallers.rendererOrAgent`.
- **`S41` — Screenshot & Live Demo: `step-04-a2ui`** (`layout: hardware-callout`)
  - `image: /images/step-04-a2ui.png`
  - **Live Demo Transition**:
    ```bash
    git clean -fd lib test && git checkout step-04-a2ui -- lib test
    # Press 'R' in flutter run!
    ```
  - **What to Show Live**: Quick-prompt chips (`Clarifying parameter form` and `Run workspace RPC function`), live reactive form summary (`formatParameterSummary`), `Use Audit Preset` button (`setSurfaceData`), and validation-gated submit button.

---

### Act 5: Codebase Review, Hardening Fixups & Finale (`slides/acts/06-act5-fixup.md`)

- **`S42` — Section Divider: Act 5 — Codebase Audit & Hardening Fixups** (`layout: center`)
  - `forwardSurfaceActionsToAgent` · RPC Batching · `step-05-fixup`
- **`S43` — Lead-in: Prompt 5.1 (Fresh-Session Codebase Audit)** (`layout: skill-breakdown`, `way: 1`)
  - **Prompt 5.1**:
    ```text
    please review this codebase
    ```
- **`S44` — Cast Clip 5.1: Auditing the Full Codebase** (`layout: cast-full`)
  - `cast: /casts/05a-act5-codebase-audit.cast`
- **`S45` — 5 Issues Surfaced by the Fresh-Context Audit** (`layout: default`)
  - Revealed one issue at a time with `v-click`:
    1. `[v-click 1]` **`forwardSurfaceActionsToAgent` & `forwardRpcMessagesToAgent` defaulted to `false` in `main.dart`**: Surface button clicks in the live desktop app recorded locally without forwarding to `localharness`!
    2. `[v-click 2]` **Stream Self-Cancellation on Multi-RPC Turns**: Synchronous `sendRpcMessageToAgent` mid-stream cancelled the active stream when multiple `callRendererFunction` calls fired in one block.
    3. `[v-click 3]` **Auto-Titling Overwrote Custom Thread Titles on First Message**.
    4. `[v-click 4]` **Sandbox-Escape Path Heuristics Edge Cases**: `--flag=/outside/path`, `$HOME` expansion, trailing `/..`, and false-positive `awk '/pattern/'`.
    5. `[v-click 5]` **Unbounded Synchronous `listSync()` in `ListWorkspaceFilesFunction`**.
- **`S46a` — Lead-in: Prompt 5.2 (Fix Surfaced Issues)** (`layout: skill-breakdown`, `way: 3`)
  - **Prompt 5.2**:
    ```text
    please fix issues
    ```
- **`S46b` — Lead-in: Prompt 5.3 (Tag `step-05-fixup`)** (`layout: skill-breakdown`, `way: 3`)
  - **Prompt 5.3**:
    ```text
    git commit and tag as step-05-fixup
    ```
- **`S47` — Cast Clip 5.2: Fixing All 5 Issues & Tagging `step-05-fixup`** (`layout: cast-full`)
  - `cast: /casts/05b-act5-fixups-and-tag.cast`
- **`S48` — Screenshot & Live Finale Demo: `step-05-fixup`** (`layout: hardware-callout`)
  - `image: /images/step-05-fixup.png`
  - **Live Demo Transition**:
    ```bash
    git clean -fd lib test && git checkout main -- lib test
    # Press 'R' in flutter run!
    ```
  - **What to Show Live**:
    1. Ask `Please ask a multiple choice question` $\rightarrow$ streams an interactive A2UI v1.0 Trivia card $\rightarrow$ pick **Java** and click **Submit Answer** $\rightarrow$ automatic two-way `ActionMessage` + `a2uiRendererDataModel` round-trip back to `localharness`!
    2. Ask `Please review this codebase` $\rightarrow$ runs `ls`/`find` inside the `exebox` sandbox and streams back a custom **Codebase Review Clarifying Parameter Form**.
- **`S49` — Takeaways & Resources** (`layout: default`)
  - Using `/clear` + Git tags at each milestone keeps context sharp and makes live-demo time travel effortless (`git checkout <tag> -- lib test` + Hot Restart).
  - Asking `agy` to review its own codebase in a fresh session (`Act 3.1` and `Act 5.1`) caught critical integration bugs before going on stage.
  - Links to repo, `CODELAB.md`, `prompts/` session transcripts, and A2UI / Antigravity SDK docs.
