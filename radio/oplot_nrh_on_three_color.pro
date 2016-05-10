pro oplot_nrh_on_three_color, tstart, freq_tags=freq_tags

	;				PLOT NRH
	;tstart = anytim(aia_hdr.date_obs, /utim) 
	;NOTE: doesn't necessarily have to be an AIA three colour that the contours are overplotted onto.
	;	   It simly plots onto a map.
	  
	folder = '~/Data/2014_sep_01/radio/nrh/clean_wresid/'
	cd, folder
	nrh_filenames = reverse(findfile('*.fts'))
							;[10,	9,	 8,	  7,   6,	5,	 4,	  3,	2]
							;[445, 432, 408, 327, 298, 270, 228, 173, 150]
	
	colors = reverse(indgen(9)+2.)
					;colors = [6, 7, 10]
	inds = indgen(9)
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

		freq_tag = string(nrh_hdr.freq, format='(I3)')		 
		nrh_data = smooth(nrh_data, 5)
		nrh_data = alog10(nrh_data)
		nrh_map.data = nrh_data	
		data_roi = nrh_data[0:40, 0:127] 	; For determinging source max for 2014-04-18 event

		max_val = max( (nrh_data) ,/nan) 							   
		nlevels=5.0   
		top_percent = 0.95	; 0.7 if linear, 0.99 if log
		levels = (dindgen(nlevels)*(max_val - max_val*top_percent)/(nlevels-1.0)) $
					+ max_val*top_percent  > 3.5		
		

		set_line_color
		plot_map, nrh_map, $
			/overlay, $
			/cont, $
			/noerase, $
			levels=levels, $
			;/noxticks, $
			;/noyticks, $
			/noaxes, $
			thick=5, $
			color=0

		if j eq 0 then plot_helio, nrh_hdr.date_obs, $
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
			thick=3, $
			color=colors[j]					 


		print, 'Brightness temperature max at '+freq_tag+'  MHz: '+string(levels)
		print, 'Frequency: '+freq_tag+' MHz '+'. Color: '+string(j+2)
		print, '--------'

		xpos_nrh_lab = 0.15
		ypos_nrh_lab = 0.75

		if keyword_set(freq_tags) then begin
			if j eq 0 then begin
				xyouts, xpos_nrh_lab+0.0015, ypos_nrh_lab - (j)/40.0, 'NRH '+freq_tag+' MHz '+anytim(nrh_hdr.date_obs, /cc, /trun)+' UT', color=0, /normal
				xyouts, xpos_nrh_lab-0.0015, ypos_nrh_lab - (j)/40.0, 'NRH '+freq_tag+' MHz '+anytim(nrh_hdr.date_obs, /cc, /trun)+' UT', color=0, /normal
				xyouts, xpos_nrh_lab, ypos_nrh_lab - (j)/40.0, 'NRH '+freq_tag+' MHz '+anytim(nrh_hdr.date_obs, /cc, /trun)+' UT', color=colors[j], /normal 
			endif else begin
				xyouts, xpos_nrh_lab+0.0015, ypos_nrh_lab - (j)/40.0, 'NRH '+freq_tag+' MHz ', /normal, color=0
				xyouts, xpos_nrh_lab-0.0015, ypos_nrh_lab - (j)/40.0, 'NRH '+freq_tag+' MHz ', /normal, color=0
				xyouts, xpos_nrh_lab, ypos_nrh_lab - (j)/40.0, 'NRH '+freq_tag+' MHz ', /normal, color=colors[j]
			endelse
		endif		

	endfor						 


 END