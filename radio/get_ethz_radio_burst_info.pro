function parse_ethz_events, data

	;---------------------------------------------------;
	; This takes into account missing/blank data entries in the file. I have to parse
	; the file for information with a set number of rows.

	; This reads in an 'ideal' row positions with the max possible amount of entries. It has the positions of where each entry should be.
	
	for i=0, n_elements(data)-1 do begin
		if i eq 0 then $
			num_entries = n_elements(strsplit(data[i])) $
		else  $
			num_entries = [ num_entries, n_elements(strsplit(data[i])) ] 
	endfor	 
	max_index = ( where(num_entries eq max(num_entries)) )[0]
	max_entry = data[max_index]
	total_len = strlen(max_entry)
	data_entry_pos = (strsplit(max_entry) -1) > 0

	;if file eq '20130424events.txt' then stop

	for j=0, n_elements(data)-1 do begin
		row = data[j]

		for i=0, n_elements(data_entry_pos)-1 do begin

			if i lt n_elements(data_entry_pos)-1 then $
				len = data_entry_pos[i+1] - data_entry_pos[i] $
			else $
				len = total_len - data_entry_pos[i]	
			pos = data_entry_pos[i]
			element = strmid(row, pos, len)

			if i eq 0 then elems = element else elems = [elems, element]
		endfor

		if j eq 0 then all_rows = [[elems]] else all_rows = [ [all_rows], [elems]  ]

	endfor	

	return, all_rows
END


pro get_ethz_radio_burst_info, time, trange, radio_type, $
				assoc_radio_events=assoc_radio_events

	;
	; Description of NOAA events here: ftp://ftp.swpc.noaa.gov/pub/indices/events/README
	; time: Input time to search around  e.g., '2010-01-04T22:00:00'
	; trange: range of time window in minutes e.g., 30.0
	; radio_events_info: output radio_events_info within stated time range
	; radio_type is 'RSP' for radio bursts or 'RBR' for flux_density max at single frequency.
	; Calling sequence: get_ethz_radio_burst_info, '1995-05-01T22:00:00', 30.0, 'RSP'

	; There's also numerous event lists here: http://soleil.i4ds.ch/solarradio/
	; WIND/WAVES type II burst lists: http://cdaw.gsfc.nasa.gov/CME_list/radio/waves_type2.html
	;

	time_ut = anytim(time, /utim)
	time_0 = time_ut - trange*60.0
	time_1 = time_ut + trange*60.0
	

	yyyymmdd = time2file(time, /date_only)
	yyyymm = strmid(yyyymmdd, 0, 6)
	dd = strmid(yyyymmdd, 6, 2)
	yyyy = string((anytim(time, /ex))[6], format='(I4)')
	
	;folder = '~/ELEVATE/data/noaa_events/'+yyyy+'_events
	;if file_test(folder) eq 0 then begin
	if time_ut lt anytim('2010-01-01T00:00:00', /utim) then $
		url = 'http://soleil.i4ds.ch/solarradio/data/BurstLists/1998-2010_Benz/'+yyyymm $
	else $	
		url = 'http://soleil.i4ds.ch/solarradio/data/BurstLists/2010-yyyy_Monstein/'+'SGD_BLEN_'+yyyy+'_'+dd+'.txt'	

	sock_list, url, data
	;endif 	

	;------------------------------;
	;
	;    Sort events into array
	;
	events_info = parse_ethz_events(data)
	events_info[4, where(events_info[4, *] eq '' ) ] = '1200.0'	
	events_info[5, where(events_info[5, *] eq '' ) ] = '1200.0'	


	tstart_file_fmt = transpose( strmid(yyyymmdd + '_' + strtrim(events_info[4, *],1), 0, 13) )
	tstop_file_fmt = transpose( strmid(yyyymmdd + '_' + strtrim(events_info[5, *],1), 0, 13) )

	times_start = anytim( file2time( tstart_file_fmt ), /utim)
	times_stop = anytim(  file2time( tstart_file_fmt ), /utim)	   

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

stop

END