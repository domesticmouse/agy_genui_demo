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
- In **Act 4**, we dedicate **4 slides** after Clip 4.2 to unpack the architecture and 4 seamlines between `a2ui_core`, `a2ui_agent`, and `a2ui_flutter`, and **2 slides** after Clip 4.3 to walk through the 6 A2UI capability options `agy` proposed for the codebase.
- At the end of each of the 5 Acts (where we create a Git tag), we show a **Screenshot & Live Demo Slide** (`layout: hardware-callout`) with the hot-restart checkout command to transition smoothly into the live macOS app.
- **Deck Rendering Libraries, LaTeX Guardrails & GitHub Hosting**:
  - Use Slidev's built-in **Shiki** (`highlighter: shiki`) for syntax highlighting, **KaTeX** for any standalone math, and **MermaidJS** for architecture, dependency, and sequence diagrams (`S03`, `S27`, `S31`, `S32`).
  - **Zero Raw LaTeX Leaks Rule**: CommonMark treats everything inside block-level HTML tags (`<div>`, `<ol>`, `<li>`, `<h3>`) as raw HTML and skips `markdown-it-katex`, causing `$...$` inside HTML wrappers to render verbatim as raw LaTeX text. Always use HTML entities or Unicode arrows (`&rarr;` / `→` and `&harr;` / `↔`) instead of TeX arrows inside HTML blocks, and escape literal dollar signs (`\$HOME`) when outside backticks.
  - **GitHub Pages Hosting & Links**:
    - Hosted at **`https://domesticmouse.github.io/agy_genui_demo/`** (`slidev build --base /agy_genui_demo/`) via `.github/workflows/deploy-slides.yml`.
    - All slide links to repository files (`CODELAB.md`, `PRESENTATION.md`, `prompts/*.md`, `lib/...`) must use full GitHub URLs (`https://github.com/domesticmouse/agy_genui_demo/blob/main/...`).
    - The final slide (`S49`) includes a **QR Code** (`slides/public/images/deck-qr.svg`) pointing to `https://domesticmouse.github.io/agy_genui_demo/` alongside links to the GitHub repository, session transcripts, interactive cast player, and pub.dev packages (`antigravity`, `a2ui_core`, `a2ui_agent`, `a2ui_flutter`, `flutter_markdown_plus`).

---

## Content Steering & Voice Guidelines

Use these guidelines to write, edit, or review content so that it sounds authentically like a seasoned, curious software engineer and developer advocate with decades of coding experience who loves exploring new domains (like synths, Eurorack, embedded hardware, and AI) and sharing the real, unfiltered learning journey.

### Core Persona & Worldview

1. **Experienced Peer & Curious Explorer**:
   - Write from the perspective of someone who has been coding for decades yet approaches new hobbies and tools with humble, infectious curiosity.
   - Frame learning as an adventure or exploration. Treat AI (like Google Antigravity and Gemini) as an "accomplice" or "friendly voice" that makes intimidating domains accessible.
2. **Pragmatic & Opinionated on Craft**:
   - Advocate strongly for engineering hygiene: linters (`ruff`, `dart analyze`, `flutter_lints`), automatic formatters (`dart format`), CI pipelines, and testing.
   - Frame these tools not as pedantic bureaucracy, but as sanity-savers that keep codebases evergreen and let humans focus on semantics.
3. **Generous Community Member**:
   - Credit peers, content creators, and library authors by name and link to their work (e.g., Jeremy from Red Means Recording, Zach of this.is.NOISE, Filip Hracek, David Morgan).
   - Maintain a philosophy of "the audience is always right/correct" when recounting live events or tutorials.

### What to Avoid (Anti-Patterns)

- **No Corporate AI Slop**: Never use stiff transitions or buzzwords like *"Furthermore"*, *"Moreover, it is crucial to delve into"*, *"In conclusion"*, *"testament to"*, *"tapestry"*, or *"game-changer"*.
- **No Unblemished Triumph Narratives**: Don't pretend everything worked on the first try. Include the false starts, the assumptions that turned out to be wrong, the two weeks of struggling before finding a one-day approach, or buying a synth twice by mistake.
- **No Unjustified Hype**: Ground excitement in concrete workflows, code diffs, or practical observations.

### Drafting & Review Checklist

Before presenting a draft or edit to the user, verify:
1. **Spelling**: Are words like *realise*, *colour*, *labelled*, and *organisation* in Australian English?
2. **Show, Don't Just Tell**: Are claims backed by specific links to repos, skills, prompts, or concrete examples?

---

## TODO: Live Demo Transition Screenshots

Each of the 5 Acts ends with a `layout: hardware-callout` slide displaying the **Git Tag** to check out, a screenshot of the macOS desktop app at that tag, and the live Hot Restart transition command.

- [x] **1. Act 1 Transition (`S07`) — Tag: `step-01-markdown-chat`**
  - **Captured Path**: [`screenshots/step-01-markdown-chat.png`](screenshots/step-01-markdown-chat.png) *(copied to `slides/public/images/step-01-markdown-chat.png` for Slidev)*
  - **Checkout Command**: `git clean -fd lib test && git checkout step-01-markdown-chat -- lib test`
  - **What Is Captured**: The macOS Markdown chat app showing the collapsible split-view thread sidebar on the left, the `Markdown Showcase` starter thread with `Hi **Bob**` and the simulated `Response: Hi Bob` breakdown (bold, italics, strikethrough `~~GFM~~`, blockquote, fenced code block, and GitHub-Flavored Markdown table), the `Copy Markdown` button on message bubbles, and the composer formatting toolbar + `Live Preview` toggle at the bottom.
- [x] **2. Act 2 Transition (`S11`) — Tag: `step-02-antigravity-sdk`**
  - **Captured Path**: [`screenshots/step-02-antigravity-sdk.png`](screenshots/step-02-antigravity-sdk.png) *(copied to `slides/public/images/step-02-antigravity-sdk.png` for Slidev)*
  - **Checkout Command**: `git clean -fd lib test && git checkout step-02-antigravity-sdk -- lib test`
  - **What Is Captured**: The macOS chat app connected to the live `package:antigravity` backend (`localharness`), showing the prompt `Compare StatelessWidget and StatefulWidget in a Markdown table with a short Dart code example.` and streamed assistant Markdown tokens with a 3-column comparison table.
- [x] **3. Act 3 Transition (`S20`) — Tag: `step-03-projects-sandbox`**
  - **Captured Path**: [`screenshots/step-03-projects-sandbox.png`](screenshots/step-03-projects-sandbox.png) *(copied to `slides/public/images/step-03-projects-sandbox.png` for Slidev)*
  - **Checkout Command**: `git clean -fd lib test && git checkout step-03-projects-sandbox -- lib test`
  - **What Is Captured**: The project-grouped sidebar (`agy_genui_demo` project and `/Users/brett/tmp/agy_genui_demo` working-directory pill in both the sidebar and top toolbar), `pwd` → `/Users/brett/tmp/agy_genui_demo` executed inside the `exebox` sandbox, and `What sort of project is this?` answered by inspecting the workspace.
- [x] **4. Act 4 Transition (`S41`) — Tag: `step-04-a2ui`**
  - **Captured Path**: [`screenshots/step-04-a2ui.png`](screenshots/step-04-a2ui.png) *(copied to `slides/public/images/step-04-a2ui.png` for Slidev)*
  - **Checkout Command**: `git clean -fd lib test && git checkout step-04-a2ui -- lib test`
  - **What Is Captured**: The prompt `Please give me a multi-choice question` streaming Markdown prose alongside an inline interactive **A2UI v1.0 `A2uiSurface` card** (`Computer History Trivia` with `ChoicePicker` chips `A) Python`, `B) Java`, `C) Ruby`, `D) Kotlin` and a validation-gated `Submit Answer` button).
- [x] **5. Act 5 Finale Transition (`S48`) — Tag: `step-05-fixup`**
  - **Captured Path**: [`screenshots/step-05-fixup.png`](screenshots/step-05-fixup.png) *(copied to `slides/public/images/step-05-fixup.png` for Slidev)*
  - **Checkout Command**: `git clean -fd lib test && git checkout step-05-fixup -- lib test`
  - **What Is Captured**: A live end-to-end bidirectional A2UI v1.0 RPC round-trip (`Invoke getWorkspaceInfo`), showing the first assistant bubble invoking the renderer-side `getWorkspaceInfo` function (`callRendererFunction`), `ChatViewModel` automatically flushing `RendererFunctionResponseMessage` back to `localharness` once the stream completes (`forwardRpcMessagesToAgent: true`), and the second assistant bubble rendering the returned `WorkspaceInfoSnapshot` (`Project Name: agy_genui_demo`, `Project ID: project-default`, `Working Directory: /Users/brett/tmp/agy_genui_demo`, `Active Thread Title: Markdown Showcase`, `Active Thread ID: thread-showcase`, `Theme Mode: light`).

---

## Cast Clips Breakdown (Split from `agy-genui-codelab.cast` + `plugins.cast`)

| Clip File (`recordings/final/`) | Act / Prompt | Source Markers | Event Range | Warped Duration | Ends With |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `01-act1-markdown-chat.cast` | Setup + Prompt 1.1 & 1.2 | `[1]–[8]` | `#0..#6585` | ~58.6s | `git tag step-01-markdown-chat` + `/clear` |
| `01b-act1-plugins.cast` (`plugins.cast`) | `/plugin` (How `agy` Knew Flutter Skills) | `[1]–[6]` | `#0..#51` | ~8.5s | Expanded `flutter` plugin details (25 Skills, Agents, Rules, MCP) |
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
  - **Presenter Notes**: Welcome everyone! When I pitched this talk, I had a simple, slightly mischievous question: what happens if we take Flutter on desktop, the new Google Antigravity SDK, and GenUI, and glue them all together?
- **`S01a` — Title Slide (The Deprecation Twist)** (`layout: center`, `class: text-center`)
  - **Title**: Flutter, Antigravity SDK, and ~~GenUI~~ **A2UI**
  - **Subtitle**: A vibe coding exploration
  - **Speaker**: Brett Morgan · Developer Relations Engineer, Google Cloud
  - **Presenter Notes**: And then, as happens in software engineering when you live on the bleeding edge, right as I sat down to build the demo I realised `package:genui` had just been deprecated and replaced by the brand-new **A2UI v1.0** packages (`a2ui_core`, `a2ui_agent`, `a2ui_flutter`). Rather than hiding that behind a polished slide deck, we're going to share the real, unfiltered learning journey — with `agy` as our accomplice.
- **`S02` — The Pitch: What Happens If We Glue Them Together?** (`layout: default`)
  - Revealed with `v-click` (1 ingredient per click):
    1. `[v-click 1]` **Flutter (macOS Desktop)**: Fast, expressive multi-platform UI with sub-second hot-restart and strict static analysis (`dart analyze`, `flutter_lints`).
    2. `[v-click 2]` **Google Antigravity (`agy` CLI & `package:antigravity` SDK)**: Both our coding accomplice building the app *and* the embedded agent backend running inside the app via `~/.antigravity/bin/localharness`.
    3. `[v-click 3]` **GenUI → A2UI v1.0 (`a2ui_core`, `a2ui_agent`, `a2ui_flutter`)**: Replacing `package:genui` with the modular A2UI v1.0 catalogue and protocol for streaming live interactive UI surfaces inline with Markdown.
  - **Presenter Notes**: Having an AI accomplice makes intimidating or brand-new APIs approachable, provided we pair that curiosity with real engineering hygiene — linters, formatters, and widget tests that act as sanity-savers and keep us honest.
- **`S03` — How We Built This: 5 Acts, `/clear`, and Git Tags** (`layout: default`)
  - Overview of the 5 tagged milestones, showing how each stage resets context with `/clear`, verifies `dart analyze` and `flutter test`, and ends with a Git tag we can hot-restart into in `<1s`:
    1. `step-00-scaffold` → `step-01-markdown-chat` — [Session 01 Transcript](prompts/01-6ee8f6c2-please-build-a-macos-desktop-markdown-chat.md)
    2. `step-02-antigravity-sdk` — [Session 02 Transcript](prompts/02-8f4aafaf-please-add-the-antigravity-package-dependency-and.md)
    3. `step-03-projects-sandbox` — [Session 03 Transcript](prompts/03-10ad2b6c-please-review-this-program-i-m-interested.md)
    4. `step-04-a2ui` — [Session 04 Transcript](prompts/04-ba34877d-please-add-a2ui-core-a2ui-agent-and.md)
    5. `step-05-fixup` — [Session 05 Transcript](prompts/05-7407df5f-please-review-this-codebase.md)
  - **Mermaid Diagram (Milestone Pipeline & Context Compaction)**:
    ```mermaid
    flowchart LR
      T0["step-00-scaffold"] -->|"Act 1"| T1["step-01-markdown-chat"]
      T1 -->|"/clear + Act 2"| T2["step-02-antigravity-sdk"]
      T2 -->|"/clear + Act 3 (Compacted!)"| T3["step-03-projects-sandbox"]
      T3 -->|"/clear + Act 4 (Compacted!)"| T4["step-04-a2ui"]
      T4 -->|"/clear + Act 5"| T5["step-05-fixup"]
    ```
  - **Presenter Notes**: My plan was simple: use `/clear` at the end of every act to keep the context window lean and avoid context bloat. Spoiler alert: despite my best intentions, I still got carried away stacking follow-up prompts inside Acts 3 and 4 and got hit by automatic context compaction (`Conversation compacted`) later in the show!

---

### Act 1: Build the macOS Markdown Chat UI (`slides/acts/02-act1-markdown-chat.md`)

- **`S04` — Section Divider: Act 1 — macOS Markdown Chat UI** (`layout: center`)
  - `flutter_markdown_plus` · `step-01-markdown-chat` · [Transcript 01](prompts/01-6ee8f6c2-please-build-a-macos-desktop-markdown-chat.md)
- **`S05a` — Lead-in: Terminal & Project Scaffold Commands** (`layout: skill-breakdown`, `way: 1`)
  - Revealed line-by-line with `v-click`:
    1. `[v-click 1]` `flutter create agy_genui_demo --platforms=macos`
    2. `[v-click 2]` `cd agy_genui_demo && git init && git add . && git commit -m "Initial commit"`
    3. `[v-click 3]` `git tag step-00-scaffold`
    4. `[v-click 4]` `agy`
  - **Presenter Notes**: We all know what the default Flutter counter app looks like, so we tag `step-00-scaffold` and jump straight into `agy`.
- **`S05b` — Lead-in: Prompt 1.1 (Build the Markdown Chat App)** (`layout: skill-breakdown`, `way: 1`)
  - Opening line visible initially; each numbered requirement revealed with `v-click`:
    - *Initial*: `Please build a macOS desktop Markdown chat application in this project using flutter_markdown_plus with the following features:`
    - `[v-click 1]` `1. A collapsible macOS split-view conversation thread sidebar with per-thread typing state, automatic thread titling, and starter threads showcasing rich Markdown.`
    - `[v-click 2]` `2. Markdown message rendering (headings, bold/italic/strikethrough, inline and fenced code blocks, blockquotes, lists, and GitHub-style tables) with a one-click Copy Markdown button on every message bubble.`
    - `[v-click 3]` `3. A Markdown composer that restores focus after sending, with a formatting toolbar (Bold, Italic, Inline Code, Code Block, List, Blockquote), a live Markdown preview toggle, and desktop keyboard shortcuts (Enter or Numpad Enter to send, Shift + Enter for a newline with an IME composition guard).`
    - `[v-click 4]` `4. A responsive top toolbar with Light and Dark Material 3 theme switching.`
    - `[v-click 5]` `5. Widget tests in test/widget_test.dart and macOS build/run instructions in README.md.`
  - **Presenter Notes**: Notice item 5: we ask for widget tests in [`test/widget_test.dart`](test/widget_test.dart) right from the first prompt. Having tests and static analysis in the loop isn't bureaucracy — it's what lets the agent catch its own layout mistakes before we ever see them.
- **`S05c` — Lead-in: Prompt 1.2 (Tag `step-01-markdown-chat` & Reset Context)** (`layout: skill-breakdown`, `way: 1`)
  - Revealed step-by-step with `v-click`:
    1. `[v-click 1]` Prompt: `git commit and tag as step-01-markdown-chat`
    2. `[v-click 2]` Slash command: `/clear`
- **`S06` — Cast Clip 1: Scaffolding & Building the Markdown Chat UI** (`layout: cast-full`)
  - `cast: /casts/01-act1-markdown-chat.cast`
  - **Talking Points During Playback** ([Session 01 Transcript](prompts/01-6ee8f6c2-please-build-a-macos-desktop-markdown-chat.md)):
    - Before writing a single line of Dart, `agy` reads `flutter-apply-architecture-best-practices`, `flutter-add-widget-test`, and `dart-run-static-analysis`.
    - Organises the codebase into clean Domain / Data / Presentation layers ([`lib/domain/models/chat_message.dart`](lib/domain/models/chat_message.dart), [`lib/domain/models/chat_thread.dart`](lib/domain/models/chat_thread.dart), [`lib/data/chat_repository.dart`](lib/data/chat_repository.dart), [`lib/presentation/viewmodels/chat_view_model.dart`](lib/presentation/viewmodels/chat_view_model.dart)).
    - **No unblemished triumph**: When `agy` runs `flutter test`, the 800px default test viewport triggers a horizontal `RenderFlex` overflow in [`lib/presentation/widgets/message_bubble.dart`](lib/presentation/widgets/message_bubble.dart) when a starter thread badge and timestamp sit side-by-side. Because `flutter test` and `dart analyze` are in the loop, `agy` spots the overflow immediately, fixes the flex wrapping, re-runs all 5 widget tests to green, and tags `step-01-markdown-chat`.
- **`S06a` — Lead-in: Wait — How Did `agy` Know Those Flutter Skills? (`/plugin`)** (`layout: skill-breakdown`, `way: 2`)
  - Revealed step-by-step with `v-click`:
    1. `[v-click 1]` Slash command: `/plugin`
    2. `[v-click 2]` Inspect **Discover (74)** marketplace & **Installed (5)** plugins (`flutter`, `firebase`, `egm`, `modern-web-guidance-plugin`, `chrome-devtools-plugin`).
  - **Presenter Notes**: If you watched closely during Clip 1, you might have wondered: where did those `flutter-apply-architecture-best-practices` and `dart-run-static-analysis` skills come from? We didn't put them in this repo!
- **`S06b` — Cast Clip 1b: Inspecting the Official Flutter Plugin (`/plugin`)** (`layout: cast-full`)
  - `cast: /casts/01b-act1-plugins.cast` *(from `plugins.cast`)*
  - **Talking Points During Playback**:
    - Typing `/plugin` opens the interactive plugin manager: **Installed (5)** vs. **Discover (74)** across Google Workspace, Build with Google, and partner shelves.
    - Expanding the official **`flutter` plugin** (authored by the Flutter & Dart teams) reveals everything bundled as a single toggleable unit:
      - **25 Dart & Flutter Skills** (`flutter-apply-architecture-best-practices`, `flutter-add-widget-test`, `dart-run-static-analysis`, `flutter-fix-layout-issues`, etc.)
      - **Custom Subagent**: `flutter_a11y_agent`
      - **Rules**: `flutter-hot-reload.md`, `flutter-hot-reload.mdc`
      - **MCP Server**: `dart-mcp-server`
- **`S07` — Screenshot & Live Demo: `step-01-markdown-chat`** (`layout: hardware-callout`)
  - **Git Tag on Slide**: `step-01-markdown-chat`
  - **Screenshot**: [`screenshots/step-01-markdown-chat.png`](screenshots/step-01-markdown-chat.png) (`image: /images/step-01-markdown-chat.png` in Slidev)
  - **Live Demo Transition**:
    ```bash
    git clean -fd lib test && git checkout step-01-markdown-chat -- lib test
    # Press 'R' (Hot Restart) in flutter run!
    ```
  - **What to Show Live**: Collapsible thread sidebar, GitHub-Flavored Markdown tables/code blocks, Copy Markdown button, composer formatting toolbar + live preview pane, Light/Dark colour scheme toggle, and simulated replies (`Hi **Bob**`).

---

### Act 2: Integrate the Antigravity Dart SDK (`slides/acts/03-act2-antigravity-sdk.md`)

- **`S08` — Section Divider: Act 2 — Antigravity Dart SDK Backend** (`layout: center`)
  - `package:antigravity` · `localharness` · `step-02-antigravity-sdk` · [Transcript 02](prompts/02-8f4aafaf-please-add-the-antigravity-package-dependency-and.md)
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
  - **Talking Points During Playback** ([Session 02 Transcript](prompts/02-8f4aafaf-please-add-the-antigravity-package-dependency-and.md)):
    - After running `flutter pub add antigravity`, `agy` doesn't guess the SDK API — it reads `~/.pub-cache/hosted/pub.dev/antigravity-0.18.1/lib/` directly.
    - Discovers that `LocalConnectionStrategy` spawns `~/.antigravity/bin/localharness` as a subprocess and opens a local WebSocket + outbound HTTPS, so it updates [`macos/Runner/DebugProfile.entitlements`](macos/Runner/DebugProfile.entitlements) and [`macos/Runner/Release.entitlements`](macos/Runner/Release.entitlements) (`com.apple.security.app-sandbox: false`, `network.client: true`, `network.server: true`).
    - **Testing sanity-saver**: While reading `antigravity`'s `chat.dart`, `agy` realises `ChatResponse.chunks` uses a `Future.delayed(5ms)` polling loop and `Agent.start()` spawns a real OS process — which would hang Flutter's `FakeAsync` widget test zone! So it designs an injectable `AntigravityAgentSession` interface in [`lib/data/antigravity_chat_service.dart`](lib/data/antigravity_chat_service.dart) and tags `step-02-antigravity-sdk`.
- **`S11` — Screenshot & Live Demo: `step-02-antigravity-sdk`** (`layout: hardware-callout`)
  - **Git Tag on Slide**: `step-02-antigravity-sdk`
  - **Screenshot**: [`screenshots/step-02-antigravity-sdk.png`](screenshots/step-02-antigravity-sdk.png) (`image: /images/step-02-antigravity-sdk.png` in Slidev)
  - **Live Demo Transition**:
    ```bash
    git clean -fd lib test && git checkout step-02-antigravity-sdk -- lib test
    # Press 'R' in flutter run!
    ```
  - **What to Show Live**: Send a real conceptual/Markdown prompt (e.g., `Compare StatelessWidget and StatefulWidget in a Markdown table with a short Dart code example.`) in the macOS app and watch live streaming tokens arrive from `localharness` via `package:antigravity`.

---

### Act 3: Project Workspaces (`CWD`) & Sandbox Escape Review UI (`slides/acts/04-act3-projects-sandbox.md`)

- **`S12` — Section Divider: Act 3 — Project Workspaces & Sandbox Review** (`layout: center`)
  - `workspaces` · `exebox` · `askUser` · `step-03-projects-sandbox` · [Transcript 03](prompts/03-10ad2b6c-please-review-this-program-i-m-interested.md)
- **`S13` — Lead-in: Prompt 3.1 (Which Directory Is `localharness` Running In?)** (`layout: skill-breakdown`, `way: 1`)
  - Each sentence revealed with `v-click`:
    1. `[v-click 1]` `Please review this program.`
    2. `[v-click 2]` `I'm interested in which directory the Antigravity local harness has as its initial working directory`
  - **Presenter Notes**: Once the app was talking to `localharness`, I got curious — and slightly nervous. What directory does a macOS desktop app actually hand to an embedded coding agent as its working directory?
- **`S14` — Cast Clip 3.1: Investigating Initial Working Directory** (`layout: cast-full`)
  - `cast: /casts/03a-act3-cwd-review.cast`
- **`S15` — What `agy` Found: The macOS `.app` Bundle Root (`/`) Trap** (`layout: default`)
  - 2-column comparison (`Anti-Pattern: Implicit Directory.current` vs. `Target Architecture: Explicit Project Workspaces`):
    - Passing `workspaces: null` to `LocalAgentConfig` defaults to `Directory.current.absolute.path` in `local_strategy.dart`.
    - When launched via `flutter run`, `Directory.current` is your repo root (`./`). When launched from Finder or the macOS Dock (`agy_genui_demo.app`), macOS `launchd` sets `Directory.current` to **`/` (the filesystem root)!**
    - Plus 2 bonus code-review catches: `threadTitle` was locked into `CustomSystemInstructions` at session creation time, and `composerController` draft text leaked across threads when switching conversations.
- **`S16` — Lead-in: Prompt 3.2 (Add Projects & Sandbox Escape Review UI)** (`layout: skill-breakdown`, `way: 2`)
  - Each numbered item (and its sub-sentences) revealed with `v-click`:
    1. `[v-click 1]` `1. Add a concept of projects that set a working directory for the Antigravity harness.`
    2. `[v-click 2]` `2. I'm guessing workspaceOnly enables commands that are inside the sandbox.`
    3. `[v-click 3]` `We should add UI that allows programs to be run that want to escape the sandbox, but only after review by the user.`
    4. `[v-click 4]` `3. Update README.md and add /skills/ to .gitignore.`
  - **Presenter Notes**: Look at item 2: *"I'm guessing `workspaceOnly` enables commands that are inside the sandbox."* Spoiler alert: my assumption was completely wrong! And watching how `agy` checks my assumption is one of my favourite moments in the whole recording.
- **`S17` — Cast Clip 3.2: Reverse-Engineering `localharness` Policies & Building the UI** (`layout: cast-full`)
  - `cast: /casts/03b-act3-projects-sandbox.cast`
  - **Talking Points During Playback** ([Session 03 Transcript](prompts/03-10ad2b6c-please-review-this-program-i-m-interested.md)):
    - **Checking my wrong assumption**: `agy` inspects `policy.dart`, `capabilities.dart`, and even runs `strings` on the `~/.antigravity/bin/localharness` Go binary!
    - Gently proves me wrong: `workspaceOnly` only confines file tools (`view_file`, `write_to_file`, `grep_search`, etc.). It is actually `CapabilitiesConfig(runCommand: RunCommandConfig(enableSandbox: true))` that enables the OS-level `exebox` sandbox and exposes `BypassSandbox` on `run_command`.
    - Pauses at Marker `[19]` with `ask_question`: *"How should projects and conversation threads be organized in the UI?"* → we choose Option 1 (Projects group threads).
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
  - **Talking Points**:
    - **Context bloat strikes!** Because we stacked Prompt 3.1 (code review), Prompt 3.2 (binary reverse-engineering + full UI implementation), and Prompt 3.3 (review fixes) without a `/clear` in between, you'll see `─── Conversation compacted ───` trigger automatically right at the start of this clip!
    - Even after automatic compaction, `agy` retains the earlier review findings, fixes per-thread draft preservation (`_draftsByThreadId`) and automatic session recreation when a thread's title or project workspace changes, verifies all 10 widget tests, and tags `step-03-projects-sandbox`.
- **`S20` — Screenshot & Live Demo: `step-03-projects-sandbox`** (`layout: hardware-callout`)
  - **Git Tag on Slide**: `step-03-projects-sandbox`
  - **Screenshot**: [`screenshots/step-03-projects-sandbox.png`](screenshots/step-03-projects-sandbox.png) (`image: /images/step-03-projects-sandbox.png` in Slidev)
  - **Live Demo Transition**:
    ```bash
    git clean -fd lib test && git checkout step-03-projects-sandbox -- lib test
    # Press 'R' in flutter run!
    ```
  - **What to Show Live**: Project switcher & New Project dialogue (`/Users/brett/tmp/agy_genui_demo` working-directory pill in sidebar & toolbar), in-sandbox `run_command` execution (`pwd` and `What sort of project is this?`), per-thread isolated drafts, and the amber **Sandbox Escape Review** banner (`Deny` / `Approve & Run` backed by a `Completer<bool>`).

---

### Act 4: Generative UI with A2UI v1.0 (`slides/acts/05-act4-a2ui.md`)

- **`S21` — Section Divider: Act 4 — Generative UI with A2UI v1.0** (`layout: center`)
  - `a2ui_core` · `a2ui_agent` · `a2ui_flutter` · `step-04-a2ui` · [Transcript 04](prompts/04-ba34877d-please-add-a2ui-core-a2ui-agent-and.md)
- **`S22` — Lead-in: Prompt 4.1 (Add `a2ui_core`, `a2ui_agent`, and `a2ui_flutter`)** (`layout: skill-breakdown`, `way: 1`)
  - Revealed clause-by-clause with `v-click`:
    1. `[v-click 1]` `Please add a2ui_core, a2ui_agent, and a2ui_flutter to this project`
    2. `[v-click 2]` `and integrate A2UI v1.0 surface rendering into the chat UI so <a2ui-json> blocks stream live interactive A2uiSurface widgets inline alongside Markdown.`
- **`S23` — Cast Clip 4.1: Streaming `<a2ui-json>` Surfaces & Debugging 3 Subtle Bugs** (`layout: cast-full`)
  - `cast: /casts/04a-act4-a2ui-surfaces.cast`
  - **Talking Points During Playback**:
    - Exploring all three brand-new A2UI packages in `.pub-cache` and diagnosing three subtle integration bugs takes 90+ tool calls in a single turn — triggering automatic `Conversation compacted` even inside a freshly `/clear`ed session!
- **`S24` — 3 Real-World A2UI v1.0 Bugs `agy` Diagnosed During Testing** (`layout: default`)
  - Revealed one bug at a time with `v-click`:
    1. `[v-click 1]` **A2UI v1.0 `Text.variant` Schema Constraint**: `BasicCatalog.v1_0` only allows `'caption'` or `'body'` (v0.8 allowed `'h5'`), which `PayloadValidator` caught immediately when validating our starter surface.
    2. `[v-click 2]` **Inline Backtick `<a2ui-json>` Tag Collision**: `DirectJsonParser` strips backticks around `` `<a2ui-json>` `` to forgive LLMs that wrap tags in inline code, so mentioning literal `` `<a2ui-json>` `` in prose opened the JSON block prematurely!
    3. `[v-click 3]` **`A2uiMarkdown` Inside `OutlinedButton` Intercepting Taps**: Wrapping `A2uiSurface` with `A2uiMarkdown` made button labels `selectable: true` and full-width, swallowing pointer taps in widget tests until `selectable: false, fitContent: true` was set in [`lib/presentation/widgets/message_bubble.dart`](lib/presentation/widgets/message_bubble.dart).
  - **Presenter Notes**: None of these three bugs were obvious from reading a README. All three were caught because `agy` wrote widget tests for the streaming surfaces and refused to move on until `flutter test` and `dart analyze` were completely clean.

#### Deep Dive Part A: A2UI Package Architecture & Seamlines (7 Slides After Clip 4.2)

- **`S25` — Lead-in: Prompt 4.2 (Research the A2UI Package Seamlines)** (`layout: skill-breakdown`, `way: 2`)
  - Each sentence revealed with `v-click`:
    1. `[v-click 1]` `Please research the seamlines between a2ui_core, a2ui_agent and a2ui_flutter.`
    2. `[v-click 2]` `Explain when to use each.`
  - **Presenter Notes**: Because `a2ui_core`, `a2ui_agent`, and `a2ui_flutter` had just replaced `package:genui`, I asked `agy` to be my research accomplice and map out the exact architectural seamlines between the three packages.
- **`S26` — Cast Clip 4.2: Researching A2UI Package Seamlines** (`layout: cast-full`)
  - `cast: /casts/04b-act4-a2ui-seamlines.cast`
- **`S27` — Overview (1 of 7): How the 3 A2UI Packages Layer Together** (`layout: default`)
  - High-level package dependency graph and separation of concerns:
    - **`a2ui_core`** (Pure Dart foundation): Zero dependency on Flutter or any LLM SDK.
    - **`a2ui_agent`** (Pure Dart agent bridge): Depends on `a2ui_core` (and `antlr4`), **never** on `flutter`.
    - **`a2ui_flutter`** (Flutter widget layer): Depends on `a2ui_core` and `flutter`, **never** on `a2ui_agent`.
  - **Mermaid Diagram (Package Dependency Graph)**:
    ```mermaid
    flowchart TD
      App["agy_genui_demo (Flutter macOS App)"] --> Agent["a2ui_agent (Pure Dart + antlr4)"]
      App --> Flutter["a2ui_flutter (Flutter Widget Adapter)"]
      Agent -->|"Imports"| Core["a2ui_core (Pure Dart Protocol, Catalog & Signals)"]
      Flutter -->|"Imports"| Core
      Flutter -->|"Imports"| SDK["package:flutter"]
    ```
- **`S28` — Package 1 (2 of 7): `a2ui_core` — Headless Protocol, State & Expression Engine** (`layout: default`)
  - Revealed with `v-click`:
    1. `[v-click 1]` **Wire Protocol & Envelopes**: `AgentToRendererMessage` (`CreateSurfaceMessage`, `UpdateComponentsMessage`, `UpdateDataModelMessage`, `DeleteSurfaceMessage`, `CallRendererFunctionMessage`) and `RendererToAgentMessage` (`ActionMessage`, `ErrorMessage`, `FunctionResponseMessage`).
    2. `[v-click 2]` **Catalogue Specification**: `Catalog<T extends ComponentApi, F extends FunctionApi>` and `BasicCatalog.v1_0` (JSON Schemas for components + client-side functions like `formatString`, `required`, `regex`).
    3. `[v-click 3]` **Message Routing & Validation**: `MessageProcessor<T>` validates messages against catalogue schemas (`PayloadValidator`) and component graph topology (`ValidationConfig`), applying them to `SurfaceGroupModel<T>`.
    4. `[v-click 4]` **Reactive Surface & Node Resolution**: `SurfaceModel<T>`, `DataModel`, `GenericBinder`, and `NodeResolver<T>` turn a surface's flat component map and JSON Pointer data model (`@path`, `@call`) into a reactive tree of `ComponentNode<T>` backed by `preact_signals`.
- **`S29` — Package 2 (3 of 7): `a2ui_agent` — Prompt Generation, Stream Parsing & JSON Healing** (`layout: default`)
  - Revealed with `v-click`:
    1. `[v-click 1]` **Capability Negotiation**: `A2uiGenerator` matches the client's `A2uiRendererCapabilities` against available `CatalogConfig`s (optionally pruning via `PruningTransformer`) to build an `A2uiRequestProcessor`.
    2. `[v-click 2]` **System Prompt Generation**: `a2uiRequestProcessor.promptSnippet` emits the system instructions and `---BEGIN A2UI JSON SCHEMA---` teaching the LLM to output `<a2ui-json>` (`DirectJsonFormatFactory`) or A2UI Express DSL (`ExpressFormatFactory`).
    3. `[v-click 3]` **Streaming LLM Parser & JSON Healer**: `DirectJsonParser` and `DirectJsonContinuingResponseStream` split raw LLM token streams into prose `TextPart`, healed incremental `A2uiPart` (`List<AgentToRendererMessage>`), and `ErrorPart` while validating against `RendererState` with transactional rollback on invalid blocks.
- **`S30` — Package 3 (4 of 7): `a2ui_flutter` — Flutter Widget Adapter (`package:flutter`)** (`layout: default`)
  - Revealed with `v-click`:
    1. `[v-click 1]` **Concrete Component Type (`ComponentImplementation`)**: Subclasses `a2ui_core`'s `ComponentApi`, attaching a `ComponentWidgetBuilder` (`Widget Function(BuildContext, ComponentNode, ComponentProps, ChildWidgetBuilder)`) to each component's JSON Schema.
    2. `[v-click 2]` **Flutter Basic Catalogue (`basicCatalog()`)**: Returns a `CatalogImplementation` (`Catalog<ComponentImplementation, FunctionImplementation>`) implementing all 18 A2UI v1.0 basic components (`Card`, `Row`, `Column`, `List`, `Tabs`, `Modal`, `Text`, `Image`, `Icon`, `Video`, `AudioPlayer`, `Divider`, `Button`, `TextField`, `CheckBox`, `ChoicePicker`, `Slider`, `DateTimeInput`).
    3. `[v-click 3]` **Reactive Surface Widget (`A2uiSurface`)**: Takes a `SurfaceModel<ComponentImplementation>`, attaches a `NodeResolver<ComponentImplementation>`, and rebuilds only affected widget subtrees via `SignalState` as signals change.
- **`S31` — Seamlines 1 & 2 (5 of 7): Catalogue Type Erasure & Stream Processing** (`layout: skill-breakdown`, `way: 1`)
  - **Seamline 1: `ComponentApi` ↔ `ComponentImplementation` (`a2ui_core` ↔ `a2ui_flutter` & `a2ui_agent`)**
    - `a2ui_core` is generic over `T extends ComponentApi`.
    - `a2ui_flutter` provides `basicCatalog()` (`Catalog<ComponentImplementation, FunctionImplementation>`).
    - `a2ui_agent`'s `CatalogConfig.fromCatalog(a2uiCatalog)` erases the Flutter widget builder down to `ComponentApi` JSON Schemas so prompt generation never imports Flutter.
  - **Seamline 2: `A2uiRequestProcessor` ↔ `MessageProcessor<T>` (`a2ui_agent` ↔ `a2ui_core`)**
    - `A2uiRequestProcessor` converts raw LLM text chunks (`<a2ui-json>`) → `List<AgentToRendererMessage>`.
    - `MessageProcessor<T>` consumes `List<AgentToRendererMessage>` → mutates `SurfaceGroupModel<T>` / `SurfaceModel<T>`.
    - Can run across a network wire (Server → Client) or fused in-process via `RendererState.of(renderer)` and `StreamedAnswer<ComponentImplementation>` (`AnswerTextPart`, `AnswerSurfacePart`, `AnswerErrorPart`).
  - **Mermaid Diagram (Inbound Streaming Pipeline)**:
    ```mermaid
    flowchart LR
      LLM["LLM Stream (Markdown + a2ui-json)"] --> ReqProc["A2uiRequestProcessor (a2ui_agent)"]
      ReqProc -->|"TextPart"| Prose["AnswerTextPart (Markdown)"]
      ReqProc -->|"AgentToRendererMessage[]"| MsgProc["MessageProcessor (a2ui_core)"]
      MsgProc -->|"Mutates"| SurfModel["SurfaceModel (a2ui_core)"]
      SurfModel -->|"Mounts"| Widget["A2uiSurface (a2ui_flutter)"]
    ```
- **`S32` — Seamlines 3 & 4 (6 of 7): Reactive Surface Mounting & Two-Way Actions** (`layout: skill-breakdown`, `way: 2`)
  - **Seamline 3: `SurfaceModel<ComponentImplementation>` ↔ `A2uiSurface` (`a2ui_core` ↔ `a2ui_flutter`)**
    - `MessageProcessor<ComponentImplementation>` (or `AnswerSurfacePart.surface`) produces a `SurfaceModel<ComponentImplementation>` passed directly to `A2uiSurface(key: ObjectKey(surface), surface: surface)`, wrapped in `A2uiMarkdown` for rich text.
  - **Seamline 4: `onAction` & `outboundListener` ↔ `ActionMessage` + `getRendererDataModel` (`a2ui_flutter` → `a2ui_core` → `a2ui_agent`)**
    1. *Local Data Bindings (`WritableBinding`)*: Editing `TextField`, `CheckBox`, or `Slider` bound to `{"@path": "/..."}` mutates `SurfaceModel.dataModel` in-place in `a2ui_core` without round-tripping to the agent.
    2. *Agent Actions (`NodeAction`)*: Pressing a `Button` resolves `action.event.context` against `SurfaceModel.dataModel` and emits `A2uiRendererAction` on `renderer.model.onAction`.
    3. *Outbound Turn*: Wrapped in `a2ui_core`'s `ActionMessage` + `renderer.getRendererDataModel(version: A2uiProtocolVersion.v1_0)` (plus `outboundListener` for `RendererFunctionResponseMessage` / `CallAgentFunctionMessage`) and sent back to the agent.
  - **Mermaid Diagram (Two-Way Local Binding vs. Agent Action Loop)**:
    ```mermaid
    sequenceDiagram
      actor User
      participant UI as "A2uiSurface (a2ui_flutter)"
      participant Model as "SurfaceModel.dataModel (a2ui_core)"
      participant Agent as "Antigravity Agent (localharness)"
      User->>UI: Edit TextField / Slider (@path)
      UI->>Model: WritableBinding mutates signal in-place
      Model-->>UI: SignalState rebuilds bound widgets
      User->>UI: Click Submit Button (NodeAction)
      UI->>Model: Resolve action.event.context + getRendererDataModel
      Model->>Agent: ActionMessage + a2uiRendererDataModel
      Agent-->>Model: Stream UpdateDataModel / UpdateComponents
      Model-->>UI: Reactive subtree update
    ```
- **`S33` — When to Use Each Package (7 of 7): 4 Architecture Topologies** (`layout: default`)
  - Revealed one topology at a time with `v-click`:
    1. `[v-click 1]` **Full-Stack / Local Agent Flutter App (`agy_genui_demo`)** — `a2ui_core` + `a2ui_agent` + `a2ui_flutter`: App both prompts/streams from the LLM (`StreamedAnswer`) and renders interactive `A2uiSurface` widgets over shared `SurfaceModel` state.
    2. `[v-click 2]` **Thin Flutter Client + Remote Backend Agent** — `a2ui_core` + `a2ui_flutter` (No `a2ui_agent` on client): Backend server parses LLM output and streams `AgentToRendererMessage`s over WebSockets/SSE/gRPC directly into the client's `MessageProcessor<ComponentImplementation>`.
    3. `[v-click 3]` **Dart Backend Agent Server / CLI (`shelf`, `dart_frog`, CLI)** — `a2ui_core` + `a2ui_agent` (No `a2ui_flutter`): Pure Dart server cannot depend on `flutter`; uses `BasicCatalog.v1_0()` + `A2uiRequestProcessor` + `RendererState` to prompt the LLM, heal/validate `<a2ui-json>`, and forward messages to clients.
    4. `[v-click 4]` **Custom Non-Flutter Dart Renderer / Headless Testing** — `a2ui_core` (+ optional `a2ui_agent`): Subclass `ComponentApi` and mount `NodeResolver<MyComponent>` to target Jaspr, terminal UI, or headless unit tests.

#### Deep Dive Part B: Options `agy` Suggested for Utilising A2UI (2 Slides After Clip 4.3)

- **`S34` — Lead-in: Prompt 4.3 (Explore Capabilities for This Codebase)** (`layout: skill-breakdown`, `way: 3`)
  - **Prompt 4.3**:
    ```text
    Give me some options for utilising this capability in the current codebase
    ```
- **`S35` — Cast Clip 4.3: Brainstorming 6 A2UI Enhancements** (`layout: cast-full`)
  - `cast: /casts/04c-act4-a2ui-options.cast`
- **`S36` — `agy`'s Suggestions (1 of 2): Action Loops, Developer Widgets & Canvas** (`layout: default`)
  - Revealed with `v-click`:
    - `[v-click 1]` **Option 1: Live Two-Way Action Loop (`Button` → Agent Turn + `a2uiRendererDataModel` Sync)**
      - Automatically dispatch `ActionMessage` + `a2uiRendererDataModel` to the thread's Antigravity `Agent` when a user clicks an `A2uiSurface` `Button`.
      - Show a compact user "Action Pill" in the chat feed (e.g., `⚡ Action: book_flight (destination: Kyoto)`) and let the agent mutate the existing surface in-place via `updateDataModel` / `updateComponents` or stream a follow-up surface.
      - Attach `renderer.getRendererDataModel(version: A2uiProtocolVersion.v1_0)` to regular text prompts when active surfaces have `sendDataModel: true`.
    - `[v-click 2]` **Option 2: Custom Workspace & Developer Catalogue (`CatalogImplementation` Extensions)**
      - Pair custom JSON Schemas with Flutter `ComponentWidgetBuilder`s tailored to an Antigravity coding assistant:
        - `CodeDiffCard`: Side-by-side or unified diff preview with **Apply Patch** / **Discard** action buttons.
        - `FileTreeCard` / `WorkspaceFileCard`: Clickable file badges (`path`, `lineStart`, `lineEnd`, `summary`) for files in `ChatProject.workingDirectory`.
        - `CommandRunnerCard`: Proposes a shell command with editable flags (`TextField` / `CheckBox` bound to data model) and a **Run in Workspace** button.
    - `[v-click 3]` **Option 3: Persistent Split-Pane "Surface Canvas" Drawer (Alongside Inline Chat Surfaces)**
      - `RendererState` supports two UX modes over the same `MessageProcessor`: inline chat turns and a persistent canvas where multi-turn prompts iteratively evolve a single surface.
      - Add a toggleable right-hand **A2UI Inspector / Canvas** pane in `ChatScreen` and `TopToolbar`.
      - Pin any active surface from `renderer.model.allSurfaces` with a live **Data Model JSON Inspector** (`surface.dataModel`) and **Component Tree Viewer** to watch `@path` bindings mutate in real time.
- **`S37` — `agy`'s Suggestions (2 of 2): Self-Healing, Clarification Forms & RPCs** (`layout: default`)
  - Revealed with `v-click`:
    - `[v-click 1]` **Option 4: Self-Healing Validation Loop (Automatic LLM Repair on `AnswerErrorPart`)**
      - When the LLM emits a malformed `<a2ui-json>` block or violates a component schema, `StreamedAnswer` rolls back that block and `MessageBubble` displays `_InlineA2uiErrorBanner`.
      - Add a **Fix Surface** button on `_InlineA2uiErrorBanner` (or an automatic 1-retry self-repair option in `ChatViewModel`) that sends `ErrorMessage(version: '1.0', error: ...)` back to the thread's Antigravity session so the agent repairs the surface automatically.
    - `[v-click 2]` **Option 5: Agent-Driven Clarification Forms ("Ask Question" Surface Pattern)** *(Selected for Act 4.4)*
      - Instead of asking plain-text clarifying questions before writing code or running tools, the agent streams an interactive A2UI v1.0 parameter form (`ChoicePicker` chips/checkboxes, `TextField` with validation `checks`, `CheckBox`, `Slider`, and a validation-gated `Submit` `Button`).
      - Submitting the form sends the resolved JSON context + data model straight back to the agent.
    - `[v-click 3]` **Option 6: A2UI Express Format Toggle (`DirectJsonFormatFactory` vs. `ExpressFormatFactory`) & Bidirectional RPCs (`FunctionImplementation`)** *(Selected for Act 4.4)*
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
  - **Talking Points**: Implements [`lib/data/catalog/renderer_rpc_functions.dart`](lib/data/catalog/renderer_rpc_functions.dart) with `getWorkspaceInfo`, `listWorkspaceFiles`, `setSurfaceData`, and `formatParameterSummary` registered with `AllowedCallers.rendererOrAgent`, plus 17 passing widget tests, and tags `step-04-a2ui`.
- **`S41` — Screenshot & Live Demo: `step-04-a2ui`** (`layout: hardware-callout`)
  - **Git Tag on Slide**: `step-04-a2ui`
  - **Screenshot**: [`screenshots/step-04-a2ui.png`](screenshots/step-04-a2ui.png) (`image: /images/step-04-a2ui.png` in Slidev)
  - **Live Demo Transition**:
    ```bash
    git clean -fd lib test && git checkout step-04-a2ui -- lib test
    # Press 'R' in flutter run!
    ```
  - **What to Show Live**: Prompt `Please give me a multi-choice question` streaming an inline `A2uiSurface` card (`Computer History Trivia` with `ChoicePicker` chips and validation-gated `Submit Answer` button), or click `+ New Thread` to try the quick-prompt chips (`Clarifying parameter form` and `Run workspace RPC function`).
  - **Cliffhanger into Act 5**: Notice what happens if we click `Submit Answer` right now at `step-04-a2ui` — it records the action locally, *but doesn't send a turn back to `localharness` yet!* Why? Let's ask a fresh session of `agy` to review the codebase in Act 5.

---

### Act 5: Codebase Review, Hardening Fixups & Finale (`slides/acts/06-act5-fixup.md`)

- **`S42` — Section Divider: Act 5 — Codebase Audit & Hardening Fixups** (`layout: center`)
  - `forwardSurfaceActionsToAgent` · RPC Batching · `step-05-fixup` · [Transcript 05](prompts/05-7407df5f-please-review-this-codebase.md)
- **`S43` — Lead-in: Prompt 5.1 (Fresh-Session Codebase Audit)** (`layout: skill-breakdown`, `way: 1`)
  - **Prompt 5.1**:
    ```text
    please review this codebase
    ```
  - **Presenter Notes**: Before declaring victory, we clear the context window one more time and ask a fresh session of `agy` to audit the whole codebase from scratch. If you take one workflow habit away from this talk, make it this one!
- **`S44` — Cast Clip 5.1: Auditing the Full Codebase** (`layout: cast-full`)
  - `cast: /casts/05a-act5-codebase-audit.cast`
- **`S45` — 5 Issues Surfaced by the Fresh-Context Audit** (`layout: default`)
  - Revealed one issue at a time with `v-click`:
    1. `[v-click 1]` **`forwardSurfaceActionsToAgent` & `forwardRpcMessagesToAgent` defaulted to `false` in [`lib/main.dart`](lib/main.dart)**: To keep earlier widget tests deterministic, Act 4 had left both flags defaulting to `false` in `ChatViewModel` — meaning clicking an A2UI surface button in the live desktop app recorded the action pill locally without ever forwarding it to `localharness`!
    2. `[v-click 2]` **Stream Self-Cancellation on Multi-RPC Turns**: Calling `sendRpcMessageToAgent` synchronously inside `outboundListener` mid-stream incremented `_requestGeneration` and cancelled the active LLM stream whenever multiple `callRendererFunction` envelopes arrived in one block.
    3. `[v-click 3]` **Auto-Titling Overwrote Custom Thread Titles on First Message**: `thread.messages.isEmpty` overwrote user-renamed threads on their first message.
    4. `[v-click 4]` **Sandbox-Escape Path Heuristics Edge Cases**: [`lib/data/repositories/chat_repository.dart`](lib/data/repositories/chat_repository.dart) missed `--flag=/outside/path`, `$HOME` expansion, and trailing `/..`, while false-positiving on `awk '/pattern/'`.
    5. `[v-click 5]` **Unbounded Synchronous `listSync()` in `ListWorkspaceFilesFunction`**: Could block the Flutter UI thread if a user pointed a project at a huge parent directory.
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
  - **Talking Points**: Enables `forwardSurfaceActionsToAgent: true` and `forwardRpcMessagesToAgent: true` in [`lib/main.dart`](lib/main.dart), batches pending RPC responses in [`lib/ui/features/chat/view_models/chat_view_model.dart`](lib/ui/features/chat/view_models/chat_view_model.dart) until the active stream finishes, hardens sandbox path heuristics, caps directory traversal in [`lib/data/catalog/renderer_rpc_functions.dart`](lib/data/catalog/renderer_rpc_functions.dart), brings the test suite to 21 passing widget tests, and tags `step-05-fixup`.
- **`S48` — Screenshot & Live Finale Demo: `step-05-fixup`** (`layout: hardware-callout`)
  - **Git Tag on Slide**: `step-05-fixup`
  - **Screenshot**: [`screenshots/step-05-fixup.png`](screenshots/step-05-fixup.png) (`image: /images/step-05-fixup.png` in Slidev)
  - **Live Demo Transition**:
    ```bash
    git clean -fd lib test && git checkout step-05-fixup -- lib test
    # Press 'R' in flutter run!
    ```
  - **What to Show Live** ([Session 06 Transcript](prompts/06-7e5e8534-please-ask-a-multiple-choice-question.md)):
    1. Ask `Invoke getWorkspaceInfo` → `localharness` emits `callRendererFunction: getWorkspaceInfo`, Flutter's `MessageProcessor` executes [`GetWorkspaceInfoFunction`](lib/data/catalog/renderer_rpc_functions.dart), `ChatViewModel` flushes the batched `RendererFunctionResponseMessage` back to `localharness` when the first stream finishes (`forwardRpcMessagesToAgent: true`), and the agent renders the live `Workspace Information` table (`Project Name`, `Working Directory`, `Active Thread Title`, `Theme Mode: light`).
    2. Ask `Please ask a multiple choice question` → streams an interactive A2UI v1.0 Trivia card → pick **Java** and click **Submit Answer** → automatic two-way `ActionMessage` + `a2uiRendererDataModel` round-trip back to `localharness`!
- **`S49` — Takeaways, Resources & Thank You (with Deck QR Code)** (`layout: default`)
  - **Takeaways**:
    - **Treat AI as a curious accomplice, not an infallible oracle**: Share the false starts (`workspaceOnly` vs `enableSandbox`, `Directory.current` in Finder, `forwardSurfaceActionsToAgent: false`) — and ask the agent to audit its own work in a fresh `/clear` session.
    - **Manage context bloat deliberately (and expect compaction when you get greedy)**: Using `/clear` at the end of each milestone keeps context sharp, though stacking multi-step exploration and implementation turns in Acts 3 and 4 still triggered automatic context compaction (`Conversation compacted`) mid-flight.
    - **Engineering hygiene is a sanity-saver**: `dart analyze`, `flutter_lints`, `dart format`, and widget tests keep the codebase evergreen so humans can focus on semantics.
    - **Git tags + Hot Restart = Live-Demo Time Travel**: `git checkout <tag> -- lib test` lets us jump between any of the 5 acts (`step-01-markdown-chat` through `step-05-fixup`) in under a second.
  - **QR Code (Right Column / Callout Card)**:
    - **QR Code Asset**: `slides/public/images/deck-qr.svg` (`image: /images/deck-qr.svg`) encoding **`https://domesticmouse.github.io/agy_genui_demo/`** so the audience can scan the deck and click every resource link below directly from their phone.
  - **Resources & Links**:
    - **Live Presentation Deck**: [`https://domesticmouse.github.io/agy_genui_demo/`](https://domesticmouse.github.io/agy_genui_demo/)
    - **GitHub Repository & Codelab**: [`github.com/domesticmouse/agy_genui_demo`](https://github.com/domesticmouse/agy_genui_demo) · [`CODELAB.md`](https://github.com/domesticmouse/agy_genui_demo/blob/main/CODELAB.md) · [`PRESENTATION.md`](https://github.com/domesticmouse/agy_genui_demo/blob/main/PRESENTATION.md)
    - **Exported Session Transcripts (via `agy-brain-explorer`)**: [`prompts/README.md`](https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/README.md) ([01](https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/01-6ee8f6c2-please-build-a-macos-desktop-markdown-chat.md) · [02](https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/02-8f4aafaf-please-add-the-antigravity-package-dependency-and.md) · [03](https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/03-10ad2b6c-please-review-this-program-i-m-interested.md) · [04](https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/04-ba34877d-please-add-a2ui-core-a2ui-agent-and.md) · [05](https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/05-7407df5f-please-review-this-codebase.md) · [06](https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/06-7e5e8534-please-ask-a-multiple-choice-question.md) · [07](https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/07-fd1fed76-please-extract-agy-brain-transcripts-for-this.md))
    - **Standalone Interactive Cast Player**: [`agy-genui-codelab-cast-player.html`](https://domesticmouse.github.io/agy_genui_demo/agy-genui-codelab-cast-player.html)
    - **Pub.dev Packages**: [`antigravity`](https://pub.dev/packages/antigravity) · [`a2ui_core`](https://pub.dev/packages/a2ui_core) · [`a2ui_agent`](https://pub.dev/packages/a2ui_agent) · [`a2ui_flutter`](https://pub.dev/packages/a2ui_flutter) · [`flutter_markdown_plus`](https://pub.dev/packages/flutter_markdown_plus)
