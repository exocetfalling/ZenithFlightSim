extends AeroBody

var force_wing_l : Vector3 = Vector3.ZERO
var force_wing_r : Vector3 = Vector3.ZERO

var force_aileron_l : Vector3 = Vector3.ZERO
var force_aileron_r : Vector3 = Vector3.ZERO
var force_flap_l : Vector3 = Vector3.ZERO
var force_flap_r : Vector3 = Vector3.ZERO

var force_ruddervator_l : Vector3 = Vector3.ZERO
var force_ruddervator_r : Vector3 = Vector3.ZERO

var force_fin_ventral : Vector3 = Vector3.ZERO

var pos_wing_l : Vector3 = Vector3.ZERO
var pos_wing_r : Vector3 = Vector3.ZERO

var pos_aileron_l : Vector3 = Vector3.ZERO
var pos_aileron_r : Vector3 = Vector3.ZERO
var pos_flap_l: Vector3 = Vector3.ZERO
var pos_flap_r : Vector3 = Vector3.ZERO

var pos_ruddervator_l : Vector3 = Vector3.ZERO
var pos_ruddervator_r : Vector3 = Vector3.ZERO

var pos_fin_ventral : Vector3 = Vector3.ZERO

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
#	DebugOverlay.stats.add_property(self, "input_throttle", "round")
#	DebugOverlay.stats.add_property(self, "input_flaps", "round")
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
#	DebugOverlay.stats.add_property(self, "output_yaw_damper", "round")
#	DebugOverlay.stats.add_property(self, "angle_alpha_deg", "round")
#	DebugOverlay.stats.add_property(self, "angle_alpha_test_deg", "round")
#	DebugOverlay.stats.add_property(self, "pos_wing_l", "round")
#	DebugOverlay.stats.add_property(self, "force_tail_v", "round")
#	DebugOverlay.stats.add_property(self, "force_tail_h", "round")
#	DebugOverlay.stats.add_property(self, "cmd_vector", "round")
#	DebugOverlay.stats.add_property(self, "proportional", "round")
#	DebugOverlay.stats.add_property(self, "value_setpoint", "round")
#	DebugOverlay.stats.add_property(self, "value_current", "round")
#	DebugOverlay.stats.add_property(self, "output_P", "round")
#	DebugOverlay.stats.add_property(self, "output_I", "round")
#	DebugOverlay.stats.add_property(self, "output_D", "round")
#	DebugOverlay.stats.add_property(self, "output_total", "round")
#	DebugOverlay.stats.add_property(self, "air_density", "round")
	
	pos_wing_l = $AeroSurface_Wing_L.translation
	pos_wing_r = $AeroSurface_Wing_R.translation
	
	pos_aileron_l = $AeroSurface_Aileron_L.translation
	pos_aileron_r = $AeroSurface_Aileron_R.translation
	
	pos_flap_l = $AeroSurface_Flap_L.translation
	pos_flap_r = $AeroSurface_Flap_R.translation
	
	pos_ruddervator_l = $AeroSurface_Ruddervator_L.translation
	pos_ruddervator_r = $AeroSurface_Ruddervator_R.translation
	
	pos_fin_ventral = $AeroSurface_Fin_Ventral.translation
	
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
	
#	vel_local_test = calc_vel_local_with_offset(vel_local, vel_angular_local, Vector3(-19, 0, 0))
#	vel_local_test = Vector3(0, 1, 0).rotated(Vector3(0, 0, 1), $TestProbe.rotation.x)
	
	
#	angle_alpha_test = _calc_alpha(vel_local_test.y, -vel_local_test.z)
	angle_alpha_test = 0
	angle_alpha_test_deg = rad2deg(angle_alpha_test)
	
	
	# Aero forces
	$AeroSurface_Wing_L.vel_body = vel_local
	force_wing_l = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Wing_L.force_total_surface_vector, \
			$AeroSurface_Wing_L.rotation \
			)
	$AeroSurface_Wing_R.vel_body = vel_local
	force_wing_r = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Wing_R.force_total_surface_vector, \
			$AeroSurface_Wing_R.rotation \
			)
	
	$AeroSurface_Aileron_L.vel_body = vel_local
	force_aileron_l = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Aileron_L.force_total_surface_vector, \
			$AeroSurface_Aileron_L.rotation \
			)
	
	$AeroSurface_Aileron_R.vel_body = vel_local
	force_aileron_r = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Aileron_R.force_total_surface_vector, \
			$AeroSurface_Aileron_R.rotation \
			)
	
	$AeroSurface_Flap_L.vel_body = vel_local
	force_flap_l = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Flap_L.force_total_surface_vector, \
			$AeroSurface_Flap_L.rotation \
		)
	$AeroSurface_Flap_R.vel_body = vel_local
	force_flap_r = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Flap_R.force_total_surface_vector, \
			$AeroSurface_Flap_R.rotation \
		)
	
	$AeroSurface_Ruddervator_L.vel_body = vel_local
	force_ruddervator_l = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Ruddervator_L.force_total_surface_vector, \
			$AeroSurface_Ruddervator_L.rotation \
			)
	$AeroSurface_Ruddervator_R.vel_body = vel_local
	force_ruddervator_r = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Ruddervator_R.force_total_surface_vector, \
			$AeroSurface_Ruddervator_R.rotation \
			)
	$AeroSurface_Fin_Ventral.vel_body = vel_local
	force_fin_ventral = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Fin_Ventral.force_total_surface_vector, \
			$AeroSurface_Fin_Ventral.rotation \
			)
	
	$AeroSurface_Aileron_L.rotation.x =  0.2 * output_aileron
	$AeroSurface_Aileron_R.rotation.x = -0.2 * output_aileron
	
	$AeroSurface_Flap_L.rotation.x = 0.2 * output_flaps
	$AeroSurface_Flap_R.rotation.x = 0.2 * output_flaps
	
	$AeroSurface_Ruddervator_L.rotation.x = -0.2 * (output_elevator + output_rudder)
	$AeroSurface_Ruddervator_R.rotation.x = -0.2 * (output_elevator - output_rudder)
	
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
	brake = input_braking * 5
	
	# NWS input
	if (abs(vel_total) < 10):
		steering = -0.5 * output_rudder
	else:
		steering = 0
	
	# Cameras
	if (Input.is_action_just_pressed("camera_toggle")):
		if ($Camera_Ext.current == false):
			$Camera_Ext.current = true
			Main_Panel_active = false
#		if ($Camera_Ext.current == true):
#			$Camera_FPV_Node/Gimbal_X/Gimbal_Y/Camera_FPV.current = true
#			Main_Panel_active = true

	# AP input
	if (Input.is_action_just_pressed("autopilot_toggle")):
		if (autopilot_on == 0):
			autopilot_on = 1
			tgt_pitch = adc_pitch
			output_yaw_damper = 0
		else:
			autopilot_on = 0
			output_yaw_damper = 0

	# Output delays
	output_aileron = interpolate_linear(output_aileron, input_aileron, deflection_rate, delta)
	output_elevator = interpolate_linear(output_elevator, input_elevator, deflection_rate, delta)
	output_rudder = interpolate_linear(output_rudder, input_rudder + output_yaw_damper, deflection_rate, delta)
	
	output_flaps = interpolate_linear(output_flaps, input_flaps, deflection_rate_flaps, delta)
	output_elevator_trim = input_elevator_trim

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
