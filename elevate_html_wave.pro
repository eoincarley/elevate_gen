pro elevate_html_wave, row_num, tstart, em_start, wave_times, wave_times_html, flare_class, active_region, location, template, $
                        euv_wave, output_flare_data, assoc_wave_time
	
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

                irow = where(strtrim(template,1) eq "<!--Solmon-->")  
                ind_date = stregex(template[irow+1], 'date=', length=len) 
                template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + time2file(tstart, /date_only)+'")>SM</a><br>'+$
                                    active_region[result[k]]+'<br>'+$
                                    location[result[k]]       

                output_flare_data[0, row_num-1] = anytim(wave_times[result[k]], /cc)
                output_flare_data[1, row_num-1] = goes_class
                output_flare_data[2, row_num-1] = location[result[k]]        

            endif                        

        ENDFOR
        if row_num eq 1 then assoc_wave_time = wave_times[result[0]] else assoc_wave_time = [ assoc_wave_time, wave_times[ result[0]] ]
        euv_wave = 'yes'
    endif

    ; Now provide local link to three colour AIA movies.
    if anytim(tstart, /utim) gt anytim('2010-08-14T00:00:00', /utim) then begin
        date_str1 = anytim(tstart, /cc, /date_only)
        date_str2 = time2file(tstart, /date_only)
        three_col_mov = 'AIA_' +date_str2+'_3col_ratio_cool.mp4'
        irow = where( strtrim(template, 1) eq "<!--EUV Wave Local-->" )
        ind_date = stregex(template[irow+1], 'maths_server_mirror/', length=len)   
        template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + date_str1 + '/SDO/'+ three_col_mov + '")>Three Colour</a><br>'
    endif

END