American National Election Studies (ANES) 2016 Time Series Study Data
Prep
================

## Data information

All data and resources were downloaded from
<https://electionstudies.org/data-center/2016-time-series-study/> on
April 3, 2021.

American National Election Studies. 2019. ANES 2016 Time Series Study
\[dataset and documentation\]. September 4, 2019 version.
www.electionstudies.org

``` r
library(here) #easy relative paths
```

``` r
library(tidyverse) #data manipulation
```

    ## -- Attaching packages ----------------------------- tidyverse 1.3.0 --

    ## v ggplot2 3.3.3     v purrr   0.3.4
    ## v tibble  3.1.0     v dplyr   1.0.5
    ## v tidyr   1.1.3     v stringr 1.4.0
    ## v readr   1.4.0     v forcats 0.5.1

    ## -- Conflicts -------------------------------- tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
library(haven) #data import
library(tidylog) #informative logging messages
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
anes_in <- read_sav(here("RawData", "ANES_2016", "anes_timeseries_2016.sav"))


anes <- anes_in %>%
   select('V160102',    'V160201',  'V160202',  'V160501',  'V161004',  'V161005',  'V161006',  'V161024x', 'V161158x', 'V161215',  'V161219',  'V161267',  'V161267',  'V161270',  'V161310x', 'V161342',  'V161361x', 'V162031',  'V162031x', 'V162034',  'V162034a', 'V162062x', 'V162062x'
   ) %>%
   mutate(
      InterviewMode=fct_recode(as.character(V160501), FTF="1", Web="2"),
      Weight=V160102,
      Stratum=as.factor(V160201),
      VarUnit=as.factor(V160202),
      Age=if_else(V161267>0, as.numeric(V161267), NA_real_),
      AgeGroup=cut(Age, c(17, 29, 39, 49, 59, 69, 200),
                   labels=c("18-29", "30-39", "40-49", "50-59", "60-69", "70 or older")),
      Gender=factor(
         case_when(
            V161342==1~"Male",
            V161342==2~"Female",
            V161342==3~"Other",
            TRUE~NA_character_
         ),
         levels=c("Male", "Female", "Other")
      ),
      RaceEth=factor(
         case_when(
            V161310x==1~"White",
            V161310x==2~"Black",
            V161310x==5~"Hispanic",
            V161310x==3~"Asian, NH/PI",
            near(V161310x, 4)~"AI/AN",
            near(V161310x, 6)~"Other/multiple race",
            TRUE ~ NA_character_
         ),
         levels=c("White", "Black", "Hispanic", "Asian, NH/PI", "AI/AN", "Other/multiple race", NA_character_)
      ),
      PartyID=factor(
         case_when(
            V161158x==1~"Strong democrat",
            V161158x==2~"Not very strong democrat",
            V161158x==3~"Independent-democrat",
            V161158x==4~"Independent",
            V161158x==5~"Independent-republican",
            V161158x==6~"Not very strong republican",
            V161158x==7~"Strong republican",
            TRUE ~ NA_character_
         ),
         levels=c("Strong democrat", "Not very strong democrat", "Independent-democrat", "Independent", "Independent-republican", "Not very strong republican", "Strong republican")
      ),
      Education=factor(
         case_when(
            V161270 <=0~NA_character_,
            V161270 <= 8~"Less than HS",
            V161270==9|V161270==90~"High school",
            V161270<=12~"Post HS",
            V161270==13~"Bachelor's",
            V161270<=16~"Graduate",
            TRUE~NA_character_
         ),
         levels=c("Less than HS", "High school", "Post HS", "Bachelor's", "Graduate")
      ),
      Income=cut(V161361x, c(-5, 1:28),
                 labels=c("Under $5k", 
                          "$5-10k", "$10-12.5k", "$12.5-15", "$15-17.5k", "$17.5-20k", "$20-22.5k", "$22.5-25k", "$25-27.5k", "$27.5-30k", "$30-35k", "$35-40k", "$40-45k", "$45-50k", "$50-55k", "$55-60k", "$60-65k","$65-70k", "$70-75k", "$75-80k", "$80-90k", "$90-100k","$100-110k", "$110-125k", "$125-150k", "$150-175k", "$175-250k", "$250k or more"  )
      ), 
      Income7=fct_collapse(
         Income,
         "Under $20k"=c("Under $5k", "$5-10k", "$10-12.5k", "$12.5-15", "$15-17.5k", "$17.5-20k"),
         "$20-40k"=c("$20-22.5k", "$22.5-25k", "$25-27.5k", "$27.5-30k", "$30-35k", "$35-40k"),
         "$40-60k"=c( "$40-45k", "$45-50k", "$50-55k", "$55-60k"),
         "$60-80k"=c( "$60-65k", "$65-70k", "$70-75k", "$75-80k"),
         "$80-100k"=c("$80-90k", "$90-100k"),
         "$100-125k"=c("$100-110k", "$110-125k"),
         "$125k or more"=c("$125-150k", "$150-175k", "$175-250k", "$250k or more")
      ),
      CampaignInterest=factor(
         case_when(
            V161004==1~"Very much interested",
            V161004==2~"Somewhat interested",
            V161004==3~"Not much interested",
            TRUE~NA_character_
         ),
         levels=c("Very much interested", "Somewhat interested", "Not much interested")
      ),
      TrustGovernment=factor(
         case_when(
            V161215==1~"Always",
            V161215==2~"Most of the time",
            V161215==3~"About half the time",
            V161215==4~"Some of the time",
            V161215==5~"Never",
            TRUE~NA_character_
         ),
         levels=c("Always", "Most of the time", "About half the time", "Some of the time", "Never")
      ),
      TrustPeople=factor(
         case_when(
            V161219==1~"Always",
            V161219==2~"Most of the time",
            V161219==3~"About half the time",
            V161219==4~"Some of the time",
            V161219==5~"Never",
            TRUE ~ NA_character_
         ),
         levels=c("Always", "Most of the time", "About half the time", "Some of the time", "Never")
      ),
      VotedPres2012=factor(
         case_when(
            V161005==1~"Yes",
            V161005==2~"No",
            TRUE~NA_character_
         ), levels=c("Yes", "No")
      ),
      VotedPres2012_selection=factor(
         case_when(
            V161006==1~"Obama",
            V161006==2~"Romney",
            V161006==5~"Other",
            TRUE~NA_character_
         ), levels=c("Obama", "Romney", "Other")
      ),
      VotedPres2016=factor(
         case_when(
            V162031x==1~"Yes",
            V162031x==0~"No",
            TRUE~NA_character_
         ), levels=c("Yes", "No")
      ),
      VotedPres2016_selection=factor(
         case_when(
            V162062x==1~"Clinton",
            V162062x==2~"Trump",
            V162062x >=3 ~"Other",
            TRUE~NA_character_
         ), levels=c("Clinton", "Trump", "Other")
      ),
      EarlyVote2016=factor(
         case_when(
            V161024x==4~"Yes",
            VotedPres2016=="Yes"~"No",
            TRUE~NA_character_
         ), levels=c("Yes", "No")
      )
   )
```

    ## select: dropped 1,821 variables (version, V160001, V160001_orig, V160101, V160101f, …)

    ## mutate: new variable 'InterviewMode' (factor) with 2 unique values and 0% NA

    ##         new variable 'Weight' (double) with 2,609 unique values and 0% NA

    ##         new variable 'Stratum' (factor) with 132 unique values and 0% NA

    ##         new variable 'VarUnit' (factor) with 3 unique values and 0% NA

    ##         new variable 'Age' (double) with 74 unique values and 3% NA

    ##         new variable 'AgeGroup' (factor) with 7 unique values and 3% NA

    ##         new variable 'Gender' (factor) with 4 unique values and 1% NA

    ##         new variable 'RaceEth' (factor) with 7 unique values and 1% NA

    ##         new variable 'PartyID' (factor) with 8 unique values and 1% NA

    ##         new variable 'Education' (factor) with 6 unique values and 1% NA

    ##         new variable 'Income' (factor) with 29 unique values and 5% NA

    ##         new variable 'Income7' (factor) with 8 unique values and 5% NA

    ##         new variable 'CampaignInterest' (factor) with 3 unique values and 0% NA

    ##         new variable 'TrustGovernment' (factor) with 6 unique values and 1% NA

    ##         new variable 'TrustPeople' (factor) with 6 unique values and <1% NA

    ##         new variable 'VotedPres2012' (factor) with 3 unique values and <1% NA

    ##         new variable 'VotedPres2012_selection' (factor) with 4 unique values and 28% NA

    ##         new variable 'VotedPres2016' (factor) with 3 unique values and 22% NA

    ##         new variable 'VotedPres2016_selection' (factor) with 4 unique values and 34% NA

    ##         new variable 'EarlyVote2016' (factor) with 3 unique values and 32% NA

``` r
summary(anes)
```

    ##     V160102          V160201          V160202         V160501     
    ##  Min.   :0.0000   Min.   :  1.00   Min.   :1.000   Min.   :1.000  
    ##  1st Qu.:0.3934   1st Qu.: 36.00   1st Qu.:1.000   1st Qu.:1.000  
    ##  Median :0.7481   Median : 71.00   Median :1.500   Median :2.000  
    ##  Mean   :0.8541   Mean   : 69.58   Mean   :1.505   Mean   :1.724  
    ##  3rd Qu.:1.1294   3rd Qu.:105.00   3rd Qu.:2.000   3rd Qu.:2.000  
    ##  Max.   :6.4445   Max.   :133.00   Max.   :3.000   Max.   :2.000  
    ##                                                                   
    ##     V161004       V161005          V161006           V161024x    
    ##  Min.   :1.0   Min.   :-9.000   Min.   :-9.0000   Min.   :1.000  
    ##  1st Qu.:1.0   1st Qu.: 1.000   1st Qu.:-1.0000   1st Qu.:3.000  
    ##  Median :1.0   Median : 1.000   Median : 1.0000   Median :3.000  
    ##  Mean   :1.6   Mean   : 1.232   Mean   : 0.6773   Mean   :2.804  
    ##  3rd Qu.:2.0   3rd Qu.: 2.000   3rd Qu.: 2.0000   3rd Qu.:3.000  
    ##  Max.   :3.0   Max.   : 2.000   Max.   : 6.0000   Max.   :4.000  
    ##                                                                  
    ##     V161158x         V161215         V161219          V161267     
    ##  Min.   :-9.000   Min.   :-9.00   Min.   :-9.000   Min.   :-9.00  
    ##  1st Qu.: 2.000   1st Qu.: 3.00   1st Qu.: 2.000   1st Qu.:33.00  
    ##  Median : 4.000   Median : 4.00   Median : 3.000   Median :49.00  
    ##  Mean   : 3.792   Mean   : 3.49   Mean   : 2.831   Mean   :47.92  
    ##  3rd Qu.: 6.000   3rd Qu.: 4.00   3rd Qu.: 4.000   3rd Qu.:63.00  
    ##  Max.   : 7.000   Max.   : 5.00   Max.   : 5.000   Max.   :90.00  
    ##                                                                   
    ##     V161270         V161310x         V161342          V161361x    
    ##  Min.   :-9.00   Min.   :-2.000   Min.   :-9.000   Min.   :-9.00  
    ##  1st Qu.: 9.00   1st Qu.: 1.000   1st Qu.: 1.000   1st Qu.: 8.00  
    ##  Median :11.00   Median : 1.000   Median : 2.000   Median :15.00  
    ##  Mean   :11.66   Mean   : 1.787   Mean   : 1.432   Mean   :14.25  
    ##  3rd Qu.:13.00   3rd Qu.: 2.000   3rd Qu.: 2.000   3rd Qu.:22.00  
    ##  Max.   :95.00   Max.   : 6.000   Max.   : 3.000   Max.   :28.00  
    ##                                                                   
    ##     V162031          V162031x          V162034           V162034a      
    ##  Min.   :-8.000   Min.   :-8.0000   Min.   :-9.0000   Min.   :-9.0000  
    ##  1st Qu.:-1.000   1st Qu.: 0.0000   1st Qu.:-1.0000   1st Qu.:-1.0000  
    ##  Median : 4.000   Median : 1.0000   Median : 1.0000   Median : 1.0000  
    ##  Mean   : 1.759   Mean   : 0.2349   Mean   :-0.4625   Mean   :-0.1468  
    ##  3rd Qu.: 4.000   3rd Qu.: 1.0000   3rd Qu.: 1.0000   3rd Qu.: 2.0000  
    ##  Max.   : 4.000   Max.   : 1.0000   Max.   : 2.0000   Max.   : 9.0000  
    ##                                                                        
    ##     V162062x       InterviewMode     Weight          Stratum     VarUnit 
    ##  Min.   :-9.0000   FTF:1180      Min.   :0.0000   123    :  57   1:2135  
    ##  1st Qu.:-2.0000   Web:3090      1st Qu.:0.3934   121    :  55   2:2115  
    ##  Median : 1.0000                 Median :0.7481   126    :  55   3:  20  
    ##  Mean   : 0.3393                 Mean   :0.8541   118    :  52           
    ##  3rd Qu.: 2.0000                 3rd Qu.:1.1294   108    :  50           
    ##  Max.   : 5.0000                 Max.   :6.4445   107    :  46           
    ##                                                   (Other):3955           
    ##       Age               AgeGroup      Gender                    RaceEth    
    ##  Min.   :18.00   18-29      :651   Male  :1987   White              :3038  
    ##  1st Qu.:34.00   30-39      :761   Female:2231   Black              : 397  
    ##  Median :50.00   40-49      :620   Other :  11   Hispanic           : 450  
    ##  Mean   :49.58   50-59      :781   NA's  :  41   Asian, NH/PI       : 148  
    ##  3rd Qu.:63.00   60-69      :769                 AI/AN              :  27  
    ##  Max.   :90.00   70 or older:567                 Other/multiple race: 177  
    ##  NA's   :121     NA's       :121                 NA's               :  33  
    ##                        PartyID           Education          Income    
    ##  Strong democrat           :890   Less than HS: 282   Under $5k: 275  
    ##  Strong republican         :721   High school : 815   $80-90k  : 231  
    ##  Independent               :579   Post HS     :1499   $30-35k  : 213  
    ##  Not very strong democrat  :559   Bachelor's  : 955   $60-65k  : 205  
    ##  Not very strong republican:508   Graduate    : 680   $50-55k  : 204  
    ##  (Other)                   :990   NA's        :  39   (Other)  :2940  
    ##  NA's                      : 23                       NA's     : 202  
    ##           Income7                CampaignInterest            TrustGovernment
    ##  $20-40k      :773   Very much interested:2230    Always             :  66  
    ##  Under $20k   :703   Somewhat interested :1519    Most of the time   : 429  
    ##  $40-60k      :621   Not much interested : 521    About half the time:1382  
    ##  $125k or more:615                                Some of the time   :1826  
    ##  $60-80k      :576                                Never              : 545  
    ##  (Other)      :780                                NA's               :  22  
    ##  NA's         :202                                                          
    ##               TrustPeople   VotedPres2012 VotedPres2012_selection VotedPres2016
    ##  Always             :  50   Yes :3117     Obama :1728             Yes :2887    
    ##  Most of the time   :1765   No  :1137     Romney:1268             No  : 444    
    ##  About half the time:1305   NA's:  16     Other :  58             NA's: 939    
    ##  Some of the time   : 947                 NA's  :1216                          
    ##  Never              : 188                                                      
    ##  NA's               :  15                                                      
    ##                                                                                
    ##  VotedPres2016_selection EarlyVote2016
    ##  Clinton:1364            Yes : 156    
    ##  Trump  :1245            No  :2731    
    ##  Other  : 202            NA's:1383    
    ##  NA's   :1459                         
    ##                                       
    ##                                       
    ## 

## Check derived variables for correct coding

``` r
anes %>% count(InterviewMode, V160501)
```

    ## count: now 2 rows and 3 columns, ungrouped

    ## # A tibble: 2 x 3
    ##   InterviewMode          V160501     n
    ##   <fct>                <dbl+lbl> <int>
    ## 1 FTF           1 [1. FTF /CASI]  1180
    ## 2 Web           2 [2. Web]        3090

``` r
anes %>% group_by(AgeGroup) %>% summarise(minAge=min(Age), maxAge=max(Age), minV=min(V161267), maxV=max(V161267))
```

    ## group_by: one grouping variable (AgeGroup)

    ## summarise: now 7 rows and 5 columns, ungrouped

    ## # A tibble: 7 x 5
    ##   AgeGroup    minAge maxAge                   minV                          maxV
    ##   <fct>        <dbl>  <dbl>              <dbl+lbl>                     <dbl+lbl>
    ## 1 18-29           18     29 18                     29                           
    ## 2 30-39           30     39 30                     39                           
    ## 3 40-49           40     49 40                     49                           
    ## 4 50-59           50     59 50                     59                           
    ## 5 60-69           60     69 60                     69                           
    ## 6 70 or older     70     90 70                     90 [90. Age 90 or older]     
    ## 7 NA              NA     NA -9 [-9. RF (year of b~ -8 [-8. DK (year of birth, F~

``` r
anes %>% count(Gender, V161342)
```

    ## count: now 4 rows and 3 columns, ungrouped

    ## # A tibble: 4 x 3
    ##   Gender          V161342     n
    ##   <fct>         <dbl+lbl> <int>
    ## 1 Male    1 [1. Male]      1987
    ## 2 Female  2 [2. Female]    2231
    ## 3 Other   3 [3. Other]       11
    ## 4 NA     -9 [-9. Refused]    41

``` r
anes %>% count(RaceEth, V161310x)
```

    ## count: now 7 rows and 3 columns, ungrouped

    ## # A tibble: 7 x 3
    ##   RaceEth                                                         V161310x     n
    ##   <fct>                                                          <dbl+lbl> <int>
    ## 1 White             1 [1. White, non-Hispanic]                              3038
    ## 2 Black             2 [2. Black, non-Hispanic]                               397
    ## 3 Hispanic          5 [5. Hispanic]                                          450
    ## 4 Asian, NH/PI      3 [3. Asian, native Hawaiian or other Pacif Islr,non-~   148
    ## 5 AI/AN             4 [4. Native American or Alaska Native, non-Hispanic]     27
    ## 6 Other/multiple ~  6 [6. Other non-Hispanic incl multiple races [WEB: bl~   177
    ## 7 NA               -2 [-2. Missing]                                           33

``` r
anes %>% count(PartyID, V161158x)
```

    ## count: now 9 rows and 3 columns, ungrouped

    ## # A tibble: 9 x 3
    ##   PartyID                                                         V161158x     n
    ##   <fct>                                                          <dbl+lbl> <int>
    ## 1 Strong democrat         1 [1. Strong Democrat]                             890
    ## 2 Not very strong democ~  2 [2. Not very strong Democract]                   559
    ## 3 Independent-democrat    3 [3. Independent-Democrat]                        490
    ## 4 Independent             4 [4. Independent]                                 579
    ## 5 Independent-republican  5 [5. Independent-Republican]                      500
    ## 6 Not very strong repub~  6 [6. Not very strong Republican]                  508
    ## 7 Strong republican       7 [7. Strong Republican]                           721
    ## 8 NA                     -9 [-9. RF (-9) in V161155 (FTF only) /-9 in V16~    12
    ## 9 NA                     -8 [-8. DK (-8) in V161156 or V161157 (FTF only)]    11

``` r
anes %>% count(Education, V161270)
```

    ## count: now 19 rows and 3 columns, ungrouped

    ## # A tibble: 19 x 3
    ##    Education                                                       V161270     n
    ##    <fct>                                                         <dbl+lbl> <int>
    ##  1 Less than HS  1 [1. Less than 1st grade]                                    1
    ##  2 Less than HS  2 [2. 1st, 2nd, 3rd or 4th grade]                             3
    ##  3 Less than HS  3 [3. 5th or 6th grade]                                      15
    ##  4 Less than HS  4 [4. 7th or 8th grade]                                      22
    ##  5 Less than HS  5 [5. 9th grade]                                             32
    ##  6 Less than HS  6 [6. 10th grade]                                            40
    ##  7 Less than HS  7 [7. 11th grade]                                            62
    ##  8 Less than HS  8 [8. 12th grade no diploma]                                107
    ##  9 High school   9 [9. High school graduate- high school diploma or equiv~   810
    ## 10 High school  90 [90. Other specify given as: high school graduate]          5
    ## 11 Post HS      10 [10. Some college but no degree]                          898
    ## 12 Post HS      11 [11. Associate degree in college - occupational /vocat~   313
    ## 13 Post HS      12 [12. Associate degree in college -- academic program]     288
    ## 14 Bachelor's   13 [13. Bachelor's degree (for example: BA, AB, BS)]         955
    ## 15 Graduate     14 [14. Master's degree (for example: MA, MS, MENG, MED, ~   499
    ## 16 Graduate     15 [15. Professional school degree (for example: MD, DDS,~    88
    ## 17 Graduate     16 [16. Doctorate degree (for example: PHD, EDD)]             93
    ## 18 NA           -9 [-9. Refused]                                              15
    ## 19 NA           95 [95. Other SPECIFY]                                        24

``` r
anes %>% count(Income, Income7, V161361x) %>% print(n=30)
```

    ## count: now 30 rows and 4 columns, ungrouped

    ## # A tibble: 30 x 4
    ##    Income       Income7                                           V161361x     n
    ##    <fct>        <fct>                                            <dbl+lbl> <int>
    ##  1 Under $5k    Under $20k     1 [01. Under $5,000]                          275
    ##  2 $5-10k       Under $20k     2 [02. $5,000-$9,999]                          96
    ##  3 $10-12.5k    Under $20k     3 [03. $10,000-$12,499]                       133
    ##  4 $12.5-15     Under $20k     4 [04. $12,500-$14,999]                        37
    ##  5 $15-17.5k    Under $20k     5 [05. $15,000-$17,499]                       110
    ##  6 $17.5-20k    Under $20k     6 [06. $17,500-$19,999]                        52
    ##  7 $20-22.5k    $20-40k        7 [07. $20,000-$22,499]                       153
    ##  8 $22.5-25k    $20-40k        8 [08. $22,500-$24,999]                        64
    ##  9 $25-27.5k    $20-40k        9 [09. $25,000-$27,499]                       143
    ## 10 $27.5-30k    $20-40k       10 [10. $27,500-$29,999]                        34
    ## 11 $30-35k      $20-40k       11 [11. $30,000-$34,999]                       213
    ## 12 $35-40k      $20-40k       12 [12. $35,000-$39,999]                       166
    ## 13 $40-45k      $40-60k       13 [13. $40,000-$44,999]                       178
    ## 14 $45-50k      $40-60k       14 [14. $45,000-$49,999]                       154
    ## 15 $50-55k      $40-60k       15 [15. $50,000-$54,999]                       204
    ## 16 $55-60k      $40-60k       16 [16. $55,000-$59,999]                        85
    ## 17 $60-65k      $60-80k       17 [17. $60,000-$64,999]                       205
    ## 18 $65-70k      $60-80k       18 [18. $65,000-$69,999]                       107
    ## 19 $70-75k      $60-80k       19 [19. $70,000-$74,999]                       138
    ## 20 $75-80k      $60-80k       20 [20. $75,000-$79,999]                       126
    ## 21 $80-90k      $80-100k      21 [21. $80,000-$89,999]                       231
    ## 22 $90-100k     $80-100k      22 [22. $90,000-$99,999]                       176
    ## 23 $100-110k    $100-125k     23 [23. $100,000-$109,999]                     191
    ## 24 $110-125k    $100-125k     24 [24. $110,000-$124,999]                     182
    ## 25 $125-150k    $125k or more 25 [25. $125,000-$149,999]                     166
    ## 26 $150-175k    $125k or more 26 [26. $150,000-$174,999]                     154
    ## 27 $175-250k    $125k or more 27 [27. $175,000-$249,999]                     154
    ## 28 $250k or mo~ $125k or more 28 [28. $250,000 or more]                      141
    ## 29 NA           NA            -9 [-9. Refused]                               190
    ## 30 NA           NA            -5 [-5. Interview breakoff (sufficient part~    12

``` r
anes %>% count(CampaignInterest, V161004)
```

    ## count: now 3 rows and 3 columns, ungrouped

    ## # A tibble: 3 x 3
    ##   CampaignInterest                         V161004     n
    ##   <fct>                                  <dbl+lbl> <int>
    ## 1 Very much interested 1 [1. Very much interested]  2230
    ## 2 Somewhat interested  2 [2. Somewhat interested]   1519
    ## 3 Not much interested  3 [3. Not much interested]    521

``` r
anes %>% count(TrustGovernment, V161215)
```

    ## count: now 7 rows and 3 columns, ungrouped

    ## # A tibble: 7 x 3
    ##   TrustGovernment                            V161215     n
    ##   <fct>                                    <dbl+lbl> <int>
    ## 1 Always               1 [1. Always]                    66
    ## 2 Most of the time     2 [2. Most of the time]         429
    ## 3 About half the time  3 [3. About half the time]     1382
    ## 4 Some of the time     4 [4. Some of the time]        1826
    ## 5 Never                5 [5. Never]                    545
    ## 6 NA                  -9 [-9. Refused]                  19
    ## 7 NA                  -8 [-8. Don't know (FTF only)]     3

``` r
anes %>% count(TrustPeople, V161219)
```

    ## count: now 7 rows and 3 columns, ungrouped

    ## # A tibble: 7 x 3
    ##   TrustPeople                                V161219     n
    ##   <fct>                                    <dbl+lbl> <int>
    ## 1 Always               1 [1. Always]                    50
    ## 2 Most of the time     2 [2. Most of the time]        1765
    ## 3 About half the time  3 [3. About half the time]     1305
    ## 4 Some of the time     4 [4. Some of the time]         947
    ## 5 Never                5 [5. Never]                    188
    ## 6 NA                  -9 [-9. Refused]                  14
    ## 7 NA                  -8 [-8. Don't know (FTF only)]     1

``` r
anes %>% count(VotedPres2012, V161005)
```

    ## count: now 4 rows and 3 columns, ungrouped

    ## # A tibble: 4 x 3
    ##   VotedPres2012                        V161005     n
    ##   <fct>                              <dbl+lbl> <int>
    ## 1 Yes            1 [1. Yes, voted]              3117
    ## 2 No             2 [2. No, didn't vote]         1137
    ## 3 NA            -9 [-9. Refused]                   2
    ## 4 NA            -8 [-8. Don't know (FTF only)]    14

``` r
anes %>% count(VotedPres2012_selection, V161006)
```

    ## count: now 7 rows and 3 columns, ungrouped

    ## # A tibble: 7 x 3
    ##   VotedPres2012_select~                                            V161006     n
    ##   <fct>                                                          <dbl+lbl> <int>
    ## 1 Obama                  1 [1. Barack Obama]                                1728
    ## 2 Romney                 2 [2. Mitt Romney]                                 1268
    ## 3 Other                  5 [5. Other SPECIFY]                                 58
    ## 4 NA                    -9 [-9. Refused]                                      47
    ## 5 NA                    -8 [-8. Don't know (FTF only)]                        13
    ## 6 NA                    -1 [-1. Inap, 2,-8,-9 in V161005]                   1153
    ## 7 NA                     6 [6. Other specify - specified as:  Did not vot~     3

``` r
anes %>% count(VotedPres2016, V162031x)
```

    ## count: now 4 rows and 3 columns, ungrouped

    ## # A tibble: 4 x 3
    ##   VotedPres2016                                                   V162031x     n
    ##   <fct>                                                          <dbl+lbl> <int>
    ## 1 Yes            1 [1. Voted in 2016]                                       2887
    ## 2 No             0 [0. Did not vote in 2016]                                 444
    ## 3 NA            -8 [-8. Don't know (in V162031)]                               1
    ## 4 NA            -2 [-2. Missing, 3 in V162022 /FTF: -8,-9 in V162022 /WEB~   938

``` r
anes %>% count(VotedPres2016_selection, V162062x)
```

    ## count: now 8 rows and 3 columns, ungrouped

    ## # A tibble: 8 x 3
    ##   VotedPres2016_select~                                           V162062x     n
    ##   <fct>                                                          <dbl+lbl> <int>
    ## 1 Clinton                1 [1. Hillary Clinton]                             1364
    ## 2 Trump                  2 [2. Donald Trump]                                1245
    ## 3 Other                  3 [3. Gary Johnson]                                 118
    ## 4 Other                  4 [4. Jill Stein]                                    32
    ## 5 Other                  5 [5. Other candidate SPECIFY]                       52
    ## 6 NA                    -9 [-9. Refused]                                      31
    ## 7 NA                    -8 [-8. Don't know (FTF only)]                         2
    ## 8 NA                    -2 [-2. Missing, no vote for Pres in Post /no Pos~  1426

``` r
anes %>% count(EarlyVote2016, V161024x, VotedPres2016)
```

    ## count: now 10 rows and 4 columns, ungrouped

    ## # A tibble: 10 x 4
    ##    EarlyVote2016                                    V161024x VotedPres2016     n
    ##    <fct>                                           <dbl+lbl> <fct>         <int>
    ##  1 Yes           4 [4. Registered and voted early]           Yes             156
    ##  2 No            1 [1. Not (or DK /RF if) registered, does ~ Yes              28
    ##  3 No            2 [2. Not (or DK /RF if) registered, inten~ Yes              65
    ##  4 No            3 [3. Registered but did not vote early (o~ Yes            2638
    ##  5 NA            1 [1. Not (or DK /RF if) registered, does ~ No               31
    ##  6 NA            1 [1. Not (or DK /RF if) registered, does ~ NA              322
    ##  7 NA            2 [2. Not (or DK /RF if) registered, inten~ No               46
    ##  8 NA            2 [2. Not (or DK /RF if) registered, inten~ NA              120
    ##  9 NA            3 [3. Registered but did not vote early (o~ No              367
    ## 10 NA            3 [3. Registered but did not vote early (o~ NA              497

``` r
anes %>%
   summarise(WtSum=sum(Weight)) %>%
   pull(WtSum)
```

    ## summarise: now one row and one column, ungrouped

    ## [1] 3646.921

## Save data

``` r
write_rds(anes, here("Data", "anes.rds"), compress="gz")
```
