pro sort_ace_elevate_data, ace_filename

	file = '~/ELEVATE/data/ACE/'+ace_filename

	data = READ_ASCII(file, TEMPLATE=template, DATA_START=69)

	date = dblarr( n_elements( (data.field01)[0, *] ) )
	date_doy = dblarr(5, n_elements( (data.field01)[0, *] ) )
	date_doy[0, *] = (data.field01)[0, *]		;yyyy
	date_doy[1, *] = (data.field01)[1, *]		;doy
	date_doy[2, *] = (data.field01)[2, *]		;hr
	date_doy[3, *] = (data.field01)[3, *]		;min
	date_doy[4, *] = (data.field01)[4, *]		;sec
	

	for i=0, n_elements( (data.field01)[0, *] )-1 do date[i] = anytim( date_conv(date_doy[*, i], 'string'), /utim )
	

	index = 0.0
	j = 0.0
	i = 0.0D
	while i le n_elements( (data.field01)[0, *] )-1 do begin	;Not the neatest loop but works.

		current_month = (anytim( date[index], /ex))[5]	
		month = (anytim( date[i], /ex))[5]	

		if month gt current_month or i eq n_elements( (data.field01)[0, *] )-1 then begin
			if i eq n_elements( (data.field01)[0, *] )-1 then date_ep = [ [date_ep], [date_month, protons, electrons] ]  ; concat very last element
			filename = 'ace_ep_test_' +time2file(date[index], /date_only)+ '.sav' ;_' + time2file(date[i-1], /date_only)+'.sav'
			save, date_ep, filename = filename
			index = i
			j = 0
		endif

		if j eq 0 then begin
			protons = data.field01[5:12, i]
			electrons = data.field01[13:19, i]
			date_month = date[i] 
			date_ep = [date_month, protons, electrons]
		endif else begin 
			protons = data.field01[5:12, i]
			electrons = data.field01[13:19, i]
			date_month = date[i] 
			date_ep = [ [date_ep], [date_month, protons, electrons] ]  	
		end	
		print, date_doy[1, i]
		print, anytim(date[i], /cc)
		
		j=j+1
		i=i+1	

	endwhile

END
