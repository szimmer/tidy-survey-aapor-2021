American National Election Studies (ANES) 2016 Time Series Study Data
Prep
================

## Data information

All data and resources were downloaded from
<https://electionstudies.org/data-center/2020-time-series-study/> on
February 28, 2022.

American National Election Studies. 2021. ANES 2020 Time Series Study
Full Release \[dataset and documentation\]. www.electionstudies.org

``` r
library(here) # easy relative paths
```

``` r
library(tidyverse) # data manipulation
```

    ## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──

    ## ✓ ggplot2 3.3.5     ✓ purrr   0.3.4
    ## ✓ tibble  3.1.6     ✓ dplyr   1.0.8
    ## ✓ tidyr   1.2.0     ✓ stringr 1.4.0
    ## ✓ readr   2.1.2     ✓ forcats 0.5.1

    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
library(haven) # data import
library(tidylog) # informative logging messages
```

    ## 
    ## Attaching package: 'tidylog'

    ## The following objects are masked from 'package:dplyr':
    ## 
    ##     add_count, add_tally, anti_join, count, distinct, distinct_all,
    ##     distinct_at, distinct_if, filter, filter_all, filter_at, filter_if,
    ##     full_join, group_by, group_by_all, group_by_at, group_by_if,
    ##     inner_join, left_join, mutate, mutate_all, mutate_at, mutate_if,
    ##     relocate, rename, rename_all, rename_at, rename_if, rename_with,
    ##     right_join, sample_frac, sample_n, select, select_all, select_at,
    ##     select_if, semi_join, slice, slice_head, slice_max, slice_min,
    ##     slice_sample, slice_tail, summarise, summarise_all, summarise_at,
    ##     summarise_if, summarize, summarize_all, summarize_at, summarize_if,
    ##     tally, top_frac, top_n, transmute, transmute_all, transmute_at,
    ##     transmute_if, ungroup

    ## The following objects are masked from 'package:tidyr':
    ## 
    ##     drop_na, fill, gather, pivot_longer, pivot_wider, replace_na,
    ##     spread, uncount

    ## The following object is masked from 'package:stats':
    ## 
    ##     filter

## Import data and create derived variables

``` r
anes_in_2020 <- read_sav(here("RawData", "ANES_2020", "anes_timeseries_2020_spss_20220210.sav"))

anes_2020 <- anes_in_2020 %>%
  select(
    "V200010b", # FULL SAMPLE POST-ELECTION WEIGHT
    "V200010d", # FULL SAMPLE VARIANCE STRATUM
    "V200010c", # FULL SAMPLE VARIANCE UNIT
    "V200002", # MODE OF INTERVIEW: PRE-ELECTION INTERVIEW
    "V201006", # PRE: HOW INTERESTED IN FOLLOWING CAMPAIGNS
    "V201101", # PRE: DID R VOTE FOR PRESIDENT IN 2016 [REVISED]
    "V201103", # PRE: RECALL OF LAST (2016) PRESIDENTIAL VOTE CHOICE)
    "V201025x", # PRE: SUMMARY: REGISTRATION AND EARLY VOTE STATUS
    "V201231x", # PRE: SUMMARY: PARTY ID
    "V201233", # PRE: HOW OFTEN TRUST GOVERNMENT IN WASHINGTON TO DO WHAT IS RIGHT [REVISED]
    "V201237", # PRE: HOW OFTEN CAN PEOPLE BE TRUSTED
    "V201507x", # PRE: SUMMARY: RESPONDENT AGE
    "V201510", # PRE: HIGHEST LEVEL OF EDUCATION
    "V201549x", # PRE: SUMMARY: R SELF-IDENTIFIED RACE/ETHNICITY
    "V201600", # PRE: WHAT IS YOUR (R) SEX? [REVISED]
    "V201617x", # PRE: SUMMARY: TOTAL (FAMILY) INCOME
    "V202066", # POST: DID R VOTE IN NOVEMBER 2020 ELECTION
    "V202109x", # PRE-POST: SUMMARY: VOTER TURNOUT IN 2020
    "V202072", # POST: DID R VOTE FOR PRESIDENT
    "V202073", # POST: FOR WHOM DID R VOTE FOR PRESIDENT
    "V202110x" # PRE-POST: SUMMARY: 2020 PRESIDENTIAL VOTE
  ) %>%
  mutate(
    InterviewMode = fct_recode(as.character(V200002), Video = "1", Telephone = "2", Web = "3"),
    Weight = V200010b,
    Stratum = as.factor(V200010d),
    VarUnit = as.factor(V200010c),
    Age = if_else(V201507x > 0, as.numeric(V201507x), NA_real_),
    AgeGroup = cut(Age, c(17, 29, 39, 49, 59, 69, 200),
      labels = c("18-29", "30-39", "40-49", "50-59", "60-69", "70 or older")
    ),
    Gender = factor(
      case_when(
        V201600 == 1 ~ "Male",
        V201600 == 2 ~ "Female",
        TRUE ~ NA_character_
      ),
      levels = c("Male", "Female")
    ),
    RaceEth = factor(
      case_when(
        V201549x == 1 ~ "White",
        V201549x == 2 ~ "Black",
        V201549x == 3 ~ "Hispanic",
        V201549x == 4 ~ "Asian, NH/PI",
        V201549x == 5 ~ "AI/AN",
        V201549x == 6 ~ "Other/multiple race",
        TRUE ~ NA_character_
      ),
      levels = c("White", "Black", "Hispanic", "Asian, NH/PI", "AI/AN", "Other/multiple race", NA_character_)
    ),
    PartyID = factor(
      case_when(
        V201231x == 1 ~ "Strong democrat",
        V201231x == 2 ~ "Not very strong democrat",
        V201231x == 3 ~ "Independent-democrat",
        V201231x == 4 ~ "Independent",
        V201231x == 5 ~ "Independent-republican",
        V201231x == 6 ~ "Not very strong republican",
        V201231x == 7 ~ "Strong republican",
        TRUE ~ NA_character_
      ),
      levels = c("Strong democrat", "Not very strong democrat", "Independent-democrat", "Independent", "Independent-republican", "Not very strong republican", "Strong republican")
    ),
    Education = factor(
      case_when(
        V201510 <= 0 ~ NA_character_,
        V201510 == 1 ~ "Less than HS",
        V201510 == 2 ~ "High school",
        V201510 <= 5 ~ "Post HS",
        V201510 == 6 ~ "Bachelor's",
        V201510 <= 8 ~ "Graduate",
        TRUE ~ NA_character_
      ),
      levels = c("Less than HS", "High school", "Post HS", "Bachelor's", "Graduate")
    ),
    Income = cut(V201617x, c(-5, 1:22),
      labels = c(
        "Under $9,999",
        "$10,000-14,999",
        "$15,000-19,999",
        "$20,000-24,999",
        "$25,000-29,999",
        "$30,000-34,999",
        "$35,000-39,999",
        "$40,000-44,999",
        "$45,000-49,999",
        "$50,000-59,999",
        "$60,000-64,999",
        "$65,000-69,999",
        "$70,000-74,999",
        "$75,000-79,999",
        "$80,000-89,999",
        "$90,000-99,999",
        "$100,000-109,999",
        "$110,000-124,999",
        "$125,000-149,999",
        "$150,000-174,999",
        "$175,000-249,999",
        "$250,000 or more"
      )
    ),
    Income7 = fct_collapse(
      Income,
      "Under $20k" = c("Under $9,999", "$10,000-14,999", "$15,000-19,999"),
      "$20-40k" = c("$20,000-24,999", "$25,000-29,999", "$30,000-34,999", "$35,000-39,999"),
      "$40-60k" = c("$40,000-44,999", "$45,000-49,999", "$50,000-59,999"),
      "$60-80k" = c("$60,000-64,999", "$65,000-69,999", "$70,000-74,999", "$75,000-79,999"),
      "$80-100k" = c("$80,000-89,999", "$90,000-99,999"),
      "$100-125k" = c("$100,000-109,999", "$110,000-124,999"),
      "$125k or more" = c("$125,000-149,999", "$150,000-174,999", "$175,000-249,999", "$250,000 or more")
    ),
    CampaignInterest = factor(
      case_when(
        V201006 == 1 ~ "Very much interested",
        V201006 == 2 ~ "Somewhat interested",
        V201006 == 3 ~ "Not much interested",
        TRUE ~ NA_character_
      ),
      levels = c("Very much interested", "Somewhat interested", "Not much interested")
    ),
    TrustGovernment = factor(
      case_when(
        V201233 == 1 ~ "Always",
        V201233 == 2 ~ "Most of the time",
        V201233 == 3 ~ "About half the time",
        V201233 == 4 ~ "Some of the time",
        V201233 == 5 ~ "Never",
        TRUE ~ NA_character_
      ),
      levels = c("Always", "Most of the time", "About half the time", "Some of the time", "Never")
    ),
    TrustPeople = factor(
      case_when(
        V201237 == 1 ~ "Always",
        V201237 == 2 ~ "Most of the time",
        V201237 == 3 ~ "About half the time",
        V201237 == 4 ~ "Some of the time",
        V201237 == 5 ~ "Never",
        TRUE ~ NA_character_
      ),
      levels = c("Always", "Most of the time", "About half the time", "Some of the time", "Never")
    ),
    VotedPres2016 = factor(
      case_when(
        V201101 == 1 ~ "Yes",
        V201101 == 2 ~ "No",
        TRUE ~ NA_character_
      ),
      levels = c("Yes", "No")
    ),
    VotedPres2016_selection = factor(
      case_when(
        V201103 == 1 ~ "Clinton",
        V201103 == 2 ~ "Trump",
        V201103 == 5 ~ "Other",
        TRUE ~ NA_character_
      ),
      levels = c("Clinton", "Trump", "Other")
    ),
    VotedPres2020 = factor(
      case_when(
        V202109x == 1 ~ "Yes",
        V202109x == 0 ~ "No",
        TRUE ~ NA_character_
      ),
      levels = c("Yes", "No")
    ),
    VotedPres2020_selection = factor(
      case_when(
        V202073 == 1 ~ "Biden",
        V202073 == 2 ~ "Trump",
        V202073 >= 3 ~ "Other",
        TRUE ~ NA_character_
      ),
      levels = c("Biden", "Trump", "Other")
    ),
    EarlyVote2020 = factor(
      case_when(
                 V201025x < 0 ~ NA_character_,
        V201025x == 4 ~ "Yes",
        VotedPres2020 == "Yes" ~ "No",
        TRUE ~ NA_character_
      ),
      levels = c("Yes", "No")
    )
  )
```

    ## select: dropped 1,750 variables (version, V200001, V160001_orig, V200003, V200004, …)

    ## mutate: new variable 'InterviewMode' (factor) with 3 unique values and 0% NA

    ##         new variable 'Weight' (double) with 7,196 unique values and 10% NA

    ##         new variable 'Stratum' (factor) with 50 unique values and 0% NA

    ##         new variable 'VarUnit' (factor) with 3 unique values and 0% NA

    ##         new variable 'Age' (double) with 64 unique values and 4% NA

    ##         new variable 'AgeGroup' (factor) with 7 unique values and 4% NA

    ##         new variable 'Gender' (factor) with 3 unique values and 1% NA

    ##         new variable 'RaceEth' (factor) with 7 unique values and 1% NA

    ##         new variable 'PartyID' (factor) with 8 unique values and <1% NA

    ##         new variable 'Education' (factor) with 6 unique values and 2% NA

    ##         new variable 'Income' (factor) with 23 unique values and 7% NA

    ##         new variable 'Income7' (factor) with 8 unique values and 7% NA

    ##         new variable 'CampaignInterest' (factor) with 4 unique values and <1% NA

    ##         new variable 'TrustGovernment' (factor) with 6 unique values and <1% NA

    ##         new variable 'TrustPeople' (factor) with 6 unique values and <1% NA

    ##         new variable 'VotedPres2016' (factor) with 3 unique values and 51% NA

    ##         new variable 'VotedPres2016_selection' (factor) with 4 unique values and 23% NA

    ##         new variable 'VotedPres2020' (factor) with 3 unique values and 10% NA

    ##         new variable 'VotedPres2020_selection' (factor) with 4 unique values and 29% NA

    ##         new variable 'EarlyVote2020' (factor) with 3 unique values and 22% NA

``` r
summary(anes_2020)
```

    ##     V200010b         V200010d        V200010c        V200002     
    ##  Min.   :0.0083   Min.   : 1.00   Min.   :1.000   Min.   :1.000  
    ##  1st Qu.:0.3863   1st Qu.:12.00   1st Qu.:1.000   1st Qu.:3.000  
    ##  Median :0.6863   Median :25.00   Median :2.000   Median :3.000  
    ##  Mean   :1.0000   Mean   :24.74   Mean   :1.508   Mean   :2.896  
    ##  3rd Qu.:1.2110   3rd Qu.:37.00   3rd Qu.:2.000   3rd Qu.:3.000  
    ##  Max.   :6.6507   Max.   :50.00   Max.   :3.000   Max.   :3.000  
    ##  NA's   :827                                                     
    ##     V201006          V201101            V201103          V201025x     
    ##  Min.   :-9.000   Min.   :-9.00000   Min.   :-9.000   Min.   :-4.000  
    ##  1st Qu.: 1.000   1st Qu.:-1.00000   1st Qu.: 1.000   1st Qu.: 3.000  
    ##  Median : 1.000   Median :-1.00000   Median : 1.000   Median : 3.000  
    ##  Mean   : 1.606   Mean   : 0.08901   Mean   : 1.026   Mean   : 2.914  
    ##  3rd Qu.: 2.000   3rd Qu.: 1.00000   3rd Qu.: 2.000   3rd Qu.: 3.000  
    ##  Max.   : 3.000   Max.   : 2.00000   Max.   : 5.000   Max.   : 4.000  
    ##                                                                       
    ##     V201231x         V201233          V201237          V201507x    
    ##  Min.   :-9.000   Min.   :-9.000   Min.   :-9.000   Min.   :-9.00  
    ##  1st Qu.: 2.000   1st Qu.: 3.000   1st Qu.: 2.000   1st Qu.:35.00  
    ##  Median : 4.000   Median : 4.000   Median : 3.000   Median :51.00  
    ##  Mean   : 3.834   Mean   : 3.421   Mean   : 2.785   Mean   :49.04  
    ##  3rd Qu.: 6.000   3rd Qu.: 4.000   3rd Qu.: 4.000   3rd Qu.:65.00  
    ##  Max.   : 7.000   Max.   : 5.000   Max.   : 5.000   Max.   :80.00  
    ##                                                                    
    ##     V201510          V201549x         V201600          V201617x    
    ##  Min.   :-9.000   Min.   :-9.000   Min.   :-9.000   Min.   :-9.00  
    ##  1st Qu.: 3.000   1st Qu.: 1.000   1st Qu.: 1.000   1st Qu.: 4.00  
    ##  Median : 5.000   Median : 1.000   Median : 2.000   Median :11.00  
    ##  Mean   : 5.532   Mean   : 1.499   Mean   : 1.457   Mean   :10.22  
    ##  3rd Qu.: 6.000   3rd Qu.: 2.000   3rd Qu.: 2.000   3rd Qu.:17.00  
    ##  Max.   :95.000   Max.   : 6.000   Max.   : 2.000   Max.   :22.00  
    ##                                                                    
    ##     V202066          V202109x          V202072            V202073       
    ##  Min.   :-9.000   Min.   :-2.0000   Min.   :-9.00000   Min.   :-9.0000  
    ##  1st Qu.: 3.000   1st Qu.: 1.0000   1st Qu.:-1.00000   1st Qu.:-1.0000  
    ##  Median : 4.000   Median : 1.0000   Median : 1.00000   Median : 1.0000  
    ##  Mean   : 2.453   Mean   : 0.5879   Mean   :-0.04746   Mean   : 0.2389  
    ##  3rd Qu.: 4.000   3rd Qu.: 1.0000   3rd Qu.: 1.00000   3rd Qu.: 2.0000  
    ##  Max.   : 4.000   Max.   : 1.0000   Max.   : 2.00000   Max.   :12.0000  
    ##                                                                         
    ##     V202110x         InterviewMode      Weight          Stratum     VarUnit 
    ##  Min.   :-9.0000   Video    : 359   Min.   :0.0083   12     : 192   1:4091  
    ##  1st Qu.: 1.0000   Telephone: 139   1st Qu.:0.3863   30     : 190   2:4173  
    ##  Median : 1.0000   Web      :7782   Median :0.6863   21     : 188   3:  16  
    ##  Mean   : 0.8036                    Mean   :1.0000   1      : 186           
    ##  3rd Qu.: 2.0000                    3rd Qu.:1.2110   25     : 186           
    ##  Max.   : 5.0000                    Max.   :6.6507   26     : 185           
    ##                                     NA's   :827      (Other):7153           
    ##       Age               AgeGroup       Gender                    RaceEth    
    ##  Min.   :18.00   18-29      :1003   Male  :3763   White              :5963  
    ##  1st Qu.:37.00   30-39      :1381   Female:4450   Black              : 726  
    ##  Median :52.00   40-49      :1199   NA's  :  67   Hispanic           : 762  
    ##  Mean   :51.59   50-59      :1335                 Asian, NH/PI       : 284  
    ##  3rd Qu.:66.00   60-69      :1562                 AI/AN              : 172  
    ##  Max.   :80.00   70 or older:1452                 Other/multiple race: 271  
    ##  NA's   :348     NA's       : 348                 NA's               : 102  
    ##                      PartyID            Education                 Income    
    ##  Strong democrat         :1961   Less than HS: 376   Under $9,999    : 719  
    ##  Strong republican       :1730   High school :1336   $50,000-59,999  : 546  
    ##  Independent-democrat    : 975   Post HS     :2790   $100,000-109,999: 506  
    ##  Independent             : 968   Bachelor's  :2055   $250,000 or more: 449  
    ##  Not very strong democrat: 900   Graduate    :1592   $80,000-89,999  : 426  
    ##  (Other)                 :1711   NA's        : 131   (Other)         :5018  
    ##  NA's                    :  35                       NA's            : 616  
    ##           Income7                 CampaignInterest            TrustGovernment
    ##  $125k or more:1616   Very much interested:4320    Always             :  88  
    ##  Under $20k   :1211   Somewhat interested :2890    Most of the time   :1133  
    ##  $20-40k      :1157   Not much interested :1069    About half the time:2569  
    ##  $40-60k      :1097   NA's                :   1    Some of the time   :3674  
    ##  $60-80k      :1004                                Never              : 779  
    ##  (Other)      :1579                                NA's               :  37  
    ##  NA's         : 616                                                          
    ##               TrustPeople   VotedPres2016 VotedPres2016_selection VotedPres2020
    ##  Always             :  52   Yes :3070     Clinton:3172            Yes :6450    
    ##  Most of the time   :3842   No  :1001     Trump  :2746            No  :1039    
    ##  About half the time:2265   NA's:4209     Other  : 432            NA's: 791    
    ##  Some of the time   :1810                 NA's   :1930                         
    ##  Never              : 292                                                      
    ##  NA's               :  19                                                      
    ##                                                                                
    ##  VotedPres2020_selection EarlyVote2020
    ##  Biden:3267              Yes : 415    
    ##  Trump:2462              No  :6035    
    ##  Other: 170              NA's:1830    
    ##  NA's :2381                           
    ##                                       
    ##                                       
    ## 

## Check derived variables for correct coding

``` r
anes_2020 %>% count(InterviewMode, V200002)
```

    ## count: now 3 rows and 3 columns, ungrouped

    ## # A tibble: 3 × 3
    ##   InterviewMode          V200002     n
    ##   <fct>                <dbl+lbl> <int>
    ## 1 Video         1 [1. Video]       359
    ## 2 Telephone     2 [2. Telephone]   139
    ## 3 Web           3 [3. Web]        7782

``` r
anes_2020 %>%
  group_by(AgeGroup) %>%
  summarise(
    minAge = min(Age),
    maxAge = max(Age),
    minV = min(V201507x),
    maxV = max(V201507x)
  )
```

    ## group_by: one grouping variable (AgeGroup)

    ## summarise: now 7 rows and 5 columns, ungrouped

    ## # A tibble: 7 × 5
    ##   AgeGroup    minAge maxAge             minV                     maxV
    ##   <fct>        <dbl>  <dbl>        <dbl+lbl>                <dbl+lbl>
    ## 1 18-29           18     29 18               29                      
    ## 2 30-39           30     39 30               39                      
    ## 3 40-49           40     49 40               49                      
    ## 4 50-59           50     59 50               59                      
    ## 5 60-69           60     69 60               69                      
    ## 6 70 or older     70     80 70               80 [80. Age 80 or older]
    ## 7 <NA>            NA     NA -9 [-9. Refused] -9 [-9. Refused]

``` r
anes_2020 %>% count(Gender, V201600)
```

    ## count: now 3 rows and 3 columns, ungrouped

    ## # A tibble: 3 × 3
    ##   Gender          V201600     n
    ##   <fct>         <dbl+lbl> <int>
    ## 1 Male    1 [1. Male]      3763
    ## 2 Female  2 [2. Female]    4450
    ## 3 <NA>   -9 [-9. Refused]    67

``` r
anes_2020 %>% count(RaceEth, V201549x)
```

    ## count: now 8 rows and 3 columns, ungrouped

    ## # A tibble: 8 × 3
    ##   RaceEth                                                         V201549x     n
    ##   <fct>                                                          <dbl+lbl> <int>
    ## 1 White                1 [1. White, non-Hispanic]                           5963
    ## 2 Black                2 [2. Black, non-Hispanic]                            726
    ## 3 Hispanic             3 [3. Hispanic]                                       762
    ## 4 Asian, NH/PI         4 [4. Asian or Native Hawaiian/other Pacific Islan…   284
    ## 5 AI/AN                5 [5. Native American/Alaska Native or other race,…   172
    ## 6 Other/multiple race  6 [6. Multiple races, non-Hispanic]                   271
    ## 7 <NA>                -9 [-9. Refused]                                        96
    ## 8 <NA>                -8 [-8. Don't know]                                      6

``` r
anes_2020 %>% count(PartyID, V201231x)
```

    ## count: now 9 rows and 3 columns, ungrouped

    ## # A tibble: 9 × 3
    ##   PartyID                                              V201231x     n
    ##   <fct>                                               <dbl+lbl> <int>
    ## 1 Strong democrat             1 [1. Strong Democrat]             1961
    ## 2 Not very strong democrat    2 [2. Not very strong Democrat]     900
    ## 3 Independent-democrat        3 [3. Independent-Democrat]         975
    ## 4 Independent                 4 [4. Independent]                  968
    ## 5 Independent-republican      5 [5. Independent-Republican]       879
    ## 6 Not very strong republican  6 [6. Not very strong Republican]   832
    ## 7 Strong republican           7 [7. Strong Republican]           1730
    ## 8 <NA>                       -9 [-9. Refused]                      31
    ## 9 <NA>                       -8 [-8. Don't know]                    4

``` r
anes_2020 %>% count(Education, V201510)
```

    ## count: now 11 rows and 3 columns, ungrouped

    ## # A tibble: 11 × 3
    ##    Education                                                       V201510     n
    ##    <fct>                                                         <dbl+lbl> <int>
    ##  1 Less than HS  1 [1. Less than high school credential]                     376
    ##  2 High school   2 [2.  High school graduate - High school diploma or equ…  1336
    ##  3 Post HS       3 [3. Some college but no degree]                          1684
    ##  4 Post HS       4 [4. Associate degree in college - occupational/vocatio…   615
    ##  5 Post HS       5 [5. Associate degree in college - academic]               491
    ##  6 Bachelor's    6 [6. Bachelor's degree (e.g. BA, AB, BS)]                 2055
    ##  7 Graduate      7 [7. Master's degree (e.g. MA, MS, MEng, MEd, MSW, MBA)]  1185
    ##  8 Graduate      8 [8. Professional school degree (e.g. MD, DDS, DVM, LLB…   407
    ##  9 <NA>         -9 [-9. Refused]                                              33
    ## 10 <NA>         -8 [-8. Don't know]                                            1
    ## 11 <NA>         95 [95. Other {SPECIFY}]                                      97

``` r
anes_2020 %>%
  count(Income, Income7, V201617x) %>%
  print(n = 30)
```

    ## count: now 24 rows and 4 columns, ungrouped

    ## # A tibble: 24 × 4
    ##    Income           Income7                                       V201617x     n
    ##    <fct>            <fct>                                        <dbl+lbl> <int>
    ##  1 Under $9,999     Under $20k     1 [1. Under $9,999]                       719
    ##  2 $10,000-14,999   Under $20k     2 [2. $10,000-14,999]                     282
    ##  3 $15,000-19,999   Under $20k     3 [3. $15,000-19,999]                     210
    ##  4 $20,000-24,999   $20-40k        4 [4. $20,000-24,999]                     325
    ##  5 $25,000-29,999   $20-40k        5 [5. $25,000-29,999]                     263
    ##  6 $30,000-34,999   $20-40k        6 [6. $30,000-34,999]                     327
    ##  7 $35,000-39,999   $20-40k        7 [7. $35,000-39,999]                     242
    ##  8 $40,000-44,999   $40-60k        8 [8. $40,000-44,999]                     321
    ##  9 $45,000-49,999   $40-60k        9 [9. $45,000-49,999]                     230
    ## 10 $50,000-59,999   $40-60k       10 [10. $50,000-59,999]                    546
    ## 11 $60,000-64,999   $60-80k       11 [11. $60,000-64,999]                    325
    ## 12 $65,000-69,999   $60-80k       12 [12. $65,000-69,999]                    182
    ## 13 $70,000-74,999   $60-80k       13 [13. $70,000-74,999]                    264
    ## 14 $75,000-79,999   $60-80k       14 [14. $75,000-79,999]                    233
    ## 15 $80,000-89,999   $80-100k      15 [15. $80,000-89,999]                    426
    ## 16 $90,000-99,999   $80-100k      16 [16. $90,000-99,999]                    304
    ## 17 $100,000-109,999 $100-125k     17 [17. $100,000-109,999]                  506
    ## 18 $110,000-124,999 $100-125k     18 [18. $110,000-124,999]                  343
    ## 19 $125,000-149,999 $125k or more 19 [19. $125,000-149,999]                  347
    ## 20 $150,000-174,999 $125k or more 20 [20. $150,000-174,999]                  404
    ## 21 $175,000-249,999 $125k or more 21 [21. $175,000-249,999]                  416
    ## 22 $250,000 or more $125k or more 22 [22. $250,000 or more]                  449
    ## 23 <NA>             <NA>          -9 [-9. Refused]                           584
    ## 24 <NA>             <NA>          -5 [-5. Interview breakoff (sufficient …    32

``` r
anes_2020 %>% count(CampaignInterest, V201006)
```

    ## count: now 4 rows and 3 columns, ungrouped

    ## # A tibble: 4 × 3
    ##   CampaignInterest                          V201006     n
    ##   <fct>                                   <dbl+lbl> <int>
    ## 1 Very much interested  1 [1. Very much interested]  4320
    ## 2 Somewhat interested   2 [2. Somewhat interested]   2890
    ## 3 Not much interested   3 [3. Not much interested]   1069
    ## 4 <NA>                 -9 [-9. Refused]                 1

``` r
anes_2020 %>% count(TrustGovernment, V201233)
```

    ## count: now 7 rows and 3 columns, ungrouped

    ## # A tibble: 7 × 3
    ##   TrustGovernment                         V201233     n
    ##   <fct>                                 <dbl+lbl> <int>
    ## 1 Always               1 [1. Always]                 88
    ## 2 Most of the time     2 [2. Most of the time]     1133
    ## 3 About half the time  3 [3. About half the time]  2569
    ## 4 Some of the time     4 [4. Some of the time]     3674
    ## 5 Never                5 [5. Never]                 779
    ## 6 <NA>                -9 [-9. Refused]               34
    ## 7 <NA>                -8 [-8. Don't know]             3

``` r
anes_2020 %>% count(TrustPeople, V201237)
```

    ## count: now 7 rows and 3 columns, ungrouped

    ## # A tibble: 7 × 3
    ##   TrustPeople                             V201237     n
    ##   <fct>                                 <dbl+lbl> <int>
    ## 1 Always               1 [1. Always]                 52
    ## 2 Most of the time     2 [2. Most of the time]     3842
    ## 3 About half the time  3 [3. About half the time]  2265
    ## 4 Some of the time     4 [4. Some of the time]     1810
    ## 5 Never                5 [5. Never]                 292
    ## 6 <NA>                -9 [-9. Refused]               17
    ## 7 <NA>                -8 [-8. Don't know]             2

``` r
anes_2020 %>% count(VotedPres2016, V201101)
```

    ## count: now 5 rows and 3 columns, ungrouped

    ## # A tibble: 5 × 3
    ##   VotedPres2016                 V201101     n
    ##   <fct>                       <dbl+lbl> <int>
    ## 1 Yes            1 [1. Yes, voted]       3070
    ## 2 No             2 [2. No, didn't vote]  1001
    ## 3 <NA>          -9 [-9. Refused]           14
    ## 4 <NA>          -8 [-8. Don't know]         2
    ## 5 <NA>          -1 [-1. Inapplicable]    4193

``` r
anes_2020 %>% count(VotedPres2016_selection, V201103)
```

    ## count: now 6 rows and 3 columns, ungrouped

    ## # A tibble: 6 × 3
    ##   VotedPres2016_selection                 V201103     n
    ##   <fct>                                 <dbl+lbl> <int>
    ## 1 Clinton                  1 [1. Hillary Clinton]  3172
    ## 2 Trump                    2 [2. Donald Trump]     2746
    ## 3 Other                    5 [5. Other {SPECIFY}]   432
    ## 4 <NA>                    -9 [-9. Refused]           48
    ## 5 <NA>                    -8 [-8. Don't know]         2
    ## 6 <NA>                    -1 [-1. Inapplicable]    1880

``` r
anes_2020 %>% count(VotedPres2020, V202109x)
```

    ## count: now 3 rows and 3 columns, ungrouped

    ## # A tibble: 3 × 3
    ##   VotedPres2020              V202109x     n
    ##   <fct>                     <dbl+lbl> <int>
    ## 1 Yes            1 [1. Voted]          6450
    ## 2 No             0 [0. Did not vote]   1039
    ## 3 <NA>          -2 [-2. Not reported]   791

``` r
anes_2020 %>% count(VotedPres2020_selection, V202073)
```

    ## count: now 13 rows and 3 columns, ungrouped

    ## # A tibble: 13 × 3
    ##    VotedPres2020_selection                                         V202073     n
    ##    <fct>                                                         <dbl+lbl> <int>
    ##  1 Biden                    1 [1. Joe Biden]                                3267
    ##  2 Trump                    2 [2. Donald Trump]                             2462
    ##  3 Other                    3 [3. Jo Jorgensen]                               69
    ##  4 Other                    4 [4. Howie Hawkins]                              23
    ##  5 Other                    5 [5. Other candidate {SPECIFY}]                  56
    ##  6 Other                    7 [7. Specified as Republican candidate]           1
    ##  7 Other                    8 [8. Specified as Libertarian candidate]          3
    ##  8 Other                   11 [11. Specified as don't know]                    2
    ##  9 Other                   12 [12. Specified as refused]                      16
    ## 10 <NA>                    -9 [-9. Refused]                                   53
    ## 11 <NA>                    -7 [-7. No post-election data, deleted due to …    77
    ## 12 <NA>                    -6 [-6. No post-election interview]               754
    ## 13 <NA>                    -1 [-1. Inapplicable]                            1497

``` r
anes_2020 %>% count(EarlyVote2020, V201025x, VotedPres2020)
```

    ## count: now 12 rows and 4 columns, ungrouped

    ## # A tibble: 12 × 4
    ##    EarlyVote2020                                    V201025x VotedPres2020     n
    ##    <fct>                                           <dbl+lbl> <fct>         <int>
    ##  1 Yes            4 [4. Registered and voted early]          Yes             414
    ##  2 Yes            4 [4. Registered and voted early]          <NA>              1
    ##  3 No             1 [1. Not registered (or DK/RF), does not… Yes              35
    ##  4 No             2 [2. Not registered (or DK/RF), intends … Yes             109
    ##  5 No             3 [3. Registered but did not vote early (… Yes            5891
    ##  6 <NA>          -4 [-4. Technical error]                    Yes               1
    ##  7 <NA>           1 [1. Not registered (or DK/RF), does not… No              301
    ##  8 <NA>           1 [1. Not registered (or DK/RF), does not… <NA>             56
    ##  9 <NA>           2 [2. Not registered (or DK/RF), intends … No              180
    ## 10 <NA>           2 [2. Not registered (or DK/RF), intends … <NA>             47
    ## 11 <NA>           3 [3. Registered but did not vote early (… No              558
    ## 12 <NA>           3 [3. Registered but did not vote early (… <NA>            687

``` r
anes_2020 %>%
  summarise(WtSum = sum(Weight, na.rm = TRUE)) %>%
  pull(WtSum)
```

    ## summarise: now one row and one column, ungrouped

    ## [1] 7453

## Save data

``` r
write_rds(anes_2020, here("Data", "anes_2020.rds"), compress = "gz")
```
