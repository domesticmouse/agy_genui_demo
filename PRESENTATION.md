# Flutter, Antigravity SDK, and GenUI, a vibe coding exploration

**Speaker**: Brett Morgan, Developer Relations Engineer, Google Cloud

## Presentation Pitch
Sometimes you look at a set of technologies and wonder "What happens if I glue them all together?" With the power of Google Antigravity we can find out together!

In this presentation we will find out that Flutter and GenUI, a framework for having agents generate user interface on the fly, works really well with Antigravity SDK, which is an easy way to bring the power of Google Antigravity into your applications.

## Notes
- The Dart GenUI package (`genui`) has just been deprecated and replaced by the **A2UI** packages (`a2ui_core`, `a2ui_agent`, `a2ui_flutter`).
- We collapse Setup (`step-00-scaffold`) and Act 1 (`step-01-markdown-chat`) into the first cast clip since everyone knows what the default Flutter counter app looks like; our first live demo happens at the end of Act 1.
- Each prompt gets its own **Lead-in Slide** (showing the exact commands/prompt and what to watch for) followed by its **Cast Clip Slide** (`layout: cast-full`).
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

- **`S01` — Title Slide** (`layout: center`, `class: text-center`)
  - **Title**: Flutter, Antigravity SDK, and GenUI
  - **Subtitle**: A vibe coding exploration
  - **Speaker**: Brett Morgan · Developer Relations Engineer, Google Cloud
- **`S02` — The Pitch: What Happens If We Glue Them Together?** (`layout: default`)
  - **Three ingredients**:
    1. **Flutter (macOS Desktop)**: Fast, expressive multi-platform UI with instant hot-restart.
    2. **Google Antigravity (`agy` CLI & `package:antigravity` SDK)**: Both the coding agent building our app *and* the embedded agent backend running inside our app via `localharness`.
    3. **GenUI $\rightarrow$ A2UI v1.0 (`a2ui_core`, `a2ui_agent`, `a2ui_flutter`)**: Notice that `package:genui` was just deprecated and replaced by the modular A2UI v1.0 packages for streaming live interactive UI surfaces inline with Markdown.
- **`S03` — How We Built This: 5 Acts, `/clear`, and Git Tags** (`layout: default`)
  - Overview table of the 5 tagged stages (`step-01-markdown-chat` through `step-05-fixup`), showing how each stage resets context with `/clear` and ends with a Git tag we can hot-restart into in `<1s`.

---

### Act 1: Build the macOS Markdown Chat UI (`slides/acts/02-act1-markdown-chat.md`)

- **`S04` — Section Divider: Act 1 — macOS Markdown Chat UI** (`layout: center`)
  - `flutter_markdown_plus` · `step-01-markdown-chat`
- **`S05` — Lead-in: Scaffold & Prompt 1.1 (Build the Markdown Chat App)** (`layout: skill-breakdown`, `way: 1`)
  - **Shell Setup**:
    ```bash
    flutter create agy_genui_demo --platforms=macos
    cd agy_genui_demo && git init && git add . && git commit -m "Initial commit"
    git tag step-00-scaffold
    agy
    ```
  - **Prompt 1.1 & 1.2**:
    ```text
    Please build a macOS desktop Markdown chat application in this project using `flutter_markdown_plus` with the following features:
    1. A collapsible macOS split-view conversation thread sidebar with per-thread typing state, automatic thread titling, and starter threads showcasing rich Markdown.
    2. Markdown message rendering (headings, bold/italic/strikethrough, inline and fenced code blocks, blockquotes, lists, and GitHub-style tables) with a one-click Copy Markdown button on every message bubble.
    3. A Markdown composer that restores focus after sending, with a formatting toolbar (Bold, Italic, Inline Code, Code Block, List, Blockquote), a live Markdown preview toggle, and desktop keyboard shortcuts (`Enter` or `Numpad Enter` to send, `Shift + Enter` for a newline with an IME composition guard).
    4. A responsive top toolbar with Light and Dark Material 3 theme switching.
    5. Widget tests in `test/widget_test.dart` and macOS build/run instructions in `README.md`.
    ```
    Followed by: `git commit and tag as step-01-markdown-chat` and `/clear`.
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
- **`S09` — Lead-in: Prompt 2.1 (Wire Up `package:antigravity`)** (`layout: skill-breakdown`, `way: 2`)
  - **Prompt 2.1 & 2.2**:
    ```text
    Please add the `antigravity` package dependency and integrate it as the backend for the Markdown chat in this app. Update the macOS entitlements so the app can spawn the local harness, and update README.md and the widget tests.
    ```
    Followed by: `git commit and tag as step-02-antigravity-sdk` and `/clear`.
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
  - **Prompt 3.1**:
    ```text
    Please review this program. I'm interested in which directory the Antigravity local harness has as its initial working directory
    ```
- **`S14` — Cast Clip 3.1: Investigating Initial Working Directory** (`layout: cast-full`)
  - `cast: /casts/03a-act3-cwd-review.cast`
- **`S15` — What `agy` Found: The macOS `.app` Bundle Root (` / `) Trap** (`layout: default`)
  - 2-column comparison (`Anti-Pattern: Implicit Directory.current` vs. `Target Architecture: Explicit Project Workspaces`):
    - Passing `workspaces: null` to `LocalAgentConfig` defaults to `Directory.current.absolute.path`.
    - From `flutter run`, `Directory.current` is `./`. From Finder/Dock (`agy_genui_demo.app`), macOS `launchd` sets `Directory.current` to **`/` (root)!**
    - Plus 2 bonus review catches: `threadTitle` locked into `CustomSystemInstructions` at session start, and shared composer draft text leaking across threads.
- **`S16` — Lead-in: Prompt 3.2 (Add Projects & Sandbox Escape Review UI)** (`layout: skill-breakdown`, `way: 2`)
  - **Prompt 3.2**:
    ```text
    1. Add a concept of projects that set a working directory for the Antigravity harness.
    2. I'm guessing workspaceOnly enables commands that are inside the sandbox. We should add UI that allows programs to be run that want to escape the sandbox, but only after review by the user.
    3. Update README.md and add `/skills/` to `.gitignore`.
    ```
- **`S17` — Cast Clip 3.2: Reverse-Engineering `localharness` Policies & Building the UI** (`layout: cast-full`)
  - `cast: /casts/03b-act3-projects-sandbox.cast`
  - **Talking Points During Playback**:
    - `agy` inspects `policy.dart`, `capabilities.dart`, and even runs `strings` on the `~/.antigravity/bin/localharness` Go binary!
    - Discovers `workspaceOnly` only confines file tools (`view_file`, `write_to_file`, etc.) — `CapabilitiesConfig(runCommand: RunCommandConfig(enableSandbox: true))` is what enables the OS-level `exebox` sandbox and exposes `BypassSandbox`.
    - Pauses at Marker `[19]` with `ask_question`: *"How should projects and conversation threads be organized in the UI?"* $\rightarrow$ we pick Option 1 (Projects group threads).
- **`S18` — Lead-in: Prompt 3.3 & 3.4 (Fix Review Issues & Tag `step-03-projects-sandbox`)** (`layout: skill-breakdown`, `way: 3`)
  - **Prompt 3.3 & 3.4**:
    ```text
    Please fix issues highlighted in the review
    ```
    Followed by: `git commit and tag as step-03-projects-sandbox` and `/clear`.
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
- **`S22` — From `genui` to A2UI v1.0 & Lead-in: Prompt 4.1** (`layout: skill-breakdown`, `way: 1`)
  - Context callout: `package:genui` has been deprecated in favor of the modular A2UI v1.0 packages (`a2ui_core`, `a2ui_agent`, `a2ui_flutter`).
  - **Prompt 4.1**:
    ```text
    Please add `a2ui_core`, `a2ui_agent`, and `a2ui_flutter` to this project and integrate A2UI v1.0 surface rendering into the chat UI so `<a2ui-json>` blocks stream live interactive `A2uiSurface` widgets inline alongside Markdown.
    ```
- **`S23` — Cast Clip 4.1: Streaming `<a2ui-json>` Surfaces & Debugging 3 Subtle Bugs** (`layout: cast-full`)
  - `cast: /casts/04a-act4-a2ui-surfaces.cast`
- **`S24` — 3 Real-World A2UI v1.0 Bugs `agy` Diagnosed During Testing** (`layout: default`)
  - Numbered breakdown of what `agy` caught via `flutter test`:
    1. **A2UI v1.0 `Text.variant` Schema Constraint**: `BasicCatalog.v1_0` only allows `'caption'` or `'body'` (v0.8 allowed `'h5'`).
    2. **Inline Backtick `<a2ui-json>` Tag Collision**: `DirectJsonParser` strips backticks around `` `<a2ui-json>` `` to forgive LLMs that wrap tags in inline code, so mentioning literal `` `<a2ui-json>` `` in prose opened the JSON block prematurely.
    3. **`A2uiMarkdown` Inside `OutlinedButton` Intercepting Taps**: Wrapping `A2uiSurface` with `A2uiMarkdown` made button labels `selectable: true` and full-width, swallowing pointer taps until `selectable: false, fitContent: true` was set.
- **`S25` — Lead-in: Prompt 4.2 (Research the A2UI Package Seamlines)** (`layout: skill-breakdown`, `way: 2`)
  - **Prompt 4.2**:
    ```text
    Please research the seamlines between a2ui_core, a2ui_agent and a2ui_flutter. Explain when to use each.
    ```
- **`S26` — Cast Clip 4.2: Researching A2UI Package Seamlines** (`layout: cast-full`)
  - `cast: /casts/04b-act4-a2ui-seamlines.cast`
- **`S27` — The 3 A2UI Packages & Their 4 Seamlines** (`layout: default`)
  - Architectural summary of `a2ui_core` (headless protocol, `Catalog`, `MessageProcessor`, `SurfaceModel` signals), `a2ui_agent` (`A2uiGenerator`, `DirectJsonFormatFactory`, `StreamedAnswer`), and `a2ui_flutter` (`basicCatalog()`, `A2uiSurface`, `A2uiMarkdown`).
- **`S28` — Lead-in: Prompt 4.3 (Explore Capabilities for This Codebase)** (`layout: skill-breakdown`, `way: 3`)
  - **Prompt 4.3**:
    ```text
    Give me some options for utilising this capability in the current codebase
    ```
- **`S29` — Cast Clip 4.3: Brainstorming 6 A2UI Enhancements** (`layout: cast-full`)
  - `cast: /casts/04c-act4-a2ui-options.cast`
- **`S30` — Lead-in: Prompt 4.4 & 4.5 (Clarifying Parameter Forms & Bidirectional RPCs)** (`layout: skill-breakdown`, `way: mashup`)
  - **Prompt 4.4 & 4.5**:
    ```text
    Please implement:
    - Interactive Clarifying Questions & Parameter Forms (Basic Catalog)
    - Bidirectional Renderer RPC Functions (`FunctionImplementation`)
    ```
    Followed by: `git commit and tag as step-04-a2ui` and `/clear`.
- **`S31` — Cast Clip 4.4: Implementing Parameter Forms & Custom `FunctionImplementation`s** (`layout: cast-full`)
  - `cast: /casts/04d-act4-forms-and-rpcs.cast`
  - **Talking Points**: `getWorkspaceInfo`, `listWorkspaceFiles`, `setSurfaceData`, and `formatParameterSummary` registered with `AllowedCallers.rendererOrAgent`.
- **`S32` — Screenshot & Live Demo: `step-04-a2ui`** (`layout: hardware-callout`)
  - `image: /images/step-04-a2ui.png`
  - **Live Demo Transition**:
    ```bash
    git clean -fd lib test && git checkout step-04-a2ui -- lib test
    # Press 'R' in flutter run!
    ```
  - **What to Show Live**: Quick-prompt chips (`Clarifying parameter form` and `Run workspace RPC function`), live reactive form summary (`formatParameterSummary`), `Use Audit Preset` button (`setSurfaceData`), and validation-gated submit button.

---

### Act 5: Codebase Review, Hardening Fixups & Finale (`slides/acts/06-act5-fixup.md`)

- **`S33` — Section Divider: Act 5 — Codebase Audit & Hardening Fixups** (`layout: center`)
  - `forwardSurfaceActionsToAgent` · RPC Batching · `step-05-fixup`
- **`S34` — Lead-in: Prompt 5.1 (Fresh-Session Codebase Audit)** (`layout: skill-breakdown`, `way: 1`)
  - **Prompt 5.1**:
    ```text
    please review this codebase
    ```
- **`S35` — Cast Clip 5.1: Auditing the Full Codebase** (`layout: cast-full`)
  - `cast: /casts/05a-act5-codebase-audit.cast`
- **`S36` — 5 Issues Surfaced by the Fresh-Context Audit** (`layout: default`)
  1. **`forwardSurfaceActionsToAgent` & `forwardRpcMessagesToAgent` defaulted to `false` in `main.dart`**: Surface button clicks in the live desktop app recorded locally without forwarding to `localharness`!
  2. **Stream Self-Cancellation on Multi-RPC Turns**: Synchronous `sendRpcMessageToAgent` mid-stream cancelled the active stream when multiple `callRendererFunction` calls fired in one block.
  3. **Auto-Titling Overwrote Custom Thread Titles on First Message**.
  4. **Sandbox-Escape Path Heuristics Edge Cases**: `--flag=/outside/path`, `$HOME` expansion, trailing `/..`, and false-positive `awk '/pattern/'`.
  5. **Unbounded Synchronous `listSync()` in `ListWorkspaceFilesFunction`**.
- **`S37` — Lead-in: Prompt 5.2 & 5.3 (Fix Surfaced Issues & Tag `step-05-fixup`)** (`layout: skill-breakdown`, `way: 3`)
  - **Prompt 5.2 & 5.3**:
    ```text
    please fix issues
    ```
    Followed by: `git commit and tag as step-05-fixup`.
- **`S38` — Cast Clip 5.2: Fixing All 5 Issues & Tagging `step-05-fixup`** (`layout: cast-full`)
  - `cast: /casts/05b-act5-fixups-and-tag.cast`
- **`S39` — Screenshot & Live Finale Demo: `step-05-fixup`** (`layout: hardware-callout`)
  - `image: /images/step-05-fixup.png`
  - **Live Demo Transition**:
    ```bash
    git clean -fd lib test && git checkout main -- lib test
    # Press 'R' in flutter run!
    ```
  - **What to Show Live**:
    1. Ask `Please ask a multiple choice question` $\rightarrow$ streams an interactive A2UI v1.0 Trivia card $\rightarrow$ pick **Java** and click **Submit Answer** $\rightarrow$ automatic two-way `ActionMessage` + `a2uiRendererDataModel` round-trip back to `localharness`!
    2. Ask `Please review this codebase` $\rightarrow$ runs `ls`/`find` inside the `exebox` sandbox and streams back a custom **Codebase Review Clarifying Parameter Form**.
- **`S40` — Takeaways & Resources** (`layout: default`)
  - Using `/clear` + Git tags at each milestone keeps context sharp and makes live-demo time travel effortless (`git checkout <tag> -- lib test` + Hot Restart).
  - Asking `agy` to review its own codebase in a fresh session (`Act 3.1` and `Act 5.1`) caught critical integration bugs before going on stage.
  - Links to repo, `CODELAB.md`, `prompts/` session transcripts, and A2UI / Antigravity SDK docs.
