pro process_all_mag_day

	; Small code to run through all the mag data
	elevate_folder = '~/Data/elevate_db/'
	folders = file_search(elevate_folder+'20*')
	files = folders+'/SDO/HMI/chole_field*'	; If this file exists then the pfss extrapolation has been ran

	for i=0, n_elements(files)-1 do begin

		date = strmid(files[i], 34, 10)
		date_str2 = time2file(date, /date_only)
		print, '---------------------------'
		print, ' '
		print, 'Processing: '+date
		print, ' '
		print, '---------------------------'

		if file_test(files[i]) eq 1 then begin
			print, 'File '+files[i]+' exists.'
			mag_synoptic_map_plot, date, /post, /hs	
		endif	

		if file_test(files[i]) eq 0 then begin
			print, 'File '+files[i]+' does not exist exists. Processing...'
		

			@pfss_data_block

			;  first restore the file containing the coronal field model
			;  date/time is set here to Apr 5, 2003 for demonstration purposes, but any
			;  SSW formatted date/time will do
			pfss_restore,pfss_time2file(date,/ssw_cat,/url)  ;  for all users
			;pfss_restore,pfss_time2file('2003-04-05')   ;  for users at LMSAL

			;  starting points to be on a regular grid covering the full disk, with a
			;  starting radius of r=1.5 Rsun
			necliptic=120	; M.DeRosa default
			pfss_field_start_coord, 1, necliptic, radstart=2.5
			spacing=2.5		; M.Derosa default
			pfss_field_start_coord, 7, spacing, radstart=2.5, /add

			pfss_trace_field

			pfss_get_chfootprint, openfield2, /quiet, /usecurrent;, /sinlat  ;  for debugging
	   		pfss_get_chfootprint, openfield, /quiet, /close, /usecurrent, spacing=spacing;, /sinlat
	   		save, openfield, filename = '~/ELEVATE/data/'+date+'/SDO/HMI/chole_field_'+date_str2+'.sav'
			;-------------------------------------------;
			;		Determine open field colours
			mag_determine_color, date, rix, theta, nstep, ptr, ptth, ptph, lat, lon, br
			;------------------------------------

			rad = ptr
			lat = 90.0 - ptth*!radeg
			lon = (ptph)*!radeg + 180.0

			save, br, rad, lat, lon, filename = '~/ELEVATE/data/'+date+'/SDO/HMI/connected_field_'+date_str2+'.sav'

			mag_synoptic_map_plot, date, /post, /hs
			
		endif	
		

	endfor


END