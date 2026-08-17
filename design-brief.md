# Design brief: R & Reproducible Research, MedEd Conclave 2026

Drafted 2026-08-17 from the 38 session objectives that already exist. Sections 3
to 5 are complete; 1, 2, 6 and 7 are outstanding and marked.

This file is internal. It is in neither the render list nor `resources:` in
`_quarto.yml`, so it is not published. The outcomes in section 4 are meant to be
public and belong on `index.qmd`.

Method: `academic-course-designer`, see `references/learners-and-outcomes.md`
in that skill.

## 1. Readiness

Not scored. The course is built and three weeks out, so the inventory is moot.
Recorded for the next run.

## 2. The learners

**Cohort size: 37.** Confirmed by the workshop lead, 2026-08-17.

Known: medical education faculty and researchers, complete beginners in R, own
laptops, blended delivery with a Moodle prelude.

Still unwritten: prior R exposure and what participants already believe about
reproducibility. The pre-test on SARAL answers part of this before Day 1. Read
the report rather than guess.

### What 37 implies

**Six groups**, decided 2026-08-17: five of six and one of seven.

| Consequence | Detail |
|---|---|
| Group size | Six is the right size for one document in 45 minutes. Three pairs, one keyboard each, one person owning the merge |
| Questions | Two new questions written 2026-08-17, Q5 colleges and Q6 study hours, so all six groups have distinct work. See below |
| Presentation time | Six groups at four minutes plus two of questions is 36 minutes, inside the 16:15 to 17:00 slot with about nine minutes spare. Four groups left far more slack; six is comfortable but no longer generous |
| Facilitator ratio | Three faculty plus SET team for 37 is roughly 1 to 12 during hands-on, and six groups to circulate rather than four. The red and green sticky-note system is now doing real work, not decoration |
| Venue bandwidth | 37 participants times about 45 MB of WebAssembly payload is roughly 1.7 GB, and about 22 Mbit/s sustained if they all load in the first ten minutes. This is why the prelude tells them to open the primers before they travel |
| Feedback | At this size no individual written feedback is possible in the room. The group document is the only artefact anyone will look at, which raises the value of stating its criteria |

## 3. Big ideas

Four. Everything in the course serves one of them, or it is not in the course.

| # | Big idea |
|---|---|
| A | An analysis nobody else can re-run is not evidence, it is an assertion. |
| B | Look at the data before you model it. What is missing is part of the data. |
| C | The document and the analysis are one artefact, not two things kept in step by hand. |
| D | A tool that writes your code does not take responsibility for it. You do. |

**The question that runs through the course:** *Did the flipped classroom
improve knowledge gain compared with traditional lectures, and for whom?* This
already exists in `day1/index.qmd` and is doing real work; it just was not
written down as the spine.

## 4. Course outcomes

Nine. Each is course-level, names the evidence, and is assessable by a single
method. This is the section to put on the landing page.

By the end of the two days, a participant will be able to:

| # | Outcome | Evidence | Big idea | Bloom |
|---|---|---|---|---|
| O1 | Organise an analysis as a self-contained RStudio project that another person can open and run without editing a single path | The project folder they hand over on Day 2 | A | Apply |
| O2 | Import a dataset and report its structure, types and missingness before analysing it | The inspection step in their rendered document | B | Apply |
| O3 | Transform a dataset to answer a stated question using dplyr verbs chained with the native pipe, stating in prose how missing values were handled | The pipeline and the Methods sentence in their document | B | Apply |
| O4 | Construct a labelled ggplot2 figure that stands alone in a manuscript, and justify the geometry chosen for those variables | The figure, its caption, and the one-line justification | B | Evaluate |
| O5 | Produce a stratified summary table with an appropriate comparison test, and defend the choice of test | Table 1 in their document | B | Evaluate |
| O6 | Author a Quarto document that contains its own code and render it to more than one output format, with cross-references and a bibliography | One source rendered to HTML and Word | C | Create |
| O7 | Critique AI-generated analysis code for plausible-but-wrong output, and state what was checked | A short written critique | D | Evaluate |
| O8 | Decide whether a given dataset may be entered into a commercial AI tool under Indian data protection law and institutional policy, and record that decision and any AI assistance in an ICMJE-compliant statement | The AI-use statement in their document | D | Evaluate |

**Dropped: O9**, "assess another group's analysis for reproducibility". Decided
2026-08-17. It was never taught, no criteria existed, and the Day 2 afternoon
has no slack to add a peer-review step. Assessing something the course does not
teach is the failure the alignment matrix exists to catch, so the honest move
was to remove the outcome rather than pretend the presentations covered it.

Big idea A is still served, by O1 and by the stated criteria in section 5a.

Note the Bloom spread: five outcomes at Evaluate and one at Create. That is
appropriate for a beginners' course and worth saying out loud, because the
instinct with beginners is to stop at Remember and Understand. The material is
simple; the demand is not.

### These are not new promises

`index.qmd` already carries a "What you will be able to do" grid of six tiles.
The nine outcomes formalise what is on that page; they do not add to it. The
tiles map cleanly:

| Landing page tile | Outcome |
|---|---|
| Work reproducibly | O1 |
| Visualise data | O4 |
| Wrangle and explore | O2, O3 |
| Publish with Quarto | O6 |
| Tabulate for journals | O5 |
| Use GenAI honestly | O7, O8 |

So the gap was never that the course had no destination. It was that the
destination was written as marketing prose, with nothing measurable behind it
and no line from it to any session objective. Every promise on that page is now
traceable to objectives that already exist.

## 5. Objective to outcome mapping

All 38 existing objectives, traced. No objective was rewritten.

| Session | Objectives | Serve |
|---|---|---|
| 1 Introduction to the basics | 4 | O1 (obj 1-3), housekeeping (obj 4) |
| 2 Getting started | 4 | O1 (panes, project structure), O6 (workflow), O7 (placing AI) |
| 3 R and data visualisation | 5 | O2 (read and inspect), O4 (all four others) |
| 4 Introduction to Quarto | 5 | O6 (all five) |
| 5 Working with data | 5 | O3 (verbs, pipe, missing, join), O2 (exploratory analysis) |
| 6 Communicating with Quarto | 5 | O6 (all five) |
| 7 Publication-ready tables | 5 | O5 (all five) |
| 8 Generative AI | 5 | O7 (obj 1-3), O8 (obj 4-5) |
| 9 Live code session | 0 | O1, O3, O6 demonstrated end to end |
| 10 Group activity | 0 | O1 to O8, this is where the evidence is produced |

### Orphans

One: session 1 objective 4, "State the workshop's ground rules and learning
objectives." That is orientation, not an outcome. Leave it on the page and stop
calling it a learning objective.

### Outcomes with thin coverage

**O1** is taught in a 10-minute project demo opening session 2 and never
practised deliberately. It is now assessed explicitly: criterion 1 in section 5a
is whether the document renders from the project folder on a machine that is not
the author's.

## 5a. Group activity criteria

Decided 2026-08-17. The group document is the only artefact anyone examines, so
what it is judged on is now stated in advance rather than described afterwards.
The criteria go in the printed brief handed out at the Day 2 morning recap, and
on `day2/s10-group-activity.qmd`.

Met or not met. Nothing is scored, nothing is ranked, and no group is compared
with another. The point is that a group can tell before 16:15 whether it has
done the thing.

| # | Criterion | Outcome | How it is checked |
|---|---|---|---|
| 1 | The document renders from a clean session on a machine that is not the author's | O1 | A facilitator opens the folder and renders it |
| 2 | Every number in the prose comes from inline code, not from typing | O3, O6 | At least one visible `r ...` in the source |
| 3 | Missing data are handled deliberately, with the count stated in prose | O2, O3 | The Methods sentence |
| 4 | One labelled figure, with a caption that stands alone, and a stated reason for the geometry | O4 | The figure and its caption |
| 5 | One `gtsummary` table, labelled, with the comparison justified in one line | O5 | The table and the line under it |
| 6 | Cross-references resolve: `@tbl-` and `@fig-` render as numbers, not as literal text | O6 | The rendered output |
| 7 | One honest limitation, naming something the design cannot show | Big idea A | The Limitations paragraph |
| 8 | An AI disclosure sentence, or a statement that none was used | O8 | The disclosure section |

Not criteria, stated explicitly so nobody optimises for them: statistical
sophistication, elegance of code, or finding a significant result.

### What each group will actually find

Faculty should know this before the presentations, because two groups are
designed to find nothing and that needs to be received as success, not failure.

| Group | Question | Honest answer |
|---|---|---|
| 1 | Attendance vs arm | Real. The arm effect is built into the data and survives adjustment |
| 2 | OSCE stations | Real. Stations differ in difficulty and discrimination by construction |
| 3 | Burnout | Mixed. Burnout tracks attendance, not the teaching arm |
| 4 | Faculty survey | Descriptive. The work is the cleaning, and row counts will differ between groups |
| 5 | Colleges | **Null on the arm effect.** College is not in the data-generating model |
| 6 | Study hours | **Null.** `study_hours` is generated independently of the outcome |

Two nulls out of six is deliberate. A set of questions that all find something
teaches that analysis always finds something, which is the opposite of the
lesson. Groups 5 and 6 also have real work to do before reaching the null: group
5 has unequal strata and a small-cell caution, group 6 has a right-skewed
predictor that needs a decision.

Brief the facilitators: when group 5 or 6 says "we did not find anything", the
response is that this is the correct answer and asking why is the interesting
part.

Criteria 4 and 5 are the ones that close the Apply-versus-Evaluate gap noted in
section 6. They add one sentence each to work the groups were already doing.

## 6. The alignment matrix

**Not built.** This is the outstanding piece of work. The mapping above gets you
most of the way: it needs the four timing columns added, one row per objective,
and then the four failure checks run.

The failures already visible without building it:

1. **Nothing is scored, by design.** The pre-test and the five primer quizzes are
   diagnostic and formative, weighted zero. The in-workshop exercises are
   self-checked against collapsed solutions. This is right for a two-day CME.

   Resolved 2026-08-17: the Day 2 group document is now judged against the eight
   stated criteria in section 5a, given out at the morning recap. Still not
   scored and still not ranked, but no longer judged against something the groups
   were never told.

2. **O4 and O5 sit at Evaluate but are practised at Apply.** The exercises ask
   participants to build a figure and a table. They do not ask anyone to justify
   a choice or reject an alternative. Criteria 4 and 5 close this at the group
   activity, which is the assessment point. Worth also adding "say in one line
   why this geometry rather than a boxplot" to one existing session 3 exercise,
   so the demand is rehearsed before it counts. That is the only change to
   teaching content this brief recommends.

3. **O7 and O8 are taught in session 8 and assessed two hours later in session
   10.** One pass, no practice in between. Accepted: the Day 2 afternoon has no
   slack, and criterion 8 is a single sentence rather than a demanding task.

## 7. The learner walkthrough

**Not done.** Worth the ten minutes before the workshop. Take a participant from
the pre-test through to the Day 2 presentation and check what they are asked to
do that they have never done before.

## 8. Constraints

- **Contact:** two days, 9 September to 10 September 2026.
- **Prelude:** self-paced Moodle course on SARAL, opens 17 August.
- **Modality:** in person, with an online prelude.
- **Session budget:** 45 minutes teaching plus 45 to 60 minutes hands-on. All
  five instrumented sessions currently fit; session 6 has zero slack.
- **Out of scope:** statistical modelling beyond descriptive work and one
  regression table, git, and any language other than R.

### Resolved 2026-08-17

| Item | Decision |
|---|---|
| Cohort size | About 35 |
| O9, peer review of reproducibility | Dropped. Never taught, no slack to add it |
| Group activity criteria | Stated in advance. See section 5a |

### Still open

| Item | Needed by | Who decides |
|---|---|---|
| Group size arithmetic: 35 people over 4 groups is about 9 each, but the session page plans the 45 minutes for a group of six | Before the brief is printed | Workshop lead |
| Whether to add the one-line justification to a session 3 exercise | Before Day 1 | Workshop lead |
