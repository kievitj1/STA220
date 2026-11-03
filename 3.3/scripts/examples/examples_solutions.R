# scripts/examples/examples_solutions.R
# One way to do Q21 to Q25 (Module 3.3 Practice, Part 2: Copy, Then Change). Each one copies one
# example and changes a few words. Look only after you have tried!
# Source: NJ DCA, User Friendly Budget Database (2025), joined to the Census town boundaries (2022)

library(tidyverse)
library(sf)

towns <- read_sf("data/nj_towns_2025.gpkg")

mercer <- towns |>
  filter(county == "Mercer")


# Q21. Which example would you start from? (no code) ----------------------------------------------

# Each town's state aid as a comparable number: Example 2 (a rate: state_aid_m / pop)
# Towns by whether they have a police department: Example 3 (a category, e.g., police_ft > 0)
# Whether towns closer to Trenton receive more state aid per resident: Example 2 (a rate, on a map)
# Tax rates above or below the median town: Example 4 (a midpoint)
# Which towns have the most full-time employees: Example 5 (sorted bars; Example 1 if you want "where")


# Q22. Sorted bars of each town's budget (Example 5: change pop to budget_m) ----------------------

ggplot(mercer, aes(x = budget_m, y = fct_reorder(town, budget_m))) +
  geom_col() +
  labs(title = "General budget of Mercer County's towns, 2025", x = "Millions of dollars", y = NULL) +
  theme_minimal()


# Q23. Burlington's towns by type (Example 3: change the county) ---------------------------------

burlington <- towns |>
  filter(county == "Burlington")

ggplot(burlington) +
  geom_sf(aes(fill = type)) +
  labs(title = "Burlington County's towns by type", fill = "Type") +
  theme_void()


# Q24. Full-time employees per 1,000 residents (Example 2: change the rate) ----------------------

mercer_rate <- mercer |>
  mutate(employees_per_1000 = ft_employees / pop * 1000)

ggplot(mercer_rate) +
  geom_sf(aes(fill = employees_per_1000)) +
  scale_fill_distiller(palette = "Blues", direction = 1) +
  labs(title = "Full-time town employees per 1,000 residents", fill = "Employees") +
  theme_void()


# Q25. Density, with white at the median NJ town (Example 4: change the column and the midpoint) -

# white is the median NJ town (about 2,244 people per square mile)
density_median <- median(towns$density, na.rm = TRUE)

ggplot(mercer) +
  geom_sf(aes(fill = density)) +
  scale_fill_gradient2(low = "red", mid = "white", high = "blue",
                       midpoint = density_median) +
  labs(title = "People per square mile", fill = "People") +
  theme_void()


# Extra practice (not in the workbook): Hunterdon's towns by land area (Example 1) ---------------

hunterdon <- towns |>
  filter(county == "Hunterdon")

ggplot(hunterdon) +
  geom_sf(aes(fill = land_sqmi)) +
  scale_fill_distiller(palette = "Blues", direction = 1) +
  labs(title = "Land area of Hunterdon County's towns", fill = "Square miles") +
  theme_void()
