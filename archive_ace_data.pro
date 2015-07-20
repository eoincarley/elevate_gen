pro archive_ace_data

	;Just putting ACE data into appropriate date folders

	cd,'~/ELEVATE/data/'
	data_folders = file_search('*-*')
	data_times = anytim(data_folders, /ex)
	data_months = data_times[5, *]
	data_tmp = data_times
	data_tmp[4, *] = 1.0
	data_tmp = anytim(data_tmp, /utim)

	cd,'~/ELEVATE/data/ACE'
	ace_files = file_search('*.sav')
	ace_times = anytim(file2time(ace_files), /utim)
	ace_months = ace_times[5, *]
	

	for i=0, n_elements(data_months)-1 do begin
	
		index_ace = closest(ace_times, data_tmp[i])
		
		print, 'Data time: ' + anytim(data_times[*, i], /cc)
		print, 'ACE time: ' + anytim(ace_times[index_ace], /cc)
		print, 'Data folder: ' + data_folders[i]
		cd, '~/ELEVATE/data/'+ data_folders[i]+'/ACE/'
		file = file_search('*.sav')
		
		new_name = (strsplit(file, 'test_', /ex, /reg))[0] + (strsplit(file, 'test_', /ex, /reg))[1]
		spawn, 'mv '+file+' '+new_name	
		print, new_name
		print, ' '
		print, '----------------'
		;spawn, 'rm -f  ~/ELEVATE/data/'+ data_folders[i]+'/*.sav'
	endfor	


END
