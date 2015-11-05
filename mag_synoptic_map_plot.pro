pro mag_synoptic_map_plot

	;------------Read and plot the synoptic map-------------;

	loadct, 0
	window, 0, xs=1250, ys=550
	!p.charsize = 1.5
	file='~/ELEVATE/data/pfss/hmi.Synoptic_Mr_720s.2100.synopMr.fits'
	
	;pfss_mag_create, magout, 4, 1800.0, 2, file='~/ELEVATE/data/pfss/hmi.Synoptic_Mr_720s.2104.synopMr.fits'

	;------------Read and plot the synoptic map-------------;

	mreadfits, file, hdr, data

	plot_image, data > (-200) < (200), $
			XTICKFORMAT="(A1)", $
			YTICKFORMAT="(A1)", $
			xticklen=0.001, $
			yticklen=0.001, $
			position = [0.1, 0.1, 0.9, 0.9];, $
			;title = hdr.telescop+' '+hdr.date+' UT'; ystyle=4;xticks=2, yticks=2, ytickname=['', '', ''], xtickname=['','', '']

	axis, xaxis = 0, xr = [0, 360], xticks=6, xtitle = 'Carrington Longitude (deg)', /xs
	axis, yaxis = 0, yr = [-1, 1], ytitle = 'Sine latitude', /ys

	degs = [-90, -60, -40, -20, 0, 20, 40, 60, 90]
	degs_sin = sin(degs*!dtor)
	degs_label = string(degs, format='(I3)') 

	axis, yaxis = 1, yr = [-1, 1], $
			yticks=8, $
			ytickv = degs_sin, $
			ytickname = degs_label, $
			ytitle = 'Latitude (deg)', $
			/ys

	restore, '~/ELEVATE/data/pfss/connected_field_20100810.sav', /verb
	restore, '~/ELEVATE/data/pfss/open_closed_20100810.sav', /verb

	colors = intarr(n_elements(open))
	colors[where(open eq 1)] = 4
	colors[where(open eq -1)] = 3

	lon = lon*10.0 					; For use on synoptic map.
	sinlat = sin(lat*!dtor)		; Sine of the latitude.
	ypix = lat

	nBlines = (size(rad))[2]
	npoints = (size(data))[2]
	ypixels = dindgen(npoints)

	sinlat_points = (dindgen(npoints)*(1.0 - (-1.0))/(npoints-1) ) + (-1.0)

	for i=0, nBlines-1 do begin
		ypix_line = interpol(ypixels, sinlat_points, sinlat[*, i])
		ypix[*, i] = ypix_line
	endfor

	;------Map to Carrongtinton lonitudes-----;
	lon_new = lon + 1800.0 
	lon_new[where(lon_new gt 3600.0)] = lon_new[where(lon_new gt 3600.0)] - 3600.0
	
	set_line_color
		;plots, lon[*, 80], ypix[*, 80], color=4, /data, psym=3

	for i=0, n_elements(lon_new[0, *])-1 do begin
		plots, lon_new[*,i], ypix[*,i], color=colors[i], /data, psym=3
	endfor	
	

	

	stop

END