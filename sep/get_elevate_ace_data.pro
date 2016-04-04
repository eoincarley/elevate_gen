pro get_elevate_ace_data

	
	ace_url = 'ftp://ftp.swpc.noaa.gov/pub/lists/''
	remote_path = ['ace', 'ace2']
	elev_folder = '~/Data/elevate_db/'
	folder_dates = file_search('*-*') 


	for i=0, n_elements(folder_dates)-1 do begin
		date = time2file(anytim(folder_dates[i], /utim), /date_only)
		epam_file = date + '_ace_epam_5m.txt'
		swepam_file = date + '_ace_swepam_1m.txt'
		sis_file = date + '_ace_sis_5m.txt'
		mag_file = date + '_ace_mag_1m.txt'

		sock_copy, epam_file, out_dir = elev_folder + folder_dates[i] + '/ACE'
		sock_copy, swepam_file, out_dir = elev_folder + folder_dates[i] + '/ACE'
		sock_copy, sis_file, out_dir = elev_folder + folder_dates[i] + '/ACE'
		sock_copy, mag_file, out_dir = elev_folder + folder_dates[i] + '/ACE'

	endfor



END