pro return_struct, bridge, struct_name, struct

      ; IDL bridges cannot pass structures I/O. This procedure works around that.

      tag_namess = bridge->GetVar('tag_names('+struct_name+')') 
      first_val = bridge->GetVar(struct_name+'.(0)')
      first_tag = tag_namess[0]
      struct = CREATE_STRUCT(NAME=struct_name, first_tag, first_val)
      for i =1, n_elements(tag_namess)-2 do begin
         append_name = tag_namess[i]
         append_value = bridge->GetVar(struct_name+".("+strcompress(string(i), /remove_all)+")")
         struct = CREATE_STRUCT(struct, append_name, append_value)
      endfor

END

pro stamp_date, i_a, i_b, i_c
   set_line_color
   !p.charsize = 1.8

   xyouts, 0.02, 0.06, 'AIA '+string(i_a.wavelnth, format='(I03)') +' A '+anytim(i_a.t_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 0, charthick=4
   xyouts, 0.02, 0.06, 'AIA '+string(i_a.wavelnth, format='(I03)') +' A '+anytim(i_a.t_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 3
   
   xyouts, 0.02, 0.04, 'AIA '+string(i_b.wavelnth, format='(I03)') +' A '+anytim(i_b.t_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 0, charthick=4
   xyouts, 0.02, 0.04, 'AIA '+string(i_b.wavelnth, format='(I03)') +' A '+anytim(i_b.t_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 10
   
   xyouts, 0.02, 0.02, 'AIA '+string(i_c.wavelnth, format='(I03)') +' A '+anytim(i_c.t_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 0, charthick=4
   xyouts, 0.02, 0.02, 'AIA '+string(i_c.wavelnth, format='(I03)') +' A '+anytim(i_c.t_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 4
END

;--------------------------------------------------------------------;
;
; Routine to plot three-color AIA images. From code by Paolo Grigis.
;
;--------------------------------------------------------------------;

pro aia_three_color, date = date, mssl = mssl, xwin = xwin, zoom=zoom, parallelise=parallelise, winnum=winnum
     
   pass_a = '211'
   pass_b = '193'
   pass_c = '171'

   folder = '~/Data/elevate_db/'+date+'/SDO/AIA'

   file_loc_211 = folder + '/211'
   file_loc_193 = folder + '/193'
   file_loc_171 = folder + '/171'

   fls_a = file_search( file_loc_211 +'/*.fits' )
   fls_b = file_search( file_loc_193 +'/*.fits' )
   fls_c = file_search( file_loc_171 +'/*.fits' )


   if keyword_set(zoom) then begin
      ;     x_range = [800, 3000]
      ;     y_range = [500, 2000]
      x_range = [2047, 4095]     ; 20110607
      y_range = [512, 2560]      ; 20110607
      ;     pix_range_x = [1000, 1600] ; 20120307
      ;     pix_range_y = [2400, 3000] ; 20120307
      if (x_range[1]-x_range[0]) gt 1024 or (y_range[1]-y_range[0]) gt 1024 then begin
         if (x_range[1]-x_range[0]) ge (y_range[1]-y_range[0]) then begin
            x_size = 1024
            y_size = round(1024*(float(y_range[1]-y_range[0])/float(x_range[1]-x_range[0])))
         endif
         if (x_range[1]-x_range[0]) lt (y_range[1]-y_range[0]) then begin
            y_size = 1024
            x_size = round(1024*(float(x_range[1]-x_range[0])/float(y_range[1]-y_range[0])))
         endif
      endif else begin
         x_size = (x_range[1]-x_range[0])
         y_size = (y_range[1]-y_range[0])
      endelse        

   endif else begin
     x_range = [0, 4095]
     y_range = [0, 4095]
     x_size = 1024
     y_size = 1024
   endelse

   ; Check the images to make sure we're not using AEC-affected images
   min_exp_t_193 = 1.0
   min_exp_t_211 = 1.5
   min_exp_t_171 = 1.5

   read_sdo, fls_a, i_a, /nodata, only_tags='exptime,date-obs', /mixed_comp, /noshell
   f_a = fls_a[where(i_a.exptime gt min_exp_t_211)]
   t = anytim(i_a.date_d$obs)
   t_a = t[where(i_a.exptime gt min_exp_t_211)]

   read_sdo, fls_b, i_b, /nodata, only_tags='exptime,date-obs', /mixed_comp, /noshell
   f_b = fls_b[where(i_b.exptime gt min_exp_t_193)]
   t = anytim(i_b.date_d$obs)
   t_b = t[where(i_b.exptime gt min_exp_t_193)]

   read_sdo, fls_c, i_c, /nodata, only_tags='exptime,date-obs', /mixed_comp, /noshell
   f_c = fls_c[where(i_c.exptime gt min_exp_t_171)]
   t = anytim(i_c.date_d$obs)
   t_c = t[where(i_c.exptime gt min_exp_t_171)]

   t_str_a = anytim(t_a)
   t_str_b = anytim(t_b)
   t_str_c = anytim(t_c)

   ; Now identify images adjacent in time using the smallest array to get
   ; the image times
   arrs = [n_elements(f_a), n_elements(f_b), n_elements(f_c)]
   val = max(arrs, f_max, subscript_min = f_min)
   n_array = [0,1,2]


   case f_min of
      0: image_time = t_a
      1: image_time = t_b
      2: image_time = t_c
   endcase

   f_mid = n_array[where(n_array ne f_max and n_array ne f_min)]

   case f_max of
      0: max_tim = t_str_a
      1: max_tim = t_str_b
      2: max_tim = t_str_c
   endcase
   case f_min of
      0: min_tim = t_str_a
      1: min_tim = t_str_b
      2: min_tim = t_str_c
   endcase
   case f_mid of
      0: mid_tim = t_str_a
      1: mid_tim = t_str_b
      2: mid_tim = t_str_c
   endcase


   ; This loop finds the closest file to min_tim[n] for each of the filters. It constructs an
   ; array of indices for each of the filters.
   for n = 0, n_elements(min_tim)-1 do begin
      sec_min = min(abs(min_tim - min_tim[n]),loc_min)
      if n eq 0 then next_min_im = loc_min else next_min_im = [next_min_im, loc_min]

      sec_max = min(abs(max_tim - min_tim[n]),loc_max)
      if n eq 0 then next_max_im = loc_max else next_max_im = [next_max_im, loc_max]

      sec_mid = min(abs(mid_tim - min_tim[n]),loc_mid)
      if n eq 0 then next_mid_im = loc_mid else next_mid_im = [next_mid_im, loc_mid]
   endfor

   case f_max of
      0: loc_211 = next_max_im
      1: loc_193 = next_max_im
      2: loc_171 = next_max_im
   endcase
   case f_mid of
      0: loc_211 = next_mid_im
      1: loc_193 = next_mid_im
      2: loc_171 = next_mid_im
   endcase
   case f_min of
      0: loc_211 = next_min_im
      1: loc_193 = next_min_im
      2: loc_171 = next_min_im
   endcase

   fls_211 = f_a[loc_211]
   fls_193 = f_b[loc_193]
   fls_171 = f_c[loc_171]

   ; Setup plotting parameters  
   if keyword_set(xwin) then begin
      window, winnum, xs = x_size, ys = y_size, retain=2
      !p.multi = 0
   endif else begin     
      set_plot, 'z'
      !p.multi = 0
      img = fltarr(3, x_size, y_size)
      device, set_resolution = [x_size, y_size], set_pixel_depth=24, decomposed=0
   endelse

   lwr_lim = 5

   for i = lwr_lim, n_elements(fls_211) - 1 do begin
      
      get_utc, start_loop_t, /cc
      
      IF keyword_set(parallelise) THEN BEGIN
         ;---------- Run processing of three images in parallel using IDL bridges ------------;
         pref_set, 'IDL_STARTUP', '/Users/eoincarley/idl/.idlstartup',/commit             
         oBridge1 = OBJ_NEW('IDL_IDLBridge', output='/Users/eoincarley/child1_output.txt') 
         oBridge1->EXECUTE, '@' + PREF_GET('IDL_STARTUP')   ;Necessary to define startup file because child process has no memory of ssw_path of parent process
         oBridge1->SetVar, 'fls_211', fls_211
         oBridge1->SetVar, 'fls_193', fls_193
         oBridge1->SetVar, 'fls_171', fls_171
         oBridge1->SetVar, 'i', i

         oBridge2 = OBJ_NEW('IDL_IDLBridge')
         oBridge2->EXECUTE, '@' + PREF_GET('IDL_STARTUP')
         oBridge2->SetVar, 'fls_211', fls_211
         oBridge2->SetVar, 'fls_193', fls_193
         oBridge2->SetVar, 'fls_171', fls_171
         oBridge2->SetVar, 'i', i

         oBridge3 = OBJ_NEW('IDL_IDLBridge')
         oBridge3->EXECUTE, '@' + PREF_GET('IDL_STARTUP') 
         oBridge3->SetVar, 'fls_211', fls_211
         oBridge3->SetVar, 'fls_193', fls_193
         oBridge3->SetVar, 'fls_171', fls_171
         oBridge3->SetVar, 'i', i
         
         oBridge1 -> Execute, 'aia_process_image, fls_211[i], fls_211[i-5], i_a, i_a_pre, iscaled_a, xsize=x_size', /nowait

         oBridge2 -> Execute, 'aia_process_image, fls_193[i], fls_193[i-5], i_b, i_b_pre, iscaled_b, xsize=x_size', /nowait

         oBridge3 -> Execute, 'aia_process_image, fls_171[i], fls_171[i-5], i_c, i_c_pre, iscaled_c, xsize=x_size', /nowait

         print, 'Waiting for child processes to finish.'
         WHILE (oBridge1->Status() EQ 1 or oBridge2->Status() EQ 1 or oBridge3->Status() EQ 1) DO BEGIN
            junk=1
         ENDWHILE
   
         return_struct, oBridge1, 'i_a', i_a
         return_struct, oBridge2, 'i_b', i_b
         return_struct, oBridge3, 'i_c', i_c

         iscaled_a = oBridge1->GetVar('iscaled_a')
         iscaled_b = oBridge2->GetVar('iscaled_b')
         iscaled_c = oBridge3->GetVar('iscaled_c')

      ENDIF ELSE BEGIN
         aia_process_image, fls_211[i], fls_211[i-5], i_a, i_a_pre, iscaled_a, xsize=x_size;, /nrgf
         aia_process_image, fls_193[i], fls_193[i-5], i_b, i_b_pre, iscaled_b, xsize=x_size;, /nrgf
         aia_process_image, fls_171[i], fls_171[i-5], i_c, i_c_pre, iscaled_c, xsize=x_size;, /nrgf
      ENDELSE
     
      ; Check that the images are closely spaced in time
      if (abs(anytim(i_a.date_d$obs)-anytim(i_b.date_d$obs)) or $
          abs(anytim(i_a.date_d$obs)-anytim(i_c.date_d$obs)) or $
          abs(anytim(i_b.date_d$obs)-anytim(i_c.date_d$obs))) gt 12. then goto, skip_img

      truecolorim = [[[iscaled_a]], [[iscaled_b]], [[iscaled_c]]]

      if keyword_set(zoom) then $
        img = congrid(truecolorim[x_range[0]:x_range[1],y_range[0]:y_range[1], *], x_size, y_size, 3) else $
           img = rebin(truecolorim, x_size, y_size, 3)

      expand_tv, img, x_size, y_size, 0, 0, true = 3;, min = -3.0, max = 3.0;, origin=img_origin, scale=img_scale, /data
      ;if keyword_set(grid) then plot_helio, i_a1[0].date_d$obs, grid=15, /over, b0=map.b0, rsun=map.rsun, l0=map.l0, gthick=thicky

      pixrad = (1.0d*x_size/i_a.naxis1)*i_a.r_sun
      xcen = (1.0d*x_size/i_a.naxis1)*i_a.crpix1
      ycen = (1.0d*x_size/i_a.naxis2)*i_a.crpix2
      tvcircle, pixrad, xcen, ycen, /device

      stamp_date, i_a, i_b, i_c

      if ~keyword_set(xwin) then begin
         img = tvrd(/true)
         write_png, 'SDO_3col_plain_'+time2file(i_a.t_obs, /sec)+'.png', img   
      endif else x2png, folder + '/image_'+string(i-5, format='(I03)' )+'.png'
	      
      ; If images too far apart in time then go to here.
      skip_img:

      get_utc, end_loop_t, /cc
      loop_time = anytim(end_loop_t, /utim) - anytim(start_loop_t, /utim)
      print,'-------------------'
      print,'Currently '+string(loop_time, format='(I04)')+' seconds per 3 color image.'
      print,'-------------------'

   endfor

   date = time2file(i_a.t_obs, /date_only)
   movie_type = '3col_ratio_nrgf' ;else movie_type = '3col_ratio'
   cd, folder
   print, folder
   spawn, 'ffmpeg -y -r 25 -i image_%03d.png -vb 50M SDO_AIA_'+date+'_'+movie_type+'.mpg'


   spawn, 'cp SDO_AIA_'+date+'_'+movie_type+'.mpg ~/Dropbox/sdo_movies/'
   ;spawn, 'cp image_000.png ~/Dropbox/sdo_movies/'
   spawn, 'rm -f image*.png'


END
