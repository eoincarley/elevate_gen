pro make_instrument_folders
	
	elev_folder = '~/Data/elevate_db/'
	cd, elev_folder
	folder_dates = file_search('*-*') 

	soho_folders = ['/SOHO/ENRE/', '/SOHO/LASCO/']


	for i=0, n_elements(folder_dates)-1 do begin
		;cd, elev_folder + folder_dates[i]
		;spawn, 'cp ' + elev_folder + folder_dates[i] + soho_folders[0] + 'soho_erne*.txt ~/Dropbox/soho_erne/'
		;spawn, 'mkdir -p ' + elev_folder + folder_dates[i] + soho_folders[1]
		spawn, 'mkdir -p ' + elev_folder + folder_dates[i] + '/ACE/'

	endfor	




END