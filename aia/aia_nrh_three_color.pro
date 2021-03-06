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

pro stamp_date_aia, i_a, i_b, i_c
   set_line_color
   !p.charsize = 1.8

   xyouts, 0.02, 0.07, 'AIA '+string(i_a.wavelnth, format='(I03)') +' A '+anytim(i_a.t_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 0, charthick=2
   xyouts, 0.02, 0.07, 'AIA '+string(i_a.wavelnth, format='(I03)') +' A '+anytim(i_a.t_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 3
   
   xyouts, 0.02, 0.045, 'AIA '+string(i_b.wavelnth, format='(I03)') +' A '+anytim(i_b.t_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 0, charthick=2
   xyouts, 0.02, 0.045, 'AIA '+string(i_b.wavelnth, format='(I03)') +' A '+anytim(i_b.t_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 10
   
   xyouts, 0.02, 0.02, 'AIA '+string(i_c.wavelnth, format='(I03)') +' A '+anytim(i_c.t_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 0, charthick=2
   xyouts, 0.02, 0.02, 'AIA '+string(i_c.wavelnth, format='(I03)') +' A '+anytim(i_c.t_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 4
END

pro stamp_date_nrh, nrh0, nrh1, nrh2
   set_line_color
   !p.charsize = 1.8

   xyouts, 0.52, 0.07, 'NRH '+string(nrh0.freq, format='(I03)') +' MHz '+anytim(nrh0.date_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 0, charthick=1
   xyouts, 0.52, 0.07, 'NRH '+string(nrh0.freq, format='(I03)') +' MHz '+anytim(nrh0.date_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 3
   
   xyouts, 0.52, 0.045, 'NRH '+string(nrh1.freq, format='(I03)') +' MHz '+anytim(nrh1.date_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 0, charthick=1
   xyouts, 0.52, 0.045, 'NRH '+string(nrh1.freq, format='(I03)') +' MHz '+anytim(nrh1.date_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 10
   
   xyouts, 0.52, 0.02, 'NRH '+string(nrh2.freq, format='(I03)') +' MHz '+anytim(nrh2.date_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 0, charthick=1
   xyouts, 0.52, 0.02, 'NRH '+string(nrh2.freq, format='(I03)') +' MHz '+anytim(nrh2.date_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 4
END

pro plot_nrh_tri_color, time, freqs, x_size, y_size, $
         hdr_freqs = hdr_freqs

   ;x_size = 8.*128
   ;y_size = 8.*128

   t0 = anytim(time, /utim)

   t0str = anytim(t0, /yoh, /trun, /time_only)

   cd, '~/Data/2014_apr_18/radio/nrh/'
   filenames = findfile('*.fts')


   read_nrh, filenames[freqs[0]], $
         nrh_hdr0, $
         nrh_data0, $
         hbeg=t0str;, $ 
         ;hend=t1str

   read_nrh, filenames[freqs[1]], $
         nrh_hdr1, $
         nrh_data1, $
         hbeg=t0str

   read_nrh, filenames[freqs[2]], $
         nrh_hdr2, $
         nrh_data2, $
         hbeg=t0str

   max_value0 = max(nrh_data0)
   max_value1 = max(nrh_data1)
   max_value2 = max(nrh_data2)

   max_value = max([nrh_data0, nrh_data1, nrh_data2])

   nrh_data0 = nrh_data0 > max_value*0.3 < max_value*0.7
   nrh_data1 = nrh_data1 > max_value*0.3 < max_value*0.7
   nrh_data2 = nrh_data2 > max_value*0.3 < max_value*0.7 

   xcen = nrh_hdr0.crpix1
   ycen = nrh_hdr0.crpix2

   truecolorim = [[[nrh_data0]], [[nrh_data1]], [[nrh_data2]]]

   ; 31 pixels per radius. Want to have FOV as 1.3 Rsun (same as AIA). So ~31*1.3 = 40.3
   ; Have 40.3 pixels on either side of image center to have FOV of 1.3 Rsun. 

   pix_fov = nrh_hdr0.solar_r*1.4

   truecolorim_zoom = [[[nrh_data0[xcen-pix_fov:xcen+pix_fov, ycen-pix_fov:ycen+pix_fov]]], $
                       [[nrh_data1[xcen-pix_fov:xcen+pix_fov, ycen-pix_fov:ycen+pix_fov]]], $
                       [[nrh_data2[xcen-pix_fov:xcen+pix_fov, ycen-pix_fov:ycen+pix_fov]]]]

   img_origin = [-1.0*x_size/2, -1.0*y_size/2]

   img = congrid(truecolorim, x_size, y_size, 3)
   im_zoom = congrid(truecolorim_zoom, x_size, y_size, 3)

   xposition = x_size+40
   expand_tv, im_zoom, x_size, y_size, xposition, 10, true = 3, origin = img_origin, /data

   naxis1 = pix_fov*2.0
   naxis2 = pix_fov*2.0

   pixrad = (1.0d*x_size/naxis1)*nrh_hdr0.solar_r
   xcen = (1.0d*x_size/naxis1)*(naxis1/2.0)
   ycen = (1.0d*x_size/naxis2)*(naxis2/2.0)
   tvcircle, pixrad, xcen+xposition, ycen+10, /device

   index2map, nrh_hdr0, nrh_data0, map0
   mapb0 = map0.b0
   maprsun = nrh_hdr0.solar_r
   mapl0 = map0.l0

   plot_helio, nrh_hdr0.date_obs, grid=15, /over, b0=mapb0, rsun=pixrad, l0=mapl0, gthick=2

   stamp_date_nrh, nrh_hdr0, nrh_hdr1, nrh_hdr2
   hdr_freqs = [nrh_hdr0.freq, nrh_hdr1.freq, nrh_hdr2.freq]
   hdr_freqs = string(hdr_freqs, format='(I03)')

   date = time2file(t0, /date_only)
   freq_string = string(nrh_hdr0.freq, format='(I03)') + '_'+ string(nrh_hdr1.freq, format='(I03)') + '_' +string(nrh_hdr2.freq, format='(I03)')


END


;--------------------------------------------------------------------;
;
; Routine to plot three-color AIA images. From code by Paolo Grigis.
;
;--------------------------------------------------------------------;

pro aia_nrh_three_color, date = date, mssl = mssl, xwin = xwin, zoom=zoom, parallelise=parallelise, winnum=winnum
     
   pass_a = '211'
   pass_b = '193'
   pass_c = '171'

   folder = '~/Data/elevate_db/'+date+'/SDO/AIA'
   ;folder = '~/Data/'+date+'/sdo'

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
     x_size = 700
     y_size = 700
   endelse

   ; Check the images to make sure we're not using AEC-affected images
   min_exp_t_193 = 1.0
   min_exp_t_211 = 1.5
   min_exp_t_171 = 1.5

   read_sdo, fls_a, i_a, /nodata, only_tags='exptime,date-obs', /mixed_comp, /noshell
   f_a = fls_a[where(i_a.exptime gt min_exp_t_211)]
   t = anytim(i_a.date_d$obs)
   t211 = anytim(i_a.date_d$obs)
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

   if f_min eq f_max then begin
         max_tim = t_str_a
         mid_tim = t_str_b
         min_tim = t_str_c
   endif else begin
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
   endelse


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

   if f_min eq f_max then begin
         loc_211 = next_max_im
         loc_193 = next_mid_im
         loc_171 = next_min_im
   endif else begin
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
   endelse  

   fls_211 = f_a[loc_211]
   fls_193 = f_b[loc_193]
   fls_171 = f_c[loc_171]

   ; Setup plotting parameters  
   if keyword_set(xwin) then begin
      window, winnum, xs = x_size + x_size+60.0, ys = y_size+20, retain=2
      !p.multi = 0
   endif else begin     
      set_plot, 'z'
      !p.multi = 0
      img = fltarr(3, x_size, y_size)
      device, set_resolution = [x_size, y_size], set_pixel_depth=24, decomposed=0
   endelse

   read_sdo, fls_211, hdr_aia, /nodata, only_tags='date-obs', /mixed_comp, /noshell
   tims_aia = anytim(hdr_aia.date_d$obs)
   index_start = closest(tims_aia, anytim('2014-04-18T12:48', /utim))
   index_stop = closest(tims_aia, anytim('2014-04-18T13:15', /utim))

  
   image_index = 0
   for i = index_start, index_stop do begin
      
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
         aia_process_image, fls_211[i], fls_211[i-5], i_a, i_a_pre, iscaled_a, xsize=x_size, /nrgf
         aia_process_image, fls_193[i], fls_193[i-5], i_b, i_b_pre, iscaled_b, xsize=x_size, /nrgf
         aia_process_image, fls_171[i], fls_171[i-5], i_c, i_c_pre, iscaled_c, xsize=x_size, /nrgf
      ENDELSE
     
      ; Check that the images are closely spaced in time
      if (abs(anytim(i_a.date_d$obs)-anytim(i_b.date_d$obs)) or $
          abs(anytim(i_a.date_d$obs)-anytim(i_c.date_d$obs)) or $
          abs(anytim(i_b.date_d$obs)-anytim(i_c.date_d$obs))) gt 12. then goto, skip_img

      truecolorim = [[[iscaled_a]], [[iscaled_b]], [[iscaled_c]]]

      undefine, iscaled_a
      undefine, iscaled_b
      undefine, iscaled_c

      if keyword_set(zoom) then $
        img = congrid(truecolorim[x_range[0]:x_range[1],y_range[0]:y_range[1], *], x_size, y_size, 3) else $
           img = congrid(truecolorim, x_size, y_size, 3)

      undefine, truecolorim
      
      aia_prep, fls_211[i], -1, i_0, d_0, /uncomp_delete, /norm
      index2map, i_0, d_0, map0
      mapb0 = map0.b0
      maprsun = map0.rsun
      mapl0 = map0.l0


      img_origin = [-1.0*x_size/2 - mapb0, -1.0*y_size/2]
      expand_tv, img, x_size, y_size, 10, 10, true = 3, origin =img_origin, /data

      undefine, map0
      undefine, map
   
      pixrad = (1.0d*x_size/i_a.naxis1/2)*i_a.r_sun      ;Use divide by 2 here because nrgf uses 2048 image to cut down on computation time.
      xcen = (1.0d*x_size/i_a.naxis1)*i_a.crpix1
      ycen = (1.0d*x_size/i_a.naxis2)*i_a.crpix2
      tvcircle, pixrad, xcen+10, ycen+10, /device

      plot_helio, i_0[0].date_d$obs, grid=15, /over, b0=mapb0, rsun=pixrad, l0=mapl0, gthick=2

      stamp_date_aia, i_a, i_b, i_c

      ;--------------------------------------------;
      ;         Plot NRH three colour
      ;
      plot_nrh_tri_color, i_a.t_obs, [0,4,8], x_size, y_size, $
                     hdr_freqs = hdr_freqs
      ;
      ;
      ;--------------------------------------------;

      if ~keyword_set(xwin) then begin
      	image_loc_name = '~/Data/2014_apr_18/image_'+string(image_index, format='(I03)' )+'.png' 
   	   write_png, image_loc_name, img
      endif else x2png, '~/Data/2014_apr_18/image_'+string(image_index, format='(I03)' )+'.png'
	      
      image_index = image_index + 1
      ; If images too far apart in time then go to here.
      skip_img:

      ; Indicate progress
      get_utc, end_loop_t, /cc
      loop_time = anytim(end_loop_t, /utim) - anytim(start_loop_t, /utim)
      box_message, str2arr('Currently '+string(loop_time, format='(I04)') + ' s per 3 color image.')
      progress_percent, i, index_start, index_stop

   endfor

   date = time2file(i_a.t_obs, /date_only)
   movie_type = '3col_ratio' ;else movie_type = '3col_ratio'
   cd, '~/Data/2014_apr_18/'
   print, folder
   spawn, 'ffmpeg -y -r 25 -i image_%03d.png -vb 50M AIA_NRH_'+hdr_freqs[0]+'_'+hdr_freqs[1]+'_'+hdr_freqs[2]+'_scl3.mpg'
   ;spawn, 'rm -f image*.png'

END
