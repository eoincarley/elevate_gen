pro define_ecliptic

	nlines = 200
	str = dblarr(nlines)
	str[*] = 2.5

	lat0 = 85.0
	lat1 = 95.0
	stth = ( dindgen(nlines)*(lat1 - lat0)/(nlines-1.) ) + lat0
	stth[*] = 0.0 ;stth*!dtor
	new_stth = stth

	lon0 = 	-90.0
	lon1 =   90.0
	stph = ( dindgen(nlines)*(lon1 - lon0)/(nlines-1.) ) + lon0
	stph = stph*!dtor

	;junk = execute('pfss_trace_field')

	coord = [1.0, stth, stph]

	for i=0, n_elements(stth)-1 do begin
		coord = [1.0, stth[i], stph[i]]
		CONVERT_STEREO_COORD, '2010-08-10T00:00', coord, 'HEE', 'HEEQ'
		new_stth[i] = coord[1]
	endfor
	stop
	;------------------------------------

	ptr_deg = ptr
	ptth_deg = ptth*!radeg*10.0
	ptph_deg = (ptph + 180.0)*!radeg*10.0

	pfss_mag_create, magout, 3, 180.0, 2, file='synop_Ml_0.2100.fits'
	plot_image, magout > (-100) < 200

	set_line_color
	for i=0, 199 do plots, ptph[*, i]/10.0 + 180.0, ptth[*, i]/10.0, psym=3, /data, color=3

END