# scripts/03_join_budgets.R
# Joins the 2025 budgets to the town map on a code key. Writes data/nj_towns_2025.gpkg, which
# Figures 2 to 5 read (and the 3.4 project copies for the dashboards).
#
# Sources:
#   U.S. Census Bureau, cartographic boundary files, 2022 (data/boundaries/nj_towns.gpkg)
#     https://www.census.gov/geographies/mapping-files/time-series/geo/cartographic-boundary.html
#   NJ Office of GIS, Municipal Boundaries of NJ, the crosswalk (data/muni_codes.csv)
#     https://njogis-newjersey.opendata.arcgis.com/datasets/newjersey::municipal-boundaries-of-nj
#   NJ DCA, User Friendly Budget (UFB) Database, 2025, from 3.2 (data/nj_2025.csv)
#     https://datahub.dca.nj.gov/datasets/user-friendly-budget-database


# Packages and Load the Data ---------------------------------------------------------------------

library(tidyverse)
library(sf)

nj_towns <- read_sf("data/boundaries/nj_towns.gpkg")

muni_codes <- read_csv(
  "data/muni_codes.csv",
  col_types = cols(
    muni_code = col_character(),     # "0101", not 101
    tax_code = col_character(),
    geoid = col_character(),
    gnis = col_character()
  )
)

nj_2025 <- read_csv(
  "data/nj_2025.csv",
  col_types = cols(muni_code = col_character())
)

# One row is one town. Expect 564 rows and 15 columns.
dim(nj_towns)
names(nj_towns)
summary(nj_towns)

# One row is one town. Expect 565 rows (this copy still has Pine Valley) and 8 columns.
dim(muni_codes)
names(muni_codes)
summary(muni_codes)

# One row is one town's 2025 budget. Expect 564 rows and 18 columns.
dim(nj_2025)
names(nj_2025)
summary(nj_2025)


# Before Every Join ------------------------------------------------------------------------------

# key checks: 0 rows each
nj_2025 |>
  count(muni_code) |>
  filter(n > 1)

muni_codes |>
  count(muni_code) |>
  filter(n > 1)

nj_towns |>
  st_drop_geometry() |>
  count(GEOID) |>
  filter(n > 1)

# anti_join() both ways. 
anti_join(nj_2025, muni_codes, by = "muni_code")              # 0 rows

anti_join(muni_codes, nj_2025, by = "muni_code")              # 1 row: Pine Valley


# The Join: Shapes on the Left -------------------------------------------------------------------

# Step 1: give the budgets their Census code
geoid_lookup <- muni_codes |>
  select(muni_code, geoid)

nj_keyed <- nj_2025 |>
  left_join(geoid_lookup, by = "muni_code")

# Expect 564 rows and 19 columns, and no NA in geoid
dim(nj_keyed)
names(nj_keyed)
summary(nj_keyed)

# Step 2: shapes on the left, so the result is still a map
nj_towns_2025 <- nj_towns |>
  left_join(nj_keyed, by = c("GEOID" = "geoid"))

# Expect 564 rows and 33 columns (15 + 19, with the key kept once)
dim(nj_towns_2025)
names(nj_towns_2025)
summary(nj_towns_2025)

class(nj_towns_2025)                 # "sf": still a map

# Check a column that is in both but is not the key: the town's name
nj_towns_2025 |>
  st_drop_geometry() |>
  filter(NAMELSAD != town) |>
  select(GEOID, NAMELSAD, town)      # 2 rows, each one town written two ways (Princeton, Atlantic City)

st_write(nj_towns_2025, "data/nj_towns_2025.gpkg", delete_dsn = TRUE, quiet = TRUE)
