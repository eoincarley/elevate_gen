pro setup_ps, name
  
   set_plot,'ps'
   !p.font=0
   !p.charsize=1.5
   device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=15, $
          ysize=7, $
          bits_per_pixel=32, $
          /encapsulate

end

;-----------------------------------------------------------------;
;					Coronal hole positions.
;-----------------------------------------------------------------;

pro get_chole_pos, openfield, xsize, ysize, $		; input
		lon_points, sinlat_points, $				; output
		positive=positive, negative=negative		; keywords
	
	if keyword_set(positive) then pos = where(openfield gt 0.01) else pos = where(openfield lt -0.01)

	pos = array_indices(openfield, pos)
	index_x = pos[0, *]
	index_range = dindgen(xsize)
	lon_range = findgen(xsize)*(180 + 180)/(xsize-1) - 180
	lon_points = transpose(interpol(lon_range, index_range, index_x))

	index_y = pos[1, *]
	index_range = findgen(ysize)
	lat_range = (findgen(ysize)*(90.+90.)/(ysize-1) - 90.0) 
	latpoints = interpol(lat_range, index_range, index_y)
	sinlat_points = transpose(sin( latpoints*!dtor ))

END

;-----------------------------------------------------------------;
;				Heliospheric current sheet finder.
;-----------------------------------------------------------------;

pro calc_helio_curr_sheet, extrem_map, lon, ypix, rad, colors, $
		lon_points,	lat_points

	; The heliospheric current sheet field lines will generally reach greater than 2.4 solar radii in the pfss.
	; This point is found in this alogorithm and then averaged/smoothed.
	print, '--------------------------'
	print, 'Finding position of heliospheric current sheet.'
	extrem_map[*] = 1.
	xsize = (size(extrem_map))[1]
	ysize = (size(extrem_map))[2]

	for i=0, n_elements(rad[0, *])-1 do begin
		extrem_map[ lon[where(rad[*, i] ge 2.4), i], ypix[where(rad[*, i] ge 2.4), i] ] = 1.
		extrem_map[ lon[where(rad[*, i] le 2.4), i], ypix[where(rad[*, i] le 2.4), i] ] = 0.
	endfor	

	result = filter_image(extrem_map, fwhm=20, /ALL_PIXELS)
	;plot_image, result > 1.0

	min_pos = where(result gt 0.98)
	xy_pos = array_indices(result, min_pos)	
	xpos = xy_pos[0, *]
	ypos = xy_pos[1, *]
	set_line_color
	ypos = ypos[sort(xpos)]
	xpos = xpos[sort(xpos)]
	set_line_color
	
	for i=10, n_elements(xpos)-1, 20 do begin
		indices = where(xpos gt xpos[i]-50 and xpos lt xpos[i]+50 $
					and ypos gt ypos[i]-50 and ypos lt ypos[i]+50)
	
		if i eq 10 then xpos_new = mean(xpos[indices]) else xpos_new = [xpos_new,  mean(xpos[indices])]
		if i eq 10 then ypos_new = mean(ypos[indices]) else ypos_new = [ypos_new,  mean(ypos[indices])]
		;progress_percent, i, 10, (n_elements(xpos)-1)/20.
	endfor
	xpos = xpos_new
	ypos = ypos_new

	;indeces = findgen(n_elements(xpos)/10)*10
	;xpos = xpos[indeces]
	;ypos = ypos[indeces]
	;plots, xpos_new, ypos_new, color=10, psym=3

	xsize = (size(extrem_map))[1]
	ysize = (size(extrem_map))[2]
	index_range = dindgen(xsize)
	lon_range = findgen(xsize)*(180 + 180)/(xsize-1) - 180
	lon_points = transpose(interpol(lon_range, index_range, xpos))

	index_range = findgen(ysize)
	lat_range = (findgen(ysize)*(1.+1.)/(ysize-1) - 1.0) 
	lat_points = interpol(lat_range, index_range, ypos)

END		

;-----------------------------------------------------------------;
;					Flare position parser.
;-----------------------------------------------------------------;

pro flare_pos_string_parse, pos_string, $
	lat_pos = lat_pos, lon_pos = lon_pos, err=err

	err=0
	nors = strmid(pos_string, 0, 1)
	wore = strmid(pos_string, 3, 1)

	case nors of
		'N': lat_sign = 1.0
		'S': lat_sign = -1.0
		 else: err=1
	endcase

	case wore of
		'W': lon_sign = 1.0
		'E': lon_sign = -1.0
		 else: err=1
	endcase

	if err eq 0 then begin	
		lat_pos = float(strmid(pos_string, 1, 2))*lat_sign
		lon_pos = float(strmid(pos_string, 4, 2))*lon_sign
	endif else begin
		print, 'Flare location parsing error.'
	endelse

END

;-----------------------------------------------------------------;
;			 ********** Main procedure. ************
;-----------------------------------------------------------------;

pro mag_synoptic_map_plot, date, postscript=postscript, carrington=carrington, hs_csheet=hs_csheet

	; Example: mag_synoptic_map_plot, 2010-08-14'
	; 'Carrington' also plots a map in Carrington longitude. Otherwise it is in HEE (Stonyhurst) coord system.
	; Used by mag_syn_map_process.pro

	;------------Read the synoptic map-------------;
	date_str = date
	folder = '~/ELEVATE/data/'+date_str+'/'
	file = findfile(folder + '/SDO/HMI/hmi.Synoptic_Mr_720s*.fits')
	
	if file[0] eq '' then goto, no_file_err
	
	mreadfits, file, hdr, data
	tstop = anytim(STRJOIN(STRSPLIT(hdr.t_stop, '.', /EXTRACT), '-'), /yoh)	;Last time of the recording of the synoptic map
	date = time2file(date_str, /date)
	car_rot_str = string(hdr.car_rot, format='(I4)')
	event_info_file = folder + date + '_event_info_structure.sav'
	
	if file_test(event_info_file) eq 0 then goto, no_file_err
	
	restore, event_info_file, /verb
	if event_info.flare_start_t eq 'YYYY-MM-DDTHH:MMM:SS UT' then $
		event_info.flare_start_t = date_str+'T12:00:00 UT'

	flare_time = anytim((STRSPLIT(event_info.flare_start_t, ' ', /EXTRACT))[0], /utim)
	flare_date = time2file(flare_time, /date)
	degs = [-90, -60, -40, -20, 0, 20, 40, 60, 90]
	degs_sin = sin(degs*!dtor)
	degs_label = string(degs, format='(I3)') 
	
	
	if keyword_set(carrington) then begin
		if keyword_set(postscript) then begin
			setup_ps, folder + 'SDO/HMI/HMI_synoptic_map_'+flare_date+'_carr.eps'
		endif else begin			
			loadct, 0
			window, 2, xs=1250, ys=550
			!p.charsize = 1.5
		endelse
		pos = [0.12, 0.12, 0.9, 0.9]
			;----------------------------------------------------;
			;	  Plot the synoptic map in Carrington coords.
			;----------------------------------------------------;

			plot_image, data > (-200) < (200), $
					XTICKFORMAT="(A1)", $
					YTICKFORMAT="(A1)", $
					xticklen=0.001, $
					yticklen=0.001, $
					title = 'Carrington Rotation '+car_rot_str+' ('+date+')', $
					position = pos
					;title = hdr.telescop+' '+hdr.date+' UT'; ystyle=4;xticks=2, yticks=2, ytickname=['', '', ''], xtickname=['','', '']

			axis, xaxis = 0, xr = [0, 360], xticks=6, xtitle = 'Carrington Longitude (deg)', /xs
			axis, yaxis = 0, yr = [-1, 1], ytitle = 'Sine latitude', /ys, $
					yticklen=-0.01

			axis, yaxis = 1, yr = [-1, 1], $
					yticks=8, $
					ytickv = degs_sin, $
					ytickname = degs_label, $
					ytitle = 'Latitude (deg)', $
					/ys, $
					yticklen=-0.01

			plot, [-180, 180], [-1, 1], $
	   			/nodata, $
	   			/noerase, $
	   			position = pos, $
	   			/xs, $
	   			/ys, $
	   			xtickformat='(A1)', $
	   			ytickformat='(A1)', $
	   			yticklen=-0.0001		

			;------------Oplot field lines-------------;
			mag_oplot_open_lines, data, folder

		if keyword_set(postscript) then begin	
			device, /close
		endif
	endif	
;stop
	;----------------------------------------------------;
	;	  		Now convert to Stonyhurst coords.
	;----------------------------------------------------;
	one_day_rot = (TIM2CARR(flare_time))[0] - (TIM2CARR(tstop))[0]
	; The 16th at 17:30 is the last observation to produce the map. Therefore the active region rotated 
	; an extra day ahead of the flare time (15th) on the map. The PFSS is also produced from the map
	; that was finalised on the 16th. In order to get the map and PFSS on the day of the flare
	; it is necessary to rotate back the position of the active region at the time of the flare.

	merid_car_lon =  TIM2CARR(tstop) 			; Carrinton Longitude for the central meridian on CR XXXX.
	npixx = n_elements(data[*,0])
	npixy = n_elements(data[0,*])
	pixels = dindgen(npixx)
	car_lons = dindgen(npixx)*(360.0)/(npixx-1)
	stny_lons = car_lons - merid_car_lon[0] - one_day_rot
	ind0_snty = round(closest(stny_lons, 0.0))

	data_stny = [data[ind0_snty:npixx-1, *], data[0:ind0_snty-1, *]]

	; Convert to Stonyhurst Longitude, centered on 0.0
	stny_lons = dindgen(npixx)*(360.0)/(npixx-1)
	ind1_snty = round(closest(stny_lons, 180.0))
	data_stny = [data_stny[ind1_snty:npixx-1, *], data_stny[0:ind1_snty-1, *]]


	;----------------------------------------------------;
	;	  		Plot in Stonyhurst coords.
	;----------------------------------------------------;

	if keyword_set(postscript) then begin
		setup_ps, folder + 'SDO/HMI/HMI_synoptic_map_'+flare_date+'_hee.eps'
	endif else begin
		loadct, 0
		window, 1, xs=1250, ys=550
		!p.charsize = 1.5
	endelse	


		plot_image, data_stny > (-200) < (200), $
				XTICKFORMAT="(A1)", $
				YTICKFORMAT="(A1)", $
				xticklen=0.001, $
				yticklen=0.001, $
				title = 'Carrington Rotation '+car_rot_str+' ('+date+')', $
				position = [0.1, 0.1, 0.9, 0.9]


		axis, xaxis = 0, xr = [-180, 180], xticks=6, xtitle = 'HEE Longitude (deg)', /xs
		axis, yaxis = 0, yr = [-1, 1], ytitle = 'Sine latitude', /ys, $
				yticklen=-0.01


		axis, yaxis = 1, yr = [-1, 1], $
				yticks=8, $
				ytickv = degs_sin, $
				ytickname = degs_label, $
				ytitle = 'HEE Latitude (deg)', $
				/ys, $
				yticklen=-0.01

		plot, [-180, 180], [-1, 1], $
   			/nodata, $
   			/noerase, $
   			position = [0.1, 0.1, 0.9, 0.9], $
   			/xs, $
   			/ys, $
   			xtickformat='(A1)', $
   			ytickformat='(A1)', $
   			yticklen=-0.0001		


		open_field_file = findfile(folder + 'SDO/HMI/connected_field_*.sav')
		colors_file = findfile(folder + 'SDO/HMI/open_colour_*.sav')
		restore, open_field_file[0], /verb
		restore, colors_file[0], /verb

		colors = intarr(n_elements(open))
		colors[where(open eq 1)] = 4
		colors[where(open eq -1)] = 3

		lon_new = lon - 180.0 
		lon_new[where(lon_new gt 180.0)] = lon_new[where(lon_new gt 180.0)] - 360.0
		lon_new[where(lon_new lt -180.0)] = lon_new[where(lon_new lt -180.0)] + 180.0

		stny_lons = lon_new - merid_car_lon[0] - one_day_rot 
		sinlat = sin(lat*!dtor)							; Sine of the latitude.

		stny_lons[where(stny_lons lt -180.0)] = stny_lons[where(stny_lons lt -180.0)] + 360.0
		
		set_line_color	
		for i=0, 119 do begin	;n_elements(lon_new[0, *])-1 do begin
			plots, stny_lons[*,i], sinlat[*,i], color=colors[i], /data, psym=3
		endfor

		for i=0, n_elements(stny_lons[0, *])-1 do begin
			plots, stny_lons[0,i], sinlat[0,i], color=colors[i], /data, psym=3, symsize=1.5
		endfor	

		;----------------------------------------------------;
		;	  	    Plot heliospheric current sheet. 
		;           Not the most efficient way, but 
		;           couldn't find anything else.
		;			Calculation also done in pixel coords 
		;			and converted to long and sinlat
		;----------------------------------------------------;
		if keyword_set(hs_csheet) then begin
	   		open_field_file = findfile(folder + 'SDO/HMI/connected_field_*.sav')
			colors_file = findfile(folder + 'SDO/HMI/open_colour_*.sav')
			restore, open_field_file[0], /verb
			restore, colors_file[0], /verb

			colors = intarr(n_elements(open))
			colors[where(open eq 1)] = 4
			colors[where(open eq -1)] = 3

			sinlat = sin(lat*!dtor)									; Sine of the latitude.
			ypix = lat

			nBlines = (size(rad))[2]
			npoints = (size(data))[2]
			ypixels = dindgen(npoints)

			sinlat_points = (dindgen(npoints)*(1.0 - (-1.0))/(npoints-1) ) + (-1.0)

			for i=0, nBlines-1 do begin
				ypix_line = interpol(ypixels, sinlat_points, sinlat[*, i])
				ypix[*, i] = ypix_line
			endfor	

			lon[where(lon lt 0.0)] = (lon[where(lon lt 0.0)]) + 360.0
			lon[where(lon gt 360.0)] = (lon[where(lon gt 360.0)]) - 360.0 
			lon = lon - merid_car_lon[0] - one_day_rot
			lon[where(lon lt 0.0)] = (lon[where(lon lt 0.0)]) + 360.0 
			lon = lon*10.
			calc_helio_curr_sheet, data_stny, lon, ypix, rad, colors, $
					lon_points, lat_points		

			plot, [-180, 180], [-1, 1], $
	   			/nodata, $
	   			/noerase, $
	   			position = [0.1, 0.1, 0.9, 0.9], $
	   			/xs, $
	   			/ys, $
	   			xtickformat='(A1)', $
	   			ytickformat='(A1)', $
	   			yticklen=-0.0001

			plots, lon_points, lat_points, color=5, /data, psym=3, thick=3
		endif

		;----------------------------------------------------;
		;	  			  Plot coronal holes
		;----------------------------------------------------;

		restore, '~/ELEVATE/data/'+date_str+'/SDO/HMI/chole_field_'+date+'.sav', /verb
		xsize = (size(data_stny))[1]
		ysize = (size(data_stny))[2]
		openfield = congrid(openfield, xsize, ysize)
		
		openfield= [openfield[ind0_snty:npixx-1, *], openfield[0:ind0_snty-1, *]]
		;          Convert to Stonyhurst Longitude, centered on 180.0
		openfield = [openfield[ind1_snty:npixx-1, *], openfield[0:ind1_snty-1, *]]

		get_chole_pos, openfield, xsize, ysize, $ 		; input
				lon_points_pos, sinlat_points_pos, $	; output	
				/positive								; keywords		

		get_chole_pos, openfield, xsize, ysize, $ 		; input
				lon_points_neg, sinlat_points_neg, $	; output	
				/negative								; keywords			

   		indeces_pos = findgen( n_elements(lon_points_pos)/30. )*30.
   		indeces_neg = findgen( n_elements(lon_points_neg)/30. )*30.
   		
   		plots, lon_points_pos[indeces_pos], sinlat_points_pos[indeces_pos], psym=3, color=4	
   		plots, lon_points_neg[indeces_neg], sinlat_points_neg[indeces_neg], psym=3, color=3
   	
		;----------------------------------------------------;
		;	  		Plot position of L1 connection
		;----------------------------------------------------;

		radius = 1.5e11			; 1AU in meters
		ang_vel = 2.8e-6		; Angular velocity of the solar equator
		v_solwind = get_solar_wind_speed(anytim(flare_time, /cc, /trun))*1e3		; meters per second

		theta = radius*ang_vel/v_solwind
		theta = theta*!radeg
		pixx_theta = interpol(pixels, car_lons, theta + 180.0)

		lat = 0.0
		sinlat = sin(lat*!dtor)
		sinlats = ( dindgen(npixy)*(1.0 + 1.0)/(npixy-1.) ) - 1.0
		pixelsy = dindgen(npixy)
		pixy_lat = interpol(pixelsy, sinlats, lat)

		
		set_line_color
		;plotsym, 0
		plots, theta, lat, $
				 psym=4, $
				 color=5, $
				 thick=8, $
				 symsize=3

		;----------------------------------------------------;
		;	  			Plot Flare position
		;----------------------------------------------------;

		flare_pos_string_parse, event_info.flare_location, $
			lat_pos = lat, lon_pos = theta, err=err

		if err ne 1 then begin
			pixx_theta = interpol(pixels, car_lons, theta + 180.0)
			
			sinlat = sin(lat*!dtor)
			sinlats = ( dindgen(npixy)*(1.0 + 1.0)/(npixy-1.) ) - 1.0
			pixelsy = dindgen(npixy)
			pixy_lat = interpol(pixelsy, sinlats, sinlat)

			
			set_line_color
			;plotsym, 0
			plots, theta, sinlat, $
					 psym=2, $
					 color=10, $
					 thick=7, $
					 symsize=3	
		endif			 

	if keyword_set(postscript) then begin			 
		device, /close
		set_plot, 'x'
	endif

	cd, folder + 'SDO/HMI/
	spawn, 'convert -density 70 HMI_synoptic_map_'+flare_date+'_hee.eps -flatten HMI_synoptic_map_'+flare_date+'_hee.png
	spawn, 'cp HMI_synoptic_map_'+flare_date+'_hee.png ~/ELEVATE/website/maths_server_mirror/'+date_str+'/SDO/'
	
	no_file_err: print, 'Error: no HMI file found.'

END