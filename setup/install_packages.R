# install_packages.R ----------------------------------------------------------
# Installs everything needed for the workshop and to build the site.
# Run once:  Rscript _setup/install_packages.R
# -----------------------------------------------------------------------------

pkgs <- c(
  # Core
  "tidyverse", "here", "janitor",
  # Tables
  "gtsummary", "gt", "flextable",
  # Reporting
  "quarto", "knitr", "rmarkdown", "rstudioapi",
  # Data and extras
  "skimr", "scales", "patchwork", "MASS"
)

missing <- setdiff(pkgs, rownames(installed.packages()))

if (length(missing) == 0) {
  message("All packages already installed.")
} else {
  message("Installing: ", paste(missing, collapse = ", "))
  install.packages(missing, repos = "https://cloud.r-project.org")
}

# Optional: PDF output
# install.packages("tinytex"); tinytex::install_tinytex()

failed <- setdiff(pkgs, rownames(installed.packages()))
if (length(failed) > 0) {
  stop("Failed to install: ", paste(failed, collapse = ", "))
}
message("Done. Now run: Rscript R/00_generate_datasets.R")
