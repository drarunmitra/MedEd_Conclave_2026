# private/

Working files that belong with the project but must never be published.

This directory is in neither the `render:` list nor the `resources:` list in
`_quarto.yml`, and it is git-ignored. Nothing here reaches `_site`.

Use it for real datasets, drafts, and anything received from a third party.

## Why it exists

`data/**` and `admin/**` are both listed under `resources:`, so Quarto copies
them into `_site` verbatim, with no render step and no warning. A file dropped
into `data/` to look at later is published the next time the site is deployed.

The exposure is intermittent, which is what makes it easy to miss: CI renders
from a clean checkout and will not upload an untracked file, but a local
`quarto publish` uploads whatever is on disk.

## Contents

- `BLS INSIGHT - Final Data for Quanti workshop.xlsx`, moved out of `data/` on
  2026-08-17. It was untracked, referenced by nothing in the site, and appears
  to be real data from a different workshop.
