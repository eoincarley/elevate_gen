pro setup_ps, name, xsize, ysize

    set_plot,'ps'
    !p.font=0
    !p.charsize=1.0
    device, filename = name, $
          ;/decomposed, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=14, $ ;xsize/100, $
          ysize=7, $ ;xsize/100, $
          /encapsulate, $
          bits_per_pixel=32

end

pro stamp_date_nrh, nrh0, nrh1, nrh2, xpos
   
   set_line_color
   !p.charsize = 1.2

   xyouts, xpos-0.0001, 0.87, 'NRH '+string(nrh0.freq, format='(I03)') +' MHz '+anytim(nrh0.date_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 1
   xyouts, xpos+0.0001, 0.87, 'NRH '+string(nrh0.freq, format='(I03)') +' MHz '+anytim(nrh0.date_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 1
   xyouts, xpos, 0.87, 'NRH '+string(nrh0.freq, format='(I03)') +' MHz '+anytim(nrh0.date_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 3
  
   xyouts, xpos-0.0001, 0.84, 'NRH '+string(nrh1.freq, format='(I03)') +' MHz '+anytim(nrh1.date_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 1
   xyouts, xpos+0.0001, 0.84, 'NRH '+string(nrh1.freq, format='(I03)') +' MHz '+anytim(nrh1.date_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 1
   xyouts, xpos, 0.84, 'NRH '+string(nrh1.freq, format='(I03)') +' MHz '+anytim(nrh1.date_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 4

   xyouts, xpos-0.0001, 0.81, 'NRH '+string(nrh2.freq, format='(I03)') +' MHz '+anytim(nrh2.date_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 1    
   xyouts, xpos+0.0001, 0.81, 'NRH '+string(nrh2.freq, format='(I03)') +' MHz '+anytim(nrh2.date_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 1
   xyouts, xpos, 0.81, 'NRH '+string(nrh2.freq, format='(I03)') +' MHz '+anytim(nrh2.date_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 10
END

pro plot_nrh_tri_color, time, freqs, x_size, y_size

    ; plot_nrh_tri_color, '2014-04-18T12:57:57', [6,7,8], 500, 500     

    window, 0, xs=700, ys=700, retain=2
    border = 200.
    folder = '~/Data/2014_sep_01/radio/nrh/clean_wresid/'
    cd, folder
    filenames = findfile('*.fts')
    time = anytim('2014-09-01T10:59:00')     ; For the loop, otherwise comment this out and use input time. 
    time_end = anytim('2014-09-01T11:10:00') ;

    ; Just for the purposes of getting hdr
    t0 = anytim(time, /utim)
    t0str = anytim(t0, /yoh, /trun, /time_only) 
    read_nrh, filenames[freqs[0]], $
        nrh_hdr0, $
        nrh_data0, $
        hbeg=t0str

    min_scl = 0.2   ; Lower intensity scale on image
    max_scl = 0.7   ; Upper intensity scale on image
    CENTER = [-1000, 400] 
    ; 31 pixels per radius. Want to have FOV as 1.3 Rsun (same as AIA). So ~31*1.3 = 40.3
    ; Have 40.3 pixels on either side of image center to have FOV of 1.3 Rsun. 
    rsun_fov = 0.9     
    image_half = (nrh_hdr0.naxis1/2.0)*nrh_hdr0.cdelt1 
    xcen = (CENTER[0]+image_half)/nrh_hdr0.cdelt1  ;nrh_hdr0.crpix1
    ycen = (CENTER[1]+image_half)/nrh_hdr0.cdelt2   ;nrh_hdr0.crpix2
    pix_fov = nrh_hdr0.solar_r*rsun_fov
    map_fov = ( (2.0*rsun_fov*nrh_hdr0.solar_r)*nrh_hdr0.cdelt1 )/60.0
    img_origin = [-1.0*x_size/2, -1.0*y_size/2]
    xpos_labels = 0.15;(x_size+border/4)/(2.0*x_size)+0.01

    i=0.
    while t0 lt time_end do begin
        
        t0 = anytim(time, /utim) + i
        t0str = anytim(t0, /yoh, /trun, /time_only) 

        read_nrh, filenames[freqs[0]], $
            nrh_hdr0, $
            nrh_data0, $
            hbeg=t0str

        read_nrh, filenames[freqs[1]], $
            nrh_hdr1, $
            nrh_data1, $
            hbeg=t0str

        read_nrh, filenames[freqs[2]], $
            nrh_hdr2, $
            nrh_data2, $
            hbeg=t0str

        nrh_roi0 = nrh_data0[0:64, 64:127]
        nrh_roi1 = nrh_data1[0:64, 64:127]
        nrh_roi2 = nrh_data2[0:64, 64:127]
        max_value0 = max(nrh_roi0)
        max_value1 = max(nrh_roi1)
        max_value2 = max(nrh_roi2)
        max_value = max([nrh_roi0, nrh_roi1, nrh_roi2])
        max_val = max_value*max_scl 
        min_val = max_value*min_scl ;> 1e7

        nrh_data0 = nrh_data0 > min_val < max_val 
        nrh_data1 = nrh_data1 > min_val < max_val
        nrh_data2 = nrh_data2 > min_val < max_val 

        truecolorim = [[[nrh_data0]], [[nrh_data1]], [[nrh_data2]]]
        ; Note there is no control here on indices going outside the array range and producing an error.
        truecolorim_zoom = [[[nrh_data0[xcen-pix_fov:xcen+pix_fov, ycen-pix_fov:ycen+pix_fov]]], $
                            [[nrh_data1[xcen-pix_fov:xcen+pix_fov, ycen-pix_fov:ycen+pix_fov]]], $
                            [[nrh_data2[xcen-pix_fov:xcen+pix_fov, ycen-pix_fov:ycen+pix_fov]]]]

        img = congrid(truecolorim, x_size, y_size, 3)
        img_zoom = congrid(truecolorim_zoom, x_size, y_size, 3)

        ;setup_ps, '~/test.eps', x_size+border, y_size+border ;'+string(i - start_index, format='(I03)' )+'.eps', x_size+border, y_size+border
        wset, 0
        loadct, 0, /silent
        plot_image, img_zoom, true=3, $
            position = [border/2, border/2, x_size+border/2, y_size+border/2]/(x_size+border), $
            /normal, $
            xticklen=-0.001, $
            yticklen=-0.001, $
            xtickname=[' ',' ',' ',' ',' ',' ',' '], $
            ytickname=[' ',' ',' ',' ',' ',' ',' ']

          
        index2map, nrh_hdr0, nrh_data0, map0
        data = map0.data 
        data = data < 50.0   ; Juse to make sure the map contours of the dummy map don't sow up.
        map0.data = data
        levels = [100,100,100]

        set_line_color
        plot_map, map0, $
            /cont, $
            levels=levels, $
            ; /noxticks, $
            ; /noyticks, $
            ; /noaxes, $
            thick=2.5, $
            color=1, $
            position = [border/2, border/2, x_size+border/2, y_size+border/2]/(x_size+border), $ 
            /normal, $
            /noerase, $
            /notitle, $
            xticklen=-0.02, $
            yticklen=-0.02, $
            fov = [map_fov, map_fov], $
            center = CENTER         

        plot_helio, nrh_hdr0.date_obs, $
            /over, $
            gstyle=2, $
            gthick=1.5, $  
            gcolor=255, $
            grid_spacing=15.0 

        if i eq 0 then hdr_freqs = [nrh_hdr0.freq, nrh_hdr1.freq, nrh_hdr2.freq]
        if i eq 0 then hdr_freqs = string(hdr_freqs, format='(I03)')
        stamp_date_nrh, nrh_hdr0, nrh_hdr1, nrh_hdr2, xpos_labels

        ;min_tb = string(round(alog10(max_value*0.2)*10.0)/10.0, format='(f3.1)')
        ;max_tb = string(round(alog10(max_value*0.7)*10.0)/10.0, format='(f3.1)')
        ;xyouts, xpos_labels, 0.12, min_tb+' < log!L10!N(T!LB!N [K]) < '+max_tb, /normal, color=1

        x2png, folder + '/image_'+string(i, format='(I04)' )+'.png'

        i = i+1.
        ;device, /close
        ;set_plot, 'x'
    endwhile    
    date = time2file(t0, /date_only)
    freq_string = string(nrh_hdr0.freq, format='(I03)') + '_'+ string(nrh_hdr1.freq, format='(I03)') + '_' +string(nrh_hdr2.freq, format='(I03)')
    spawn, 'ffmpeg -y -r 25 -i image_%04d.png -vb 50M nrh_'+freq_string+'_'+date+'_3col.mpg'
    spawn, 'rm image*.png'

    stop

END