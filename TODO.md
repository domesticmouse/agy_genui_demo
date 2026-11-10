# Slide Deck & Repository TODO

Each task below is scoped to be completed in a **single fresh `agy` session** (followed by `/clear`) to prevent context bloat and automatic compaction.

Before starting any slide-authoring task, read:
- [`PRESENTATION.md`](PRESENTATION.md) (authoritative slide-by-slide outline, voice guidelines, and zero-LaTeX-leak rules)
- [`.agents/skills/slidev-deck/SKILL.md`](.agents/skills/slidev-deck/SKILL.md) and [`.agents/skills/slidev-deck/references/SLIDE-PATTERNS.md`](.agents/skills/slidev-deck/references/SLIDE-PATTERNS.md)

---

## Task 1: Split & Stage the 12 `.cast` Clips into `recordings/final/`

- [x] Create `recordings/final/`.
- [x] Split [`agy-genui-codelab.cast`](agy-genui-codelab.cast) into the 11 per-scene `.cast` files defined in the **Cast Clips Breakdown** table in [`PRESENTATION.md`](PRESENTATION.md#L83-L100):
  1. `01-act1-markdown-chat.cast` (`[1]–[8]`, `#0..#6585`)
  2. `02-act2-antigravity-sdk.cast` (`[8]–[14]`, `#6585..#13183`)
  3. `03a-act3-cwd-review.cast` (`[14]–[16]`, `#13183..#15294`)
  4. `03b-act3-projects-sandbox.cast` (`[16]–[21]`, `#15294..#26607`)
  5. `03c-act3-review-fixes.cast` (`[21]–[26]`, `#26607..#31705`)
  6. `04a-act4-a2ui-surfaces.cast` (`[26]–[28]`, `#31705..#60807`)
  7. `04b-act4-a2ui-seamlines.cast` (`[28]–[30]`, `#60807..#64157`)
  8. `04c-act4-a2ui-options.cast` (`[30]–[32]`, `#64157..#65171`)
  9. `04d-act4-forms-and-rpcs.cast` (`[32]–[38]`, `#65171..#80902`)
  10. `05a-act5-codebase-audit.cast` (`[38]–[40]`, `#80902..#83628`)
  11. `05b-act5-fixups-and-tag.cast` (`[40]–[44]`, `#83628..#87984`)
  - Ensure each split clip preserves a clean initial terminal state and retains its internal `"m"` chapter markers so `AsciinemaPlayer.vue` can step between stop points (`[` / `]`) and compute adaptive segment speeds.
- [x] Copy [`plugins.cast`](plugins.cast) to `recordings/final/01b-act1-plugins.cast`.
- [x] **Completion Criterion**: All 12 `.cast` files exist in `recordings/final/` and pass `python3 .agents/skills/asciinema/scripts/mark-cast.py <file> --list`.

---

## Task 2: Scaffold `slides/`, Stage Assets, Generate Deck QR Code & Configure GitHub Pages CI

- [ ] Scaffold `slides/` from [`.agents/skills/slidev-deck/resources/`](.agents/skills/slidev-deck/resources/):
  - Copy `package.json`, `vite.config.ts`, `style.css`, `components/AsciinemaPlayer.vue`, and `layouts/*.vue` into `slides/`.
  - Set `"build": "slidev build --base /agy_genui_demo/"` in `slides/package.json`.
  - Configure `slides/slides.md` with dark-theme headmatter (`hide: true`) and `src:` entries for:
    - `./acts/01-primer.md`
    - `./acts/02-act1-markdown-chat.md`
    - `./acts/03-act2-antigravity-sdk.md`
    - `./acts/04-act3-projects-sandbox.md`
    - `./acts/05-act4-a2ui.md`
    - `./acts/06-act5-fixup.md`
  - Create placeholder `.md` files for any acts not yet authored so `slidev build` succeeds.
- [ ] Stage static assets into `slides/public/`:
  - Copy `screenshots/step-0*.png` into `slides/public/images/`.
  - Generate a crisp SVG QR code at `slides/public/images/deck-qr.svg` encoding **`https://domesticmouse.github.io/agy_genui_demo/`** for the final slide (`S49`).
  - Copy [`agy-genui-codelab-cast-player.html`](agy-genui-codelab-cast-player.html) into `slides/public/agy-genui-codelab-cast-player.html` so it is served alongside the deck on GitHub Pages.
  - Run `npm --prefix slides run sync-casts` to copy `recordings/final/*.cast` into `slides/public/casts/`.
- [ ] Add GitHub Pages workflow at `.github/workflows/deploy-slides.yml` (based on [`.agents/skills/slidev-deck/resources/deploy-slides.yml`](.agents/skills/slidev-deck/resources/deploy-slides.yml)) triggered on pushes to `main` touching `slides/**`, `recordings/final/**`, or `screenshots/**`.
- [ ] Update [`.gitignore`](.gitignore) with `slides/node_modules/`, `slides/dist/`, `slides/.slidev.pid`, and `slides/.slidev.log`.
- [ ] Install dependencies (`npm --prefix slides install`) and verify `npm --prefix slides run build` exits with code `0`.

---

## Task 3: Author Act 0, Act 1 & Act 2 Slides (`01-primer.md`, `02-act1-markdown-chat.md`, `03-act2-antigravity-sdk.md`)

- [ ] Author `slides/acts/01-primer.md` (`S01`, `S01a`, `S02`, `S03`) per [`PRESENTATION.md`](PRESENTATION.md#L103-L140):
  - Include the Mermaid milestone & context compaction flowchart on `S03` and full GitHub URLs (`https://github.com/domesticmouse/agy_genui_demo/blob/main/prompts/...`) for the session transcripts.
- [ ] Author `slides/acts/02-act1-markdown-chat.md` (`S04`, `S05a`, `S05b`, `S05c`, `S06`, `S06a`, `S06b`, `S07`) per [`PRESENTATION.md`](PRESENTATION.md#L142-L196):
  - Separate slides for scaffold commands (`S05a`), Prompt 1.1 (`S05b`), Prompt 1.2 (`S05c`), and `/plugin` (`S06a`), with line-by-line `v-click` animations.
  - Embed `/casts/01-act1-markdown-chat.cast` (`S06`) and `/casts/01b-act1-plugins.cast` (`S06b`).
  - Configure `S07` (`layout: hardware-callout`, `image: /images/step-01-markdown-chat.png`) with the `step-01-markdown-chat` hot-restart command.
- [ ] Author `slides/acts/03-act2-antigravity-sdk.md` (`S08`, `S09a`, `S09b`, `S10`, `S11`) per [`PRESENTATION.md`](PRESENTATION.md#L198-L226):
  - Separate `v-click` prompt slides (`S09a`, `S09b`), `/casts/02-act2-antigravity-sdk.cast` (`S10`), and `S11` (`layout: hardware-callout`, `image: /images/step-02-antigravity-sdk.png`).
- [ ] **Completion Criterion**: Every slide has `<!-- Sxx -->` ID comments, Australian English spelling, conversational speaker notes (`<!-- ... -->`), HTML/Unicode arrows (`&rarr;` / `→`) instead of raw LaTeX inside HTML blocks, and `npm --prefix slides run build` succeeds.

---

## Task 4: Author Act 3 Slides (`04-act3-projects-sandbox.md`)

- [ ] Author `slides/acts/04-act3-projects-sandbox.md` (`S12`, `S13`, `S14`, `S15`, `S16`, `S17`, `S18a`, `S18b`, `S19`, `S20`) per [`PRESENTATION.md`](PRESENTATION.md#L228-L282):
  - `S13` (`Prompt 3.1`) and `S14` (`/casts/03a-act3-cwd-review.cast`).
  - `S15`: 2-column red/emerald comparison card contrasting the macOS `.app` Finder `/` root trap (`Directory.current`) against explicit `ChatProject` workspaces, plus the 2 bonus review catches.
  - `S16` (`Prompt 3.2` with `v-click` per numbered item/sentence) and `S17` (`/casts/03b-act3-projects-sandbox.cast` — reverse-engineering `localharness` policies and `workspaceOnly` vs `enableSandbox`).
  - `S18a` (`Prompt 3.3`), `S18b` (`Prompt 3.4`), `S19` (`/casts/03c-act3-review-fixes.cast` — featuring automatic `Conversation compacted`), and `S20` (`layout: hardware-callout`, `image: /images/step-03-projects-sandbox.png`).
- [ ] **Completion Criterion**: `slides/acts/04-act3-projects-sandbox.md` builds cleanly with `npm --prefix slides run build` with zero raw LaTeX or indented code fence issues.

---

## Task 5: Author Act 4 Slides (`05-act4-a2ui.md`)

- [ ] Author `slides/acts/05-act4-a2ui.md` (`S21`–`S41`) per [`PRESENTATION.md`](PRESENTATION.md#L284-L453):
  - `S22` (`Prompt 4.1`), `S23` (`/casts/04a-act4-a2ui-surfaces.cast`), and `S24` (the 3 subtle A2UI v1.0 bugs diagnosed via widget tests, revealed with `v-click`).
  - **7-Slide Package Seamlines Deep Dive (`S25`–`S33`)**:
    - `S25` (`Prompt 4.2`) and `S26` (`/casts/04b-act4-a2ui-seamlines.cast`).
    - `S27` (3-package layering overview + Mermaid dependency graph).
    - `S28` (`a2ui_core`), `S29` (`a2ui_agent`), `S30` (`a2ui_flutter`) with `v-click` reveals.
    - `S31` (Seamlines 1 & 2 + Mermaid inbound streaming pipeline).
    - `S32` (Seamlines 3 & 4 + Mermaid two-way sequence diagram).
    - `S33` (4 architecture topologies when to use each package).
  - **3-Slide Capability Options (`S34`–`S38`)**:
    - `S34` (`Prompt 4.3`), `S35` (`/casts/04c-act4-a2ui-options.cast`), and `S36`–`S38` covering all 6 options proposed by `agy`.
  - **Implementing Forms & RPCs (`S39a`–`S41`)**:
    - `S39a` (`Prompt 4.4`), `S39b` (`Prompt 4.5`), `S40` (`/casts/04d-act4-forms-and-rpcs.cast`), and `S41` (`layout: hardware-callout`, `image: /images/step-04-a2ui.png`, including the cliffhanger into Act 5).
- [ ] **Completion Criterion**: All Mermaid diagrams (`S27`, `S31`, `S32`), `v-click` lists, and cast players in `slides/acts/05-act4-a2ui.md` compile cleanly via `npm --prefix slides run build`.

---

## Task 6: Author Act 5 & Finale Slides (`06-act5-fixup.md`) & Audit Compiled Deck

- [ ] Author `slides/acts/06-act5-fixup.md` (`S42`–`S49`) per [`PRESENTATION.md`](PRESENTATION.md#L455-L515):
  - `S43` (`Prompt 5.1`), `S44` (`/casts/05a-act5-codebase-audit.cast`), and `S45` (the 5 issues surfaced by the fresh-context audit, revealed with `v-click`).
  - `S46a` (`Prompt 5.2`), `S46b` (`Prompt 5.3`), `S47` (`/casts/05b-act5-fixups-and-tag.cast`), and `S48` (`layout: hardware-callout`, `image: /images/step-05-fixup.png`).
  - `S49` (**Takeaways, Resources & Thank You**):
    - Pair the 4 core takeaways and clickable resource cards on the left with the **Deck QR Code** (`/images/deck-qr.svg` → `https://domesticmouse.github.io/agy_genui_demo/`) on the right.
    - Include clickable links to the live deck, GitHub repo (`github.com/domesticmouse/agy_genui_demo`), `CODELAB.md`, `PRESENTATION.md`, `prompts/README.md` (sessions 01–07), `agy-genui-codelab-cast-player.html`, and the `pub.dev` packages (`antigravity`, `a2ui_core`, `a2ui_agent`, `a2ui_flutter`, `flutter_markdown_plus`).
- [ ] Run `npm --prefix slides run build` and audit `slides/dist/` to verify:
  - Zero raw LaTeX escapes (`\rightarrow`, `\leftrightarrow`, or unescaped `$`) appear in the rendered output.
  - All `/casts/*` and `/images/*` assets exist in `slides/public/` and `slides/dist/`.
  - Local dev server (`.agents/skills/slidev-deck/scripts/slides-server.sh start`) serves the deck with `HTTP 200`.

---

## Task 7: Tidy Up `README.md`

- [ ] Refactor [`README.md`](README.md) to remove bloated implementation prose and make it a crisp, scannable entry point for the repository:
  - **Overview & Links Banner**: Brief 2–3 sentence summary linking to the **Live Slidev Presentation Deck** (`https://domesticmouse.github.io/agy_genui_demo/`), **Step-by-Step Codelab** ([`CODELAB.md`](CODELAB.md)), **Presentation Outline** ([`PRESENTATION.md`](PRESENTATION.md)), **Interactive Terminal Recording** ([`agy-genui-codelab-cast-player.html`](https://domesticmouse.github.io/agy_genui_demo/agy-genui-codelab-cast-player.html)), and **Exported `agy` Session Transcripts** ([`prompts/README.md`](prompts/README.md)).
  - **5-Act Git Tag Milestones Table**: Compact table showing `step-00-scaffold` through `step-05-fixup`, what each tag adds, and the one-line `git checkout <tag> -- lib test` hot-restart command for live demos.
  - **Key Packages**: Concise list with links to [`antigravity`](https://pub.dev/packages/antigravity), [`a2ui_core`](https://pub.dev/packages/a2ui_core), [`a2ui_agent`](https://pub.dev/packages/a2ui_agent), [`a2ui_flutter`](https://pub.dev/packages/a2ui_flutter), and [`flutter_markdown_plus`](https://pub.dev/packages/flutter_markdown_plus).
  - **Quick Start (macOS Desktop App & Slidev Deck)**: Essential commands to run the Flutter macOS app (`flutter pub get`, `flutter run -d macos`, `dart analyze`, `flutter test`) and preview the Slidev deck locally (`.agents/skills/slidev-deck/scripts/slides-server.sh start`).
