pro mag_oplot_open_lines, data, folder
		
	open_field_file = findfile(folder + 'SDO/HMI/connected_field_*.sav')
	colors_file = findfile(folder + 'SDO/HMI/open_colour_*.sav')
	restore, open_field_file[0], /verb
	restore, colors_file[0], /verb

	colors = intarr(n_elements(open))
	colors[where(open eq 1)] = 4
	colors[where(open eq -1)] = 3
					
	sinlat = sin(lat*!dtor)			; Sine of the latitude.	

	lon_new = lon - 180.0 
	lon_new[where(lon_new gt 360.0)] = lon_new[where(lon_new gt 360.0)] - 360.0
	lon_new[where(lon_new lt 0.0)] = lon_new[where(lon_new lt 0.0)] + 360.0
	
	set_line_color	
	for i=0, 119 do begin	;n_elements(lon_new[0, *])-1 do begin
		plots, lon_new[*,i], sinlat[*,i], color=colors[i], /data, psym=3
	endfor

	for i=0, n_elements(lon_new[0, *])-1 do begin
		plots, lon_new[0,i], sinlat[0,i], color=colors[i], /data, psym=1, symsize=1.5
	endfor	

END