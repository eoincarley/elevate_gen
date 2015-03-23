pro write_row, tstart, em_start, row_num, folder
  
  template = rd_tfile('~/ELEVATE/website/row_template.html') 
  template = transpose(template)

  ; Edit event_num
  irow = where(strtrim(template,1) eq "<!--Row-->")
  template[irow+1] = string(row_num, format='(I03)')

  ; Edit time row
  irow = where(strtrim(template,1) eq "<!--Date-->")
  tstring = anytim(tstart, /ccsds, /date_only) +' <br> '+anytim(tstart, /ccsds, /time_only, /trun)
  template[irow+1] = tstring

  ; Edit SM links
  irow = where(strtrim(template,1) eq "<!--Solmon-->")  
  ind_date = stregex(template[irow+1], 'date=', length=len) 
  template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + time2file(tstart, /date_only)+'")>'

  irow = where(strtrim(template,1) eq "<!--Goes-->")  
  ind_date = stregex(template[irow+1], 'date=', length=len)   
  template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + time2file(tstart, /date_only)+'&type=xray")>'
  
  ;--------------------------------------------;
  ;           Edit Radio links
  ; NANCAY Survey
    nrh_sun_ephemeris, tstart, $
          nrh_tstart, nrh_tend
    IF anytim(em_start, /utim) le nrh_tstart[0] or anytim(em_start, /utim) ge nrh_tend[0] THEN BEGIN
      survey='4' 
    ENDIF ELSE BEGIN
      survey='1'
      template[0] = '<tr bgcolor="CCFFCC" >'
    ENDELSE
    irow = where(strtrim(template,1) eq "<!--RadioBurst-->")  
    ind_date = stregex(template[irow+1], 'dayofyear=', length=len)   
    template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + time2file(tstart, /date_only)+'&survey_type='+survey+'")>Obspm</a><br>'
    
    ; Learmonth Culgoora
    lear_tstart = anytim('2001-01-01T21:30:00', /utim, /time_only)  
    lear_tend = anytim('2001-01-01T10:30:00', /utim, /time_only)

    IF anytim(em_start, /utim, /time_only) ge lear_tstart[0] or anytim(em_start, /utim, /time_only) le lear_tend[0] THEN BEGIN
      date = time2file(tstart[0], /date_only)
      YY = string(anytim(tstart[0], /hxrbs), format='(A03)')
      irow = where(strtrim(template,1) eq "<!--Learmonth-->")  
      ind_date = stregex(template[irow+1], 'images/', length=len)   
      template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + YY + date + 'spectrograph.gif")>Learmonth</a><br>'
    ENDIF 

    culg_tstart = anytim('2001-01-01T20:00:00', /utim, /time_only)  
    culg_tend = anytim('2001-01-01T08:30:00', /utim, /time_only)

    IF anytim(em_start, /utim, /time_only) ge culg_tstart[0] or anytim(em_start, /utim, /time_only) le culg_tend[0] THEN BEGIN
      date = time2file(tstart[0], /date_only)
      YY = string(anytim(tstart[0], /hxrbs), format='(A03)')
      irow = where(strtrim(template,1) eq "<!--Culgoora-->")  
      ind_date = stregex(template[irow+1], 'images/', length=len)   
      template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + YY + date + 'spectrograph.gif")>Culgoora</a><br>'
    ENDIF
  ;
  ;--------------------------------------------;

  ;Edit CDAW lists
  irow = where(strtrim(template,1) eq "<!--CME-->")  
  ind_date = stregex(template[irow+1], 'daily_movies/', length=len)   
  template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + anytim(tstart, /ecs, /date)+'/")>'

  openw, 100, '~/ELEVATE/website/'+folder+'/row_'+string(row_num, format='(I03)')+'.html'
  printf, 100, template
  close, 100

END

pro nrh_sun_ephemeris, tstart, $
        nrh_tstart, nrh_tend
         
  nrh_lat = 47.0  ;degrees
  nrh_lon = 2.0   ;degrees
  day_hrs = findgen(1000.0)*(24.0)/999.0  ;hours
  day_date = anytim(tstart, /utim, /date_only) + day_hrs*3600.0 ; ut seconds
  date2doy, time2file(tstart, /date_only, /year2) , doy
  zensun, doy, day_hrs, nrh_lat, nrh_lon, zenith_angle
  elevation = 90.0 - zenith_angle   ;degrees
  index = where(elevation eq max(elevation))
  ut_max_elev = day_date[index]           

  nrh_tstart = anytim(ut_max_elev -3.5*3600.0, /utim) ;NRH observes 7 hrs on central meridian
  nrh_tend = anytim(ut_max_elev +3.5*3600.0, /utim)

END


pro elevate_html_row, fname, folder, outname

    ;Procedure to produce html rows for the ELEVATE catalogue.
    ;Input is the text file of times from SEPserver catalogues.

  template = rd_tfile('~/ELEVATE/website/row_template.html') 
  ;readcol, fname, obs_tstart, obs_tend, a, format='A,A,D', delimiter=','
  readcol, fname, obs_tstart, format='A'

  tonset = obs_tstart ;anytim(obs_tstart, /utim) + 0.25*24.0*3600.0  ;Onset is 0.25 days after obs start in catalogue
  em_start = anytim(tonset, /utim) - 60.0*60.0*2.0 ;Roughly, 55-80 MeV protons arrive ~1hr after first EM signatures.
  tstart = tonset
      
    ;Nancay observed for 7 hours of the day centered around the time when
    ;the Sun pases through the meridian at Nancay e.g., when the Sun
    ;has maximum elevation or minimum zenith
  
  nrh_lat = 47.0  ;degrees
  nrh_lon = 2.0   ;degrees
  day_hrs = findgen(1000.0)*(24.0)/999.0  ;hours

  i = 0
  row_num = 1
  save_index = 0.0
  php_incl = strarr(n_elements(tstart))
  WHILE i lt n_elements(tstart)-1 DO BEGIN
    
   
     ; print, anytim(nrh_tstart, /cc), anytim(nrh_tend, /cc)
      ;print, anytim(tstart[i], /cc)
      write_row, tstart[i], em_start[i], row_num, folder
      php_incl[i] = "<?php include('"+folder+"/row_"+string(row_num, format='(I03)')+ ".html'); ?>"
      row_num = row_num + 1
 
     
    i=i+1
  ENDWHILE  
  index = where(php_incl ne '')
  print, transpose(php_incl[index])
  
stop
END