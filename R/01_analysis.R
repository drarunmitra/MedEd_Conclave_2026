# 01_analysis.R ---------------------------------------------------------------
# MedEd Conclave 2026 · live code session (Day 2, 14:45)
# Flipped classroom and knowledge gain: complete workflow, raw data to report.
#
# Run with a clean session:
#   Ctrl/Cmd + Shift + F10, then source("R/01_analysis.R")
# -----------------------------------------------------------------------------

library(tidyverse)
library(gtsummary)

if (!dir.exists("output")) dir.create("output")

# 1. Import -------------------------------------------------------------------

students <- read_csv("data/meded_students.csv", show_col_types = FALSE)
osce     <- read_csv("data/osce_stations.csv",  show_col_types = FALSE)

glimpse(students)
stopifnot(nrow(students) == 240)          # fail loudly, early

# 2. Derive -------------------------------------------------------------------

osce_summary <- osce |>
  group_by(student_id) |>
  summarise(
    osce_total = sum(score),
    osce_mean  = mean(score),
    n_stations = n(),
    .groups = "drop"
  )

stopifnot(all(osce_summary$n_stations == 5))   # catch a duplicated station

analysis <- students |>
  left_join(osce_summary, by = "student_id") |>
  mutate(
    teaching_arm = factor(
      teaching_arm,
      levels = c("Traditional lecture", "Flipped classroom")   # reference first
    ),
    attendance_band = case_when(
      attendance_pct >= 90 ~ "High",
      attendance_pct >= 75 ~ "Adequate",
      .default             = "Below requirement"
    ),
    complete_case = !is.na(posttest)
  )

stopifnot(nrow(analysis) == nrow(students))    # the join did not duplicate rows

# 3. Describe -----------------------------------------------------------------

n_excluded <- sum(!analysis$complete_case)
message("Excluded for missing post-test: ", n_excluded)

# Baseline comparability - check BEFORE comparing outcomes
tbl1 <- analysis |>
  select(teaching_arm, age, sex, rural_background, attendance_pct,
         pretest, osce_total) |>
  tbl_summary(
    by = teaching_arm,
    label = list(
      age              ~ "Age (years)",
      sex              ~ "Sex",
      rural_background ~ "Domicile",
      attendance_pct   ~ "Attendance (%)",
      pretest          ~ "Pre-test score",
      osce_total       ~ "OSCE total (/100)"
    )
  ) |>
  add_overall() |>
  bold_labels() |>
  modify_caption("**Table 1.** Cohort characteristics by teaching arm.")

# 4. Visualise ----------------------------------------------------------------

fig1 <- analysis |>
  filter(complete_case) |>
  ggplot(aes(x = teaching_arm, y = gain, fill = teaching_arm)) +
  geom_boxplot(alpha = 0.75, width = 0.55, outlier.shape = NA) +
  geom_jitter(width = 0.12, alpha = 0.30, size = 1) +
  scale_fill_manual(values = c("Traditional lecture" = "#b8860b",
                               "Flipped classroom"   = "#0f5257")) +
  labs(
    x = NULL,
    y = "Knowledge gain (post − pre)",
    title    = "Knowledge gain by teaching method",
    subtitle = paste0("n = ", sum(analysis$complete_case),
                      " with complete data; ", n_excluded, " excluded"),
    caption  = "Synthetic data generated for teaching purposes."
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "none", plot.title = element_text(face = "bold"))

ggsave("output/fig1_gain.png", fig1,
       width = 7, height = 4.5, dpi = 300, bg = "white")

# 5. Model --------------------------------------------------------------------

m1 <- lm(gain ~ teaching_arm + pretest + attendance_pct + sex, data = analysis)

tbl2 <- tbl_regression(
  m1,
  label = list(
    teaching_arm   ~ "Teaching arm",
    pretest        ~ "Pre-test score",
    attendance_pct ~ "Attendance (%)",
    sex            ~ "Sex"
  )
) |>
  add_glance_table(include = c(nobs, r.squared, adj.r.squared)) |>
  bold_p() |>
  modify_caption("**Table 2.** Linear regression of knowledge gain.")

# 6. Report -------------------------------------------------------------------
# quarto::quarto_render("report.qmd")

message("Done. Objects available: analysis, tbl1, tbl2, fig1")
