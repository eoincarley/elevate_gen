pro write_row, tstart, em_start, row_num, folder, wave_times, wave_times_html, num_rows, flare_class, active_region, location, $
                      assoc_wave_time, p_intensity, output_flare_data, cme_list = cme_list
  
    template = rd_tfile('~/ELEVATE/website/row_template.html') 
    template = transpose(template)

    ; Edit event_num
    irow = where(strtrim(template,1) eq "<!--Row-->")
    template[irow+1] = string(row_num, format='(I03)')
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

    irow = where(strtrim(template,1) eq "<!--Goes-->")  
    ind_date = stregex(template[irow+1], 'date=', length=len)   
    template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + $
        time2file(tstart, /date_only)+'&type=xray")>'

    event_folder = '/Users/eoincarley/ELEVATE/data/'+anytim(em_start, /cc, /date)+'/'
    date_string = time2file(em_start, /date_only)

    

    ;---------------------------------------------------;
    ;        Find closest flare to em_start             ;
    ;---------------------------------------------------;
    elevate_html_flares, row_num, em_start, template, $
            output_flare_data

   
    ;---------------------------------------------------;
    ;----------------Edit radio links-------------------;
    ;---------------------------------------------------;
    elevate_html_radio, row_num, tstart, em_start, template, $
                    nrh_obs_window

 
    ;---------------------------------------------------;
    ;------------SEPserver Particle links---------------;
    ;---------------------------------------------------;
    if folder eq 'soho-erne' then begin
        sep_row = num_rows - (row_num)
        pinten = p_intensity[sep_row]
        irow = where(strtrim(template,1) eq "<!--ERNE-->")  
        ind_date = stregex(template[irow+1], 'ERNE_P_', length=len)   
        template[irow+1] = strmid(template[irow+1], 0, ind_date+len) + string(sep_row, format='(I04)')+'.gif")>ERNE</a><br>'+pinten     

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
    elevate_html_wave, row_num, tstart, em_start, wave_times, wave_times_html, flare_class, active_region, location, template, $
                        euv_wave, output_flare_data, assoc_wave_time



    ;---------------------------------------------------;
    ;---------------- Edit CME links -------------------;
    ;---------------------------------------------------;
    elevate_html_cme, row_num, tstart, em_start, pinten, template, $
                    cme_list


   if euv_wave eq 'yes' then template[0] = '<tr bgcolor="CCFFCC" >'
   if nrh_obs_window eq 'yes' and euv_wave eq 'yes' then template[0] = '<tr bgcolor="CCFFFF" >'


   openw, 100, '~/ELEVATE/website/'+folder+'/row_'+string(row_num, format='(I03)')+'.html'
   printf, 100, template
   close, 100

   wait, 0.5

END


;
;--------------------------------------------;

;********************************************;
;           MASTER PROCEDURE                 ;  
;
pro elevate_html_row, fname, folder ;, outname

    ; fname is the text file of times from SEPserver catalogues.
    ; folder is where php rows are written to

    ; Procedure to produce html rows for the ELEVATE catalogue.
    ; Input is the text file of times from SEPserver catalogues.
    ; EXAMPLE: elevate_html_row, 'soho_onset.txt', 'soho-erne'

    template = rd_tfile('~/ELEVATE/website/row_template.html') 

    ;readcol, fname, obs_tstart, obs_tend, a, format='A,A,D', delimiter=','
    readcol, fname, obs_tstart, p_intensity, format='A, A, A'
    tonset = obs_tstart ;anytim(obs_tstart, /utim) + 0.25*24.0*3600.0  ;Onset is 0.25 days after obs start in catalogue
    ;Roughly, 55-80 MeV protons arrive ~1hr after first EM signatures. Also take into account rough light travel time:
    em_start = anytim(tonset, /utim) - 60.0*60.0*1.0 + 8.0*60.0 
    tstart = tonset
    output_flare_data = strarr(3, n_elements(tstart))

  
    restore, '~/ELEVATE/data/lmsal_euv_wave_times.sav'
    row_num = 1
    num_rows = n_elements(obs_tstart)
    save_index = 0.0
    php_incl = strarr(n_elements(tstart))
    FOR i = n_elements(tstart)-1, 0, -1 DO BEGIN  ;reverse loop to have latest events at the top

        write_row, tstart[i], em_start[i], row_num, folder, wave_times, wave_times_html, num_rows, flare_class, active_region, location, $
              assoc_wave_times, p_intensity, output_flare_data, cme_list = cme_list
        php_incl[i] = "<?php include('"+folder+"/row_"+string(row_num, format='(I03)')+ ".html'); ?>"

        stop        
        row_num = row_num + 1

    ENDFOR   

  save, cme_list, filename='~/ELEVATE/data/elevate_cactus_cmes.sav'
  save, assoc_wave_times, filename = '~/ELEVATE/data/assoc_wave_times.sav'

  index = where(php_incl ne '')
  print, transpose(php_incl[index])
  
END