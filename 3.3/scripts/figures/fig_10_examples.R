# scripts/figures/fig_10_examples.R
# Figure 10: what each of the five example scripts in scripts/examples/ makes (small versions).
#
# Source: NJ DCA, User Friendly Budget Database (2025), joined to the Census town boundaries (2022)

library(tidyverse)
library(sf)
library(patchwork)   # puts plots side by side

towns <- read_sf("data/nj_towns_2025.gpkg")

mercer <- towns |>
  filter(county == "Mercer")

mercer_rate <- mercer |>
  mutate(police_per_1000 = police_ft / pop * 1000)

ex_1 <- ggplot(mercer) +
  geom_sf(aes(fill = pop)) +
  scale_fill_distiller(palette = "Blues", direction = 1, labels = scales::comma) +
  labs(title = "Example 1: a number", fill = "Residents") +
  theme_void(base_size = 7)

ex_2 <- ggplot(mercer_rate) +
  geom_sf(aes(fill = police_per_1000)) +
  scale_fill_distiller(palette = "Blues", direction = 1) +
  labs(title = "Example 2: a rate", fill = "Officers\nper 1,000") +
  theme_void(base_size = 7)

ex_3 <- ggplot(mercer) +
  geom_sf(aes(fill = type)) +
  labs(title = "Example 3: a category", fill = "Type") +
  theme_void(base_size = 7)

# white is the median NJ town ($1,344 of debt per resident)
debt_median <- median(towns$debt_per_resident, na.rm = TRUE)

ex_4 <- ggplot(mercer) +
  geom_sf(aes(fill = debt_per_resident)) +
  scale_fill_gradient2(low = "red", mid = "white", high = "blue", midpoint = debt_median) +
  labs(title = "Example 4: above or below a midpoint", fill = "Debt per\nresident ($)") +
  theme_void(base_size = 7)

ex_5 <- ggplot(mercer, aes(x = pop, y = fct_reorder(town, pop))) +
  geom_col() +
  scale_x_continuous(labels = scales::comma) +
  labs(title = "Example 5: sorted bars", x = "Residents", y = NULL) +
  theme_minimal(base_size = 7)

fig_10 <- (ex_1 + ex_2 + ex_3) / (ex_4 + ex_5) +
  plot_annotation(caption = "Mercer County's 12 towns. Gray: not reported. Source: NJ DCA, User Friendly Budget Database (2025)")

fig_10

ggsave("output/figures/fig_10_examples.png", fig_10, width = 6.6, height = 4.6, bg = "white")
