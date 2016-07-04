pro mag_syn_map_process, date

	; Master script for synoptic map data. Downloads and plots the data.
	; date is in format '2010-10-10'

	carrington_rot_num = TIM2CARR(anytim(date, /cc), /dc)
	crn_string = string(carrington_rot_num, format='(I4)')
	date_str2 = time2file(date, /date_only)

	response = ''
	READ, response, PROMPT='Is HMI synoptic map for Carrington rotation '+crn_string+' downloaded? (y/n)'

	if response eq 'n' then begin
		print, 'Making directory ~/ELEVATE/data/'+date+'/SDO/HMI/'
		spawn, 'mkdir -p ~/ELEVATE/data/'+date+'/SDO/HMI/
		cd, '~/ELEVATE/data/'+date+'/SDO/HMI/'
		spawn, 'open .'
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
		necliptic=120	; M.DeRosa default
		pfss_field_start_coord, 1, necliptic, radstart=2.5
		spacing=2.5		; M.Derosa default
		pfss_field_start_coord, 7, spacing, radstart=2.5, /add
		;pfss_field_start_coord,15,spacing,radstart=rix(1), /add
		pfss_trace_field

		pfss_get_chfootprint, openfield2, /quiet;, /usecurrent;, /sinlat  ;  for debugging
   		pfss_get_chfootprint, openfield, /quiet, /close, spacing=spacing, /usecurrent;, /sinlat
   		save, openfield, filename = '~/ELEVATE/data/'+date+'/SDO/HMI/chole_field_'+date_str2+'.sav'

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

		save, br, rad, lat, lon, filename = '~/ELEVATE/data/'+date+'/SDO/HMI/connected_field_'+date_str2+'.sav'

		mag_synoptic_map_plot, date, /hs;, /post

	endif
	
END