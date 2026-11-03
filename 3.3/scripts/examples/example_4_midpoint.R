# scripts/examples/example_4_midpoint.R
# Example 4: above or below a benchmark. White is the median New Jersey town ($1,344 of debt
# per resident).
# Source: NJ DCA, User Friendly Budget Database (2025), joined to the Census town boundaries (2022)

library(tidyverse)
library(sf)

towns <- read_sf("data/nj_towns_2025.gpkg")

mercer <- towns |>
  filter(county == "Mercer")

# white is the median NJ town ($1,344 of debt per resident)
debt_median <- median(towns$debt_per_resident, na.rm = TRUE)

ggplot(mercer) +
  geom_sf(aes(fill = debt_per_resident)) +
  scale_fill_gradient2(low = "red", mid = "white", high = "blue",
                       midpoint = debt_median) +
  labs(title = "Debt per resident", fill = "Dollars") +
  theme_void()
