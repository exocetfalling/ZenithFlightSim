extends RigidBody

var Main_Panel_active = true
var rocket_scene = preload("res://scenes/GPRocket.tscn")

var LineDrawer = preload("res://scripts/DrawLine3D.gd").new()

var air_density = 1.2
var ground_contact_NLG = false
var ground_contact_MLG_L = false
var ground_contact_MLG_R = false

var force_local
var pos_local

var corr_velocity = Vector3.ZERO

var vel_local_intermediate = Vector3.ZERO
var vel_local = Vector3.ZERO
var vel_total = 0

var pfd_spd = 0
var pfd_alt = 0
var pfd_hdg = 0

var pfd_pitch = 0
var pfd_roll = 0

var pfd_alpha = 0
var pfd_beta = 0

var pfd_fpa = 0
var tgt_fpa = 0
var pfd_trk = 0
var tgt_trk = 0

var pfd_stall = false

var throttle_max = 100
var throttle_min = 0
var throttle_input = 0

var autopilot_on = 0
var tgt_pitch = 0

var sta_1_rdy = 1
var sta_2_rdy = 1
var sta_3_rdy = 1
var sta_4_rdy = 1

var angle_alpha = 0
var angle_alpha_deg = 0
var angle_beta = 0
var angle_beta_deg = 0

var forward_local = Vector3.ZERO
var aft_local = Vector3.ZERO
var right_local = Vector3.ZERO
var left_local = Vector3.ZERO
var up_local = Vector3.ZERO
var down_local = Vector3.ZERO

# Specs from CollisionShape measurements

# Positions as (x, y, z) m, z reversed
var pos_wing = Vector3(0, -0.75, 0)
var pos_h_tail = Vector3(0, 0, 11)
var pos_v_tail = Vector3(0, 1.5, 10)
var pos_fuse = Vector3(0, 0, 3)
var pos_aileron_l = Vector3(-8, -0.75, 1)
var pos_aileron_r = Vector3( 8, -0.75, 1)
var pos_elevator = Vector3(0, 0, 11)
var pos_rudder = Vector3(0, 1.6, 11)
var pos_flaps = Vector3( 0, -0.75, 2)
var pos_gear = Vector3(0, -0.5, 0)


# Areas in m^2
var area_wing = 7 
var area_h_tail = 3
var area_v_tail = 1.5
var area_fuse = 3.5
var area_aileron = 3
var area_elevator = 3
var area_rudder = 3
var area_flaps = 3
var area_gear = 2

# forces in N
var force_lift_wing = Vector3.ZERO
var force_lift_h_tail = Vector3.ZERO
var force_lift_v_tail = Vector3.ZERO
var force_lift_h_fuse = Vector3.ZERO
var force_lift_v_fuse = Vector3.ZERO
var force_lift_aileron_l = Vector3.ZERO
var force_lift_aileron_r = Vector3.ZERO
var force_lift_elevator = Vector3.ZERO
var force_lift_rudder = Vector3.ZERO
var force_lift_flaps = Vector3.ZERO

var force_drag_wing = Vector3.ZERO
var force_drag_h_tail = Vector3.ZERO
var force_drag_v_tail = Vector3.ZERO
var force_drag_fuse = Vector3.ZERO
var force_drag_aileron_l = Vector3.ZERO
var force_drag_aileron_r = Vector3.ZERO
var force_drag_elevator = Vector3.ZERO
var force_drag_rudder = Vector3.ZERO
var force_drag_flaps = Vector3.ZERO
var force_drag_gear = Vector3.ZERO

# Deflection in radians
var deflection_control_max = PI/6
var deflection_flaps_max = PI/4
var angle_incidence = 0.02

var input_elevator = 0
var current_elevator = 0
var output_elevator = 0

var current_aileron = 0
var input_aileron = 0
var output_aileron = 0

var current_rudder = 0
var input_rudder = 0
var output_rudder = 0
var output_yaw_damper = 0

var current_flaps = 0
var input_flaps = 0
var output_flaps = 0
var flaps_max = 1
var flaps_min = -1

var current_elevator_trim = 0
var input_elevator_trim = 0
var output_elevator_trim = 0

var input_trim_pitch_max = 1
var input_trim_pitch_min = -1

var input_braking = 0

var gear_max = 1
var gear_min = 0
var gear_current = 1
var gear_input = 1

var deflection_rate = 1/(PI/6)
var deflection_rate_flaps = 1/(2 * PI)

var waypoint_data = Vector2.ZERO
var wpt_current = 'WPT 01'
var wpt_current_coordinates = Vector3.ZERO
var WPT_01_coodinates = Vector3.ZERO
var WPT_02_coodinates = Vector3.ZERO
var WPT_03_coodinates = Vector3.ZERO

var waypoint_data_3d = Vector3.ZERO
var global_rotation = Vector3.ZERO
var global_rotation_deg = Vector3.ZERO

var pfd_fd_commands = Vector3.ZERO
var rate_pitch = 0
var cmd_vector = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(LineDrawer)

#	DebugOverlay.stats.add_property(self, "pfd_spd", "round")
#	DebugOverlay.stats.add_property(self, "pfd_hdg", "round")
#	DebugOverlay.stats.add_property(self, "pfd_alt", "round")
#	DebugOverlay.stats.add_property(self, "pfd_fpa", "round")
#	DebugOverlay.stats.add_property(self, "pfd_trk", "round")
#	DebugOverlay.stats.add_property(self, "pfd_stall", "")
#	DebugOverlay.stats.add_property(self, "input_elevator", "round")
#	DebugOverlay.stats.add_property(self, "input_aileron", "round")
#	DebugOverlay.stats.add_property(self, "input_rudder", "round")
#	DebugOverlay.stats.add_property(self, "throttle_input", "round")
#	DebugOverlay.stats.add_property(self, "input_flaps", "round")
	DebugOverlay.stats.add_property(self, "pfd_pitch", "round")
	DebugOverlay.stats.add_property(self, "tgt_pitch", "round")
#	DebugOverlay.stats.add_property(self, "output_yaw_damper", "round")
#	DebugOverlay.stats.add_property(self, "angle_beta_deg", "round")
#	DebugOverlay.stats.add_property(self, "global_rotation_deg", "round")
#	DebugOverlay.stats.add_property(self, "waypoint_data_3d", "round")
#	DebugOverlay.stats.add_property(self, "cmd_vector", "round")
#	DebugOverlay.stats.add_property(self, "proportional", "round")
#	DebugOverlay.stats.add_property(self, "value_setpoint", "round")
#	DebugOverlay.stats.add_property(self, "value_current", "round")
#	DebugOverlay.stats.add_property(self, "output_P", "round")
#	DebugOverlay.stats.add_property(self, "output_I", "round")
#	DebugOverlay.stats.add_property(self, "output_D", "round")
#	DebugOverlay.stats.add_property(self, "output_total", "round")
	pass

# Lift coeffecient calculation function
func _calc_lift_coeff(angle_alpha_rad):
	var x1 = -PI
	var y1 = 0
	var x2 = -PI/12
	var y2 = -1.5
	var x3 = PI/12
	var y3 = 1.5
	var x4 = PI
	var y4 = 0

	var a = (y2 - y1) / (x2 - x1)
	var b = (y3 - y2) / (x3 - x2)
	var c = (y4 - y3) / (x4 - x3)

	if (angle_alpha_rad < x1):
		return (a * (angle_alpha_rad + 2 * PI - x1) + y1)
		
	elif ((angle_alpha_rad > x1) and (angle_alpha_rad <= x2)):
		return (a * (angle_alpha_rad - x1) + y1)
	
	elif ((angle_alpha_rad > x2) and (angle_alpha_rad <= x3)):
		return (b * (angle_alpha_rad - x2) + y2)

	elif ((angle_alpha_rad > x3) and (angle_alpha_rad <= x4)):
		return (c * (angle_alpha_rad - x3) + y3)
	
	elif (angle_alpha_rad > x4):
		return (a * (angle_alpha_rad - 2 * PI - x1) + y1)
	
	else:
		return 0
		

func _calc_drag_induced_coeff(angle_rad):
	return abs(0.1 * sin(angle_rad)) 

func _calc_drag_parasite_coeff(angle_rad):
	return abs(0.02 * cos(angle_rad))
	
func _calc_lift_force(air_density_current, airspeed_true, surface_area, lift_coeff):
	return 0.5 * air_density_current * pow(airspeed_true, 2) * surface_area * lift_coeff
	
func _calc_drag_force(air_density_current, airspeed_true, surface_area, drag_coeff):
	return 0.5 * air_density_current * pow(airspeed_true, 2) * surface_area * drag_coeff

func _calc_alpha(vel_up, vel_fwd):
	return atan2(-vel_up, vel_fwd)

func _calc_beta(vel_right, vel_fwd):
	return atan2(-vel_right, vel_fwd)
	
func add_force_local(force: Vector3, pos: Vector3):
	pos_local = self.transform.basis.xform(pos)
	force_local = self.transform.basis.xform(force)
	self.add_force(force_local, pos_local)
	
func interpolate_linear(value_current, value_target, rate, delta_time):
	if (abs(value_current - value_target) > delta_time):
		if (value_current < value_target):
			return value_current + rate * delta_time
		if (value_current > value_target):
			return value_current - rate * delta_time
		else:
			return value_target
	else:
		return value_target

func calc_braking_force(vel_fwd, weight_craft, commanded_braking):
	var braking_coeff
	var braking_force
	
	if (vel_fwd > 0):
		braking_coeff = 0.5

	elif (vel_fwd < 0):
		braking_coeff = -0.5
	
	else:
		braking_coeff = 0
	
	braking_force = braking_coeff * weight_craft * input_braking
	return braking_force

func find_bearing_and_range_to(vec_pos_target, vec_pos_source):
	var vec_delta_pos = vec_pos_target - vec_pos_source
	var vec_delta_pos_2d = Vector2(vec_delta_pos.x, vec_delta_pos.z)
	var vec_delta_pos_2d_norm = vec_delta_pos_2d.normalized()
	var bearing_to = fmod(-rad2deg(atan2(vec_delta_pos_2d_norm.x, vec_delta_pos_2d_norm.y)) + 360, 360)
	var range_to = vec_delta_pos_2d.length()
	return Vector2(bearing_to, range_to)

func find_angles_and_distance_to_target(vec_pos_target):
	var vec_delta_local = to_local(vec_pos_target)
	var pitch_to = rad2deg(atan2(vec_delta_local.y, -vec_delta_local.z))
	var yaw_to = rad2deg(atan2(vec_delta_local.x, -vec_delta_local.z))
	var range_to = vec_delta_local.length()
	return Vector3(yaw_to, pitch_to, range_to)

func calc_autopilot_factor(velocity_aircraft):	
	var x1 = 0
	var y1 = 0.10
	var x2 = 60
	var y2 = 0.10
	var x3 = 160
	var y3 = 0.02
	var x4 = 200
	var y4 = 0.02

	var a = (y2 - y1) / (x2 - x1)
	var b = (y3 - y2) / (x3 - x2)
	var c = (y4 - y3) / (x4 - x3)

	if (velocity_aircraft < x1):
		return 0
		
	elif ((velocity_aircraft > x1) and (velocity_aircraft <= x2)):
		return (a * (velocity_aircraft - x1) + y1)
	
	elif ((velocity_aircraft > x2) and (velocity_aircraft <= x3)):
		return (b * (velocity_aircraft - x2) + y2)

	elif ((velocity_aircraft > x3) and (velocity_aircraft <= x4)):
		return (c * (velocity_aircraft - x3) + y3)
	
	elif (velocity_aircraft > x4):
		return 0
	
	else:
		return 0

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	get_input(delta)
	corr_velocity = Vector3(linear_velocity.x, linear_velocity.y, -linear_velocity.z)
	angle_alpha = _calc_alpha(vel_local.y, vel_local.z)
	angle_beta = _calc_beta(vel_local.x, vel_local.z)
	
	angle_alpha_deg = rad2deg(angle_alpha)
	angle_beta_deg = rad2deg(angle_beta)
	
	pfd_spd = vel_total
	pfd_hdg = fmod(-rotation_degrees.y + 360, 360)
	pfd_alt = global_transform.origin.y
	
	pfd_pitch = rotation_degrees.x
	pfd_roll = -rotation_degrees.z
	
	pfd_alpha = angle_alpha_deg
	pfd_beta = angle_beta_deg
	
	pfd_fpa = pfd_pitch - pfd_alpha
	pfd_trk = pfd_hdg - pfd_beta
	
	pfd_fd_commands = find_angles_and_distance_to_target(wpt_current_coordinates)
	
	global_rotation = global_transform.basis.get_euler()
	global_rotation_deg = Vector3(rad2deg(global_rotation.x), rad2deg(global_rotation.y), rad2deg(global_rotation.z))
	
	# Panel updates
	get_node("3D_GCS/Viewport/Main_Panel").display_active = Main_Panel_active
	get_node("3D_GCS/Viewport/Main_Panel").display_pitch = pfd_pitch
	get_node("3D_GCS/Viewport/Main_Panel").display_roll = pfd_roll
	get_node("3D_GCS/Viewport/Main_Panel").display_spd = pfd_spd
	get_node("3D_GCS/Viewport/Main_Panel").display_hdg = pfd_hdg
	get_node("3D_GCS/Viewport/Main_Panel").display_alt = pfd_alt
	get_node("3D_GCS/Viewport/Main_Panel").display_flaps = input_flaps * 4
	get_node("3D_GCS/Viewport/Main_Panel").display_trim = output_elevator_trim
	get_node("3D_GCS/Viewport/Main_Panel").display_gear = gear_current
	get_node("3D_GCS/Viewport/Main_Panel").display_throttle = throttle_input
	get_node("3D_GCS/Viewport/Main_Panel").display_ap = autopilot_on
	
	get_node("3D_GCS/Viewport/Main_Panel").display_nav_brg = waypoint_data.x
	get_node("3D_GCS/Viewport/Main_Panel").display_nav_range = waypoint_data.y
	
	if (angle_alpha_deg > 15):
		pfd_stall = true
	else:
		pfd_stall = false
	
	if (gear_current < gear_input):
		gear_current = gear_current + 0.2 * delta
	if (gear_current > gear_input):
		gear_current = gear_current - 0.2 * delta
	if (abs(gear_current - gear_input) < 0.01):
		gear_current = gear_input

	if (autopilot_on == 1):
		if (pfd_stall == false):
			if (\
			(abs(input_elevator) < 0.1) && \
			(abs(pfd_roll) < 30) && \
			(abs(pfd_pitch) < 20) && \
			(ground_contact_NLG == false)\
			):
					input_elevator_trim = \
					$Trim_PID_Calc.calc_proportional_output(tgt_pitch, pfd_pitch, delta) + \
					$Trim_PID_Calc.calc_integral_output(tgt_pitch, pfd_pitch, delta) + \
					$Trim_PID_Calc.calc_derivative_output(tgt_pitch, pfd_pitch, delta)
					
					
					
					output_yaw_damper = calc_autopilot_factor(vel_total) * -angle_beta_deg
#					input_elevator_trim = PID_Trim.calc_PID(tgt_pitch, pfd_pitch, delta)
			else:
				tgt_pitch = pfd_pitch
				output_yaw_damper = 0
		if (pfd_stall == true):
			autopilot_on = 0
	
	if (input_elevator_trim > input_trim_pitch_max):
		input_elevator_trim = input_trim_pitch_max
	if (input_elevator_trim < input_trim_pitch_min):
		input_elevator_trim = input_trim_pitch_min
	
	if (output_rudder > 1):
		output_rudder = 1
	if (output_rudder < -1):
		output_rudder = -1
	
	# NWS
	if ($'../LG_AttachPoint_Nose/Wheel/RayCast'.is_colliding() == true):
		ground_contact_NLG = true
	else:
		ground_contact_NLG = false

	# MLG weight on wheels
	if ($'../LG_AttachPoint_Main_L/Wheel/RayCast'.is_colliding() == true):
		ground_contact_MLG_L = true
	else:
		ground_contact_MLG_L = false

	if ($'../LG_AttachPoint_Main_R/Wheel/RayCast'.is_colliding() == true):
		ground_contact_MLG_R = true
	else:
		ground_contact_MLG_R = false
	
	# Waypoints
	waypoint_data = find_bearing_and_range_to(self.global_transform.origin, wpt_current_coordinates)
	waypoint_data_3d = find_angles_and_distance_to_target(wpt_current_coordinates)
#	get_node('3D_GCS/Viewport/Main_Panel').display_nav_waypoint = wpt_current
	if(get_node("3D_GCS/Viewport/Main_Panel/MFD/Page_NAV/Waypoint_ID").text == 'WPT 01'):
		wpt_current = 'WPT 01'
		wpt_current_coordinates = WPT_01_coodinates
	if(get_node("3D_GCS/Viewport/Main_Panel/MFD/Page_NAV/Waypoint_ID").text == 'WPT 02'):
		wpt_current = 'WPT 02'
		wpt_current_coordinates = WPT_02_coodinates
	if(get_node("3D_GCS/Viewport/Main_Panel/MFD/Page_NAV/Waypoint_ID").text == 'WPT 03'):
		wpt_current = 'WPT 03'
		wpt_current_coordinates = WPT_03_coodinates
	
	# HUD
	get_node("HUD_Point/HUD_Ladder").rotation_degrees.z = pfd_roll
	get_node("HUD_Point/HUD_Ladder").translation.y = -(pfd_pitch / 90 * 260) * cos(deg2rad(pfd_roll))
	get_node("HUD_Point/HUD_Ladder").translation.x = get_node("HUD_Point/HUD_Ladder").translation.y * -1 * tan(deg2rad(pfd_roll))
	get_node("HUD_Point/FlightPathVector").translation.y = -(pfd_alpha / 90 * 260)
	get_node("HUD_Point/FlightPathVector").translation.x = -(pfd_beta / 90 * 260)
	get_node("HUD_Point/FlightDirector").translation.y = (pfd_fd_commands.y / 90 * 260)
	get_node("HUD_Point/FlightDirector").translation.x = (pfd_fd_commands.x / 90 * 260)
	if (vel_total > 2):
		get_node('HUD_Point/FlightPathVector').visible = true
	else:
		get_node('HUD_Point/FlightPathVector').visible = false
		
	if (autopilot_on == 1):
		get_node('HUD_Point/FlightDirector').visible = true
	else:
		get_node('HUD_Point/FlightDirector').visible = false
	
	# Draw lines
#	LineDrawer.DrawLine(self.global_transform.origin, wpt_current_coordinates, Color(0, 1, 0))
func get_input(delta):
	# Throttle input
	if (Input.is_action_pressed("throttle_up")):
		if (throttle_input < throttle_max):
			throttle_input = throttle_input + 1 
	if (Input.is_action_pressed("throttle_down")):
		if (throttle_input > throttle_min):
			throttle_input = throttle_input - 1
			
	# Cameras
	if (Input.is_action_just_pressed("camera_toggle")):
		if ($Camera_Ext.current == false):
			$Camera_Ext.current = true
			Main_Panel_active = false
		else:
			$Camera_FPV.current = true
			Main_Panel_active = true
	
	if ((Input.is_action_pressed("ui_up")) && ($Camera_FPV.current == true)):
		$Camera_FPV.rotate_x(2 * delta)
	if ((Input.is_action_pressed("ui_down")) && ($Camera_FPV.current == true)):
		$Camera_FPV.rotate_x(-2 * delta)
	if ((Input.is_action_pressed("ui_left")) && ($Camera_FPV.current == true)):
		$Camera_FPV.rotate_y(-2 * delta)
	if ((Input.is_action_pressed("ui_right")) && ($Camera_FPV.current == true)):
		$Camera_FPV.rotate_y(2 * delta)
	if ((Input.is_action_pressed("ui_page_up")) && ($Camera_FPV.current == true)):
		$Camera_FPV.fov -= (5 * delta)
	if ((Input.is_action_pressed("ui_page_down")) && ($Camera_FPV.current == true)):
		$Camera_FPV.fov += (5 * delta)
	if ((Input.is_action_pressed("ui_home")) && ($Camera_FPV.current == true)):
		$Camera_FPV.rotation = Vector3.ZERO
		$Camera_FPV.fov = 65
	# Roll input
	input_aileron = -Input.get_action_strength("roll_left") + Input.get_action_strength("roll_right")
	
	# Pitch (climb/dive) input
	input_elevator = -Input.get_action_strength("pitch_down") + Input.get_action_strength("pitch_up")
	# yaw input
	input_rudder = -Input.get_action_strength("yaw_left") + Input.get_action_strength("yaw_right")
	
	# Flaps input
	if (Input.is_action_just_pressed("flaps_down")):
		if (input_flaps < flaps_max):
			input_flaps = input_flaps + 0.25 
	if (Input.is_action_just_pressed("flaps_up")):
		if (input_flaps > flaps_min):
			input_flaps = input_flaps - 0.25
			
	# Trim input
	if (Input.is_action_pressed("trim_pitch_up")):
		if (input_elevator_trim < input_trim_pitch_max):
			input_elevator_trim = input_elevator_trim + 0.25 * delta 
	if (Input.is_action_pressed("trim_pitch_down")):
		if (input_elevator_trim > input_trim_pitch_min):
			input_elevator_trim = input_elevator_trim - 0.25 * delta

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
			tgt_pitch = pfd_pitch
			output_yaw_damper = 0
		else:
			autopilot_on = 0
			output_yaw_damper = 0
	
	# Braking input
	input_braking = Input.get_action_strength("braking")
	
	# Weapons
	if (Input.is_action_just_pressed("fire_sta_1") && (sta_1_rdy == 1)):
		$'../GPRocket_1'.launched = true
		$'../GPRocket_1'.tgt_coordinates = wpt_current_coordinates
		$'../Wpn_Joint_1'.queue_free()
		sta_1_rdy = 0
	if (Input.is_action_just_pressed("fire_sta_2") && (sta_2_rdy == 1)):
		$'../GPRocket_2'.launched = true
		$'../GPRocket_2'.tgt_coordinates = wpt_current_coordinates
		$'../Wpn_Joint_2'.queue_free()
		sta_2_rdy = 0
	if (Input.is_action_just_pressed("fire_sta_3") && (sta_3_rdy == 1)):
		$'../GPRocket_3'.launched = true
		$'../GPRocket_3'.tgt_coordinates = wpt_current_coordinates
		$'../Wpn_Joint_3'.queue_free()
		sta_3_rdy = 0
	if (Input.is_action_just_pressed("fire_sta_4") && (sta_4_rdy == 1)):
		$'../GPRocket_4'.launched = true
		$'../GPRocket_4'.tgt_coordinates = wpt_current_coordinates
		$'../Wpn_Joint_4'.queue_free()
		sta_4_rdy = 0
	# Lift/drag calculations (helpers for add_force_local)
	
	#Static, non-moving elements
	force_lift_wing = Vector3(0, _calc_lift_force(air_density, vel_total, area_wing, _calc_lift_coeff(angle_alpha + angle_incidence)), 0)

	force_lift_h_tail = Vector3(0, _calc_lift_force(air_density, vel_total, area_h_tail, _calc_lift_coeff(angle_alpha)), 0)
	force_lift_v_tail = Vector3(_calc_lift_force(air_density, vel_total, area_v_tail, _calc_lift_coeff(angle_beta)), 0, 0)


	force_drag_wing = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_wing, _calc_drag_induced_coeff(angle_alpha + angle_incidence)))

	force_drag_h_tail = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_h_tail, _calc_drag_induced_coeff(angle_alpha)))
	force_drag_v_tail = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_v_tail, _calc_drag_induced_coeff(angle_beta)))

	force_drag_fuse = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_fuse, _calc_drag_parasite_coeff(angle_alpha)))
	
	force_drag_gear = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_gear * gear_current, _calc_drag_parasite_coeff(angle_alpha)))
	# Control forces calc.
	force_lift_aileron_l = Vector3(0, _calc_lift_force(air_density, vel_total, area_aileron, _calc_lift_coeff(angle_alpha + angle_incidence + output_aileron * deflection_control_max)), 0)
	force_lift_aileron_r = Vector3(0, _calc_lift_force(air_density, vel_total, area_aileron, _calc_lift_coeff(angle_alpha + angle_incidence - output_aileron * deflection_control_max)), 0)
	force_lift_elevator = Vector3(0, _calc_lift_force(air_density, vel_total, area_elevator, _calc_lift_coeff(angle_alpha - (output_elevator + input_elevator_trim) * deflection_control_max)), 0)
	force_lift_rudder = Vector3(_calc_lift_force(air_density, vel_total, area_rudder, _calc_lift_coeff(angle_beta - output_rudder * deflection_control_max)), 0, 0)
	
	force_lift_flaps = Vector3(0, _calc_lift_force(air_density, vel_total, area_flaps, _calc_lift_coeff(angle_alpha + angle_incidence + output_flaps * deflection_flaps_max)), 0)
	
	force_drag_aileron_l = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_aileron, _calc_drag_induced_coeff(angle_alpha + angle_incidence + output_aileron * deflection_control_max)))
	force_drag_aileron_r = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_aileron, _calc_drag_induced_coeff(angle_alpha + angle_incidence - output_aileron * deflection_control_max)))
	force_drag_elevator = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_elevator, _calc_drag_induced_coeff(angle_alpha - (output_elevator + input_elevator_trim) * deflection_control_max)))
	force_drag_rudder = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_rudder, _calc_drag_induced_coeff(angle_beta + output_rudder * deflection_control_max)))
	
	force_drag_flaps = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_flaps, _calc_drag_induced_coeff(angle_alpha + angle_incidence + output_flaps * deflection_flaps_max)))
	
	# Output delays
	output_aileron = interpolate_linear(output_aileron, input_aileron, deflection_rate, delta)
	output_elevator = interpolate_linear(output_elevator, input_elevator, deflection_rate, delta)
	output_rudder = interpolate_linear(output_rudder, input_rudder + output_yaw_damper, deflection_rate, delta)
	
	output_flaps = interpolate_linear(output_flaps, input_flaps, deflection_rate_flaps, delta)
	output_elevator_trim = input_elevator_trim
	
	# Animations
	$Glider_CSG_Mesh/Fuse_Mid/Wing_Origin/Hinge_Aileron_L.rotation.x =  output_aileron * deflection_control_max + PI/2
	$Glider_CSG_Mesh/Fuse_Mid/Wing_Origin/Hinge_Aileron_R.rotation.x = -output_aileron * deflection_control_max + PI/2
	$Glider_CSG_Mesh/Hinge_Elevator_L.rotation.x = -(output_elevator + input_elevator_trim) * deflection_control_max
	$Glider_CSG_Mesh/Hinge_Elevator_R.rotation.x = -(output_elevator + input_elevator_trim) * deflection_control_max
	$Glider_CSG_Mesh/Hinge_Rudder.rotation.y =  output_rudder * deflection_control_max


	$Glider_CSG_Mesh/Fuse_Mid/Wing_Origin/Hinge_Flap_L.rotation.x = output_flaps * deflection_flaps_max + PI/2
	$Glider_CSG_Mesh/Fuse_Mid/Wing_Origin/Hinge_Flap_R.rotation.x = output_flaps * deflection_flaps_max + PI/2

	if (gear_input != gear_current):	
		# NLG
		$'../Joint_NLG_1'.set("angular_limit_x/lower_angle", ((1 - gear_current) * 90))
		$'../Joint_NLG_1'.set("angular_limit_x/upper_angle", ((1 - gear_current) * 90))
		$'../Joint_NLG_2'.set("angular_limit_x/lower_angle", ((1 - gear_current) * 90))
		$'../Joint_NLG_2'.set("angular_limit_x/upper_angle", ((1 - gear_current) * 90))
		$'../Joint_NLG_3'.set("angular_limit_x/lower_angle", ((1 - gear_current) * 90))
		$'../Joint_NLG_3'.set("angular_limit_x/upper_angle", ((1 - gear_current) * 90))
		
		# MLG_L
		$'../Joint_MLG_L_1'.set("angular_limit_z/lower_angle", ((1 - gear_current) * -90))
		$'../Joint_MLG_L_1'.set("angular_limit_z/upper_angle", ((1 - gear_current) * -90))
		$'../Joint_MLG_L_2'.set("angular_limit_z/lower_angle", ((1 - gear_current) * -90))
		$'../Joint_MLG_L_2'.set("angular_limit_z/upper_angle", ((1 - gear_current) * -90))
		$'../Joint_MLG_L_3'.set("angular_limit_z/lower_angle", ((1 - gear_current) * -90))
		$'../Joint_MLG_L_3'.set("angular_limit_z/upper_angle", ((1 - gear_current) * -90))
		
		# MLG_R
		$'../Joint_MLG_R_1'.set("angular_limit_z/lower_angle", ((1 - gear_current) * 90))
		$'../Joint_MLG_R_1'.set("angular_limit_z/upper_angle", ((1 - gear_current) * 90))
		$'../Joint_MLG_R_2'.set("angular_limit_z/lower_angle", ((1 - gear_current) * 90))
		$'../Joint_MLG_R_2'.set("angular_limit_z/upper_angle", ((1 - gear_current) * 90))
		$'../Joint_MLG_R_3'.set("angular_limit_z/lower_angle", ((1 - gear_current) * 90))
		$'../Joint_MLG_R_3'.set("angular_limit_z/upper_angle", ((1 - gear_current) * 90))

func _integrate_forces(_state):
	forward_local = -get_global_transform().basis.z
	aft_local = get_global_transform().basis.z
	right_local = get_global_transform().basis.x
	left_local = -get_global_transform().basis.x
	up_local = get_global_transform().basis.y
	down_local = -get_global_transform().basis.y
	
	vel_total = abs(sqrt(pow(vel_local.x, 2) + pow(vel_local.y, 2) + pow(vel_local.z, 2)))
	
	vel_local_intermediate = (self.transform.basis.xform_inv(linear_velocity))
	vel_local = Vector3(vel_local_intermediate.x, vel_local_intermediate.y, -vel_local_intermediate.z)
	
	# Gravity
	add_central_force(Vector3(0, -weight, 0))
	
	# Thrust forces
	add_force_local(Vector3(0, 0, -weight/300 * throttle_input), Vector3(0, 0, 0))
	
	# Lift forces from static elements (non-moving)
	add_force_local(force_lift_wing, pos_wing)
	add_force_local(force_lift_h_tail, pos_h_tail)
	add_force_local(force_lift_v_tail, pos_v_tail)
	
	# Lift forces from control surfaces
	add_force_local(force_lift_aileron_l, pos_aileron_l)
	add_force_local(force_lift_aileron_r, pos_aileron_r)
	add_force_local(force_lift_elevator, pos_elevator)
	add_force_local(force_lift_rudder, pos_rudder)
	
	add_force_local(force_lift_flaps, pos_flaps)
	# Drag forces
	add_force_local(force_drag_wing, pos_wing)
	add_force_local(force_drag_h_tail, pos_h_tail)
	add_force_local(force_drag_v_tail, pos_v_tail)
	add_force_local(force_drag_flaps, pos_flaps)
	
	add_force_local(force_drag_fuse, pos_fuse)
	
	add_force_local(force_drag_gear, pos_gear)
	
	# Wheel forces
	if (ground_contact_NLG == true):
		if (abs(vel_local.z) < 10):
			add_force_local((Vector3(vel_local.x * -weight/10 + input_rudder * weight/10 * vel_total, 0, 0)), Vector3(0, -3, -3))
		else:
			add_force_local((Vector3(vel_local.x * -weight/10, 0, 0)), Vector3(0, -3, -3))
	if (ground_contact_MLG_L == true):
		add_force_local((Vector3(0, 0, calc_braking_force(vel_local.z, weight, input_braking))), Vector3(-5, -3, 1))
		add_force_local((Vector3(vel_local.x * -weight, 0, 0)), Vector3(-5, -3, 1))
	if (ground_contact_MLG_R == true):
		add_force_local((Vector3(0, 0, calc_braking_force(vel_local.z, weight, input_braking))), Vector3( 5, -3, 1))
		add_force_local((Vector3(vel_local.x * -weight, 0, 0)), Vector3( 5, -3, 1))
		
