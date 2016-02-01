pro mag_determine_color, date, rix, theta, nstep, ptr, ptth, ptph, lat, lon, br, open=open

	; This is code taken from the PFSS package. See pfss_view_create.pro
	; It determines which field lines are open or closed from the pfss_viewer 
	; common data block variables.

	rmax=max(rix,min=rmin)
	thmin=min(theta,max=thmax)

	nlines=n_elements(nstep)
	open=intarr(nlines)

	firstline=1
	for i=0,nlines-1 do begin

	  ;  Only draw lines that have line data

	  ns=(nstep)(i)
	  if ns gt 0 then begin

	    ;  determine whether field lines are open or closed
	    if (max((ptr)(0:ns-1,i))-rmin)/(rmax-rmin) gt 0.99 then begin
			irc=get_interpolation_index(rix,(ptr)(0,i))
			ithc=get_interpolation_index( $
			lat,90-(ptth)(0,i)*!radeg)
			iphc=get_interpolation_index( $
			lon,((ptph)(0,i)*!radeg+360) mod 360)
			brc=interpolate(br,iphc,ithc,irc)
			if brc gt 0 then open(i)=1 else open(i)=-1
	    endif  ;  else open(i)=0, which has already been done
	  endif  
	endfor  

	date_str2 = time2file(date, /date_only)
	save, open, filename='~/ELEVATE/data/'+date+'/SDO/HMI/open_colour_'+date_str2+'.sav'

END