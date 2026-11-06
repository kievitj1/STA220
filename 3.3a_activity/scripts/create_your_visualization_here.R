# scripts/create_your_visualization_here.R
# Activity 3.3a: Make the case for one bike lane.
#
# Pine County can afford ONE protected bike lane. Your group argues for ONE street:
#   Group 1: Market Street    Group 2: Ridge Road    Group 3: College Avenue    Group 4: Station Road
#
# To Do: copy everything under The Figure (and any steps above it that make a table or do a merge) from your example. Paste it under Your Figure.


# Packages and Load the Data ---------------------------------------------------------------------

library(tidyverse)
library(sf)

my_corridor <- "Market Street"           # CHANGE to your group's street (spelled exactly as above)

# One colour per street, if you want them
corridor_colours <- c(
  "Market Street"  = "#2a78d6",
  "Ridge Road"     = "#eb6834",
  "College Avenue" = "#1baf7a",
  "Station Road"   = "#eda100"
)

# The six towns of Pine County (a map background)
pine_towns <- read_sf("data/pine_towns.gpkg")

# One row is one town. Expect 6 rows and 7 columns
dim(pine_towns)
names(pine_towns)
summary(pine_towns)

# One row is one street, with its shape (a line). Expect 4 rows and 12 columns
bike_corridors <- read_sf("data/bike_corridors.gpkg")

dim(bike_corridors)
names(bike_corridors)
summary(bike_corridors)

# One row is one street in one year, 2023 to 2025. Expect 12 rows and 7 columns.
# Station Road's bike counter went in in January 2024, so its 2023 bikes_per_day is NA.
bike_yearly <- read_csv("data/bike_yearly.csv")

dim(bike_yearly)
names(bike_yearly)
summary(bike_yearly)

# One row is one street in one month, January 2023 to December 2025. Expect 144 rows and 6 columns
# (12 NA in bikes_per_day: Station Road in 2023)
bike_monthly <- read_csv("data/bike_monthly.csv")

dim(bike_monthly)
names(bike_monthly)
summary(bike_monthly)

# One row is one street in one hour of an average weekday in 2025. Expect 96 rows and 5 columns
bike_hourly <- read_csv("data/bike_hourly.csv")

dim(bike_hourly)
names(bike_hourly)
summary(bike_hourly)

# One row is one crash involving a bike, 2023 to 2025, with where it happened (a point).
# Expect 111 rows and 10 columns (town, x, and y say where it happened)
bike_crashes <- read_sf("data/bike_crashes.gpkg")

dim(bike_crashes)
names(bike_crashes)
summary(bike_crashes)


#  The Key (Use this to compare Highway to Bikes! -------------------------



#   In the examples                        In your data
#   highway_sections (one line each)       bike_corridors
#   highway_yearly (2016 to 2025)          bike_yearly (2023 to 2025), or bike_monthly for months
#   highway_hourly                         bike_hourly
#   highway_crashes (one point each)       bike_crashes
#   section, my_section, section_colours   corridor, my_corridor, corridor_colours
#   vehicles_per_day                       bikes_per_day (riders) or cars_per_day
#   vehicles_per_hour                      bikes_per_hour
#   avg_speed_mph, speed_limit             car_speed_mph, speed_limit
#   rush_delay_min, truck_pct              (nothing like them; try bikes_per_day or cars_per_day)
#   crashes, serious_crashes               crashes, serious_crashes
#   severity                               severity (the same three levels)
#   crash_type                             crash_type: dooring, turning car, passing car, other
#   town, x, y (on each crash)             town, x, y
#   cost_million, years_to_build           cost_million, years_to_build
#   homes_affected, wetland_acres          parking_lost, trees_removed
#   miles                                  miles
#   (not in the highway data)              connects_to, counted_since
#
#   Examples 5 and 11: names_prefix = "vehicles_" makes vehicles_2016 to vehicles_2025. Yours can be
#   names_prefix = "bikes_", which makes bikes_2023 to bikes_2025. Station Road has no 2023 count,
#   so its 2023 to 2025 change is NA: use 2024 to 2025, or say on the figure why it is missing.
#
#   Examples 5, 10, and 12 draw my_section again on top (the table called mine) in its own colour.
#   Use filter(corridor == my_corridor), and your street's colour from corridor_colours above.
#
#   A rate for bikes: crashes per 100,000 bike trips = crashes / (bikes_per_day x 365) x 100000
#   (drop the years with no count first: filter(!is.na(bikes_per_day)))
#
#   Remember to change the title, the axis labels, and the caption to fit your figure and your argument.


# Hints -------------------------------------------------------------------
# Hints
#   1. Check that you loaded the data by running the script above!
#   2. Highlight a word and other matching will e highlighted. 
#   3. Run your code one step at a time (or one pipe at a time)
#   5. A few examples need some hints:
#        Example 3    the streets are short, so try binwidth = 0.25
#        Example 7    use the bike rate in The Key (crashes per 100,000 bike trips)
#        Example 8    there is no bike speed: use car_speed_mph (keep geom_hline()), or
#                     bikes_per_hour (and delete the geom_hline() line)
#        Example 9    for Market Street, try fill = crash_type in place of severity
#        Example 12   there is no rush-hour delay for bikes: divide something else by
#                     cost_million (riders per $1 million, or crashes per $1 million)
#        Example 13   the hardest one: count(town) works on bike_crashes too, and Cedar and Fir
#                     (none of the four streets) come out grey
#   8. To show your figure to the class, click Zoom above the plot (or Export > Save as Image).


# Your Figure ------------------------------------------------------------------------------------
# Step 1: how many vehicles drive each section in the rush hours (7 and 8 a.m.; 4, 5, and 6 p.m.)
bikes_crashes_yearly <- bike_yearly |>
  group_by(corridor) |>
  summarize(crashes_per_year = mean(crashes))


# Step 3: put the problem next to the price. Minutes / 60 = hours, x 250 weekdays in a year.
value <- bike_corridors |>
  st_drop_geometry() |>
  select(corridor, cost_million) |>
  left_join(bikes_crashes_yearly, by = "corridor") |>
  mutate(
    bike_crashes_yearly_per_million = crashes_per_year / cost_million)

# Expect 4 rows, one per section
value

mine <- value |>
  filter(corridor == my_corridor)



fig_12 <- ggplot(value, aes(x = hours_per_million, y = fct_reorder(section, hours_per_million))) +
  geom_col(fill = "grey75") +
  geom_col(data = mine, fill = "#eda100") +
  scale_x_continuous(labels = scales::comma) +
  labs(
    title = "Birch Straightaway takes on the most rush-hour delay per dollar",
    subtitle = "Hours lost to rush hour in a year, for each $1 million it would cost to add a lane",
    x = "Hours of delay per $1 million",
    y = NULL,
    caption = "Hours lost = vehicles in the five rush hours x minutes of delay / 60 x 250 weekdays.\nMade-up data for practice. Pine County does not exist."
  ) +
  theme_minimal()

fig_12

ggsave("output/figures/example_12_value.png", fig_12, width = 7, height = 4.5, bg = "white")