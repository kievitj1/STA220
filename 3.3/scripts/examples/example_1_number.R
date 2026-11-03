# scripts/examples/example_1_number.R
# Example 1: shade each town by a number (here, its population).
# Source: NJ DCA, User Friendly Budget Database (2025), joined to the Census town boundaries (2022)

library(tidyverse)
library(sf)

towns <- read_sf("data/nj_towns_2025.gpkg")

mercer <- towns |>
  filter(county == "Mercer")

ggplot(mercer) +
  geom_sf(aes(fill = pop)) +
  scale_fill_distiller(palette = "Blues", direction = 1) +
  labs(title = "Population of Mercer County's towns", fill = "Residents") +
  theme_void()
