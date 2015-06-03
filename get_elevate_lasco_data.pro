pro get_elevate_lasco_data

	sep_folder = ''
	elev_folder = '~/Data/elevate_db/'
	folder_dates = file_search('*-*') 
	foler_times = anytim(folder_dates, /ut)

	;-----------------------;
	;	  Read SEP times
	cd, sep_folder
	readcol, fname, obs_tstart, format='A'
	;Roughly, 55-80 MeV protons arrive ~1hr after first EM signatures. Also take into account rough light travel time:
	em_start = anytim(obs_tstart, /utim) - 60.0*60.0*1.0 + 8.0*60.0 
	
	for i=0, n_elements(em_start)-1 do begin

		t0_cme = anytim(em_start[i], /cc)
		t1_cme = anytim(em_start[i] + 60.0*60.0*10.0, /cc) ;CME search window is em_start + 10 hours.
		;-----------------------;
		;	  LASCO search
		c2search = vso_search(t0_cme, t1_cme, instr='LASCO', detector='C2')
		if n_elements(result) gt 1 do begin
		  out_dir = elev_folder + date + 'SOHO/LASCO/C2'
		endif	

	endfor




END