---
layout: center
class: text-center
---

<!-- S12 -->
<div class="space-y-4">
  <h1 class="text-4xl font-extrabold text-white">
    Act 3 &mdash; Project Workspaces &amp; Sandbox Review
  </h1>
  <p class="text-xl font-mono text-emerald-300">
    workspaces &middot; exebox &middot; askUser &middot; step-03-projects-sandbox &middot;
    <a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/03-10ad2b6c-please-review-this-program-i-m-interested.md" target="_blank" class="underline hover:text-emerald-200">Transcript 03</a>
  </p>
  <p class="text-base text-gray-400 max-w-xl mx-auto">
    Auditing initial working directories on macOS, reverse-engineering localharness sandbox policies, and building a human-in-the-loop escape review UI.
  </p>
</div>

<!--
Welcome to Act 3! Once our macOS desktop app was talking to localharness, I got curious — and slightly nervous. What directory does a macOS desktop app actually hand to an embedded coding agent as its initial working directory, and how do we keep terminal commands safely sandboxed?
-->

---
layout: skill-breakdown
way: 1
title: "Prompt 3.1 — Which Directory Is localharness Running In?"
---

<!-- S13 -->
<div class="space-y-4 my-auto">
  <div class="text-xs font-mono text-cyan-400 uppercase tracking-wider">
    Codebase Review &amp; Working Directory Audit
  </div>

  <div class="space-y-3 font-mono text-sm">
    <div v-click class="p-4 rounded-lg bg-[#0d0e12] border border-cyan-500/30 text-gray-200 leading-relaxed">
      Please review this program.
    </div>
    <div v-click class="p-4 rounded-lg bg-[#0d0e12] border border-gray-800 text-gray-200 leading-relaxed">
      I'm interested in which directory the <span class="text-cyan-300 font-semibold">Antigravity local harness</span> has as its <span class="text-amber-300 font-semibold">initial working directory</span>
    </div>
  </div>
</div>

<!--
Once the app was talking to localharness, I started Act 3 with a review prompt: Please review this program. I am interested in which directory the Antigravity local harness has as its initial working directory. Let us watch how agy investigates both our app code and the SDK source.
-->

---
layout: cast-full
title: "Act 3.1: Investigating Initial Working Directory"
cast: /casts/03a-act3-cwd-review.cast
autoPlay: false
speed: 2.0
idleTimeLimit: 2.0
fit: both
---

<!-- S14 -->
<!--
In Clip 3.1, agy traces our ChatRepository into package:antigravity's LocalConnectionStrategy and local_connection_config.dart. It discovers that passing workspaces: null defaults to Directory.current.absolute.path, and that Process.start spawns localharness without an explicit workingDirectory. When you run via flutter run in a terminal, Directory.current is your repository root. But when you launch a packaged macOS .app bundle from Finder or the Dock, launchd sets Directory.current to slash — the filesystem root!
-->

---
layout: default
---

<!-- S15 -->
<div class="flex items-center gap-3 mb-4">
  <h2 class="text-2xl font-bold m-0">What <code class="text-cyan-300">agy</code> Found: The macOS <code class="text-red-400">.app</code> Bundle Root (<code class="text-red-400">/</code>) Trap</h2>
</div>

<div class="grid grid-cols-2 gap-5 mt-3">
  <div class="p-4 rounded-xl bg-red-950/15 border border-red-500/30 space-y-2.5">
    <div class="text-xs font-mono text-red-400 uppercase">Anti-Pattern: Implicit Directory.current</div>
    <h3 class="text-base font-bold text-white">Why <code class="text-red-300">workspaces: null</code> Is Dangerous on Desktop</h3>
    <ul class="text-xs text-gray-300 space-y-1.5 list-disc pl-4 leading-relaxed">
      <li>Passing <code class="text-red-300">workspaces: null</code> to <code class="text-gray-200">LocalAgentConfig</code> defaults to <code class="text-red-300">Directory.current.absolute.path</code>.</li>
      <li>Under <code class="text-gray-200">flutter run</code>, <code class="text-gray-200">Directory.current</code> is your repo root (<code class="text-gray-200">./</code>).</li>
      <li>Launched from Finder or the macOS Dock (<code class="text-red-300">agy_genui_demo.app</code>), macOS <code class="text-gray-200">launchd</code> sets <code class="text-gray-200">Directory.current</code> to <strong><code class="text-red-300">/</code> (the filesystem root)!</strong></li>
    </ul>
  </div>

  <div class="p-4 rounded-xl bg-emerald-950/15 border border-emerald-500/30 space-y-2.5">
    <div class="text-xs font-mono text-emerald-400 uppercase">Target Architecture: Explicit Project Workspaces</div>
    <h3 class="text-base font-bold text-white">Explicit <code class="text-emerald-300">ChatProject</code> Working Directories</h3>
    <ul class="text-xs text-gray-300 space-y-1.5 list-disc pl-4 leading-relaxed">
      <li><code class="text-emerald-300">ChatRepository.resolveDefaultWorkingDirectory()</code> detects <code class="text-gray-200">/</code> and falls back safely to <code class="text-emerald-300">&#36;HOME</code> or <code class="text-emerald-300">Directory.systemTemp</code>.</li>
      <li>Every conversation belongs to a <code class="text-emerald-300">ChatProject</code> with an explicit, editable <code class="text-gray-200">workingDirectory</code> passed to <code class="text-gray-200">LocalAgentConfig(workspaces: [...])</code>.</li>
      <li>Changing a project's directory cleanly closes and recreates active sessions.</li>
    </ul>
  </div>
</div>

<div v-click class="mt-4 p-3.5 rounded-xl bg-amber-950/15 border border-amber-500/30 text-xs text-gray-200">
  <div class="font-mono text-amber-400 uppercase mb-1.5">Plus 2 Bonus Code-Review Catches from <code class="text-amber-300">agy</code>:</div>
  <div class="grid grid-cols-2 gap-4 text-gray-300">
    <div>
      <strong class="text-white">1. Stale <code class="text-amber-300">threadTitle</code> in System Instructions:</strong> <code class="text-gray-200">threadTitle</code> was baked into <code class="text-gray-200">CustomSystemInstructions</code> only when a session was first created.
    </div>
    <div>
      <strong class="text-white">2. Shared Composer Draft Leak:</strong> <code class="text-gray-200">MarkdownComposer</code> shared one <code class="text-gray-200">TextEditingController</code>, so unsent draft text leaked across threads on switch.
    </div>
  </div>
</div>

<!--
Let us unpack what agy found on a single slide. On the left is the trap: passing workspaces: null to LocalAgentConfig defaults to Directory.current. In a terminal that is fine, but when a user double-clicks a macOS .app bundle in Finder or the Dock, launchd sets Directory.current to the root of the hard drive! On the right is the architecture we actually want: explicit ChatProject workspaces with a safe fallback to the user's home directory. And as a bonus, agy also caught two subtle bugs in our existing code: thread titles were locked into system instructions at session creation time, and unsent composer drafts leaked across threads when switching conversations.
-->

---
layout: skill-breakdown
way: 2
title: "Prompt 3.2 — Add Projects & Sandbox Escape Review UI"
---

<!-- S16 -->
<div class="space-y-3 text-xs leading-relaxed my-auto">
  <div class="text-xs font-mono text-amber-400 uppercase tracking-wider">
    Project Workspaces, Sandboxing &amp; A Wrong Assumption!
  </div>

  <div class="space-y-2.5 font-mono text-sm text-gray-200">
    <div v-click class="p-3 rounded-lg bg-[#0d0e12] border border-gray-800">
      <span class="text-amber-400 font-bold">1.</span> Add a concept of <span class="text-cyan-300 font-semibold">projects</span> that set a working directory for the Antigravity harness.
    </div>
    <div v-click class="p-3 rounded-lg bg-red-950/25 border border-red-500/40 text-red-200">
      <span class="text-red-400 font-bold">2.</span> I'm guessing <code class="text-red-300 font-bold">workspaceOnly</code> enables commands that are inside the sandbox.
    </div>
    <div v-click class="p-3 rounded-lg bg-[#0d0e12] border border-amber-500/40 text-amber-200">
      <span class="text-amber-400 font-bold">&rarr;</span> We should add UI that allows programs to be run that want to <span class="text-amber-300 font-semibold">escape the sandbox</span>, but only after review by the user.
    </div>
    <div v-click class="p-3 rounded-lg bg-[#0d0e12] border border-gray-800">
      <span class="text-amber-400 font-bold">3.</span> Update <code class="text-emerald-300">README.md</code> and add <code class="text-emerald-300">/skills/</code> to <code class="text-emerald-300">.gitignore</code>.
    </div>
  </div>
</div>

<!--
Now look closely at item 2 in Prompt 3.2: I'm guessing workspaceOnly enables commands that are inside the sandbox. Spoiler alert: my assumption was completely wrong! And watching how agy checks my assumption instead of blindly agreeing with me is one of my favourite moments in the entire recording.
-->

---
layout: cast-full
title: "Act 3.2: Reverse-Engineering localharness Policies & Building the UI"
cast: /casts/03b-act3-projects-sandbox.cast
autoPlay: false
speed: 2.0
idleTimeLimit: 2.0
fit: both
---

<!-- S17 -->
<!--
Watch how agy investigates my claim about workspaceOnly. It reads policy.dart and capabilities.dart in the Dart SDK, and then it actually runs strings and Python byte-slice inspection on the compiled Go binary ~/.antigravity/bin/localharness! It gently proves me wrong: workspaceOnly only sets workspace_containment for file tools like view_file and write_to_file — it does not enable or sandbox run_command at all! Instead, CapabilitiesConfig with RunCommandConfig(enableSandbox: true) activates the OS-level exebox sandbox and exposes BypassSandbox on run_command. At marker 19, agy pauses with ask_question to ask how projects and threads should be organised in the UI, and we pick Option 1 so projects group conversation threads.
-->

---
layout: skill-breakdown
way: 3
title: "Prompt 3.3 — Fix Review Issues"
---

<!-- S18a -->
<div class="space-y-4 my-auto">
  <div class="text-xs font-mono text-emerald-400 uppercase tracking-wider">
    Closing the Loop on the Prompt 3.1 Code Review
  </div>

  <div v-click class="p-4 rounded-lg bg-[#0d0e12] border border-emerald-500/40 font-mono text-base text-emerald-200">
    Please fix issues highlighted in the review
  </div>

  <div v-click class="grid grid-cols-2 gap-4 text-xs pt-2">
    <div class="p-3.5 rounded-lg bg-gray-900/80 border border-gray-800 text-gray-300">
      <div class="text-emerald-300 font-semibold mb-1">1. Per-Thread Composer Drafts</div>
      Isolate unsent draft text per thread (<code class="text-gray-200">_threadDrafts</code> map in <a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/lib/ui/features/chat/view_models/chat_view_model.dart" target="_blank" class="text-cyan-400 underline">chat_view_model.dart</a>) so switching threads never leaks text.
    </div>
    <div class="p-3.5 rounded-lg bg-gray-900/80 border border-gray-800 text-gray-300">
      <div class="text-emerald-300 font-semibold mb-1">2. Session Metadata Refresh</div>
      Track <code class="text-gray-200">_SessionMetadata</code> (<code class="text-gray-200">threadTitle</code>, <code class="text-gray-200">projectId</code>, <code class="text-gray-200">workingDirectory</code>) in <a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/lib/data/repositories/chat_repository.dart" target="_blank" class="text-cyan-400 underline">chat_repository.dart</a> and recreate sessions on change.
    </div>
  </div>
</div>

<!--
While agy is finishing the projects and sandbox UI, we queue up Prompt 3.3: Please fix issues highlighted in the review. We don't even have to re-explain what the two issues were — we just refer back to the review from Prompt 3.1.
-->

---
layout: skill-breakdown
way: 3
title: "Prompt 3.4 — Tag step-03-projects-sandbox & Reset Context"
---

<!-- S18b -->
<div class="space-y-4 my-auto">
  <div class="text-xs font-mono text-emerald-400 uppercase tracking-wider">
    Commit Milestone &amp; Reset Session Context
  </div>

  <div class="space-y-3 font-mono text-sm">
    <div v-click class="p-3.5 rounded-lg bg-[#0d0e12] border border-gray-800 text-gray-200">
      <span class="text-emerald-400 font-semibold">Prompt: </span>git commit and tag as step-03-projects-sandbox
    </div>
    <div v-click class="p-3.5 rounded-lg bg-[#0d0e12] border border-amber-500/40 text-amber-300">
      <span class="text-gray-400 font-semibold">Slash command: </span>/clear
    </div>
  </div>

  <p class="text-xs text-gray-400 pt-2">
    Commits project workspaces, <code class="text-emerald-300">exebox</code> sandbox policies, and per-thread drafts at <code class="text-cyan-300">step-03-projects-sandbox</code> before clearing for Act 4.
  </p>
</div>

<!--
And then Prompt 3.4 commits and tags step-03-projects-sandbox, followed by /clear.
-->

---
layout: cast-full
title: "Act 3.3: Per-Thread Composer Drafts, Session Refresh & Tagging"
cast: /casts/03c-act3-review-fixes.cast
autoPlay: false
speed: 2.0
idleTimeLimit: 2.0
fit: both
---

<!-- S19 -->
<!--
Watch the very top of the terminal as Clip 3.3 starts: Conversation compacted! Remember how in Act 0 I promised I would use /clear to avoid automatic context compaction? Because we stacked Prompt 3.1 (full codebase review), Prompt 3.2 (binary reverse-engineering plus new UI), and Prompt 3.3 (review fixes) inside a single session, we blew past the context threshold anyway! Thankfully, even after automatic compaction, agy remembers the two review findings from Prompt 3.1, implements per-thread draft preservation and automatic session recreation on thread rename or workspace changes, runs all 10 widget tests to green, and tags step-03-projects-sandbox.
-->

---
layout: hardware-callout
title: "Live Demo — step-03-projects-sandbox"
image: /images/step-03-projects-sandbox.png
imageCaption: "Tag: step-03-projects-sandbox · Project Workspaces & exebox Sandbox"
---

<!-- S20 -->
<div class="space-y-3">
  <div class="flex items-center justify-between">
    <span class="text-xs font-mono uppercase tracking-wider text-emerald-400">Git Tag Milestone</span>
    <code class="text-xs font-mono px-2 py-0.5 rounded bg-emerald-950/60 border border-emerald-500/40 text-emerald-200">step-03-projects-sandbox</code>
  </div>

```bash
git clean -fd lib test && git checkout step-03-projects-sandbox -- lib test
# Press 'R' (Hot Restart) in flutter run!
```

  <div class="text-xs text-gray-300 space-y-1.5 pt-1">
    <div class="font-semibold text-white">What to Explore Live:</div>
    <ul class="list-disc pl-4 space-y-1 text-gray-300">
      <li>Project switcher &amp; New Project dialogue (<a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/lib/ui/features/chat/views/widgets/project_dialog.dart" target="_blank" class="text-cyan-400 underline">project_dialog.dart</a>) showing the active <code class="text-emerald-300">CWD</code> pill in sidebar &amp; toolbar.</li>
      <li>In-sandbox <code class="text-cyan-300">run_command</code> execution (<code class="text-amber-300">pwd</code> &amp; <code class="text-amber-300">What sort of project is this?</code>) inside <code class="text-emerald-300">exebox</code>.</li>
      <li>Amber <strong>Sandbox Escape Review</strong> banner (<a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/lib/ui/features/chat/views/widgets/sandbox_review_banner.dart" target="_blank" class="text-cyan-400 underline">sandbox_review_banner.dart</a>) with <strong>Deny</strong> / <strong>Approve &amp; Run</strong> backed by a <code class="text-gray-200">Completer&lt;bool&gt;</code>.</li>
    </ul>
  </div>
</div>

<!--
Let us hot-restart our live macOS app into step-03-projects-sandbox! Notice the project switcher at the top of the sidebar and the working directory pill in both the sidebar and top toolbar. We can ask localharness to run pwd inside the exebox sandbox, ask what sort of project sits in this workspace, verify that unsent composer drafts stay isolated per thread, and see how any command that tries to escape the sandbox triggers the amber human-in-the-loop review banner.
-->
