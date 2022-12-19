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
var pos_flap_l: Vector3 = Vector3.ZERO
var pos_flap_r : Vector3 = Vector3.ZERO

var pos_ruddervator_l : Vector3 = Vector3.ZERO
var pos_ruddervator_r : Vector3 = Vector3.ZERO

var Main_Panel_active = true
var rocket_scene = preload("res://scenes/GPRocket.tscn")

var LineDrawer = preload("res://scripts/DrawLine3D.gd").new()

var waypoint_data = Vector2.ZERO
var wpt_current = 'WPT 01'

#var wpt_current_coordinates = Vector3.ZERO
var wpt_current_coordinates = Vector3(1184.5, 402.423, 0)
var WPT_01_coodinates = Vector3.ZERO
var WPT_02_coodinates = Vector3.ZERO
var WPT_03_coodinates = Vector3.ZERO

var waypoint_data_3d = Vector3.ZERO
var global_rotation = Vector3.ZERO
var global_rotation_deg = Vector3.ZERO

var adc_fd_commands = Vector3.ZERO
var rate_pitch = 0
var cmd_vector = Vector3.ZERO

var panel_throttle = 0

var vel_local_test = Vector3.ZERO

var angle_alpha_test = 0
var angle_alpha_test_deg = 0

var vec_test : Vector3 = Vector3.ZERO

var camera_mode = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	control_type = 1
	
#	add_child(LineDrawer)

#	DebugOverlay.stats.add_property(self, "adc_spd", "round")
#	DebugOverlay.stats.add_property(self, "adc_hdg", "round")
#	DebugOverlay.stats.add_property(self, "adc_alt", "round")
#	DebugOverlay.stats.add_property(self, "adc_fpa", "round")
#	DebugOverlay.stats.add_property(self, "adc_trk", "round")
#	DebugOverlay.stats.add_property(self, "adc_stall", "")
#	DebugOverlay.stats.add_property(self, "input_elevator", "round")
#	DebugOverlay.stats.add_property(self, "input_aileron", "round")
#	DebugOverlay.stats.add_property(self, "input_rudder", "round")
#	DebugOverlay.stats.add_property(self, "input_throttle", "round")
#	DebugOverlay.stats.add_property(self, "air_pressure_dynamic", "round")
#	DebugOverlay.stats.add_property(self, "output_elevator", "round")
#	DebugOverlay.stats.add_property(self, "output_aileron", "round")
#	DebugOverlay.stats.add_property(self, "output_rudder", "round")
#	DebugOverlay.stats.add_property(self, "adc_fpa", "round")
#	DebugOverlay.stats.add_property(self, "tgt_fpa", "round")
#	DebugOverlay.stats.add_property(self, "vel_local", "round")
#	DebugOverlay.stats.add_property(self, "vel_local_test", "")
#	DebugOverlay.stats.add_property(self, "adc_rates", "round")
#	DebugOverlay.stats.add_property(self, "tgt_rates", "round")
#	DebugOverlay.stats.add_property(self, "fbw_output", "")
#	DebugOverlay.stats.add_property(self, "autopilot_on", "round")
#	DebugOverlay.stats.add_property(self, "angle_alpha_deg", "round")
#	DebugOverlay.stats.add_property(self, "angle_alpha_test_deg", "round")
#	DebugOverlay.stats.add_property(self, "camera_mode", "")
#	DebugOverlay.stats.add_property(self, "force_tail_v", "round")
#	DebugOverlay.stats.add_property(self, "force_tail_h", "round")
#	DebugOverlay.stats.add_property(self, "cmd_vector", "round")
#	DebugOverlay.stats.add_property(self, "adc_stall", "round")
#	DebugOverlay.stats.add_property(self, "value_setpoint", "round")
#	DebugOverlay.stats.add_property(self, "value_current", "round")
#	DebugOverlay.stats.add_property(self, "output_P", "round")
#	DebugOverlay.stats.add_property(self, "output_I", "round")
#	DebugOverlay.stats.add_property(self, "output_D", "round")
#	DebugOverlay.stats.add_property(self, "output_total", "round")
#	DebugOverlay.stats.add_property(self, "air_density", "round")
	
	vel_wind = Vector3(0, 0, 5)
	

	pass

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta): 
	adc_fd_commands = find_angles_and_distance_to_target(wpt_current_coordinates)
	
	global_rotation = global_transform.basis.get_euler()
	global_rotation_deg = Vector3(rad2deg(global_rotation.x), rad2deg(global_rotation.y), rad2deg(global_rotation.z))

#	vel_angular_local = (angular_velocity)
	if (control_type == 1):
		# Panel updates
		FlightData.aircraft_active = Main_Panel_active
		FlightData.aircraft_pitch = adc_pitch
		FlightData.aircraft_roll = adc_roll
		FlightData.aircraft_alpha = adc_alpha
		FlightData.aircraft_beta = adc_beta
		
		if (Global.setting_units == 0):
			FlightData.aircraft_spd_indicated = adc_spd_indicated
			FlightData.aircraft_spd_true = adc_spd_true
			FlightData.aircraft_alt_barometric = adc_alt_barometric
		if (Global.setting_units == 1):
			FlightData.aircraft_spd_indicated = adc_spd_indicated * 2
			FlightData.aircraft_spd_true = adc_spd_true * 2
			FlightData.aircraft_alt_barometric = adc_alt_barometric * 3.2809
		
		FlightData.aircraft_hdg = adc_hdg
		FlightData.aircraft_flaps = input_flaps * 4
		FlightData.aircraft_trim = output_elevator_trim
		FlightData.aircraft_gear = gear_current
		FlightData.aircraft_throttle = input_throttle
		FlightData.aircraft_ap = autopilot_on
		
		FlightData.aircraft_nav_brg = waypoint_data.x
		FlightData.aircraft_nav_range = waypoint_data.y
	
	if (angle_alpha_deg > 15):
		adc_stall = true
	else:
		adc_stall = false
	
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


	
	if (autopilot_on == 1):
		if (abs(input_joystick.y) < 0.1):
			$PID_Calc_Pitch.reset_integral = false
			input_elevator_trim = \
			calc_autopilot_factor(air_pressure_dynamic) * \
			( \
			$PID_Calc_Pitch.calc_PID_output(tgt_pitch, adc_pitch, delta)
			) \
			
		else: 
			$PID_Calc_Pitch.integral = 0
			$PID_Calc_Pitch.output_I = 0
			tgt_pitch = adc_pitch
#
#				Panel_Trim_Node.value = \
#				-1 * fbw_output.x
	
#		output_yaw_damper = calc_autopilot_factor(vel_total) * -0.1 * angle_beta_deg
#				input_elevator_trim = PID_Trim.calc_PID(tgt_pitch, adc_pitch, delta)

	if (input_elevator_trim > input_trim_pitch_max):
		input_elevator_trim = input_trim_pitch_max
	if (input_elevator_trim < input_trim_pitch_min):
		input_elevator_trim = input_trim_pitch_min
	
	if (output_rudder > 1):
		output_rudder = 1
	if (output_rudder < -1):
		output_rudder = -1
	
	$Camera_FPV/FPV_HUD.cam_fov = $Camera_FPV.fov
	
	# Waypoints
	waypoint_data = find_bearing_and_range_to(self.global_transform.origin, wpt_current_coordinates)
	waypoint_data_3d = find_angles_and_distance_to_target(wpt_current_coordinates)
#	get_node('3D_GCS/Viewport/Main_Panel').panel_nav_waypoint = wpt_current
#	if(get_node("3D_GCS/Viewport/Main_Panel/MFD/Page_NAV/Waypoint_ID").text == 'WPT 01'):
#		wpt_current = 'WPT 01'
#		wpt_current_coordinates = WPT_01_coodinates
#	if(get_node("3D_GCS/Viewport/Main_Panel/MFD/Page_NAV/Waypoint_ID").text == 'WPT 02'):
#		wpt_current = 'WPT 02'
#		wpt_current_coordinates = WPT_02_coodinates
#	if(get_node("3D_GCS/Viewport/Main_Panel/MFD/Page_NAV/Waypoint_ID").text == 'WPT 03'):
#		wpt_current = 'WPT 03'
#		wpt_current_coordinates = WPT_03_coodinates

#	vel_local_test = ($TestProbe.transform.basis.xform_inv(vel_local))
	
#	vel_local_test = calc_vel_local_with_offset(vel_local, vel_angular_local, Vector3(-19, 0, 0))
#	vel_local_test = Vector3(0, 1, 0).rotated(Vector3(0, 0, 1), $TestProbe.rotation.x)
	
	
#	angle_alpha_test = _calc_alpha(vel_local_test.y, -vel_local_test.z)
	angle_alpha_test = 0
	angle_alpha_test_deg = rad2deg(angle_alpha_test)
	
	
	# Aero forces
	$AeroSurface_Wing_L.vel_body = vel_airspeed_true
	force_wing_l = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Wing_L.force_total_surface_vector, \
			$AeroSurface_Wing_L.rotation \
			)
	$AeroSurface_Wing_R.vel_body = vel_airspeed_true
	force_wing_r = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Wing_R.force_total_surface_vector, \
			$AeroSurface_Wing_R.rotation \
			)
	
	$AeroSurface_Aileron_L.vel_body = vel_airspeed_true
	force_aileron_l = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Aileron_L.force_total_surface_vector, \
			$AeroSurface_Aileron_L.rotation \
			)
	
	$AeroSurface_Aileron_R.vel_body = vel_airspeed_true
	force_aileron_r = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Aileron_R.force_total_surface_vector, \
			$AeroSurface_Aileron_R.rotation \
			)
	
	$AeroSurface_Flap_L.vel_body = vel_airspeed_true
	force_flap_l = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Flap_L.force_total_surface_vector, \
			$AeroSurface_Flap_L.rotation \
		)
	$AeroSurface_Flap_R.vel_body = vel_airspeed_true
	force_flap_r = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Flap_R.force_total_surface_vector, \
			$AeroSurface_Flap_R.rotation \
		)
	
	$AeroSurface_Ruddervator_L.vel_body = vel_airspeed_true
	force_ruddervator_l = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Ruddervator_L.force_total_surface_vector, \
			$AeroSurface_Ruddervator_L.rotation \
			)
	$AeroSurface_Ruddervator_R.vel_body = vel_airspeed_true
	force_ruddervator_r = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Ruddervator_R.force_total_surface_vector, \
			$AeroSurface_Ruddervator_R.rotation \
			)
	
	$AeroSurface_Aileron_L.rotation.x =  0.2 * output_aileron
	$AeroSurface_Aileron_R.rotation.x = -0.2 * output_aileron
	
	$AeroSurface_Flap_L.rotation.x = 0.2 * output_flaps
	$AeroSurface_Flap_R.rotation.x = 0.2 * output_flaps
	
	$AeroSurface_Ruddervator_L.rotation = \
		Vector3( \
			(-0.1 * (output_elevator + output_elevator_trim + output_rudder)), \
			0, \
			($AeroSurface_Ruddervator_L.rotation.z) \
			)\
			.rotated(Vector3.FORWARD, \
		-$AeroSurface_Ruddervator_L.rotation.z)
	
	$AeroSurface_Ruddervator_R.rotation = \
		Vector3( \
			(-0.1 * (output_elevator + output_elevator_trim - output_rudder)), \
			0, \
			($AeroSurface_Ruddervator_R.rotation.z) \
			)\
			.rotated(Vector3.FORWARD, \
		-$AeroSurface_Ruddervator_R.rotation.z)
	
	pos_wing_l = $AeroSurface_Wing_L.pos_force_rel
	pos_wing_r = $AeroSurface_Wing_R.pos_force_rel

	pos_aileron_l = $AeroSurface_Aileron_L.pos_force_rel
	pos_aileron_r = $AeroSurface_Aileron_R.pos_force_rel

	pos_flap_l = $AeroSurface_Flap_L.pos_force_rel
	pos_flap_r = $AeroSurface_Flap_R.pos_force_rel

	pos_ruddervator_l = $AeroSurface_Ruddervator_L.pos_force_rel
	pos_ruddervator_r = $AeroSurface_Ruddervator_R.pos_force_rel
	
#	# HMD 
#	get_node("Camera_FPV_Node/HMD").body_angles.x = deg2rad(adc_pitch)
#	get_node("Camera_FPV_Node/HMD").body_angles.z = deg2rad(adc_roll)

	$CSGCylinder_Axle_MLG_L.translation.y = $VehicleWheel_MLG_L.translation.y
	$CSGCylinder_Axle_MLG_R.translation.y = $VehicleWheel_MLG_R.translation.y
	
	# Draw lines
#	LineDrawer.DrawLine(self.global_transform.origin, wpt_current_coordinates, Color(0, 1, 0))
func get_input(delta):
	# Check if aircraft is under player control
	if (control_type == 1):
			# Throttle input
		if (Input.is_action_pressed("throttle_up")):
			if (input_throttle < throttle_max):
				input_throttle += 0.5 * delta 
		if (Input.is_action_pressed("throttle_down")):
			if (input_throttle > throttle_min):
				input_throttle -= 0.5 * delta

		# Joystick input (as vector) 
		input_joystick = Input.get_vector("roll_left", "roll_right", "pitch_down", "pitch_up")
		
		# Yaw input
		input_rudder = -Input.get_action_strength("yaw_left") + Input.get_action_strength("yaw_right")
		
		# Flaps input
		if (Input.is_action_just_pressed("flaps_down")):
			input_flaps += 0.25 
		if (Input.is_action_just_pressed("flaps_up")):
			input_flaps -= 0.25

		# Trim input
		
		if (Input.is_action_pressed("trim_pitch_up")):
			input_elevator_trim += 0.1 * delta 
		if (Input.is_action_pressed("trim_pitch_down")):
			input_elevator_trim -= 0.1 * delta 

	#	# Gear input
	#	if (Input.is_action_just_pressed("gear_toggle")):
	#
	#		if (gear_input == 0):
	#			gear_input = -1
	#		else:
	#			gear_input = 0
		
		# AP input
		if (Input.is_action_just_pressed("autopilot_toggle")):
			if (autopilot_on == 0):
				autopilot_on = 1
				tgt_fpa = adc_fpa
				output_yaw_damper = 0
			else:
				autopilot_on = 0
				output_yaw_damper = 0

		# Braking input
		input_braking = Input.get_action_strength("braking")
		brake = input_braking * 5
		
		# NWS input
		if (abs(vel_total) < 10):
			steering = -0.5 * output_rudder
		else:
			steering = 0
		
		# Cameras
		if (Input.is_action_just_pressed("camera_toggle")):
			camera_mode = camera_mode + 1
		if (camera_mode == 0):
			$Camera_FPV.current = true
		if (camera_mode == 1):
			$Camera_Ext.current = true
		if (camera_mode > 1):
			camera_mode = 0
		
		if (Input.is_action_pressed("cam_zoom_in")):
			$Camera_FPV.fov -= 10 * delta 
		if (Input.is_action_pressed("cam_zoom_out")):
			$Camera_FPV.fov += 10 * delta

func _integrate_forces(_state):
	# Gravity
	add_central_force(Vector3(0, -weight, 0))
	
	# Thrust forces
	add_force_local(Vector3(0, 0, -weight/3 * input_throttle), Vector3(0, 0, 0))
	
	# Forces from surfaces 
	add_force_local(force_wing_l, pos_wing_l)
	add_force_local(force_wing_r, pos_wing_r)
	
	add_force_local(force_aileron_l, pos_aileron_l)
	add_force_local(force_aileron_r, pos_aileron_r)
	
	add_force_local(force_flap_l, pos_flap_l)
	add_force_local(force_flap_r, pos_flap_r)
	
	add_force_local(force_ruddervator_l, pos_ruddervator_l)
	add_force_local(force_ruddervator_r, pos_ruddervator_r)
