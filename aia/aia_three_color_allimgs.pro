pro aia_three_color_allimgs, start_index, stop_index, winnum

	cd,'~/Data/elevate_db/'
	folders = file_search('*-*')

	;for j=0, n_elements(folders)-1 do begin
;		aia_three_color_eoin, date = folders[j], /xwin
;	endfor

	for j=start_index, stop_index do begin
		aia_three_color, date = folders[j], /xwin, winnum=winnum;, /parallelise
	endfor


END
