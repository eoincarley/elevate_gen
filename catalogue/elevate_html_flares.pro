pro elevate_html_flares, row_num, tstart, em_start, template,  $
			output_flare_data

	; Prodecure used by elevate_write_row to search for closest flare to em_start

    ;------------------------------------------;
    ;  Search for the closest flare to the EM 
    ;  start time (~90 minutes before the 55 
    ;  MeV proton onset.)
    flares = hsi_read_flarelist()
    start_times = flares.start_time
    closest_flare = closest(start_times, em_start)
    cand_flare = flares[closest_flare]
    goes_class = cand_flare.goes_class
    hsi_flare_time = cand_flare.start_time
    ;active_region = cand_flare.active_region

    ;-----------------------------------------;
    ;   Search for links to the flare 
    ;   on the LMSAL archive.
    flare_date = anytim(hsi_flare_time, /ecs, /date_only)
    gev_name = strmid('gev_'+time2file(hsi_flare_time), 0, 17)
    gev_link = 'http://www.lmsal.com/solarsoft/latest_events_archive/events_summary/'+flare_date+'/';+gev_name
    sock_list, gev_link, gev_html
    
    if gev_html[0] ne '' and n_elements(gev_html) lt 100 then begin 
        gev_html = gev_html[where(strmid(gev_html, 0, 19) eq '   <tr class="even"' or strmid(gev_html, 0, 18) eq '   <tr class="odd"')]
        gev_html = gev_html[1:n_elements(gev_html)-1]
        result = STREGEX(gev_html, 'gev_'+time2file(hsi_flare_time, /date_only))
        gev_names = gev_html
        for i = 0, n_elements(gev_names)-1 do gev_names[i] = strmid(gev_html[i], result[i], 17)
        gev_times = anytim(file2time(gev_names), /utim)
        gev_flare_index = closest(gev_times, em_start)
        gev_flare_time = gev_times[gev_flare_index]
        if abs(gev_flare_time - em_start) gt 60.0*60.0*2.0 or (tstart - gev_flare_time) lt 0.0 then begin
            gev_name = ''
            goes_class = ''
            gev_location = ''
            positon = ''
            gev_active_region = ''
            gev_link = 'http://www.lmsal.com/solarsoft/latest_events_archive/events_summary/'+flare_date+'/'
            flare_time_stamp = ''
        endif else begin
            gev_name = gev_names[gev_flare_index]       ; The closest flare to the em_start time.
            gev_link = 'http://www.lmsal.com/solarsoft/latest_events_archive/events_summary/'+flare_date+'/'+gev_name
            sock_list, gev_link, gev_flare_html
            
            ;-------------------------------------------------;
            ;       Various parsings of the LMSAL links.
            ;
            goes_class = strmid(gev_flare_html[where(stregex(gev_flare_html, '<th>GOES*') eq 0) + 7], 4, 4)
            ar_html = gev_flare_html[where(stregex(gev_flare_html, '<th>GOES*') eq 0) +8]
            if strlen(ar_html) gt 25 then gev_location = strmid(ar_html, stregex(ar_html, '</a>')-6, 6) else gev_location = strmid(ar_html, 4, 6)
            gev_active_region = strmid(ar_html, stregex(ar_html, 'region=')+7, 5)
            nors = strmid(gev_active_region, 0,1)
            if nors eq '0' or nors eq '1' then gev_active_region = gev_active_region else gev_active_region = ''
            flare_time_stamp = anytim(gev_flare_time, /cc, /time_only, /trun)+' UT'    
            ;if gev_name eq 'gev_20140901_1805' then stop

            event_folder = '~/ELEVATE/data/'+anytim(em_start, /cc, /date)
            date_string  = time2file(em_start, /date)
            event_info_to_text, event_folder, date_string, 'flare_class', goes_class
            event_info_to_text, event_folder, date_string, 'flare_start_t', anytim(gev_flare_time, /cc)+' UT'
            event_info_to_text, event_folder, date_string, 'flare_location', gev_location  
        endelse   

        irow = where( strtrim(template, 1) eq "<!--Flare LMSAL-->" )
        ind_date = stregex(template[irow+1], 'events_summary/', length=len)   
        template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + flare_date+'/'+gev_name+'")>LMSAL </a><br>'$
                          +goes_class+'<br>'+flare_time_stamp

        irow = where(strtrim(template,1) eq "<!--Solmon-->")  
        ind_date = stregex(template[irow+1], 'date=', length=len) 
        template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + time2file(gev_flare_time, /date_only)+'")>SM</a><br>'+$
                            gev_active_region+'<br>'+$
                            gev_location       

        output_flare_data[0, row_num-1] = anytim(gev_flare_time, /cc)
        output_flare_data[1, row_num-1] = goes_class
        output_flare_data[2, row_num-1] = gev_location                          

    endif



END