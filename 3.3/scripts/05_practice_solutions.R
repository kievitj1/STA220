# scripts/05_practice_solutions.R
# One way to do each Practice in R task. Look only after you have tried!
# Most of this code was copied from scripts/figures/fig_06_election.R!


#  Packages and Load the Data ---------------------------------------------------------------------

library(tidyverse)
library(sf)

nj12_towns <- read_sf("data/boundaries/nj12_towns.gpkg")

house <- read_csv(
  "data/house_2024_nj12_town.csv",
  col_types = cols(geoid = col_character())
)


#  Plan It in English ------------------------------------------------------------

# This is just one way to write the steps in plain English. Your steps may be different, but they should be similar.
#   Step 1: Read the data and run the three checks on each
#   Step 2: Check that geoid is a key
#   Step 3: Predict the dimensions, then join with the map on left
#   Step 4: Graph 1: shade each town by its winner (appropriate title and labels and captions)
#   Step 5: Graph 2: shade each town by the margin in percentage points  (appropriate title and labels and captions)
#   Step 6: Graph 3: use geom_col() to get sorted bars showing margin count
#   Step 7: Write a title that states the finding for each graph, and save them
# 



#  Get the Data Ready ------------------------------------------------------------

# Step 1. One row is one town. Expect 32 rows and 15 columns (14 fields and the shape).
dim(nj12_towns)
names(nj12_towns)
summary(nj12_towns)

# One row is one town. Expect 32 rows and 12 columns.
dim(house)
names(house)
summary(house)

# Step 2. 0 rows: geoid is a key
house |>
  count(geoid) |>
  filter(n > 1)

# Step 3. Predict 32 rows and 26 columns (15 + 12, with the key kept once)
nj12_vote <- nj12_towns |>
  left_join(house, by = c("GEOID" = "geoid"))

dim(nj12_vote)
names(nj12_vote)
summary(nj12_vote)

class(nj12_vote)                     # "sf": still a map



#  Figure 1 -----------------------------------------------------

# Set colors
party_colours <- c("Watson Coleman" = "#2166ac", "Mayfield" = "#b2182b")

# Create graph 1
ggplot(nj12_vote) +
  geom_sf(aes(fill = winner), colour = "white") +
  scale_fill_manual(values = party_colours) +
  labs(
    title = "Watson Coleman won 24 of the district's 32 towns",
    fill = "Won the town",
    caption = "Old Bridge, Bridgewater, and Hillsborough are only partly in the district.\nSource: NJ Division of Elections, 2024 general election for the U.S. House, 12th District"
  ) +
  theme_void()


#  Figure 2 -----------------------------------------------------------


# Create graph 2
ggplot(nj12_vote) +
  geom_sf(aes(fill = margin_pct), colour = "white") +
  scale_fill_gradient2(low = "#b2182b", mid = "white", high = "#2166ac", midpoint = 0) +
  labs(
    title = "Watson Coleman won Trenton by 70 points; Mayfield won Helmetta by 25",
    fill = "Margin\n(points)",
    caption = "Positive: Watson Coleman ahead.\nSource: NJ Division of Elections, 2024 U.S. House, 12th District"
  ) +
  theme_void()


#  Figure 3  ---------------------------------------------------


# Create graph 3
ggplot(house, aes(x = margin, y = fct_reorder(town, margin), fill = winner)) +
  geom_col() +
  scale_fill_manual(values = party_colours) +
  scale_x_continuous(labels = scales::comma) +
  labs(
    title = "Watson Coleman's biggest margins: Franklin, Trenton, Plainfield",
    x = "Watson Coleman's votes minus Mayfield's votes",
    y = "Town",
    fill = "Won the town",
    caption = "Source: NJ Division of Elections, 2024 general election for the U.S. House, 12th District"
  ) +
  theme_minimal()


