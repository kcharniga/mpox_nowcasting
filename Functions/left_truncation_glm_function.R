left_truncate_data_for_glm <- function(complete_cases, snapshot_no){
	
	if (snapshot_no == 1){
		t_date <- as.Date("2022-05-15")
	} 
	else if (snapshot_no == 2){
		t_date <- as.Date("2022-06-05")
	}
	else if (snapshot_no == 3){
		t_date <- as.Date("2022-06-12")
	}
	else if (snapshot_no == 4){
		t_date <- as.Date("2022-07-03")
	}
	else if (snapshot_no == 5){
		t_date <- as.Date("2022-08-14")
	}
	else if (snapshot_no == 6){
		t_date <- as.Date("2022-08-28")
	}
	else if (snapshot_no == 7){
		t_date <- as.Date("2022-09-18")
	} 
	else if (snapshot_no == 8){
		t_date <- as.Date("2022-11-13")
	} else {
		t_date <- NA
	}

	return(t_date)
		
}

