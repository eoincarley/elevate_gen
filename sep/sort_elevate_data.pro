pro sort_elevate_data

  cd,'~/Data/elevate_db/'
  folders = file_search('*-*')
  
  for i=0, n_elements(folders)-1 do begin
      cd, '~/Data/elevate_db/'+folders[i]
      spawn, 'mkdir -p SDO/AIA'
      spawn, 'mv * SDO/AIA'
  endfor


END     
