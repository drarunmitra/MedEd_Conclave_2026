# WebR interactive primers — full-site verification record

**Date:** 2026-08-07
**Branch:** `feat/webr-primers`
**Baseline compared against:** `c8ed2df` ("chore: initial commit of MedEd Conclave 2026 workshop site")
**Quarto:** 1.9.36 **R (local render):** 4.4.1
**webR:** v0.6.0, which ships **R 4.6.0 (2026-04-24)** — confirmed by running
`R.version.string` in a live cell, not assumed.

This is the whole-site check. Each primer was verified individually as it was
built; the purpose here is to confirm the five new pages did not disturb the
35 pages that already existed, and to replace the estimated download figures
with measured ones.

---

## 1. Clean render from scratch

```bash
rm -rf _site _freeze .quarto
Rscript R/00_generate_datasets.R
quarto render
```

Exit code 0.

| Check | Result |
|---|---|
| HTML files in `_site` | **40** (35 baseline + 5 primers) — as expected |
| New files vs baseline | exactly the five `prelude/primer-0*.html` |
| Missing files vs baseline | none |
| Warnings | **1**, listed below |

The complete warning output of the render was a single line:

```
WARNING (…/share/filters/main.lua:9924) Unable to parse table from raw html
block: skipping.
```

It is emitted while rendering `day2/s7-gtsummary.qmd`. **The identical warning
is emitted by the baseline commit at the same point**, so it is pre-existing
and unrelated to this work. No new warnings were introduced.

> Note for whoever renders next: an interrupted `quarto render` leaves
> generated `.html` files and a `site_libs/` tree beside the sources, and
> `.gitignore` covers neither. `git clean -fd` clears it. Worth adding
> `/site_libs/` and the stray root-level `*.html` to `.gitignore`.

---

## 2. Proof the 35 pre-existing pages are unharmed

The baseline commit was extracted to a scratch directory, its datasets
regenerated, and rendered with the same Quarto version. Every baseline page
was then compared byte-for-byte with the current render.

**Whole-file comparison — 35/35 baseline filenames present.** Of those:

| Outcome | Count | Explanation |
|---|---|---|
| Byte-identical | 2 | `slides/workshop_intro.html`, `speaker-view.html` (static assets) |
| Differ by exactly 2 lines | 26 | the Bootstrap / Reveal theme filename hash only |
| Differ by more | 7 | 6 `prelude/*` (new sidebar entries) + `s7-gtsummary` (see below) |

The 2-line difference is the compiled stylesheet's content hash, which changed
because `styles.scss` and `slides/custom.scss` gained the ligature rule:

```
- bootstrap-6b0feb3e3c88299e16838f59eb26672a.min.css
+ bootstrap-a7f727fa8503a6eae620d9a8996881bf.min.css
```

**Article-body comparison** (the `<main>` element, i.e. everything except
chrome and navigation) is the stronger test. 23 of the 25 content pages have a
**byte-identical body**. The two that differ:

- `day2/s7-gtsummary.html` — differs only in `gt`'s randomly generated table
  element IDs (`#bwzceygqip` → `#jdbprxthwr`). After normalising those IDs the
  diff is empty. `gt` regenerates these on every render; the baseline differs
  from itself between renders in the same way. Not a regression.
- `prelude/index.html` — the one intended content change (checklist row plus
  the pre-travel callout), +1236 bytes.

### `prelude/r-primer.html` — scrutinised specifically

| Check | Result |
|---|---|
| `prelude/r-primer.qmd` blob SHA vs baseline | `45f29ee…` = `45f29ee…` — **byte-identical source** |
| Rendered `<main>` body vs baseline | **byte-identical** (26,642 bytes, same MD5) |
| Occurrences of the string `webr` in the rendered page | **0** — still a purely static page |
| Whole-file delta | +2,065 bytes, entirely sidebar `<li>` entries for the five primers, plus the "next page" pagination target moving from `data.html` to `primer-01-objects.html` |

The page itself is untouched; only the navigation furniture Quarto generates
around it reflects the new sidebar section.

---

## 3. Ligature fix

`|>` must render as two characters. The rule is applied by disabling the
OpenType feature, which is font-independent.

| Target | Rule present in compiled CSS? |
|---|---|
| Website theme (`bootstrap-a7f727fa….min.css`) | yes — `code,pre,kbd,samp,div.sourceCode,.cm-editor,.cm-content,.cm-line{font-variant-ligatures:none;font-feature-settings:"liga" 0,"clig" 0,"calt" 0}` |
| Reveal.js theme (`quarto-5c2b896c….css`) | yes — same declarations scoped to `.reveal code,.reveal pre,.reveal kbd,.reveal samp` |

Confirmed that the primer pages actually load the theme carrying the rule, and
that the extension's own `live-runtime.css` declares no competing
`font-family` / `font-feature-settings` that could override it.

Verified on the **live, running page** (not just the stylesheet) via computed
style, which is what actually matters for CodeMirror since it injects styles
from JavaScript:

| Selector | `font-variant-ligatures` | `font-feature-settings` |
|---|---|---|
| `.cm-editor` | `none` | `"calt" 0, "clig" 0, "liga" 0` |
| `.cm-content` | `none` | `"calt" 0, "clig" 0, "liga" 0` |
| `.cm-line` | `none` | `"calt" 0, "clig" 0, "liga" 0` |
| `pre`, `code` | `none` | `"calt" 0, "clig" 0, "liga" 0` |

The reveal theme does not target the CodeMirror classes, which is correct —
no slide deck embeds a live editor.

Minor observation, not a fault: CodeMirror sets its own `font-family: monospace`
on `.cm-content`, so the interactive editors use the browser's default
monospace rather than the site's JetBrains Mono / Fira Code stack used by
static code blocks. The ligature rule is what makes this safe, because a
reader's default monospace may itself be a ligature font.

---

## 4. Measured cold-cache payload

### Method, and its limits — read this before quoting the numbers

The webR engine and every R package are fetched **inside a Web Worker**.
Worker traffic is invisible to main-thread `performance.getEntriesByType('resource')`
and, as confirmed here, invisible to the browser-extension network log too:
during a full primer load that log recorded 42 main-thread requests and
**zero** requests to `webr.r-wasm.org` or `repo.r-wasm.org`. Any figure taken
from those APIs would be wrong by an order of magnitude. `transferSize` also
reports `0` on a warm cache, which would look like a free page load.

The figures below were therefore built from two independent sources and
cross-checked against each other:

1. **The package list actually requested.** Captured from the
   `Downloading webR package: …` console lines emitted on a real page load.
2. **Authoritative byte counts.** `Content-Length` fetched directly from
   `https://webr.r-wasm.org/v0.6.0/` and
   `https://repo.r-wasm.org/bin/emscripten/contrib/4.6/`, with the same
   `Accept-Encoding` a browser sends, so these are on-the-wire bytes.

The dependency closure was computed from the repository's own `PACKAGES`
index and **validated against the observed console output**: predicted 10
packages for Primer 1 and 19 for Primer 2, observed exactly 10 and exactly 19,
with identical package names. An independent run under Microsoft Edge
logged 10 / 19 / 24 packages for Primers 1–3, again matching.

*Limit:* these totals cover the engine, the package tarballs and the page's own
assets. If webR lazily fetches small extra VFS fragments at runtime, they are
not counted; the numbers are therefore a tight lower bound, not a ceiling.
They also assume an empty HTTP cache — the second and later primers a
participant opens reuse the engine and any shared packages, so only the first
page pays the 12.5 MB engine cost.

### Engine (constant for all five pages)

| Asset | Wire bytes |
|---|---|
| `R.wasm` | 12,328,048 |
| `R.js` (brotli) | 131,542 |
| `webr-worker.js` (brotli) | 40,417 |
| `webr.mjs` (brotli) | 18,571 |
| **Total** | **12,518,578 B = 12.52 MB** |

This reproduces the 12.51 MB figure recorded earlier in the project, which is
hereby confirmed rather than merely copied.

### Per page

Site assets are gzipped, as GitHub Pages serves them. Package tarballs are
already gzip and do not compress further.

| Page | Pkgs | Site assets | Engine | Packages | **Total (cold)** | Page's own claim |
|---|---|---|---|---|---|---|
| primer-01 | 10 | 0.63 MB | 12.52 MB | 2.98 MB | **16.12 MB** | "about 15 MB" |
| primer-02 | 19 | 0.63 MB | 12.52 MB | 7.02 MB | **20.17 MB** | "about 20 MB" |
| primer-03 | 24 | 0.63 MB | 12.52 MB | 8.65 MB | **21.79 MB** | "about 20 MB" |
| primer-04 | 35 | 0.63 MB | 12.52 MB | 11.72 MB | **24.87 MB** | "about 22 MB" |
| primer-05 | 42 | 0.63 MB | 12.52 MB | 23.34 MB | **36.49 MB** | "about 35 MB" |

Time from page load to a cell actually producing output, measured under Edge
with a fresh profile and an empty cache (see §5 for the full run):

| Page | Time to first Run |
|---|---|
| primer-01 | 21 s |
| primer-02 | 20 s |
| primer-03 | 20 s |
| primer-04 | 31 s |
| primer-05 | 30 s |

These were taken on a fast connection. On the "slow connection" the page
callouts warn about, expect several times this. Observationally under Chrome,
with many tabs open and 10-second polling, the same pages took 40–140 s; that
figure is inflated by the measurement method and by browser load, and the
instrumented Edge numbers above are the ones to trust.

Primer 5's own callout already warns that it is the heaviest and suggests
doing it at home rather than at the venue. That advice is well judged.

**Every page's stated size is within about 13% of the measured value and every
one understates rather than overstates**, which is the safe direction for a
warning. The loosest is Primer 4 (24.87 MB measured against "about 22 MB");
if these strings are ever revised, that is the one to adjust. Note that read
as MiB rather than MB the claims are closer still (Primer 5 measures
34.8 MiB against its stated 35), so the author appears to have worked in MiB.

Correction to the task brief, which expected Primer 1 to make "no
repo.r-wasm.org hits": it makes **ten**. The knitr/evaluate runtime machinery
is not part of the base webR image and is downloaded on every primer,
Primer 1 included.

---

## 5. Cross-browser

All five primers were loaded and **at least one cell was executed on each**.
Clicks were genuine mouse events — the Run Code control is an `<a>`, and a
scripted `.click()` does not trigger it.

| Browser | Version | Result |
|---|---|---|
| Google Chrome | extension-driven, real mouse input | **PASS** — all 5 |
| Microsoft Edge | `Edg/150.0.4078.65`, Puppeteer with real CDP mouse input | **PASS** — all 5, zero page errors |
| Mozilla Firefox | `firefox/153.0.3`, Puppeteer over WebDriver BiDi, headful | **PASS** — all 5, zero page errors |
| Safari | — | **NOT TESTABLE.** Apple withdrew Safari for Windows in 2012; there is no Safari on this machine. The brief asks for it and it remains genuinely unverified — the one coverage gap in this report. |

Both major engines available on Windows pass: Blink (Chrome, Edge) and Gecko
(Firefox). Only WebKit is unverified.

### Microsoft Edge — instrumented run, cold cache

Each page was loaded in a fresh Edge profile, the Run Code control clicked with
a real mouse event, and the resulting output text read back from the DOM.

| Page | Result | Time to output | Packages logged | Output observed |
|---|---|---|---|---|
| primer-01 | PASS | 21 s | 10 | `[1] 240` / `[1] "Community Medicine"` |
| primer-02 | PASS | 20 s | 19 | `# A tibble: 4 × 4` with correct column types |
| primer-03 | PASS | 20 s | 24 | `[1] 2` |
| primer-04 | PASS | 31 s | 32 | `Rows: 240  Columns: 17` |
| primer-05 | PASS | 30 s | 39 | plot image rendered |

No uncaught JavaScript errors on any page. The package counts for Primers 1–3
match the computed closure exactly; Primers 4 and 5 show fewer only because
the run stopped as soon as output appeared, while remaining packages were
still installing.

These instrumented Edge timings are the more reliable "time to first Run"
measurement and supersede the Chrome figures below, which were obtained by
10-second polling on a browser with many tabs open and are inflated by that
measurement overhead.

### Mozilla Firefox — instrumented run, cold cache

Same harness, driving stock Firefox 153.0.3 over WebDriver BiDi. A headless
launch was refused by Puppeteer; headful worked.

| Page | Result | Time to output | Packages logged | Output observed |
|---|---|---|---|---|
| primer-01 | PASS | 31 s | 10 | `[1] 240` / `[1] "Community Medicine"` |
| primer-02 | PASS | 21 s | 19 | `# A tibble: 4 × 4` with correct column types |
| primer-03 | PASS | 21 s | 24 | `[1] 2` |
| primer-04 | PASS | 31 s | 32 | `Rows: 240  Columns: 17` |
| primer-05 | PASS | 31 s | 39 | plot image rendered |

No uncaught JavaScript errors. Gecko produces the same output as Blink,
including the ggplot2 image in Primer 5, and the same package counts again.

The only untested engine is WebKit. If a participant is expected to bring a
Mac or iPad, one manual pass through the five pages would close the gap.

Evidence gathered under Chrome:

| Page | Cell executed | Observed output |
|---|---|---|
| primer-01 | `n_students <- 240; course <- …` | `[1] 240` / `[1] "Community Medicine"` |
| primer-01 | typed live: `R.version.string` | `[1] "R version 4.6.0 (2026-04-24)"` |
| primer-02 | `library(tibble); tibble(…)` | page reached ready state, cells runnable |
| primer-03 | `library(dplyr); n_distinct(…)` | `[1] 2` |
| primer-04 | `read_csv("data/meded_students.csv"); glimpse()` | `Rows: 240  Columns: 17` — the CSV is read correctly from the WebAssembly virtual filesystem |
| primer-05 | `library(ggplot2); ggplot(students)` | the empty grey panel rendered, exactly as the page predicts |

Typing into a CodeMirror editor and re-running worked, so the editors are
genuinely interactive rather than merely displaying code.

Font rendering in Primer 5's plots: the plot device is rendered inside
WebAssembly, so glyphs come from webR's bundled font rather than the host
system. Output is therefore identical across browsers and, unlike an ordinary
R install, will not differ between a participant's laptop and the projector.

---

## 6. Offline / blocked-CDN fallback

Tested by fault injection: `_site` was copied to a scratch directory and the
webR base URL rewritten from `https://webr.r-wasm.org/v0.6.0/` to an
unroutable `.invalid` host, then served over HTTP. This reproduces exactly
what a participant behind a restrictive firewall sees. The repository and its
real `_site` were not modified.

Result for `primer-01-objects.html` with the CDN unreachable:

| Requirement | Result |
|---|---|
| Page still renders | **yes** — navbar, sidebar, table of contents, all prose, all headings |
| Degrades to a blank screen | **no** |
| Degrades to a modal / blocking spinner | **no** — a small "Downloading webR" label sits in the bottom-right corner and the rest of the page is fully usable |
| Fallback callout visible | **yes**, at the top of the page |
| Callout's link to the R primer | **works** — `href` resolves to `prelude/r-primer.html`, which loads and renders |
| Code still readable | **yes** — all 7 CodeMirror editors render with the R code syntax-highlighted, so a blocked participant can still read every example |
| Cells execute | no, correctly — no output blocks are produced |

This is a good failure mode: the reader loses interactivity but loses no
teaching content, and the callout tells them where to go instead.

Two small observations, neither blocking:

- The "Downloading webR" indicator persists indefinitely rather than becoming
  an explicit "could not load" message. The callout pre-empts this in words
  ("If nothing happens after that, your network is probably blocking it"), so
  a reader who reads the callout is not stranded.
- The Run Code controls are greyed visually but carry no `aria-disabled` or
  `disabled` class, so assistive technology gets no signal that they are
  inoperative. Cosmetic accessibility point, inherited from the upstream
  quarto-live extension rather than introduced here.

---

## 7. Link integrity across the whole site

Every internal `href` and `src` in all 40 rendered pages was resolved against
the built site. **1,451 internal references checked.**

| Finding | Verdict |
|---|---|
| `schedule.html` → `admin/agenda.pdf` | **Known and accepted.** The agenda PDF has not been produced yet; it is already on the pre-publication checklist. Present in the baseline too. |
| 4 apparent broken links in `slides/workshop_intro.html` (`${s}`, `${e}`, `${t}`, `'+t+'`) | **False positives.** These are JavaScript template literals inside the minified Reveal.js bundle, not markup. |
| `.qmd` links surviving into the HTML (3, all → `R/report_template.qmd`) | **Intentional.** `R/**` is published as a site resource and the file is present at `_site/R/report_template.qmd`; these are deliberate "download the source" links. |

The identical set of findings — same five, same three — is produced by the
baseline commit. **The five new primer pages introduced 276 additional
internal references and not one of them is broken.**

All five primers appear correctly in `search.json` (60 indexed sections) and
in `sitemap.xml`.

---

## 8. CI workflow change

`.github/workflows/publish.yml` had its `r-lib/actions/setup-renv@v2` step
replaced with `setup-r-dependencies@v2` and an explicit package list. This is
a fix, not a regression: the repository contains no `renv.lock` and no `renv/`
directory, so the previous step could not have succeeded.

The new list was checked against `setup/install_packages.R`. It covers
everything the site needs at render time. It omits the `quarto` R package that
`install_packages.R` installs, but every `quarto::` call in the content sits
in a display-only code block that is never executed, so the build does not
need it.

---

## Summary

| Area | Verdict |
|---|---|
| Clean render, 40 pages | pass |
| 35 pre-existing pages unharmed | pass — 23/25 bodies byte-identical, the rest explained |
| `prelude/r-primer.html` untouched | pass — source and rendered body both byte-identical |
| Ligature fix reaches website and slides | pass — verified in compiled CSS and in live computed style |
| Payload measured | done — figures above supersede the earlier estimates |
| Cross-browser | Chrome, Edge and Firefox all pass; **Safari not testable here** |
| Offline fallback | pass |
| Link integrity | pass — no new broken links |

**No defect was found that blocks publication.** The open items are a coverage
gap and three polish points rather than faults:

1. **Safari is unverified.** Blink and Gecko both pass; WebKit is untested and
   cannot be tested on Windows. Worth one manual pass before the workshop.
2. `admin/agenda.pdf` is still missing and still linked from `schedule.qmd` —
   already a known pre-publication task.
3. Primer 4's stated "about 22 MB" is the loosest of the five size warnings
   against a measured 24.87 MB. Understating is the safe direction, so this is
   a polish item, not a fault.
4. `.gitignore` does not cover `/site_libs/` or generated root-level `*.html`,
   so an interrupted render leaves untracked build debris that could be
   committed by accident.
