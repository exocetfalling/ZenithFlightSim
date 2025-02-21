extends AeroBody

var force_wing_l : Vector3 = Vector3.ZERO
var force_wing_r : Vector3 = Vector3.ZERO

var force_roll_l : Vector3 = Vector3.ZERO
var force_roll_r : Vector3 = Vector3.ZERO
var force_flap_l : Vector3 = Vector3.ZERO
var force_flap_r : Vector3 = Vector3.ZERO

var force_yawvator_l : Vector3 = Vector3.ZERO
var force_yawvator_r : Vector3 = Vector3.ZERO

var pos_wing_l : Vector3 = Vector3.ZERO
var pos_wing_r : Vector3 = Vector3.ZERO

var pos_roll_l : Vector3 = Vector3.ZERO
var pos_roll_r : Vector3 = Vector3.ZERO
var pos_flap_l : Vector3 = Vector3.ZERO
var pos_flap_r : Vector3 = Vector3.ZERO

var pos_yawvator_l : Vector3 = Vector3.ZERO
var pos_yawvator_r : Vector3 = Vector3.ZERO

var camera_mode : int = 0
var camera_mouse_delta = 0

var ground_contact : bool = true
var ground_contact_NLG = false
var ground_contact_MLG_L = false
var ground_contact_MLG_R = false

var ccip_position: Vector3 = Vector3.ZERO
var ccip_position_local: Vector3 = Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	control_type = 1
	deflection_rate = 1/(PI/3)
#	add_child(LineDrawer)

#	DebugOverlay.stats.add_property(self, "adc_spd", "round")
#	DebugOverlay.stats.add_property(self, "adc_hdg", "round")
#	DebugOverlay.stats.add_property(self, "adc_alt", "round")
#	DebugOverlay.stats.add_property(self, "adc_fpa", "round")
#	DebugOverlay.stats.add_property(self, "adc_trk", "round")
#	DebugOverlay.stats.add_property(self, "adc_stall", "")
	#DebugOverlay.stats.add_property(self, "input_pitch", "round")
#	DebugOverlay.stats.add_property(self, "input_roll", "round")
#	DebugOverlay.stats.add_property(self, "input_yaw", "round")
	#DebugOverlay.stats.add_property(self, "input_throttle", "round")
#	DebugOverlay.stats.add_property(self, "air_pressure_dynamic", "round")
#	DebugOverlay.stats.add_property(self, "output_pitch", "round")
#	DebugOverlay.stats.add_property(self, "output_roll", "round")
#	DebugOverlay.stats.add_property(self, "output_yaw", "round")
#	DebugOverlay.stats.add_property(self, "adc_pitch", "round")
#	DebugOverlay.stats.add_property(self, "tgt_fpa", "round")
#	DebugOverlay.stats.add_property(self, "linear_velocity_local", "round")
#	DebugOverlay.stats.add_property(self, "linear_velocity_total", "")
#	DebugOverlay.stats.add_property(self, "adc_rates", "round")
#	DebugOverlay.stats.add_property(self, "tgt_rates", "round")
#	DebugOverlay.stats.add_property(self, "global_rotation", "")
#	DebugOverlay.stats.add_property(self, "autopilot_on", "round")
#	DebugOverlay.stats.add_property(self, "angle_alpha_deg", "round")
#	DebugOverlay.stats.add_property(self, "angle_alpha_test_deg", "round")
#	DebugOverlay.stats.add_property(self, "camera_mode", "")
#	DebugOverlay.stats.add_property(self, "force_tail_v", "round")
#	DebugOverlay.stats.add_property(self, "force_tail_h", "round")
#	DebugOverlay.stats.add_property(self, "cmd_vector", "round")
#	DebugOverlay.stats.add_property(self, "input_joystick", "round")
#	DebugOverlay.stats.add_property(self, "value_setpoint", "round")
#	DebugOverlay.stats.add_property(self, "value_current", "round")
#	DebugOverlay.stats.add_property(self, "output_P", "round")
#	DebugOverlay.stats.add_property(self, "output_I", "round")
#	DebugOverlay.stats.add_property(self, "output_D", "round")
#	DebugOverlay.stats.add_property(self, "output_total", "round")
#	DebugOverlay.stats.add_property(self, "air_density", "round")
#	DebugOverlay.stats.add_property(self, "adc_alt_radio", "round")
#	linear_velocity_wind = Vector3(5, 0, 0)
	
	pass


# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta): 
	#get_input(delta)
	super(delta)
	
	if (angle_alpha_deg > 15):
		adc_stall = true
	else:
		adc_stall = false
	
	# Panel updates
	$HUDShared.hud_spd = adc_spd_indicated
	$HUDShared.hud_hdg = adc_hdg
	$HUDShared.hud_alt = adc_alt_asl
	$HUDShared.hud_thr = adc_throttle
	
	$HUDShared.hud_pitch = adc_pitch
	$HUDShared.hud_roll = adc_roll
	
	$HUDShared.hud_angle_inertial_x = rad_to_deg(adc_angle_inertial_x)
	$HUDShared.hud_angle_inertial_y = rad_to_deg(adc_angle_inertial_y)
	
	$HUDShared.hud_flaps = input_flaps
	$HUDShared.hud_gear = gear_current
	$HUDShared.hud_trim = output_pitch_trim
	
	$HUDShared.hud_ap_mode = autopilot_on
	
	if (gear_current < gear_input):
		gear_current = gear_current + 0.2 * delta
	if (gear_current > gear_input):
		gear_current = gear_current - 0.2 * delta
	if (abs(gear_current - gear_input) < 0.01):
		gear_current = gear_input
	
#	fbw_output.x = clamp(($PID_Calc_Pitch.calc_PID_output(tgt_rates.x, adc_rates.x, delta)), -1, 1)
	
#	if ((adc_rates.x < tgt_rates.x) && (fbw_output.x < 1)):
#		fbw_output.x += 0.1
#	if ((adc_rates.x > tgt_rates.x) && (fbw_output.x > -1)):
#		fbw_output.x -= 0.1
	$RadioAltimeter.rotation_degrees.x = clamp(-adc_pitch, -30, +30)
	$RadioAltimeter.rotation_degrees.z = clamp(+adc_roll, -30, +30)
	
	# CCIP
	$CCIP.global_position = calc_ccip_pos()
	ccip_position = $CCIP.global_position
	ccip_position_local = $CCIP.position
	
	if ($RadioAltimeter.is_colliding() == true):
		adc_alt_agl = (global_position - $RadioAltimeter.get_collision_point()).length()
	else:
		# Set value to show sensor is out of range
		adc_alt_agl = 9999
	
	if ((autopilot_on == 1) && (adc_alt_agl >= 15)):
		if abs(adc_roll) < 30 && abs(adc_pitch) < 15 && adc_stall == false:
			input_pitch_trim = \
			calc_fcs_gains(air_pressure_dynamic) * \
			( \
			$PIDCalcPitchRate.calc_PID_output(input_joystick.y * 15, adc_rates.x)
			)
			input_yaw += calc_fcs_gains(air_pressure_dynamic) * -0.05 * angle_beta_deg
		else:
			input_pitch_trim = 0
			$PIDCalcPitchRate.integral = 0
		
		
	if (input_pitch_trim > input_trim_pitch_max):
		input_pitch_trim = input_trim_pitch_max
	if (input_pitch_trim < input_trim_pitch_min):
		input_pitch_trim = input_trim_pitch_min
	
	if (output_yaw > 1):
		output_yaw = 1
	if (output_yaw < -1):
		output_yaw = -1
	
	# Thrust forces
	apply_force_local(Vector3(0, 0, -mass * get_gravity().length() /3 * input_throttle), Vector3(0, 0, 0))

	# Clamping
	input_flaps = clamp(input_flaps, flaps_min, flaps_max)
	input_throttle = clamp(input_throttle, throttle_min, throttle_max)
	
	# Gear animations
	$LGPointNLG/StrutLower.position.y = $WheelNLG.position.y + 0.85
	$LGPointMLGLeft/StrutLower.position.y = $WheelMLGLeft.position.y + 0.5
	$LGPointMLGRight/StrutLower.position.y = $WheelMLGRight.position.y + 0.5
	
	$LGPointNLG.rotation.x = (1 - gear_current) * (-PI/2)
	$LGPointMLGLeft.rotation.z = (1 - gear_current) * (+PI/2)
	$LGPointMLGRight.rotation.z = (1 - gear_current) * (-PI/2)

	# Detect ground contact
	if (\
	$WheelNLG.is_in_contact() == true || \
	$WheelMLGLeft.is_in_contact() == true || \
	$WheelMLGRight.is_in_contact() == true
	):
		ground_contact = true
	
	else:
		ground_contact = false
	
	# Move surfaces
	$AileronL.rotation.x = + PI/12 * output_roll
	$AileronR.rotation.x = - PI/12 * output_roll
	
	$FlapL.rotation.x = +PI/6 * output_flaps
	$FlapR.rotation.x = +PI/6 * output_flaps
	
	$RuddervatorL.rotation = \
		Vector3( \
			(-0.1 * (output_pitch + output_pitch_trim + output_yaw)), \
			0, \
			($RuddervatorL.rotation.z) \
			)\
			.rotated(Vector3.FORWARD, \
		-$RuddervatorL.rotation.z)
	
	$RuddervatorR.rotation = \
		Vector3( \
			(-0.1 * (output_pitch + output_pitch_trim - output_yaw)), \
			0, \
			($RuddervatorR.rotation.z) \
			)\
			.rotated(Vector3.FORWARD, \
		-$RuddervatorR.rotation.z)


func get_input(delta):
	# Check if aircraft is under player control
	if (control_type == 1):
			# Throttle input
		if (Input.is_action_pressed("throttle_up")):
			input_throttle += 0.5 * delta 
		if (Input.is_action_pressed("throttle_down")):
			input_throttle -= 0.5 * delta

		# Joystick input as axes
		input_joystick.x = Input.get_axis("roll_left", "roll_right")
		input_joystick.y = Input.get_axis("pitch_down", "pitch_up")
		
		# Yaw input
		input_yaw = Input.get_axis("yaw_left", "yaw_right")
		
		# Flaps input
		if (Input.is_action_just_pressed("flaps_down")):
			input_flaps += 0.25 
		if (Input.is_action_just_pressed("flaps_up")):
			input_flaps -= 0.25

		# Trim input
		
		if (Input.is_action_pressed("trim_pitch_up")):
			input_pitch_trim += 0.2 * delta 
		if (Input.is_action_pressed("trim_pitch_down")):
			input_pitch_trim -= 0.2 * delta 

		# Gear input
		if (Input.is_action_just_pressed("gear_toggle")):
		
			if (gear_input == 0):
				gear_input = 1
			else:
				gear_input = 0
		
		# AP input
		if (Input.is_action_just_pressed("autopilot_toggle")):
			if (autopilot_on == 0):
				autopilot_on = 1
				tgt_pitch = adc_pitch
				output_yaw_damper = 0
			else:
				autopilot_on = 0
				output_yaw_damper = 0

		# Braking input
		input_braking = Input.get_action_strength("braking")
		brake = input_braking * 50
		
		# NWS input
		steering = -0.5 * _nosewheel_gains(linear_velocity_total) * output_yaw
		
		# Cameras
		if (Input.is_action_just_pressed("camera_toggle")):
			camera_mode = camera_mode + 1
		if (camera_mode == 0):
			$CameraFPV.current = true
			$HUDShared.visible = true
		if (camera_mode == 1):
			$CameraExt.current = true
			$HUDShared.visible = false
		if (camera_mode > 1):
			camera_mode = 0
		
		
		if (Input.is_action_just_pressed("nav_mode_toggle")):
			if (AeroDataBus.aircraft_nav_active == false): 
				AeroDataBus.aircraft_nav_active = true
			else:
				AeroDataBus.aircraft_nav_active = false


# NWS gains
func _nosewheel_gains(speed):
	var speed_1 = 5
	var speed_2 = 40
	
	var gain_1 = 1
	var gain_2 = 0
	
	if (speed < speed_1):
		return gain_1
	elif ((speed > speed_1) && (speed < speed_2)):
		return ((gain_2 - gain_1) / (speed_2 - speed_1)) * (speed - speed_1) + gain_1
	else:
		return 0


func calc_ccip_pos():
	var ccip_velocity: Vector3 = Vector3.ZERO
	var ccip_position: Vector3 = Vector3.ZERO
	var ccip_tof: float = 0
	
	ccip_velocity.y = -sqrt(pow(linear_velocity.y, 2) + 2 * (-9.81) * -adc_alt_agl)
	ccip_tof = (ccip_velocity.y - linear_velocity.y) / (-9.81)
	ccip_position.y = global_position.y - adc_alt_agl
	ccip_position.x = global_position.x + linear_velocity.x * ccip_tof
	ccip_position.z = global_position.z + linear_velocity.z * ccip_tof
	
	return ccip_position
