# Interactive R primers with WebR — design

**Date:** 2026-08-03
**Author:** Dr Arun Mitra, with Claude Code
**Status:** approved design, ready for implementation planning
**Target:** MedEd Conclave 2026 · R & Reproducible Research workshop, 9–10 September 2026

---

## 1. Problem

Participants must install R, RStudio, Quarto and sixteen packages before Day 1.
`prelude/install.qmd` budgets 30 minutes for the install and
`prelude/check-setup.qmd` warns that packages alone take "10–20 minutes on a
first run". The site's own copy concedes the risk twice: "Installation
problems... can eat half of Day 1."

Two of the four documented failure classes — CRAN blocked by institutional
firewalls, and Quarto missing from `PATH` — are outside a participant's
competence to diagnose.

Separately, `CLAUDE.md` records known issue #2: Day 1 teaches ggplot2 at 11:15
before any session teaches R fundamentals. The mitigation is the existing
static `prelude/r-primer.qmd`, which participants must choose to work through
in RStudio — which requires the install to have succeeded first.

Interactive in-browser R breaks that dependency. A participant can learn R
fundamentals with nothing but a browser, before and independently of the
install.

## 2. Goals and non-goals

**Goals**

- Five self-paced interactive primers, runnable in a browser with no install.
- Tidyverse-native from primer 02 onward, per `CLAUDE.md`'s "R/tidyverse only".
- A participant reaching Day 1 11:15 has already run `ggplot()` successfully.
- No change in behaviour for the 24 existing pages.

**Non-goals**

- Replacing the local install. The workshop's central claim is reproducibility
  via a local project, relative paths and clean sessions. WebR has no project,
  no `.Rproj` and a filesystem participants cannot inspect. The primers are a
  ramp onto the local toolchain, never a substitute.
- Collecting participant data. Explicitly decided against — see §9.
- Touching Day 1 or Day 2 teaching pages. Out of scope.

## 3. Decisions

| # | Decision | Rationale |
|---|---|---|
| 1 | Extension: `r-wasm/quarto-live` v0.2.0 | Maintained by webR's author at Posit; ships webR 0.6.0; only option with an exercise/grading system. `coatless/quarto-webr` has had no commit since 2025-11 and still documents a `service-worker` channel that webR **deleted in 0.5.5**. |
| 2 | Deploy on GitHub Pages unchanged | WebR does not require COOP/COEP; it falls back to the PostMessage channel automatically. The quarto-live docs site is itself on GitHub Pages. Verified empirically: `crossOriginIsolated === false`, cells still run. |
| 3 | Scope: prelude only | Highest value where install has not yet succeeded. Day 1/2 pages left alone. |
| 4 | `r-primer.qmd` stays static, unchanged | Serves readers who prefer RStudio, and doubles as the fallback when WebR will not load. |
| 5 | Primers are practice-first, not a prose mirror | Minimal orientation prose, then cells. Explanation lives once, in `r-primer.qmd`, cross-linked. Avoids two copies of every explanation drifting apart. |
| 6 | Five primers, tidyverse-native after the first | Primer 01 is irreducible base-R scaffolding; 02–05 are tibbles, the native pipe, dplyr verbs, ggplot2. |
| 7 | Graded checks + hints + solutions | Learners work alone at home with no faculty to ask. |
| 8 | **No gradethis** | Costs 31.6 MB and 53 packages (pulls in shiny) for feedback a plain `#\| check: true` block gives for 0 MB. |
| 9 | Native quarto-live hint/solution buttons | Deliberate deviation from `CLAUDE.md`; see §6. |
| 10 | `live-html` declared in each primer's **front matter**, never in `_quarto.yml` | Existing pages and the `_freeze/` cache untouched. Reversible: delete five files. **Corrected 2026-08-03 after the Task 3 spike — see §4.** |
| 11 | Primers 04–05 read the real `meded_students.csv` | Continuity with Day 1 s3, and the same relative path works in both places. |
| 12 | No participant data collection | See §9. |
| 13 | Drop renv from CI | See §10. |

## 4. Architecture

Install the extension to `_extensions/r-wasm/live/`. **`_quarto.yml` is not
modified at all.** Each primer declares `live-html` in its own front matter.

```
_quarto.yml     UNCHANGED — no live-html block
prelude/primer-0N.qmd
  ---
  format:
    live-html:      # declared per page
      theme:
        light: [cosmo, ../styles.scss]
  ---
```

> **Corrected 2026-08-03 by the Task 3 spike.** The original design put a
> `live-html:` sibling under `_quarto.yml`'s top-level `format:` map. That is
> not merely ineffective — it is **destructive**. In a Quarto *website*
> project the top-level `format:` map is the list of formats *every* input
> renders to. Only the five `slides/**` decks declare their own `format:`;
> the other ~28 pages inherit the project list, so adding `live-html` made
> each render **twice** to the same output path. The build aborts with
> `NotFound … rename`, `_site` is left with 1 file instead of 35, and 32
> stray `.html` files plus a root `site_libs/` are scattered into the source
> tree — none of them gitignored. Verified empirically; do not retry it.
>
> Declaring the format in a page's own front matter narrows that page to a
> single format, which is exactly how the existing slide decks already avoid
> the problem. With `_quarto.yml` untouched, all 35 existing pages were
> confirmed **byte-identical by md5** before and after installing the
> extension. The extension's filter runs only for documents that request a
> live format, so its mere presence changes nothing.

The render list already globs `prelude/*.qmd`, so new files are picked up with
no change there. Quarto ignores `_`-prefixed directories, so `_extensions/`
is not rendered.

**A page whose filename begins with `_` cannot be rendered directly** —
Quarto excludes it from the project and then resolves `_extensions/` relative
to the page's own directory, failing with a misleading
`Unable to read the extension 'live'`. Work-in-progress live pages must not
use an `_` prefix.

### Files

```
prelude/
  r-primer.qmd                  unchanged, static
  primer-01-objects.qmd         base R           engine only
  primer-02-tibbles.qmd         tibble           small
  primer-03-packages-pipe.qmd   dplyr            + ~6.5 MB
  primer-04-dplyr-verbs.qmd     dplyr, readr     + readr only
  primer-05-first-plot.qmd      ggplot2, readr   + ~16 MB
```

Sidebar: a nested "Interactive primers" section directly beneath
`r-primer.qmd`, so the static page and its practice track sit together.

### Payload

Measured against `repo.r-wasm.org` (full recursive Depends+Imports closure,
actual `.tgz` sizes):

| Asset | Size |
|---|---|
| webR engine (`R.wasm` + support) | ~13 MB |
| dplyr closure (15 pkgs) | 6.5 MB |
| ggplot2 closure (16 pkgs) | 16.1 MB |
| A participant completing all five | ~40–45 MB |

quarto-live's `packages:` key is **per document**, so primers 01–03 never
download ggplot2. Assets are served with `cache-control: max-age=604800`
(7 days) from a version-pinned URL, so a participant who opens the primers at
home pays nothing again at the venue.

## 5. Page anatomy

Every primer follows one shape, honouring `CLAUDE.md`'s worked-example-before-
exercise rule:

1. YAML — `format: live-html`, `engine: knitr`, per-page `webr: packages:`
2. `{{< include ../_extensions/r-wasm/live/_knitr.qmd >}}` — required for
   ` ```{webr} ` cells under the knitr engine
3. Fallback callout (see §8)
4. 2–3 sentences of orientation, linking to the matching `r-primer.qmd` section
5. **Worked example** — an autorun cell showing the concept working
6. **Exercises** — blank-filling cell, hint, solution, check
7. `## Next` footer in the site's existing `→ [link] — gloss` style

### Curriculum

| Primer | Teaches | Packages |
|---|---|---|
| 01 objects, functions, vectors | `<-`, `c()`, function calls, named arguments, vector types, type coercion | none |
| 02 tibbles: the data rectangle | `tibble()`, rows-as-observations, `glimpse()`, pulling a column | tibble |
| 03 packages and the native pipe | `library()`, why `install.packages()` stays out of scripts, `\|>` as a left-to-right pipeline | dplyr |
| 04 dplyr verbs | `filter()`, `select()`, `arrange()`, `mutate()`, `summarise()` on the real cohort | dplyr, readr |
| 05 your first plot | `ggplot()` + `aes()` + `geom_histogram()` / `geom_boxplot()`, `labs()` | ggplot2, readr |

Native pipe `|>` only, never `%>%`. British English. Health/med-ed framing
throughout. Synthetic data only.

**One honesty point primer 03 must make.** quarto-live installs *and*
`library()`-attaches every package named in `webr: packages:` before the first
cell runs. A learner in the browser therefore never needs `library()`, which is
precisely the opposite of the habit primer 03 is teaching. The page must say so
explicitly: *in this browser the packages are already attached for you; in
RStudio you must call `library()` yourself, at the top of every script.*
Teaching `library()` without naming that difference would be actively
misleading.

## 6. House-style deviation (accepted)

`CLAUDE.md` mandates exercises in `callout-note` and solutions in
`callout-tip collapse="true"`. quarto-live has its own exercise machinery:
`#| solution: true` renders a reveal button and `::: {.hint}` renders a hint
button, both wired to the checker.

Reproducing solutions as collapsed callouts *and* wiring the checker would mean
maintaining every answer twice in one file.

**Resolution:** the exercise stays in a `callout-note` titled in house format
(`Exercise 1: your first vector`, with the `**Time:**` line). Hints and
solutions use quarto-live's native buttons rather than a collapsed
`callout-tip`. One source of truth per answer; better UX for interactive work.

`CLAUDE.md` should be updated to record this exception.

## 7. Data flow

Primers 01–03 touch no files and no packages beyond tibble.

Primers 04–05: `data/meded_students.csv` (30 KB) is already published by the
existing `resources: data/**` in `_quarto.yml`. quarto-live's
`webr: resources:` key fetches it into the WebAssembly virtual filesystem at
`/home/web_user/data/`, so `read_csv("data/meded_students.csv")` works with the
**same relative path** participants use on Day 1.

`data/` is both committed to the repo and regenerated by CI
(`Rscript R/00_generate_datasets.R`) before render, so it exists at render time
either way.

**Nothing survives page navigation.** Each page load is a fresh webR worker
with a fresh global environment and a fresh filesystem. Every primer is
therefore self-contained: no primer may depend on an object created in another.

## 8. Failure handling

| Failure | Response |
|---|---|
| WebR will not load — proxy, old browser, no connection | Each primer opens with a callout: *"If the cells below never become ready, work through [the R primer](r-primer.qmd) in RStudio instead."* The static page is the fallback. |
| Runaway loop | No interrupt exists on the PostMessage channel. Cells keep quarto-live's 30 s `timelimit`; recovery is a page reload, stated plainly in the fallback callout. |
| Reload loses typing | `persist: true` on exercise cells saves editor text to localStorage. |
| Check false-negative | Checks compare **values** with `identical()` / `all.equal()`, never code text. Where several answers are correct, all are accepted. |
| Venue bandwidth | Primers are pre-workshop by design. `prelude/index.qmd` gains one line: open these before you travel. The 7-day cache makes the venue morning nearly free. |
| Package download interrupted mid-startup | Page hangs on "Downloading package". Recovery is a reload; cached assets are reused. Noted in the fallback callout. |

## 9. Participant data — explicitly none

WebR runs entirely client-side and GitHub Pages has no backend. Exercise
results never leave the browser; `persist: true` writes only to the learner's
own localStorage.

**Decision: collect nothing.** The primers are private practice. This avoids
consent, DPDP and IEC questions entirely.

**Open item, not part of this work:** `{{PRETEST_URL}}` appears in
`admin/invitation-email.md:24` and `admin/reminder-email.md:39` and has no
target. Either those lines are removed or they point at something built
separately. This is a workshop-lead decision and is deliberately left alone
here.

## 10. CI prerequisite (blocking)

`.github/workflows/publish.yml:35` uses `r-lib/actions/setup-renv@v2`, but the
repository contains **no `renv.lock`**. That step fails, so the site cannot
currently deploy at all — independent of this work, but blocking it.

**Fix:** replace with `r-lib/actions/setup-r-dependencies@v2` and an explicit
package list. The correct block is already present in the file, commented out
at lines 36–47.

## 11. Verification

No test framework exists here, so verification is explicit and manual. It must
run over HTTP — opening the rendered HTML via `file://` blocks the worker.

1. `quarto render` completes; the 24 existing pages are byte-identical
   (diff `_site/` before and after).
2. Each primer reaches "ready"; every worked example produces correct output.
3. For every exercise: the intended answer passes, **and** a plausible wrong
   answer fails with a useful message.
4. Primers 04–05 read the CSV from the virtual filesystem and produce the
   expected output and plot.
5. Cold-cache payload measured with devtools (cache disabled) per page, to
   confirm the §4 figures on this site rather than trusting published sizes.
6. Chrome and Safari, plus one Windows laptop — what most participants bring.
7. Fallback verified: with the webR CDN blocked, the fallback callout is
   visible and its link works.

## 12. Risks

| Risk | Severity | Mitigation |
|---|---|---|
| Extension churn — quarto-live's gradethis include is documented as "temporary" | Low | We do not use gradethis. Version pinned at v0.2.0. |
| `_extension.yml` at the v0.2.0 tag still declares `version: 0.1.3-dev` | Cosmetic | Known upstream packaging bug; `quarto list extensions` under-reports. No functional effect. |
| Participants on tablets | Low | Browsers cap WebAssembly memory regardless of device RAM. Primers state a laptop is expected — which the workshop already requires. |
| Two formats in one project confuse future edits | Low | Documented here and in the skill (§13). |
| Cells inside callout divs may not render as expected | Medium | Unverified. Must be checked in the implementation spike before the page template is fixed. |

## 13. Follow-on deliverable

Package this approach as a reusable skill (`webr-workshop`) built on
progressive disclosure: a short `SKILL.md` covering when and how to reach for
WebR, with detail deferred to `references/` files loaded only when needed
(extension setup, payload budgeting, exercise/check patterns, failure
handling). Scope, structure and authoring to follow `superpowers:writing-skills`.

## 14. Sources

- webR serving and channels — <https://docs.r-wasm.org/webr/latest/serving.html>, <https://docs.r-wasm.org/webr/latest/communication.html>
- Service-worker channel removed in 0.5.5 — <https://github.com/r-wasm/webr/blob/main/NEWS.md>
- quarto-live exercises and grading — <https://r-wasm.github.io/quarto-live/exercises/exercises.html>, <https://r-wasm.github.io/quarto-live/exercises/grading.html>
- quarto-live resources (virtual filesystem) — <https://r-wasm.github.io/quarto-live/other/resources.html>
- WebR package repository index — <https://repo.r-wasm.org/bin/emscripten/contrib/4.6/PACKAGES>
- webR limitations — <https://docs.r-wasm.org/webr/latest/plotting.html>, <https://docs.r-wasm.org/webr/latest/networking.html>, <https://docs.r-wasm.org/webr/latest/building.html>
