pro manual_detection_linfit, date, ints, average_window, tonset, $
				onset_times = onset_times, plot_sep = plot_sep


	plot_sep_zoom = "utplot, date, ints, /noerase, /xs, /ys, yr = yzoom, xr=xzoom, /ylog, ytitle = 'Intensity (cm!U-2!N sr!U-1!N s!U-1!N MeV!U-1!N)', xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, /normal"
	print, 'Choose bottom of rise: '
	cursor, t_bottom, i_bottom, /data

	wait, 0.1

	print, 'Choose top of rise: '
	cursor, t_top, i_top, /data

	t_rise_section = date[ where(date gt t_bottom and date lt t_top) ]
	i_rise_section = ints[ where(date gt t_bottom and date lt t_top) ]

	t0_pre = t_bottom - 2.0*60.0*60.0

	t_pre_event = date[ where(date gt t0_pre and date lt t_bottom) ]
	i_pre_event = ints[ where(date gt t0_pre and date lt t_bottom) ]

	imean = mean(i_pre_event)
	isdev = stdev(i_pre_event)

	set_line_color
	window, 3, xs=500, ys=500
	twhole = [t_pre_event, t_rise_section] - t_pre_event[0]
	iwhole = [i_pre_event, i_rise_section]
	plot, twhole, iwhole, $
			/xs, $
			/ys, $
			/ylog

	imeans = twhole
	imeans[*] = imean		

	oplot, twhole, imeans, color=3
	oplot, twhole, imeans + 3.0*isdev, color=5, linestyle=3

	trise = t_rise_section - t_rise_section[0]
	
	result = linfit(trise, alog10(i_rise_section), yfit = yfit)

	t_pre_end = t_pre_event[n_elements(t_pre_event)-1] - t_pre_event[0] 
	oplot, t_pre_end + trise, 10^yfit, color=4


	tsim = ( dindgen(1000)*( trise[n_elements(trise) - 1] - (-60.0*60.0) )/(999) ) + (-60.0*60.0)
	ysim = result[0] + result[1]*tsim
		

	oplot, t_pre_end + tsim, 10^ysim, color=7, linestyle=5

	cross_point = closest(10^ysim, imeans + 3.0*isdev)
	tsim_cross_point = tsim[cross_point]

	tonset = t_rise_section[0] + tsim_cross_point
	print, anytim(tonset, /cc)
END