pro aia_extract_wave_times

	; Procedure to get a list of all AIA times from http://aia.lmsal.com/AIA_Waves/.

	sock_list,'http://aia.lmsal.com/AIA_Waves/', aia_page

	wave_times_html = aia_page[where(strmid(aia_page, 0, 4) eq '<tr>')]
	wave_times = wave_times_html
	FOR i = 0, n_elements(wave_times_html)-1 DO BEGIN
		wave_time_info = strsplit(wave_times_html[i],  "</td><td>", /extract, /regex)
		wave_time_info = strsplit(wave_time_info,  "<tr><td>", /extract, /regex)
		wave_times[i] = anytim(wave_time_info[0]+' '+wave_time_info[1], /cc) 
	ENDFOR	
	save, wave_times, wave_times_html, filename = 'lmsal_euv_wave_times.sav'

stop
END