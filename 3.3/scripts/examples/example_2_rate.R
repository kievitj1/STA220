# scripts/examples/example_2_rate.R
# Example 2: make a rate, then shade each town by it (officers per 1,000 residents).
# Source: NJ DCA, User Friendly Budget Database (2025), joined to the Census town boundaries (2022)

library(tidyverse)
library(sf)

towns <- read_sf("data/nj_towns_2025.gpkg")

mercer <- towns |>
  filter(county == "Mercer")

mercer_rate <- mercer |>
  mutate(police_per_1000 = police_ft / pop * 1000)

ggplot(mercer_rate) +
  geom_sf(aes(fill = police_per_1000)) +
  scale_fill_distiller(palette = "Blues", direction = 1) +
  labs(title = "Police officers per 1,000 residents", fill = "Officers") +
  theme_void()
