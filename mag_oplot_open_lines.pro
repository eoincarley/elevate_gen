pro mag_oplot_open_lines, data, folder
		
	open_field_file = findfile(folder + 'SDO/HMI/connected_field_*.sav')
	colors_file = findfile(folder + 'SDO/HMI/open_colours_*.sav')
	restore, open_field_file[0], /verb
	restore, colors_file[0], /verb


	colors = intarr(n_elements(open))
	colors[where(open eq 1)] = 4
	colors[where(open eq -1)] = 3

	lon = lon*10.0 					; For use on synoptic map.
	sinlat = sin(lat*!dtor)			; Sine of the latitude.
	ypix = lat

	nBlines = (size(rad))[2]
	npoints = (size(data))[2]
	ypixels = dindgen(npoints)

	sinlat_points = (dindgen(npoints)*(1.0 - (-1.0))/(npoints-1) ) + (-1.0)

	for i=0, nBlines-1 do begin
		ypix_line = interpol(ypixels, sinlat_points, sinlat[*, i])
		ypix[*, i] = ypix_line
	endfor

	;------Map to Carrongtinton longitudes-----;
	lon_new = lon + 1800.0 
	lon_new[where(lon_new gt 3600.0)] = lon_new[where(lon_new gt 3600.0)] - 3600.0
	

	set_line_color
		;plots, lon[*, 80], ypix[*, 80], color=4, /data, psym=3

	for i=0, n_elements(lon_new[0, *])-1 do begin
		plots, lon_new[*,i], ypix[*,i], color=colors[i], /data, psym=3
	endfor	
	

END