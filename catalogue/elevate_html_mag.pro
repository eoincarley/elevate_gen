pro elevate_html_mag, em_start, template  

  	if em_start gt anytim('2010-08-14T00:00:00', /utim) then begin         
        irow = where(strtrim(template,1) eq "<!--DenMaps-->")  
        hmi_png_link = anytim(em_start, /cc, /date)+'/SDO/HMI_synoptic_map_'+time2file(em_start, /date)+'_hee.png' 

        ind_date = stregex(template[irow+1], 'maths_server_mirror/', length=len)   
        template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + hmi_png_link + '")>HMI Synoptic<span>'
    
        ind_date = stregex(template[irow+2], 'maths_server_mirror/', length=len)   
        template[irow+2] = strmid(template[irow+2], 0, ind_date+len) + hmi_png_link + '" alt="image" height="300" /></span></a><br>'
    endif   


END    