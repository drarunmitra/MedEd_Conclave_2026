# Activity text

Copy-paste text for every activity in the course. Structure and settings are in
`course-blueprint.md`.

Two rules held throughout, both from the design (§3, decision 3):

- **Nothing here teaches.** Every instruction is one or two sentences and a link
  out. The website is the single source of truth; if it changes, none of this
  needs to.
- **Every activity says how long it takes**, because the invitation email
  promises "about two hours in total" and participants budget accordingly.

Replace `https://drarunmitra.github.io/MedEd_Conclave_2026`, `https://setfacilitysaral2.org/course/view.php?id=394`, `AIIMS Bibinagar, Hyderabad` and `dr.arunmitra@gmail.com`
before publishing.

---

## §1 Section summaries

**Section 0 — Start here**

> Everything in this course happens before Wednesday 9 September. Work through
> it in order, at your own pace, on the laptop you are bringing. Budget about two
> hours in total, spread over a few evenings — it is not two hours in one sitting.

**Section 1 · Get your laptop ready** — *target: Sunday 23 August*

> The one part that cannot wait. If your laptop is not ready on the morning of
> Day 1 you will spend the first session watching downloads instead of writing
> code, and there is no way for us to give that time back.

**Section 2 · Learn just enough R** — *target: Sunday 30 August*

> Day 1 starts drawing plots at 11:15. This section is how you arrive having
> already written R rather than meeting it cold. Pick either track — in your
> browser or in RStudio — and do the five short check quizzes as you go.

**Section 3 · Data and reading** — *target: Sunday 6 September*

> The datasets you will analyse on both days, twenty minutes of optional
> reading, and the practical details of getting to the room.

**Section 4 — Reference, open all the time**

> Four pages worth bookmarking. They stay useful during the workshop and after
> it.

---

## §2 Section 0 — Start here

### Label (first item on the page)

> **Welcome.** This course is the *prelude* to the two-day workshop — the part
> you do at home. It holds the instructions, the deadlines and one short
> pre-test; all of the actual material lives on the workshop website, which stays
> online after the conclave ends.
>
> Three targets, one per week: **laptop ready by Sunday 23 August**, **R primers
> done by Sunday 30 August**, **data and reading by Sunday 6 September**. Nothing
> locks and nothing is marked. If you are stuck, post in the help desk forum —
> somebody else has the same problem.

### Page · "How this course works"

*Name:* `How this course works`

*Content:*

> **What you must do before 9 September**
>
> | | Task | Time | Where |
> |---|---|---|---|
> | 1 | Install R, RStudio and Quarto | 30 min | Section 1 |
> | 2 | Install the workshop packages and run the setup check | 15 min | Section 1 |
> | 3 | Upload your setup-check result so we know you are ready | 2 min | Section 1 |
> | 4 | Work through the R primers — browser or RStudio, your choice | 45 min | Section 2 |
> | 5 | Do the five short check quizzes | 15 min | Section 2 |
> | 6 | Download the workshop datasets | 5 min | Section 3 |
> | 7 | Skim the pre-reading | 20 min | Section 3 |
> | 8 | Complete the pre-test | 10 min | Section 0 |
>
> **Where things live.** This course carries instructions, dates and reminders.
> The teaching material — every page, dataset, slide and code example — is on the
> workshop website at https://drarunmitra.github.io/MedEd_Conclave_2026, and it remains there after the workshop.
> Links in this course open the website in a new tab.
>
> **Why the primers run in a separate tab.** The interactive primers run R inside
> your browser, and they download 16–37 MB the first time you open each one. Your
> browser only caches that properly when the page is open in its own tab, so we
> deliberately do not embed them here. Open them at home, not on conference wifi.
>
> **What we can see.** Whether you have opened each page, your quiz attempts, and
> your setup-check upload. Nothing you type into a primer is recorded anywhere —
> those pages run entirely on your own computer and send nothing back. Practise
> freely, and break things on purpose.
>
> **If you get stuck**, post in the help desk forum in Section 1 with your
> operating system, the exact error message, and the output of `sessionInfo()`.
> That is usually enough for us to answer in one reply instead of five.

### URL · The workshop website

*Name:* `The workshop website`
*URL:* `https://drarunmitra.github.io/MedEd_Conclave_2026/`

*Description:*

> Everything for both days: schedule, session pages, datasets, slides and
> resources. Bookmark it — it stays online after the conclave.

### Quiz · Pre-test

*Name:* `Pre-test (10 minutes)`

*Description:*

> Ten questions, one attempt, ten minutes. **This measures the workshop, not
> you.** We use it to pitch Day 1 at the room that actually turns up, and to
> compare against the same questions at the end of Day 2 — so answering
> honestly, including leaving something you do not know, is more useful to us
> than guessing well.
>
> It is not graded and it does not count towards anything. Answers stay hidden
> until the course closes on 8 September, which is why there is only one attempt.
>
> Do it **before** you start the primers in Section 2, otherwise it measures the
> primers.

### Forum · Announcements

Use the course's default news forum. Rename it to `Announcements` if it is not
already, and leave forced subscription on — this is the channel that reaches
people who never log in.

---

## §3 Section 1 — Get your laptop ready

### URL · Install R, RStudio and Quarto

*Name:* `Install R, RStudio and Quarto`
*URL:* `https://drarunmitra.github.io/MedEd_Conclave_2026/prelude/install.html`

*Description:*

> **30 minutes.** Three separate installs, in this order, on the laptop you are
> bringing. You need administrator rights and about 5 GB free.
>
> If your institution locks down software installation, email
> dr.arunmitra@gmail.com **at least a week before** the workshop — we can arrange a
> cloud fallback, but a local install is much better for your work afterwards.

### URL · Install the packages and run the setup check

*Name:* `Install the packages and run the setup check`
*URL:* `https://drarunmitra.github.io/MedEd_Conclave_2026/prelude/check-setup.html`

*Description:*

> **15 minutes, mostly waiting.** Paste one line into the RStudio console to
> install sixteen packages, then run `check_setup.R`. It prints a tick or a cross
> against eight things and tells you exactly what is wrong with any of them.
>
> Start it and make tea. Then upload the result below.

### Assignment · Setup check

*Name:* `Show us your setup check passed`

*Description:*

> **2 minutes.** Paste the whole output of `check_setup.R` into the text box, or
> upload a screenshot of it. Either is fine.
>
> **Send it even if it failed** — especially if it failed. Every line beginning
> `✖` names a specific problem we can usually fix by email in a day, and the
> whole output tells us which one. Arriving on Wednesday with an unfixed cross is
> the one avoidable way to lose the first session.
>
> This is not marked. It is how we know, before the day, who is ready and who
> needs help.

### Forum · Help desk

*Name:* `Help desk — stuck on something?`

*Description:*

> Post here rather than emailing, so that the next person with the same error
> finds the answer. Faculty read this daily until 8 September.
>
> Include three things and you will usually get a fix first time: **your
> operating system and version**, **the exact error message** (copy the text, do
> not paraphrase it), and the output of `sessionInfo()`. Screenshots of the
> console are welcome.
>
> Before posting, it is worth checking
> [Troubleshooting](https://drarunmitra.github.io/MedEd_Conclave_2026/resources/troubleshooting.html) in Section 4 —
> it covers the errors behind most installation failures.

---

## §4 Section 2 — Learn just enough R

### Label · Choose your track

> **Two tracks, same content. Pick one.**
>
> **In your browser** — the five numbered primers below. R runs inside the page,
> so there is nothing to install and nothing can go wrong with your setup. Start
> here if your install has not gone smoothly yet: you can keep learning while we
> sort it out.
>
> **In RStudio** — the R primer, one page, 45 minutes. Choose this if your
> install worked and you would rather practise in the tool you will actually use
> on the day. It is also the fallback if your network blocks the browser primers.
>
> **Do the five check quizzes either way.** Four questions each, unlimited
> attempts, answerable from either track. They are the only way we can tell that
> anyone has worked through this, so they are also how we know whether Day 1
> morning can move at pace.
>
> One practical warning: each browser primer downloads 16–37 MB the first time
> you open it. Open them **at home, before you travel**. Conference wifi shared
> by forty people is not the moment to find out.

### URL · R primer (RStudio track)

*Name:* `R primer — the RStudio version`
*URL:* `https://drarunmitra.github.io/MedEd_Conclave_2026/prelude/r-primer.html`

*Description:*

> **45 minutes, in RStudio.** Objects, vectors, data frames, packages and the
> pipe, with the full explanation of each. Covers exactly the same ground as the
> five browser primers below, so do one track or the other rather than both.

### URL · Primer 1

*Name:* `Primer 1 · Objects, functions and vectors`
*URL:* `https://drarunmitra.github.io/MedEd_Conclave_2026/prelude/primer-01-objects.html`

*Description:*

> **10 minutes. Downloads about 17 MB the first time.** Runs R in your browser —
> nothing to install. Three ideas that carry the whole of Day 1: objects,
> functions, vectors. Change the numbers and break the cells on purpose; nothing
> you type is recorded or sent anywhere.

### URL · Primer 2

*Name:* `Primer 2 · Tibbles: the data rectangle`
*URL:* `https://drarunmitra.github.io/MedEd_Conclave_2026/prelude/primer-02-tibbles.html`

*Description:*

> **10 minutes. About 21 MB.** One row per observation, one column per variable —
> the shape every dataset in this workshop has. Also `glimpse()`, which is the
> function you will reach for whenever something looks wrong.

### URL · Primer 3

*Name:* `Primer 3 · Packages and the native pipe`
*URL:* `https://drarunmitra.github.io/MedEd_Conclave_2026/prelude/primer-03-packages-pipe.html`

*Description:*

> **10 minutes. About 22 MB.** The two lines of plumbing every tidyverse script
> needs: `library()`, and the pipe `|>` that chains steps in the order you think
> about them. Note the page's warning about one way the browser lies to you —
> that difference matters when you move to RStudio.

### URL · Primer 4

*Name:* `Primer 4 · The five dplyr verbs`
*URL:* `https://drarunmitra.github.io/MedEd_Conclave_2026/prelude/primer-04-dplyr-verbs.html`

*Description:*

> **20 minutes. About 25 MB.** `filter()`, `select()`, `arrange()`, `mutate()`,
> `summarise()` — almost all data work is these five. Worked on the real
> 240-student cohort you will use on both days, with the same missing values that
> will surprise you in the room.

### URL · Primer 5

*Name:* `Primer 5 · Your first plot`
*URL:* `https://drarunmitra.github.io/MedEd_Conclave_2026/prelude/primer-05-first-plot.html`

*Description:*

> **20 minutes. About 37 MB — the heaviest page, so do this one at home.** Day 1
> starts plotting at 11:15. Work through this and that will not be the first
> `ggplot()` call you have ever written.

### Quiz descriptions

*Names:* `Check yourself · Primer 1` … `Check yourself · Primer 5`

*Description* (adapt the primer number and the last line):

> Four questions on Primer 1. **Unlimited attempts**, and you are told
> immediately whether each answer is right and why. Not graded, not counted, not
> compared with anyone.
>
> Nothing here needs R to be running — every question is answerable from the
> primer page or from the R primer. If an answer surprises you, go back to the
> page and run the cell.

Per-quiz closing line, appended to the above:

| Quiz | Line |
|---|---|
| 1 | Aim to get the difference between `>` and `>=` right. It is the single most common off-by-one error in health data. |
| 2 | The question about type tags is the one worth getting right: `<chr>` where you expected `<dbl>` explains most puzzling errors. |
| 3 | If you only remember one thing: `library()` goes in the script, `install.packages()` stays in the console. |
| 4 | Missing values are the theme. Eleven students in the cohort have no post-test score, and they will change your answers. |
| 5 | Layers join with `+`, not `\|>`. Everybody gets this wrong once; better now than at 11:20 on Wednesday. |

---

## §5 Section 3 — Data and reading

### URL · Datasets

*Name:* `Download the workshop datasets`
*URL:* `https://drarunmitra.github.io/MedEd_Conclave_2026/prelude/data.html`

*Description:*

> **5 minutes.** Four files, all synthetic, all small. Save them into the `data/`
> folder of your RStudio project — the same relative path every code example in
> the workshop uses.
>
> One scenario carries both days: three medical colleges, two teaching arms, a
> knowledge test before and after, a five-station OSCE, and a deliberately messy
> faculty survey for cleaning practice.

### URL · Pre-reading

*Name:* `Pre-reading — twenty minutes`
*URL:* `https://drarunmitra.github.io/MedEd_Conclave_2026/prelude/pre-reading.html`

*Description:*

> **20 minutes, none of it compulsory.** Three short pieces on why
> reproducibility matters, one on tidy data, and the ICMJE line on declaring AI
> use — which we come back to on Day 2 afternoon.
>
> You are not expected to absorb it. Skim now; come back afterwards when the
> words have referents.

### URL · Introduction deck

*Name:* `The workshop introduction deck`
*URL:* `https://drarunmitra.github.io/MedEd_Conclave_2026/slides/workshop_intro.html`

*Description:*

> Optional, and worth skimming. Philosophy of knowledge, the frequentist,
> Bayesian and AI paradigms, and the argument that runs through both days: your
> choice of tools follows from a position on what counts as knowledge, and
> reproducibility is where that position becomes checkable by other people.

### Page · Logistics

*Name:* `What to bring, where to be, when`

*Content:*

> **When.** Wednesday 9 and Thursday 10 September, 09:00–17:00 both days.
> Registration, the icebreaker and group allotment run 09:00–09:30 on Day 1 — if
> you arrive at 09:30 you will have missed the group you present with on
> Thursday afternoon.
>
> **Where.** AIIMS Bibinagar, Hyderabad.
>
> **Bring**
>
> - The laptop you did Section 1 on, with **administrator rights** on it
> - Its charger — power outlets are limited, so arrive charged
> - At least 5 GB of free disk space
> - Your institutional email address; some of the tools ask for one
>
> **Provided.** Tea and lunch on both days. Datasets, slides and every code
> example are on the website and stay there afterwards.
>
> **Groups** are allotted at registration on Day 1, and you present with your
> group on Thursday afternoon. There is nothing to prepare for that in advance.
>
> **What you do not need:** any prior programming experience, statistics beyond
> what you already use in your own research, or a paid licence for anything.
> Every tool in this workshop is free and open source.
>
> **If something goes wrong on the morning**, come to the registration desk
> before 09:30 rather than working on it quietly at your seat. Almost everything
> is fixable in ten minutes with someone standing next to you.

---

## §6 Section 4 — Reference

### URL · Troubleshooting

*Name:* `Troubleshooting — start here when something breaks`
*URL:* `https://drarunmitra.github.io/MedEd_Conclave_2026/resources/troubleshooting.html`

*Description:*

> The errors behind most installation failures, with the fix for each. Check here
> before posting in the help desk — it will often be faster than waiting for a
> reply.

### URL · Cheatsheet

*Name:* `R cheatsheet`
*URL:* `https://drarunmitra.github.io/MedEd_Conclave_2026/resources/cheatsheet.html`

*Description:*

> One page of the functions used across both days. Useful during the hands-on
> blocks; keep the tab open.

### URL · Glossary

*Name:* `Glossary`
*URL:* `https://drarunmitra.github.io/MedEd_Conclave_2026/resources/glossary.html`

*Description:*

> Plain-English definitions of the words we will use without explaining them —
> tibble, working directory, render, chunk, reproducible.

### URL · Further reading

*Name:* `Further reading`
*URL:* `https://drarunmitra.github.io/MedEd_Conclave_2026/resources/further-reading.html`

*Description:*

> Where to go next, including *R for Data Science* and *The Epidemiologist R
> Handbook* — both free online, both the usual answer to "what should I read
> after this?".

### Label · Closing pointer

> Still stuck after all that? The **help desk forum** in Section 1 is read daily
> until 8 September. Post your operating system, the exact error and the output
> of `sessionInfo()`, and we will work it out with you before Wednesday.
