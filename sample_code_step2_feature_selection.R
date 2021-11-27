# Clear workspace: 
rm(list = ls())


library(h2o)
library(tidyverse)

# set variables
outcome <- "anycomp" # outcome: Any Post-surgical Complications
list_variables <- c("AMONTH", "AWEEKEND", "CM_ALCOHOL", "CM_ANEMDEF", "CM_ARTH", 
                    "CM_BLDLOSS", "CM_CHF", "CM_CHRNLUNG", "CM_COAG", "CM_DEPRESS", 
                    "CM_DM", "CM_DMCX", "CM_DRUG", "CM_HTN_C", "CM_HYPOTHY", "CM_LIVER", 
                    "CM_LYMPH", "CM_LYTES", "CM_NEURO", "CM_OBESE", "CM_PARA", "CM_PERIVASC", 
                    "CM_PSYCH", "CM_PULMCIRC", "CM_RENLFAIL", "CM_TUMOR", "CM_VALVE", 
                    "CM_WGHTLOSS", "HOSPID", "DISCWT", "NIS_STRATUM", "FEMALE", "H_CONTRL", 
                    "HOSP_BEDSIZE", "HOSP_LOCTEACH", "PL_NCHS", "RACE", "ZIPINC_QRTL", 
                    "pr_blood", "age_cat", "pay1_cat", "YEAR", "anycomp")
predictors <- setdiff(list_variables, outcome)

# set categorical variables list 
list_factors <- setdiff(list_variables, 'DISCWT') 


# load data
df <- fread('tka.tka_rdy.csv') %>% as_tibble() %>% 
  mutate_at(vars(all_of(list_factors)), ~factor(.,ordered = FALSE)) %>%
  dplyr::select(list_variables)

df <- bdx %>% as_tibble() %>% 
  mutate_at(vars(all_of(list_factors)), ~factor(.,ordered = FALSE)) %>%
  dplyr::select(all_of(list_variables))

## activate h2o environment 
h2o.init(nthreads = -1) ## -1: use all available threads    
h2o.removeAll() ## Clean slate - just in case the cluster was already running

## preprocess data
df_h2o <- as.h2o(df)   # set bdx as h2o format to be compatible with h2o

## split into train and test based on CV or not
split_ratio <- c(0.5,0.2)   # single valid splitting - set split ratio (0.5/0.2/0.3) to get train / valid / test data   

split_df <- h2o.splitFrame(df_h2o, 
                           ratios = split_ratio,
                           seed = 13113)  # set seed to get reproducible results 

df_train  <-  split_df[[1]]   ## training data
df_valid  <-  split_df[[2]]   ## validating data 
df_test   <-  split_df[[3]]   ## testing data

df_ft_slct <- h2o.rbind(df_train, df_valid) ## data for feature selection

gbm.ft <- h2o.gbm(x = predictors, y = outcome, training_frame = df_ft_slct) ## train a GBM model for feature selection

df_vip <- h2o.varimp(gbm.ft) %>% as_tibble() ## extract variable importance dataframe 

vars_lst <- df_vip$variable ## list all variables based on the importance value

## select 25% of the most important variables
vip25 <- vars_lst[1:ceiling(length(vars_lst)*.25)]

## select 50% of the most important variables
vip50 <- vars_lst[1:ceiling(length(vars_lst)*.5)]

## select 75% of the most important variables
vip75 <- vars_lst[1:ceiling(length(vars_lst)*.75)]

## select 100% of the most important variables (no feature selection)
vip100 <- vars_lst

## save 4 different variable lists after feature selection 
ft_slct_lst <- list(vip25 = vars_lst[1:ceiling(length(vars_lst)*.25)],
               vip50 = vars_lst[1:ceiling(length(vars_lst)*.5)],
               vip75 = vars_lst[1:ceiling(length(vars_lst)*.75)],
               vip100 = vars_lst)

write_rds(ft_lst, file = 'ft_slct_lst.rds')

