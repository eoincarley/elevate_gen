function get_solar_wind_speed, date_time

	; date_time  is 'YYYY-MM-DDTHH:MM:SS'

	; Returns the mean solar wind speed on the day of the event in km/s

	; Improvement: Figure out what the best averaging window is. Should
	; 			   event time +/- 1 hour, 1 day etc. be used?

	;date_time = '2010-08-14T12:00:00'
	date_time_ut = anytim(date_time, /utim)
	yyyy_mm_dd = strmid(date_time, 0, 10)
	day_start = date_time_ut+30.0*60.0	;anytim(yyyy_mm_dd +'T00:00:00', /utim)
	day_end = date_time_ut-30.0*60.0  ;anytim(yyyy_mm_dd +'T23:59:59', /utim)
	yyyymm = strmid(time2file(date_time, /date_only), 0, 6)
	ace_file = yyyymm + '_ace_swepam_1h.txt'
	url = 'ftp://sohoftp.nascom.nasa.gov/sdb/goes/ace/monthly/'
	out_dir = '~/Data/elevate_db/'+yyyy_mm_dd+'/ACE/'
	spawn,'mkdir -p '+out_dir 
	
	file_check = findfile(out_dir+ace_file)
	if file_check eq '' then begin
		;-----------------------------------------;
		;			Copy the data
		;
		print, 'Downloading file from: '+url+ace_file
		sock_copy, url+ace_file, out_dir=out_dir
	endif

 	;file = '~/201008_ace_swepam_1h.txt'
	;-----------------------------------------;
	;			Read the data
	;
	file = out_dir+ace_file
	FMT = 'A, A, A, A, F, F, F, F, F, F'
	READCOL, file, F=FMT, yyyy, mm, dd, hhmm, mjd, sod, junk, p_density, v_sw, ion_temp
;
	times = dblarr(n_elements(yyyy))
	for i=0, n_elements(yyyy)-1 do times[i] = anytim(file2time(yyyy[i]+mm[i]+dd[i]+'_'+hhmm[i]), /utim)

	;utplot, times, v_sw, $
	;	/xs, $
	;	/ys, $
	;	ytitle='Solar Wind Speed (km/s)';, $
	;	yr=[200,900]

	bad_data = where( abs(deriv(times, v_sw)) gt 0.2)
	v_sw[bad_data] = !Values.F_NAN
	bad_data = where( v_sw lt 200)
	v_sw[bad_data] = !Values.F_NAN
	;set_line_color
	;outplot, times, v_sw, color=3

	indices_day = where(times gt day_start and times lt day_end)
	indices_b4_event = where(times gt day_start and times lt date_time_ut)
	mean_v_sw = mean(v_sw[indices_day], /nan)
	mean_v_sw1 = mean(v_sw[indices_b4_event], /nan)

	print, 'Mean solar wind speed on '+yyyy_mm_dd+' : '+string(mean_v_sw)+' (km/s)'
	print, 'Mean solar wind speed between' + anytim(day_start, /yoh) + ' and '$
				+ anytim(date_time_ut, /yoh) + ' :'+string(mean_v_sw1)+' (km/s)'

	if mean_v_sw lt 100.0 then spawn, 'touch	'+out_dir+yyyymm+'_wind_corrupted.txt'		

	return, mean_v_sw			
END