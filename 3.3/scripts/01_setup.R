# scripts/01_setup.R
# Setup check for 3.3. Run before class on November 3.


# Install the Two New Packages -------------------------------------------------------------------

# sf reads and draws maps, and tigris downloads boundary files from the Census Bureau. These lines
# install each one only if you do not have it yet.
if (!requireNamespace("sf", quietly = TRUE)) install.packages("sf")

if (!requireNamespace("tigris", quietly = TRUE)) install.packages("tigris")

library(tidyverse)
library(sf)       # maps: a data table with a shape column


# Load the Data ----------------------------------------------------------------------------------

# Every town in New Jersey, already downloaded and saved in data/boundaries/
# see 02_import for creation of nj_towns.gpkg 
nj_towns <- read_sf("data/boundaries/nj_towns.gpkg")

# One row is one town. Expect 564 rows and 15 columns.
dim(nj_towns)
names(nj_towns)
summary(nj_towns)


# The Check --------------------------------------------------------------------------------------

# If a map of New Jersey shows up in the Plots pane, you are set!
ggplot(nj_towns) +
  geom_sf()


# The Download Check (optional) ------------------------------------------------------------------

# You do not need the internet in class. This line checks that tigris can download a boundary
# file on your computer, which you may want for your dashboard. Expect 21 rows (for each county)
library(tigris)

nj_counties_check <- counties(state = "NJ", cb = TRUE, year = 2022)

dim(nj_counties_check)
