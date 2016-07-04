;-----------------------------------;
;     NRH empheris calculation
;
pro nrh_sun_ephemeris, tstart, $
        nrh_tstart, nrh_tend

    ;Nancay observed for 7 hours of the day centered around the time when
    ;the Sun pases through the meridian at Nancay e.g., when the Sun
    ;has maximum elevation or minimum zenith      
         
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

pro elevate_html_radio, row_num, tstart, em_start, template, $
                    nrh_obs_window, swpc_radio_burst_list

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
    template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + $
        time2file(tstart, /date_only)+'&survey_type='+survey+'")>Obspm</a><br>'

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

    ;------------------------------------------;
    ;           Search radio bursts            ;
    ;                                          ;
    get_swpc_radio_burst_info, em_start, 120.0, 'RSP', assoc_radio_events=assoc_swpc_radio_bursts
    event_folder = '~/ELEVATE/data/'+anytim(em_start, /cc, /date)
    date_string  = time2file(em_start, /date)
    separator = strarr(12)
    separator[*] = '---'
    if row_num eq 1 then begin
        swpc_radio_burst_list = [assoc_swpc_radio_bursts]
    endif else begin   
        assoc_swpc_radio_bursts = [[assoc_swpc_radio_bursts], [separator]]
        swpc_radio_burst_list = [ [swpc_radio_burst_list], [assoc_swpc_radio_bursts] ]
    endelse
    radio_types = ''
    types = strtrim(assoc_swpc_radio_bursts[9, *], 2)
    if ISA(strsplit(types, '/', /extract), 'LIST') then begin
    	types = (strsplit(types, '/', /extract)).toarray() 
    	types = types[*, 0]
    endif else begin
    	types = strsplit(types, '/', /extract) ; NOAA SWPC places a /1, /2 or /3 after the radio burst type to indicate significance of the burst. This removes it.
    	types = types[0]
    endelse	

    types = types[ uniq(types, sort(types)) ]
    foreach elem, types do radio_types = radio_types+strtrim(elem, 2)+' '
    irow = where(strtrim(template,1) eq "<!--Burst-Types-->")  
    template[irow+1] = radio_types

    irow = where(strtrim(template,1) eq "<!--SWPC-Events-->")  
    yyyy = strmid(time2file(tstart[0], /date_only), 0, 4)
    ind_date = stregex(template[irow+1], 'noaa_events/', length=len)   
    template[irow+1] = strmid(template[irow+1], 0, ind_date+len) +  yyyy + '_events/'+date_string+'events.txt")>SWPC events</a><br>'
 
    if em_start gt anytim('2010-08-14T00:00:00', /utim) then event_info_to_text, event_folder, date_string, 'radio_types', [radio_types]

END