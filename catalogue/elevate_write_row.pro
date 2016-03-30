pro elevate_write_row, folder, row_num, num_rows, tstart, p_intensity, $     ; INPUT
                      assoc_euv_waves, assoc_flares, assoc_cmes    ; OUTPUT

    ;+
    ;NAME:
    ;   elevate_write_row
    ;
    ;PROJECT:
    ;   ELEVATE Catalogue
    ;
    ;
    ;PURPOSE:
    ;       Using the particle onset time and the EM radiation start time find the low coronal activity
    ;       associated with the SEP events. Then write the links.
    ;
    ;CALLING SEQUENCE:
    ;      elevate_html_row, folder, row_num, num_rows, tstart,  p_intensity, $     ; INPUT
    ;                  assoc_euv_waves, assoc_flares, assoc_cmes    ; OUTPUT
    ;
    ;INPUT:
    ;       folder: Folder in which html is to be written.
    ;       row_num: Row number to write into the table.
    ;       num_rows: Total number of rows.
    ;       tstart: SEP onset time from SEPserver catalogue.
    ;       p_intensity: Proton intensity from SEPserver catalogue.
    ;
    ;OUTPUT:
    ;       assoc_euv_waves: Times of the EUV waves associated with the particle events. 
    ;                        Found from Nariaki Nitta's LMSAL list.
    ;       assoc_flares: Properties of the associated flare. Found from a variety of lists.
    ;       assoc_cmes: Associated CME properties. Found from CACTus for now.
    ;       
    ;KEYWORDS:
    ;       None
    ;
    ;HISTORY:
    ;     2015: Written by Eoin Carley
    ;     2016-March-23: Cleanup, Eoin Carley.  
    ;-                  

    em_start = anytim(tstart, /utim) - 60.0*60.0*1.0 + 8.0*60.0    ; 1hr before particle onset, plus 8 minute light travel time.
    sep_row = num_rows - (row_num)
    pinten = p_intensity[sep_row]

    template = rd_tfile('~/ELEVATE/website/row_template_v2.html') 
    template = transpose(template)

    ; Edit event_num
    irow = where(strtrim(template,1) eq "<!--Row-->")
    template[irow+1] = '<a name="'+string(row_num, format='(I03)')+'">'+string(row_num, format='(I03)')+'</a>'
    print,'Row number: '+string(row_num)

    ; Edit time row
    irow = where(strtrim(template,1) eq "<!--Date-->")
    tstring = anytim(tstart, /ccsds, /date_only) + $
      ' <br> '+anytim(tstart, /ccsds, /time_only, /trun)
    template[irow+1] = tstring + ' UT'

    ; Edit SM links
    irow = where(strtrim(template,1) eq "<!--Solmon-->")  
    ind_date = stregex(template[irow+1], 'date=', length=len) 
    template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + $
        time2file(tstart, /date_only)+'")>SM</a>'

    ; Edit Goes links    
    irow = where(strtrim(template,1) eq "<!--Goes-->")  
    ind_date = stregex(template[irow+1], 'date=', length=len)   
    template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + $
        time2file(tstart, /date_only)+'&type=xray")>'

    event_folder = '/Users/eoincarley/ELEVATE/data/'+anytim(em_start, /cc, /date)+'/'
    date_string = time2file(em_start, /date_only)

    ;---------------------------------------------------;
    ;          Find closest flare to em_start           ;
    ;---------------------------------------------------;
    elevate_html_flares, row_num, tstart, em_start, template, $
            assoc_flares

   
    ;---------------------------------------------------;
    ;----------------Edit radio links-------------------;
    ;---------------------------------------------------;
    elevate_html_radio, row_num, tstart, em_start, template, $
            nrh_obs_window

    ;---------------------------------------------------;
    ;------------SEPserver Particle links---------------;
    ;---------------------------------------------------;
    elevate_html_seps, folder, row_num, num_rows, tstart, em_start, p_intensity, template  


    ;---------------------------------------------------;
    ;         Check for candidate EUV wave
    ;   Data from http://aia.lmsal.com/AIA_Waves/
    ;   Define a two hour window around em_start time
    elevate_html_wave, row_num, tstart, em_start, template, $
                euv_wave, assoc_flares, assoc_euv_waves


    ;---------------------------------------------------;
    ;---------------- Edit CME links -------------------;
    ;---------------------------------------------------;
    elevate_html_cme, row_num, tstart, em_start, pinten, template, $
                    assoc_cmes
           
    ;---------------------------------------------------;
    ;--------- Edit HMI Synoptic map links -------------;
    ;---------------------------------------------------;         
    elevate_html_mag, em_start, template    

    ;---------------------------------------------------;
    ;---------------- Edit Results ---------------------;
    ;---------------------------------------------------;    
    if em_start gt anytim('2010-08-14T00:00:00', /utim) then begin         
        irow = where(strtrim(template,1) eq "<!--Results-->")  
        local_results_file = time2file(em_start, /date)+'_event_info_structure.txt'
        local_url = anytim(em_start, /cc, /date) +'/'+ local_results_file

        ind_date = stregex(template[irow+1], 'maths_server_mirror/', length=len)   
        template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + local_url  + '")>Event Info</a><br>'
    endif    

    if row_num mod 2 eq 0 then template[0] = '<tr bgcolor=#B0B0B0 >' else template[0] = '<tr bgcolor=#D0D0D0 >' ;Alternate the row colours.
    ;if euv_wave eq 'yes' then template[0] = '<tr bgcolor=#333366 >'
    ;if nrh_obs_window eq 'yes' and euv_wave eq 'yes' then template[0] = '<tr bgcolor=#333366 >'


   openw, 100, '~/ELEVATE/website/'+folder+'/row_'+string(row_num, format='(I03)')+'.html'
   printf, 100, template
   close, 100


END