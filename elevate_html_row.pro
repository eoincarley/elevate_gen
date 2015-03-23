pro write_row, tstart, row_num
  
  template = rd_tfile('~/ELEVATE/website/row_template.html') 
  template = transpose(template)
  
  ; Edit event_num
  template[3] = string(row_num, format='(I03)')
  
  ; Edit time row
  tstring = anytim(tstart, /ccsds, /date_only) +' <br> '+anytim(tstart, /ccsds, /time_only, /trun)
  template[8] = tstring
  
  ; Edit SM links
  ind_date = stregex(template[13], 'date=', length=len)   
  template[13] = strmid(template[13], 0, ind_date+len) + time2file(tstart, /date_only)+'")>'
  ind_date = stregex(template[19], 'date=', length=len)   
  template[19] = strmid(template[19], 0, ind_date+len) + time2file(tstart, /date_only)+'&type=xray")>'
  
  ; Edit NRH links
  ind_date = stregex(template[30], 'dayofyear=', length=len)   
  template[30] = strmid(template[30], 0, ind_date+len) + time2file(tstart, /date_only)+'&survey_type=1")>'
  
  ;Edit CDAW lists
  ind_date = stregex(template[41], 'daily_movies/', length=len)   
  template[41] = strmid(template[41], 0, ind_date+len) + anytim(tstart, /ecs, /date)+'/")>'
  
  
  openw, 100, '~/ELEVATE/website/soho-erne/row_'+string(row_num, format='(I03)')+'.html'
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


pro elevate_html_row, fname, outname

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
    
    nrh_sun_ephemeris, tstart[i], $
        nrh_tstart, nrh_tend
    IF anytim(em_start[i], /utim) ge nrh_tstart[0] and anytim(em_start[i], /utim) le nrh_tend[0] THEN BEGIN
      print, anytim(nrh_tstart, /cc), anytim(nrh_tend, /cc)
      print, anytim(tstart[i], /cc)
      write_row, tstart[i], row_num
      php_incl[i] = "<?php include('soho-erne/row_"+string(row_num, format='(I03)')+ ".html'); ?>"
      row_num = row_num + 1
    ENDIF 
     
    i=i+1
  ENDWHILE  
  index = where(php_incl ne '')
  print, transpose(php_incl[index])
  
stop
END