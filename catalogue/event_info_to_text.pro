pro event_info_to_text, event_folder, date_string, tag, tag_value


	;--------------------------------------------------------------;
	;	Produce event info structure and save in various formats   ;
	;--------------------------------------------------------------;


	sav_dir_name = event_folder +'/'+ date_string+'_event_info_structure.sav'
	txt_dir_name = event_folder +'/'+ date_string+'_event_info_structure.txt'
	csv_dir_name = event_folder +'/'+ date_string+'_event_info_structure.csv'

	date = anytim(file2time(date_string), /cc, /date, /trun)

	file_exist = file_test(sav_dir_name)

	comment_field = ['Velocity units: km/s', $
							  'Accel units: m/s/s', $
							  'Mass units: g', $
							  'Energy units: J', $
							  'Angle units: degrees', $
							  'Radio Flux units: Jansky', $
							  'Particle intensity units: 1/(cm2/sr/s/MeV)', $
							  'Length units: AU']
							  
	if file_exist eq 0 then begin
		event_info = {name:'event_info', $
					  event_date:date, $
					  flare_class:' ', $
					  flare_location:'00N00E', $
					  flare_start_t:'YYYY-MM-DDTHH:MMM:SS UT', $
					  radio_types:'I, II, III, IV, V ?', $
					  radio_tII_speed:'X km/s (model)', $
					  radio_max_flux:'X Jy (GHz)', $
					  euv_wave_speed:'X km/s', $
					  euv_wave_accel:'X m/s/s', $
					  cme_time:'YYYY-MM-DDTHH:MMM:SS UT', $
					  cme_speed:'X km/s', $
					  cme_accel:'X m/s/s', $
					  cme_pa:'X deg', $
					  cme_width:'X deg', $
					  cme_mass:'X g', $
					  cme_energy:'X J', $
					  proton_vda_t0:' ', $
					  proton_vda_s:' ', $
					  proton_max_i:' (1/cm2/sr/s/MeV)', $
					  electron_vda_t0:' ', $ 
					  electron_vda_s:' ', $	
					  electron_max_i:' (1/cm2/sr/s/MeV)', $
					  sol_wind_speed:' ',$
					  parker_sp_s:' ' $;, $
					  ;comment:comment_field  $
					}

		;event_info = add_tag(event_info, tag_value, tag) 
		save, event_info, filename = sav_dir_name
	endif 


	restore, sav_dir_name, /verb
	if tag_exist(event_info, tag) then begin
		tags = strlowcase( tag_names(event_info) )
		tindex=WHERE(STRCMP(tags, tag) EQ 1)
		event_info.(tindex) = tag_value
	endif else begin
		event_info = add_tag(event_info, tag_value, tag) 
	endelse	
	save, event_info, filename = sav_dir_name
	
	;help, event_info, /str

	tags = strlowcase(tag_names(event_info))
	for	i=0, n_elements(tags)-1 do begin
		tag = tags[i]
		tags = strlowcase( tag_names(event_info) )
		tindex=WHERE(STRCMP(tags, tags[i]) EQ 1)
		if i eq 0 then info_array = [tag+':', event_info.(tindex)] else $
			info_array = [ [info_array], [tag+':', event_info.(tindex) ] ]
	endfor	
	
	OpenW, 100, txt_dir_name
	PrintF, 100, info_array
	close, 100

	write_csv, csv_dir_name, info_array, table_header = ': '+date_string+' event information :'	


END	