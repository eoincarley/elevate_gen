pro setup_ps, name
  
   set_plot, 'ps'
   !p.font=0
   !p.charsize=1.0
   device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=10, $
          ysize=6, $
          bits_per_pixel=16, $
          /encapsulate, $
          yoffset=5

end

pro radio_summary_plot, date, time_range, freq_range, $
						orfees=orfees, dam=dam, learmonth=learmonth, $
						culgoora=culgoora, waves=waves, swaves=swaves, $
						callisto=callisto

	;+
    ;
    ;NAME:
    ;   radio_summary_plot
    ;
    ;PROJECT:
    ;   ELEVATE Catalogue
    ;
    ;PURPOSE:
   	;  This is an attempt to generalise a radio spectrogram summary plot.
	;  Choose times and frequencies and choose instruments to use.
    ;
    ;CALLING SEQUENCE:
    ;      radio_summary_plot, date, [time0, time1], [freq0, freq1]
    ;      e.g., radio_summary_plot, '2013-04-11', ['00:00:00', '12:00:00'], [1., 1000.]
    ;
    ;INPUT:
    ;       date: Date folder in the elevate catalgoue e.g., 2013-04-11.
    ;		time_range: Time range to be plot. Time format is YYYY-MM-DDTHH:MM:SS
    ;		freq_range: Frequency range to be plot. Frequency in MHz.
    ;
    ;KEYWORDS:
    ;       Name the instrument to be plotted.
    ;
    ;HISTORY:
    ;     2015: Written by Eoin Carley
    ;     2016-March-23: Cleanup, Eoin Carley. 
    ; 
    ;-

    ; Define named variables
    folder = '~/Data/2015_nov_04/radio/'
    time0 = date+'T'+time_range[0]
    time1 = date+'T'+time_range[1]
    time0 = anytim(time0, /utim)
	time1 = anytim(time1, /utim)
	freq0 = freq_range[0]
	freq1 = freq_range[1]
	
	;------------------------------------;
	;			Window params			 ; 	
	;									 ;
	if keyword_set(postscript) then begin 
		setup_ps, folder+'/radio_summary_'+date+'.eps'
	endif else begin
		loadct, 74
		reverse_ct
		window, 0, xs=1000, ys=600, retain=2
		!p.charsize=1.5
		!p.thick=1
		!x.thick=1
		!y.thick=1
	endelse	

	utplot, [time0, time1], [freq1, freq0], $
			/xs, $
			/ys, $
			/nodata, $
			/ylog, $
			yr = [ freq1, freq0 ],  $
	  		xrange = [ time0, time1 ], $
			ytitle='Frequency (MHz)', $
			position = [0.15, 0.15, 0.94, 0.94], $
			xticklen = -0.012, $
			yticklen = -0.015
		
	;-----------------------------------;
	;	 Plot Culgoora and Learmonth
	;
	if keyword_set(culgoora) then culgoora_plot, folder+'/culgoora/', $
			time0, time1, freq0, freq1	

	if keyword_set(learmonth) then learmonth_plot, folder+'/learmonth/', $
			time0, time1, freq0, freq1		

	;-------------------------;
	;	Plot Orfees and DAM
	;
	if keyword_set(orfees) then orfees_plot, folder+'/orfees/', $
							time0, time1, freq0, freq1	

	if keyword_set(dam) then dam_plot, folder+'/dam/', $
			                time0, time1, freq0, freq1			

	;-------------------------;
	;	Plot WIND/WAVES
	;
	if keyword_set(waves) then waves_plot, folder+'/waves/', 'R1', $
						time0, time1, freq0, freq1;, scl1=-0.1, scl2=0.8

	if keyword_set(waves) then waves_plot, folder+'/waves/', 'R2', $
						time0, time1, freq0, freq1;, scl1=-0.1, scl2=0.8
					

	;-----------------------------------;
	;		 Plot Callistos
	;
	;callisto_plot, 'BLEN', time0, time1, freq0, freq1
	;callisto_plot, 'MRT', time0, time1, freq0, freq1
	;callisto_plot, 'GAURI', time0, time1, freq0, freq1		

	if keyword_set(postscript) then begin 
		device, /close
		set_plot, 'x'
	endif			

END