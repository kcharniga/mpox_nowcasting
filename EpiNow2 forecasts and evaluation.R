# 2022 mpox forecasts using EpiNow2

# Load R packages
library(reshape2)
library(tidyverse)
library(dplyr)
library(EpiNow2) # version 1.3.2

# Load functions
source("estimate_params/code for lessons learned/Functions/natural_history_params_function.R")
source("estimate_params/code for lessons learned/Functions/performance_assessment_function.R")

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

# Is the snapshot before or after October 2022?
before_october <- ifelse(snapshot_no < 7, 1, 0)

# Get incubation period and serial interval depending on date of snapshot
# (columns 3-4 of Table S1)
params <- get_natural_history_parameters(before_october = before_october) 

incubation_period_rash <- params$incubation_period_rash
serial_interval <- params$serial_interval

#############################################
# Load case data that have been pre-processed
#############################################

# Note that these data have already been right truncated according to column 7 of Table S1
# (this means we removed some dates from the end of the time series)
# Starting with September 6, the data have also been left truncated (this means
# we removed some dates from the beginning of the time series). We reduced
# the estimation period due to fitting issues with EpiNow2.
complete_cases <- readRDS("estimate_params/code for lessons learned/Data/complete_cases_list.RDS")

complete_cases <- complete_cases[[snapshot_no]]

# Plot time series to check
ggplot(complete_cases) +
	theme_classic() +
	geom_col(aes(x=date, y=confirm), fill="grey60", size=.1) 

# Load in the reporting delay distribution
reporting_delay <- readRDS("estimate_params/code for lessons learned/Data/reporting_delay_list.RDS")

# Corresponds to the same number as for the snapshot above
reporting_delay <- reporting_delay[[snapshot_no]]


set.seed(1234)
# run epinow to obtain Rt estimates and nowcasts/forecasts
tictoc::tic() # see how long it takes
epinow_res <- epinow(
	reported_cases = complete_cases,
	generation_time = serial_interval,
	delays = delay_opts(incubation_period_rash, reporting_delay),
	horizon = 7, # default
	stan = stan_opts(samples = 2000, chains = 3, cores = 3) # run 3 chains in parallel and allocate 3 cores
)
tictoc::toc()
beepr::beep() # lets you know when it's done running

estimates <- as_tibble(epinow_res$estimates$summarised) 

# Format dates
estimates$date <- as.Date(estimates$date)

# subset to variables of interest
est1 <- filter(estimates, variable == "reported_cases")

# Combine epinow2 results to case data
to_save <- left_join(est1, complete_cases)

forecast <- select(to_save, -strat) %>%
    filter(type == 'forecast') %>%
	select(-confirm,-type,-variable) %>%
	mutate(date = as.Date(date))

# Import gold standard data from March 16, 2023 that has been pre-processed
gold <- readRDS("estimate_params/code for lessons learned/Data/gold_data_16march2023.RDS")

# merge gold data with forecast
all <- merge(forecast, gold, by = 'date')

# Convert integer to numeric
all <- all %>% mutate_if(is.integer, as.numeric)

# Use a function to get the performance assessment metrics
eval_metrics <- eval_forecasts(all)

pic <- eval_metrics$pic
avg_wis <- eval_metrics$avg_wis
MAE <- eval_metrics$MAE

