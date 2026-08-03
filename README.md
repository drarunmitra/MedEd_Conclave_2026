# R & Reproducible Research — MedEd Conclave 2026

Course website for the two-day hands-on workshop for medical education
faculty and researchers, **9–10 September 2026**.

Built with [Quarto](https://quarto.org), published to GitHub Pages.

Live site: <https://SET-TEAM.github.io/meded-conclave-2026/>

## Faculty

| Faculty | Sessions |
|---|---|
| Biju Soman | Fundamentals of reproducible research; live coding |
| Arun Mitra | Data science & AI basics; Quarto; gtsummary; live coding |
| Gurpreet | R & ggplot2; dplyr & EDA; Generative AI in health research |
| SET Team | Registration, groups, pre/post-test, valedictory |

## Build it locally

Requires R ≥ 4.1 and Quarto ≥ 1.4.

```bash
git clone https://github.com/SET-TEAM/meded-conclave-2026.git
cd meded-conclave-2026

# 1. Install the R packages
Rscript setup/install_packages.R

# 2. Generate the synthetic teaching datasets (REQUIRED before first render)
Rscript R/00_generate_datasets.R

# 3. Render
quarto preview      # live reload while editing
quarto render       # full build into _site/
```

> **The second step is not optional.** `data/` is generated, not stored in the
> repository. Several pages execute R against those files and the render will
> fail without them.

## Publish

```bash
quarto publish gh-pages
```

Or push to `main` and let `.github/workflows/publish.yml` do it.

## Structure

```
├── _quarto.yml              # site configuration and navigation
├── index.qmd                # landing page
├── schedule.qmd             # master schedule (mirrors admin/*.xlsx)
├── styles.scss              # site theme
├── prelude/                 # pre-workshop: install, check, primer, data
├── day1/                    # 5 session pages, each with hands-on + solutions
├── day2/                    # 5 session pages
├── resources/               # cheatsheet, troubleshooting, glossary, reading
├── slides/                  # Reveal.js decks + shared SCSS
│   ├── day1/                # 5 decks
│   ├── day2/                # 3 decks
│   └── workshop_intro.html  # pre-existing philosophy deck
├── R/
│   ├── 00_generate_datasets.R   # seeded synthetic data (set.seed(20260909))
│   ├── 01_analysis.R            # complete worked pipeline (live code session)
│   └── report_template.qmd      # starter document for the group activity
├── _setup/
│   ├── install_packages.R
│   └── check_setup.R            # participant verification script
├── admin/                   # schedule xlsx, emails, feedback form
└── data/                    # generated, git-ignored
```

## Datasets

All synthetic, generated with `set.seed(20260909)`, so every run is
byte-identical. No real student, faculty member or institution is
represented.

| File | Rows | Used in |
|---|---|---|
| `meded_students.csv` | 240 | ggplot2, dplyr, gtsummary |
| `osce_stations.csv` | 1200 | joins, grouped summaries |
| `faculty_survey_raw.csv` | 132 | data cleaning (deliberately messy) |
| `codebook.csv` | 25 | variable dictionary |

Scenario: three government medical colleges compared a flipped classroom
against traditional lectures, with pre/post knowledge tests and a
five-station OSCE.

## Editing the material

- **Session pages** live in `day1/` and `day2/`. Each has a `## Hands-on`
  section with exercises in `callout-note` and solutions in collapsed
  `callout-tip` blocks.
- **Slides** are Reveal.js `.qmd` in `slides/`. Faculty own their own decks —
  these are structured starters with speaker notes, not final content.
  Press <kbd>S</kbd> in a rendered deck for the presenter view.
- **The schedule spreadsheet in `admin/` is the source of truth.** If
  `schedule.qmd` disagrees with it, fix `schedule.qmd`.

## Licence

Materials [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/), code
MIT. Reuse and adapt with attribution.
