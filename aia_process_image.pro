pro aia_process_image, img_name, img_pre_name, hdr, hdr_pre, $
         iscaled_img, xsize=xsize, nrgf=nrgf, $
         total_b = total_b, ratio = ratio

      ; This is a simple routine to process AIA images. It belonged to
      ; aia_three_color_eoin, but in order for IDL bridge to run it, 
      ; it needed to be an external procesure   
      
      ;read_sdo, img_name, hdr, img, outsize=2048 ; /nodata, only_tags='exptime,date-obs', /mixed_comp, /noshell 
      ;read_sdo, img_pre_name, hdr_pre, img_pre, outsize=2048

      aia_prep, img_pre_name, -1, hdr_pre, img_pre, /uncomp_delete, /norm
      aia_prep, img_name, -1, hdr, img, /uncomp_delete, /norm

      ;img_pre = img_pre/hdr_pre.exptime
      ;img = img/hdr.exptime

      if keyword_set(nrgf) then begin
         iscaled_img = img/img_pre
         undefine, img
         undefine, img_pre
         read_sdo, img_name, hdr, junk, outsize=2048
         iscaled_img = rebin(iscaled_img, 2048, 2048)
         remove_nans, iscaled_img, iscaled_img, /return_img
         iscaled_img = disk_nrgf_3col_ratio(iscaled_img, hdr, 0, 0, rsub = rsub, rgt=rgt)
         iscaled_img[rsub] = iscaled_img[rsub]*5.0 > (-3.0) < 5.0   
         iscaled_img[rgt] = iscaled_img[rgt] > (-5.0) < 4.0 
      endif 

      if keyword_set(total_b) then begin
         iscaled_img = img
         undefine, img
         undefine, img_pre
         iscaled_img = ( iscaled_img - mean(iscaled_img) ) /stdev(iscaled_img)   
         iscaled_img = iscaled_img > (-2.5) < 8 
      endif   

      if keyword_set(ratio) then begin
         iscaled_img = img/img_pre
         undefine, img
         undefine, img_pre
         iscaled_img = rebin(iscaled_img, 2048, 2048)
         iscaled_img = iscaled_img >0.85 <1.1 ;    ;0.85, 1.1 for ratio image
         iscaled_img =smooth(iscaled_img, 5)
      endif   

 

END
