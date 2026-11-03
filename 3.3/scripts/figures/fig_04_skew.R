# scripts/figures/fig_04_skew.R
# Figure 4: every New Jersey town in five equal intervals and in five quantiles.
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

nj_counties <- read_sf("data/boundaries/nj_counties.gpkg")

mercer_county <- nj_counties |>
  filter(COUNTYFP == "021")

# A town with no budget (or a zero) gets NA, not a rate of 0
nj_rates <- nj_towns_2025 |>
  mutate(per_resident = if_else(budget_m > 0 & pop > 0, budget_m * 1000000 / pop, NA_real_))

state_values <- nj_rates$per_resident

breaks_equal_nj <- seq(min(state_values, na.rm = TRUE), max(state_values, na.rm = TRUE), length.out = 6)

breaks_quantile_nj <- quantile(state_values, probs = seq(0, 1, 0.2), na.rm = TRUE)

# The labels are typed from the rounded breaks
nj_classes <- nj_rates |>
  mutate(
    class_equal = cut(
      per_resident,
      breaks = breaks_equal_nj,
      include.lowest = TRUE,
      labels = c("$69 to $20,055", "$20,055 to $40,042", "$40,042 to $60,028",
                 "$60,028 to $80,014", "$80,014 to $100,000")
    ),
    class_quantile = cut(
      per_resident,
      breaks = breaks_quantile_nj,
      include.lowest = TRUE,
      labels = c("$69 to $1,154", "$1,154 to $1,542", "$1,542 to $1,843",
                 "$1,843 to $2,428", "$2,428 to $100,000")
    )
  )

# drop = FALSE shows the empty bins in the legend too
equal_nj <- ggplot(nj_classes) +
  geom_sf(aes(fill = class_equal), colour = "grey70", linewidth = 0.05) +
  geom_sf(data = mercer_county, fill = NA, colour = "black", linewidth = 0.5) +
  scale_fill_brewer(palette = "Blues", na.value = "grey85", drop = FALSE) +
  labs(title = "A: equal intervals (five bins)", fill = NULL) +
  theme_void(base_size = 7)

quantile_nj <- ggplot(nj_classes) +
  geom_sf(aes(fill = class_quantile), colour = "grey70", linewidth = 0.05) +
  geom_sf(data = mercer_county, fill = NA, colour = "black", linewidth = 0.5) +
  scale_fill_brewer(palette = "Blues", na.value = "grey85") +
  labs(title = "B: quantiles (five bins)", fill = NULL) +
  theme_void(base_size = 7)

fig_04 <- equal_nj + quantile_nj +
  plot_annotation(caption = "General budget per resident, 2025, every New Jersey town. Gray: no budget filed.\nMercer outlined. Source: NJ DCA, UFB Database")

fig_04

ggsave("output/figures/fig_04_skew.png", fig_04, width = 6.6, height = 3.6, bg = "white")
