pro elevate_build_html_table, filename, folder 

    ;+
    ;
    ;NAME:
    ;   elevate_build_html_table
    ;
    ;PROJECT:
    ;   ELEVATE Catalogue
    ;
    ;
    ;PURPOSE:
    ;   This routine generates all the elements of each row in the ELEVATe table on
    ;   http://www.maths.tcd.ie/~eoincarley/index.php?table=EARTH. It starts with the 
    ;   times of events listed in the SEPserver catalogue then uses these to find 
    ;   coronal activity associated with the SEP events from various catalogue. If 
    ;   coronal activity is found, a URL link is provided in the ELEVATE table.
    ;   On the ELEVATE machine, the website is stored in ~/ELEVATE/website/
    ;   The actual website is hosted in TCD Maths. To acces the live html, go to
    ;   ssh eoincarley@salmon.maths.tcd.ie
    ;
    ;CALLING SEQUENCE:
    ;      elevate_build_html_table, 'soho_onset.txt', 'soho-erne'
    ;      calls elevate_write_row.pro
    ;
    ;
    ;INPUT:
    ;       filename: Text file of SEP onset times. For example, from SOHO ERNE.
    ;                   soho_erne.txt stored in ~/ELEVATE/data/SEPserver
    ;       folder: Folder containing the written html files.
    ;
    ;KEYWORDS:
    ;       None
    ;
    ;HISTORY:
    ;     2015: Written by Eoin Carley
    ;     2016-March-23: Cleanup, Eoin Carley. 
    ; 
    ;-

    readcol, filename, t_onset, p_intensity, format='A, A, A'
    output_flare_data = strarr(3, n_elements(t_onset))
   

    row_num = 1
    save_index = 0.0   
    num_rows = n_elements(t_onset)
    php_incl = strarr(n_elements(t_onset))

    FOR i = n_elements(t_onset)-1, 0, -1 DO BEGIN  ;reverse loop to have latest events at the top of the table

        elevate_write_row, folder, $            ; INPUT
                row_num, $
                num_rows, $
                t_onset[i], $
                p_intensity, $
                assoc_wave_times, $     ; OUTPUT
                output_flare_data, $
                cme_list
        
        php_incl[i] = "<?php include('"+folder+"/row_"+string(row_num, format='(I03)')+ ".html'); ?>"
        
        row_num = row_num + 1
        
    ENDFOR   

  save, cme_list, filename='~/ELEVATE/data/elevate_cactus_cmes.sav'
  save, assoc_wave_times, filename = '~/ELEVATE/data/assoc_wave_times.sav'

  index = where(php_incl ne '')
  print, transpose(php_incl[index])     ; Simply the php include statement of the row names. 
                                        ; Copy and paste these into ~/ELEVATE/website/soho_erne_table.html
  
END