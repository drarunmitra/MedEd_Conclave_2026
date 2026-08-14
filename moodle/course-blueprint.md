# Course blueprint

Build guide for the MedEd Conclave 2026 prelude course. Names and description
text live in `activity-text.md`; this file is the structure and the settings.

Read `README.md` first — there are three preconditions to check with the Moodle
admin before you start.

---

## §0 Course settings

| Setting | Value |
|---|---|
| Full name | R & Reproducible Research — Prelude |
| Short name | MEDED-R-PRELUDE-2026 |
| Format | **Topics**, 5 sections |
| Course layout | Show all sections on one page |
| Course start date | Mon 17 August 2026, 09:00 |
| Course end date | Tue 8 September 2026, 23:59 |
| Show gradebook to students | **No** — nothing here is a grade |
| Completion tracking | **Yes** |
| Show activity completion conditions | Yes |
| Group mode | No groups (groups are allotted at registration, on the day) |

Everything is visible from day one. **No section and no activity is gated on
completing another.** A beginner blocked by a locked section emails the SET Team
instead of fixing their install, which is the opposite of the point.

Dates below are *targets*, stated in prose and set as the activities' "due" or
"expect completed on" dates so they appear in each participant's Moodle
calendar. Nothing closes early.

---

## §1 Sections

| # | Section name | Target date |
|---|---|---|
| 0 | Start here | — |
| 1 | 1 · Get your laptop ready | Sun 23 August |
| 2 | 2 · Learn just enough R | Sun 30 August |
| 3 | 3 · Data and reading | Sun 6 September |
| 4 | Reference — open all the time | — |

Section summaries are in `activity-text.md` §1.

---

## §2 Section 0 — Start here

| Order | Type | Name | Target / setting |
|---|---|---|---|
| 1 | Label | *(orientation text)* | — |
| 2 | Page | How this course works | — |
| 3 | URL | The workshop website | `{{SITE_URL}}/` |
| 4 | Quiz | **Pre-test (10 minutes)** | — |
| 5 | Forum | Announcements | The default news forum. Do not add a second one. |

### Pre-test quiz settings

| Setting | Value |
|---|---|
| Questions | All 10 from category `Prelude/Pre-test` |
| Maximum grade | 10 |
| Attempts allowed | **1** |
| How questions behave | **Deferred feedback** |
| Shuffle within questions | Yes |
| Review options — *During the attempt* and *Immediately after* | untick everything except *The attempt* |
| Review options — *After the quiz is closed* | tick everything |
| Time limit | None. It takes ten minutes; a clock adds nothing but anxiety |
| Open / close | Open 17 Aug; close **Tue 8 Sep 23:59** |
| Grade category / weight | Weight **0** |
| Completion | *Student must make an attempt* |

Why one attempt and closed review: this is a baseline measurement of what the
cohort knows before teaching, used to pitch Day 1. Multiple attempts and visible
answers would destroy the measurement. The description says so plainly —
participants who think it is an exam behave differently.

This quiz is the target for `{{PRETEST_URL}}` in the invitation and reminder
emails. Link to the quiz itself, not the course, so a participant who only wants
to do the pre-test lands on it.

---

## §3 Section 1 — Get your laptop ready (target Sun 23 August)

| Order | Type | Name | Points at |
|---|---|---|---|
| 1 | URL | Install R, RStudio and Quarto | `{{SITE_URL}}/prelude/install.html` |
| 2 | URL | Install the packages and run the setup check | `{{SITE_URL}}/prelude/check-setup.html` |
| 3 | Assignment | **Show us your setup check passed** | — |
| 4 | Forum | Help desk — stuck on something? | — |

### Assignment settings

| Setting | Value |
|---|---|
| Submission types | **Online text** *and* **File submissions** |
| Maximum files | 1 · maximum size 5 MB · any file type |
| Due date | Sun 23 August 2026, 23:59 |
| Cut-off date | **None** — late is much better than never |
| Remind me to grade by | untick |
| Require students to click submit | **No** |
| Grade → Type | **None** |
| Feedback types | Feedback comments **on** |
| Completion | *Student must make a submission* |

Grade type None is deliberate. This is triage: you are reading the output for
`✖` lines, not marking it. Feedback comments are on so you can reply to a
failing run in place instead of starting an email thread.

### Help desk forum settings

| Setting | Value |
|---|---|
| Forum type | **Standard forum for general use** |
| Subscription mode | **Optional** — participants choose |
| Attachments | 1 file, 5 MB (screenshots) |
| Completion | *View* only. Never require a post; it manufactures noise |

---

## §4 Section 2 — Learn just enough R (target Sun 30 August)

| Order | Type | Name | Points at |
|---|---|---|---|
| 1 | Label | *(which track to choose)* | — |
| 2 | URL | R primer — the RStudio version | `{{SITE_URL}}/prelude/r-primer.html` |
| 3 | URL | Primer 1 · Objects, functions and vectors | `{{SITE_URL}}/prelude/primer-01-objects.html` |
| 4 | Quiz | Check yourself · Primer 1 | 4 questions |
| 5 | URL | Primer 2 · Tibbles | `{{SITE_URL}}/prelude/primer-02-tibbles.html` |
| 6 | Quiz | Check yourself · Primer 2 | 4 questions |
| 7 | URL | Primer 3 · Packages and the pipe | `{{SITE_URL}}/prelude/primer-03-packages-pipe.html` |
| 8 | Quiz | Check yourself · Primer 3 | 4 questions |
| 9 | URL | Primer 4 · The five dplyr verbs | `{{SITE_URL}}/prelude/primer-04-dplyr-verbs.html` |
| 10 | Quiz | Check yourself · Primer 4 | 4 questions |
| 11 | URL | Primer 5 · Your first plot | `{{SITE_URL}}/prelude/primer-05-first-plot.html` |
| 12 | Quiz | Check yourself · Primer 5 | 4 questions |

### URL settings — every URL resource in the course

| Setting | Value |
|---|---|
| Appearance → Display | **Open** with *Open in new window* ticked, or **In pop-up** |
| Display description on course page | **Yes** — the one-line instruction should be readable without a click |
| Completion | *Student must view this activity* |

**Do not set Display: Embed.** The primers cost 16–37 MB on first load and
current browsers partition the HTTP cache by top-level site, so an embedded
primer does not reuse the cache from a direct visit — and the primers' saved
typing (`localStorage`) is partitioned or blocked in a third-party frame,
worst in Safari. Design doc §5 has the numbers; `README.md` step 5 is the
measurement that would overturn this.

### Primer quiz settings — all five identical

| Setting | Value |
|---|---|
| Questions | All 4 from the matching `Prelude/Primer 0N …` category |
| Maximum grade | 4 |
| Attempts allowed | **Unlimited** |
| Grading method | **Highest grade** |
| How questions behave | **Immediate feedback** |
| Shuffle within questions | Yes |
| Review options — *Immediately after the attempt* | tick *The attempt*, *Whether correct*, *Specific feedback*, *General feedback* |
| Review options — *Right answer* | untick everywhere. Unlimited attempts plus per-distractor feedback is enough to get there; showing the answer removes the reason to think |
| Grade to pass | **3** of 4 (75%) |
| Grade category / weight | Weight **0** |
| Completion | *Student must receive a passing grade*, plus *Student must make an attempt* |
| Open / close | Open 17 Aug; close Tue 8 Sep 23:59 |

Unlimited attempts and a 75% pass make these mastery checks. Nobody is ranked;
the report answers one question — has this person actually worked through the
primer?

---

## §5 Section 3 — Data and reading (target Sun 6 September)

| Order | Type | Name | Points at |
|---|---|---|---|
| 1 | URL | Download the workshop datasets | `{{SITE_URL}}/prelude/data.html` |
| 2 | URL | Pre-reading — twenty minutes | `{{SITE_URL}}/prelude/pre-reading.html` |
| 3 | URL | The workshop introduction deck | `{{SITE_URL}}/slides/workshop_intro.html` |
| 4 | Page | What to bring, where to be, when | — |

The logistics Page is the only place in the course that carries information the
website does not: venue, room, registration time, and what happens if you are
late. It uses `{{VENUE}}` and takes its timings from `schedule.qmd`.

---

## §6 Section 4 — Reference, open all the time

| Order | Type | Name | Points at |
|---|---|---|---|
| 1 | URL | Troubleshooting — start here when something breaks | `{{SITE_URL}}/resources/troubleshooting.html` |
| 2 | URL | R cheatsheet | `{{SITE_URL}}/resources/cheatsheet.html` |
| 3 | URL | Glossary | `{{SITE_URL}}/resources/glossary.html` |
| 4 | URL | Further reading | `{{SITE_URL}}/resources/further-reading.html` |
| 5 | Label | *(pointer back to the help desk forum)* | — |

Completion tracking on these four: **None**. They are references; ticking them
off means nothing and would pollute the readiness report.

---

## §7 What the readiness report should look like

*Reports → Activity completion*, read one week out. The three columns that
matter, in order:

1. **Assignment: setup check** — a submission means their toolchain worked at
   least once. Read the text for `✖` lines even where it was submitted.
2. **Check yourself · Primer 1** — the cheapest possible proof that somebody has
   started. If this is empty a week out, the participant has not begun.
3. **Check yourself · Primer 5** — they have run `ggplot()` before Day 1 11:15,
   which is `CLAUDE.md` known issue #2's whole mitigation.

Everything else is texture. Chase on those three.
