pro oplot_nrh_on_three_color, tstart

	;				PLOT NRH
	;tstart = anytim(aia_hdr.date_obs, /utim) 
	  
	folder = '~/Data/2014_Apr_18/radio/nrh/clean_wresid/'
	cd, folder
	nrh_filenames = reverse(findfile('*.fts'))
							;[10,	9,	 8,	  7,   6,	5,	 4,	  3,	2]
							;[445, 432, 408, 327, 298, 270, 228, 173, 150]
	colors = reverse([2,3,4,5,6,7,8,9,10])
	;colors = [6, 7, 10]
	inds = [0,1,2]
	for j=0, n_elements(inds)-1 do begin
		;tstart =  anytim('2014-04-18T13:09:35', /utim); anytim(aia_hdr.date_obs, /utim) ;anytim('2014-04-18T12:35:11', /utim)
		t0 = anytim(tstart, /yoh, /trun, /time_only)
		nrh_file_index = inds[j]

		read_nrh, nrh_filenames[nrh_file_index], $	; 432 MHz
				nrh_hdr, $
				nrh_data, $
				hbeg=t0			
							
		index2map, nrh_hdr, nrh_data, $
				 nrh_map  

		nrh_data = smooth(nrh_data, 5)
		nrh_data = alog10(nrh_data)
		nrh_map.data = nrh_data	

		max_val = max( (nrh_data) ,/nan) 							   
		nlevels=5.0   
		top_percent = 0.99
		levels = (dindgen(nlevels)*(max_val - max_val*top_percent)/(nlevels-1.0)) $
					+ max_val*top_percent

		;levels = (dindgen(nlevels)*(9.0 - 8.5)/(nlevels-1.0)) $
	;				+ 8.5		

				
		set_line_color
		plot_map, nrh_map, $
			/overlay, $
			/cont, $
			/noerase, $
			levels=levels, $
			;/noxticks, $
			;/noyticks, $
			/noaxes, $
			thick=16, $
			color=0

		plot_helio, nrh_hdr.date_obs, $
			/over, $
			gstyle=0, $
			gthick=3.0, $	
			gcolor=255, $
			grid_spacing=15.0


		set_line_color
		plot_map, nrh_map, $
			/overlay, $
			/cont, $
			levels=levels, $
			/noxticks, $
			/noyticks, $
			/noaxes, $
			thick=14, $
			color=colors[j]					 


		freq_tag = string(nrh_hdr.freq, format='(I03)')
		print, 'Brightness temperature max at '+freq_tag+'  MHz: '+string(levels)
		print, 'Frequency: '+freq_tag+' MHz '+'. Color: '+string(j+2)
		print, '--------'

		xpos_nrh_lab = 0.075
		ypos_nrh_lab = 0.75

		;xyouts, xpos_nrh_lab, 0.45 - (j)/40.0, 'NRH '+freq_tag+' MHz', $;+' MHz (1e'+string(max_val, format='(f3.1)')+' K)', $
		;		color=0, $
	;			/normal	

	;	xyouts, xpos_nrh_lab, 0.45 - (j)/40.0, 'NRH '+freq_tag+' MHz', $;+' MHz (1e'+string(max_val, format='(f3.1)')+' K)', $
	;			color=j+2, $
	;			/normal		


		;xyouts, xpos_nrh_lab, ypos_nrh_lab, 'NRH '+anytim(nrh_hdr.date_obs, /cc, /trun)+' UT', $
	;					/normal, $
	;					color=1

		;xyouts, xpos_nrh_lab, ypos_nrh_lab, 'NRH '+anytim(nrh_hdr.date_obs, /cc, /trun)+' UT', $
		;		/normal, $
		;		color=2				

	endfor						 


 END