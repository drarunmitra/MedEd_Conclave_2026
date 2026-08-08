# Project memory — MedEd Conclave 2026 workshop site

## What this is
Quarto website for the R & Reproducible Research workshop, 9–10 September
2026, MedEd Conclave. Deployed to GitHub Pages.

## Non-negotiables
- **R/tidyverse only.** Native pipe `|>`, never `%>%`.
- **Beginners.** Every concept gets a worked example before an exercise.
- Exercises in `callout-note`, solutions in `callout-tip collapse="true"`.
  **Exception:** the interactive primers (`prelude/primer-0*.qmd`) keep the
  `callout-note` exercise but use quarto-live's native hint/solution buttons,
  because the checker and a collapsed callout would mean maintaining every
  answer twice. See `docs/superpowers/specs/2026-08-03-webr-r-primers-design.md` §6.
- Slides are Reveal.js `.qmd` with speaker notes (`::: {.notes}`).
- Synthetic data only, seeded, health/med-ed framing, laptop-sized.
- `admin/MedEd_Conclave_2026_Workshop_Schedule_v3.xlsx` is the source of
  truth for sessions, timings and ownership. Flag conflicts, do not silently
  rework the agenda.

## Session budget
45 min teaching + 45–60 min hands-on. Say so explicitly if content will not
fit.

## Known issues flagged to the workshop lead
1. `slides/workshop_intro.html` is a generated artefact with **no source
   `.qmd` anywhere in the repo**. Its wrong date (2026-06-18) was patched
   directly in the HTML on 2026-08-03; that patch is lost if the deck is ever
   regenerated. Recover the source or re-author the deck.
2. Day 1 teaches ggplot2 (11:15) before any R fundamentals; the 12:00
   hands-on assumes "primers, file and project management" that no session
   teaches. Mitigated by the Prelude R primer, the interactive WebR primers
   (which let participants run `ggplot()` before Day 1 without installing
   anything), and a 10-minute project demo opening Session 2 — but the
   schedule itself is unchanged.
3. Day 2 afternoon has no slack. Group activity brief must be handed out at
   the morning recap, not at 15:15.
4. The interactive primers are verified on Chrome, Edge 150 and Firefox 153
   on Windows only. Safari is **unverified** — no Apple hardware was
   available. Check at least one primer on Safari before the workshop.

## Build
```bash
Rscript setup/install_packages.R
Rscript R/00_generate_datasets.R   # REQUIRED - data/ is generated, not stored
quarto render
```

The interactive primers need the quarto-live extension, which is committed
under `_extensions/`. If it is ever missing:

    quarto add r-wasm/quarto-live@v0.2.0

The extension self-reports version `0.1.3-dev` even when installed from tag
`v0.2.0` — `quarto update` cannot be trusted for it; re-pin with the command
above instead.

Each primer declares its own `format: live-html:` in its **own** front
matter (see `prelude/primer-01-objects.qmd`). **Never** add `live-html` to
`_quarto.yml`'s site-wide `format:` block — in a Quarto website project that
map applies to every format-less input, so all ~28 other pages would render
twice to the same output path, aborting the build, emptying `_site`, and
scattering stray `.html` files and `site_libs/` into the source tree.

A primer's theme path is `../styles.scss`, not `styles.scss` — it is
resolved relative to the document, not the project root. Getting this wrong
fails almost silently: one `WARN: Theme file not found` line, and the page
renders unbranded.

Never name a work-in-progress primer with a leading underscore. Quarto
excludes underscore-prefixed files from the project, and it then cannot
resolve `_extensions/`, failing with a misleading
`Unable to read the extension 'live'`.

Never open a rendered primer via `file://` — the WebAssembly worker is
blocked. Use `quarto preview`.

## Placeholders to replace before publishing
- `SET-TEAM` in `site-url` and `repo-url` (`_quarto.yml`, README)
- `{{VENUE}}`, `{{SITE_URL}}`, `{{PRETEST_URL}}`, `{{CONTACT_EMAIL}}`,
  `{{FIRST_NAME}}` in `admin/*.md`
- Faculty full names/titles and any ORCIDs
- `admin/agenda.pdf` (linked from schedule.qmd, not yet created)
