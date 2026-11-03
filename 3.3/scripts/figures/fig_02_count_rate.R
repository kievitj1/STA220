# scripts/figures/fig_02_count_rate.R
# Figure 2: the Mercer towns shaded by a count (officers) and by a rate (per 1,000 residents).
#
# Sources:
#   NJ DCA, UFB Database, 2025, joined to the map by 03_join_budgets.R (data/nj_towns_2025.gpkg)
#     https://datahub.dca.nj.gov/datasets/user-friendly-budget-database
#   U.S. Census Bureau, cartographic boundary files, 2022
#     https://www.census.gov/geographies/mapping-files/time-series/geo/cartographic-boundary.html

library(tidyverse)
library(sf)
library(patchwork)

nj_towns_2025 <- read_sf("data/nj_towns_2025.gpkg")

mercer <- nj_towns_2025 |>
  filter(COUNTYFP == "021") |>
  mutate(police_per_1000 = police_ft / pop * 1000)

ewing <- mercer |>
  filter(town == "Ewing township")

count_map <- ggplot(mercer) +
  geom_sf(aes(fill = police_ft), colour = "white") +
  geom_sf(data = ewing, fill = NA, colour = "black", linewidth = 0.7) +
  scale_fill_distiller(palette = "Blues", direction = 1, na.value = "grey85") +
  labs(title = "A: a count", fill = "Full-time\nofficers") +
  theme_void(base_size = 8)

rate_map <- ggplot(mercer) +
  geom_sf(aes(fill = police_per_1000), colour = "white") +
  geom_sf(data = ewing, fill = NA, colour = "black", linewidth = 0.7) +
  scale_fill_distiller(palette = "Blues", direction = 1, na.value = "grey85") +
  labs(title = "B: a rate", fill = "Officers per\n1,000 residents") +
  theme_void(base_size = 8)

fig_02 <- count_map + rate_map +
  plot_annotation(caption = "Gray: no officer count reported (Trenton, Hightstown). Ewing outlined. Source: NJ DCA, UFB Database, 2025")

fig_02

ggsave("output/figures/fig_02_count_rate.png", fig_02, width = 6.4, height = 3.1, bg = "white")
