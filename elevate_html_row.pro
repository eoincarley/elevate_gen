pro write_row, tstart, em_start, row_num, folder, wave_times, wave_times_html, num_rows, flare_class, location, active_region
  
  template = rd_tfile('~/ELEVATE/website/row_template.html') 
  template = transpose(template)

  ; Edit event_num
  irow = where(strtrim(template,1) eq "<!--Row-->")
  template[irow+1] = string(row_num, format='(I03)')

  ; Edit time row
  irow = where(strtrim(template,1) eq "<!--Date-->")
  tstring = anytim(tstart, /ccsds, /date_only) +' <br> '+anytim(tstart, /ccsds, /time_only, /trun)
  template[irow+1] = tstring + ' UT'

  ; Edit SM links
  irow = where(strtrim(template,1) eq "<!--Solmon-->")  
  ind_date = stregex(template[irow+1], 'date=', length=len) 
  template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + time2file(tstart, /date_only)+'")>SM</a>'

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
        irow = where(strtrim(template,1) eq "<!--RadioImgs-->") 
        template[irow+1] = 'Soon' 
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
  wave_check_t0 = anytim(em_start, /utim) - 60.0*60.0*1.5
  wave_check_t1 = anytim(em_start, /utim) + 60.0*60.0*1.5
  wave_times = anytim(wave_times, /utim)
  result = where(wave_times ge wave_check_t0 and wave_times le wave_check_t1)

  if result[0] ne -1 then begin
      FOR k =0, n_elements(result)-1 DO BEGIN
          irow = where(strtrim(template,1) eq "<!--EUV Wave-->")  
          wave_time = anytim(wave_times[result[k]], /cc, /time_only, /trun)+' UT'    ; For display online.
          candidate_wave = (strsplit(wave_times_html[result[k]], '"', /extract))[1]
          candidate_wave = (strsplit(candidate_wave, '..', /extract))[0]
          lmsal_94_link = candidate_wave 
          lmsal_211_link = STRJOIN(STRSPLIT(lmsal_94_link, 'aia_0094', /EXTRACT, /REGEX), 'aia_0211_rdiff')
          lmsal_211_link = STRJOIN(STRSPLIT(lmsal_211_link, 'AIA_0094', /EXTRACT, /REGEX), 'AIA_0211_RDIFF')
          ind_date = stregex(template[irow+1], 'aia.lmsal.com', length=len)   
          template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + lmsal_211_link + '.html")>LMSAL <br>'+wave_time+'</a><br>'

          ;-----------Find closest flare to this--------------;
          goes_class = flare_class[result[k]]
          flare_date = anytim(wave_times[result[k]], /ecs, /date_only)
          gev_name = strmid('gev_'+time2file(wave_times[result[k]]), 0, 17)
          gev_link = 'http://www.lmsal.com/solarsoft/latest_events_archive/events_summary/'+flare_date+'/'+gev_name

          if goes_class ne 'U-FL' and goes_class ne 'N-FL' then begin
            irow = where( strtrim(template, 1) eq "<!--Flare LMSAL-->" )
            ind_date = stregex(template[irow+1], 'events_summary/', length=len)   
            template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + flare_date+'/'+gev_name+'")>LMSAL </a><br>'$
                                  +goes_class+'<br>'+anytim(wave_times[result[k]], /cc, /time_only, /trun)+' UT'    
          endif                        


          irow = where(strtrim(template,1) eq "<!--Solmon-->")  
          ind_date = stregex(template[irow+1], 'date=', length=len) 
          template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + time2file(tstart, /date_only)+'")>SM</a><br>'+$
                                active_region[result[k]]+'<br>'+$
                                location[result[k]]                 
        
      ENDFOR
      euv_wave = 'yes'
  endif


  ;------------------------------------------;
  ;                 CMEs
  ;
  irow = where(strtrim(template,1) eq "<!--CDAW-->")  
  ind_date = stregex(template[irow+1], 'daily_movies/', length=len)   
  cdaw_link = 'http://cdaw.gsfc.nasa.gov/CME_list/daily_movies/'+anytim(tstart, /ecs, /date)+'/
  sock_list, cdaw_link, cdaw_html
  if cdaw_html[0] ne '' then template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + anytim(tstart, /ecs, /date)+'/")>CDAW</a> <br>'
  
  ;-------Find closest CACTus CME------------;
  irow = where(strtrim(template,1) eq "<!--Cactus-->")  
  ind_date = stregex(template[irow+1], '2_5_0/', length=len)   
  cactus_date = anytim(em_start, /ex)

  if anytim(tstart, /utim) le anytim('2010-07-01T00:00:00', /utim) then qkl = '' else qkl='qkl/'
  cactus_date = string(cactus_date[6], format='(I04)')+'/'+string(cactus_date[5], format='(I02)')
  cactus_link = 'http://sidc.oma.be/cactus/catalog/LASCO/2_5_0/'+qkl+cactus_date+'/latestCMEs.html

  sock_list, cactus_link, cactus_html
  cme_links  = cactus_html[where(strmid(cactus_html, 0, 14) eq '  <a href="CME')]
  cme_info = (strsplit(cme_links[*], '</a>', /extract, /regex))
  cme_times = fltarr(n_elements(cme_links))
  for i = 0, n_elements(cme_links)-1 do cme_times[i] = anytim(strmid(cme_info[i, 1], 1, 16), /utim)
  cme_times = reverse(cme_times) ;Online CACTus list from the bottom up.

  cactus_check_t0 = anytim(em_start, /utim)
  cactus_check_t1 = anytim(em_start, /utim) + 2.0*60.0*60.0
  cactus_ind = closest(cme_times, em_start+ 40.0)     ;CME should appear in C2 on average less than 40 mins after EM emission start
  cme_time = cme_times[cactus_ind]
  cme_delay =  (cme_time - em_start )/60.0
  if anytim(cme_time, /utim) gt anytim(tstart, /utim) then question = '(?)' else question = ''
  print, 'CME DELAY: '+string(cme_delay)+' mins'
  ;result = where(cme_times ge cactus_check_t0 and cme_times le cactus_check_t1)
  template[irow+1] = strmid(template[irow+1], 0, ind_date+len) +qkl+ cactus_date +'/latestCMEs.html")>CACTus</a> <br>'
   if cme_delay lt 90.0 and cme_delay gt -30 then begin
        cme_time = anytim(cme_time, /cc, /time_only, /trun)
        print, cme_time
        cme_num = 'CME'+string(cactus_ind+1, format='(I04)')
        template[irow+1] = template[irow+1] + strmid(template[irow+1], 0, ind_date+len) +qkl+ cactus_date +'/'+cme_num+'/CME.html")>'+cme_time+' UT</a> '+question+'<br>' 
   endif


  if euv_wave eq 'yes' then template[0] = '<tr bgcolor="CCFFCC" >'
  if nrh_obs_window eq 'yes' and euv_wave eq 'yes' then template[0] = '<tr bgcolor="CCFFFF" >'


  openw, 100, '~/ELEVATE/website/'+folder+'/row_'+string(row_num, format='(I03)')+'.html'
  printf, 100, template
  close, 100
  wait, 2.0
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
  ;Roughly, 55-80 MeV protons arrive ~1hr after first EM signatures. Also take into account light travel time:
  em_start = anytim(tonset, /utim) - 60.0*60.0*1.0 + 8.0*60.0 
  tstart = tonset
  
  restore, 'lmsal_euv_wave_times.sav'
    ;Nancay observed for 7 hours of the day centered around the time when
    ;the Sun pases through the meridian at Nancay e.g., when the Sun
    ;has maximum elevation or minimum zenith
  
  nrh_lat = 47.0  ;degrees
  nrh_lon = 2.0   ;degrees
  day_hrs = findgen(1000.0)*(24.0)/999.0  ;hours


  row_num = 1
  num_rows = n_elements(obs_tstart)
  save_index = 0.0
  php_incl = strarr(n_elements(tstart))
  FOR i = n_elements(tstart)-1, 0, -1 DO BEGIN  
   
     ; print, anytim(nrh_tstart, /cc), anytim(nrh_tend, /cc)
      print, i
      print, anytim(tstart[i], /cc)
      print,' '
      print,'--------------------------'
      write_row, tstart[i], em_start[i], row_num, folder, wave_times, wave_times_html, num_rows, flare_class, location, active_region
      php_incl[i] = "<?php include('"+folder+"/row_"+string(row_num, format='(I03)')+ ".html'); ?>"
      row_num = row_num + 1
 
  ENDFOR   
    ;i=i+1
  ;ENDWHILE  
  index = where(php_incl ne '')
  print, transpose(php_incl[index])
  
END