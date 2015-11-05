pro archive_ace_data

	;Just putting ACE data into appropriate date folders

	cd,'~/ELEVATE/data/'
	data_folders = file_search('*-*')
	data_times = anytim(data_folders, /utim)

	cd,'~/ELEVATE/data/ACE'
	ace_files = file_search('*.sav')
	ace_times = anytim(file2time(ace_files), /utim)

	stop
	for i=0, n_elements(data_times)-1 do begin
		index_ace = closest(ace_times, data_times[i])
		print, 'Data time: ' + anytim(data_times[i], /cc)
		print, 'ACE time: ' + anytim(ace_times[index_ace], /cc)
		print, ' '
		print, '-----'
	endfor	




END