#' ---
#' title: "Continous Data Analysis Exercise Solutions"
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

recs <- read_rds(here("Data", "recs.rds"))

recs_des <- recs %>%
   as_survey_rep(weights=NWEIGHT,
                 repweights=starts_with("BRRWT"),
                 type="Fay",
                 rho=0.5,
                 mse=TRUE)

#' 
#' # Part 1
#' 
#' 1. Find the average square footage of housing units (TOTSQFT_EN) with a 90% confidence interval.
#' 
## -------------------------------------------------------------------
recs_des %>%
   summarize(
      SF_HU=survey_mean(TOTSQFT_EN,
                          vartype = "ci",
                          level = 0.9)
   )

#' 
#' 2. Estimate the ratio of cooled square footage to total square footage (TOTCSQFT) to the total square footage of housing units (TOTSQFT_EN) with its standard error.
#' 
## -------------------------------------------------------------------
recs_des %>%
   summarize(
      PropCooled=survey_ratio(
         numerator = TOTCSQFT,
         denominator = TOTSQFT_EN,
         vartype = "se")
   )

#' 
#' 3. Estimate the median temperature housing units are set to during the night in the winter (WinterTempNight) using the `survey_median` function.
#' 
## -------------------------------------------------------------------
recs_des %>%
   summarize(
      WinterNightTemp=survey_median(WinterTempNight,
                     vartype = "se",
                     na.rm = TRUE)
   )

#' 
#' 4. Estimate the median temperature housing units are set to during the night in the winter (WinterTempNight) using the `survey_quantile` function.
#' 
## -------------------------------------------------------------------
recs_des %>%
   summarize(
      WinterNightTemp=survey_median(WinterTempNight,
                            quantiles = "0.5",
                            vartype = "se",
                            na.rm = TRUE)
   )

#' 
#' # Part 2
#' 
#' 1. Estimate the total average energy cost (TOTALDOL) by region, division, and urbanicity.
#' 
## -------------------------------------------------------------------
# option 1
recs_des %>%
   group_by(Region, Division, Urbanicity) %>%
   cascade(
      EnergyCost=survey_mean(TOTALDOL)
   )
# option 2
# one way
recs_des %>%
   group_by(Region, Division, Urbanicity) %>%
   summarize(
      EnergyCost=survey_mean(TOTALDOL)
   )

#' 
#' 2. What is the median electric cost (DOLLAREL) for housing units in the South Region? What is the 95% confidence interval?
#' 
## -------------------------------------------------------------------
recs_des %>%
   filter(Region=="South") %>%
   summarize(
      MedElBill=survey_median(DOLLAREL,
                              vartype="ci")
   )

#' 
#' 3. Test whether daytime winter and daytime summer temperatures of homes are set the same.
#' 
## -------------------------------------------------------------------
recs_des %>%
   svyttest(design=.,
            formula = I(WinterTempDay-SummerTempDay)~0,
            na.rm = TRUE)

#' 
#' 4. Test whether average electric bill (DOLLAREL) varies by region (Region).
#' 
## -------------------------------------------------------------------
m1 <- recs_des %>%
   svyglm(design=.,
          formula=DOLLAREL~Region,
          na.action=na.omit)
summary(m1)

#' 
#' 5. Fit a regression between the cooled square footage of a housing unit (TOTCSQFT) and the total amount spent on energy (TOTALDOL).
#' 
## -------------------------------------------------------------------
m2 <- recs_des %>%
   svyglm(design=.,
          formula=TOTALDOL~TOTCSQFT,
          na.action=na.omit)
summary(m2)

#' 
