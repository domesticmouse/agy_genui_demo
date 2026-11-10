---
layout: center
class: text-center
---

<!-- S21 -->
<div class="space-y-4">
  <h1 class="text-4xl font-extrabold text-white">
    Act 4 &mdash; Generative UI with A2UI v1.0
  </h1>
  <p class="text-xl font-mono text-purple-300">
    a2ui_core &middot; a2ui_agent &middot; a2ui_flutter &middot; step-04-a2ui &middot;
    <a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/04-ba34877d-please-add-a2ui-core-a2ui-agent-and.md" target="_blank" class="underline hover:text-purple-200">Transcript 04</a>
  </p>
  <p class="text-base text-gray-400 max-w-xl mx-auto">
    Streaming live interactive A2UI v1.0 surfaces inline with Markdown, unpacking the three-package architecture, and wiring bidirectional RPCs.
  </p>
</div>

<!--
Welcome to Act 4! This is where we bring in the brand-new A2UI v1.0 packages — a2ui_core, a2ui_agent, and a2ui_flutter — that just replaced package:genui. We are going to stream live interactive UI surfaces inline with Markdown, ask agy to map out the exact seamlines between the three packages, and implement interactive parameter forms and bidirectional RPCs.
-->

---
layout: skill-breakdown
way: 1
title: "Prompt 4.1 — Add a2ui_core, a2ui_agent, and a2ui_flutter"
---

<!-- S22 -->
<div class="space-y-4 my-auto">
  <div class="text-xs font-mono text-cyan-400 uppercase tracking-wider">
    Inline Generative UI Surfaces (A2UI v1.0)
  </div>

  <div class="space-y-3 font-mono text-sm">
    <div v-click class="p-4 rounded-lg bg-[#0d0e12] border border-cyan-500/30 text-gray-200 leading-relaxed">
      Please add <span class="text-cyan-300 font-semibold">a2ui_core</span>, <span class="text-amber-300 font-semibold">a2ui_agent</span>, and <span class="text-emerald-300 font-semibold">a2ui_flutter</span> to this project
    </div>
    <div v-click class="p-4 rounded-lg bg-[#0d0e12] border border-gray-800 text-gray-200 leading-relaxed">
      and integrate <span class="text-purple-300 font-semibold">A2UI v1.0 surface rendering</span> into the chat UI so <code class="text-cyan-300">&lt;a2ui-json&gt;</code> blocks stream live interactive <code class="text-emerald-300">A2uiSurface</code> widgets inline alongside Markdown.
    </div>
  </div>
</div>

<!--
Here is Prompt 4.1. Remember, a2ui_core, a2ui_agent, and a2ui_flutter had just been published to replace package:genui. We ask agy to add all three dependencies and integrate A2UI v1.0 surface rendering so a2ui-json blocks stream live interactive A2uiSurface widgets right inside our chat bubbles alongside standard Markdown.
-->

---
layout: cast-full
title: "Act 4.1: Streaming a2ui-json Surfaces & Debugging 3 Subtle Bugs"
cast: /casts/04a-act4-a2ui-surfaces.cast
autoPlay: false
speed: 2.0
idleTimeLimit: 2.0
fit: both
---

<!-- S23 -->
<!--
Watch what happens in Clip 4.1. Because these three A2UI packages are brand new, agy inspects every single library export inside ~/.pub-cache/hosted/pub.dev/ across a2ui_core, a2ui_agent, and a2ui_flutter, wires up StreamedAnswer and A2uiSurface, and writes comprehensive widget tests. Exploring all three packages and diagnosing three subtle integration bugs takes over 90 tool calls in a single turn — triggering automatic Conversation compacted even inside a freshly cleared session!
-->

---
layout: default
---

<!-- S24 -->
<div class="flex items-center gap-3 mb-5">
  <h2 class="text-2xl font-bold m-0">3 Real-World A2UI v1.0 Bugs <code class="text-cyan-300">agy</code> Diagnosed During Testing</h2>
</div>

<ol class="space-y-4 text-sm text-gray-200 list-decimal pl-6 mt-4 leading-relaxed">
  <li v-click>
    <strong class="text-white">A2UI v1.0 <code class="text-amber-300">Text.variant</code> Schema Constraint</strong>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li><code class="text-cyan-300">BasicCatalog.v1_0</code> only allows <code class="text-emerald-300">'caption'</code> or <code class="text-emerald-300">'body'</code> (whereas v0.8 allowed <code class="text-red-300">'h5'</code>).</li>
      <li><code class="text-cyan-300">PayloadValidator</code> caught the invalid enum immediately when validating our starter showcase surface during <code class="text-cyan-300">flutter test</code>.</li>
    </ul>
  </li>
  <li v-click>
    <strong class="text-white">Inline Backtick <code class="text-amber-300">&lt;a2ui-json&gt;</code> Tag Collision</strong>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li><code class="text-cyan-300">DirectJsonParser</code> strips backticks around <code class="text-amber-300">`&lt;a2ui-json&gt;`</code> to forgive LLMs that wrap delimiter tags in inline code.</li>
      <li>Mentioning literal <code class="text-red-300">`&lt;a2ui-json&gt;`</code> in Markdown prose opened the JSON block prematurely until escaped or referred to as an <code class="text-emerald-300">a2ui-json</code> block.</li>
    </ul>
  </li>
  <li v-click>
    <strong class="text-white"><code class="text-amber-300">A2uiMarkdown</code> Inside <code class="text-amber-300">OutlinedButton</code> Intercepting Taps</strong>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li>Wrapping <code class="text-cyan-300">A2uiSurface</code> with <code class="text-cyan-300">A2uiMarkdown</code> defaulted button labels to <code class="text-red-300">selectable: true</code> and full-width, swallowing pointer taps in widget tests.</li>
      <li>Fixed by setting <code class="text-emerald-300">selectable: false, fitContent: true</code> in <a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/lib/ui/features/chat/views/widgets/message_bubble.dart" target="_blank" class="text-cyan-400 underline">message_bubble.dart</a>.</li>
    </ul>
  </li>
</ol>

<!--
None of these three bugs were obvious from reading a README. First, A2UI v1.0 tightened Text.variant to only allow caption or body instead of h5, which PayloadValidator caught right away. Second, DirectJsonParser forgivingly strips backticks around a2ui-json tags, so mentioning the tag in inline prose prematurely opened the JSON parser! Third, wrapping A2uiSurface with A2uiMarkdown made button text selectable by default, which intercepted pointer taps on OutlinedButton until agy set selectable: false and fitContent: true. All three were caught and fixed before we ever launched the app because agy wrote widget tests for the streaming surfaces and refused to move on until flutter test was completely green.
-->

---
layout: skill-breakdown
way: 2
title: "Prompt 4.2 — Research the A2UI Package Seamlines"
---

<!-- S25 -->
<div class="space-y-4 my-auto">
  <div class="text-xs font-mono text-amber-400 uppercase tracking-wider">
    Architectural Deep Dive &mdash; 3-Package Separation of Concerns
  </div>

  <div class="space-y-3 font-mono text-sm">
    <div v-click class="p-4 rounded-lg bg-[#0d0e12] border border-amber-500/30 text-gray-200 leading-relaxed">
      Please research the <span class="text-amber-300 font-semibold">seamlines</span> between <code class="text-cyan-300">a2ui_core</code>, <code class="text-amber-300">a2ui_agent</code> and <code class="text-emerald-300">a2ui_flutter</code>.
    </div>
    <div v-click class="p-4 rounded-lg bg-[#0d0e12] border border-gray-800 text-gray-200 leading-relaxed">
      Explain <span class="text-cyan-300 font-semibold">when to use each</span>.
    </div>
  </div>
</div>

<!--
Because a2ui_core, a2ui_agent, and a2ui_flutter had just replaced package:genui, I asked agy to be my research accomplice in Prompt 4.2 and map out the exact architectural seamlines between the three packages and explain when to use each.
-->

---
layout: cast-full
title: "Act 4.2: Researching A2UI Package Seamlines"
cast: /casts/04b-act4-a2ui-seamlines.cast
autoPlay: false
speed: 2.0
idleTimeLimit: 2.0
fit: both
---

<!-- S26 -->
<!--
In Clip 4.2, agy traces the pubspecs, type parameters, and class boundaries across all three packages and synthesises a crystal-clear architectural map. Because that terminal report scrolls by fast, let us take the next four slides to unpack what agy discovered.
-->

---
layout: default
---

<!-- S27 -->
<div class="flex items-center gap-3 mb-5">
  <h2 class="text-2xl font-bold m-0">Overview (1 of 4): How the 3 A2UI Packages Layer Together</h2>
</div>

<ol class="space-y-4 text-sm text-gray-200 list-decimal pl-6 mt-4 leading-relaxed">
  <li v-click>
    <strong class="text-cyan-300 font-mono">a2ui_core</strong> <span class="text-gray-400">(Pure Dart foundation)</span>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li>Zero dependency on Flutter or any LLM SDK.</li>
      <li>Defines protocol envelopes, catalogue schemas, JSON Pointer data models, and reactive <code class="text-gray-200">preact_signals</code>.</li>
    </ul>
  </li>
  <li v-click>
    <strong class="text-amber-300 font-mono">a2ui_agent</strong> <span class="text-gray-400">(Pure Dart agent bridge)</span>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li>Depends on <code class="text-cyan-300">a2ui_core</code> (and <code class="text-gray-200">antlr4</code>), <strong>never</strong> on <code class="text-gray-200">flutter</code>.</li>
      <li>Handles system prompt generation, streaming LLM token parsing, and incremental JSON healing.</li>
    </ul>
  </li>
  <li v-click>
    <strong class="text-emerald-300 font-mono">a2ui_flutter</strong> <span class="text-gray-400">(Flutter widget layer)</span>
    <ul class="list-disc pl-5 mt-1 space-y-1 text-gray-300">
      <li>Depends on <code class="text-cyan-300">a2ui_core</code> and <code class="text-gray-200">flutter</code>, <strong>never</strong> on <code class="text-amber-300">a2ui_agent</code>.</li>
      <li>Provides the concrete Material 3 widget catalogue and reactive <code class="text-emerald-300">A2uiSurface</code> widget.</li>
    </ul>
  </li>
</ol>

<!--
Here is the big-picture dependency graph. At the foundation sits a2ui_core, which is pure Dart with zero dependency on Flutter or any LLM SDK. Above it sit two sibling packages that never import each other: a2ui_agent is pure Dart for server or client LLM orchestration, and a2ui_flutter is the Flutter widget adapter that only knows about a2ui_core and package:flutter.
-->

---
layout: skill-breakdown
way: 1
title: "Seamlines 1 & 2 (2 of 4): Shared Catalogues & Stream Parsing"
---

<!-- S31 -->
<div class="space-y-4 text-sm leading-relaxed my-auto">
  <div class="grid grid-cols-2 gap-4">
    <div class="p-4 rounded-lg bg-gray-900/80 border border-gray-800 space-y-2">
      <div class="text-cyan-300 font-semibold font-mono">
        Seamline 1: Widget Catalogue &harr; Prompt Schema
      </div>
      <ul class="list-disc pl-5 space-y-1.5 text-gray-300">
        <li>One catalogue defines both the Flutter widgets and the JSON Schemas sent to the LLM.</li>
        <li>Strips away Flutter widget builders when generating prompts so <code class="text-amber-300">a2ui_agent</code> stays pure Dart.</li>
      </ul>
    </div>
    <div class="p-4 rounded-lg bg-gray-900/80 border border-gray-800 space-y-2">
      <div class="text-amber-300 font-semibold font-mono">
        Seamline 2: LLM Stream &harr; Surface State
      </div>
      <ul class="list-disc pl-5 space-y-1.5 text-gray-300">
        <li><code class="text-amber-300">a2ui_agent</code> parses streaming <code class="text-gray-200">&lt;a2ui-json&gt;</code> blocks into typed protocol messages.</li>
        <li><code class="text-cyan-300">a2ui_core</code> validates those messages and updates surface state &mdash; either in-process or across a network wire.</li>
      </ul>
    </div>
  </div>
</div>

<!--
Now look at Seamlines 1 and 2. Seamline 1 is how a single catalogue feeds both the LLM prompt generator and the Flutter widget tree: it strips the Flutter widget builders down to pure JSON Schemas so a2ui_agent never touches Flutter. Seamline 2 is the boundary between stream parsing and surface state: a2ui_agent turns raw LLM text chunks into typed protocol messages, and a2ui_core validates and applies them to the surface model — either in-process or across a network connection.
-->

---
layout: skill-breakdown
way: 2
title: "Seamlines 3 & 4 (3 of 4): Reactive Rendering & Two-Way Actions"
---

<!-- S32 -->
<div class="space-y-4 text-sm leading-relaxed my-auto">
  <div class="grid grid-cols-2 gap-4">
    <div class="p-4 rounded-lg bg-gray-900/80 border border-gray-800 space-y-2">
      <div class="text-emerald-300 font-semibold font-mono">
        Seamline 3: Surface State &harr; Flutter Widgets
      </div>
      <ul class="list-disc pl-5 space-y-1.5 text-gray-300">
        <li><code class="text-cyan-300">a2ui_core</code> holds the live reactive state for each UI surface.</li>
        <li><code class="text-emerald-300">A2uiSurface</code> mounts that state in Flutter and rebuilds only the widgets whose signals change.</li>
      </ul>
    </div>
    <div class="p-4 rounded-lg bg-gray-900/80 border border-gray-800 space-y-2">
      <div class="text-amber-300 font-semibold font-mono">
        Seamline 4: Local Edits vs. Agent Actions
      </div>
      <ul class="list-disc pl-5 space-y-1.5 text-gray-300">
        <li>Typing into text fields or dragging sliders updates the local surface data model with zero network round-trips.</li>
        <li>Clicking an action button packages the current form state and dispatches an action event back to the agent.</li>
      </ul>
    </div>
  </div>
</div>

<!--
Seamlines 3 and 4 show what happens once a surface is on screen. Seamline 3 passes the reactive surface state straight into the A2uiSurface widget, which granularly rebuilds only the widgets whose signals change. Seamline 4 separates local input edits from agent actions: typing into a text field or dragging a slider updates the data model locally with zero network round-trips, whereas clicking an action button packages the current state and sends an action event back to the agent.
-->

---
layout: default
---

<!-- S33 -->
<div class="flex items-center gap-3 mb-4">
  <h2 class="text-2xl font-bold m-0">When to Use Each Package (4 of 4): 4 Architecture Topologies</h2>
</div>

<ol class="space-y-3.5 text-xs text-gray-200 list-decimal pl-6 mt-3 leading-relaxed">
  <li v-click>
    <strong class="text-white text-sm">Full-Stack / Local Agent Flutter App</strong> &mdash; <code class="text-cyan-300">a2ui_core</code> + <code class="text-amber-300">a2ui_agent</code> + <code class="text-emerald-300">a2ui_flutter</code>
    <ul class="list-disc pl-5 mt-1 text-gray-300">
      <li>Prompts the LLM, parses streaming responses, and renders interactive surfaces all inside the Flutter app.</li>
    </ul>
  </li>
  <li v-click>
    <strong class="text-white text-sm">Thin Flutter Client + Remote Backend Agent</strong> &mdash; <code class="text-cyan-300">a2ui_core</code> + <code class="text-emerald-300">a2ui_flutter</code>
    <ul class="list-disc pl-5 mt-1 text-gray-300">
      <li>Backend handles the LLM; the Flutter client simply receives streamed protocol messages and renders widgets.</li>
    </ul>
  </li>
  <li v-click>
    <strong class="text-white text-sm">Dart Backend Agent Server or CLI</strong> &mdash; <code class="text-cyan-300">a2ui_core</code> + <code class="text-amber-300">a2ui_agent</code>
    <ul class="list-disc pl-5 mt-1 text-gray-300">
      <li>Pure Dart server (no Flutter dependency) generates prompts, heals streaming JSON, and streams validated UI messages to clients.</li>
    </ul>
  </li>
  <li v-click>
    <strong class="text-white text-sm">Custom Non-Flutter Renderer or Headless Tests</strong> &mdash; <code class="text-cyan-300">a2ui_core</code>
    <ul class="list-disc pl-5 mt-1 text-gray-300">
      <li>Build a custom UI renderer (web DOM, terminal UI) or test surface state headlessly without Flutter.</li>
    </ul>
  </li>
</ol>

<!--
That clean separation gives you four distinct architecture topologies. First, a full-stack or local-agent Flutter app like our demo uses all three packages together. Second, a thin Flutter client talking to a remote backend only needs a2ui_core and a2ui_flutter. Third, a pure Dart backend server or CLI pairs a2ui_core with a2ui_agent to prompt the LLM and stream validated UI messages without importing Flutter. Fourth, you can use a2ui_core on its own for headless testing or custom non-Flutter renderers.
-->

---
layout: skill-breakdown
way: 3
title: "Prompt 4.3 — Explore Capabilities for This Codebase"
---

<!-- S34 -->
<div class="space-y-4 my-auto">
  <div class="text-xs font-mono text-emerald-400 uppercase tracking-wider">
    Brainstorming Concrete A2UI Enhancements with agy
  </div>

  <div v-click class="p-4 rounded-lg bg-[#0d0e12] border border-emerald-500/40 font-mono text-base text-emerald-200">
    Give me some options for utilising this capability in the current codebase
  </div>

  <p class="text-xs text-gray-400 pt-2">
    With the three-package architecture loaded in context, we ask <code class="text-cyan-300">agy</code> to propose concrete ways to exploit A2UI v1.0 inside our desktop app.
  </p>
</div>

<!--
Now that both we and agy have the full three-package architecture loaded in context, we send Prompt 4.3: Give me some options for utilising this capability in the current codebase.
-->

---
layout: cast-full
title: "Act 4.3: Brainstorming 6 A2UI Enhancements"
cast: /casts/04c-act4-a2ui-options.cast
autoPlay: false
speed: 2.0
idleTimeLimit: 2.0
fit: both
---

<!-- S35 -->
<!--
In Clip 4.3, agy inspects what our codebase already wires up versus what A2UI v1.0 is capable of, and proposes six concrete options tailored to this application. Let us walk through all six suggestions across the next two slides.
-->

---
layout: default
---

<!-- S36 -->
<div class="flex items-center gap-3 mb-4">
  <h2 class="text-2xl font-bold m-0"><code class="text-cyan-300">agy</code>'s Suggestions (1 of 2): Action Loops, Developer Widgets &amp; Canvas</h2>
</div>

<ol class="space-y-3.5 text-xs text-gray-200 list-decimal pl-5 mt-3 leading-relaxed">
  <li v-click class="p-3 rounded-lg bg-cyan-950/15 border border-cyan-500/30">
    <strong class="text-cyan-300 text-sm">Option 1: Live Two-Way Action Loop</strong>
    <ul class="list-disc pl-5 mt-1 space-y-0.5 text-gray-300">
      <li>Clicking a button on an interactive <code class="text-cyan-300">A2uiSurface</code> dispatches the user's <code class="text-amber-300">ActionMessage</code> and current form state back to the agent.</li>
      <li>Renders a compact <span class="text-cyan-200 font-semibold">"Action Pill"</span> in the chat feed while the agent updates the existing surface in place.</li>
    </ul>
  </li>
  <li v-click class="p-3 rounded-lg bg-amber-950/15 border border-amber-500/30">
    <strong class="text-amber-300 text-sm">Option 2: Custom Workspace &amp; Developer Widgets</strong>
    <ul class="list-disc pl-5 mt-1 space-y-0.5 text-gray-300">
      <li><strong class="text-amber-200">Code Diff Card</strong>: Preview proposed file changes inline with <code class="text-emerald-300">Apply Patch</code> and <code class="text-red-300">Discard</code> actions.</li>
      <li><strong class="text-amber-200">Workspace File &amp; Command Cards</strong>: Clickable project file badges and proposed shell commands with editable flags.</li>
    </ul>
  </li>
  <li v-click class="p-3 rounded-lg bg-purple-950/15 border border-purple-500/30">
    <strong class="text-purple-300 text-sm">Option 3: Persistent Split-Pane "Surface Canvas"</strong>
    <ul class="list-disc pl-5 mt-1 space-y-0.5 text-gray-300">
      <li>Pin any active surface into a side-by-side <span class="text-purple-200 font-semibold">Canvas Drawer</span> where multi-turn prompts iteratively evolve a single UI.</li>
      <li>Includes a live <code class="text-cyan-300">DataModel</code> and component tree inspector to watch <code class="text-purple-300">preact_signals</code> bindings update in real time.</li>
    </ul>
  </li>
</ol>

<!--
Here are the first three options from agy. Option 1 closes the two-way action loop so clicking a button on an A2UI surface sends the ActionMessage and current form state back to the agent, letting the agent update the surface in place. Option 2 extends the widget catalogue with custom developer components like a Code Diff card, Workspace File card, or Command Runner card with editable flags. Option 3 adds a persistent split-pane Surface Canvas alongside inline chat bubbles, complete with a live data model inspector so you can watch state bindings update as you type.
-->

---
layout: default
---

<!-- S37 -->
<div class="flex items-center gap-3 mb-4">
  <h2 class="text-2xl font-bold m-0"><code class="text-cyan-300">agy</code>'s Suggestions (2 of 2): Self-Healing, Clarification Forms &amp; RPCs</h2>
</div>

<ol start="4" class="space-y-3.5 text-xs text-gray-200 list-decimal pl-5 mt-3 leading-relaxed">
  <li v-click class="p-3 rounded-lg bg-rose-950/15 border border-rose-500/30">
    <strong class="text-rose-300 text-sm">Option 4: Self-Healing Validation Loop</strong>
    <ul class="list-disc pl-5 mt-1 space-y-0.5 text-gray-300">
      <li>When the LLM emits malformed UI JSON or violates a component schema, <code class="text-rose-300">PayloadValidator</code> automatically rolls back the invalid block.</li>
      <li>Feeds the schema validation error straight back to the agent so it can repair its own surface automatically.</li>
    </ul>
  </li>
  <li v-click class="p-3 rounded-lg bg-emerald-950/20 border border-emerald-500/40">
    <div class="flex items-center justify-between">
      <strong class="text-emerald-300 text-sm">Option 5: Interactive Clarification &amp; Parameter Forms</strong>
      <span class="text-[10px] font-mono uppercase tracking-wider px-2 py-0.5 rounded bg-emerald-950/80 border border-emerald-500/40 text-emerald-300">Selected for Act 4.4</span>
    </div>
    <ul class="list-disc pl-5 mt-1 space-y-0.5 text-gray-300">
      <li>Instead of plain-text questions, the agent streams an interactive form (<code class="text-cyan-300">ChoicePicker</code> chips, validated <code class="text-cyan-300">TextField</code>s, <code class="text-cyan-300">Slider</code>s, and a submit button).</li>
      <li>Submitting the form packages the bound <code class="text-emerald-300">DataModel</code> and dispatches the structured answers back to the agent.</li>
    </ul>
  </li>
  <li v-click class="p-3 rounded-lg bg-amber-950/20 border border-amber-500/40">
    <div class="flex items-center justify-between">
      <strong class="text-amber-300 text-sm">Option 6: A2UI Express DSL &amp; Bidirectional RPCs</strong>
      <span class="text-[10px] font-mono uppercase tracking-wider px-2 py-0.5 rounded bg-amber-950/80 border border-amber-500/40 text-amber-300">Selected for Act 4.4</span>
    </div>
    <ul class="list-disc pl-5 mt-1 space-y-0.5 text-gray-300">
      <li>Switch between standard <code class="text-cyan-300">&lt;a2ui-json&gt;</code> and the compact, token-saving <code class="text-purple-300">&lt;a2ui-express&gt;</code> DSL.</li>
      <li>Register custom <code class="text-amber-300">FunctionImplementation</code> RPCs so the agent and Flutter UI can invoke functions across the boundary.</li>
    </ul>
  </li>
</ol>

<!--
And here are Options 4, 5, and 6! Option 4 wires up a self-healing validation loop: whenever an invalid UI block is rolled back by PayloadValidator, the app sends the validation error straight back to the agent so it can repair its own surface. Option 5 teaches the agent to stream interactive clarifying forms — with ChoicePicker chips, validated text fields, sliders, and a submit button — whenever a prompt has multiple valid interpretations. Option 6 introduces the compact A2UI Express DSL and custom FunctionImplementation RPCs so the agent can invoke client-side Dart functions and receive structured responses. We loved Options 5 and 6 so much that we asked agy to build both of them right on the spot.
-->

---
layout: skill-breakdown
way: mashup
title: "Prompt 4.4 — Clarifying Parameter Forms & Bidirectional RPCs"
---

<!-- S39a -->
<div class="space-y-3 text-sm leading-relaxed my-auto">
  <div class="p-3 rounded-lg bg-[#0d0e12] border border-purple-500/30 font-mono text-purple-200">
    Please implement:
  </div>

  <div class="space-y-2.5 font-mono text-gray-200 pl-2">
    <div v-click class="p-3.5 rounded-lg bg-gray-900/80 border border-cyan-500/30">
      <span class="text-cyan-400 font-bold">-</span> Interactive Clarifying Questions &amp; Parameter Forms (<span class="text-cyan-300 font-semibold">Basic Catalog</span>)
    </div>
    <div v-click class="p-3.5 rounded-lg bg-gray-900/80 border border-amber-500/30">
      <span class="text-amber-400 font-bold">-</span> Bidirectional Renderer RPC Functions (<code class="text-amber-300 font-semibold">FunctionImplementation</code>)
    </div>
  </div>
</div>

<!--
Prompt 4.4 is short and sweet: Please implement Interactive Clarifying Questions and Parameter Forms using the Basic Catalog, and Bidirectional Renderer RPC Functions using FunctionImplementation.
-->

---
layout: skill-breakdown
way: mashup
title: "Prompt 4.5 — Tag step-04-a2ui & Reset Context"
---

<!-- S39b -->
<div class="space-y-4 my-auto">
  <div class="text-xs font-mono text-purple-400 uppercase tracking-wider">
    Commit Milestone &amp; Reset Session Context
  </div>

  <div class="space-y-3 font-mono text-sm">
    <div v-click class="p-3.5 rounded-lg bg-[#0d0e12] border border-gray-800 text-gray-200">
      <span class="text-purple-400 font-semibold">Prompt: </span>git commit and tag as step-04-a2ui
    </div>
    <div v-click class="p-3.5 rounded-lg bg-[#0d0e12] border border-amber-500/40 text-amber-300">
      <span class="text-gray-400 font-semibold">Slash command: </span>/clear
    </div>
  </div>

  <p class="text-xs text-gray-400 pt-2">
    Tags the A2UI v1.0 surfaces, clarifying forms, and custom <code class="text-amber-300">FunctionImplementation</code> RPCs at <code class="text-purple-300">step-04-a2ui</code> before clearing for our final Act 5 codebase audit.
  </p>
</div>

<!--
Followed by Prompt 4.5 to commit and tag step-04-a2ui and run /clear before Act 5.
-->

---
layout: cast-full
title: "Act 4.4: Implementing Parameter Forms & Custom FunctionImplementations"
cast: /casts/04d-act4-forms-and-rpcs.cast
autoPlay: false
speed: 2.0
idleTimeLimit: 2.0
fit: both
---

<!-- S40 -->
<!--
In Clip 4.4, agy builds lib/data/catalog/renderer_rpc_functions.dart with four custom FunctionImplementations registered with AllowedCallers.rendererOrAgent: getWorkspaceInfo, listWorkspaceFiles, setSurfaceData, and formatParameterSummary. It also wires up outboundListener on the thread's MessageProcessor, adds starter threads showcasing both clarifying parameter forms and bidirectional RPCs, runs all 17 widget tests to green, and tags step-04-a2ui.
-->

---
layout: hardware-callout
title: "Live Demo — step-04-a2ui"
image: /images/step-04-a2ui.png
imageCaption: "Tag: step-04-a2ui · Inline A2UI v1.0 Surface & ChoicePicker"
---

<!-- S41 -->
<div class="space-y-2.5">
  <div class="flex items-center justify-between">
    <span class="text-xs font-mono uppercase tracking-wider text-purple-400">Git Tag Milestone</span>
    <code class="text-xs font-mono px-2 py-0.5 rounded bg-purple-950/60 border border-purple-500/40 text-purple-200">step-04-a2ui</code>
  </div>

```bash
git clean -fd lib test && git checkout step-04-a2ui -- lib test
# Press 'R' (Hot Restart) in flutter run!
```

  <div class="text-xs text-gray-300 space-y-1 pt-0.5">
    <div class="font-semibold text-white">What to Explore Live:</div>
    <ul class="list-disc pl-4 space-y-1 text-gray-300">
      <li>Send <code class="text-cyan-300">Please give me a multi-choice question</code> &rarr; streams an inline <code class="text-emerald-300">A2uiSurface</code> trivia card (<code class="text-gray-200">ChoicePicker</code> chips + validation-gated <code class="text-gray-200">Submit Answer</code> button).</li>
      <li>Custom RPCs in <a href="https://github.com/domesticmouse/agy_genui_demo/blob/main/lib/data/catalog/renderer_rpc_functions.dart" target="_blank" class="text-cyan-400 underline">renderer_rpc_functions.dart</a> (<code class="text-amber-300">getWorkspaceInfo</code>, <code class="text-amber-300">listWorkspaceFiles</code>).</li>
    </ul>
  </div>

  <div class="p-2.5 rounded-lg bg-amber-950/30 border border-amber-500/40 text-xs text-amber-200">
    <strong class="text-amber-300">Cliffhanger into Act 5:</strong> Click <code class="text-white">Submit Answer</code> right now at <code class="text-purple-300">step-04-a2ui</code> &mdash; it records the action pill locally, <em>but doesn't send a turn back to <code class="text-amber-300">localharness</code> yet!</em> Why? Let's ask a fresh session of <code class="text-cyan-300">agy</code> to audit the codebase in Act 5!
  </div>
</div>

<!--
Let us hot-restart into step-04-a2ui! We can ask the agent: Please give me a multi-choice question, and watch it stream a live interactive A2UI v1.0 Computer History Trivia surface with ChoicePicker chips and a validation-gated Submit Answer button. But here is our cliffhanger into Act 5: watch what happens when we select an answer and click Submit Answer right now at step-04-a2ui. It records the action pill locally in the UI, but it does not send a turn back to localharness yet! Why? Let us ask a fresh session of agy to review the entire codebase in Act 5 and find out!
-->
