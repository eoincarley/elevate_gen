pro sort_ste_sep_list, input, output
  
  ;Could not find the actual SEPserver data in text format.
  ;So this is a cleanup of a copy and paste from the web
  
  readcol, input, num, date, time, intensity, format='A,A,A,A', delimiter=' '
  
  FOR i=0, n_elements(date)-1 DO BEGIN
    datesplit = STRSPLIT(date[i], '.', /EXTRACT)
    if time[i] eq '-' then time[i] = '12:00:00'
    date[i] = datesplit[2]+'-'+datesplit[1]+'-'+datesplit[0]+' '+$
              time[i]
    date[i] = anytim(date[i], /cc)          
  ENDFOR  
  
  date = transpose(date[where(time ne '-')])
  intensity = transpose(intensity[where(time ne '-')])
  result = strarr(2, n_elements(date))
  result[0, *] = date
  result[1, *] = intensity
  openw, 100, output
  printf, 100, result
  close, 100
  
END  