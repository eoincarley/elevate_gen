pro oplot_nrh_on_three_color, aia_hdr

	;				PLOT NRH
	;tstart = anytim(aia_hdr.date_obs, /utim) 
	  
	folder = '~/Data/2014_Apr_18/radio/nrh/'
	cd, folder
	nrh_filenames = findfile('*.fts')

	for j=0,8 do begin
		tstart = anytim('2014-04-18T12:35:11', /utim) ;anytim(aia_hdr.date_obs, /utim) 
		t0 = anytim(tstart, /yoh, /trun, /time_only)
		nrh_file_index = j



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
				;levels = (dindgen(nlevels)*(max_val - 7.0)/(nlevels-1.0)) $
				;			+ 7.0		

				;			Overlay NRH contours
		set_line_color
		
		set_line_color
		plot_map, nrh_map, $
			/overlay, $
			/cont, $
			levels=levels, $
			/noxticks, $
			/noyticks, $
			/noaxes, $
			thick=4.0, $
			color=1	


		plot_map, nrh_map, $
			/overlay, $
			/cont, $
			levels=levels, $
			/noxticks, $
			/noyticks, $
			/noaxes, $
			thick=2.5, $
			color=j+2					 	
		
		freq_tag = string(nrh_hdr.freq, format='(I03)')

		xpos_nrh_lab = 0.15
		ypos_nrh_lab = 0.23

		;xyouts, xpos_nrh_lab, 0.45 - (j)/40.0, 'NRH '+freq_tag+' MHz', $;+' MHz (1e'+string(max_val, format='(f3.1)')+' K)', $
		;		color=0, $
	;			/normal	

	;	xyouts, xpos_nrh_lab, 0.45 - (j)/40.0, 'NRH '+freq_tag+' MHz', $;+' MHz (1e'+string(max_val, format='(f3.1)')+' K)', $
	;			color=j+2, $
	;			/normal		


		xyouts, xpos_nrh_lab, ypos_nrh_lab, 'NRH '+anytim(nrh_hdr.date_obs, /cc, /trun)+' UT', $
						/normal, $
						color=0

		xyouts, xpos_nrh_lab, ypos_nrh_lab, 'NRH '+anytim(nrh_hdr.date_obs, /cc, /trun)+' UT', $
				/normal, $
				color=2				

	endfor						 


 END