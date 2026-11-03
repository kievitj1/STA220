# scripts/master.R
# Reruns everything: the made-up data in data/, the thirteen example figures in output/figures/, and
# output/example_figures_all.pdf (one example per page, for the class discussion before the activity).
# Restart R first (Session > Restart R), then source this file from the project.
#
# Not included: create_your_visualization_here.R (yours to fill in).

source("scripts/01_make_data.R")             # the made-up data (the same numbers every time)

# One script per example, from simplest to most complex. Examples 3, 6, 11, and 13 are maps.
source("scripts/example_figures/example_01_cost.R")

source("scripts/example_figures/example_02_traffic.R")

source("scripts/example_figures/example_03_crash_map.R")

source("scripts/example_figures/example_04_traffic_over_time.R")

source("scripts/example_figures/example_05_growth.R")

source("scripts/example_figures/example_06_traffic_map.R")

source("scripts/example_figures/example_07_count_vs_rate.R")

source("scripts/example_figures/example_08_rush_hour.R")

source("scripts/example_figures/example_09_severity.R")

source("scripts/example_figures/example_10_tradeoffs.R")

source("scripts/example_figures/example_11_growth_and_serious_map.R")

source("scripts/example_figures/example_12_value.R")

source("scripts/example_figures/example_13_town_rate_map.R")

# All thirteen in one PDF, one per page
pdf("output/example_figures_all.pdf", width = 8, height = 5.5)

all_figures <- list(fig_01, fig_02, fig_03, fig_04, fig_05, fig_06, fig_07, fig_08, fig_09, fig_10, fig_11, fig_12, fig_13)

for (fig in all_figures) {
  print(fig)
}

dev.off()

list.files("output/figures")
