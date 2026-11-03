# scripts/figures/fig_01_counties.R
# Figure 1: the 21 counties, and Mercer's 12 towns with their names.
#
# Source: U.S. Census Bureau, cartographic boundary files, 2022 (saved by 02_import.R)
#         https://www.census.gov/geographies/mapping-files/time-series/geo/cartographic-boundary.html

library(tidyverse)
library(sf)
library(patchwork)   # puts plots side by side

nj_counties <- read_sf("data/boundaries/nj_counties.gpkg")

nj_towns <- read_sf("data/boundaries/nj_towns.gpkg")

mercer_county <- nj_counties |>
  filter(COUNTYFP == "021")

# Labels need a flat map, so the towns go on New Jersey's projection (EPSG:3424)
mercer_3424 <- nj_towns |>
  filter(COUNTYFP == "021") |>
  st_transform(3424)

ewing_3424 <- mercer_3424 |>
  filter(NAMELSAD == "Ewing township")

hightstown_3424 <- mercer_3424 |>
  filter(NAMELSAD == "Hightstown borough")

others_3424 <- mercer_3424 |>
  filter(NAMELSAD != "Hightstown borough")

fig_01a <- ggplot(nj_counties) +
  geom_sf(fill = "grey95", colour = "grey50") +
  geom_sf(data = mercer_county, fill = "grey35") +
  labs(title = "A: 21 counties") +
  theme_void(base_size = 9)

# Hightstown sits inside East Windsor, so its label is nudged up (in feet)
fig_01b <- ggplot(mercer_3424) +
  geom_sf(fill = "grey95", colour = "grey40") +
  geom_sf(data = ewing_3424, fill = "grey35") +
  geom_sf_text(data = others_3424, aes(label = NAME), size = 2.2) +
  geom_sf_text(data = hightstown_3424, aes(label = NAME), size = 2.2, nudge_y = 7000) +
  labs(title = "B: Mercer's 12 towns, Ewing filled") +
  theme_void(base_size = 9)

fig_01 <- fig_01a + fig_01b + plot_layout(widths = c(1, 1.7))

fig_01

ggsave("output/figures/fig_01_counties.png", fig_01, width = 6.4, height = 3.4, bg = "white")
