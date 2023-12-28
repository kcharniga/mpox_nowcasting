eval_forecasts <- function(all){
	
	all <- all %>%
		mutate(
			IS_20 = case_when(
				(confirm < lower_20) & (confirm > upper_20) ~ (upper_20 - lower_20) + (2/.2 * (lower_20 - confirm)) + (2/.2 * (confirm - upper_20)),
				(confirm < lower_20) & (confirm <= upper_20) ~ (upper_20 - lower_20) + (2/.2 * (lower_20 - confirm)),
				(confirm >= lower_20) & (confirm > upper_20) ~ (upper_20 - lower_20) + (2/.2 * (confirm - upper_20)),
				(confirm >= lower_20) & (confirm <= upper_20) ~ (upper_20 - lower_20)
			),
			
			IS_50 = case_when(
				(confirm < lower_50) & (confirm > upper_50) ~ (upper_50 - lower_50) + (2/.5 * (lower_50 - confirm)) + (2/.5 * (confirm - upper_50)),
				(confirm < lower_50) & (confirm <= upper_50) ~ (upper_50 - lower_50) + (2/.5 * (lower_50 - confirm)),
				(confirm >= lower_50) & (confirm > upper_50) ~ (upper_50 - lower_50) + (2/.5 * (confirm - upper_50)),
				(confirm >= lower_50) & (confirm <= upper_50) ~ (upper_50 - lower_50)
			),
			
			IS_90 = case_when(
				(confirm < lower_90) & (confirm > upper_90) ~ (upper_90 - lower_90) + (2/.9 * (lower_90 - confirm)) + (2/.9 * (confirm - upper_90)),
				(confirm < lower_90) & (confirm <= upper_90) ~ (upper_90 - lower_90) + (2/.9 * (lower_90 - confirm)),
				(confirm >= lower_90) & (confirm > upper_90) ~ (upper_90 - lower_90) + (2/.9 * (confirm - upper_90)),
				(confirm >= lower_90) & (confirm <= upper_90) ~ (upper_90 - lower_90)
			),
			
			in_20 = ifelse((confirm >= lower_20) & (confirm <= upper_20), 1, 0),
			in_50 = ifelse((confirm >= lower_50) & (confirm <= upper_50), 1, 0),
			in_90 = ifelse((confirm >= lower_90) & (confirm <= upper_90), 1, 0)
		)
	
	pic <- all %>%
		summarise(
			# prediction interval coverage
			pic_20 = sum(in_20) / nrow(all),
			pic_50 = sum(in_50) / nrow(all),
			pic_90 = sum(in_90) / nrow(all)
		)
	
	# Get the WIS for each day of the 7-day forecast
	W0 <- 0.5
	alpha <- c(0.2, 0.5, 0.9)
	k <- length(alpha)
	Wk <- alpha/2
	
	WIS_20_50_90 <- vector()
	for (i in 1:nrow(all)) {
		
		WIS_20_50_90[i] <- (1/(k + 0.5)) * (W0 * abs(all$confirm[i] - all$median[i]) + # changed median to fit
												((Wk[1]*all$IS_20[i]) +
												 	(Wk[2]*all$IS_50[i]) +
												 	(Wk[3]*all$IS_90[i])))
		
	}
	
	# Average WIS over 7 day forecast
	avg_wis <- sum(WIS_20_50_90)/7
	
	##########
	
	# Now calculate MAE
	AE <- vector()
	for (i in 1:nrow(all)){
		
		AE[i] <- abs(all$confirm[i] - all$median[i])
		
	}
	
	MAE <- sum(AE)/7
	
	return(list = list(pic = pic, avg_wis = avg_wis, MAE = MAE))
	
}