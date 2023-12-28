# 2022 mpox forecasts using Bayesian GLM
# We will implement a glm with a log link and weekend effects using stan

library(dplyr)
library(ggplot2)
library(tidyverse)
library(here)
library(bayesplot)
theme_set(bayesplot::theme_default())
library(rstanarm)

# Load functions
source("estimate_params/code for lessons learned/Functions/left_truncation_glm_function.R")
source("estimate_params/code for lessons learned/Functions/performance_assessment_function.R")

#############################################
# Load case data that have been pre-processed
#############################################

# Note that these data have already been right truncated according to column 7 of Table S1
# (this means we removed some dates from the end of the time series)
# Starting with September 6, the data have also been left truncated (this means
# we removed some dates from the beginning of the time series).
complete_cases <- readRDS("estimate_params/code for lessons learned/Data/complete_cases_list.RDS")

# Choose date for snapshot
# 1: June 13
# 2: June 27
# 3: July 5
# 4: July 27
# 5: September 6
# 6: September 19
# 7: October 11
# 8: December 5
snapshot_no <- 1

complete_cases <- complete_cases[[snapshot_no]]

# Plot time series to check
ggplot(complete_cases) +
	theme_classic() +
	geom_col(aes(x=date, y=confirm), fill="grey60", size=.1) 

# Only fit the most recent ~3 weeks of data, with the first date starting on a Monday
# and the last date ending on a Friday, except for the first snapshot where we do not 
# left truncate the data
left_trunc_date <- left_truncate_data_for_glm(complete_cases, snapshot_no)

complete_cases <- filter(complete_cases, date > left_trunc_date)

######################
# Model fitting
######################

# Adding an indicator for weekend
complete_cases$weekend <- ifelse(weekdays(as.Date(as.character(complete_cases$date),"%Y-%m-%d")) %in% c('Sunday','Saturday'), 1, 0)

# Estimate Bayesian version with stan_glm
stan_glm2 <- stan_glm(confirm ~ as.numeric(date) + weekend, 
					  data = complete_cases, family =  neg_binomial_2,
					  prior = normal(0, 2.5),
					  prior_intercept = normal(0, 5),
					  seed = 12345)

summary(stan_glm2)

new_data <- data.frame(date = seq(max(complete_cases$date)+1, max(complete_cases$date)+7, "days"),
					   weekend = c(1,1,rep(0,5)))

new_data$date <- as.numeric(new_data$date)

# Get model fits
y_rep1 <- posterior_predict(stan_glm2)

# Get medians and CrIs
res1 <- data.frame(date = complete_cases$date,
				   median = apply(y_rep1, 2, FUN = median),
				   lower_90 = apply(y_rep1, 2, quantile, probs = 0.05),
				   upper_90 = apply(y_rep1, 2, quantile, probs = 0.95),
				   lower_50 = apply(y_rep1, 2, quantile, probs = 0.25),
				   upper_50 = apply(y_rep1, 2, quantile, probs = 0.75),
				   lower_20 = apply(y_rep1, 2, quantile, probs = 0.40),
				   upper_20 = apply(y_rep1, 2, quantile, probs = 0.60))

# Get out of sample predictions
y_rep <- posterior_predict(stan_glm2, newdata = new_data)

# Get medians and CrIs
res <- data.frame(date = seq(max(complete_cases$date)+1, max(complete_cases$date)+7, "days"),
				  median = apply(y_rep, 2, FUN = median),
				  lower_90 = apply(y_rep, 2, quantile, probs = 0.05),
				  upper_90 = apply(y_rep, 2, quantile, probs = 0.95),
				  lower_50 = apply(y_rep, 2, quantile, probs = 0.25),
				  upper_50 = apply(y_rep, 2, quantile, probs = 0.75),
				  lower_20 = apply(y_rep, 2, quantile, probs = 0.40),
				  upper_20 = apply(y_rep, 2, quantile, probs = 0.60))

# Combine predictions
res_all <- rbind(res1, res)

# Merge with cases used to calibrate model
to_plot <- merge(res_all, complete_cases, by = "date", all = T)


p1 <- to_plot |>
	ggplot(aes(date, confirm)) +
	geom_line() +
	geom_line(aes(y = median), color = "red") +
	geom_ribbon(aes(ymin = lower_90, ymax = upper_90),
				alpha = 0.1, fill = "red") +
	theme_classic()
p1

model_predictions <- to_plot

# Import gold standard data from March 16, 2023 that has been pre-processed
gold <- readRDS("estimate_params/code for lessons learned/Data/gold_data_16march2023.RDS")

# Drop case counts used to make predictions
model_predictions <- select(model_predictions, -confirm)

# merge observed cases and forecast
all <- merge(model_predictions, gold, by = 'date', all.x = T)

# Convert integer to numeric
all <- all %>% mutate_if(is.integer, as.numeric)

# Only the rows we need
all <- all[(nrow(all)-6):nrow(all),]

# Use a function to get the performance assessment metrics
eval_metrics <- eval_forecasts(all)

pic <- eval_metrics$pic
avg_wis <- eval_metrics$avg_wis
MAE <- eval_metrics$MAE

