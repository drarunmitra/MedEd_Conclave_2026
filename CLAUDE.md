# Project memory — MedEd Conclave 2026 workshop site

## What this is
Quarto website for the R & Reproducible Research workshop, 9–10 September
2026, MedEd Conclave. Deployed to GitHub Pages.

## Non-negotiables
- **R/tidyverse only.** Native pipe `|>`, never `%>%`.
- **Beginners.** Every concept gets a worked example before an exercise.
- Exercises in `callout-note`, solutions in `callout-tip collapse="true"`.
- Slides are Reveal.js `.qmd` with speaker notes (`::: {.notes}`).
- Synthetic data only, seeded, health/med-ed framing, laptop-sized.
- `admin/MedEd_Conclave_2026_Workshop_Schedule_v3.xlsx` is the source of
  truth for sessions, timings and ownership. Flag conflicts, do not silently
  rework the agenda.

## Session budget
45 min teaching + 45–60 min hands-on. Say so explicitly if content will not
fit.

## Known issues flagged to the workshop lead
1. `workshop_intro.html` carries the date 2026-06-18; the workshop is
   9–10 September 2026. Needs regenerating from its source `.qmd`.
2. Day 1 teaches ggplot2 (11:15) before any R fundamentals; the 12:00
   hands-on assumes "primers, file and project management" that no session
   teaches. Mitigated by the Prelude R primer plus a 10-minute project demo
   opening Session 2 — but the schedule itself is unchanged.
3. Day 2 afternoon has no slack. Group activity brief must be handed out at
   the morning recap, not at 15:15.

## Build
```bash
Rscript setup/install_packages.R
Rscript R/00_generate_datasets.R   # REQUIRED - data/ is generated, not stored
quarto render
```

## Placeholders to replace before publishing
- `SET-TEAM` in `site-url` and `repo-url` (`_quarto.yml`, README)
- `{{VENUE}}`, `{{SITE_URL}}`, `{{PRETEST_URL}}`, `{{CONTACT_EMAIL}}`,
  `{{FIRST_NAME}}` in `admin/*.md`
- Faculty full names/titles and any ORCIDs
- `admin/agenda.pdf` (linked from schedule.qmd, not yet created)
