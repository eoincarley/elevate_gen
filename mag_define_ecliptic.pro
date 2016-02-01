pro mag_define_ecliptic, date

	carrington_rot_num = TIM2CARR(anytim(date, /cc), /dc)
	crn_string = string(carrington_rot_num, format='(I4)')

	response = ''
	READ, response, PROMPT='Is HMI synoptic map for Carrington rotation '+crn_string+' downloaded? (y/n)'

	if response eq 'n' then begin
		print, 'Making directory ~/ELEVATE/data/'+date+'/SDO/HMI/'
		spawn, 'mkdir -p ~/ELEVATE/data/'+date+'/SDO/HMI/
		print, 'Go to the following URL to download the data: '
		print, 'http://jsoc.stanford.edu/ajax/exportdata.html?ds%3Dhmi.Synoptic_Mr_720s%5B'+crn_string+'%5D%26limit%3Dnone'
	endif 

	if response eq 'y' then begin

		@pfss_data_block

		;  first restore the file containing the coronal field model

		;  date/time is set here to Apr 5, 2003 for demonstration purposes, but any
		;  SSW formatted date/time will do
		pfss_restore,pfss_time2file(date,/ssw_cat,/url)  ;  for all users
		;pfss_restore,pfss_time2file('2003-04-05')   ;  for users at LMSAL

		;  starting points to be on a regular grid covering the full disk, with a
		;  starting radius of r=1.5 Rsun
		invdens = 10 ;  factor inverse to line density, i.e. lower values = more lines
		pfss_field_start_coord,5,invdens,radstart=1.5


		nlines = 200
		str = dblarr(nlines)
		str[*] = 2.5

		lat0 = 89.0
		lat1 = 91.0
		stth = ( dindgen(nlines)*(lat1 - lat0)/(nlines-1.) ) + lat0
		stth = stth*!dtor

		lon0 = -180.0
		lon1 = 180.0
		stph = ( dindgen(nlines)*(lon1 - lon0)/(nlines-1.) ) + lon0
		stph = stph*!dtor

		junk = execute('pfss_trace_field')


		; To get the color of these lines, go to pfss_draw_field3.pro. On line 143 there is a for loop
		; that sets each field line property. The color of the field line can be gotten here from the
		; olist object. The olist object is created by pfss_view_create.

		;-------------------------------------------;
		;		Determine open field colours
		mag_determine_color, date, rix, theta, nstep, ptr, ptth, ptph, lat, lon, br
		;------------------------------------

		rad = ptr
		lat = 90.0 - ptth*!radeg
		lon = (ptph)*!radeg + 180.0

		date_str2 = time2file(date, /date_only)
		save, br, rad, lat, lon, filename = '~/ELEVATE/data/'+date+'/SDO/HMI/connected_field_'+date_str2+'.sav'


		mag_synoptic_map_plot, date
	endif
	
END