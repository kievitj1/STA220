# scripts/04_practice_in_r.R
# Practice in R: the 2024 U.S. House race in the 12th Congressional District, by town. 

# Instructions ------------------------------------------------------------
#####  I recommend the following strategy when completing this practice

# STEP 1: Attempt each task and answer the questions first without using AI.

# STEP 2: Look back at the code printed in the workbook and in fig_06_election.R. Every command
# you need is there or in an earlier workbook.

# STEP 3: Ask AI for help identifying specific problems with the script you wrote
# i.e., do not give AI the whole prompt! Instead, give it specifically what you wrote
# with no context and ask it to identify the problem and suggest a solution.

# STEP 4: Look at the practice solutions (05_practice_solutions.R).


#### HOWEVER HOWEVER HOWEVER
# It's better to use the syntax from practice_solutions to answer the questions
# than to do nothing!


# Packages and Load the Data (done for you) ------------------------------------------------------

library(tidyverse)
library(sf)

# The Census boundaries (2022) of the 32 towns in the 12th Congressional District: one row per town
nj12_towns <- read_sf("data/boundaries/nj12_towns.gpkg")

# The 2024 U.S. House race, one row per town. geoid is read as text, so it keeps every digit.
house <- read_csv(
  "data/house_2024_nj12_town.csv",
  col_types = cols(geoid = col_character())
)


# Get the Data Ready ---------------------------------------------------------------

# Step 1. Run the three checks on nj12_towns and on house.
#   HINT: dim(), names(), and summary(). 



# Step 2. Run the key check on geoid in house.
#   HINT: look under "Before Every Join" in 03_join_budgets.R.



# Step 3. Predict the rows and columns. Then join house to nj12_towns and run the three checks.
#   HINT: fig_06_election.R does this for counties 





# Figure 1 -------------------------------------------------------

# Map who won each town.
#   HINT: Work from fig_06_election.R, and the party_colours line above it. 
#   HINT: Consider adding labs(), a title, and a caption. See fig_05_diverging.R
#   HINT: change theme_void(base_size = 7) to theme_void() for bigger text






# Figure 2 -------------------------------------------------------------

#  Map margin_pct (Watson Coleman's percent minus Mayfield's).
#   HINT: Work from fig_06_election.R
#   Don't forget labels, titles, and a caption!




# Figure 3 -----------------------------------------------------

# Draw a bar chart of the margin in votes, one bar per town.
#   HINT: Use fig_06_election.R. 
#   Hint: You can stretch the plot quadrant if you can't see all bars.



