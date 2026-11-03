# scripts/examples/example_3_category.R
# Example 3: color each town by a category (here, the type of town).
# Source: NJ DCA, User Friendly Budget Database (2025), joined to the Census town boundaries (2022)

library(tidyverse)
library(sf)

towns <- read_sf("data/nj_towns_2025.gpkg")

mercer <- towns |>
  filter(county == "Mercer")

ggplot(mercer) +
  geom_sf(aes(fill = type)) +
  labs(title = "Mercer County's towns by type", fill = "Type") +
  theme_void()
