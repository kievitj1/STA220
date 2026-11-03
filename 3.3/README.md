# STA 220, Module 3.3: Maps

This project has the R code for workbook 3.3.
Data for Everyday Life: Data Ethics, Management, and Visualization. 
The College of New Jersey.


## For students


1. Run `scripts/01_setup.R` before class. You should see a map of New Jersey.
2. All scripts used to produce the figures in this workbook are included. 
     You are not responsible for any code not covered in the workbook.
     However, you may and are encouraged to use this syntax for your dashboard 
     (you are responsible for any code you use in your dashboard).
3. `scripts/04_practice_in_r.R` is your responsibility. 
     The solutions are also available (`scripts/05_practice_solutions.R`), but I suggest that you try first!



## The sources

**Source 1. Cartographic boundary files**, U.S. Census Bureau, 1:500,000.
- Where to download: https://www.census.gov/geographies/mapping-files/time-series/geo/cartographic-boundary.html
- The files: https://www2.census.gov/geo/tiger/GENZ2022/shp/cb_2022_34_cousub_500k.zip (towns),
  https://www2.census.gov/geo/tiger/GENZ2022/shp/cb_2022_us_county_500k.zip (counties),
  and https://www2.census.gov/geo/tiger/GENZ2022/shp/cb_2022_34_unsd_500k.zip (school districts).
  `tigris` downloads the same files.
- The key is `GEOID`, kept as text: state (34) + county (021) + town (22185).
- `ALAND` and `AWATER` are land and water area in square meters (2,589,988 square meters is one
  square mile).

**Source 2. Municipal Boundaries of NJ**, NJ Office of GIS (NJOGIS), on NJGIN Open Data.
- Download: https://njogis-newjersey.opendata.arcgis.com/datasets/newjersey::municipal-boundaries-of-nj
- The copy in `data/raw/` is from October 2021, so it has `CENSUS2010`.


**Source 3. The 2025 general election for Governor, official results**, NJ Division of Elections.
The state only posts these as PDFs. I had Claude convert the two PDFs to the CSVs in `data/raw/`
and then audited them by checking every column for the first, last, and a few random rows in the
middle. `02_import.R` also checks each column against the statewide totals printed on the PDFs
(1,896,610; 1,417,705; 11,880; 8,164; 6,549,793 registered; 3,369,507 ballots cast). You could also
type them into a CSV by hand or use Excel's Get Data feature.
- Results by county: https://nj.gov/state/elections/assets/pdf/election-results/2025/2025-official-general-results-governor.pdf
- Registered voters and ballots cast: https://nj.gov/state/elections/assets/pdf/election-results/2025/2025-official-general-voter-turnout.pdf
- All the 2025 results: https://nj.gov/state/elections/election-information-2025.shtml
- A trusted secondary source with CSVs (presidential races by county): the MIT Election Data and
  Science Lab, https://electionlab.mit.edu/data


**Source 4. The 2024 general election for the U.S. House of Representatives, 12th Congressional
District, official results by town**, NJ Division of Elections. The 12th district is the one TCNJ is
in. Bonnie Watson Coleman (Democrat) won with 196,871 votes to Darius Mayfield's (Republican) 117,222
Claude typed the town rows from the PDF into `data/raw/`
- Results by town: https://nj.gov/state/elections/assets/pdf/election-results/2024/2024-official-general-results-us-house-district12.pdf
- The district map (2022 to 2031): https://nj.gov/state/elections/assets/pdf/2022-congressional-districts/2022-2031-congressional-map.pdf
- The Federal rows (overseas ballots) are not towns, so `02_import.R` drops them. 
- The 2026 House election is on November 3, 2026. To use it instead, download the new PDF once the
  results are certified, type it into `data/raw/` the same way, and change the names in `02_import.R`.

**From 3.2**, copied as they were (the 3.2 README has the by-hand steps):
- The UFB Database, NJ DCA, 2025 (`nj_2025.csv` and `state_by_year.csv`):
  https://datahub.dca.nj.gov/datasets/user-friendly-budget-database

**Crosswalks for other units** (Section 4; not used in the scripts):
- ZIP code to town, with shares of addresses: HUD USPS ZIP Code Crosswalk Files,
  https://www.huduser.gov/portal/datasets/usps_crosswalk.html (free account; the ZIP-COUNTYSUB file)
- ZCTA to town, with the land and water area of each piece: the Census Bureau's relationship files,
  https://www.census.gov/geographies/reference-files/time-series/geo/relationship-files.html
- School districts: NCES EDGE Geographic Relationship Files,
  https://nces.ed.gov/programs/edge/Geographic/RelationshipFiles, and each district's own website

`pine_county.csv` is made up for the practice questions. Pine County does not exist.



