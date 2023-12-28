get_natural_history_parameters <- function(before_october){
	
	if(before_october == 1){
		
		# Incubation period distribution from Charniga et al. 
		incubation_period_rash <- list(
			mean = convert_to_logmean(8.7, 4.3),
			mean_sd = 0.1, # assumed
			sd =  convert_to_logsd(8.7, 4.3),
			sd_sd = 0.1, # assumed
			max = 26
		)
		
		# Serial interval distribution from UKHSA TR 1 posted on June 10
		serial_interval <- list(
			mean = convert_to_logmean(9.8, 8.6),
			mean_sd = 0.1, # Assumed
			sd = convert_to_logsd(9.8, 8.6),
			sd_sd = 0.1, # Assumed
			max = 25
		)
		
	} else {
		
		# Incubation period distribution for rash onset from Madewell et al.
		incubation_period_rash <- list(
			mean = convert_to_logmean(7.5, 4.9),
			mean_sd = 0.12,
			sd =  convert_to_logsd(7.5, 4.9),
			sd_sd = 0.09,
			max = 26
		)
		
		# Serial interval distribution for rash onset from Madewell et al. 
		serial_interval <- list(
			mean = convert_to_logmean(7.0, 4.2),
			mean_sd = 0.1, # Obtained from fitting log normal distribution to data and taking sd of logmean (parameter 1)
			sd = convert_to_logsd(7.0, 4.2),
			sd_sd = 0.08, # Obtained from fitting log normal distribution to data and taking sd of logsd (parameter 2)
			max = 25
		)
		
	}
	
	return(list = list(incubation_period_rash = incubation_period_rash,
					   serial_interval = serial_interval))
	
}