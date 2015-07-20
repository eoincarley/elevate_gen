pro setup_ps, name
  
  set_plot,'ps'
  !p.font=0
  !p.charsize=1.0
  !p.thick=3
  device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=10, $
          ysize=8, $
          /encapsulate, $
          yoffset=5

end

pro plot_ace_soho_elevate, date_folder

	!p.charsize = 1.5
	;window, 0, xs=1000, ys=800
	ace_folder = '/Users/eoincarley/ELEVATE/data/' +date_folder+ '/ACE/'
	;soho_folder = '~/Data/ELEVATE/soho_test/ERNE/'
	soho_folder = '/Users/eoincarley/ELEVATE/data/' +date_folder+ '/SOHO/ERNE/'

	erne_channels = ['1.68', '1.97', '2.41', '2.98', '3.70', '4.71', $
					 '5.72', '7.15', '9.09', '11.4', '15.4', '18.9', $ 
					 '23.3', '29.1', '36.4', '45.6', '57.4', '72.0', $
					 '90.5', '108']
	
	; SOHO ERNE DATA

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
	print, 'Writing file : ' +soho_folder + 'soho_erne_' + yyyymmdd + '.eps'	
	setup_ps, soho_folder + 'soho_erne_' + yyyymmdd + '.eps'		

		good = where(erne_data[6, *] ge 0.0)
		utplot, erne_date[good], smooth(erne_data[6, good], 10), $
				/xs, $;, psym=1
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
				position = [0.1, 0.1, 0.88, 0.95], $
				/normal


		colors = 0
		loadct, 39
		for i=1, 19 do begin
			good = where(erne_data[6+i*2, *] ge 0.0)
			outplot, erne_date[good], smooth(erne_data[6+i*2, good], 10), $
					color = i*13.0

			colors = [colors, fix(i*13.0)]		
		endfor	

		cgDCBar, colors, labels = erne_channels, $
				position=[0.9, 0.95, 0.91, 0.1], $
				charsize=1.0, $
				/vertical, $
				spacing=0.16, $
				rotate=-45, $
				title='MeV / nucleon', $
				/right

	
	device, /close
	set_plot, 'x'	
	
	;cd,'/Users/eoincarley/ELEVATE/data/' +date_folder+ '/SOHO/'
	;spawn, 'mv ENRE ERNE'
	spawn, 'cp '+soho_folder + 'soho_erne_' + yyyymmdd + '.eps ~/Dropbox/'
	



;-----------------------------;
;	  Reading ACE EPAM
;
	; ACE EPAM data  Time P1 P2 P3 P4 P5 P6 P7 P8 E1p E2p E3p E4p FP5p FP6p FP7p 
	ace_file = file_search(ace_folder + 'ace_ep_*.sav')
	restore, ace_file, /verb
	epam_data = date_ep
	index = where(epam_data[0, *] gt erne_date[0] and epam_data[0, *] lt erne_date[n_elements(erne_date)-1])

	ace_e_channels = ['53', '79', '133']
	ace_p_channels = ['56', '88', '150', '250', '424', '789', '1419', '3020']
	ace_fp_channels = ['671', '974', '2424']
	ace_ps = [ace_p_channels, ace_fp_channels]
	p_index = sort(float(ace_ps))
	p_chans = [1,2,3,4,5,6,7,8,13,14,15]
	p_chans_order = p_chans[p_index]

	epam_data = epam_data[*, index]
	epam_protons = epam_data[[p_chans_order], *]
	epam_electrons = epam_data[9:12, *]

	p_max = max(epam_protons)
	p_min = min(epam_protons)
	
	xtitle = strjoin(strsplit(anytim(epam_data[0, 0], /cc, /trun), 'T', /extract, /regex), ' ') + ' UT'

	print, 'Writing file : ' +ace_folder + 'ace_epam_' + yyyymmdd + '.eps'	
	setup_ps, ace_folder + 'ace_epam_' + yyyymmdd + '.eps'		

	;----------------------PROTONS----------------------;
	min_pflux = min(epam_protons[where(epam_protons gt 0.0)])
	utplot, epam_data[0, *], epam_protons[0, *], $
			/xs, $
			yr = [min_pflux, max(epam_protons)], $
			/ylog, $
			xtitle = xtitle, $
			ytitle = 'Particle Intensity (cm!U-2!N sr!U-1!N s!U-1!N MeV!U-1!N)', $
			title = 'ACE EPAM Protons', $
			xticklen = 1.0, $
			xgridstyle = 1.0, $
			yticklen = 1.0, $
			ygridstyle = 1.0, $
			position = [0.11, 0.56, 0.88, 0.96], $
			/normal, $
			/noerase

	proton_colors = 0		
	for i=1, 10 do begin
		outplot, epam_data[0, *], epam_protons[i, *], $
				color = i*25.0

		proton_colors = [proton_colors, fix(i*25.0)]		
	endfor	

	cgDCBar, proton_colors, $
			labels =  ace_ps[p_index], $
			position=[0.9, 0.95, 0.91, 0.55], $
			charsize=1.0, $
			/vertical, $
			spacing=0.16, $
			rotate=-45, $
			title='keV', $
			/right

	;----------------------ELECTRONS----------------------;
	min_eflux = min(epam_electrons[where(epam_electrons gt 0.0)])
	utplot, epam_data[0, *], epam_electrons[0, *], $
			/xs, $
			yr = [min_eflux, max(epam_electrons)], $
			/ylog, $
			xtitle = xtitle, $
			ytitle = 'Particle Intensity (cm!U-2!N sr!U-1!N s!U-1!N MeV!U-1!N)', $
			title = 'ACE EPAM Electrons', $
			xticklen = 1.0, $
			xgridstyle = 1.0, $
			yticklen = 1.0, $
			ygridstyle = 1.0, $
			position = [0.11, 0.06, 0.88, 0.46], $
			/normal, $
			/noerase

	electron_colors = 0		
	for i=1, 2  do begin
		outplot, epam_data[0, *], epam_electrons[i, *], $
				color = i*110.0
		electron_colors = [electron_colors, fix(i*110)]		
	endfor		

	cgDCBar, electron_colors, $
			labels = ace_e_channels, $
			position=[0.9, 0.45, 0.91, 0.05], $
			charsize=1.0, $
			/vertical, $
			spacing=0.16, $
			rotate=-45, $
			title='keV', $
			/right

	device, /close
	set_plot, 'x'

	spawn, 'cp ' +ace_folder + 'ace_epam_' + yyyymmdd + '.eps ~/Dropbox/'

END
