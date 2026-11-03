# scripts/figures/fig_08_school_districts.R
# Figure 8: Mercer's nine school districts over its twelve towns.
#
# Source: U.S. Census Bureau, cartographic boundary files: towns and unified school districts (2022)
#         https://www.census.gov/geographies/mapping-files/time-series/geo/cartographic-boundary.html

library(tidyverse)
library(sf)

# Labels need a flat map, so both go on New Jersey's projection (EPSG:3424)
nj_towns <- read_sf("data/boundaries/nj_towns.gpkg") |>
  st_transform(3424)

nj_districts <- read_sf("data/boundaries/nj_school_districts.gpkg") |>
  st_transform(3424)

mercer <- nj_towns |>
  filter(COUNTYFP == "021")

ewing <- mercer |>
  filter(NAMELSAD == "Ewing township")

# The nine districts that serve a Mercer town (each district's website lists its towns)
mercer_district_names <- c(
  "East Windsor Regional School District",
  "Ewing Township School District",
  "Hamilton Township School District",
  "Hopewell Valley Regional School District",
  "Lawrence Township School District",
  "Princeton Public Schools",
  "Robbinsville Township School District",
  "Trenton City School District",
  "West Windsor-Plainsboro Regional School District"
)

# st_filter() keeps the districts that touch Mercer. NOTE: there is another Lawrence Township
# School District, in Cumberland County! Shorter names make the labels fit.
mercer_districts <- nj_districts |>
  filter(NAME %in% mercer_district_names) |>
  st_filter(mercer) |>
  mutate(short = str_remove_all(NAME, " School District| Public Schools| Regional| Township| City"))

fig_08 <- ggplot() +
  geom_sf(data = mercer, fill = "grey95", colour = "grey40") +
  geom_sf(data = ewing, fill = "grey75", colour = "grey40") +
  geom_sf(data = mercer_districts, fill = NA, colour = "#2166ac", linewidth = 0.9) +
  geom_sf(data = mercer, fill = NA, colour = "grey30", linewidth = 0.25) +
  geom_sf_text(data = mercer_districts, aes(label = short), size = 2.2, colour = "#2166ac") +
  labs(
    title = "Nine school districts for twelve towns, and one that leaves the county",
    subtitle = "Town lines in gray (Ewing filled); unified school districts in blue",
    caption = "Source: U.S. Census Bureau, cartographic boundary files: towns and unified school districts (2022)"
  ) +
  theme_void(base_size = 7)

fig_08

ggsave("output/figures/fig_08_school_districts.png", fig_08, width = 5.6, height = 4.4, bg = "white")
