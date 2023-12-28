# Nowcasting/forecasting mpox in the US

This repository contains the data and code necessary to reproduce the analysis for the paper entitled “Nowcasting and Forecasting the 2022 U.S. Mpox Outbreak: Support for Public Health Decision Making and Lessons Learned.” The paper is posted as a preprint on medRxiv (https://doi.org/10.1101/2023.04.14.23288570) and has been submitted to a peer-reviewed journal. 

To run the nowcasts/forecasts and evaluation for EpiNow2, use the “EpiNow2 forecasts and evaluation.R” script.
To run the nowcasts/forecasts and evaluation for the Bayesian GLM, use the “Bayes GLM forecasts and evaluation.R” script.

As the line list data could not be made publicly available, we describe the data processing steps in detail here.
There are three files in the “Data” folder:
1.	complete_cases_list
2.	gold_data_16march2023 
3.	reporting_delay_list

complete_cases_list is an RDS file containing a list of eight dataframes. Each dataframe has two variables, “date” and “confirm,” which is the preferred format for EpiNow2. “Confirm” refers to the number of laboratory-confirmed mpox cases. See the Appendix of the paper for an explanation of the date field.

gold_data_16march2023 is a csv file that contains a dataframe with the same format as the dataframes in “complete_cases_list.” This snapshot of the mpox case data was pulled from DCIPHER on March 16, 2023 and was used for the retrospective evaluation of the forecasts. Minimal data processing was performed (i.e., no left- or right-truncation).

reporting_delay_list is an RDS file containing a list of eight lists. Each list within the main list has five quantities: mean, mean_sd, sd, sd_sd, and max which correspond to the reporting delay distribution that we estimated from the line list data. We followed these steps to estimate the delay:

•	Filter the mpox case data to exclude cases that were missing at least one reference date (see Table S1, column 5)

•	Do some basic checks and exclude cases with unlikely dates (e.g., very long delays or negative delays)

Then, we used the bootstrapped_dist_fit function in EpiNow2:

reporting_delay <- bootstrapped_dist_fit(
	no_miss$reference_date2 - no_miss$rash_onset_date,
	dist = "lognormal",
	max_value = 29,
	bootstraps = 1
)

Where no_miss is a subset of the case data containing only cases that have both reference dates and “reference_date2” refers to the second date listed in column 5 of Table S1. 


