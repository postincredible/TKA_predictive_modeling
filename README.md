# TKA predictive modeling

This folder contains sample code for applying GBM for predictive modeling of TKA patients extracted from the NIS 2010 dataset in 3 steps.

Step 1. The SAS code is used to extract the target TKA population from the NIS 2010 data with all variables of interest. 

Step 2. The R code was used to do the feature selection based on GBM and created a list of top 25%, 50%, 75%, and 100% variables after feature selection.

Step 3. There are four R codes to run GBM predictive model based on different settings of feature selection. 


Data preparation SAS code was tested under SAS 9.4. 
All R codes were tested under R (Version 4.0.2) and Rstudio (Version 1.3.959).
