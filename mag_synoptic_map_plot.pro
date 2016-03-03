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



pro mag_synoptic_map_plot, date, postscript=postscript, carrington=carrington

	; date='2010-08-10'
	; Used by mag_syn_map_process.pro

	;------------Read the synoptic map-------------;
	date_str = date
	folder = '~/ELEVATE/data/'+date_str+'/'
	file = findfile(folder + '/SDO/HMI/hmi.Synoptic_Mr_720s*.fits')
	mreadfits, file, hdr, data
	tstop = anytim(STRJOIN(STRSPLIT(hdr.t_stop, '.', /EXTRACT), '-'), /yoh)	;Last time of the recording of the synoptic map
	date = time2file(date_str, /date)
	car_rot_str = string(hdr.car_rot, format='(I4)')
	restore, folder + date + '_event_info_structure.sav', /verb
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

			;------------Oplot field lines-------------;
			mag_oplot_open_lines, data, folder

		if keyword_set(postscript) then begin	
			device, /close
		endif
	endif	

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

	; Convert to Stonyhurst Longitude, centered on 180.0
	stny_lons = dindgen(npixx)*(360.0)/(npixx-1)
	ind1_snty = round(closest(stny_lons, 180.0))
	data_stny = [data_stny[ind1_snty:npixx-1, *], data_stny[0:ind1_snty-1, *]]


	;----------------------------------------------------;
	;	  		Plot in Stonyhurst coords.
	;----------------------------------------------------;

	if keyword_set(postscript) then begin
		setup_ps, folder + 'SDO/HMI/HMI_synoptic_map_'+flare_date+'_heeq.eps'
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


		open_field_file = findfile(folder + 'SDO/HMI/connected_field_*.sav')
		colors_file = findfile(folder + 'SDO/HMI/open_colour_*.sav')
		restore, open_field_file[0], /verb
		restore, colors_file[0], /verb


		colors = intarr(n_elements(open))
		colors[where(open eq 1)] = 4
		colors[where(open eq -1)] = 3

		lon = (lon - one_day_rot)*10.0					; For use on synoptic map.
		sinlat = sin(lat*!dtor)							; Sine of the latitude.
		ypix = lat

		nBlines = (size(rad))[2]
		npoints = (size(data))[2]
		ypixels = dindgen(npoints)

		sinlat_points = (dindgen(npoints)*(1.0 - (-1.0))/(npoints-1) ) + (-1.0)

		for i=0, nBlines-1 do begin
			ypix_line = interpol(ypixels, sinlat_points, sinlat[*, i])
			ypix[*, i] = ypix_line
		endfor
		
		lon[where(lon lt 0.0)] = (lon[where(lon lt 0.0)]) + 3600.0

		set_line_color

		for i=0, 120 do begin ;n_elements(lon[0, *])-1 do begin
			plots, lon[*,i], ypix[*,i], color=colors[i], /data, psym=3
		endfor	
		for i=120, n_elements(lon[0, *])-1 do begin
			plots, lon[0,i], ypix[0,i], color=colors[i], /data, psym=1, symsize=0.5
			;wait, 0.01
		endfor
		;contour, data_stny, transpose(lon[0,*]), transpose(ypix[0,*]), /overplot, /follow, position = [0.1, 0.1, 0.9, 0.9]
	
		restore, '~/ELEVATE/data/'+date_str+'/SDO/HMI/chole_field_'+date+'.sav', /verb
		xsize = (size(data_stny))[1]
		ysize = (size(data_stny))[2]
		openfield = congrid(openfield, xsize, ysize)
		
		openfield= [openfield[ind0_snty:npixx-1, *], openfield[0:ind0_snty-1, *]]
		; Convert to Stonyhurst Longitude, centered on 180.0
		openfield = [openfield[ind1_snty:npixx-1, *], openfield[0:ind1_snty-1, *]]


		pos = where(openfield gt 0.03)
   		pos = array_indices(openfield, pos)
   		index_x = pos[0, *]
   		index_range = dindgen(xsize)
   		lon_range = findgen(xsize)*(180 + 180)/(xsize-1) - 180
   		lonpoints = interpol(lon_range, index_range, index_x)
 
   		index_y = pos[1, *]
   		index_range = findgen(ysize)
   		lat_range = (findgen(ysize)*(90.+90.)/(ysize-1) - 90.0) 
   		latpoints = interpol(lat_range, index_range, index_y)
   		sinlat_points = sin( latpoints*!dtor )
 
   		plot, [-180, 180], [-1, 1], /nodata, /noerase, position = [0.1, 0.1, 0.9, 0.9], /xs, /ys, xtickformat='(A1)', ytickformat='(A1)'
   		plots, lonpoints, sinlat_points, psym=3
   		STOP
		contour, filter_image(openfield, fwhm=20), /overplot, /follow, levels=[-1e-4, 1e-4]

		;contour, openfield, /overplot, /follow, levels=[0.0], color=5

     	STOP
		;----------------------------------------------------;
		;	  		Plot position of L1 connection
		;----------------------------------------------------;

		radius = 1.5e11			; 1AU in meters
		ang_vel = 2.8e-6		; Angular velocity of the solar equator
		v_solwind = 3.8e5		; meters per second

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
		plots, pixx_theta, pixy_lat, $
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
			plots, pixx_theta, pixy_lat, $
					 psym=2, $
					 color=10, $
					 thick=7, $
					 symsize=3	
		endif			 

	if keyword_set(postscript) then begin			 
		device, /close
		set_plot, 'x'
	endif

	;cd, folder + 'SDO/HMI/
	;spawn, 'convert -density 70 HMI_synoptic_map_'+flare_date+'_heeq.eps -flatten HMI_synoptic_map_'+flare_date+'_heeq.png
		;spawn, 'cp HMI_synoptic_map_'+flare_date+'_heeq.png ~/ELEVATE/website/maths_server_mirror/'+date_str+'/SDO/'
	

END