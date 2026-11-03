# scripts/examples/example_5_bars.R
# Example 5: sorted bars, one bar per town.
# Source: NJ DCA, User Friendly Budget Database (2025), joined to the Census town boundaries (2022)

library(tidyverse)
library(sf)

towns <- read_sf("data/nj_towns_2025.gpkg")

mercer <- towns |>
  filter(county == "Mercer")

ggplot(mercer, aes(x = pop, y = fct_reorder(town, pop))) +
  geom_col() +
  labs(title = "Population of Mercer's towns", x = "Residents", y = NULL) +
  theme_minimal()
