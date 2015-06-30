pro setup_ps, name
  
  set_plot,'ps'
  !p.font=0
  !p.charsize=1.5
  device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=10, $
          ysize=10, $
          /encapsulate, $
          yoffset=5

end

pro plot_flare_and_pintensity

	;Procedure to plot the positions on a heliographic grid of the flares associated with the SEP events,
	;taking into account SEP intensity with colour and flare class with symbol.

	;---------------------------;
	;  Plot heliographic grid
	;
	loadct, 0
	reverse_ct
	window, 0, xs=800, ys=800

	restore, 'assoc_flare_data.sav', /verb
	flare_time = output_flare_data[0, *]
	flare_class = output_flare_data[1, *]
	flare_pos = output_flare_data[2, *]
	good_index = where(strmid(flare_pos, 0, 1) eq 'N' or strmid(flare_pos, 0, 1) eq 'S')
	flare_pos = flare_pos[good_index] 
	flare_class = flare_class[good_index]
	flare_time = flare_time[good_index]
	flare_lat = fltarr(n_elements(flare_pos))
	flare_lon = fltarr(n_elements(flare_pos))
	latlon = fltarr(2, n_elements(flare_lat))
	symcol = fltarr(n_elements(flare_pos))

	readcol, 'soho_onset.txt', obs_start, p_intensity, format='A, A'
	obs_start = (reverse(obs_start))[good_index]
	p_intensity = (reverse(p_intensity))[good_index]
	for i=0, n_elements(p_intensity)-1 do begin

		p_intensity[i] = strsplit(p_intensity[i], escape='>', /extract)
		sat_index = where(p_intensity eq 'saturated')
		p_intensity[sat_index] = '0.0'

	endfor

	p_intensity =float(p_intensity)
	size_range = (findgen(100)*(3. - 1.)/9.9) + 1.0

	plog = alog10(100.0*p_intensity)
	irange = (findgen(100)*(max(plog) - min(plog))/99) + min(plog)
	sizes = interpol(size_range, irange, plog)

	for i=0, n_elements(flare_pos)-1 do begin

		flare_lat[i] = float(strmid(flare_pos[i], 1, 2))
		if strmid(flare_pos[i], 0, 1) eq 'S' then flare_lat[i] = -1.0*flare_lat[i]

		flare_lon[i] = float(strmid(flare_pos[i], 4, 2))
		if strmid(flare_pos[i], 3, 1) eq 'E' then flare_lon[i] = -1.0*flare_lon[i]

		goes_class = strmid(flare_class[i], 0, 1)

		CASE goes_class OF
		   'B': symcol[i] = 9
		   'C': symcol[i] = 4
		   'M': symcol[i] = 5
		   'X': symcol[i] = 3
		ELSE: symcol[i] = 1

		ENDCASE

	end	

	latlon[0, *] = flare_lat
	latlon[1, *] = flare_lon

	setup_ps, 'assoc_flare_plot.eps'
		set_line_color
		!p.background=1
		draw_grid_eoin_edit, latlon=latlon, symsize = plog*3.5, symcolor = symcol, color=0, thick=2.0

		;legend, ['B', 'C', 'M', 'X'], psym=[4,4,4,4], color=[9,4,5,3], box=0, charsize=3, thick=3, charthick=2, /bottom, /right

		p_intensity = p_intensity[where(p_intensity) gt 0.0]
		max_int = string( max(p_intensity), format='(e9.2)' )
		min_int = string( min(p_intensity), format='(e9.2)' )
		mean_int = string( mean(p_intensity), format='(e9.2)' )
		unit  = ' (cm!U-2!N, s!U-1!N, sr!U-1!N, MeV!U-1!N)'
		legend, [min_int+unit , max_int+unit ], psym=[4, 4], color=[0,0], symsize=[1,3], box=0, charsize=1.5, thick=3, charthick=1.5, /bottom
		
		xyouts, 0.15, 0.08, 'B', color=9, /normal, charsize=2.0, charthick=2
		xyouts, 0.11, 0.08, 'C', color=4, /normal, charsize=2.0, charthick=2
		xyouts, 0.07, 0.08, 'M', color=5, /normal, charsize=2.0, charthick=2
		xyouts, 0.03, 0.08, 'X', color=3, /normal, charsize=2.0, charthick=2
	device, /close
	set_plot, 'x'



END