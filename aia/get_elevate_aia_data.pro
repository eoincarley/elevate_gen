pro get_elevate_aia_data, assoc_wave_times
	
	use_network

	lambda = ['171', '193', '211']			; Angstroms
	restore, assoc_wave_times, /verb		; Wave times in /utim
	;start_file = 0

	;for i = 0, n_elements(wave_times)-1 do begin
	if start_file lt n_elements(assoc_wave_times) then begin

		YYYMMDD = anytim(assoc_wave_times[start_file], /cc, /date_only)
		out_folder = '~/Data/ELEVATE/SDO/AIA/' + YYYMMDD
		for j=0, 2 do spawn, 'mkdir -p ' + out_folder + '/' + lambda[j]
		;endfor	

		;DOWNLOAD INTO APPROPRIATE FOLDER
		;FOR i=0, n_elements(assoc_wave_time)-1 DO BEGIN
		t0 = anytim( assoc_wave_times[start_file] - 10.0*60.0, /cc, /trun)
		t1 = anytim( assoc_wave_times[start_file] + 50.0*60.0, /cc, /trun)

		files = vso_search( t0, t1, instr = 'AIA', wave = lambda[0]+' Angstrom')
		result = vso_get(files, OUT_DIR = out_folder+'/'+lambda[0], /FORCE)
		;stop
		files = vso_search( t0, t1, instr = 'AIA', wave = lambda[1]+' Angstrom')
		result = vso_get(files, OUT_DIR = out_folder+'/'+lambda[1], /FORCE)
		;stop
		files = vso_search( t0, t1, instr = 'AIA', wave = lambda[2]+' Angstrom')
		result = vso_get(files, OUT_DIR = out_folder+'/'+lambda[2], /FORCE)

		;ENDFOR	

		;SAVE TIMES FOR REMAINING DOWNLOADS.
		start_file = start_file + 1
		save, assoc_wave_times, start_file, filename = '~/Data/elevate_db/assoc_wave_times.sav'

	endif else begin
		print, 'Nothing to download. Exiting.'
	endelse	

END