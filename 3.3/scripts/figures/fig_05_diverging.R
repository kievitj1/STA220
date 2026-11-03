# scripts/figures/fig_05_diverging.R
# Figure 5: a diverging scale around a benchmark (the median New Jersey town).
#
# Sources:
#   NJ DCA, UFB Database, 2025, joined to the map by 03_join_budgets.R (data/nj_towns_2025.gpkg)
#     https://datahub.dca.nj.gov/datasets/user-friendly-budget-database
#   U.S. Census Bureau, cartographic boundary files, 2022
#     https://www.census.gov/geographies/mapping-files/time-series/geo/cartographic-boundary.html
#   The median NJ town's budget per resident, by year, from 3.2 (data/state_by_year.csv)

library(tidyverse)
library(sf)

nj_towns_2025 <- read_sf("data/nj_towns_2025.gpkg")

nj_counties <- read_sf("data/boundaries/nj_counties.gpkg")

state_by_year <- read_csv("data/state_by_year.csv")

mercer_county <- nj_counties |>
  filter(COUNTYFP == "021")

# The benchmark: the median NJ town in 2025 ($1,679), from 3.2's table
median_2025 <- state_by_year |>
  filter(year == 2025)

median_town <- median_2025$median_per_resident

# Towns above $4,000 are drawn as $4,000 so that Tavistock does not take over the scale
nj_vs_median <- nj_towns_2025 |>
  mutate(
    per_resident = if_else(budget_m > 0 & pop > 0, budget_m * 1000000 / pop, NA_real_),
    capped = if_else(per_resident > 4000, 4000, per_resident),
    vs_median = capped - median_town
  )

fig_05 <- ggplot(nj_vs_median) +
  geom_sf(aes(fill = vs_median), colour = "grey70", linewidth = 0.05) +
  geom_sf(data = mercer_county, fill = NA, colour = "black", linewidth = 0.5) +
  scale_fill_gradient2(low = "#b2182b", mid = "white", high = "#2166ac", midpoint = 0, na.value = "grey85") +
  labs(
    title = "Towns above the median town cluster in the northeast and on the shore",
    subtitle = "2025 budget per resident minus the median town's $1,679; red below, blue above",
    fill = "$ vs. the\nmedian town",
    caption = "Values above $4,000 are drawn as $4,000. Gray: no budget filed. Mercer outlined.\nSource: NJ DCA, UFB Database, 2025"
  ) +
  theme_void(base_size = 7)

fig_05

ggsave("output/figures/fig_05_diverging.png", fig_05, width = 5.6, height = 4.4, bg = "white")
