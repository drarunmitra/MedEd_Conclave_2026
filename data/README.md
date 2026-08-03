# data/

These files are **generated**, not stored. Run once from the project root:

```r
source("R/00_generate_datasets.R")
```

That writes:

| File | Rows |
|---|---|
| `meded_students.csv` | 240 |
| `osce_stations.csv` | 1200 |
| `faculty_survey_raw.csv` | 132 |
| `codebook.csv` | 25 |

Seeded with `set.seed(20260909)`, so every run produces identical files.
Nothing here is real data.
