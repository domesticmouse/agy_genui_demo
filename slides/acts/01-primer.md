---
layout: center
class: text-center
---

<!-- S01 -->
<div class="h-full flex flex-col items-center justify-center">
  <h1 class="text-5xl font-extrabold tracking-tight text-white mb-3">
    Flutter, Antigravity SDK, and GenUI
  </h1>
  <p class="text-2xl text-gray-300 font-light max-w-2xl">
    A vibe coding exploration
  </p>

  <div class="mt-10 text-gray-400 text-base">
    <span class="font-semibold text-gray-200">Brett Morgan</span> &middot; Developer Relations Engineer, Google Cloud
  </div>

  <div class="mt-10 text-xs text-gray-500">
    Press <kbd>Space</kbd> or <kbd>&rarr;</kbd> to advance
  </div>
</div>

<!--
Welcome everyone! When I pitched this talk, I had a simple, slightly mischievous question: what happens if we take Flutter on desktop, the new Google Antigravity SDK, and GenUI, and glue them all together?
-->

---
layout: center
class: text-center
---

<!-- S01a -->
<div class="h-full flex flex-col items-center justify-center">
  <h1 class="text-5xl font-extrabold tracking-tight text-white mb-3">
    Flutter, Antigravity SDK, and <del class="text-gray-500 decoration-red-400/80">GenUI</del> <span class="text-cyan-400">A2UI</span>
  </h1>
  <p class="text-2xl text-gray-300 font-light max-w-2xl">
    A vibe coding exploration
  </p>

  <div class="mt-10 text-gray-400 text-base">
    <span class="font-semibold text-gray-200">Brett Morgan</span> &middot; Developer Relations Engineer, Google Cloud
  </div>

  <div class="mt-6 text-xs font-mono text-amber-300/90 bg-amber-950/30 border border-amber-500/30 px-3 py-1.5 rounded-lg">
    package:genui deprecated &rarr; replaced by a2ui_core, a2ui_agent &amp; a2ui_flutter (v1.0)
  </div>
</div>

<!--
And then, as happens in software engineering when you live on the bleeding edge, right as I sat down to build the demo I realised package:genui had just been deprecated and replaced by the brand-new A2UI v1.0 packages: a2ui_core, a2ui_agent, and a2ui_flutter. Rather than hiding that behind a polished slide deck, we are going to share the real, unfiltered learning journey — with agy as our accomplice.
-->

---
layout: default
---

<!-- S02 -->
<div class="flex items-center gap-3 mb-6">
  <h2 class="text-2xl font-bold m-0">The Pitch: What Happens If We Glue Them Together?</h2>
</div>

<ol class="space-y-5 text-sm text-gray-200 list-decimal pl-6 mt-6 leading-relaxed">
  <li v-click>
    <strong class="text-white text-base">Flutter (macOS Desktop)</strong>
    <ul class="list-disc pl-5 mt-1.5 space-y-1 text-gray-300">
      <li>Fast, expressive multi-platform UI with sub-second hot-restart during live demos.</li>
      <li>Strict engineering hygiene out of the box with <code class="text-cyan-300">dart analyze</code>, <code class="text-cyan-300">flutter_lints</code>, and widget testing.</li>
    </ul>
  </li>
  <li v-click>
    <strong class="text-white text-base">Google Antigravity (<code class="text-amber-300">agy</code> CLI &amp; <code class="text-amber-300">package:antigravity</code> SDK)</strong>
    <ul class="list-disc pl-5 mt-1.5 space-y-1 text-gray-300">
      <li>Acts as our pair-programming accomplice building the application from the terminal.</li>
      <li>Also runs <em>inside</em> the Flutter app as its live agent backend via <code class="text-amber-300">~/.antigravity/bin/localharness</code>.</li>
    </ul>
  </li>
  <li v-click>
    <strong class="text-white text-base">GenUI &rarr; A2UI v1.0 (<code class="text-emerald-300">a2ui_core</code>, <code class="text-emerald-300">a2ui_agent</code>, <code class="text-emerald-300">a2ui_flutter</code>)</strong>
    <ul class="list-disc pl-5 mt-1.5 space-y-1 text-gray-300">
      <li>Replaces <code class="text-gray-400">package:genui</code> with the modular A2UI v1.0 component catalogue and JSON transport protocol.</li>
      <li>Streams live interactive UI surfaces (<code class="text-emerald-300">A2uiSurface</code>) and two-way RPCs inline alongside standard Markdown.</li>
    </ul>
  </li>
</ol>

<!--
Having an AI accomplice makes intimidating or brand-new APIs approachable, provided we pair that curiosity with real engineering hygiene — linters, formatters, and widget tests that act as sanity-savers and keep us honest. First, we have Flutter on macOS desktop giving us sub-second hot-restart and strict static analysis. Second, we use Google Antigravity twice: both as the agy CLI building the app and as the embedded SDK backend running localharness inside the app. Third, we bring in the brand-new A2UI v1.0 packages to stream live interactive UI surfaces inline with Markdown.
-->

---
layout: default
---

<!-- S03 -->
<div class="flex items-center gap-3 mb-4">
  <h2 class="text-2xl font-bold m-0">How We Built This</h2>
</div>

<p class="text-sm text-gray-300 leading-relaxed mb-5">
  Five incremental milestones &mdash; each verified with static analysis and widget tests, tagged in Git for instant hot-restart, and followed by <code class="text-amber-300">/clear</code> to reset the context window:
</p>

<ol class="space-y-4 text-sm text-gray-200 list-decimal pl-6 leading-relaxed">
  <li v-click>
    <strong class="text-white text-base">macOS Desktop Markdown Chat UI</strong>
    <div class="text-gray-300 mt-0.5">
      Scaffold a native desktop chat interface with conversation threads, live preview, and GitHub-Flavored Markdown.
    </div>
  </li>
  <li v-click>
    <strong class="text-white text-base">Live Antigravity SDK Backend</strong>
    <div class="text-gray-300 mt-0.5">
      Replace the simulated reply loop with a live agent backend and configure macOS sandbox entitlements.
    </div>
  </li>
  <li v-click>
    <strong class="text-white text-base">Project Workspaces &amp; Sandbox Review UI</strong>
    <div class="text-gray-300 mt-0.5">
      Ground conversations in local project folders and add an interactive approval flow for out-of-sandbox commands.
    </div>
  </li>
  <li v-click>
    <strong class="text-white text-base">A2UI v1.0 Streaming Surfaces &amp; Two-Way RPCs</strong>
    <div class="text-gray-300 mt-0.5">
      Stream interactive UI cards, forms, and client-side function calls inline alongside standard Markdown.
    </div>
  </li>
  <li v-click>
    <strong class="text-white text-base">Fresh-Context Codebase Audit &amp; Fixups</strong>
    <div class="text-gray-300 mt-0.5">
      Audit the full codebase in a clean session to uncover and fix five real end-to-end integration bugs.
    </div>
  </li>
</ol>

<!--
My plan was simple: build the application across five incremental steps, verify each step with static analysis and widget tests, tag each milestone in Git so we can hot-restart between them in under a second, and run /clear at the end of every act to keep the context window lean. First, we scaffold a macOS desktop Markdown chat UI. Second, we wire up the live Antigravity SDK backend and macOS entitlements. Third, we add local project workspaces and an interactive sandbox approval UI. Fourth, we stream interactive A2UI v1.0 surfaces, forms, and two-way RPCs inline with Markdown. And fifth, we start a fresh session to audit our own codebase and fix five real integration bugs.
-->
