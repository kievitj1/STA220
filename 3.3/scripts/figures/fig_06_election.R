# scripts/figures/fig_06_election.R
# Figure 6: the 2025 governor's race by county: the winner, the margin, and the bars.
#
# Sources:
#   NJ Division of Elections, 2025 general election for Governor, official results by county
#     (data/governor_2025_county.csv, made by 02_import.R)
#     https://nj.gov/state/elections/assets/pdf/election-results/2025/2025-official-general-results-governor.pdf
#     https://nj.gov/state/elections/assets/pdf/election-results/2025/2025-official-general-voter-turnout.pdf
#   U.S. Census Bureau, cartographic boundary files, 2022 (the counties)
#     https://www.census.gov/geographies/mapping-files/time-series/geo/cartographic-boundary.html

library(tidyverse)
library(sf)
library(patchwork)

nj_counties <- read_sf("data/boundaries/nj_counties.gpkg")

governor <- read_csv(
  "data/governor_2025_county.csv",
  col_types = cols(county_fips = col_character())    # "021", not 21
)

# Check the dimensions of nj counties
dim(nj_counties)
names(nj_counties)
summary(nj_counties)

# One row is one county. 
dim(governor)
names(governor)
summary(governor)


# Shapes on the left
counties_2025 <- nj_counties |>
  left_join(governor, by = c("COUNTYFP" = "county_fips"))

party_colours <- c("Sherrill" = "#2166ac", "Ciattarelli" = "#b2182b")

winner_map <- ggplot(counties_2025) +
  geom_sf(aes(fill = winner), colour = "white") +
  scale_fill_manual(values = party_colours) +
  labs(title = "A: who won each county", fill = NULL) +
  theme_void(base_size = 7)

margin_map <- ggplot(counties_2025) +
  geom_sf(aes(fill = margin_pct), colour = "white") +
  scale_fill_gradient2(low = "#b2182b", mid = "white", high = "#2166ac", midpoint = 0, limits = c(-55, 55)) +
  labs(title = "B: by how much (points)", fill = NULL) +
  theme_void(base_size = 7)

margin_bars <- ggplot(counties_2025, aes(x = margin, y = fct_reorder(county, margin), fill = winner)) +
  geom_col() +
  scale_fill_manual(values = party_colours) +
  scale_x_continuous(labels = scales::comma) +
  labs(title = "C: the margin, in votes", x = "Sherrill minus Ciattarelli", y = NULL) +
  theme_minimal(base_size = 7) +
  theme(legend.position = "none")

fig_06 <- winner_map + margin_map + margin_bars +
  plot_layout(widths = c(1, 1, 1.1)) +
  plot_annotation(caption = "2025 general election for Governor, official results by county. Source: NJ Division of Elections")

fig_06

ggsave("output/figures/fig_06_election.png", fig_06, width = 6.6, height = 3.4, bg = "white")
