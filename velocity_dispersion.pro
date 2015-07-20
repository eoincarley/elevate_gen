pro velocity_dispersion, date_folder

	!p.charsize = 1.5
	ace_folder = '/Users/eoincarley/ELEVATE/data/' +date_folder+ '/ACE/'
	soho_folder = '/Users/eoincarley/ELEVATE/data/' +date_folder+ '/SOHO/ERNE/'

	erne_channels = ['1.68', '1.97', '2.41', '2.98', '3.70', '4.71', $
					 '5.72', '7.15', '9.09', '11.4', '15.4', '18.9', $ 
					 '23.3', '29.1', '36.4', '45.6', '57.4', '72.0', $
					 '90.5', '108']
	
	;----------SOHO ERNE DATA------------;

	erne_data = READ_ASCII(soho_folder + 'soho_erne*.txt', DATA_START=38)
	erne_data = erne_data.field01
	erne_data = erne_data[*, 0:n_elements(erne_data[0, *])-3]

	erne_date = dblarr(n_elements(erne_data[0, *]))
	
	for i=0, n_elements(erne_data[0, *])-1 do begin
		
		erne_date_ex = [fix(erne_data[3, i]), $		;hh
				   fix(erne_data[4, i]), $			;min
				   fix(erne_data[5, i]), $     		;sec
				   0, $ 							;msec
				   fix(erne_data[2, i]), $			;day
				   fix(erne_data[1, i]), $			;month
				   fix(erne_data[0, i]) ] 			;year
		erne_date[i] = anytim(erne_date_ex, /utim)		   
				   
	endfor	

	yyyymmdd = time2file(erne_date[0, 0])
	xtitle = strjoin(strsplit(anytim(erne_date[0,0], /cc, /trun), 'T', /extract, /regex), ' ') + ' UT'
	
	chan_name = 0
	for channel=6, 44, 2 do begin
		window, 0, xs=1400, ys=800
		good = where(erne_data[channel, *] gt 0.0)
		ints = smooth(erne_data[channel, good], 5)		; Smoothness is an important parameter
		date = erne_date[good]
		nels = n_elements(date)

		utplot, date, ints, $
				/xs, $
				/ys, $
				yr = [1e-4, 1e4], $
				/ylog, $
				xtitle = xtitle, $
				ytitle = 'Intensity (cm!U-2!N sr!U-1!N s!U-1!N MeV!U-1!N)', $
				title = 'SOHO ERNE PROTONS', $
				xticklen = 1.0, $
				xgridstyle = 1.0, $
				yticklen = 1.0, $
				ygridstyle = 1.0, $
				position = [0.4, 0.1, 0.88, 0.95], $
				/normal
	
		plot_sep = "utplot, date, ints, /noerase, /xs, /ys, yr = [1e-4, 1e4], /ylog, xtitle = xtitle, ytitle = 'Intensity (cm!U-2!N sr!U-1!N s!U-1!N MeV!U-1!N)', title = 'SOHO ERNE PROTONS', xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, position = [0.4, 0.1, 0.88, 0.95], /normal"


		xyouts, date[nels-1] +60.0*2.0, ints[nels-1], erne_channels[chan_name] + ' MeV', /data
		chan_name = chan_name + 1.0

		; Define a ten minute window

		set_line_color
		minutes = 240.0
		for i=0, n_elements(ints)-5 do begin
			
			junk = execute(plot_sep)
			tcenter = date[i]
			plots, tcenter, ints[i], /data, psym=1, symsize=3, color=3

			t0 = tcenter - minutes*60.0
			t1 = tcenter + minutes*60.0

			t0_index = closest(date, t0)
			t1_index = closest(date, t1)  <  (n_elements(ints)-5)

			ints_sub = ints[t0_index:t1_index]
			time_sub = date[t0_index:t1_index]
			plots, time_sub, ints_sub, /data, color=5
				;plots, erne_date[t1_index+1], ints[t1_index+1], /data, psym=4, symsize=3, color=4

			ints_mean = mean( ints_sub )
			ints_sdev = stdev( ints_sub ) > 0.05*ints_mean 
				;if i mod 10 eq 0 then print, ints_sdev/ints_mean

			dummy_img = dist(450, 800)
			dummy_img[*] = 0.0
			tv, dummy_img	

			hist = HISTOGRAM( ints_sub, binsize = 0.15*ints_mean ) 
			bins = (  FINDGEN( N_ELEMENTS(hist) )*(MAX(ints_sub) - MIN(ints_sub))/(N_ELEMENTS(hist))  ) + MIN( ints_sub ) 
			PLOT, bins, hist, $
				;xr = [0, 5], $
				YRANGE = [MIN(hist)-1, MAX(hist)+1], $
				PSYM = 10, $ 
	   			XTITLE = 'Particle Intensity', $
	   			YTITLE = 'Density per Bin', $
	   			pos = [0.05, 0.55, 0.3, 0.95], $
	   			/normal, $
	   			/noerase

			threshold = ints_mean + 4.0*ints_sdev	  ; CHOOSE THE THRESHOLD HERE (standard deviations)
			inst_next = ints[t1_index+1]

			if inst_next gt threshold then begin
				plots, date[t1_index+1], ints[t1_index+1], /data, psym=4, symsize=3, color=4
				print, 'Onset time: ' + anytim(date[t1_index], /cc)

				if channel eq 6 then begin
					onset_times = date[t1_index] 
					erne_energy = float(erne_channels[channel])
				endif

				time_diff = abs(onset_times[n_elements(onset_times)-1] - date[t1_index])
				if time_diff gt 0.0 and time_diff lt 60.0*60.0 then begin
					onset_times = [onset_times, date[t1_index]]
					erne_energy = [erne_energy, float(erne_channels[chan_name])]
				endif	

				BREAK
			endif	

		endfor
		wait, 4.0
	endfor	

	date_string = time2file(date[0], /date_only)
	day_start = anytim(file2time(date_string+'_000000'), /utim)
	day_fraction = (onset_times - day_start)/(24.0*60.*60.0)

	keV = erne_energy
	kin_e = keV*1.602e-19*1e3	 ;J
	p_mass = 1.67e-27  			 ;kg
	c = 2.99792458e8		 	 ;m/s
	rest_E = p_mass*(c^2.0)  	 ;J
	c_fraction = sqrt(1.0 - (rest_E/(kin_e + rest_E))^2.0)

	plot, 1.0/[c_fraction], [day_fraction], $
		xr = [50, 450], $
		/ys, $
		psym = 1, $
		symsize = 2.0, $
		pos = [0.05, 0.07, 0.3, 0.47], $
		xtitle = 'Inverse velocity (Beta!U-1!N)', $
		ytitle = 'Day fraction', $
		/noerase, $
		/normal

	result = linfit(1.0/[c_fraction], [day_fraction], yfit = yfit)	
	oplot, 1.0/[c_fraction], yfit

	t_release = result[0]*(24.0*60.*60.0) + day_start
	t_release = anytim(t_release, /cc)
	box_message, str2arr('Estimated proton release time: ,'+t_release)

	;colors = 0
	;loadct, 39
	;for i=1, 19 do begin
	;	good = where(erne_data[6+i*2, *] ge 0.0)
	;	outplot, erne_date[good], smooth(erne_data[6+i*2, good], 10), $
	;			color = i*13.0

	;	colors = [colors, fix(i*13.0)]		
	;endfor	

	stop
END