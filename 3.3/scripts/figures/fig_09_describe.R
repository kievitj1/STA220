# scripts/figures/fig_09_describe.R
# Figure 9: a Pine County map to describe (the rate, in quantile classes).
#
# Source: MADE UP. Pine County and its six towns do not exist (data/pine_county.csv, from 02_import.R).

library(tidyverse)

pine <- read_csv(
  "data/pine_county.csv",
  col_types = cols(town_code = col_character())    # "01", not 1
)

pine_rates <- pine |>
  mutate(
    ev_per_1000 = ev_ports / pop * 1000,
    x_mid = (xmin + xmax) / 2,
    y_mid = (ymin + ymax) / 2
  )

# The rate in three quantile classes, two towns each
rate_breaks <- quantile(pine_rates$ev_per_1000, probs = c(0, 1/3, 2/3, 1))

pine_classes <- pine_rates |>
  mutate(
    rate_class = cut(
      ev_per_1000,
      breaks = rate_breaks,
      include.lowest = TRUE,
      labels = c("lowest 2 towns", "middle 2", "highest 2")
    )
  )

# NOTE: the towns are rectangles, so geom_rect() can draw them without a shape column
fig_09 <- ggplot(pine_classes) +
  geom_rect(aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = rate_class), colour = "white") +
  geom_text(aes(x = x_mid, y = y_mid, label = town), size = 2.6) +
  scale_fill_brewer(palette = "Blues") +
  coord_equal() +
  labs(
    title = "Cedar and Fir have the most public EV charging ports per resident",
    subtitle = "Public charging ports per 1,000 residents, in three quantile classes",
    fill = NULL,
    caption = "Pine County is made up: the ports and the residents are invented for practice."
  ) +
  theme_void(base_size = 8)

fig_09

ggsave("output/figures/fig_09_describe.png", fig_09, width = 5.0, height = 3.2, bg = "white")
