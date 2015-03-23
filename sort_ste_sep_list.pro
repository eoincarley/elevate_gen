pro sort_ste_sep_list
  
  ;Could not find the actual SEPserver data in text format.
  ;So this is a cleanup of a copy and paste from the web
  
  readcol, 'sta_test.txt', num, date, time, format='A,A,A', delimiter=' '
  
  FOR i=0, n_elements(date)-1 DO BEGIN
    datesplit = STRSPLIT(date[i], '.', /EXTRACT)
    if time[i] eq '-' then time[i] = '12:00:00'
    date[i] = datesplit[2]+'-'+datesplit[1]+'-'+datesplit[0]+' '+$
              time[i]
    date[i] = anytim(date[i], /cc)          
  ENDFOR  
  date = transpose(date[where(time ne '-')])
  openw, 100, 'sta_onset.txt'
  printf, 100, date
  close, 100
  
  
END  