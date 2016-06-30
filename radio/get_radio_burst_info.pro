function parse_noaa_events, file

	;---------------------------------------------------;
	; This takes into account missing/blank data entries in the file. I have to parse
	; the file for information with a set number of rows.

	; This reads in an 'ideal' row positions with the max possible amount of entries. It has the positions of where each entry should be.
	

	csv_data = read_csv(file)
	for i=0, n_elements(csv_data.field1)-1 do begin
		if i eq 0 then $
			num_entries = n_elements(((strsplit(csv_data.field1))[i])) $
		else  $
			num_entries = [ num_entries, n_elements(((strsplit(csv_data.field1))[i]))] 
	endfor	 
	max_index = ( where(num_entries eq max(num_entries)) )[0]
	max_entry = (csv_data.field1)[max_index]
	total_len = strlen(max_entry)
	data_entry_pos = strsplit(max_entry)

	;if file eq '20130424events.txt' then stop

	if n_elements(data_entry_pos) ne 12 then begin
		restore, '~/ELEVATE/data/noaa_events/column_template_noaa_events.sav', /verb
		if total_len lt 80 then data_entry_pos = (data_entry_pos-1) >0
	endif	


	data = read_csv(file, header=hdr)
	if anytim(file2time(file), /utim) gt anytim('1998-05-09T00:00:00', /utim) then start_index = 12 else start_index=2	; Header in first 11 lines.

	for j=start_index, n_elements((data.field1))-1 do begin
		row = (data.field1)[j]

		for i=0, n_elements(data_entry_pos)-1 do begin

			if i lt n_elements(data_entry_pos)-1 then $
				len = data_entry_pos[i+1] - data_entry_pos[i] $
			else $
				len = total_len - data_entry_pos[i]	
			pos = data_entry_pos[i]
			element = strmid(row, pos, len)

			if i eq 0 then elems = element else elems = [elems, element]
		endfor

		if j eq start_index then all_rows = [[elems]] else all_rows = [ [all_rows], [elems]  ]

	endfor	
	
	return, all_rows
END

pro get_radio_burst_info, time, trange, radio_type, $
				assoc_radio_events=assoc_radio_events

	;
	; Description of NOAA events here: ftp://ftp.swpc.noaa.gov/pub/indices/events/README
	; time: Input time to search around  e.g., '2010-01-04T22:00:00'
	; trange: range of time window in minutes e.g., 30.0
	; radio_events_info: output radio_events_info within stated time range
	; radio_type is 'RSP' for radio bursts or 'RBR' for flux_density max at single frequency.
	; Calling sequence: get_radio_burst_info, '2010-01-04T22:00:00', 30.0, 'RSP'

	; There's also numerous event lists here: http://soleil.i4ds.ch/solarradio/
	;

	time_ut = anytim(time, /utim)
	time_0 = time_ut - trange*60.0
	time_1 = time_ut + trange*60.0
	

	yyyymmdd = time2file(time, /date_only)
	yyyy = string((anytim(time, /ex))[6], format='(I4)')
	
	folder = '~/ELEVATE/data/noaa_events/'+yyyy+'_events
	if file_test(folder) eq 0 then begin
		file = yyyy+'_events.tar.gz'
		url = 'ftp://ftp.swpc.noaa.gov/pub/warehouse/'+yyyy+'/'+file
		sock_copy, url, out_dir='~/ELEVATE/data/noaa_events/'
		cd,'~/ELEVATE/data/noaa_events/'
		spawn, 'tar -xzvf '+file
	endif 	
	cd, folder
	file = yyyymmdd+'events.txt'

	;------------------------------;
	;    Sort events into array
	;
	events_info = parse_noaa_events(file)
	
	;--------------------------------;
	;    Parse events for radio 
	;
	burst_types = ['II', 'III', 'IV', 'V', 'VI', 'VII', 'CTM']
	noaa_types = [ [[burst_types+'/1']], $s
				   [[burst_types+'/2']], $
				   [[burst_types+'/3']] ]

	index_burst  = where(strtrim(events_info, 2) eq radio_type)
	if index_burst[0] ne -1 then begin

		xy = array_indices(events_info, index_burst)
		radio_events_info = events_info[*, xy[1, *]]

		times_start = anytim( file2time(yyyymmdd + '_' + strtrim(radio_events_info[2, *],1) ), /utim)
		times_max = anytim(  file2time(yyyymmdd + '_' + strtrim(radio_events_info[3, *],1) ), /utim)
		times_stop = anytim(  file2time(yyyymmdd + '_' + strtrim(radio_events_info[4, *],1) ), /utim)	   

		;----------------------------------;
		;	Concentrate on start time
		;
		indices = where(times_start gt time_0 and times_start lt time_1)
		if indices[0] ne -1 then begin
			assoc_radio_events = radio_events_info[*, [[indices]]]
			print, ' '
			print, 'Radio activity between '+anytim(time_0, /cc)+' and '+anytim(time_1, /cc)+':'
			assoc_radio_events[2, *]  = yyyymmdd+'_'+assoc_radio_events[2, *]
			assoc_radio_events[3, *]  = yyyymmdd+'_'+assoc_radio_events[3, *]
			assoc_radio_events[4, *]  = yyyymmdd+'_'+assoc_radio_events[4, *]
		endif else begin
			assoc_radio_events = strarr(12, 1)
			assoc_radio_events(*) = 'No SWPC bursts'
			assoc_radio_events[2, *]  = yyyymmdd
			assoc_radio_events[3, *]  = yyyymmdd
			assoc_radio_events[4, *]  = yyyymmdd
			print, 'No radio bursts found within the desired time range.'
		endelse	
		print, assoc_radio_events

	endif else begin
		assoc_radio_events = strarr(12, 1)
		assoc_radio_events(*) = 'No SWPC bursts'
		assoc_radio_events[2, *]  = yyyymmdd
		assoc_radio_events[3, *]  = yyyymmdd
		assoc_radio_events[4, *]  = yyyymmdd
		print, 'No radio bursts found for this day.'
	endelse		

END