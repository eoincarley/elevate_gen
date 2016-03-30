pro elevate_html_seps, folder, row_num, num_rows, tstart, em_start, p_intensity, template  

    if folder eq 'soho-erne' then begin
        date_str = time2file(em_start, /date)
        folder_date = anytim(em_start, /cc, /date)
        sep_row = num_rows - (row_num)
        pinten = p_intensity[sep_row]
        irow = where(strtrim(template,1) eq "<!--ERNE-->")  
        ind_date = stregex(template[irow+1], 'ERNE_P_', length=len)   
        template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + string(sep_row, format='(I04)')+'.gif")>SEPserver</a><br>';+pinten     
        
        if em_start gt anytim('2010-08-14T00:00:00', /utim) then begin
            local_folder = '~/ELEVATE/website/maths_server_mirror/'+folder_date+'/SOHO/'
            erne_png_name = file_search( local_folder+'soho_erne*.png')

            if erne_png_name ne '' then begin
                local_url = (strsplit(erne_png_name, 'maths_server_mirror/', /extract, /regex))[1]
                irow = where(strtrim(template,1) eq "<!--ERNE_LOCAL-->")  
                ind_date = stregex(template[irow+1], 'maths_server_mirror/', length=len)   
                template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + local_url  + '")>ERNE<span>'

                ind_date = stregex(template[irow+2], 'maths_server_mirror/', length=len)   
                template[irow+2] = strmid(template[irow+2], 0, ind_date+len) + local_url  + '" alt="image" height="400" /></span></a><br>'
            endif

            local_folder = '~/ELEVATE/website/maths_server_mirror/'+folder_date+'/ACE/
            epam_png_name = file_search( local_folder+'ace_epam*.png')
            if epam_png_name ne '' then begin
                local_url = (strsplit(epam_png_name, 'maths_server_mirror/', /extract, /regex))[1]
                irow = where(strtrim(template,1) eq "<!--EPAM_LOCAL-->")  

                ind_date = stregex(template[irow+1], 'maths_server_mirror/', length=len)   
                template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + local_url  + '")>EPAM<span>'

                ind_date = stregex(template[irow+2], 'maths_server_mirror/', length=len)   
                template[irow+2] = strmid(template[irow+2], 0, ind_date+len) + local_url  + '" alt="image" height="400" /></span></a><br>'

            endif
        endif    

        if anytim(tstart, /utim) lt anytim('2011-01-28T01:56', /utim) then begin
            irow = where(strtrim(template,1) eq "<!--EPHIN-->")  
            ind_date = stregex(template[irow+1], 'EPHIN_Es_', length=len)   
            template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + string(sep_row, format='(I04)')+'.png")>EPHIN</a><br>'

            irow = where(strtrim(template,1) eq "<!--EPAM-->")  
            ind_date = stregex(template[irow+1], 'EPAM_E_', length=len)   
            template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + string(sep_row, format='(I04)')+'.png")>SEPserver</a><br>'

        endif

        if em_start gt anytim('2010-08-14T00:00:00', /utim) then event_info_to_text, '~/ELEVATE/data/'+anytim(em_start, /cc, /date), date_str, 'proton_max_i', string(pinten, format='(E8.2)') + ' (1/cm2/sr/s/MeV)'
    endif

END    