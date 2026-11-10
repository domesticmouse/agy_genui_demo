---
layout: center
class: text-center
---

<!-- S42 -->
<div class="space-y-4">
  <h1 class="text-4xl font-extrabold text-white">
    Act 5 &mdash; Codebase Audit &amp; Hardening Fixups
  </h1>
  <p class="text-xl font-mono text-emerald-300">
    forwardSurfaceActionsToAgent &middot; RPC Batching &middot; step-05-fixup &middot;
    <a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/05-7407df5f-please-review-this-codebase.md" target="_blank" class="underline hover:text-emerald-200">Transcript 05</a>
  </p>
  <p class="text-base text-gray-400 max-w-xl mx-auto">
    Starting a fresh session to review our own code, diagnosing why live surface actions stopped at the local UI, and shipping the final end-to-end build.
  </p>
</div>

<!--
Welcome to Act 5, our final act! Remember that cliffhanger at the end of Act 4 where clicking Submit Answer recorded the action pill locally in Flutter, but didn't automatically send a turn back to localharness? Rather than digging through the code manually, let us clear the context window and ask a fresh session of agy to review the entire codebase from scratch.
-->

---
layout: skill-breakdown
way: 1
title: "Prompt 5.1 — Fresh-Session Codebase Audit"
---

<!-- S43 -->
<div class="space-y-4 my-auto">
  <div class="text-xs font-mono text-cyan-400 uppercase tracking-wider">
    Zero-Prior-Context Code Review (<a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/05-7407df5f-please-review-this-codebase.md" target="_blank" class="underline">Session 05</a>)
  </div>

  <div v-click class="p-4 rounded-lg bg-[#0d0e12] border border-cyan-500/40 font-mono text-base text-cyan-200">
    please review this codebase
  </div>

  <div v-click class="grid grid-cols-2 gap-4 text-xs pt-2">
    <div class="p-3.5 rounded-lg bg-gray-900/80 border border-gray-800 text-gray-300">
      <div class="text-cyan-300 font-semibold mb-1">Why `/clear` Before Auditing?</div>
      An agent that just wrote 1,500 lines of code carries assumptions about what it <em>meant</em> to wire up. A fresh session reads only what is actually on disk.
    </div>
    <div class="p-3.5 rounded-lg bg-gray-900/80 border border-gray-800 text-gray-300">
      <div class="text-amber-300 font-semibold mb-1">Four Words, High Leverage</div>
      No leading hints required &mdash; <code class="text-gray-200">agy</code> inspects <code class="text-gray-200">lib/</code>, <code class="text-gray-200">test/</code>, runs <code class="text-gray-200">dart analyze</code> and <code class="text-gray-200">flutter test</code>, and cross-checks every entrypoint.
    </div>
  </div>
</div>

<!--
Before declaring victory on any vibe-coded milestone, clear the context window and run a four-word prompt in a brand-new session: please review this codebase. If you take one practical habit away from this talk, make it this one! Because the new session has zero memory of our earlier compromises, it reads only what is actually on disk.
-->

---
layout: cast-full
title: "Act 5.1: Auditing the Full Codebase in a Fresh Session"
cast: /casts/05a-act5-codebase-audit.cast
autoPlay: false
speed: 2.0
idleTimeLimit: 2.0
fit: both
---

<!-- S44 -->
<!--
Watch Clip 5.1 as agy systematically reads main.dart, chat_view_model.dart, chat_repository.dart, renderer_rpc_functions.dart, and our widget tests. Within seconds, it spots five concrete bugs across the application — starting with the exact reason our Submit Answer button didn't talk back to localharness at the end of Act 4!
-->

---
layout: default
---

<!-- S45 -->
<div class="flex items-center gap-3 mb-3">
  <h2 class="text-2xl font-bold m-0">5 Real Bugs Surfaced by the Fresh-Context Audit</h2>
</div>

<ol class="space-y-2.5 text-xs text-gray-200 list-decimal pl-5 mt-2 leading-relaxed">
  <li v-click class="p-2.5 rounded-lg bg-red-950/20 border border-red-500/30">
    <strong class="text-red-300"><code class="text-red-200">forwardSurfaceActionsToAgent</code> &amp; <code class="text-red-200">forwardRpcMessagesToAgent</code> Defaulted to <code class="text-red-200">false</code> in <a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/lib/main.dart" target="_blank" class="text-cyan-400 underline">lib/main.dart</a>:</strong>
    To keep earlier widget tests deterministic without spawning <code class="text-gray-200">localharness</code>, Act 4 had left both flags defaulting to <code class="text-red-300">false</code> in <code class="text-gray-200">ChatViewModel</code> &mdash; so clicking a button in the live desktop app recorded the action pill locally without ever forwarding it to the agent!
  </li>
  <li v-click class="p-2.5 rounded-lg bg-amber-950/15 border border-amber-500/30">
    <strong class="text-amber-300">Stream Self-Cancellation on Multi-RPC Turns (<a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/lib/ui/features/chat/view_models/chat_view_model.dart" target="_blank" class="text-cyan-400 underline">chat_view_model.dart</a>):</strong>
    Calling <code class="text-gray-200">sendRpcMessageToAgent</code> synchronously inside <code class="text-gray-200">outboundListener</code> mid-stream incremented <code class="text-gray-200">_requestGeneration</code> and cancelled the active LLM stream whenever multiple <code class="text-gray-200">callRendererFunction</code> calls arrived in one block.
  </li>
  <li v-click class="p-2.5 rounded-lg bg-gray-900/80 border border-gray-800">
    <strong class="text-white">Auto-Titling Overwrote Custom Thread Titles on First Message:</strong>
    Checking only <code class="text-gray-200">thread.messages.isEmpty</code> overwrote user-renamed threads when their first message was sent.
  </li>
  <li v-click class="p-2.5 rounded-lg bg-gray-900/80 border border-gray-800">
    <strong class="text-white">Sandbox-Escape Path Heuristics Edge Cases (<a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/lib/data/repositories/chat_repository.dart" target="_blank" class="text-cyan-400 underline">chat_repository.dart</a>):</strong>
    Missed <code class="text-gray-200">--flag=/outside/path</code>, <code class="text-gray-200">&#36;HOME</code> expansion, and trailing <code class="text-gray-200">/..</code>, while false-positiving on <code class="text-gray-200">awk '/pattern/'</code>.
  </li>
  <li v-click class="p-2.5 rounded-lg bg-gray-900/80 border border-gray-800">
    <strong class="text-white">Unbounded Synchronous <code class="text-emerald-300">listSync()</code> in <code class="text-emerald-300">ListWorkspaceFilesFunction</code> (<a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/lib/data/catalog/renderer_rpc_functions.dart" target="_blank" class="text-cyan-400 underline">renderer_rpc_functions.dart</a>):</strong>
    Full recursive directory enumeration before slicing could block the Flutter UI isolate on large parent directories.
  </li>
</ol>

<!--
Let us walk through the five findings one by one. First — and funniest — to keep earlier widget tests deterministic without spawning a live localharness process, Act 4 had set forwardSurfaceActionsToAgent and forwardRpcMessagesToAgent to false by default on ChatViewModel, and forgot to pass true in lib/main.dart! That is why our button click at the end of Act 4 stayed local! Second, if the model emitted two callRendererFunction envelopes in the same response stream, forwarding the first RPC response immediately inside outboundListener incremented _requestGeneration and cancelled the active stream before the second RPC even finished. Third, auto-titling checked only whether messages were empty, overwriting custom thread titles. Fourth, our sandbox path regex missed equals-sign flags like --output=/tmp/foo and dollar-HOME while false-positiving on awk slash patterns. And fifth, ListWorkspaceFilesFunction used an unbounded synchronous listSync before taking the top entries.
-->

---
layout: skill-breakdown
way: 3
title: "Prompt 5.2 — Fix All 5 Surfaced Issues"
---

<!-- S46a -->
<div class="space-y-4 my-auto">
  <div class="text-xs font-mono text-emerald-400 uppercase tracking-wider">
    Remediation &amp; Regression Tests
  </div>

  <div v-click class="p-4 rounded-lg bg-[#0d0e12] border border-emerald-500/40 font-mono text-base text-emerald-200">
    please fix issues
  </div>

  <div v-click class="grid grid-cols-2 gap-4 text-xs pt-2">
    <div class="p-3.5 rounded-lg bg-gray-900/80 border border-gray-800 text-gray-300">
      <div class="text-emerald-300 font-semibold mb-1">Live Forwarding Enabled in <code class="text-gray-200">main.dart</code></div>
      Sets <code class="text-emerald-300">forwardSurfaceActionsToAgent: true</code> and <code class="text-emerald-300">forwardRpcMessagesToAgent: true</code> in the production entrypoint while keeping unit tests fast and isolated.
    </div>
    <div class="p-3.5 rounded-lg bg-gray-900/80 border border-gray-800 text-gray-300">
      <div class="text-cyan-300 font-semibold mb-1">Batched Post-Stream RPC Flush</div>
      Queues outbound <code class="text-gray-200">RendererFunctionResponseMessage</code> envelopes in <code class="text-gray-200">_pendingRpcMessagesByThread</code> and flushes them as a single combined turn once the active stream completes.
    </div>
  </div>
</div>

<!--
Our follow-up prompt is three words: please fix issues. Notice how conversational this workflow is once the review report is sitting in the session context.
-->

---
layout: skill-breakdown
way: 3
title: "Prompt 5.3 — Tag step-05-fixup"
---

<!-- S46b -->
<div class="space-y-4 my-auto">
  <div class="text-xs font-mono text-emerald-400 uppercase tracking-wider">
    Final Milestone Tag
  </div>

  <div v-click class="p-4 rounded-lg bg-[#0d0e12] border border-emerald-500/40 font-mono text-base text-emerald-200">
    git commit and tag as step-05-fixup
  </div>

  <p v-click class="text-xs text-gray-400 pt-2">
    Brings the widget test suite to <strong class="text-white">21 passing tests</strong>, zero <code class="text-emerald-300">dart analyze</code> warnings, and tags the completed application as <code class="text-cyan-300">step-05-fixup</code>.
  </p>
</div>

<!--
And then Prompt 5.3 commits all five fixes and tags our final milestone: step-05-fixup.
-->

---
layout: cast-full
title: "Act 5.2: Fixing All 5 Issues, Running 21 Widget Tests & Tagging step-05-fixup"
cast: /casts/05b-act5-fixups-and-tag.cast
autoPlay: false
speed: 2.0
idleTimeLimit: 2.0
fit: both
---

<!-- S47 -->
<!--
In Clip 5.2, agy enables both forwarding flags in lib/main.dart, batches pending RPC responses in ChatViewModel until the active stream finishes, preserves custom thread titles, hardens the sandbox path parser in ChatRepository, caps directory traversal in ListWorkspaceFilesFunction, adds 4 new regression tests to reach 21 passing widget tests, and tags step-05-fixup.
-->

---
layout: hardware-callout
title: "Live Finale Demo — step-05-fixup"
image: /images/step-05-fixup.png
imageCaption: "Tag: step-05-fixup · Full Bidirectional A2UI v1.0 RPC & Action Round-Trip"
---

<!-- S48 -->
<div class="space-y-2.5">
  <div class="flex items-center justify-between">
    <span class="text-xs font-mono uppercase tracking-wider text-emerald-400">Git Tag Milestone</span>
    <code class="text-xs font-mono px-2 py-0.5 rounded bg-emerald-950/60 border border-emerald-500/40 text-emerald-200">step-05-fixup</code>
  </div>

```bash
git clean -fd lib test && git checkout step-05-fixup -- lib test
# Press 'R' (Hot Restart) in flutter run!
```

  <div class="text-xs text-gray-300 space-y-1.5 pt-0.5">
    <div class="font-semibold text-white">
      What to Show Live (<a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/06-7e5e8534-please-ask-a-multiple-choice-question.md" target="_blank" class="text-cyan-400 underline">Session 06 Transcript</a>):
    </div>
    <ol class="list-decimal pl-4 space-y-1.5 text-gray-300">
      <li>
        <strong class="text-emerald-300">Bidirectional RPC Round-Trip (<code class="text-white">Invoke getWorkspaceInfo</code>):</strong>
        <code class="text-gray-200">localharness</code> emits <code class="text-amber-300">callRendererFunction: getWorkspaceInfo</code> &rarr; Flutter executes <a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/lib/data/catalog/renderer_rpc_functions.dart" target="_blank" class="text-cyan-400 underline">GetWorkspaceInfoFunction</a> &rarr; <code class="text-gray-200">ChatViewModel</code> automatically flushes <code class="text-emerald-300">RendererFunctionResponseMessage</code> back to <code class="text-gray-200">localharness</code> &rarr; second assistant bubble renders the live <code class="text-white">WorkspaceInfoSnapshot</code>!
      </li>
      <li>
        <strong class="text-cyan-300">Interactive Trivia Surface (<code class="text-white">Please ask a multiple choice question</code>):</strong>
        Pick <strong class="text-white">Java</strong> and click <strong class="text-white">Submit Answer</strong> &rarr; automatic <code class="text-emerald-300">ActionMessage</code> + <code class="text-emerald-300">a2uiRendererDataModel</code> round-trip back to <code class="text-gray-200">localharness</code>!
      </li>
    </ol>
  </div>
</div>

<!--
Let us do our final hot-restart into step-05-fixup! Look at the screenshot on the left — and let us run both flows live. First, when we send Invoke getWorkspaceInfo, localharness emits a callRendererFunction envelope inside a2ui-json, Flutter executes GetWorkspaceInfoFunction against our live desktop state, ChatViewModel automatically flushes the RendererFunctionResponseMessage back to localharness once the stream completes, and the second assistant bubble renders our live project name, working directory, active thread title, and light theme mode! Second, when we ask for a multiple-choice question, pick an answer on the A2UI ChoicePicker card, and click Submit Answer, the ActionMessage and surface data model automatically round-trip back to localharness and the agent grades our answer right in the chat!
-->

---
layout: default
---

<!-- S49 -->
<div class="flex items-center justify-between mb-3">
  <h2 class="text-2xl font-bold m-0">Takeaways, Resources &amp; Thank You!</h2>
  <span class="text-xs font-mono text-gray-400">Brett Morgan &middot; Google Cloud Developer Relations</span>
</div>

<div class="grid grid-cols-12 gap-5 items-center">
  <div class="col-span-8 space-y-2.5 text-xs">
    <div class="p-3 rounded-xl bg-gray-900/90 border border-gray-800 space-y-1.5">
      <div class="text-[11px] font-mono text-emerald-400 uppercase tracking-wider">4 Takeaways from the Journey</div>
      <ul class="space-y-1 text-gray-300 list-disc pl-4 leading-snug">
        <li><strong class="text-white">Treat AI as a curious accomplice, not an infallible oracle:</strong> Share the false starts (<code class="text-gray-200">workspaceOnly</code> vs <code class="text-gray-200">enableSandbox</code>, <code class="text-gray-200">Directory.current</code> in Finder, <code class="text-gray-200">forwardSurfaceActionsToAgent: false</code>) &mdash; and audit with a fresh <code class="text-amber-300">/clear</code> session.</li>
        <li><strong class="text-white">Manage context bloat deliberately:</strong> <code class="text-amber-300">/clear</code> at milestone boundaries keeps context sharp, though stacking multi-step turns in Acts 3 &amp; 4 still triggered automatic <code class="text-amber-300">Conversation compacted</code> mid-flight.</li>
        <li><strong class="text-white">Engineering hygiene is a sanity-saver:</strong> <code class="text-emerald-300">dart analyze</code>, <code class="text-emerald-300">flutter_lints</code>, and widget tests caught the subtle A2UI v1.0 wire contracts early.</li>
        <li><strong class="text-white">Git tags + Hot Restart = Live-Demo Time Travel:</strong> <code class="text-cyan-300">git checkout &lt;tag&gt; -- lib test</code> jumps between any of the 5 acts in under a second.</li>
      </ul>
    </div>
    <div class="p-3 rounded-xl bg-gray-900/90 border border-gray-800 space-y-1.5">
      <div class="text-[11px] font-mono text-cyan-400 uppercase tracking-wider">Repository, Codelab, Cast Player &amp; Packages</div>
      <div class="grid grid-cols-2 gap-x-4 gap-y-1 text-gray-300 leading-snug">
        <div>
          <strong class="text-white">Live Deck:</strong>
          <a href="https://domesticmouse.github.io/agy_genui_demo/" target="_blank" class="text-cyan-300 underline font-mono">domesticmouse.github.io/agy_genui_demo</a>
        </div>
        <div>
          <strong class="text-white">Cast Player:</strong>
          <a href="https://domesticmouse.github.io/agy_genui_demo/agy-genui-codelab-cast-player.html" target="_blank" class="text-cyan-300 underline font-mono">agy-genui-codelab-cast-player.html</a>
        </div>
        <div class="col-span-2">
          <strong class="text-white">GitHub &amp; Guides:</strong>
          <a href="https://github.com/domesticmouse/agy_genui_demo" target="_blank" class="text-cyan-300 underline font-mono">github.com/domesticmouse/agy_genui_demo</a> &middot;
          <a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/CODELAB.md" target="_blank" class="text-emerald-300 underline font-mono">CODELAB.md</a> &middot;
          <a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/PRESENTATION.md" target="_blank" class="text-emerald-300 underline font-mono">PRESENTATION.md</a>
        </div>
        <div class="col-span-2">
          <strong class="text-white">Session Transcripts:</strong>
          <a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/README.md" target="_blank" class="text-amber-300 underline font-mono">prompts/README.md</a>
          (<a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/01-6ee8f6c2-please-build-a-macos-desktop-markdown-chat.md" target="_blank" class="text-cyan-300 underline font-mono">01</a> &middot;
          <a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/02-8f4aafaf-please-add-the-antigravity-package-dependency-and.md" target="_blank" class="text-cyan-300 underline font-mono">02</a> &middot;
          <a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/03-10ad2b6c-please-review-this-program-i-m-interested.md" target="_blank" class="text-cyan-300 underline font-mono">03</a> &middot;
          <a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/04-ba34877d-please-add-a2ui-core-a2ui-agent-and.md" target="_blank" class="text-cyan-300 underline font-mono">04</a> &middot;
          <a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/05-7407df5f-please-review-this-codebase.md" target="_blank" class="text-cyan-300 underline font-mono">05</a> &middot;
          <a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/06-7e5e8534-please-ask-a-multiple-choice-question.md" target="_blank" class="text-cyan-300 underline font-mono">06</a> &middot;
          <a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/07-fd1fed76-please-extract-agy-brain-transcripts-for-this.md" target="_blank" class="text-cyan-300 underline font-mono">07</a>)
        </div>
        <div class="col-span-2">
          <strong class="text-white">pub.dev:</strong>
          <a href="https://pub.dev/packages/antigravity" target="_blank" class="text-purple-300 underline font-mono">antigravity</a> &middot;
          <a href="https://pub.dev/packages/a2ui_core" target="_blank" class="text-purple-300 underline font-mono">a2ui_core</a> &middot;
          <a href="https://pub.dev/packages/a2ui_agent" target="_blank" class="text-purple-300 underline font-mono">a2ui_agent</a> &middot;
          <a href="https://pub.dev/packages/a2ui_flutter" target="_blank" class="text-purple-300 underline font-mono">a2ui_flutter</a> &middot;
          <a href="https://pub.dev/packages/flutter_markdown_plus" target="_blank" class="text-purple-300 underline font-mono">flutter_markdown_plus</a>
        </div>
      </div>
    </div>
  </div>
  <div class="col-span-4 flex flex-col items-center justify-center p-4 rounded-xl bg-[#0d0e12] border border-cyan-500/40 text-center space-y-2.5 shadow-lg">
    <div class="text-xs font-mono text-cyan-300 uppercase tracking-wider font-semibold">
      Scan for Live Deck &amp; Links
    </div>
    <div class="p-2.5 bg-white rounded-xl shadow-inner">
      <img src="/images/deck-qr.svg" alt="QR Code for https://domesticmouse.github.io/agy_genui_demo/" class="w-44 h-44 object-contain" />
    </div>
    <a href="https://domesticmouse.github.io/agy_genui_demo/" target="_blank" class="text-[11px] font-mono text-cyan-300 underline break-all">
      domesticmouse.github.io/agy_genui_demo/
    </a>
  </div>
</div>

<!--
To wrap up: treat AI as a curious accomplice rather than an infallible oracle, manage your context deliberately with /clear at milestone boundaries, lean hard on static analysis and widget tests to catch subtle wire-protocol contracts early, and use git tags plus Flutter Hot Restart for stress-free live-demo time travel. Scan the QR code on the right to open this exact Slidev deck on your phone — every session transcript, the full codelab, the standalone interactive terminal recording, and all five pub.dev packages are one tap away. Thank you all so much, and let us open it up for questions!
-->
