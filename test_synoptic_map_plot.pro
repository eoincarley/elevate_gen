pro test_synoptic_map_plot

	loadct, 5
	window, 0, xs=1250, ys=550
	!p.charsize = 1.5

	file='~/ELEVATE/data/pfss/hmi.Synoptic_Mr_720s.2150.synopMr.fits'
	
	;pfss_mag_create, magout, 4, 1800.0, 2, file='~/ELEVATE/data/pfss/hmi.Synoptic_Mr_720s.2104.synopMr.fits'
	;plot_image, magout > (-200) < 200

	mreadfits, file, hdr, data



	;axis, xaxis = 0, xr = [0, 360], xtitle = 'Carrington Longitude (deg)'
	;axis, yaxis = 1, yr = [-1, 1], ytitle = 'Sine latitude'

	plot_image, data > (-200) < (200), $
			XTICKFORMAT="(A1)", $
			YTICKFORMAT="(A1)", $
			xticklen=0.001, $
			yticklen=0.001, $
			position = [0.1, 0.1, 0.9, 0.9]; ystyle=4;xticks=2, yticks=2, ytickname=['', '', ''], xtickname=['','', '']

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


	

	naxis2 = (size(data))[2]
	naxis = dindgen(naxis2)
	sinlat = (dindgen(100)*(1.0 + 1.0)/99.0 ) - 1.0

	;sin_point = sin(lat)
	;ypos = interpol(naxis, sinlat, sin_point)

	;for i=0, 199 do plots, interpol(naxis, sinlat, sin_point[*, i]), ptth_deg[*, i]*10.0, psym=3, /data, color=3

	stop



END