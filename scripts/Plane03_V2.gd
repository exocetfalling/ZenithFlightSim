extends AeroBody

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

onready var Panel_Node = get_node("3D_GCS/GUIPanel3D/Viewport/Main_Panel")

onready var Panel_Throttle_Node = get_node("3D_GCS/GUIPanel3D/Viewport/Main_Panel/Sliders/Throttle")
onready var Panel_Flaps_Node = get_node("3D_GCS/GUIPanel3D/Viewport/Main_Panel/Sliders/Flaps")
onready var Panel_Gear_Node = get_node("3D_GCS/GUIPanel3D/Viewport/Main_Panel/Sliders/Gear")
onready var Panel_Trim_Node = get_node("3D_GCS/GUIPanel3D/Viewport/Main_Panel/Sliders/Trim")

onready var HUD_Node = get_node("3D_HUD_V2/GUIPanelHUD/Viewport/3D_HUD_Panel")

var vel_local_test = Vector3.ZERO

var angle_alpha_test = 0
var angle_alpha_test_deg = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(LineDrawer)

#	DebugOverlay.stats.add_property(self, "adc_spd", "round")
#	DebugOverlay.stats.add_property(self, "adc_hdg", "round")
#	DebugOverlay.stats.add_property(self, "adc_alt", "round")
#	DebugOverlay.stats.add_property(self, "adc_fpa", "round")
#	DebugOverlay.stats.add_property(self, "adc_trk", "round")
#	DebugOverlay.stats.add_property(self, "adc_stall", "")
#	DebugOverlay.stats.add_property(self, "input_elevator", "round")
#	DebugOverlay.stats.add_property(self, "input_aileron", "round")
#	DebugOverlay.stats.add_property(self, "input_rudder", "round")
	DebugOverlay.stats.add_property(self, "input_throttle", "round")
	DebugOverlay.stats.add_property(self, "input_flaps", "round")
	DebugOverlay.stats.add_property(self, "output_elevator", "round")
	DebugOverlay.stats.add_property(self, "output_aileron", "round")
	DebugOverlay.stats.add_property(self, "output_rudder", "round")
#	DebugOverlay.stats.add_property(self, "adc_fpa", "round")
#	DebugOverlay.stats.add_property(self, "tgt_fpa", "round")
	DebugOverlay.stats.add_property(self, "vel_local", "round")
	DebugOverlay.stats.add_property(self, "vel_local_test", "round")
#	DebugOverlay.stats.add_property(self, "adc_rates", "round")
#	DebugOverlay.stats.add_property(self, "tgt_rates", "round")
#	DebugOverlay.stats.add_property(self, "fbw_output", "")
#	DebugOverlay.stats.add_property(self, "output_yaw_damper", "round")
	DebugOverlay.stats.add_property(self, "angle_alpha_deg", "round")
	DebugOverlay.stats.add_property(self, "angle_alpha_test_deg", "round")
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
	DebugOverlay.stats.add_property(self, "air_density", "round")
	pass

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	get_input(delta)
	adc_fd_commands = find_angles_and_distance_to_target(wpt_current_coordinates)
	
	global_rotation = global_transform.basis.get_euler()
	global_rotation_deg = Vector3(rad2deg(global_rotation.x), rad2deg(global_rotation.y), rad2deg(global_rotation.z))

#	vel_angular_local = (angular_velocity)

	# Panel updates
	Panel_Node.display_active = Main_Panel_active
	Panel_Node.display_pitch = adc_pitch
	Panel_Node.display_roll = adc_roll
	Panel_Node.display_spd = adc_spd
	Panel_Node.display_hdg = adc_hdg
	Panel_Node.display_alt = adc_alt
	Panel_Node.display_flaps = input_flaps * 4
	Panel_Node.display_trim = output_elevator_trim
	Panel_Node.display_gear = gear_current
	Panel_Node.display_throttle = input_throttle
	Panel_Node.display_ap = autopilot_on
	
	Panel_Node.display_nav_brg = waypoint_data.x
	Panel_Node.display_nav_range = waypoint_data.y
	
	
	# HUD updates
	HUD_Node.display_pitch = adc_pitch
	HUD_Node.display_roll = adc_roll
	HUD_Node.display_spd = adc_spd
	HUD_Node.display_hdg = adc_hdg
	HUD_Node.display_alt = adc_alt
	
	HUD_Node.display_alpha = adc_alpha
	HUD_Node.display_beta = adc_beta
	
	HUD_Node.display_flaps = input_flaps * 4
	HUD_Node.display_trim = output_elevator_trim
	HUD_Node.display_gear = gear_current
	HUD_Node.display_throttle = input_throttle
	HUD_Node.display_ap = autopilot_on
	
	HUD_Node.display_nav_brg = waypoint_data.x
	HUD_Node.display_nav_range = waypoint_data.y
	HUD_Node.display_FD_commands = adc_fd_commands
	
	
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
		if (adc_stall == false):
			if (\
			(abs(input_elevator) < 0.1) && \
			(abs(adc_roll) < 30) && \
			(abs(adc_pitch) < 20) && \
			(ground_contact_NLG == false)\
			):
				Panel_Trim_Node.value = \
				-1 * \
				calc_autopilot_factor(vel_total) * \
				( \
				$PID_Calc_Pitch.calc_PID_output(tgt_fpa, adc_fpa, delta)
				) \
#
#				Panel_Trim_Node.value = \
#				-1 * fbw_output.x
				
				output_yaw_damper = calc_autopilot_factor(vel_total) * -0.1 * angle_beta_deg
#				input_elevator_trim = PID_Trim.calc_PID(tgt_pitch, adc_pitch, delta)
			else:
				tgt_fpa = adc_fpa
				output_yaw_damper = 0
		if (adc_stall == true):
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
	
	vel_local_test = calc_vel_local_with_offset(vel_local, vel_angular_local, Vector3(-19, 0, 0))
	
	angle_alpha_test = _calc_alpha(vel_local_test.y, -vel_local_test.z)
	
	angle_alpha_test_deg = rad2deg(angle_alpha_test)
	
	$TestProbe.vel_body = vel_local
	
	# HUD
	get_node("HUD_Point/HUD_Ladder").rotation_degrees.z = adc_roll
	get_node("HUD_Point/HUD_Ladder").translation.y = -(adc_pitch / 90 * 260) * cos(deg2rad(adc_roll))
	get_node("HUD_Point/HUD_Ladder").translation.x = get_node("HUD_Point/HUD_Ladder").translation.y * -1 * tan(deg2rad(adc_roll))
	get_node("HUD_Point/FlightPathVector").translation.y = -(adc_alpha / 90 * 260)
	get_node("HUD_Point/FlightPathVector").translation.x = -(adc_beta / 90 * 260)
	get_node("HUD_Point/FlightDirector").translation.y = (adc_fd_commands.y / 90 * 260)
	get_node("HUD_Point/FlightDirector").translation.x = (adc_fd_commands.x / 90 * 260)
	if (vel_total > 2):
		get_node('HUD_Point/FlightPathVector').visible = true
	else:
		get_node('HUD_Point/FlightPathVector').visible = false
		
	if (autopilot_on == 1):
		get_node('HUD_Point/FlightDirector').visible = true
	else:
		get_node('HUD_Point/FlightDirector').visible = false
#
#	if ($Camera_FPV.rotation_degrees.x < -30):
#		$HUD_Point.visible = false
#	else:
#		$HUD_Point.visible = true
#


	# HMD 
	get_node("Camera_FPV_Node/HMD").body_angles.x = deg2rad(adc_pitch)
	get_node("Camera_FPV_Node/HMD").body_angles.z = deg2rad(adc_roll)


	# Draw lines
#	LineDrawer.DrawLine(self.global_transform.origin, wpt_current_coordinates, Color(0, 1, 0))
func get_input(delta):
		# Throttle input
	
	if (Input.is_action_pressed("throttle_up")):
		if (input_throttle < throttle_max):
			input_throttle += 0.5 * delta 
	if (Input.is_action_pressed("throttle_down")):
		if (input_throttle > throttle_min):
			input_throttle -= 0.5 * delta
	
	# Roll input
	input_aileron = -Input.get_action_strength("roll_left") + Input.get_action_strength("roll_right")
	
	# Pitch (climb/dive) input
	input_elevator = -Input.get_action_strength("pitch_down") + Input.get_action_strength("pitch_up")
	# yaw input
	input_rudder = -Input.get_action_strength("yaw_left") + Input.get_action_strength("yaw_right")
	
	# Flaps input
	if (Input.is_action_just_pressed("flaps_down")):
		input_flaps += 0.25 
	if (Input.is_action_just_pressed("flaps_up")):
		input_flaps -= 0.25

	# Trim input
	
	if (Input.is_action_pressed("trim_pitch_up")):
		input_elevator_trim += 0.5 * delta 
	if (Input.is_action_pressed("trim_pitch_down")):
		input_elevator_trim -= 0.5 * delta 

	# Gear input
	if (Input.is_action_just_pressed("gear_toggle")):
	
		if (gear_input == 0):
			gear_input = -1
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
	
	# Cameras
	if (Input.is_action_just_pressed("camera_toggle")):
		if ($Camera_Ext.current == false):
			$Camera_Ext.current = true
			Main_Panel_active = false
		else:
			$Camera_FPV_Node/Gimbal_X/Gimbal_Y/Camera_FPV.current = true
			Main_Panel_active = true

	# AP input
	if (Input.is_action_just_pressed("autopilot_toggle")):
		if (autopilot_on == 0):
			autopilot_on = 1
			tgt_pitch = adc_pitch
			output_yaw_damper = 0
		else:
			autopilot_on = 0
			output_yaw_damper = 0

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
