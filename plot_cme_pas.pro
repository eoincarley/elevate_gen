pro setup_ps, name
  
	set_plot,'ps'
	!p.font=0
	!p.charsize=1.5
	device, filename = name, $
	      /color, $
	      /helvetica, $
	      /inches, $
	      bits_per_pixel = 16, $
	      xsize=10, $
	      ysize=10, $
	      /encapsulate, $
	      yoffset=5

end

pro plot_cme_pas

	;--------------------------------;
	;		 Read the data
	;--------------------------------;
	restore,'~/Data/2011_sep_22/density_mag/cartesian_density_map_22_sep.sav', /verb
	files_c2 = findfile('~/Data/2011_sep_22/density_mag/*.fts')
	c2data = lasco_readfits(files_c2[0], hdr)
	rsun_arcsec = get_solar_radius(hdr)
	xcen = 300.0
	ycen = 300.0
  
	;--------------------------------;
	;     Plot the in postscript
	;--------------------------------;

	setup_ps, '~/ELEVATE/data/elevate_cactus_cmes.eps'
    FOV = [120.0, 120.0]
    car_den_all.data = 255.0
    tit = '2011-Sep-22 00:00:00 UT';strsplit(anytim(hdr.date_obs, /cc, /trun), 'T', /extract)+' UT'
    loadct, 0
    plot_map, car_den_all, $
        fov = FOV, $
        title = tit, $
        xticklen = -0.02, $
        yticklen = -0.02, $
        dmin = 4, $
        dmax = 9, $
        /noaxes, $
        /notitle

   
    ; Start plotting CME data 
    restore, '~/ELEVATE/data/elevate_cactus_cmes.sav'
    cme_times = cme_list[0, *]
    cme_vels = cme_list[1,*]
    cme_pa = cme_list[2, *]
    cme_wid = cme_list[3, *]
    pinten = cme_list[4, *]

    npoints = 100
    vels = (dindgen(npoints)*(max(cme_vels) - min(cme_vels))/(npoints-1) ) + min(cme_vels)
    wids = (dindgen(npoints)*(max(cme_wid) - min(cme_wid))/(npoints-1) ) + min(cme_wid)
    thick_range = (findgen(npoints)*(40. - 3.)/(npoints-1)) + 3.0
	
    pinten[where(pinten eq 0.0)] = mean(pinten)
    pi_to_col = alog10(pinten*1e5)
	pirange = (findgen(npoints)*(max(pi_to_col) - min(pi_to_col))/(npoints-1.)) + min(pi_to_col)
	cols = dindgen(npoints)*(255.0)/(npoints-1)
	col = interpol(cols, pirange, pi_to_col)
	
   	loadct, 74

   	sort_vels = reverse(sort(cme_vels))
    for k=0, n_elements(cme_vels)-1 do begin
    	;if cme_times[k] gt anytim(file2time('20100814_000000'), /utim) then begin
	    	i  = sort_vels[k]	;plot largest velocity first
	    	time = cme_times[i]
	    	velocity = cme_vels[i]	
	    	width = cme_wid[i]
	    	angle = cme_pa[i] + 90.0
	    	if width eq 360.0 then angle = 90.0
	    
			rhos = ( dindgen(npoints)*(3500.0 - 960.0)/(npoints-1) ) + 960.0
			rhos  = rhos/CAR_DEN_ALL.dx   ;pixel units
			r_len = interpol(rhos, vels, velocity)
			rhos = rhos[0: closest(rhos, r_len)]

					;Put in standard position angle

			xline = (COS(angle*!dtor) * rhos + xcen)*1.0  		;working in pixel units 		;hdr.cdelt1
			yline = (SIN(angle*!dtor) * rhos + ycen)*1.0  		;working in pixel units 		;hdr.cdelt1

			xarcsec = (xline - 300.0)*CAR_DEN_ALL.dx
			yarcsec = (yline - 300.0)*CAR_DEN_ALL.dy
			rsun_asec = get_solar_radius(hdr)
			xrsun = xarcsec/rsun_asec
			yrsun = yarcsec/rsun_asec
			
			thicks = interpol(thick_range, wids, width)
			plots, xarcsec, yarcsec, thick = thicks, /data, color=col[i]
		;endif

	endfor	

	set_line_color
    tvcircle, 960.0, 0.0, 0.0, color=1, /data, /fill
    tvcircle, 960.0, 0.0, 0.0, color=0, /data


    rhos = ( dindgen(npoints)*(3500.0 - 960.0)/(npoints-1) ) + 960.0
    vel1 = interpol(rhos, vels, 500.0)
    vel2 = interpol(rhos, vels, 1000.0)
    vel3 = interpol(rhos, vels, 1500.0)
    vel4 = interpol(rhos, vels, 2000.0)
    tvcircle, vel1, 0.0, 0.0, color=0, /data, linestyle=1
    tvcircle, vel2, 0.0, 0.0, color=0, /data, linestyle=1
    tvcircle, vel3, 0.0, 0.0, color=0, /data, linestyle=1
    tvcircle, vel4, 0.0, 0.0, color=0, /data, linestyle=1  

    plot_helio, hdr.date_obs, /over, gstyle=0, gthick=1.0, gcolor=0, grid_spacing=15.0


    xyouts, 0.0, vel1, '500', /data, alignment=0.5, charsize=1.0
    xyouts, 0.0, vel2, '1000', /data, alignment=0.5, charsize=1.0
	xyouts, 0.0, vel3, '1500', /data, alignment=0.5, charsize=1.0
	xyouts, 0.0, vel4, '2000 km/s', /data, alignment=0.5, charsize=1.0
	xyouts, 0.0, vel4+190, 'CME speed', /data, alignment=0.5, charsize=1.0

	title_pos = interpol(rhos, vels, 2500.0)
	xyouts, 0.0, title_pos, 'CMEs associated with SOHO/ERNE SEP Server events', /data, alignment=0.5, charsize=1.5
	xyouts, 0.0, title_pos-260, 'Oct 1997 - Dec 2014', /data, alignment=0.5, charsize=1.5



    loadct, 74
    unit  = ' (cm!U-2!N, s!U-1!N, sr!U-1!N, MeV!U-1!N)' 
    pi_to_col = (10^pi_to_col)/1e5

    cgColorbar, Range=[min(pi_to_col), max(pi_to_col)], $
        /bottom, $
        ;position = [0.90, 0.15, 0.91, 0.85], $
        position = [0.14, 0.07, 0.85, 0.08], $
        ticklen = -0.35, $
        title = 'Particle intensity '+unit, $
        /xlog

    
	max_wid = string( max(cme_wid), format='(I4)' )
	min_wid = string( min(cme_wid), format='(I4)' )
	mean_wid = string( mean(cme_wid), format='(I4)' )
	unit  = ' Degrees'    
	set_line_color
    legend, [min_wid+unit , max_wid+unit ], $
	    	color=[0,0], $
	    	linestyle=[0,0], $
	    	box=0, $
	    	thick=[min(thick_range), max(thick_range)], $
	    	/bottom, $
	    	charsize=1.0, $
	    	pos = [0.13, 0.09], $
	    	/normal
	xyouts, 0.145, 0.135, 'CME width:', charsize=1.0, /normal    	

   
    device, /close
    set_plot, 'x'

stop
END