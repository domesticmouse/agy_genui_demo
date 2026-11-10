---
layout: center
class: text-center
---

<!-- S04 -->
<div class="space-y-4">
  <h1 class="text-4xl font-extrabold text-white">
    Act 1 &mdash; macOS Markdown Chat UI
  </h1>
  <p class="text-xl font-mono text-cyan-300">
    flutter_markdown_plus &middot; step-01-markdown-chat &middot;
    <a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/01-6ee8f6c2-please-build-a-macos-desktop-markdown-chat.md" target="_blank" class="underline hover:text-cyan-200">Transcript 01</a>
  </p>
  <p class="text-base text-gray-400 max-w-xl mx-auto">
    Scaffolding a native macOS desktop chat workspace with GitHub-Flavored Markdown, live preview, and automated widget tests.
  </p>
</div>

<!--
Let us dive into Act 1. Our goal here is to go from a brand-new Flutter project to a rich macOS desktop Markdown chat application using flutter_markdown_plus, complete with widget tests and static analysis.
-->

---
layout: skill-breakdown
way: 1
title: "Terminal & Project Scaffold Commands"
---

<!-- S05a -->
<div class="space-y-4 my-auto">
  <div class="text-xs font-mono text-cyan-400 uppercase tracking-wider">
    Shell Setup &mdash; Baseline Tag (step-00-scaffold)
  </div>

  <div class="space-y-2.5 font-mono text-sm">
    <div v-click class="p-3 rounded-lg bg-[#0d0e12] border border-gray-800 text-gray-200">
      <span class="text-gray-500 select-none">&#36; </span>flutter create agy_genui_demo --platforms=macos
    </div>
    <div v-click class="p-3 rounded-lg bg-[#0d0e12] border border-gray-800 text-gray-200">
      <span class="text-gray-500 select-none">&#36; </span>cd agy_genui_demo &amp;&amp; git init &amp;&amp; git add . &amp;&amp; git commit -m "Initial commit"
    </div>
    <div v-click class="p-3 rounded-lg bg-[#0d0e12] border border-gray-800 text-cyan-300">
      <span class="text-gray-500 select-none">&#36; </span>git tag step-00-scaffold
    </div>
    <div v-click class="p-3 rounded-lg bg-[#0d0e12] border border-cyan-500/40 text-amber-300 font-bold">
      <span class="text-gray-500 select-none">&#36; </span>agy
    </div>
  </div>
</div>

<!--
We all know what the default Flutter counter app looks like, so we create the macOS project, commit the initial scaffold, tag it as step-00-scaffold, and launch straight into agy.
-->

---
layout: skill-breakdown
way: 1
title: "Prompt 1.1 — Build the Markdown Chat App"
---

<!-- S05b -->
<div class="space-y-3 text-xs leading-relaxed">
  <div class="p-3 rounded-lg bg-[#0d0e12] border border-cyan-500/30 font-mono text-cyan-200">
    Please build a macOS desktop Markdown chat application in this project using flutter_markdown_plus with the following features:
  </div>

  <div class="space-y-2 font-mono text-gray-200 pl-2">
    <div v-click class="p-2.5 rounded-lg bg-gray-900/80 border border-gray-800">
      <span class="text-cyan-400 font-bold">1.</span> A collapsible macOS split-view conversation thread sidebar with per-thread typing state, automatic thread titling, and starter threads showcasing rich Markdown.
    </div>
    <div v-click class="p-2.5 rounded-lg bg-gray-900/80 border border-gray-800">
      <span class="text-cyan-400 font-bold">2.</span> Markdown message rendering (headings, bold/italic/strikethrough, inline and fenced code blocks, blockquotes, lists, and GitHub-style tables) with a one-click Copy Markdown button on every message bubble.
    </div>
    <div v-click class="p-2.5 rounded-lg bg-gray-900/80 border border-gray-800">
      <span class="text-cyan-400 font-bold">3.</span> A Markdown composer that restores focus after sending, with a formatting toolbar (Bold, Italic, Inline Code, Code Block, List, Blockquote), a live Markdown preview toggle, and desktop keyboard shortcuts (Enter or Numpad Enter to send, Shift + Enter for a newline with an IME composition guard).
    </div>
    <div v-click class="p-2.5 rounded-lg bg-gray-900/80 border border-gray-800">
      <span class="text-cyan-400 font-bold">4.</span> A responsive top toolbar with Light and Dark Material 3 theme switching.
    </div>
    <div v-click class="p-2.5 rounded-lg bg-emerald-950/30 border border-emerald-500/40 text-emerald-200">
      <span class="text-emerald-400 font-bold">5.</span> Widget tests in <code class="text-emerald-300">test/widget_test.dart</code> and macOS build/run instructions in <code class="text-emerald-300">README.md</code>.
    </div>
  </div>
</div>

<!--
Here is Prompt 1.1. We ask for a collapsible split-view sidebar, full GitHub-Flavored Markdown message bubbles with a Copy Markdown button, a desktop composer with keyboard shortcuts and live preview, and Light and Dark Material 3 themes. Notice item 5 at the bottom: we ask for widget tests in test/widget_test.dart right from the first prompt. Having tests and static analysis in the loop is not bureaucracy — it is what lets the agent catch its own layout mistakes before we ever see them.
-->

---
layout: skill-breakdown
way: 1
title: "Prompt 1.2 — Tag step-01-markdown-chat & Reset Context"
---

<!-- S05c -->
<div class="space-y-4 my-auto">
  <div class="text-xs font-mono text-cyan-400 uppercase tracking-wider">
    Commit Milestone &amp; Reset Session Context
  </div>

  <div class="space-y-3 font-mono text-sm">
    <div v-click class="p-3.5 rounded-lg bg-[#0d0e12] border border-gray-800 text-gray-200">
      <span class="text-cyan-400 font-semibold">Prompt: </span>git commit and tag as step-01-markdown-chat
    </div>
    <div v-click class="p-3.5 rounded-lg bg-[#0d0e12] border border-amber-500/40 text-amber-300">
      <span class="text-gray-400 font-semibold">Slash command: </span>/clear
    </div>
  </div>

  <p class="text-xs text-gray-400 pt-2">
    Tagging the milestone lets us hot-restart straight into Act 1 during the live demo, while <code class="text-amber-300">/clear</code> resets the conversation window before Act 2.
  </p>
</div>

<!--
Once the build and tests pass, we send Prompt 1.2 to commit and tag step-01-markdown-chat, followed immediately by the /clear slash command so we start Act 2 with a fresh context window.
-->

---
layout: cast-full
title: "Act 1: Scaffolding & Building the Markdown Chat UI"
cast: /casts/01-act1-markdown-chat.cast
autoPlay: false
speed: 2.0
idleTimeLimit: 2.0
fit: both
---

<!-- S06 -->
<!--
Let us watch Clip 1. Notice that before writing a single line of Dart, agy reads three skills: flutter-apply-architecture-best-practices, flutter-add-widget-test, and dart-run-static-analysis. It organises the codebase into clean Domain, Data, and Presentation layers. And here is my favourite part — no unblemished triumph! When agy runs flutter test, the 800-pixel default test viewport triggers a horizontal RenderFlex overflow in message_bubble.dart when a starter thread badge and timestamp sit side-by-side. Because flutter test and dart analyze are in the loop, agy spots the overflow immediately, fixes the flex wrapping, re-runs all five widget tests to green, and tags step-01-markdown-chat.
-->

---
layout: skill-breakdown
way: 2
title: "Wait — How Did agy Know Those Flutter Skills? (/plugin)"
---

<!-- S06a -->
<div class="space-y-4 my-auto">
  <div class="text-xs font-mono text-amber-400 uppercase tracking-wider">
    Inspecting Installed Agent Plugins
  </div>

  <div class="space-y-3 text-sm">
    <div v-click class="p-3.5 rounded-lg bg-[#0d0e12] border border-amber-500/40 font-mono text-amber-300">
      <span class="text-gray-400">Slash command: </span>/plugin
    </div>
    <div v-click class="p-4 rounded-lg bg-gray-900/80 border border-gray-800 text-gray-200 space-y-2">
      <div class="font-semibold text-white">
        Inspect <span class="text-cyan-300 font-mono">Discover (74)</span> marketplace &amp; <span class="text-emerald-300 font-mono">Installed (5)</span> plugins:
      </div>
      <div class="flex flex-wrap gap-2 font-mono text-xs pt-1">
        <span class="px-2.5 py-1 rounded bg-cyan-950/60 border border-cyan-500/40 text-cyan-200 font-bold">flutter</span>
        <span class="px-2.5 py-1 rounded bg-gray-800 border border-gray-700 text-gray-300">firebase</span>
        <span class="px-2.5 py-1 rounded bg-gray-800 border border-gray-700 text-gray-300">egm</span>
        <span class="px-2.5 py-1 rounded bg-gray-800 border border-gray-700 text-gray-300">modern-web-guidance-plugin</span>
        <span class="px-2.5 py-1 rounded bg-gray-800 border border-gray-700 text-gray-300">chrome-devtools-plugin</span>
      </div>
    </div>
  </div>
</div>

<!--
If you watched closely during Clip 1, you might have wondered: where did those flutter-apply-architecture-best-practices and dart-run-static-analysis skills come from? We did not put them in this repository! Let us run the /plugin command inside agy to see where they live.
-->

---
layout: cast-full
title: "Inspecting the Official Flutter Plugin (/plugin)"
cast: /casts/01b-act1-plugins.cast
autoPlay: false
speed: 2.0
idleTimeLimit: 2.0
fit: both
---

<!-- S06b -->
<!--
Typing /plugin opens the interactive plugin manager, showing our 5 installed plugins alongside 74 discoverable plugins across the marketplace. When we expand the official flutter plugin authored by the Flutter and Dart teams, we see everything bundled together as a single toggleable unit: 25 Dart and Flutter skills including architecture best practices, widget testing, and static analysis, plus the flutter_a11y_agent subagent, hot-reload rules, and the dart-mcp-server.
-->

---
layout: hardware-callout
title: "Live Demo — step-01-markdown-chat"
image: /images/step-01-markdown-chat.png
imageCaption: "Tag: step-01-markdown-chat · macOS Markdown Chat UI"
---

<!-- S07 -->
<div class="space-y-3">
  <div class="flex items-center justify-between">
    <span class="text-xs font-mono uppercase tracking-wider text-cyan-400">Git Tag Milestone</span>
    <code class="text-xs font-mono px-2 py-0.5 rounded bg-cyan-950/60 border border-cyan-500/40 text-cyan-200">step-01-markdown-chat</code>
  </div>

```bash
git clean -fd lib test && git checkout step-01-markdown-chat -- lib test
# Press 'R' (Hot Restart) in flutter run!
```

  <div class="text-xs text-gray-300 space-y-1.5 pt-1">
    <div class="font-semibold text-white">What to Explore Live:</div>
    <ul class="list-disc pl-4 space-y-1 text-gray-300">
      <li>Collapsible split-view thread sidebar &amp; starter threads (<code class="text-cyan-300">Markdown Showcase</code>).</li>
      <li>GitHub-Flavored Markdown tables, fenced code blocks, and <code class="text-cyan-300">Copy Markdown</code> action in <a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/lib/presentation/widgets/message_bubble.dart" target="_blank" class="text-cyan-400 underline">message_bubble.dart</a>.</li>
      <li>Composer formatting toolbar, <code class="text-cyan-300">Live Preview</code> toggle, Light/Dark colour scheme toggle, and simulated reply (<code class="text-amber-300">Hi **Bob**</code>).</li>
    </ul>
  </div>
</div>

<!--
Let us switch over to our live macOS desktop app at step-01-markdown-chat! With a quick git checkout and capital R for Hot Restart, we can test out the collapsible thread sidebar, GitHub-Flavored Markdown tables, the Copy Markdown button, the live preview pane, and Light and Dark Material 3 colour schemes.
-->
