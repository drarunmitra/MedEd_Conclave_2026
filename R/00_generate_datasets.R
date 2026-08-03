# 00_generate_datasets.R ------------------------------------------------------
# MedEd Conclave 2026 · R & Reproducible Research Workshop
#
# Generates the three synthetic teaching datasets used across both days.
# Nothing here is real. The structure, ranges and relationships are plausible
# for an Indian medical college cohort, but no student, faculty member or
# institution is represented.
#
# Run once from the project root:
#   source("R/00_generate_datasets.R")
#
# Outputs (written to data/):
#   meded_students.csv      240 rows  · one row per student   · clean
#   osce_stations.csv      1200 rows  · one row per station   · clean, long
#   faculty_survey_raw.csv  132 rows  · one row per response  · deliberately messy
#   codebook.csv                      · variable dictionary
# -----------------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(readr)
library(stringr)

set.seed(20260909)   # workshop date; change this and every number below changes

if (!dir.exists("data")) dir.create("data")

n_stu <- 240

# 1. Student cohort -----------------------------------------------------------

colleges <- c("Govt Medical College, Thrissur",
              "Govt Medical College, Kozhikode",
              "Govt Medical College, Alappuzha")

students <- tibble(
  student_id = sprintf("S%03d", 1:n_stu),
  batch      = sample(c("2022", "2023", "2024"), n_stu, replace = TRUE,
                      prob = c(0.3, 0.35, 0.35)),
  college    = sample(colleges, n_stu, replace = TRUE, prob = c(0.4, 0.35, 0.25)),
  sex        = sample(c("Female", "Male"), n_stu, replace = TRUE, prob = c(0.54, 0.46)),
  age        = round(rnorm(n_stu, mean = 21.4, sd = 1.3)),
  rural_background = sample(c("Rural", "Urban"), n_stu, replace = TRUE,
                            prob = c(0.42, 0.58)),
  # Randomised teaching arm - the comparison that runs through the workshop
  teaching_arm = rep(c("Traditional lecture", "Flipped classroom"),
                     length.out = n_stu) |> sample()
) |>
  mutate(
    # Baseline ability drives everything downstream
    admission_score = round(rnorm(n_stu, mean = 68, sd = 9), 1),
    attendance_pct  = round(pmin(100, pmax(45, rnorm(n_stu, 82, 9))), 1),

    pretest = round(pmin(100, pmax(0,
      0.45 * admission_score + 0.10 * attendance_pct + rnorm(n_stu, 22, 7)
    )), 1),

    # Flipped classroom adds ~5 marks on average; attendance modifies it
    arm_effect = if_else(teaching_arm == "Flipped classroom", 5.2, 0),

    posttest = round(pmin(100, pmax(0,
      pretest + arm_effect + 0.06 * attendance_pct + rnorm(n_stu, 6, 5)
    )), 1),

    gain = round(posttest - pretest, 1),

    # Study hours per week, right-skewed
    study_hours = round(pmin(40, rgamma(n_stu, shape = 4, scale = 2.6)), 1),

    # Burnout: Copenhagen-style 0-100, inversely related to attendance
    burnout_score = round(pmin(100, pmax(0,
      70 - 0.35 * attendance_pct + rnorm(n_stu, 8, 11)
    )), 1),

    burnout_band = cut(
      burnout_score,
      breaks = c(-Inf, 35, 60, Inf),
      labels = c("Low", "Moderate", "High")
    ),

    satisfaction = sample(1:5, n_stu, replace = TRUE, prob = c(.05, .12, .28, .35, .20))
  ) |>
  select(-arm_effect)

# Realistic missingness: some students skipped the post-test or the burnout scale
students <- students |>
  mutate(
    posttest      = if_else(row_number() %in% sample(seq_len(n_stu), 11), NA_real_, posttest),
    gain          = if_else(is.na(posttest), NA_real_, gain),
    burnout_score = if_else(row_number() %in% sample(seq_len(n_stu), 7), NA_real_, burnout_score),
    burnout_band  = if_else(is.na(burnout_score), NA_character_,
                            as.character(burnout_band)),
    passed        = if_else(!is.na(posttest) & posttest >= 50, "Yes", "No")
  )

write_csv(students, "data/meded_students.csv")

# 2. OSCE stations (long format, for joins and grouped summaries) -------------

stations <- tribble(
  ~station,  ~station_name,          ~domain,
  "ST1",     "History taking",       "Communication",
  "ST2",     "Clinical examination", "Clinical skill",
  "ST3",     "Procedure: IV access", "Procedural skill",
  "ST4",     "Counselling",          "Communication",
  "ST5",     "Data interpretation",  "Cognitive"
)

examiners <- sprintf("EX%02d", 1:12)

osce <- expand_grid(
  student_id = students$student_id,
  station    = stations$station
) |>
  left_join(stations, by = "station") |>
  left_join(select(students, student_id, admission_score, teaching_arm),
            by = "student_id") |>
  mutate(
    # Station difficulty: procedures are marked harder than communication
    difficulty = case_when(
      domain == "Procedural skill" ~ -1.8,
      domain == "Cognitive"        ~ -0.9,
      TRUE                         ~  0.4
    ),
    arm_bonus = if_else(teaching_arm == "Flipped classroom" &
                          domain == "Communication", 0.9, 0),
    score = round(pmin(20, pmax(0,
      8 + 0.09 * (admission_score - 68) + difficulty + arm_bonus +
        rnorm(n(), 0, 2.1)
    ))),
    max_score = 20,
    examiner  = sample(examiners, n(), replace = TRUE),
    attempt   = 1L
  ) |>
  select(student_id, station, station_name, domain, examiner,
         score, max_score, attempt)

write_csv(osce, "data/osce_stations.csv")

# 3. Faculty development survey (deliberately messy) --------------------------
# Used for the data-cleaning parts of the dplyr / EDA session. The mess is
# intentional and mirrors what actually arrives from a Google Form export.

n_f <- 120

likert <- c("Strongly disagree", "Disagree", "Neutral",
            "Agree", "Strongly agree")

faculty <- tibble(
  `Timestamp`               = sample(
    c("2026-03-14", "14/03/2026", "14-03-2026", "2026/03/15"),
    n_f, replace = TRUE),
  `Respondent ID`           = sprintf("F%03d", 1:n_f),
  `Department `             = sample(
    c("Community Medicine", "community medicine", "Physiology",
      "Paediatrics", "Pediatrics", " Anatomy", "Medical Education Unit"),
    n_f, replace = TRUE),
  `Years of Experience`     = as.character(pmax(0, round(rgamma(n_f, 3, 0.25)))),
  `Ever used R?`            = sample(c("Yes", "yes", "No", "no", "N", ""),
                                     n_f, replace = TRUE,
                                     prob = c(.12, .06, .5, .2, .1, .02)),
  `Confidence with stats (1-10)` = as.character(sample(1:10, n_f, replace = TRUE)),
  `Q1: I can reproduce my own analysis six months later` =
    sample(likert, n_f, replace = TRUE, prob = c(.18, .27, .25, .22, .08)),
  `Q2: I keep raw and cleaned data separate` =
    sample(likert, n_f, replace = TRUE, prob = c(.12, .22, .26, .28, .12)),
  `Q3: I would use AI tools to draft analysis code` =
    sample(likert, n_f, replace = TRUE, prob = c(.09, .15, .24, .34, .18)),
  `Hours spent on data cleaning per paper` =
    sample(c("2", "5", "10", "20", "40", "unknown", "NA", ""),
           n_f, replace = TRUE),
  `Comments` = sample(
    c("", "Very useful", "  needs more hands on time  ", "NA",
      "Please share slides", "-", "Would like a follow up session"),
    n_f, replace = TRUE)
)

# Add 12 duplicated rows and scatter them - a real export always has some
faculty_messy <- bind_rows(faculty, slice_sample(faculty, n = 12)) |>
  slice_sample(prop = 1)

write_csv(faculty_messy, "data/faculty_survey_raw.csv", na = "")

# 4. Codebook -----------------------------------------------------------------

codebook <- tribble(
  ~dataset,               ~variable,           ~type,        ~description,
  "meded_students.csv",   "student_id",        "character",  "Unique student identifier",
  "meded_students.csv",   "batch",             "character",  "Year of admission",
  "meded_students.csv",   "college",           "character",  "Medical college (3 sites)",
  "meded_students.csv",   "sex",               "character",  "Female / Male as self-reported",
  "meded_students.csv",   "age",               "numeric",    "Age in completed years",
  "meded_students.csv",   "rural_background",  "character",  "Rural / Urban domicile",
  "meded_students.csv",   "teaching_arm",      "character",  "Traditional lecture / Flipped classroom",
  "meded_students.csv",   "admission_score",   "numeric",    "Entrance percentile at admission (0-100)",
  "meded_students.csv",   "attendance_pct",    "numeric",    "Attendance across the module (%)",
  "meded_students.csv",   "pretest",           "numeric",    "Knowledge test before the module (0-100)",
  "meded_students.csv",   "posttest",          "numeric",    "Knowledge test after the module (0-100); 11 missing",
  "meded_students.csv",   "gain",              "numeric",    "posttest - pretest",
  "meded_students.csv",   "study_hours",       "numeric",    "Self-reported study hours per week",
  "meded_students.csv",   "burnout_score",     "numeric",    "Burnout scale 0-100, higher = worse; 7 missing",
  "meded_students.csv",   "burnout_band",      "character",  "Low (<35) / Moderate (35-60) / High (>60)",
  "meded_students.csv",   "satisfaction",      "numeric",    "Course satisfaction, 1-5 Likert",
  "meded_students.csv",   "passed",            "character",  "Yes if posttest >= 50",
  "osce_stations.csv",    "student_id",        "character",  "Links to meded_students.csv",
  "osce_stations.csv",    "station",           "character",  "Station code ST1-ST5",
  "osce_stations.csv",    "station_name",      "character",  "Station description",
  "osce_stations.csv",    "domain",            "character",  "Communication / Clinical / Procedural / Cognitive",
  "osce_stations.csv",    "examiner",          "character",  "Examiner code EX01-EX12",
  "osce_stations.csv",    "score",             "numeric",    "Station score, 0-20",
  "osce_stations.csv",    "max_score",         "numeric",    "Maximum possible (20)",
  "faculty_survey_raw.csv", "(various)",       "character",  "Raw Google Form export: untidy names, mixed date formats, duplicates, inconsistent categories"
)

write_csv(codebook, "data/codebook.csv")

# 5. Report -------------------------------------------------------------------

cat("\nDatasets written to data/\n")
cat(sprintf("  meded_students.csv      %4d rows x %2d cols\n",
            nrow(students), ncol(students)))
cat(sprintf("  osce_stations.csv       %4d rows x %2d cols\n",
            nrow(osce), ncol(osce)))
cat(sprintf("  faculty_survey_raw.csv  %4d rows x %2d cols\n",
            nrow(faculty_messy), ncol(faculty_messy)))
cat(sprintf("  codebook.csv            %4d rows\n\n", nrow(codebook)))
cat("Seed: 20260909. Re-running reproduces these files byte for byte.\n")
