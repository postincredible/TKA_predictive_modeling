# Clear workspace: 
rm(list = ls())


library(caret)
library(data.table)
library(h2o)
library(pROC) 
library(rms)
library(tidyverse)

# set variables
outcome <- "anycomp" # outcome: Any Post-surgical Complications

ft_slct_lst <- readRDS(file = 'ft_slct_lst.rds') # load variables after feature selection
list_variables <- c(ft_slct_lst$vip25, outcome) # use top 25% of the features
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

### MODEL TRAINING AND PREDICTING
## GBM model with random search 
grid_params <- list(max_depth = c(3, 5,  10, 15)
                    ,sample_rate = c(0.8, 1.0)
                    ,col_sample_rate = c(0.5,0.8,1)
                    ,col_sample_rate_change_per_level = c(0.9,1,1.1)
                    ,col_sample_rate_per_tree = c(0.5, 0.8, 1.0)
                    ,ntrees=c(50,100,200))

grid_criteria <- list(strategy = "RandomDiscrete",
                      stopping_metric = 'AUC',
                      stopping_tolerance = 0.00001,
                      stopping_rounds = 5,
                      seed = 9527)

g <- h2o.grid(algorithm = 'gbm', 
              seed = 9527,
              x = predictors,
              y = outcome,
              grid_id = "GBM_grid",
              training_frame = df_train,
              validation_frame = df_valid,
              learn_rate=0.05,
              learn_rate_annealing=0.99,
              stopping_metric = 'AUC',
              stopping_tolerance = 0.0001,
              stopping_rounds = 5,
              max_runtime_secs = 3600, 
              score_tree_interval = 10,  
              balance_classes = TRUE,
              parallelism = 0,
              hyper_params = grid_params,
              search_criteria = grid_criteria)


## list model w.r.t maximum AUC  
grid.perf <- h2o.getGrid(grid_id = "GBM_grid"
                         ,sort_by = 'AUC'
                         ,decreasing = TRUE) 

## obtain best model w.r.t maximum AUC 
fit_best <- h2o.getModel(as.character(grid.perf@model_ids[1]))

## obtain threshold based on MAX F1
perf <- h2o.performance(fit_best, df_test)
threshold <- h2o.find_threshold_by_max_metric(perf, "f1")

### EVALUATIONS
posind <- max(levels(as.factor(df[[outcome]]))) # define positive class
## model performance based on test data:
test_pred <- h2o.predict(object = fit_best, newdata = df_test) %>% as_tibble() # obtain predictions for df_test
test_pred <- test_pred %>% mutate(true = as_tibble(df_test)[[outcome]])

## confusion matrix
confusion_matrix <- confusionMatrix(test_pred$predict, test_pred$true, positive = posind, mode = "everything")  # 2x2 table between predict and true and important Statistics

## F1 score
confusion_matrix$byClass[['F1']] 

## AUC
test_auc <- roc(test_pred$true, test_pred$p1)
ci.auc(tt_bdx_auc, method = 'd') # 95% CI of AUC

## 3 metrics
metrics <- val.prob(test_pred$p1, as.numeric(as.character(test_pred$true)) , 
                    pl = FALSE) %>% round(6)

Brier <- metrics[11] # Brier score
Intercept <- metrics[12] # Intercept for calibration
Slope <- metrics[13] # Slope for calibration


