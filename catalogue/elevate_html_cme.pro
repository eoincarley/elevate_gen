pro elevate_html_cme, row_num, tstart, em_start, pinten, template, $
                    cme_list
	
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
    cactus_link = 'http://sidc.oma.be/cactus/catalog/LASCO/2_5_0/'+qkl+cactus_date+'/cmecat.txt

    sock_list, cactus_link, cactus_html
    cme_cactus_start_index = where(strmid(cactus_html, 0, 5) eq '# CME') + 1
    cme_cactus_stop_index = where(strmid(cactus_html, 0, 6) eq '# Flow') - 2
    cme_info = cactus_html[cme_cactus_start_index:cme_cactus_stop_index]
    cme_info = strsplit(cme_info, '|', /extract)
    cme_times = strarr(n_elements(cme_info))
    cme_vels = fltarr(n_elements(cme_info))
    cme_pa = fltarr(n_elements(cme_info))
    cme_wid = fltarr(n_elements(cme_info))

    for i = 0, n_elements(cme_info)-1 do begin

        cme_times[i] =  ((cme_info)[i])[1]
        cme_vels[i] = ((cme_info)[i])[5]
        cme_wid[i] = ((cme_info)[i])[4]
        cme_pa[i] = ((cme_info)[i])[3]

    endfor    

    cme_times = anytim(cme_times, /utim)
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
        cme_num = 'CME'+string(n_elements(cme_times) - cactus_ind, format='(I04)')
        template[irow+1] = template[irow+1] + strmid(template[irow+1], 0, ind_date+len) +qkl+ cactus_date +'/'+cme_num+'/CME.html")>'+cme_time+' UT</a> '+question+'<br>' 
        
        first_char = strmid(pinten, 0, 1)
        if first_char eq '>' then $
                pinten = strmid(pinten, 1, 1+strlen(pinten))

        if first_char eq 'N' or first_char eq '-' then $
                pinten = '0.0'    

        if first_char eq 'N' or first_char eq 's' then $
                pinten = '2.0E-1'        
        pinten = float(pinten)        
        if row_num eq 1 then begin
            cme_list = [cme_times[cactus_ind], cme_vels[cactus_ind], cme_pa[cactus_ind], cme_wid[cactus_ind], pinten]
        endif else begin
            cme_list = [[cme_list], [cme_times[cactus_ind], cme_vels[cactus_ind], cme_pa[cactus_ind], cme_wid[cactus_ind], pinten]]
        endelse

        event_folder = '~/ELEVATE/data/'+anytim(em_start, /cc, /date)
        date_string  = time2file(em_start, /date)
        if em_start gt anytim('2010-08-14T00:00:00', /utim) then begin
            event_info_to_text, event_folder, date_string, 'cme_time', anytim(cme_times[cactus_ind], /cc)+' UT'
            event_info_to_text, event_folder, date_string, 'cme_speed', string(cme_vels[cactus_ind], format='(f6.1)')+' km/s'
            event_info_to_text, event_folder, date_string, 'cme_pa', string(cme_pa[cactus_ind], format='(I3)')+' deg'
            event_info_to_text, event_folder, date_string, 'cme_width', string(cme_wid[cactus_ind], format='(I3)')+' deg'
        endif
    endif


END