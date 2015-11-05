pro mag_define_ecliptic

	nlines = 200
	str = dblarr(nlines)
	str[*] = 2.5

	lat0 = 89.0
	lat1 = 91.0
	stth = ( dindgen(nlines)*(lat1 - lat0)/(nlines-1.) ) + lat0
	stth = stth*!dtor

	lon0 = -180.0
	lon1 = 180.0
	stph = ( dindgen(nlines)*(lon1 - lon0)/(nlines-1.) ) + lon0
	stph = stph*!dtor

	;junk = execute('pfss_trace_field')

	; To get the color of these lines, go to pfss_draw_field3.pro. On line 143 there is a for loop
	; that sets each field line property. The color of the field line can be gotten here from the
	; olist object. The olist object is created by pfss_view_create.


	coord = [1.0, stth, stph]

	for i=0, n_elements(stth)-1 do begin
		coord = [1.0, stth[i], stph[i]]
		CONVERT_STEREO_COORD, '2010-08-10T00:00', coord, 'HEE', 'HEEQ'
		new_stth[i] = coord[1]
	endfor

	;------------------------------------

	rad = ptr
	lat = 90.0 - ptth*!radeg
	lon = (ptph)*!radeg + 180.0

	save, br, rad, lat, lon, filename = '~/ELEVATE/data/pfss/connected_field_20100810.sav'

	window, 0
	pfss_mag_create, magout, 4, 1800.0, 2, file='~/ELEVATE/data/pfss/synopMr_2150.fits'
	plot_image, magout > (-100) < 200

	set_line_color
	for i=0, 199 do plots, ptph_deg[*, i], ptth_deg[*, i]*10.0, psym=3, /data, color=3

END