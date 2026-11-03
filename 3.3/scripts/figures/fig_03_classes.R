# scripts/figures/fig_03_classes.R
# Figure 3: one number three ways: a continuous scale, equal intervals, and quantiles.
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
  mutate(per_resident = budget_m * 1000000 / pop)

per_resident <- mercer$per_resident

breaks_equal <- seq(min(per_resident), max(per_resident), length.out = 5)

breaks_quantile <- quantile(per_resident, probs = c(0, 0.25, 0.5, 0.75, 1))

# The labels are typed from the rounded breaks
mercer_classes <- mercer |>
  mutate(
    class_equal = cut(
      per_resident,
      breaks = breaks_equal,
      include.lowest = TRUE,
      labels = c("$831 to $1,338", "$1,338 to $1,846", "$1,846 to $2,353", "$2,353 to $2,860")
    ),
    class_quantile = cut(
      per_resident,
      breaks = breaks_quantile,
      include.lowest = TRUE,
      labels = c("lowest 3 towns", "towns 4 to 6", "towns 7 to 9", "highest 3")
    )
  )

continuous <- ggplot(mercer_classes) +
  geom_sf(aes(fill = per_resident), colour = "white") +
  scale_fill_distiller(palette = "Blues", direction = 1) +
  labs(title = "A: continuous", fill = "$") +
  theme_void(base_size = 7) +
  theme(legend.key.height = unit(7, "pt"))   # a shorter color bar, so it clears the caption

equal <- ggplot(mercer_classes) +
  geom_sf(aes(fill = class_equal), colour = "white") +
  scale_fill_brewer(palette = "Blues") +
  labs(title = "B: equal intervals", fill = NULL) +
  theme_void(base_size = 7)

quantiles <- ggplot(mercer_classes) +
  geom_sf(aes(fill = class_quantile), colour = "white") +
  scale_fill_brewer(palette = "Blues") +
  labs(title = "C: quantiles", fill = NULL) +
  theme_void(base_size = 7)

fig_03 <- continuous + equal + quantiles +
  plot_annotation(caption = "General budget per resident, 12 Mercer County towns, 2025. Source: NJ DCA, UFB Database")

fig_03

ggsave("output/figures/fig_03_classes.png", fig_03, width = 6.6, height = 2.6, bg = "white")
