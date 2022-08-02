Data cleaning
================
2022-08-02

The Food and Agriculture Organization (FAO) of the United Nations (UN)
leads international efforts to defeat hunger and improve nutrition and
food security. FAOSTAT, the statistics division of FAO, provides free
access to [food and agriculture
data](https://www.fao.org/faostat/en/#data) for over 245 countries.  
In this project, the datasets provided by FAOSTAT will be cleaned
according to the [tidy data
framework](https://cran.r-project.org/web/packages/tidyr/vignettes/tidy-data.html).

## Importing libraries

``` r
library(tidyverse)
library(knitr)
```

## Datasets

The datasets are downloaded in CSV format.

``` r
food_balances <- read_csv("data\\FoodBalanceSheets_E_All_Data_NOFLAG.csv")
```

Food balances:

| Area Code | Area        | Item Code | Item             | Element Code | Element                                | Unit            |    Y2010 |    Y2011 |    Y2012 |    Y2013 |    Y2014 |    Y2015 |    Y2016 |    Y2017 |    Y2018 |    Y2019 |
|----------:|:------------|----------:|:-----------------|-------------:|:---------------------------------------|:----------------|---------:|---------:|---------:|---------:|---------:|---------:|---------:|---------:|---------:|---------:|
|         2 | Afghanistan |      2501 | Population       |          511 | Total Population - Both sexes          | 1000 persons    | 29186.00 | 30117.00 | 31161.00 | 32270.00 | 33371.00 | 34414.00 | 35383.00 | 36296.00 | 37172.00 | 38042.00 |
|         2 | Afghanistan |      2501 | Population       |         5301 | Domestic supply quantity               | 1000 tonnes     |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |     0.00 |
|         2 | Afghanistan |      2901 | Grand Total      |          664 | Food supply (kcal/capita/day)          | kcal/capita/day |  2170.00 |  2152.00 |  2159.00 |  2196.00 |  2265.00 |  2250.00 |  2228.00 |  2303.00 |  2270.00 |  2273.00 |
|         2 | Afghanistan |      2901 | Grand Total      |          674 | Protein supply quantity (g/capita/day) | g/capita/day    |    59.23 |    58.00 |    57.82 |    57.71 |    60.17 |    58.45 |    58.46 |    59.50 |    57.62 |    57.31 |
|         2 | Afghanistan |      2901 | Grand Total      |          684 | Fat supply quantity (g/capita/day)     | g/capita/day    |    36.69 |    34.81 |    36.53 |    37.10 |    41.48 |    38.28 |    40.70 |    40.03 |    41.46 |    39.78 |
|         2 | Afghanistan |      2903 | Vegetal Products |          664 | Food supply (kcal/capita/day)          | kcal/capita/day |  1964.00 |  1953.00 |  1955.00 |  1993.00 |  2019.00 |  2038.00 |  2024.00 |  2108.00 |  2081.00 |  2087.00 |

## Cleaning

### Food balances

-   Rows with Item == “eggs”, “milk”, or “miscellaneous” are duplicated
    as these items have 2 distinct - Item Codes each. We filter out
    these duplicate items.
-   The Area Code, Item Code, Element Code, and Unit columns will be
    dropped as they do not contain any new information.
-   The Y2010 to Y2019 columns are values and not variables. We pivot
    these columns into 2 new columns: Year and value. We also convert
    the year values to integers for easy sorting later on.
-   The values in Element are variable names. We pivot each element onto
    a different column.

``` r
food_balances <- food_balances %>%
  filter(!(`Item Code` %in% c("2949","2948","2928"))) %>%
  select(-c("Area Code", "Item Code", "Element Code", "Unit")) %>%
  pivot_longer(Y2010:Y2019,names_to = "Year", values_to = "value") %>%
  mutate(Year = as.integer(gsub("Y","",Year)),
         Item = replace(Item, Item == "Population", "Grand Total")) %>%
  pivot_wider(names_from = Element, values_from = value)
```

The food balances dataset is now in a tidy form. Next:

-   We rename certain columns for simplicity
-   There are columns in units of 1,000. We multiply the values in these
    columns by 1,000 to get the actual values

``` r
food_balances <- food_balances %>%
  rename("Population" = `Total Population - Both sexes`) %>%
  mutate(Population = Population * 1000) %>%
  mutate(across(Production:Food, ~ .x * 1000))
```

Cleaned dataset:

| Area        | Item        | Year | Population | Domestic supply quantity | Food supply (kcal/capita/day) | Protein supply quantity (g/capita/day) | Fat supply quantity (g/capita/day) | Production | Import Quantity | Stock Variation | Export Quantity | Feed | Seed | Losses | Processing | Other uses (non-food) | Tourist consumption | Residuals | Food | Food supply quantity (kg/capita/yr) |
|:------------|:------------|-----:|-----------:|-------------------------:|------------------------------:|---------------------------------------:|-----------------------------------:|-----------:|----------------:|----------------:|----------------:|-----:|-----:|-------:|-----------:|----------------------:|--------------------:|----------:|-----:|------------------------------------:|
| Afghanistan | Grand Total | 2010 |   29186000 |                        0 |                          2170 |                                  59.23 |                              36.69 |         NA |              NA |              NA |              NA |   NA |   NA |     NA |         NA |                    NA |                  NA |        NA |   NA |                                  NA |
| Afghanistan | Grand Total | 2011 |   30117000 |                        0 |                          2152 |                                  58.00 |                              34.81 |         NA |              NA |              NA |              NA |   NA |   NA |     NA |         NA |                    NA |                  NA |        NA |   NA |                                  NA |
| Afghanistan | Grand Total | 2012 |   31161000 |                        0 |                          2159 |                                  57.82 |                              36.53 |         NA |              NA |              NA |              NA |   NA |   NA |     NA |         NA |                    NA |                  NA |        NA |   NA |                                  NA |
| Afghanistan | Grand Total | 2013 |   32270000 |                        0 |                          2196 |                                  57.71 |                              37.10 |         NA |              NA |              NA |              NA |   NA |   NA |     NA |         NA |                    NA |                  NA |        NA |   NA |                                  NA |
| Afghanistan | Grand Total | 2014 |   33371000 |                        0 |                          2265 |                                  60.17 |                              41.48 |         NA |              NA |              NA |              NA |   NA |   NA |     NA |         NA |                    NA |                  NA |        NA |   NA |                                  NA |
| Afghanistan | Grand Total | 2015 |   34414000 |                        0 |                          2250 |                                  58.45 |                              38.28 |         NA |              NA |              NA |              NA |   NA |   NA |     NA |         NA |                    NA |                  NA |        NA |   NA |                                  NA |
