# scripts/02_import.R
# Reads the raw sources and writes the tables and maps in data/.
#
#   Source 1: U.S. Census Bureau, cartographic boundary files (1:500,000). tigris downloads them.
#             Counties, towns (county subdivisions), and school districts: 2022.
#             https://www.census.gov/geographies/mapping-files/time-series/geo/cartographic-boundary.html
#             Out: data/boundaries/nj_counties.gpkg, nj_towns.gpkg, nj_school_districts.gpkg
#
#   Source 2: NJ Office of GIS, Municipal Boundaries of NJ (the table only, as a CSV)
#             https://njogis-newjersey.opendata.arcgis.com/datasets/newjersey::municipal-boundaries-of-nj
#             In:  data/raw/Municipal_Boundaries_of_NJ.csv
#             Out: data/muni_codes.csv (the crosswalk)
#
#   Source 3: NJ Division of Elections, 2025 general election for Governor, official results
#             Results:  https://nj.gov/state/elections/assets/pdf/election-results/2025/2025-official-general-results-governor.pdf
#             Turnout:  https://nj.gov/state/elections/assets/pdf/election-results/2025/2025-official-general-voter-turnout.pdf
#             In:  data/raw/governor_2025_by_county.csv, data/raw/turnout_2025_by_county.csv
#                  (See README for how to do this by hand)
#             Out: data/governor_2025_county.csv
#
#   Source 4: NJ Division of Elections, 2024 general election for the U.S. House of
#             Representatives, 12th Congressional District, official results by town (the district
#             TCNJ is in)
#             https://nj.gov/state/elections/assets/pdf/election-results/2024/2024-official-general-results-us-house-district12.pdf
#             In:  data/raw/house_2024_nj12_by_town.csv (typed from the PDF)
#             Out: data/house_2024_nj12_town.csv, data/boundaries/nj12_towns.gpkg
#
#   Pine County is MADE UP. 
#
#   The two tables from 3.2 (nj_2025 and state_by_year) are copied into data/ as they are. The 3.2
#   README has their links.
#
# NOTE: You do NOT need to run this. Everything it writes is already in data/. It also uses some
# commands I did not cover in class. The Appendix of the workbook does the same steps by hand.


# Packages ---------------------------------------------------------------------------------------

library(tidyverse)
library(sf)
library(tigris)

options(tigris_use_cache = TRUE)   # download each file once, then reuse it


# Source 1: Census Boundaries --------------------------------------------------------------------

# cb = TRUE: the generalized files, made for maps
# year = 2022
nj_counties <- counties(state = "NJ", cb = TRUE, year = 2022)

nj_towns <- county_subdivisions(state = "NJ", cb = TRUE, year = 2022)

nj_districts <- school_districts(state = "NJ", type = "unified", cb = TRUE, year = 2022)

# Expect 21, 564, and 340 rows
dim(nj_counties)
dim(nj_towns)
dim(nj_districts)

# Save each one as a GeoPackage (.gpkg) to keep the shapes
st_write(nj_counties, "data/boundaries/nj_counties.gpkg", delete_dsn = TRUE, quiet = TRUE)

st_write(nj_towns, "data/boundaries/nj_towns.gpkg", delete_dsn = TRUE, quiet = TRUE)

st_write(nj_districts, "data/boundaries/nj_school_districts.gpkg", delete_dsn = TRUE, quiet = TRUE)


# Source 2: The Crosswalk ------------------------------------------------------------------------

muni_raw <- read_csv(
  "data/raw/Municipal_Boundaries_of_NJ.csv",
  col_types = cols(.default = col_character())     # every column as text!
)

# One row is one town. Expect 565 rows (this copy is from 2021)
dim(muni_raw)
names(muni_raw)

# NOTE: older copies call the Census column CENSUS2010; the current one calls it CENSUS2020.
# This copy has CENSUS2010. Change it below if yours says CENSUS2020.
muni_codes <- muni_raw |>
  mutate(
    muni_code = SSN,                       # DCA's code (the UFB's muni_code)
    tax_code = MUN_CODE,                   # the Division of Taxation's code (3.2's tax table)
    geoid = CENSUS2010,                    # the Census code (the boundaries' GEOID)
    gnis = GNIS,                           # the USGS code
    town = MUN_LABEL,
    county = str_to_title(COUNTY),         # "MERCER" becomes "Mercer"
    type = MUN_TYPE,
    sq_miles = round(as.numeric(SQ_MILES), 2)
  ) |>
  select(muni_code, tax_code, geoid, gnis, town, county, type, sq_miles) |>
  arrange(muni_code)

# Expect 565 rows and 8 columns
dim(muni_codes)
names(muni_codes)
summary(muni_codes)

# key checks: 0 rows each
muni_codes |>
  count(muni_code) |>
  filter(n > 1)

muni_codes |>
  count(geoid) |>
  filter(n > 1)

write_csv(muni_codes, "data/muni_codes.csv")


# Source 3: The 2025 Governor's Race -------------------------------------------------------------

votes <- read_csv("data/raw/governor_2025_by_county.csv")

turnout <- read_csv("data/raw/turnout_2025_by_county.csv")

# Expect 21 rows each
dim(votes)
dim(turnout)

# Check these against the totals printed on the PDFs
sum(votes$sherrill_dem)            # 1,896,610
sum(votes$ciattarelli_rep)         # 1,417,705
sum(turnout$registered_voters)     # 6,549,793
sum(turnout$ballots_cast)          # 3,369,507

# The county's Census code and land area come from the boundaries, matched on the name
county_lookup <- nj_counties |>
  st_drop_geometry() |> # gets rid of the geometry data
  mutate(
    county = NAME,
    county_fips = COUNTYFP,                       # "021", as text
    land_sqmi = round(ALAND / 2589988, 1)         # square meters to square miles
  ) |>
  select(county, county_fips, land_sqmi)

# one mile = 5280 ft * 0.3048 m/ft = 1609.344 m
# 1609.344 * 1609.344 = 2,589,988 square meters in one square mile


governor_2025 <- votes |>
  left_join(turnout, by = "county") |>
  left_join(county_lookup, by = "county") |>
  mutate(
    total_votes = sherrill_dem + ciattarelli_rep + kaplan_lib + kuniansky_swp,
    winner = if_else(sherrill_dem > ciattarelli_rep, "Sherrill", "Ciattarelli"),
    margin = sherrill_dem - ciattarelli_rep,      # positive means Sherrill was ahead
    margin_pct = round(margin / total_votes * 100, 1)
  ) |>
  select(county, county_fips, land_sqmi, everything())

# Expect 21 rows, 14 columns, and no NAs
dim(governor_2025)
names(governor_2025)
summary(governor_2025)

write_csv(governor_2025, "data/governor_2025_county.csv")


# Source 4: The 2024 U.S. House Race, 12th District, by Town -------------------------------------

house_raw <- read_csv("data/raw/house_2024_nj12_by_town.csv")

# Expect 35 rows: 32 towns and three rows of overseas (Federal) ballots. The Middlesex one has no
# label on the PDF, so I typed "Federal".
dim(house_raw)

# Check these against the totals printed on the PDF:
#   Watson Coleman: Mercer 55,545; Middlesex 79,902; Somerset 50,435; Union 10,989
#   Mayfield:       Mercer 17,147; Middlesex 67,858; Somerset 30,221; Union 1,996
#   Meudt:          Mercer 679;    Middlesex 2,811;  Somerset 1,007;  Union 155
#   Kaplan:         Mercer 293;    Middlesex 1,505;  Somerset 998;    Union 119
house_raw |>
  group_by(county) |>
  summarize(
    watson_coleman = sum(watson_coleman_dem),
    mayfield = sum(mayfield_rep),
    meudt = sum(meudt_green),
    kaplan = sum(kaplan_lib)
  )

# The PDF's town names, and the names in muni_codes
nj12_names <- tribble(
  ~municipality,        ~town,
  "Ewing Twp",          "Ewing Township",
  "Hopewell Boro",      "Hopewell Borough",
  "Hopewell Twp",       "Hopewell Township",
  "Pennington Boro",    "Pennington Borough",
  "Princeton",          "Princeton",
  "City of Trenton",    "Trenton City",
  "West Windsor Twp",   "West Windsor Township",
  "Cranbury",           "Cranbury Township",
  "Dunellen",           "Dunellen Borough",
  "East Brunswick",     "East Brunswick Township",
  "Helmetta",           "Helmetta Borough",
  "Jamesburg",          "Jamesburg Borough",
  "Middlesex",          "Middlesex Borough",
  "Milltown",           "Milltown Borough",
  "Monroe",             "Monroe Township",
  "North Brunswick",    "North Brunswick Township",
  "Old Bridge",         "Old Bridge Township",
  "Plainsboro",         "Plainsboro Township",
  "South Brunswick",    "South Brunswick Township",
  "South River",        "South River Borough",
  "Spotswood",          "Spotswood Borough",
  "Bound Brook",        "Bound Brook Borough",
  "Bridgewater",        "Bridgewater Township",
  "Franklin",           "Franklin Township",
  "Hillsborough",       "Hillsborough Township",
  "Manville",           "Manville Borough",
  "Millstone",          "Millstone Borough",
  "Montgomery",         "Montgomery Township",
  "North Plainfield",   "North Plainfield Borough",
  "Rocky Hill",         "Rocky Hill Borough",
  "South Bound Brook",  "South Bound Brook Borough",
  "Plainfield",         "Plainfield City"
)

# Three towns are split between two districts, so only part of each one voted in this race
split_towns <- c("Old Bridge Township", "Bridgewater Township", "Hillsborough Township")

house_2024 <- house_raw |>
  filter(municipality != "Federal") |>            # overseas ballots are not a town
  left_join(nj12_names, by = "municipality") |>
  left_join(select(muni_codes, town, county, geoid), by = c("town", "county")) |>
  mutate(
    in_district = if_else(town %in% split_towns, "part", "all"),
    total_votes = watson_coleman_dem + mayfield_rep + meudt_green + kaplan_lib,
    winner = if_else(watson_coleman_dem > mayfield_rep, "Watson Coleman", "Mayfield"),
    margin = watson_coleman_dem - mayfield_rep,   # positive means Watson Coleman was ahead
    margin_pct = round(margin / total_votes * 100, 1)
  ) |>
  select(town, county, geoid, in_district, watson_coleman_dem, mayfield_rep, meudt_green,
         kaplan_lib, total_votes, winner, margin, margin_pct)

# Expect 32 rows, 12 columns, and no NAs (every town found its geoid)
dim(house_2024)
names(house_2024)
summary(house_2024)

write_csv(house_2024, "data/house_2024_nj12_town.csv")

# The 32 towns' shapes (the whole town, even for the three split towns)
nj12_towns <- nj_towns |>
  filter(GEOID %in% house_2024$geoid)

# Expect 32 rows
dim(nj12_towns)

st_write(nj12_towns, "data/boundaries/nj12_towns.gpkg", delete_dsn = TRUE, quiet = TRUE)


# Pine County: MADE UP ---------------------------------------------------------------------------

# Six made-up towns drawn as rectangles. The corners are in miles, so the area is width x height.
pine_county <- tribble(
  ~town_code, ~town,      ~xmin, ~xmax, ~ymin, ~ymax, ~pop,  ~ev_ports,
  "01",       "Alder",        0,     6,     5,     9, 6000,  6,
  "02",       "Birch",        6,    10,   6.5,     9, 18000, 36,
  "03",       "Cedar",        6,    10,     5,   6.5, 12000, 30,
  "04",       "Dogwood",      0,     3,     0,     5, 9000,  15,
  "05",       "Elm",          3,     5,     0,     5, 21000, 7,
  "06",       "Fir",          5,    10,     0,     5, 4000,  9
) |>
  mutate(sq_miles = (xmax - xmin) * (ymax - ymin))

# Expect 6 rows and 9 columns: 90 square miles and 70,000 people in all
dim(pine_county)

write_csv(pine_county, "data/pine_county.csv")
