---
layout: center
class: text-center
---

<!-- S08 -->
<div class="space-y-4">
  <h1 class="text-4xl font-extrabold text-white">
    Act 2 &mdash; Antigravity Dart SDK Backend
  </h1>
  <p class="text-xl font-mono text-amber-300">
    package:antigravity &middot; localharness &middot; step-02-antigravity-sdk &middot;
    <a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/02-8f4aafaf-please-add-the-antigravity-package-dependency-and.md" target="_blank" class="underline hover:text-amber-200">Transcript 02</a>
  </p>
  <p class="text-base text-gray-400 max-w-xl mx-auto">
    Replacing the simulated echo responder with live streaming responses from Google Antigravity's local harness.
  </p>
</div>

<!--
Now for Act 2! We have a lovely Markdown chat UI, but right now it is only echoing simulated replies. Let us wire up package:antigravity so our Flutter app spawns and streams live responses from the Antigravity local harness.
-->

---
layout: skill-breakdown
way: 2
title: "Prompt 2.1 — Wire Up package:antigravity"
---

<!-- S09a -->
<div class="space-y-4 my-auto">
  <div class="text-xs font-mono text-amber-400 uppercase tracking-wider">
    Live Agent Backend &amp; macOS Entitlements
  </div>

  <div class="space-y-3 font-mono text-sm">
    <div v-click class="p-4 rounded-lg bg-[#0d0e12] border border-amber-500/30 text-gray-200 leading-relaxed">
      Please add the <span class="text-amber-300 font-semibold">antigravity</span> package dependency and integrate it as the backend for the Markdown chat in this app.
    </div>
    <div v-click class="p-4 rounded-lg bg-[#0d0e12] border border-gray-800 text-gray-200 leading-relaxed">
      Update the <span class="text-cyan-300 font-semibold">macOS entitlements</span> so the app can spawn the local harness, and update <code class="text-emerald-300">README.md</code> and the <code class="text-emerald-300">widget tests</code>.
    </div>
  </div>
</div>

<!--
Prompt 2.1 is only two sentences long. First, we ask agy to add the antigravity package dependency and integrate it as the chat backend. Second, we remind it to update the macOS entitlements so our desktop app is allowed to spawn the localharness subprocess, and to keep README.md and our widget tests green.
-->

---
layout: skill-breakdown
way: 2
title: "Prompt 2.2 — Tag step-02-antigravity-sdk & Reset Context"
---

<!-- S09b -->
<div class="space-y-4 my-auto">
  <div class="text-xs font-mono text-amber-400 uppercase tracking-wider">
    Commit Milestone &amp; Reset Session Context
  </div>

  <div class="space-y-3 font-mono text-sm">
    <div v-click class="p-3.5 rounded-lg bg-[#0d0e12] border border-gray-800 text-gray-200">
      <span class="text-amber-400 font-semibold">Prompt: </span>git commit and tag as step-02-antigravity-sdk
    </div>
    <div v-click class="p-3.5 rounded-lg bg-[#0d0e12] border border-amber-500/40 text-amber-300">
      <span class="text-gray-400 font-semibold">Slash command: </span>/clear
    </div>
  </div>

  <p class="text-xs text-gray-400 pt-2">
    Locks in the working <code class="text-amber-300">package:antigravity</code> streaming integration at <code class="text-cyan-300">step-02-antigravity-sdk</code> and clears the session before Act 3.
  </p>
</div>

<!--
And just like in Act 1, once the integration is tested and green, Prompt 2.2 commits and tags step-02-antigravity-sdk, followed by /clear.
-->

---
layout: cast-full
title: "Act 2: Integrating package:antigravity & macOS Entitlements"
cast: /casts/02-act2-antigravity-sdk.cast
autoPlay: false
speed: 2.0
idleTimeLimit: 2.0
fit: both
---

<!-- S10 -->
<!--
Watch what happens in Clip 2 right after agy runs flutter pub add antigravity. Instead of hallucinating or guessing the SDK API, agy inspects the package source inside ~/.pub-cache/hosted/pub.dev/antigravity-0.18.1/lib/ directly! It sees that LocalConnectionStrategy spawns ~/.antigravity/bin/localharness as a subprocess and opens a local WebSocket plus outbound HTTPS, so it updates both DebugProfile.entitlements and Release.entitlements. Even better, while reading chat.dart in the SDK, agy realises that ChatResponse.chunks uses a five-millisecond Future.delayed polling loop and Agent.start spawns a real OS process — which would hang Flutter's FakeAsync widget test zone! So it designs an injectable AntigravityAgentSession interface in antigravity_chat_service.dart before running flutter test.
-->

---
layout: hardware-callout
title: "Live Demo — step-02-antigravity-sdk"
image: /images/step-02-antigravity-sdk.png
imageCaption: "Tag: step-02-antigravity-sdk · Live Antigravity SDK Streaming"
---

<!-- S11 -->
<div class="space-y-3">
  <div class="flex items-center justify-between">
    <span class="text-xs font-mono uppercase tracking-wider text-amber-400">Git Tag Milestone</span>
    <code class="text-xs font-mono px-2 py-0.5 rounded bg-amber-950/60 border border-amber-500/40 text-amber-200">step-02-antigravity-sdk</code>
  </div>

```bash
git clean -fd lib test && git checkout step-02-antigravity-sdk -- lib test
# Press 'R' (Hot Restart) in flutter run!
```

  <div class="text-xs text-gray-300 space-y-1.5 pt-1">
    <div class="font-semibold text-white">What to Explore Live:</div>
    <ul class="list-disc pl-4 space-y-1 text-gray-300">
      <li>Live streaming tokens from <code class="text-amber-300">~/.antigravity/bin/localharness</code> via <a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/lib/data/antigravity_chat_service.dart" target="_blank" class="text-cyan-400 underline">antigravity_chat_service.dart</a>.</li>
      <li>Updated macOS entitlements in <a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/macos/Runner/DebugProfile.entitlements" target="_blank" class="text-cyan-400 underline">DebugProfile.entitlements</a> (<code class="text-gray-300">app-sandbox: false</code>, <code class="text-gray-300">network.client</code> &amp; <code class="text-gray-300">network.server</code>).</li>
      <li>Try prompt: <code class="text-cyan-300">Compare StatelessWidget and StatefulWidget in a Markdown table with a short Dart code example.</code></li>
    </ul>
  </div>
</div>

<!--
Let us hot-restart into step-02-antigravity-sdk and send a real prompt to our live localharness backend! We can ask it to compare StatelessWidget and StatefulWidget in a Markdown table with a Dart code example, and watch the Markdown table and syntax-highlighted code stream in live.
-->
