library(tidyverse)

food_balances <- read_csv("data\\FoodBalanceSheets_E_All_Data_NOFLAG.csv")
food_balances <- food_balances %>%
  filter(!(`Item Code` %in% c("2949","2948","2928"))) %>% # Removing duplicates for eggs, milk, miscellaneous
  select(-c("Area Code", "Item Code", "Element Code", "Unit")) %>%
  pivot_longer(Y2010:Y2019,names_to = "Year", values_to = "value") %>%
  mutate(Area = replace(Area, Area == "Côte d'Ivoire", "Cote d'Ivoire"),
         Year = as.integer(gsub("Y","",Year)),
         Item = replace(Item, Item == "Population", "Grand Total")) %>%
  pivot_wider(names_from = Element, values_from = value) %>%
  rename("Population" = `Total Population - Both sexes`) %>%
  mutate(Population = Population * 1000) %>%
  mutate(across(Production:Food, ~ .x * 1000))

write_csv(food_balances, "data\\food_balances.csv")
