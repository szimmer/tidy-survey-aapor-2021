#' ---
#' title: "Categorical Data Analysis Exercise Solutions"
#' output:
#'   html_document:
#'     df_print: paged
#' ---
#' 
#' # Set-up
## -------------------------------------------------------------------
library(tidyverse) # for tidyverse
library(here) # for file paths
library(survey) # for survey analysis
library(srvyr) # for tidy survey analysis

anes <- read_rds(here("Data", "anes.rds")) %>%
   mutate(Weight=Weight/sum(Weight)*224059005) 
# adjust weight to sum to citizen pop, 18+ in Nov 2016 per ANES methodology documentation

anes_des <- anes %>%
   as_survey_design(weights = Weight,
                    strata = Stratum,
                    ids = VarUnit,
                    nest = TRUE)

#' 
#' # Part 1
#' 
#' 1. How many females have a graduate degree?
#' 
## -------------------------------------------------------------------



#' 
#' 2. What percentage of people identify as "Strong democrat"?
#' 
## -------------------------------------------------------------------


#' 
#' 3. What percentage of people who voted in the 2016 election identify as "Strong republican"?
#' 
## -------------------------------------------------------------------


#' 
#' 4. What percentage of people voted in both the 2012 election and in the 2016 election?  Include the confidence interval.
#' 
## -------------------------------------------------------------------


#' 
#' 5. What is the design effect for the proportion of people who voted early?
#' 
## -------------------------------------------------------------------


#' 
#' # Part 2
#' 
#' 1. Is there a relationship between PartyID and When people voted in the 2016 election (on election day or early voting)?
#' 
## -------------------------------------------------------------------


#' 
#' 2. Is there a relationship between PartyID and trust in the government?
#' 
## -------------------------------------------------------------------


#' 
#' 
#' # Bonus
#' 
#' 1. What percentage of people lean republican?
#' 
## -------------------------------------------------------------------


#' 
#' 2. Were people who lean democrat more likely to vote early in the 2020 election?
#' 
## -------------------------------------------------------------------


