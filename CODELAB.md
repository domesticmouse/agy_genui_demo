# Codelab: Building a macOS Agentic Markdown & A2UI Chat App with Flutter & Antigravity SDK

This streamlined codelab walks through building `agy_genui_demo` from scratch in **`agy`** (Google Antigravity CLI), starting from `flutter create` and progressing through 5 focused acts using `/clear` and Git tags at each milestone. It is designed both for capturing an [`asciinema`](https://asciinema.org/) terminal recording and for live-demoing the Flutter macOS app at each tagged stage.

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

Turn the default Flutter counter app into a desktop split-view Markdown chat application powered by `flutter_markdown_plus`.

### Prompt 1.1 — Build the Markdown Chat App
```text
Please build a macOS desktop Markdown chat application in this project using `flutter_markdown_plus` with the following features:
1. A collapsible macOS split-view conversation thread sidebar with per-thread typing state, automatic thread titling, and starter threads showcasing rich Markdown.
2. Markdown message rendering (headings, bold/italic/strikethrough, inline and fenced code blocks, blockquotes, lists, and GitHub-style tables) with a one-click Copy Markdown button on every message bubble.
3. A Markdown composer that restores focus after sending, with a formatting toolbar (Bold, Italic, Inline Code, Code Block, List, Blockquote), a live Markdown preview toggle, and desktop keyboard shortcuts (`Enter` or `Numpad Enter` to send, `Shift + Enter` for a newline with an IME composition guard).
4. A responsive top toolbar with Light and Dark Material 3 theme switching.
5. Widget tests in `test/widget_test.dart` and macOS build/run instructions in `README.md`.
```

### Prompt 1.2 — Commit & Tag `step-01-markdown-chat`
```text
git commit and tag as step-01-markdown-chat
```

### Reset Context for Act 2
```text
/clear
```

---

## Act 2: Integrate the Antigravity Dart SDK (`step-02-antigravity-sdk`)

Replace the simulated canned assistant replies with live streaming responses from the Google Antigravity Dart SDK (`package:antigravity`).

### Prompt 2.1 — Add & Wire Up `package:antigravity`
```text
Please add the `antigravity` package dependency and integrate it as the backend for the Markdown chat in this app. Update the macOS entitlements so the app can spawn the local harness, and update README.md and the widget tests.
```

### Prompt 2.2 — Commit & Tag `step-02-antigravity-sdk`
```text
git commit and tag as step-02-antigravity-sdk
```

### Reset Context for Act 3
```text
/clear
```

---

## Act 3: Project Workspaces (`CWD`) & Sandbox Escape Review UI (`step-03-projects-sandbox`)

Investigate how `localharness` determines its working directory when launched from a macOS `.app` bundle, add **Projects** to control the workspace directory, and add a human-in-the-loop **Sandbox Escape Review** gate.

### Prompt 3.1 — Investigate `localharness` Initial Working Directory
```text
Please review this program. I'm interested in which directory the Antigravity local harness has as its initial working directory
```

### Prompt 3.2 — Add Project Workspaces & Sandbox Escape Review UI
```text
1. Add a concept of projects that set a working directory for the Antigravity harness.
2. I'm guessing workspaceOnly enables commands that are inside the sandbox. We should add UI that allows programs to be run that want to escape the sandbox, but only after review by the user.
3. Update README.md and add `/skills/` to `.gitignore`.
```

When `agy` asks **"How should projects and conversation threads be organized in the UI?"**, select Option 1:
- `(Recommended) Projects group threads (project switcher + New Project dialog with a working directory path, filtering threads by active project)`

### Prompt 3.3 — Fix Issues Highlighted in the Review
Address the observations surfaced during the Prompt 3.1 codebase review (per-thread composer draft isolation and session recreation on thread rename):
```text
Please fix issues highlighted in the review
```

### Prompt 3.4 — Commit & Tag `step-03-projects-sandbox`
```text
git commit and tag as step-03-projects-sandbox
```

### Reset Context for Act 4
```text
/clear
```

---

## Act 4: Generative UI with A2UI (`step-04-a2ui`)

Add Agent-to-UI (A2UI v1.0) generative UI surfaces (`a2ui_core`, `a2ui_agent`, `a2ui_flutter`), explore the package seamlines, and implement interactive clarifying parameter forms plus bidirectional renderer RPC functions.

### Prompt 4.1 — Add `a2ui_core`, `a2ui_agent`, and `a2ui_flutter`
```text
Please add `a2ui_core`, `a2ui_agent`, and `a2ui_flutter` to this project and integrate A2UI v1.0 surface rendering into the chat UI so `<a2ui-json>` blocks stream live interactive `A2uiSurface` widgets inline alongside Markdown.
```

### Prompt 4.2 — Research Package Seamlines
```text
Please research the seamlines between a2ui_core, a2ui_agent and a2ui_flutter. Explain when to use each.
```

### Prompt 4.3 — Explore Capabilities for This Codebase
```text
Give me some options for utilising this capability in the current codebase
```

### Prompt 4.4 — Implement Clarifying Parameter Forms & Bidirectional Renderer RPC Functions
```text
Please implement:
- Interactive Clarifying Questions & Parameter Forms (Basic Catalog)
- Bidirectional Renderer RPC Functions (`FunctionImplementation`)
```

### Prompt 4.5 — Commit & Tag `step-04-a2ui`
```text
git commit and tag as step-04-a2ui
```

### Reset Context for Act 5
```text
/clear
```

---

## Act 5: Codebase Review & Hardening Fixups (`step-05-fixup`)

Start a fresh session to audit the full codebase and resolve the surfaced issues—enabling automatic A2UI surface action and batched stream-safe outbound RPC forwarding in production, preserving custom thread titles on first message, hardening sandbox-escape path heuristics (`--flag=/path`, `KEY=/path`, `$HOME`/`$TMPDIR`, trailing `/..`, and single-segment `/regex/` literals), and bounding synchronous directory scans in `ListWorkspaceFilesFunction`.

### Prompt 5.1 — Audit the Full Codebase
```text
please review this codebase
```

### Prompt 5.2 — Fix Surfaced Issues
```text
please fix issues
```

### Prompt 5.3 — Commit & Tag `step-05-fixup`
```text
git commit and tag as step-05-fixup
```

### Finish the Recording
Exit `agy` (`Ctrl+D` twice or `/exit`) and stop `asciinema` (`Ctrl+D` or `exit`).

---

## Live-Demo Guide: Switching Between Tagged Milestones

Each milestone is tagged in Git so you can move the app forward or backward alongside your `asciinema` playback:

| Git Tag | Act | What to Demo Live in the macOS App |
| :--- | :---: | :--- |
| `step-00-scaffold` | Setup | Default Flutter counter app (`flutter create --platforms=macos`) |
| `step-01-markdown-chat` | Act 1 | Split-view thread sidebar, Markdown composer toolbar, live preview, Light/Dark theme, simulated replies |
| `step-02-antigravity-sdk` | Act 2 | Real streaming Gemini responses via `package:antigravity` (`localharness`) and macOS entitlement setup |
| `step-03-projects-sandbox` | Act 3 | Grouping threads by **Projects** (`CWD`), per-thread composer drafts, and the **Approve & Run / Deny** sandbox-escape review card |
| `step-04-a2ui` | Act 4 | Streaming inline `<a2ui-json>` v1.0 surfaces, interactive clarifying parameter forms (`ChoicePicker`, `CheckBox`, `TextField`), and bidirectional RPCs (`getWorkspaceInfo`, `listWorkspaceFiles`, `callAgentFunction`) |
| `step-05-fixup` | Act 5 | Automatic A2UI action & batched outbound RPC forwarding to the agent, hardened sandbox-escape path heuristics, preserved custom thread titles, and bounded workspace directory scans |

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
