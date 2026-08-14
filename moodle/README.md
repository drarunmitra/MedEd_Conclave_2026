# Moodle prelude course — build kit

Everything needed to build the pre-workshop Moodle course by hand, with
**teacher-in-a-course** rights only. Nothing here is uploaded to the website.

| File | What it is |
|---|---|
| `course-blueprint.md` | Section-by-section build order, with every setting that matters |
| `activity-text.md` | The exact name and description text to paste into each activity |
| `announcements.md` | Four dated announcement posts |
| `questions/*.xml` | Six Moodle XML question banks — 30 questions |

Design rationale, and the reasoning behind the choices that look odd (no
iframes, no gating, no grades), is in
`../docs/superpowers/specs/2026-08-14-moodle-prelude-course-design.md`.

---

## ⚠ Do not move this directory under `admin/`

`_quarto.yml:18` publishes `admin/**` as a site resource. Anything in `admin/`
is copied into `_site/` and served publicly from the workshop website. Moving
`questions/*.xml` there would publish the correct answers.

`moodle/` appears in neither the render list nor the resources list, which is
why it is here.

---

## Before you build: three preconditions

Check these with whoever administers the Moodle instance. Each takes a minute
and each can waste an afternoon.

1. **Completion tracking is enabled site-wide** (`enablecompletion`). Without
   it, the course still works but *Reports → Activity completion* — the whole
   point of decisions 4 and 5 — does not exist. **Fallback:** use the gradebook
   for the quizzes and the Assignment's submission list for readiness, and
   accept that you cannot see who has merely *viewed* a primer.
2. **The URL module offers a new-window display option.** Site administration →
   Plugins → Activity modules → URL → `url_displayoptions` must include *Open*
   and/or *In pop-up*. If it offers only *Embed*, ask for one of the others
   rather than switching to embedding — see the design doc §5.
3. **You can enrol users manually.** The cohort is a fixed selected list, so
   manual enrolment from the confirmed-participant spreadsheet is correct.
   **Fallback:** enable Self enrolment with an enrolment key and put the key in
   the invitation email.

---

## Build order

1. Create the course. Format **Topics**, 5 sections, course start **17 August
   2026**, course end **8 September 2026**, "Show gradebook to students" **No**.
2. Rename the sections and paste their summaries — `course-blueprint.md` §1.
3. Import the six question banks — see below.
4. Build sections 0 to 4 in order, top to bottom, from
   `course-blueprint.md` §2–§6, taking every name and description string from
   `activity-text.md`.
5. Enrol the cohort.
6. Post announcement 1. Schedule the other three in your own calendar —
   `announcements.md` gives the dates.
7. Run the verification checklist below **before** the invitation email goes out.

### Importing the question banks

Course → *More* → **Question bank** → **Import**:

- File format: **Moodle XML format**
- Import category: leave as it is — each file names its own category
- Upload one file at a time, in this order:

```
questions/pretest.xml                  10 questions
questions/primer-01-objects.xml         4
questions/primer-02-tibbles.xml         4
questions/primer-03-packages-pipe.xml   4
questions/primer-04-dplyr-verbs.xml     4
questions/primer-05-first-plot.xml      4
                                       30 total
```

Each file creates its own category under `Prelude/`, so the questions file
themselves rather than piling into *Default for …*. After importing, the
question bank should show six categories under `Prelude`.

Then, for each quiz: **Add question → from question bank**, select the whole
category, and set the maximum grade to the number of questions.

---

## Verification checklist

Steps 1 and 2 have been run in the repository. Steps 3 to 7 need the live
instance.

- [x] **1. XML shape.** Every file parses; one category element each; expected
      question count; exactly one `fraction="100"` answer per multichoice; a
      non-empty `<feedback>` on every wrong answer.
- [x] **2. Link integrity.** Every `{{SITE_URL}}` path named in
      `course-blueprint.md` and `activity-text.md` resolves to a real file in a
      built `_site/`.
- [ ] **3. Preconditions.** The three checks above, confirmed with the Moodle
      admin, before you build.
- [ ] **4. Import.** 30 questions across six categories under `Prelude`.
- [ ] **5. Cache measurement — settles an open question.** Open
      `prelude/primer-01-objects.html` directly in a cold browser profile with
      devtools open, and note whether `R.wasm` (12.5 MB) is fetched. Reload:
      it should not be. Now open the same page inside an iframe on any other
      origin and watch again. **If `R.wasm` is re-fetched, the decision not to
      embed is confirmed. If it is not, embedding is cheaper than assumed** —
      record the result in the design doc §5 either way. Note that webR fetches
      inside a Web Worker, so use the Network panel with "disable cache" off and
      watch for the worker's requests; `performance.getEntriesByType('resource')`
      will not show them (see `docs/webr-verification-2026-08.md` §4).
- [ ] **6. Student dry run** on a real test account, not *Switch role to*:
      - every URL resource opens in a new tab and lands on the right page;
      - one primer reaches ready and runs a cell **from the Moodle link**;
      - for each quiz, the intended answer scores 100% **and** one plausible
        wrong answer returns its specific message, not a generic one;
      - the Assignment accepts pasted console text and a PNG screenshot.
- [ ] **7. Readiness report.** With the test account's work done,
      *Reports → Activity completion* shows the expected ticks and the
      Assignment submission list is scannable at cohort size.

---

## Placeholders

Replace these before publishing, exactly as elsewhere in the repo:

| Placeholder | Becomes |
|---|---|
| `{{SITE_URL}}` | The published workshop site, no trailing slash |
| `{{MOODLE_URL}}` | The course's own URL, e.g. `https://…/course/view.php?id=NNN` |
| `{{VENUE}}` | The venue, for the logistics page |
| `{{CONTACT_EMAIL}}` | SET Team address |

`{{MOODLE_URL}}` is new in this work and is also used by
`admin/invitation-email.md` and `admin/reminder-email.md`.
