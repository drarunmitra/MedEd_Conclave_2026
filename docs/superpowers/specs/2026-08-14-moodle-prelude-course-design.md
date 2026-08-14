# Moodle prelude course — design

**Date:** 2026-08-14
**Author:** Dr Arun Mitra, with Claude Code
**Status:** approved design, artefacts built
**Target:** MedEd Conclave 2026 · R & Reproducible Research workshop, 9–10 September 2026

---

## 1. Problem

The prelude is a seven-item, two-hour checklist on the workshop website
(`prelude/index.qmd`). It has no roster, no deadlines, no reminders and no
evidence of completion. Three consequences:

1. **`{{PRETEST_URL}}` has no target.** It appears in
   `admin/invitation-email.md:24` and `admin/reminder-email.md:39` and was left
   as an open item in `2026-08-03-webr-r-primers-design.md` §9.
2. **Readiness is invisible until Day 1 morning.** `prelude/check-setup.qmd`
   asks participants to email the whole setup-check output to the SET Team if
   it fails; nothing collects it from the people whose run succeeded, and
   nothing shows who never ran it. `CLAUDE.md` known issue #2 and the site's own
   copy both concede that installation problems can eat half of Day 1.
3. **Engagement with the primers is unmeasurable by design.** The WebR primers
   deliberately collect nothing (`…webr-r-primers-design.md` §9, decision 12).
   That is the right privacy call and it leaves the faculty with no signal at all.

## 2. Goals and non-goals

**Goals**

- A Moodle course, open to the selected cohort from 17 August, that owns the
  roster, the calendar, the reminders and the readiness evidence.
- One durable target for `{{PRETEST_URL}}`.
- A low-stakes engagement signal for each of the five primers.
- Zero duplication of content: the Quarto site stays the single source of truth.

**Non-goals**

- Replacing or mirroring the website. Moodle carries instructions and links, not
  teaching material.
- Running R inside Moodle. R runs where it already runs: in the browser on the
  primer pages, and in RStudio on the participant's laptop.
- Post-workshop material, live-days companion, certificates, gating, LTI/SCORM
  or grade passback. Each is a separate decision.
- Any change to `_quarto.yml`, the primers, or Day 1/Day 2 pages.

## 3. Decisions

| # | Decision | Rationale |
|---|---|---|
| 1 | Stock activity types only — URL, Page, Quiz, Assignment, Forum, Label | The build is done with **teacher-in-a-course** rights. No site settings, no plugin installs, and no hand-written `<iframe>`: Moodle's editor strips iframes from users without `moodle/site:trustcontent`. |
| 2 | **Primers open in a new tab; nothing is embedded** | Reverses the original iframe idea, on measured evidence. See §5. |
| 3 | Moodle is a thin wrapper | One instruction paragraph per activity, then a link out. No install steps, package lists or checklists are copied into Moodle, so there is nothing to drift. |
| 4 | Five 4-question quizzes, one per primer, plus a 10-question pre-test | The only engagement signal available. Unlimited attempts, immediate feedback, 75% pass, zero weight — mastery, not ranking. |
| 5 | One Assignment collecting the `check_setup.R` output | Turns "email us the whole output" into a per-participant record that can be scanned before Day 1. Graded **None**; this is triage. |
| 6 | Artefacts live in a new root `moodle/` directory, **not** `admin/` | `_quarto.yml:18` publishes `admin/**` as a site resource. Question banks placed there would be served publicly from the site, correct answers included. |
| 7 | Manual enrolment from the confirmed list | The cohort is selected, not open. Self-enrolment with a key is the documented fallback. |
| 8 | Advisory dates, no completion gating | A beginner blocked by a locked section emails the SET Team instead of fixing their install. Weekly targets are stated in prose and in the Moodle calendar. |
| 9 | Per-distractor feedback on every wrong answer | Held to the standard the primer checks already meet: name the specific misconception rather than saying "Incorrect". |

## 4. Architecture

```
Moodle course                     Quarto site (unchanged)
─────────────────────────────     ────────────────────────────────
roster, calendar, reminders   →   prelude/install.html
completion report                 prelude/check-setup.html
pre-test quiz                     prelude/r-primer.html
5 × primer quiz               →   prelude/primer-0N-*.html   (R runs here)
setup-check Assignment            prelude/data.html
help-desk forum                   prelude/pre-reading.html
                                  resources/*.html
```

Every Moodle URL resource points at `{{SITE_URL}}/…`, matching the `.html`
convention already used in `admin/reminder-email.md:16`.

### Course structure

Topics format, all sections visible from 17 August. Course closes to students
23:59 Tue 8 September; the site outlives it.

| Section | Target | Contents |
|---|---|---|
| 0 · Start here | — | Label, orientation Page, URL → site home, **Pre-test quiz**, Announcements forum |
| 1 · Get your laptop ready | Sun 23 Aug | URL → install, URL → check-setup, **Assignment**, Help-desk forum |
| 2 · Learn just enough R | Sun 30 Aug | Label (choose your track), URL → r-primer, 5 × (URL → primer + its quiz) |
| 3 · Data and reading | Sun 6 Sep | URL → datasets, URL → pre-reading, URL → intro deck, logistics Page |
| 4 · Reference | always | URL → troubleshooting, cheatsheet, glossary; Label → help desk |

Operational detail — every activity name, setting and description string — is in
`moodle/course-blueprint.md` and `moodle/activity-text.md`.

## 5. Why not iframes

The original request was to embed primer pages so code chunks run inside Moodle.
Two costs, both grounded in `docs/webr-verification-2026-08.md`:

- **The payload is charged twice.** Measured cold-cache cost is 16.12 MB
  (primer 01) to 36.49 MB (primer 05), of which 12.52 MB is the webR engine.
  Chrome, Firefox and Safari all partition the HTTP cache by top-level site, so
  a primer loaded inside Moodle sits in a different cache partition from the
  same primer opened directly. `prelude/index.qmd` promises participants that
  opening the primers at home makes them "instant at the venue"; embedding
  voids that promise for anyone who then opens them through Moodle.
- **Saved typing breaks.** The primers set `persist: true`, which writes editor
  contents to `localStorage`. In a third-party frame that storage is
  partitioned (Chrome) or blocked outright (Safari ITP). Safari is already the
  one unverified browser — `CLAUDE.md` known issue #4.

A `URL` resource with "open in new window" keeps the primer top-level: full
width, its own cache, working persistence, and the fallback callout intact.
Moodle still records completion through "student must view this activity", which
is all the tracking an embed would have given either way.

**Status of the cache claim.** Cache partitioning by top-level site is
documented browser behaviour, but it has *not* been measured on this site.
`moodle/README.md` carries it as a verification step. If an embedded primer
turns out to reuse the direct-visit cache, decision 2 is over-cautious and
embedding becomes a supported option; the persistence objection stands either
way.

## 6. Question banks

Six Moodle XML files, 30 questions, one category each under
`$course$/top/Prelude/…`.

| File | Questions | Drawn from |
|---|---|---|
| `pretest.xml` | 10 | Reproducibility, R basics, tidy data, NA, verbs, ggplot2 — a baseline across the whole workshop |
| `primer-01-objects.xml` | 4 | `>=` vs `>`, type coercion, `c()` before `mean()`, logical vectors |
| `primer-02-tibbles.xml` | 4 | The tibble header, `<dbl>` vs `<chr>`, `glimpse()`, `$` |
| `primer-03-packages-pipe.xml` | 4 | `library()` vs `install.packages()`, reading a pipeline, what `\|>` does, the browser's pre-attached packages |
| `primer-04-dplyr-verbs.xml` | 4 | Verb choice, `==` vs `=`, `na.rm = TRUE`, `group_by()` + `summarise()` |
| `primer-05-first-plot.xml` | 4 | The empty panel, `+` vs `\|>`, `binwidth`, warning vs error |

Authoring rules: answerable from the primer alone, never requiring R to be run;
native pipe only; British English; health and med-ed framing; synthetic data.
Question text is wrapped in `CDATA` with `<` and `>` written as HTML entities, so
`<-`, `|>` and `>=` survive both the XML parse and the HTML render.

## 7. Failure handling

| Failure | Response |
|---|---|
| Site-wide completion tracking disabled (`enablecompletion`) | Everything still works; the readiness report does not. Fallback recorded in `moodle/README.md`: gradebook plus the Assignment submission list. |
| The `url` module's allowed display options exclude a new-window option | Fall back to Display: In pop-up, which is also top-level. If both are unavailable, ask the Moodle admin — do not switch to embedding. |
| Participant's network blocks webR | Unchanged from the site's own handling: each primer's fallback callout points at `r-primer.qmd`. The Moodle quiz is answerable from that static page too. |
| Participant never opens Moodle | The invitation and reminder emails both carry the course link; the Announcements forum mails all enrolled users. |
| Quiz false negative | Every question has exactly one 100% answer and a distractor-specific message; the student dry run (`README` step 6) checks one wrong answer per question. |

## 8. Risks

| Risk | Severity | Mitigation |
|---|---|---|
| Quiz answers leak because `moodle/` is later moved under `admin/` | High if it happens | Decision 6, recorded here, in `CLAUDE.md` and in `moodle/README.md`. |
| Two places to update if a primer changes | Medium | Only quiz *questions* reference primer content. Activity descriptions are content-free by decision 3. |
| Participants treat the pre-test as an exam | Low | One attempt, zero weight, review options closed, and the description says plainly that it measures the workshop rather than the participant. |
| Moodle instance not identified in time | Medium | Every URL is `{{MOODLE_URL}}` / `{{SITE_URL}}` placeholder-driven, so nothing is blocked on knowing the host. |

## 9. Verification

Full checklist in `moodle/README.md`. Two steps were run here:

1. Every XML file parses, carries exactly one category element, the expected
   question count, exactly one `fraction="100"` answer per multichoice, and a
   non-empty `feedback` on every wrong answer.
2. Every site URL named in the blueprint and activity text resolves against a
   built `_site/`, the method used in `docs/webr-verification-2026-08.md` §7.

Steps 3–7 — preconditions with the Moodle admin, import, the cache measurement,
the student dry run and the readiness report — require the live instance and
belong to the workshop lead.
