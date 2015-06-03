pro make_all_folders, specific_date = specific_date

	; Initially I only produced folders for where there was an EUV wave detected in the LMSAL archive.
	; Now, I want to have all folders, even when no wave reported.
	use_network
	elev_folder = '~/Data/elevate_db/'
	sep_folder = elev_folder + 'SEPserver/'
	cd, elev_folder
	current_folder_dates = file_search('*-*') 
	current_foler_times = anytim(current_folder_dates, /utim)
	aia_lambda = ['171', '193', '211']	; Angstroms

	;-----------------------;
	;	  Read SEP times
	readcol, sep_folder+'soho_onset.txt', obs_tstart, format='A'
	;Roughly, 55-80 MeV protons arrive ~1hr after first EM signatures. Also take into account rough light travel time:
	em_start = anytim(obs_tstart, /utim) - 60.0*60.0*1.0 + 8.0*60.0
	obs_tstart = em_start
	index_aia_era = where(anytim(obs_tstart, /utim) gt anytim(file2time('20100801_000000'), /utim))
	obs_tstart = obs_tstart[index_aia_era]
	all_folder_dates = anytim(obs_tstart, /cc, /date_only)


	;-----------------------;
	;	 Get AIA Data
	;
	index=0
	while index le n_elements(all_folder_dates)-1 do begin 	;Shitty loop
		
		if keyword_set(specific_date) then begin
			folder = anytim(specific_date, /cc, /date_only)
			tstart = anytim(specific_date, /utim)
			index = n_elements(all_folder_dates)-1
		endif else begin
			folder = all_folder_dates[index]
			tstart = obs_tstart[index] 
		endelse	
		
		exist = where(folder eq current_folder_dates)
		
		if exist eq -1 then begin
			box_message, str2arr(folder + ',Folder does not exist. Making folder. Downloading')
			for j=0, 2 do spawn, 'mkdir -p ' + elev_folder + folder + '/SDO/AIA/' + aia_lambda[i]
		endif 

		t0 = anytim( tstart - 10.0*60.0, /cc, /trun)
		t1 = anytim( tstart + 50.0*60.0, /cc, /trun)

		out_folder = elev_folder + folder + '/SDO/AIA/' 
		box_message, str2arr('Downloading data into '+out_folder+'between times '+t0+' and '+t1 )

		stop
		files = vso_search( t0, t1, instr = 'AIA', wave = aia_lambda[0]+' Angstrom')
		result = vso_get(files, OUT_DIR = out_folder+'/'+aia_lambda[0])
		wait, 1.0*60.0
		files = vso_search( t0, t1, instr = 'AIA', wave = aia_lambda[1]+' Angstrom')
		result = vso_get(files, OUT_DIR = out_folder+'/'+aia_lambda[1])
		wait, 1.0*60.0
		files = vso_search( t0, t1, instr = 'AIA', wave = aia_lambda[2]+' Angstrom')
		result = vso_get(files, OUT_DIR = out_folder+'/'+aia_lambda[2])
		wait, 1.0*60.0
		box_message, str2arr(folder + ',Folder exists. Downloading')
		
		index = index+1
	endwhile

stop

END