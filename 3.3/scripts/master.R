# scripts/master.R
# Reruns everything: the tables in data/ and every figure in output/figures/. Restart R first
# (Session > Restart R), then source this file from the project.
#
# NOTE: 02_import.R needs the internet (tigris downloads a few MB the first time). Everything it
# writes is already in data/, so put a # in front of it if you are offline.
# Not included: 01_setup.R (run it once by hand), 04_practice_in_r.R (yours to fill in), and the five
# example scripts in scripts/examples/ (run them one at a time).

source("scripts/02_import.R")                 # the raw sources into data/

source("scripts/03_join_budgets.R")           # the budgets joined to the map (Figures 2 to 5)

# One script per figure
source("scripts/figures/fig_01_counties.R")

source("scripts/figures/fig_02_count_rate.R")

source("scripts/figures/fig_03_classes.R")

source("scripts/figures/fig_04_skew.R")

source("scripts/figures/fig_05_diverging.R")

source("scripts/figures/fig_06_election.R")

source("scripts/figures/fig_07_circles.R")

source("scripts/figures/fig_08_school_districts.R")

source("scripts/figures/fig_09_describe.R")

source("scripts/figures/fig_10_examples.R")

source("scripts/05_practice_solutions.R")         # Practice in R solutions (output/house_margin.png)

source("scripts/examples/examples_solutions.R")   # Module 3.3 Practice, Part 2 solutions

list.files("output/figures")
