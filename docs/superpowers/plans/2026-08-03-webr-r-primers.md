# Interactive WebR R Primers Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add five self-paced interactive R primers to the workshop site that run entirely in a participant's browser, requiring no R installation.

**Architecture:** Install the `r-wasm/quarto-live` Quarto extension and add five new pages under `prelude/`, each declaring the `live-html` format in its **own front matter**. `_quarto.yml`'s `format:` block is never touched. The 24 existing pages are untouched and keep rendering through the `html` format with their `_freeze/` cache intact. Each primer declares only the R packages it needs, so the WebAssembly payload is paid per page rather than all at once.

**Tech Stack:** Quarto 1.5.57 · quarto-live v0.2.0 · webR 0.6.0 (WebAssembly R) · R 4.4.1 · tidyverse (tibble, dplyr, readr, ggplot2) · GitHub Pages

**Spec:** `docs/superpowers/specs/2026-08-03-webr-r-primers-design.md`

## Global Constraints

Every task's requirements implicitly include this section.

- **⚠️ NEVER put `live-html` in `_quarto.yml`'s `format:` block.** Proven destructive by the Task 3 spike: it makes ~28 format-less pages render twice to the same path, aborts the build, empties `_site`, and scatters 32 untracked `.html` files into the source tree. Every primer declares `live-html` in its **own front matter**. `_quarto.yml`'s `format:` block stays exactly as it is.
- **Never name a work-in-progress live page with a leading `_`.** Quarto then excludes it from the project and cannot resolve `_extensions/`, failing with a misleading `Unable to read the extension 'live'`.
- **This is the verified per-page front-matter block.** Use it in all five primers, varying only `title`, `subtitle` and the `webr: packages:` list:

```yaml
---
title: "..."
subtitle: "..."
engine: knitr
format:
  live-html:
    theme:
      light: [cosmo, styles.scss]
    toc: true
    toc-depth: 3
    toc-title: "On this page"
    code-copy: true
    code-overflow: wrap
    anchor-sections: true
    link-external-newwindow: true
    fig-align: center
    webr:
      cell-options:
        persist: true
        timelimit: 30
webr:
  packages:
    - ...
---
```

`styles.scss` resolves project-root-relative even from `prelude/` — no `../` prefix. The nested `webr:` inside the format sets cell defaults; the top-level `webr:` sets the page's packages. Both are needed.

- **R/tidyverse only. Native pipe `|>`, never `%>%`.** (`CLAUDE.md` non-negotiable)
- **Beginners.** Every concept gets a worked example before an exercise.
- **British English throughout** — `visualise`, `colour`, `summarise`, `randomised`.
- **Health / medical-education framing.** Synthetic data only, seeded, laptop-sized.
- **Exercises live in `callout-note`** titled `Exercise N: lowercase phrase`, with a `**Time:** N minutes` line directly beneath the title.
- **Solutions and hints use quarto-live's native buttons**, NOT collapsed `callout-tip`. This is a documented deviation from `CLAUDE.md` — see spec §6.
- **Chunk options always use the `#| key: value` form**, never `{r, echo=FALSE}`.
- **Live chunks are never labelled.** No `#| label:` on executable cells.
- **Every page ends with a `## Next` footer**: `→ [Link](target.qmd) — lowercase gloss.`
- **Function names in backticks with parens**: `` `filter()` ``. Package names in backticks.
- **Brand palette** where colour is needed: `#0f5257` (primary, Flipped classroom), `#b8860b` (Traditional lecture).
- **No participant data is collected.** Nothing may transmit off the page.
- **quarto-live version is pinned at v0.2.0.** Do not use `gradethis` (31.6 MB, pulls in shiny).
- **Never modify** `prelude/r-primer.qmd`, any `day1/`, `day2/`, or `resources/` page.

---

## Task 1: Initialise git (GATED — requires user approval)

**⚠️ Do not run this task without explicit user go-ahead.** The project directory is not a git repository. Every later task ends in a commit, so those steps fail without this. If the user declines, treat all later "Commit" steps as "stop and let the user inspect the diff" checkpoints instead.

**Files:**
- Create: `.git/` (via `git init`)

**Interfaces:**
- Produces: a working repository so later tasks can commit.

- [ ] **Step 1: Confirm the user wants git initialised here**

Ask explicitly. Do not proceed on assumption.

- [ ] **Step 2: Verify there is no existing repo**

Run: `git -C . rev-parse --is-inside-work-tree`
Expected: `fatal: not a git repository`

- [ ] **Step 3: Initialise and make the baseline commit**

```bash
git init -b main
git add .
git commit -m "chore: initial commit of MedEd Conclave 2026 workshop site

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

- [ ] **Step 4: Verify the working tree is clean**

Run: `git status --short`
Expected: no output.

Note `.gitignore` already excludes `_site/`, `.quarto/`, `_freeze/` and `output/`. The four CSVs in `data/` ARE tracked (not ignored), which is intended — see spec §7.

---

## Task 2: Fix the blocking CI failure

`.github/workflows/publish.yml:35` uses `r-lib/actions/setup-renv@v2`, but there is no `renv.lock` in the repo. That step fails, so the site cannot deploy at all. Independent of WebR, but it blocks shipping the primers. The user has decided **not** to adopt renv.

**Files:**
- Modify: `.github/workflows/publish.yml:34-47`

**Interfaces:**
- Produces: a CI workflow that can actually build the site.

- [ ] **Step 1: Confirm the failure mode**

Run: `ls renv.lock`
Expected: `No such file or directory` — confirming `setup-renv` has no lockfile to read.

- [ ] **Step 2: Replace the renv step with an explicit dependency list**

Replace lines 34–47 of `.github/workflows/publish.yml` (the `Install R dependencies` step and its commented-out alternative) with:

```yaml
      - name: Install R dependencies
        uses: r-lib/actions/setup-r-dependencies@v2
        with:
          packages: |
            any::tidyverse
            any::gtsummary
            any::janitor
            any::knitr
            any::rmarkdown
            any::skimr
            any::patchwork
            any::flextable
            any::scales
            any::here
            any::gt
            any::palmerpenguins
```

This list is taken from the 16 packages named in `prelude/check-setup.qmd`, minus `quarto` (the Quarto CLI is installed by the earlier `setup-quarto` step, and the R `quarto` package is only used in `eval: false` chunks).

- [ ] **Step 3: Verify the YAML still parses**

Run: `Rscript -e "cat(yaml::read_yaml('.github/workflows/publish.yml')\$jobs\$\`build-deploy\`\$steps[[4]]\$name, '\n')"`
Expected: `Install R dependencies`

If `yaml` is not installed, run `Rscript -e "install.packages('yaml', repos='https://cloud.r-project.org')"` first.

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/publish.yml
git commit -m "fix(ci): replace renv setup with explicit package list

The workflow used r-lib/actions/setup-renv@v2 but the repository has no
renv.lock, so the build step failed and the site could never deploy.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: Spike — prove quarto-live works in THIS project

**This task exists to kill assumptions before five pages are built on them.** Three things are unverified: (a) whether a second `live-html` format coexists with the site's `html` format without disturbing existing pages, (b) whether a ` ```{webr} ` cell renders correctly **inside a `callout-note` div** — the whole page template depends on this, and (c) whether the `#| check: true` mechanism actually fires.

The throwaway page is deleted at the end of this task. Nothing from it ships.

**Files:**
- Create: `_extensions/r-wasm/live/` (via `quarto add`)
- Create: `prelude/_spike.qmd` (temporary, deleted in Step 8)
- Modify: `_quarto.yml` (temporary format block, kept if the spike passes)

**Interfaces:**
- Produces: a verified `live-html` format block in `_quarto.yml`, and a confirmed answer to "can webr cells live inside callouts?" that Task 5 depends on.

- [ ] **Step 1: Record the pre-change state of the rendered site**

```bash
quarto render
find _site -name "*.html" | sort > /tmp/site-before.txt
```

Expected: 35 HTML files listed.

- [ ] **Step 2: Install the extension, pinned**

Run: `quarto add r-wasm/quarto-live@v0.2.0 --no-prompt`

Expected: creates `_extensions/r-wasm/live/`.

Verify: `ls _extensions/r-wasm/live/`
Expected: contains `_extension.yml`, `_knitr.qmd`, and resource files.

Note: `_extension.yml` will report `version: 0.1.3-dev` even at the v0.2.0 tag. This is a known upstream packaging bug with no functional effect (spec §12). Do not treat it as an installation failure.

- [ ] **Step 3: Add the `live-html` format to `_quarto.yml`**

In `_quarto.yml`, inside the existing top-level `format:` block (currently at line 113), add a sibling to `html:`:

```yaml
format:
  html:
    theme:
      light: [cosmo, styles.scss]
    toc: true
    # ... existing html config unchanged ...

  live-html:
    theme:
      light: [cosmo, styles.scss]
    toc: true
    toc-depth: 3
    toc-title: "On this page"
    code-copy: true
    code-overflow: wrap
    anchor-sections: true
    link-external-newwindow: true
    fig-align: center
    webr:
      packages: []
      cell-options:
        persist: true
        timelimit: 30
```

Do not delete or reorder anything in the existing `html:` block.

- [ ] **Step 4: Write the spike page**

Create `prelude/_spike.qmd`. The leading underscore keeps Quarto from rendering it as a site page while still allowing direct render.

````markdown
---
title: "Spike"
format: live-html
engine: knitr
webr:
  packages:
    - dplyr
---

{{< include ../_extensions/r-wasm/live/_knitr.qmd >}}

## A: bare cell outside any callout

```{webr}
x <- c(78, 64, 91)
mean(x)
```

## B: cell INSIDE a callout-note — the thing we must verify

::: {.callout-note title="Exercise 1: does this render"}
**Time:** 1 minute

Fill in the blank so `osce` holds the five marks.

```{webr}
#| exercise: ex_spike
osce <- ______
```

```{webr}
#| exercise: ex_spike
#| solution: true
osce <- c(78, 64, 91, 55, 83)
```

```{webr}
#| exercise: ex_spike
#| check: true
if (identical(.result, c(78, 64, 91, 55, 83))) {
  list(correct = TRUE, message = "Correct.")
} else {
  list(correct = FALSE, message = "Use c() with all five marks.")
}
```

::: {.hint exercise="ex_spike"}
`c()` combines values into a vector.
:::
:::

## C: does a declared package attach

```{webr}
dplyr::glimpse(data.frame(a = 1:3))
```
````

- [ ] **Step 5: Render and confirm existing pages are unaffected**

```bash
quarto render
find _site -name "*.html" | sort > /tmp/site-after.txt
diff /tmp/site-before.txt /tmp/site-after.txt
```

Expected: no differences. The spike page must NOT appear in `_site` (underscore prefix). If existing pages changed or vanished, STOP — the format block is wrong.

- [ ] **Step 6: Render the spike page directly and serve it over HTTP**

```bash
quarto render prelude/_spike.qmd --to live-html
```

Then serve — `file://` blocks the WebAssembly worker and will always fail:

```bash
quarto preview prelude/_spike.qmd --no-browser --port 4321
```

- [ ] **Step 7: Verify in a real browser**

Use the Chrome tools (`mcp__claude-in-chrome__*`) or do it by hand at `http://localhost:4321`. Check all four, and write the answers into the task notes:

1. Section A's cell shows a Run button, and running it prints `[1] 77.66667`.
2. **Section B's cell renders inside the callout box** — not escaped as literal text, not hoisted outside the callout border. This is the gating question.
3. Typing `c(78, 64, 91, 55, 83)` and running the check reports correct; typing `c(1, 2)` reports the "Use c()" message.
4. Section C prints a glimpse without a "could not find function" error, confirming declared packages are auto-attached.

Also read the browser console (`read_console_messages`) for WebR errors.

**If (2) fails**, the page template in Task 5 must change: move the cells OUT of the callout, and use a `callout-note` for the exercise *prose only*, with the cells immediately after it. Record this decision here — Tasks 5–9 depend on it.

- [ ] **Step 8: Delete the spike page**

```bash
rm prelude/_spike.qmd
quarto render
```

Expected: still 35 HTML files, no spike output.

- [ ] **Step 9: Commit**

```bash
git add _extensions _quarto.yml
git commit -m "feat: add quarto-live extension and live-html format

Installs r-wasm/quarto-live v0.2.0 and registers a second live-html
output format alongside the existing html format. Existing pages are
unaffected. Verified webr cells render inside callout divs.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: Add the primers to navigation

Wire the five (not-yet-written) pages into the sidebar first, so each later task can be verified in the real site chrome rather than in isolation.

**Files:**
- Modify: `_quarto.yml:52-63` (the `prelude` sidebar block)
- Create: `prelude/primer-01-objects.qmd` … `prelude/primer-05-first-plot.qmd` (stubs)

**Interfaces:**
- Consumes: the `live-html` format from Task 3.
- Produces: five routable page paths that Tasks 5–9 fill in.

- [ ] **Step 1: Create five minimal stubs**

Each stub is exactly this shape, with `NN`/`TITLE` substituted. This confirms routing before content exists.

````markdown
---
title: "TITLE"
subtitle: "Interactive primer"
format: live-html
engine: knitr
---

{{< include ../_extensions/r-wasm/live/_knitr.qmd >}}

Stub.
````

Titles, in order:

| File | Title |
|---|---|
| `primer-01-objects.qmd` | `Primer 1 · Objects, functions and vectors` |
| `primer-02-tibbles.qmd` | `Primer 2 · Tibbles: the data rectangle` |
| `primer-03-packages-pipe.qmd` | `Primer 3 · Packages and the native pipe` |
| `primer-04-dplyr-verbs.qmd` | `Primer 4 · The five dplyr verbs` |
| `primer-05-first-plot.qmd` | `Primer 5 · Your first plot` |

The `·` middle dot matches the site's existing session-title convention (`3 · Introduction to R and data visualisation`).

- [ ] **Step 2: Add the sidebar subsection**

In `_quarto.yml`, replace the `prelude` sidebar `contents:` block (lines 57–63) with:

```yaml
      contents:
        - prelude/index.qmd
        - prelude/install.qmd
        - prelude/check-setup.qmd
        - prelude/r-primer.qmd
        - section: "Interactive primers"
          contents:
            - prelude/primer-01-objects.qmd
            - prelude/primer-02-tibbles.qmd
            - prelude/primer-03-packages-pipe.qmd
            - prelude/primer-04-dplyr-verbs.qmd
            - prelude/primer-05-first-plot.qmd
        - prelude/data.qmd
        - prelude/pre-reading.qmd
```

The subsection sits directly beneath `r-primer.qmd` so the static page and its practice track are adjacent.

- [ ] **Step 3: Render and verify routing**

```bash
quarto render
find _site/prelude -name "primer-*.html" | sort
```

Expected: exactly five files, `primer-01-objects.html` through `primer-05-first-plot.html`.

- [ ] **Step 4: Verify the sidebar renders**

Open `http://localhost:4321/prelude/r-primer.html` via `quarto preview`. Expected: an "Interactive primers" section with five entries appears in the Prelude sidebar, between "R primer" and "Datasets".

- [ ] **Step 5: Commit**

```bash
git add _quarto.yml prelude/primer-*.qmd
git commit -m "feat: scaffold five interactive primer pages and sidebar

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Task 5: Primer 01 — objects, functions and vectors

Establishes the page template every later primer copies. Base R only: no packages, so this page costs only the ~13 MB webR engine and hits no package repository at all.

Source material: `prelude/r-primer.qmd` lines 13–77 (Objects / Functions / Vectors). Do **not** copy the prose wholesale — the primers are practice-first (spec §3 decision 5). Orientation is 2–3 sentences, then cells.

**Files:**
- Modify: `prelude/primer-01-objects.qmd`

**Interfaces:**
- Consumes: `live-html` format (Task 3), stub routing (Task 4).
- Produces: **the page template.** Tasks 6–9 replicate this exact structure — front matter shape, fallback callout wording, worked-example-then-exercise rhythm, and `## Next` footer.

- [ ] **Step 1: Write the page**

Replace `prelude/primer-01-objects.qmd` entirely:

````markdown
---
title: "Primer 1 · Objects, functions and vectors"
subtitle: "R in your browser — nothing to install"
format: live-html
engine: knitr
---

{{< include ../_extensions/r-wasm/live/_knitr.qmd >}}

::: {.callout-important title="If the cells below never become ready"}
This page runs R inside your browser. It needs about 13 MB on first load,
and a minute or two on a slow connection. If nothing happens after that, your
network is probably blocking it — work through
[the R primer](r-primer.qmd) in RStudio instead. Everything taught here is
taught there too.

There is no Stop button. If you write a loop that never ends, reload the page.
:::

Three ideas carry the whole of Day 1: R stores things in **objects**, you do
things with **functions**, and the commonest object is a **vector**. Run the
cells, change the numbers, break them on purpose. For the full explanation of
any of this, see [the R primer](r-primer.qmd).

## Objects

`<-` is the assignment arrow. It puts the thing on its right into the name on
its left.

```{webr}
n_students <- 240
course     <- "Community Medicine"

n_students
course
```

Change `240` to your own department's intake and run it again.

## Functions

A function is a verb. It takes arguments in brackets, separated by commas.

```{webr}
sqrt(64)
round(3.14159, digits = 2)
mean(c(72, 68, 81, 90))
```

Named arguments like `digits = 2` are clearer than positional ones. Prefer them.

## Vectors

`c()` **c**ombines values into a vector — a column of values, all of the same
type. It is the most-used function in R.

```{webr}
scores <- c(72, 68, 81, 90, 55)

scores
length(scores)
mean(scores)
```

A comparison returns a logical vector, one `TRUE` or `FALSE` per element:

```{webr}
scores <- c(72, 68, 81, 90, 55)
scores > 70
```

A vector holds **one** type. Mix them and everything is silently converted to
the most permissive type — a classic source of confusion:

```{webr}
c(1, 2, "three")
```

Those quotation marks mean all three are now text. You cannot take the mean of
that.

::: {.callout-note title="Exercise 1: your first vector"}
**Time:** 5 minutes

Five students sat an OSCE station and scored 78, 64, 91, 55 and 83.
Put those marks into a vector called `osce`.

```{webr}
#| exercise: ex_vector
osce <- ______
```

```{webr}
#| exercise: ex_vector
#| solution: true
osce <- c(78, 64, 91, 55, 83)
```

```{webr}
#| exercise: ex_vector
#| check: true
if (identical(.result, c(78, 64, 91, 55, 83))) {
  list(correct = TRUE, message = "Correct — that is a numeric vector of five marks.")
} else if (is.character(.result)) {
  list(correct = FALSE, message = "Those are text, not numbers. Drop the quotation marks.")
} else if (length(.result) != 5) {
  list(correct = FALSE, message = "You need all five marks, in order.")
} else {
  list(correct = FALSE, message = "Use c() to combine the five marks: c(78, 64, ...).")
}
```

::: {.hint exercise="ex_vector"}
`c()` combines values. The marks go inside the brackets, separated by commas.
:::
:::

::: {.callout-note title="Exercise 2: summarise the marks"}
**Time:** 5 minutes

How many of those five marks are 70 or above? A comparison gives you `TRUE`
and `FALSE`, and `sum()` counts `TRUE` as 1.

```{webr}
#| exercise: ex_count
osce <- c(78, 64, 91, 55, 83)

sum(______)
```

```{webr}
#| exercise: ex_count
#| solution: true
osce <- c(78, 64, 91, 55, 83)

sum(osce >= 70)
```

```{webr}
#| exercise: ex_count
#| check: true
if (identical(as.numeric(.result), 3)) {
  list(correct = TRUE, message = "Correct — three marks are 70 or above.")
} else if (identical(as.numeric(.result), 2)) {
  list(correct = FALSE, message = "Close. You used > 70, which excludes a mark of exactly 70. Use >=.")
} else {
  list(correct = FALSE, message = "Compare the whole vector at once: osce >= 70.")
}
```

::: {.hint exercise="ex_count"}
You do not need a loop. `osce >= 70` compares every element at once.
:::
:::

## Next

→ [Primer 2 · Tibbles](primer-02-tibbles.qmd) — put those vectors side by side
into the rectangle you will actually analyse.
````

- [ ] **Step 2: Render**

Run: `quarto render prelude/primer-01-objects.qmd`
Expected: completes without error.

- [ ] **Step 3: Verify in the browser**

Serve with `quarto preview --no-browser --port 4321` and open
`http://localhost:4321/prelude/primer-01-objects.html`.

Verify, and record each result:

1. The page reaches ready state — cells show a Run button, not a spinner.
2. `mean(c(72, 68, 81, 90))` prints `[1] 77.75`.
3. `c(1, 2, "three")` prints `[1] "1" "2" "three"` (quoted).
4. Exercise 1: `c(78, 64, 91, 55, 83)` → correct. `c("78", "64")` → the "text, not numbers" message. `c(78, 64)` → the "all five marks" message.
5. Exercise 2: `sum(osce >= 70)` → correct. `sum(osce > 70)` → the ">= " nudge message.
6. Hint and solution buttons both appear and work.

- [ ] **Step 4: Confirm no package downloads**

In devtools Network, filter for `repo.r-wasm.org`.
Expected: **zero** requests. This page is base R only; any package request means a stray `webr: packages:` entry.

- [ ] **Step 5: Commit**

```bash
git add prelude/primer-01-objects.qmd
git commit -m "feat(primers): add primer 1 on objects, functions and vectors

Base R only, no package downloads. Establishes the page template.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Task 6: Primer 02 — tibbles

Source material: `prelude/r-primer.qmd` lines 78–113 (Data frames), converted to tidyverse-native `tibble()` per spec decision 6.

**Files:**
- Modify: `prelude/primer-02-tibbles.qmd`

**Interfaces:**
- Consumes: the page template from Task 5. Reuse the fallback callout **verbatim**, changing only the size figure if the package set differs.
- Produces: nothing later tasks depend on structurally.

- [ ] **Step 1: Write the page**

Use Task 5's structure exactly: front matter → knitr include → fallback callout → 2–3 sentence orientation linking to `r-primer.qmd` → worked examples → exercises in `callout-note` → `## Next`.

Front matter adds the package:

```yaml
---
title: "Primer 2 · Tibbles: the data rectangle"
subtitle: "Rows are observations, columns are variables"
format: live-html
engine: knitr
webr:
  packages:
    - tibble
---
```

Content requirements:

- Worked example building a tibble from vectors:

````markdown
```{webr}
library(tibble)

students <- tibble(
  student_id = c("S01", "S02", "S03", "S04"),
  batch      = c("2023", "2023", "2024", "2024"),
  attendance = c(88, 72, 95, 64),
  passed     = c(TRUE, TRUE, TRUE, FALSE)
)

students
```
````

- A second cell showing inspection: `nrow()`, `ncol()`, `names()`, `glimpse()`.
- Prose making the one point that matters: **`glimpse()` is the function you will
  reach for when something goes wrong**, because nine times out of ten a column
  is text when you thought it was a number.
- A cell showing `students$attendance` and `mean(students$attendance)`.
- **Exercise 1** (5 min): build a tibble `viva` with `station` = `"History"`,
  `"Exam"`, `"Counselling"` and `marks` = 8, 7, 9. Check compares against the
  expected tibble with `all.equal()`, accepting either a `tibble` or a
  `data.frame` so a learner who types `data.frame()` is not failed unfairly:

````markdown
```{webr}
#| exercise: ex_tibble
#| check: true
expected <- tibble::tibble(
  station = c("History", "Exam", "Counselling"),
  marks   = c(8, 7, 9)
)
if (isTRUE(all.equal(as.data.frame(.result), as.data.frame(expected)))) {
  list(correct = TRUE, message = "Correct — three rows, two columns.")
} else if (!is.data.frame(.result)) {
  list(correct = FALSE, message = "That is not a table yet. Use tibble() with two named columns.")
} else if (ncol(.result) != 2) {
  list(correct = FALSE, message = "You need exactly two columns: station and marks.")
} else {
  list(correct = FALSE, message = "Check the spelling and order of the station names.")
}
```
````

- **Exercise 2** (5 min): from the `students` tibble, pull the `attendance`
  column and take its mean. Expected `79.75`. Check with
  `isTRUE(all.equal(.result, 79.75))`.

`## Next` footer:

```markdown
## Next

→ [Primer 3 · Packages and the pipe](primer-03-packages-pipe.qmd) — how to load
the tools, and how to chain them together.
```

- [ ] **Step 2: Render**

Run: `quarto render prelude/primer-02-tibbles.qmd`
Expected: completes without error.

- [ ] **Step 3: Verify in the browser**

At `http://localhost:4321/prelude/primer-02-tibbles.html`:

1. The tibble prints with `# A tibble: 4 × 4` and column type abbreviations.
2. `glimpse()` output shows `$ attendance <dbl>`.
3. Exercise 1: the `tibble()` answer passes; a `data.frame()` answer **also** passes; a one-column answer gives the "exactly two columns" message.
4. Exercise 2: `mean(students$attendance)` → correct.

- [ ] **Step 4: Commit**

```bash
git add prelude/primer-02-tibbles.qmd
git commit -m "feat(primers): add primer 2 on tibbles

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Task 7: Primer 03 — packages and the native pipe

This page carries dplyr (~6.5 MB), because the pipe needs verbs to pipe into.

**⚠️ The one honesty point this page must make** (spec §5): quarto-live installs *and* `library()`-attaches every declared package before the first cell runs. A learner in the browser therefore never needs `library()` — the exact opposite of the habit this page teaches. Say so explicitly. Teaching `library()` without naming that difference would be actively misleading.

**Files:**
- Modify: `prelude/primer-03-packages-pipe.qmd`

**Interfaces:**
- Consumes: the page template from Task 5.
- Produces: `dplyr` is warm in the browser cache, so Task 8's page loads faster.

- [ ] **Step 1: Write the page**

Front matter:

```yaml
---
title: "Primer 3 · Packages and the native pipe"
subtitle: "Loading the tools, and chaining them together"
format: live-html
engine: knitr
webr:
  packages:
    - dplyr
---
```

Update the fallback callout's size figure to "about 20 MB on first load".

Content requirements:

- The browser/RStudio difference, as a callout, immediately after the orientation:

````markdown
::: {.callout-warning title="One way this browser lies to you"}
This page has already loaded `dplyr` for you before you ran anything. Your own
RStudio will not. There, every script starts with its `library()` calls, and a
script that forgets them fails with `could not find function`.

So the `library(dplyr)` line below is a no-op here and essential there. Type it
anyway — it is the habit that matters.
:::
````

- Worked example: `library(dplyr)`, then the install-once/load-every-session rule.
- A `callout-warning` reproducing `r-primer.qmd`'s point that `install.packages()`
  belongs in the console, never in a script.
- The pipe, taught as the two-line comparison from `r-primer.qmd` lines 138–142:

````markdown
```{webr}
round(mean(c(72, 68, 81, 90)), 1)

c(72, 68, 81, 90) |> mean() |> round(1)
```
````

- Prose: the second reads left to right, in the order the work happens. Once an
  analysis is six steps long, the pipe is the difference between readable and
  unreadable. Note that `%>%` appears in older code and does the same thing here,
  but we use `|>` because it needs no package.
- **Exercise 1** (5 min): rewrite `round(sqrt(mean(c(16, 25, 36, 49))), 2)` using
  `|>`. Expected `5.61`. Check accepts any answer equal to `5.61` **and** requires
  the pipe in `.user_code`:

````markdown
```{webr}
#| exercise: ex_pipe
#| check: true
used_pipe <- grepl("|>", .user_code, fixed = TRUE)
right_answer <- isTRUE(all.equal(as.numeric(.result), 5.61))
if (right_answer && used_pipe) {
  list(correct = TRUE, message = "Correct — and it reads left to right.")
} else if (right_answer) {
  list(correct = FALSE, message = "Right answer, but rewrite it with |> so it reads in the order the work happens.")
} else if (grepl("%>%", .user_code, fixed = TRUE)) {
  list(correct = FALSE, message = "Use the native pipe |>, not %>%. We use |> throughout this workshop.")
} else {
  list(correct = FALSE, message = "Start with the vector, then pipe into mean(), then sqrt(), then round(2).")
}
```
````

This is the **only** check permitted to inspect `.user_code`, because the pipe
is the thing being taught and the value alone cannot prove it was used.

- **Exercise 2** (5 min): pipe the `starwars`-free equivalent — take
  `c(88, 72, 95, 64)`, pipe into `mean()`, then `round(1)`. Expected `79.8`.
  Check on value only.

`## Next` → `[Primer 4 · The five dplyr verbs](primer-04-dplyr-verbs.qmd) — the
verbs that do almost all of the work.`

- [ ] **Step 2: Render and verify**

Run: `quarto render prelude/primer-03-packages-pipe.qmd`

At `http://localhost:4321/prelude/primer-03-packages-pipe.html`:

1. Both pipe forms print `77.8`.
2. Exercise 1: the `|>` answer passes; the nested `round(sqrt(mean(...)), 2)` answer gives the "rewrite it with |>" message; a `%>%` answer gives the "use the native pipe" message.
3. devtools Network shows requests to `repo.r-wasm.org` for the dplyr closure.

- [ ] **Step 3: Commit**

```bash
git add prelude/primer-03-packages-pipe.qmd
git commit -m "feat(primers): add primer 3 on packages and the native pipe

Names the browser/RStudio library() difference explicitly.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Task 8: Primer 04 — the five dplyr verbs

**First page to read a file from the WebAssembly virtual filesystem.** If the `resources:` mechanism is going to fail, it fails here.

**Files:**
- Modify: `prelude/primer-04-dplyr-verbs.qmd`

**Interfaces:**
- Consumes: the page template (Task 5); `data/meded_students.csv`, already published by the existing `resources: data/**` in `_quarto.yml:14-19`.
- Produces: the verified `webr: resources:` idiom that Task 9 reuses.

- [ ] **Step 1: Confirm the dataset exists**

```bash
Rscript R/00_generate_datasets.R
Rscript -e "d <- readr::read_csv('data/meded_students.csv', show_col_types = FALSE); cat(nrow(d), ncol(d), '\n')"
```

Expected: `240 17`

- [ ] **Step 2: Write the page**

Front matter. The project already publishes `data/**` (see `_quarto.yml:14-19`), so no page-level `resources:` key is needed — only `webr: resources:`, which pulls the file into the virtual filesystem.

```yaml
---
title: "Primer 4 · The five dplyr verbs"
subtitle: "Almost all data work is these five"
format: live-html
engine: knitr
webr:
  packages:
    - dplyr
    - readr
  resources:
    - ../data/meded_students.csv
---
```

**⚠️ This path is the single most uncertain thing in the plan.** The page lives at `/prelude/`, but the CSV is published at the site root as `/data/meded_students.csv`. quarto-live resolves `webr: resources:` entries relative to the page, hence `../data/`. What is **not** documented is where that file then lands inside the virtual filesystem — it may preserve the `../data/` structure, flatten to the working directory, or land at `data/`. Step 3 below discovers this empirically **before** any read path is written. Do not guess it.

Update the fallback callout size figure to "about 22 MB on first load".

Content requirements:

- Orientation naming the payoff: this is the real cohort used on Day 1, so the 11:15 session will not be the first time they see it.
- Worked example reading the file. **Use whichever path Step 3 discovers** — the form below assumes it lands at `data/`, which preserves symmetry with Day 1 and is the outcome to prefer if achievable:

````markdown
```{webr}
library(dplyr)
library(readr)

students <- read_csv("data/meded_students.csv", show_col_types = FALSE)

glimpse(students)
```
````

If Step 3 shows the file lands elsewhere, the cleanest fix is a one-line
relocation in a `#| setup: true` cell rather than teaching a strange path:

````markdown
```{webr}
#| setup: true
dir.create("data", showWarnings = FALSE)
file.copy("meded_students.csv", "data/meded_students.csv")
```
````

Prefer this over writing `read_csv("meded_students.csv")` in the visible cell —
the path participants see must match the one they will type on Day 1.

- One worked cell per verb, in order — `filter()`, `select()`, `arrange()`,
  `mutate()`, `summarise()` — each a single idea, each on `students`. Use
  `group_by()` only inside the `summarise()` example.
- A pipeline cell chaining three verbs with `|>`, to pay off Primer 3.
- **Exercise 1** (5 min): filter to the 2024 batch with attendance above 85%.
  Check on `nrow()` and on the set of `student_id` values, so column order does
  not matter:

````markdown
```{webr}
#| exercise: ex_filter
#| check: true
expected_ids <- students |>
  dplyr::filter(batch == "2024", attendance_pct > 85) |>
  dplyr::pull(student_id) |>
  sort()
if (!is.data.frame(.result)) {
  list(correct = FALSE, message = "filter() returns a table. Did you pipe into it?")
} else if (identical(sort(.result$student_id), expected_ids)) {
  list(correct = TRUE, message = "Correct.")
} else {
  list(correct = FALSE, message = "Check both conditions: batch == \"2024\" AND attendance_pct > 85.")
}
```
````

- **Exercise 2** (10 min): mean `posttest` by `teaching_arm`, with a count.
  The dataset has 11 missing `posttest` values by design, so the check must
  handle `na.rm`. Include the teaching point in the correct-message: without
  `na.rm = TRUE` the answer is `NA`.
- **Exercise 3** (10 min, stretch): count students per `college`, arranged
  commonest first.

`## Next` → `[Primer 5 · Your first plot](primer-05-first-plot.qmd) — turn that
table into a picture.`

- [ ] **Step 3: Discover the virtual filesystem path BEFORE writing read paths**

Render and serve, then add a temporary cell at the top of the page:

````markdown
```{webr}
list.files(recursive = TRUE)
getwd()
```
````

Load `http://localhost:4321/prelude/primer-04-dplyr-verbs.html` and read the
output. **Record the exact path the CSV appears at.** Everything else in this
task depends on it.

- If it prints `data/meded_students.csv` — use that path directly, done.
- If it prints `meded_students.csv` at the root — add the `#| setup: true` relocation cell from Step 2.
- If it prints nothing, the resource was not fetched: check the browser Network tab for a 404 on the CSV, and correct the `webr: resources:` path.

Delete the temporary cell once the path is known.

- [ ] **Step 4: Verify the page**

At `http://localhost:4321/prelude/primer-04-dplyr-verbs.html`:

1. **`read_csv("data/meded_students.csv")` succeeds** — `glimpse()` shows `Rows: 240`, `Columns: 17`.
2. Each verb example runs.
3. Exercise 1 passes with the intended answer and gives the "check both conditions" message for a one-condition answer.
4. Exercise 2 without `na.rm = TRUE` returns `NA`, and the check message explains why.

- [ ] **Step 5: Commit**

```bash
git add prelude/primer-04-dplyr-verbs.qmd
git commit -m "feat(primers): add primer 4 on the five dplyr verbs

First page to load a CSV into the WebAssembly virtual filesystem.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Task 9: Primer 05 — your first plot

The page that pays off known issue #2: a participant arriving at Day 1 11:15 has already run `ggplot()`. Heaviest page (~16 MB of ggplot2), so it is deliberately last.

**Files:**
- Modify: `prelude/primer-05-first-plot.qmd`

**Interfaces:**
- Consumes: the page template (Task 5); the verified `webr: resources:` idiom (Task 8).

- [ ] **Step 1: Write the page**

Front matter:

```yaml
---
title: "Primer 5 · Your first plot"
subtitle: "The grammar of graphics, in three lines"
format: live-html
engine: knitr
webr:
  packages:
    - ggplot2
    - readr
  resources:
    - ../data/meded_students.csv
---
```

Use the **same resource path and the same read path Task 8 established**. Do not re-derive them; if Task 8 needed the `#| setup: true` relocation cell, this page needs it too.

Update the fallback callout size figure to "about 30 MB on first load", and add: *"This is the heaviest primer. If you are on a slow connection, do this one at home rather than at the venue."*

Content requirements:

- Orientation: Day 1 opens with visualisation at 11:15. After this page that
  will not be the first `ggplot()` call you have ever written.
- The three-part grammar, built up one cell at a time so each addition is
  visible: data → `aes()` → `geom_`.

````markdown
```{webr}
library(ggplot2)
library(readr)

students <- read_csv("data/meded_students.csv", show_col_types = FALSE)

ggplot(students, aes(x = attendance_pct)) +
  geom_histogram(binwidth = 5)
```
````

- Prose: `+` not `|>` here, and say why plainly — ggplot2 predates the pipe and
  builds a plot by adding layers. This trips up every beginner exactly once.
- A second cell varying `binwidth` from 2 to 10, with the instruction to change
  it and rerun.
- A boxplot by `teaching_arm` using the brand palette:

````markdown
```{webr}
ggplot(students, aes(x = teaching_arm, y = burnout_score, fill = teaching_arm)) +
  geom_boxplot() +
  scale_fill_manual(values = c("Flipped classroom" = "#0f5257",
                               "Traditional lecture" = "#b8860b")) +
  labs(x = NULL, y = "Burnout score", fill = NULL)
```
````

- **Exercise 1** (10 min): histogram of `pretest`, with `labs()` giving a title
  and axis labels. Check verifies the object is a ggplot with the right mapping
  and geom — never compare rendered images:

````markdown
```{webr}
#| exercise: ex_hist
#| check: true
if (!inherits(.result, "ggplot")) {
  list(correct = FALSE, message = "That did not produce a plot. Start with ggplot(students, aes(...)).")
} else if (!identical(rlang::as_label(.result$mapping$x), "pretest")) {
  list(correct = FALSE, message = "Map pretest to x inside aes().")
} else if (!any(vapply(.result$layers, function(l) inherits(l$geom, "GeomBar"), logical(1)))) {
  list(correct = FALSE, message = "Add geom_histogram() to draw the bars.")
} else if (is.null(.result$labels$title)) {
  list(correct = FALSE, message = "Nearly. Add labs(title = ...) so the plot explains itself.")
} else {
  list(correct = TRUE, message = "Correct — and it has a title, which most published figures do not.")
}
```
````

Note `geom_histogram()` uses `GeomBar`, not a `GeomHistogram` class — checking
for the wrong class is the easy mistake here.

- **Exercise 2** (10 min): scatter of `study_hours` against `gain`, coloured by
  `rural_background`. Same checking pattern, testing `x`, `y` and `colour`
  mappings and a `GeomPoint` layer.

`## Next` footer, pointing back out to the workshop proper:

```markdown
## Next

→ [Datasets](data.qmd) — download the files, ready for Day 1.

You have now written R, built a table and drawn a plot without installing
anything. Day 1 does all of this again, on your own machine, with the project
structure that makes it reproducible.
```

- [ ] **Step 2: Render and verify**

Run: `quarto render prelude/primer-05-first-plot.qmd`

At `http://localhost:4321/prelude/primer-05-first-plot.html`:

1. The histogram renders as an image, not an error. Fonts may differ from your desktop R — expected, not a bug (spec §12).
2. The boxplot shows both brand colours.
3. Exercise 1: a correct answer without `labs(title=)` gives the "Nearly" message; with it, correct. A `geom_point()` answer gives the "add geom_histogram()" message.
4. Exercise 2 passes with the intended answer.

- [ ] **Step 3: Commit**

```bash
git add prelude/primer-05-first-plot.qmd
git commit -m "feat(primers): add primer 5 on ggplot2

Directly mitigates the schedule risk of teaching ggplot2 before R
fundamentals on Day 1.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Task 10: Cross-link the primers into the site

Five pages nobody can find are worth nothing. `prelude/r-primer.qmd` must stay **unmodified** (spec decision 4), so entry points go elsewhere.

**Files:**
- Modify: `prelude/index.qmd` (checklist and timings)

**Interfaces:**
- Consumes: all five primer pages.

- [ ] **Step 1: Read the current checklist**

Run: `cat prelude/index.qmd`

Identify the checklist table and the "≈ 2 hours" time budget block described in the survey.

- [ ] **Step 2: Add the primers as a checklist row**

Add a row to the existing checklist table offering the primers as an
alternative to the static primer, worded so neither is presented as mandatory:

```markdown
| Work through the [interactive primers](primer-01-objects.qmd) | 45 min | Runs in your browser — no install needed, so you can start today |
```

Match the existing table's exact column count and header names — read them first, do not assume.

- [ ] **Step 3: Add the pre-travel note**

Add, near the checklist:

```markdown
::: {.callout-tip title="Do the interactive primers before you travel"}
They download about 30 MB the first time. Your browser keeps that for a week,
so opening them at home makes them instant at the venue — and conference wifi
shared by forty people is not the moment to find out.
:::
```

- [ ] **Step 4: Render and verify links**

```bash
quarto render
```

Then check every new link resolves:

```bash
Rscript -e "
h <- readLines('_site/prelude/index.html', warn = FALSE) |> paste(collapse = '')
m <- regmatches(h, gregexpr('primer-0[0-9-a-z]*\\\\.html', h))[[1]]
for (f in unique(m)) cat(f, file.exists(file.path('_site/prelude', f)), '\n')
"
```

Expected: every listed file reports `TRUE`.

- [ ] **Step 5: Commit**

```bash
git add prelude/index.qmd
git commit -m "docs(prelude): link the interactive primers from the checklist

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Task 11: Full-site verification

Everything so far was verified page by page. This task verifies the whole thing, including that the existing 24 pages are genuinely untouched.

**Files:**
- Create: `docs/webr-verification-2026-08.md` (the record of what was measured)

- [ ] **Step 1: Clean full render**

```bash
rm -rf _site _freeze .quarto
Rscript R/00_generate_datasets.R
quarto render
```

Expected: completes. Count pages:

```bash
find _site -name "*.html" | wc -l
```

Expected: **40** — the 35 from before, plus five primers.

- [ ] **Step 2: Confirm existing pages still render correctly**

Spot-check three pages that were fine before and must be unchanged in kind:

```bash
Rscript -e "
for (f in c('_site/day1/s3-ggplot2.html', '_site/day2/s7-gtsummary.html', '_site/prelude/r-primer.html')) {
  cat(f, file.exists(f), file.size(f), '\n')
}
"
```

Expected: all `TRUE`, all non-trivial sizes. `r-primer.html` must NOT contain the string `webr` — it is still a static page.

- [ ] **Step 3: Measure the real cold-cache payload**

For each primer, with devtools open and **cache disabled**, hard-reload and record total transferred bytes. Fill in this table in `docs/webr-verification-2026-08.md`:

| Page | Transferred (cold) | Time to first Run | Notes |
|---|---|---|---|
| primer-01 | | | expect ~13 MB, no repo.r-wasm.org hits |
| primer-02 | | | |
| primer-03 | | | expect dplyr closure |
| primer-04 | | | |
| primer-05 | | | expect ggplot2, heaviest |

If any page is materially above the spec §4 estimate, record the actual number
and revise the spec — the estimates come from published sizes, and this is the
measurement that supersedes them.

- [ ] **Step 4: Cross-browser check**

Load all five primers and run at least one cell on each of:

- Chrome (desktop)
- Safari — untested by the research; this is where an unknown would surface
- One Windows laptop, since that is what most participants bring

Record pass/fail per browser in the verification doc. Note any font differences in Primer 05 plots.

- [ ] **Step 5: Verify the offline fallback**

Block `webr.r-wasm.org` (devtools request blocking, or an `/etc/hosts` entry) and reload Primer 01.

Expected: the page still renders, the fallback callout is visible, and its link to `r-primer.qmd` works. The page must degrade to readable, not to a blank screen.

- [ ] **Step 6: Commit**

```bash
git add docs/webr-verification-2026-08.md
git commit -m "docs: record WebR payload and cross-browser verification

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Task 12: Update project documentation

**Files:**
- Modify: `CLAUDE.md`
- Modify: `README.md`

- [ ] **Step 1: Record the house-style exception in `CLAUDE.md`**

Under the "Non-negotiables" section, amend the exercises line:

```markdown
- Exercises in `callout-note`, solutions in `callout-tip collapse="true"`.
  **Exception:** the interactive primers (`prelude/primer-0*.qmd`) keep the
  `callout-note` exercise but use quarto-live's native hint/solution buttons,
  because the checker and a collapsed callout would mean maintaining every
  answer twice. See `docs/superpowers/specs/2026-08-03-webr-r-primers-design.md` §6.
```

- [ ] **Step 2: Update the known-issues list in `CLAUDE.md`**

Known issue #1 (the `workshop_intro.html` date) was fixed by patching the
generated HTML — but its source `.qmd` does not exist in the repo, so rewrite
that entry to state the real problem:

```markdown
1. `slides/workshop_intro.html` is a generated artefact with **no source
   `.qmd` anywhere in the repo**. Its wrong date (2026-06-18) was patched
   directly in the HTML on 2026-08-03; that patch is lost if the deck is ever
   regenerated. Recover the source or re-author the deck.
```

Amend known issue #2 to note the new mitigation:

```markdown
2. Day 1 teaches ggplot2 (11:15) before any R fundamentals... Mitigated by the
   Prelude R primer, the interactive WebR primers (which let participants run
   `ggplot()` before Day 1 without installing anything), and a 10-minute
   project demo opening Session 2 — but the schedule itself is unchanged.
```

- [ ] **Step 3: Add a build note to `CLAUDE.md`**

Under `## Build`:

```markdown
The interactive primers need the quarto-live extension, which is committed
under `_extensions/`. If it is ever missing:

    quarto add r-wasm/quarto-live@v0.2.0

They render through a second `live-html` format defined in `_quarto.yml`.
Never open a rendered primer via `file://` — the WebAssembly worker is blocked.
Use `quarto preview`.
```

- [ ] **Step 4: Add the primers to `README.md`**

Add a short section describing what the primers are and that they need no
install. Do **not** touch the `SET-TEAM` placeholders — those are still the
user's to resolve.

- [ ] **Step 5: Commit**

```bash
git add CLAUDE.md README.md
git commit -m "docs: record primer conventions, build notes and known issues

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Task 13: Package the approach as a reusable skill

Spec §13. Build this **last**, from what the earlier tasks actually proved, not from what this plan assumed. Where a spike or measurement contradicted an expectation, the skill records the real answer.

**REQUIRED SUB-SKILL:** Use `superpowers:writing-skills` for structure, frontmatter and verification.

**Files:**
- Create: `~/.claude/skills/webr-workshop/SKILL.md`
- Create: `~/.claude/skills/webr-workshop/references/setup.md`
- Create: `~/.claude/skills/webr-workshop/references/exercises.md`
- Create: `~/.claude/skills/webr-workshop/references/payload.md`
- Create: `~/.claude/skills/webr-workshop/references/troubleshooting.md`

**Interfaces:**
- Consumes: every lesson from Tasks 3–11, especially the Task 3 spike result and the Task 11 measurements.

- [ ] **Step 1: Invoke the writing-skills skill**

Do not hand-roll the frontmatter or directory shape.

- [ ] **Step 2: Write `SKILL.md` — the always-loaded layer, kept short**

Progressive disclosure means `SKILL.md` carries only what is needed to decide
*whether* and *roughly how*, deferring detail to `references/` loaded on demand.
It must cover:

- **When to reach for WebR** — teaching R to people who have not installed it; pre-workshop primers; anything a learner does before the toolchain works.
- **When NOT to** — pages teaching projects, file paths, `.Rproj`, rendering, or anything about the local toolchain. WebR has no project and a filesystem learners cannot inspect, so using it there contradicts what you are teaching.
- The four load-bearing facts, stated flatly: GitHub Pages needs no COOP/COEP; use `r-wasm/quarto-live`, not `coatless/quarto-webr`; never use gradethis; nothing survives page navigation.
- A pointer to each reference file with a one-line description of when to read it.

- [ ] **Step 3: Write `references/setup.md`**

Extension install, the `live-html` format block, the `_knitr.qmd` include and
its relative-path trap, the `webr: packages:` and `webr: resources:` keys, and
the `file://` gotcha. Include the working `_quarto.yml` block from Task 3.

- [ ] **Step 4: Write `references/exercises.md`**

The exercise/hint/solution/check pattern with real code. The check-block
environment variables (`.result`, `.user_code`, `.solution_code`, `.label`).
The rules that emerged from Tasks 5–9:

- Compare **values**, never rendered output or code text — except where the syntax itself is the lesson (the pipe), and say so.
- Accept every correct answer, not just the intended one.
- Make wrong-answer messages diagnostic, not just "incorrect".
- For ggplot objects, inspect `$mapping` and `$layers`; note that `geom_histogram()` produces a `GeomBar` layer.

- [ ] **Step 5: Write `references/payload.md`**

Per-package measured sizes, the per-document `packages:` principle, the 7-day
cache and the "open it before you travel" advice, and the arithmetic for
estimating a cohort's total venue bandwidth. Use the **Task 11 measured
numbers**, not the published estimates.

- [ ] **Step 6: Write `references/troubleshooting.md`**

Every failure actually hit during Tasks 3–11, with its fix. At minimum: cells
never becoming ready; `read_csv()` not finding a resourced file; no interrupt
on the PostMessage channel; font differences in plots; the `_extension.yml`
version misreport.

- [ ] **Step 7: Verify the skill loads**

Run `/webr-workshop` (or invoke via the Skill tool) in a fresh session and
confirm `SKILL.md` loads and its reference pointers resolve.

- [ ] **Step 8: Commit**

```bash
git add ~/.claude/skills/webr-workshop
git commit -m "feat: add reusable webr-workshop skill

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

Note: if `~/.claude/skills/` is outside this repository, commit it wherever the
user's skills are version-controlled, or skip the commit and tell them the
files are in place.

---

## Notes for the implementer

**Tasks 6–9 build on the page template defined in full in Task 5.** Read Task 5's
complete page source before starting any of them — the fallback callout,
front-matter shape, worked-example-then-exercise rhythm and `## Next` footer are
written out once there and referenced, not repeated. Tasks 6–9 give verbatim only
what *differs*: front matter, worked examples and check blocks.

**Deliberately out of scope — do not "helpfully" fix these:**

- `{{PRETEST_URL}}` in `admin/invitation-email.md:24` and `admin/reminder-email.md:39` has no target. Since no data is being collected, those lines either go or point at something built separately — a workshop-lead decision (spec §9). Leave them.
- The `SET-TEAM` placeholders in `_quarto.yml`, `README.md` and `resources/index.qmd`.
- `admin/agenda.pdf`, linked from `schedule.qmd` and not yet created.
- Known issues #2 and #3 in `CLAUDE.md` are flagged for the workshop lead. Task 12 amends their *wording* only; it does not rework the schedule.

**This is a Quarto site, not an application.** There is no unit-test framework
and adding one is out of scope. "Write the failing test first" becomes: state
the expected browser behaviour, confirm it does not yet hold, implement, then
confirm it does. Every verification step above names what to look at and what
it should say.

**You cannot verify a primer without a browser.** Rendering proves the Quarto
syntax parsed; it proves nothing about whether R actually ran. A page can
render perfectly and be completely broken. Always serve over HTTP and load it.

**Never open a rendered primer via `file://`.** The WebAssembly worker is
blocked and you will misdiagnose a working page as broken.

**If the Task 3 spike shows cells cannot live inside callout divs**, stop and
revise the page template before writing Tasks 5–9. Do not work around it five
times.
