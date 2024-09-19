extends AeroBody

var force_wing_l : Vector3 = Vector3.ZERO
var force_wing_r : Vector3 = Vector3.ZERO

var force_aileron_l : Vector3 = Vector3.ZERO
var force_aileron_r : Vector3 = Vector3.ZERO
var force_flap_l : Vector3 = Vector3.ZERO
var force_flap_r : Vector3 = Vector3.ZERO

var force_ruddervator_l : Vector3 = Vector3.ZERO
var force_ruddervator_r : Vector3 = Vector3.ZERO

var pos_wing_l : Vector3 = Vector3.ZERO
var pos_wing_r : Vector3 = Vector3.ZERO

var pos_aileron_l : Vector3 = Vector3.ZERO
var pos_aileron_r : Vector3 = Vector3.ZERO
var pos_flap_l : Vector3 = Vector3.ZERO
var pos_flap_r : Vector3 = Vector3.ZERO

var pos_ruddervator_l : Vector3 = Vector3.ZERO
var pos_ruddervator_r : Vector3 = Vector3.ZERO

var camera_mode : int = 0
var camera_mouse_delta = 0

var ground_contact : bool = true
var ground_contact_NLG = false
var ground_contact_MLG_L = false
var ground_contact_MLG_R = false


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
	DebugOverlay.stats.add_property(self, "input_elevator", "round")
#	DebugOverlay.stats.add_property(self, "input_aileron", "round")
#	DebugOverlay.stats.add_property(self, "input_rudder", "round")
	DebugOverlay.stats.add_property(self, "input_throttle", "round")
#	DebugOverlay.stats.add_property(self, "air_pressure_dynamic", "round")
#	DebugOverlay.stats.add_property(self, "output_elevator", "round")
#	DebugOverlay.stats.add_property(self, "output_aileron", "round")
#	DebugOverlay.stats.add_property(self, "output_rudder", "round")
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
	
	
	if ($RadioAltimeter.is_colliding() == true):
		adc_alt_agl = (global_position - $RadioAltimeter.get_collision_point()).length()
	else:
		# Set value to show sensor is out of range
		adc_alt_agl = 9999
	
	if ((autopilot_on == 1) && (adc_alt_agl >= 15)):
		if ((abs(adc_roll) < 30) && (abs(adc_pitch) < 15)):
			input_elevator_trim = \
			calc_fcs_gains(air_pressure_dynamic) * \
			( \
			$PIDCalcPitchRate.calc_PID_output(input_joystick.y * 15, adc_rates.x)
			)
			input_rudder += calc_fcs_gains(air_pressure_dynamic) * -0.1 * angle_beta_deg
		else:
			input_elevator_trim = 0
			$PIDCalcPitchRate.integral = 0
		
		
	if (input_elevator_trim > input_trim_pitch_max):
		input_elevator_trim = input_trim_pitch_max
	if (input_elevator_trim < input_trim_pitch_min):
		input_elevator_trim = input_trim_pitch_min
	
	if (output_rudder > 1):
		output_rudder = 1
	if (output_rudder < -1):
		output_rudder = -1
	
	# Aero forces
	for child in get_children():
		if child is AeroSurface:
			child.atmo_data = calc_atmo_properties(global_transform.origin.y)
			child.vel_body = airspeed_true_vector
			apply_force_local(child.force_total_surface_vector * child.basis, child.position)
	
	# Thrust forces
	apply_force_local(Vector3(0, 0, -mass * get_gravity().length() /3 * input_throttle), Vector3(0, 0, 0))

	# Clamping
	input_flaps = clamp(input_flaps, flaps_min, flaps_max)
	input_throttle = clamp(input_throttle, throttle_min, throttle_max)
	
	# Gear animations
	$LG_Point_NLG/Strut_Lower.position.y = $VehicleWheel_NLG.position.y + 0.85
	$LG_Point_MLG_L/Strut_Lower.position.y = $VehicleWheel_MLG_L.position.y + 0.5
	$LG_Point_MLG_R/Strut_Lower.position.y = $VehicleWheel_MLG_R.position.y + 0.5
	
	$LG_Point_NLG.rotation.x   = (1 - gear_current) * (-PI/2)
	$LG_Point_MLG_L.rotation.z = (1 - gear_current) * (+PI/2)
	$LG_Point_MLG_R.rotation.z = (1 - gear_current) * (-PI/2)

	# Detect ground contact
	if (\
	$VehicleWheel_NLG.is_in_contact() == true || \
	$VehicleWheel_MLG_L.is_in_contact() == true || \
	$VehicleWheel_MLG_R.is_in_contact() == true
	):
		ground_contact = true
	
	else:
		ground_contact = false
	
	# Move surfaces
	$AileronL.rotation.x = +PI/6 * output_aileron
	$AileronR.rotation.x = -PI/6 * output_aileron
	
	$RuddervatorL.rotation = \
		Vector3( \
			(-0.1 * (output_elevator + output_elevator_trim + output_rudder)), \
			0, \
			($RuddervatorL.rotation.z) \
			)\
			.rotated(Vector3.FORWARD, \
		-$RuddervatorL.rotation.z)
	
	$RuddervatorR.rotation = \
		Vector3( \
			(-0.1 * (output_elevator + output_elevator_trim - output_rudder)), \
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
		input_rudder = Input.get_axis("yaw_left", "yaw_right")
		
		# Flaps input
		if (Input.is_action_just_pressed("flaps_down")):
			input_flaps += 0.25 
		if (Input.is_action_just_pressed("flaps_up")):
			input_flaps -= 0.25

		# Trim input
		
		if (Input.is_action_pressed("trim_pitch_up")):
			input_elevator_trim += 0.2 * delta 
		if (Input.is_action_pressed("trim_pitch_down")):
			input_elevator_trim -= 0.2 * delta 

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
		steering = -0.5 * _nosewheel_gains(linear_velocity_total) * output_rudder
		
		# Cameras
		if (Input.is_action_just_pressed("camera_toggle")):
			camera_mode = camera_mode + 1
		if (camera_mode == 0):
			$CameraFPV.current = true
		if (camera_mode == 1):
			$CameraExt.current = true
		if (camera_mode > 1):
			camera_mode = 0
		
		
		if (Input.is_action_just_pressed("nav_mode_toggle")):
			if (AeroDataBus.aircraft_nav_active == false): 
				AeroDataBus.aircraft_nav_active = true
			else:
				AeroDataBus.aircraft_nav_active = false
