# scripts/figures/fig_07_circles.R
# Figure 7: a circle at each county's center, sized by the margin in votes.
#
# Sources:
#   NJ Division of Elections, 2025 general election for Governor, official results by county
#     (data/governor_2025_county.csv, made by 02_import.R)
#     https://nj.gov/state/elections/assets/pdf/election-results/2025/2025-official-general-results-governor.pdf
#   U.S. Census Bureau, cartographic boundary files, 2022 (the counties)
#     https://www.census.gov/geographies/mapping-files/time-series/geo/cartographic-boundary.html

library(tidyverse)
library(sf)

nj_counties <- read_sf("data/boundaries/nj_counties.gpkg")

governor <- read_csv(
  "data/governor_2025_county.csv",
  col_types = cols(county_fips = col_character())
)

counties_2025 <- nj_counties |>
  left_join(governor, by = c("COUNTYFP" = "county_fips"))

party_colours <- c("Sherrill" = "#2166ac", "Ciattarelli" = "#b2182b")

# NOTE: you will not need to learn this. st_centroid() swaps each county's shape for the point
# in its middle, and st_set_agr("constant") keeps it from warning.
county_centres <- counties_2025 |>
  st_set_agr("constant") |>
  st_centroid()

fig_07 <- ggplot() +
  geom_sf(data = counties_2025, fill = "grey95", colour = "grey60") +
  geom_sf(data = county_centres, aes(size = abs(margin), colour = winner), alpha = 0.7) +
  scale_colour_manual(values = party_colours) +
  scale_size_area(max_size = 12, labels = scales::comma) +
  labs(
    title = "The same 21 counties, with ink in proportion to the margin in votes",
    subtitle = "Essex's margin (133,178) is 64 times Cumberland's (2,076). On Figure 6A both are\nblue, and Cumberland gets almost four times Essex's ink.",
    size = "Margin (votes)",
    colour = NULL,
    caption = "2025 general election for Governor. Source: NJ Division of Elections"
  ) +
  theme_void(base_size = 7)

fig_07

ggsave("output/figures/fig_07_circles.png", fig_07, width = 5.6, height = 4.2, bg = "white")
