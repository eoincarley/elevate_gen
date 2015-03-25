pro write_row, tstart, em_start, row_num, folder, wave_times, wave_times_html, num_rows
  
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
        nrh_obs_window = 'no'
    ENDIF ELSE BEGIN
        survey='1'
        nrh_obs_window = 'yes'
    ENDELSE

    IF anytim(tstart, /utim, /time_only) eq anytim('2000-01-01T12:00:00', /utim, /time_only) then template[0] = '<tr bgcolor="FFCCCC" >'

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

  ;Edit CDAW and Cactus lists
  irow = where(strtrim(template,1) eq "<!--CDAW-->")  
  ind_date = stregex(template[irow+1], 'daily_movies/', length=len)   
  template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + anytim(tstart, /ecs, /date)+'/")>CDAW</a> <br>'

  irow = where(strtrim(template,1) eq "<!--Cactus-->")  
  ind_date = stregex(template[irow+1], '2_5_0/', length=len)   
  cactus_date = anytim(tstart, /ex)

  if anytim(tstart, /utim) le anytim('2010-06-01T00:00:00', /utim) then qkl = '' else qkl='qkl/'
  cactus_date = string(cactus_date[6], format='(I04)')+'/'+string(cactus_date[5], format='(I02)')
  template[irow+1] = strmid(template[irow+1], 0, ind_date+len) +qkl+ cactus_date + '/latestCMEs.html")>CACTus</a> <br>' 

  ;-----------------------------------------------;
  ;           Edit Particle links
  if folder eq 'soho-erne' then begin
      sep_row = num_rows - (row_num)
      irow = where(strtrim(template,1) eq "<!--ERNE-->")  
      ind_date = stregex(template[irow+1], 'ERNE_P_', length=len)   
      template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + string(sep_row, format='(I04)')+'.gif")>ERNE</a><br>'

      if anytim(tstart, /utim) lt anytim('2011-01-28T01:56', /utim) then begin
          irow = where(strtrim(template,1) eq "<!--EPHIN-->")  
          ind_date = stregex(template[irow+1], 'EPHIN_Es_', length=len)   
          template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + string(sep_row, format='(I04)')+'.png")>EPHIN</a><br>'

          irow = where(strtrim(template,1) eq "<!--EPAM-->")  
          ind_date = stregex(template[irow+1], 'EPAM_E_', length=len)   
          template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + string(sep_row, format='(I04)')+'.png")>EPAM</a><br>'
      endif
  endif


  ;-----------------------------------------------;
  ;         Check for candidate wave
  ;   Data from http://aia.lmsal.com/AIA_Waves/
  ;   Define a two hour window around em_start time
  euv_wave = 'no' ;Default, prove otherwise.
  wave_check_t0 = anytim(em_start, /utim) - 60.0*60.0
  wave_check_t1 = anytim(em_start, /utim) + 60.0*60.0
  wave_times = anytim(wave_times, /utim)
  result = where(wave_times ge wave_check_t0 and wave_times le wave_check_t1)

  irow = where(strtrim(template,1) eq "<!--EUV Wave-->")  
  if result[0] ne -1 then begin
      FOR k =0, n_elements(result)-1 DO BEGIN
          wave_time = anytim(wave_times[result[k]], /cc, /time_only, /trun)+' UT'    ; For display online.
          candidate_wave = (strsplit(wave_times_html[result[k]], '"', /extract))[1]
          candidate_wave = (strsplit(candidate_wave, '..', /extract))[0]
          lmsal_94_link = candidate_wave 
          lmsal_211_link = STRJOIN(STRSPLIT(lmsal_94_link, 'aia_0094', /EXTRACT, /REGEX), 'aia_0211_rdiff')
          lmsal_211_link = STRJOIN(STRSPLIT(lmsal_211_link, 'AIA_0094', /EXTRACT, /REGEX), 'AIA_0211_RDIFF')
          ind_date = stregex(template[irow+1], 'aia.lmsal.com', length=len)   
          template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + lmsal_211_link + '.html")>LMSAL <br>'+wave_time+'</a><br>'
      ENDFOR
      euv_wave = 'yes'
  endif

  if euv_wave eq 'yes' then template[0] = '<tr bgcolor="CCFFCC" >'
  if nrh_obs_window eq 'yes' and euv_wave eq 'yes' then template[0] = '<tr bgcolor="CCFFFF" >'


  openw, 100, '~/ELEVATE/website/'+folder+'/row_'+string(row_num, format='(I03)')+'.html'
  printf, 100, template
  close, 100

END

;-----------------------------------;
;     NRH empheris calculation
;
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
;
;--------------------------------------------;

;********************************************;
;           MASTER PROCEDURE                 ;  
;
pro elevate_html_row, fname, folder, outname

    ;Procedure to produce html rows for the ELEVATE catalogue.
    ;Input is the text file of times from SEPserver catalogues.

  template = rd_tfile('~/ELEVATE/website/row_template.html') 
  ;readcol, fname, obs_tstart, obs_tend, a, format='A,A,D', delimiter=','
  readcol, fname, obs_tstart, format='A'

  tonset = obs_tstart ;anytim(obs_tstart, /utim) + 0.25*24.0*3600.0  ;Onset is 0.25 days after obs start in catalogue
  em_start = anytim(tonset, /utim) - 60.0*60.0*2.0 ;Roughly, 55-80 MeV protons arrive ~1hr after first EM signatures.
  tstart = tonset
  
  restore, 'lmsal_euv_wave_times.sav'
    ;Nancay observed for 7 hours of the day centered around the time when
    ;the Sun pases through the meridian at Nancay e.g., when the Sun
    ;has maximum elevation or minimum zenith
  
  nrh_lat = 47.0  ;degrees
  nrh_lon = 2.0   ;degrees
  day_hrs = findgen(1000.0)*(24.0)/999.0  ;hours

  i = 0
  row_num = 1
  num_rows = n_elements(obs_tstart)
  save_index = 0.0
  php_incl = strarr(n_elements(tstart))
  FOR i = n_elements(tstart)-1, 0, -1 DO BEGIN  
   
     ; print, anytim(nrh_tstart, /cc), anytim(nrh_tend, /cc)
      write_row, tstart[i], em_start[i], row_num, folder, wave_times, wave_times_html, num_rows
      php_incl[i] = "<?php include('"+folder+"/row_"+string(row_num, format='(I03)')+ ".html'); ?>"
      row_num = row_num + 1
 
  ENDFOR   
    ;i=i+1
  ;ENDWHILE  
  index = where(php_incl ne '')
  print, transpose(php_incl[index])
  
END