function pspiral_lons, v_solwind

	; v_solwind should be in meters per second

	radius = 1.5e11		; 1AU in meters
	ang_vel = 2.8e-6	; Angular velocity of the solar equator

	theta = radius*ang_vel/v_solwind
	theta = theta*!radeg

	return, theta	; degrees


END