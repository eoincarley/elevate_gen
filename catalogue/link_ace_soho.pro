pro link_ace_soho
	
	; Make sim links for ACE and SOHO data.
	base = '~/ELEVATE/data/'
	cd, base
	date_folders = file_search('*-*')
	ace_folders = base+date_folders + '/ACE/'
	soho_folders = base+date_folders + '/SOHO/ERNE/'


	for i=0, n_elements(ace_folders)-1 do begin
		spawn,'mkdir -p ~/Dropbox/particles/'+date_folders[i]	
		cd,'~/Dropbox/particles/'
		spawn,'ln -s ' + ace_folders[i] + ' '+date_folders[i]+'/'
		spawn,'ln -s ' + soho_folders[i]+ ' '+date_folders[i]+'/'
	endfor

;	print, ace_folders
	
END
