extends RigidBody

var HUD_active = true
var rocket_scene = preload("GPRocket.tscn")
#signal flight_data
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

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
var area_gear = 5

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

# Called when the node enters the scene tree for the first time.
func _ready():
#	DebugOverlay.stats.add_property(self, "pfd_spd", "round")
#	DebugOverlay.stats.add_property(self, "pfd_hdg", "round")
#	DebugOverlay.stats.add_property(self, "pfd_alt", "round")
#	DebugOverlay.stats.add_property(self, "pfd_pitch", "round")
#	DebugOverlay.stats.add_property(self, "pfd_roll", "round")
#	DebugOverlay.stats.add_property(self, "pfd_stall", "")
#	DebugOverlay.stats.add_property(self, "input_elevator", "round")
#	DebugOverlay.stats.add_property(self, "input_aileron", "round")
#	DebugOverlay.stats.add_property(self, "input_rudder", "round")
#	DebugOverlay.stats.add_property(self, "throttle_input", "round")
#	DebugOverlay.stats.add_property(self, "input_flaps", "round")
#	DebugOverlay.stats.add_property(self, "pfd_pitch", "round")
#	DebugOverlay.stats.add_property(self, "tgt_pitch", "round")
#	DebugOverlay.stats.add_property(self, "input_elevator", "round")
#	DebugOverlay.stats.add_property(self, "output_elevator", "round")
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
	return abs(0.2 * sin(angle_rad)) 

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_input(delta)
	corr_velocity = Vector3(linear_velocity.x, linear_velocity.y, -linear_velocity.z)
	angle_alpha = _calc_alpha(vel_local.y, vel_local.z)
	angle_beta = _calc_beta(vel_local.x, vel_local.z)
	
	angle_alpha_deg = rad2deg(angle_alpha)
	angle_beta_deg = rad2deg(angle_beta)
	
	pfd_spd = vel_total
	pfd_hdg = fmod(-rotation_degrees.y + 360, 360)
	pfd_alt = transform.origin.y
	
	pfd_pitch = rotation_degrees.x
	pfd_roll = -rotation_degrees.z
	
	if (angle_alpha_deg > 11):
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
			if ((abs(input_elevator) < 0.1) && (abs(pfd_roll) < 30) && (abs(pfd_pitch) < 20) && (ground_contact_NLG == false)):
				input_elevator_trim = (tgt_pitch - pfd_pitch) / 25
			else:
				tgt_pitch = pfd_pitch
		if (pfd_stall == true):
			autopilot_on = 0
	
	if (input_elevator_trim > input_trim_pitch_max):
		input_elevator_trim = input_trim_pitch_max
	if (input_elevator_trim < input_trim_pitch_min):
		input_elevator_trim = input_trim_pitch_min
	
	# NWS
	if (get_node("Wheel_Collider_NLG/RayCast").is_colliding() == true):
		ground_contact_NLG = true
	else:
		ground_contact_NLG = false

	# MLG weight on wheels
	if (get_node("Wheel_Collider_MLG_L/RayCast").is_colliding() == true):
		ground_contact_MLG_L = true
	else:
		ground_contact_MLG_L = false

	if (get_node("Wheel_Collider_MLG_R/RayCast").is_colliding() == true):
		ground_contact_MLG_R = true
	else:
		ground_contact_MLG_R = false

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
			HUD_active = false
		else:
			$Camera_FPV.current = true
			HUD_active = true

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
		else:
			autopilot_on = 0
	
	# Braking input
	input_braking = Input.get_action_strength("braking")
	
	if (Input.is_action_just_pressed("fire_sta_1") && (sta_1_rdy == 1)):
		var clone = rocket_scene.instance()
		var scene_root = get_tree().root.get_children()[0]
		sta_1_rdy = 0
		scene_root.add_child(clone)
		clone.global_transform = $Glider_CSG_Mesh/Fuse_Mid/Wing_Origin/WpnRack_1.global_transform
		clone.linear_velocity = self.linear_velocity
		get_node("Glider_CSG_Mesh/Fuse_Mid/Wing_Origin/WpnRack_1/CSGBox/GPRocket_Mesh/").visible = false
	
	if (Input.is_action_just_pressed("fire_sta_2") && (sta_2_rdy == 1)):
		var clone = rocket_scene.instance()
		var scene_root = get_tree().root.get_children()[0]
		sta_2_rdy = 0
		scene_root.add_child(clone)
		clone.global_transform = $Glider_CSG_Mesh/Fuse_Mid/Wing_Origin/WpnRack_2.global_transform
		clone.linear_velocity = self.linear_velocity
		get_node("Glider_CSG_Mesh/Fuse_Mid/Wing_Origin/WpnRack_2/CSGBox/GPRocket_Mesh/").visible = false

	if (Input.is_action_just_pressed("fire_sta_3") && (sta_3_rdy == 1)):
		var clone = rocket_scene.instance()
		var scene_root = get_tree().root.get_children()[0]
		sta_3_rdy = 0
		scene_root.add_child(clone)
		clone.global_transform = $Glider_CSG_Mesh/Fuse_Mid/Wing_Origin/WpnRack_3.global_transform
		clone.linear_velocity = self.linear_velocity
		get_node("Glider_CSG_Mesh/Fuse_Mid/Wing_Origin/WpnRack_3/CSGBox/GPRocket_Mesh/").visible = false

	if (Input.is_action_just_pressed("fire_sta_4") && (sta_4_rdy == 1)):
		var clone = rocket_scene.instance()
		var scene_root = get_tree().root.get_children()[0]
		sta_4_rdy = 0
		scene_root.add_child(clone)
		clone.global_transform = $Glider_CSG_Mesh/Fuse_Mid/Wing_Origin/WpnRack_4.global_transform
		clone.linear_velocity = self.linear_velocity
		get_node("Glider_CSG_Mesh/Fuse_Mid/Wing_Origin/WpnRack_4/CSGBox/GPRocket_Mesh/").visible = false
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
	force_lift_rudder = Vector3(_calc_lift_force(air_density, vel_total, area_rudder, _calc_lift_coeff(angle_beta - input_rudder * deflection_control_max)), 0, 0)
	
	force_lift_flaps = Vector3(0, _calc_lift_force(air_density, vel_total, area_flaps, _calc_lift_coeff(angle_alpha + angle_incidence + output_flaps * deflection_flaps_max)), 0)
	
	force_drag_aileron_l = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_aileron, _calc_drag_induced_coeff(angle_alpha + angle_incidence + output_aileron * deflection_control_max)))
	force_drag_aileron_r = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_aileron, _calc_drag_induced_coeff(angle_alpha + angle_incidence - output_aileron * deflection_control_max)))
	force_drag_elevator = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_elevator, _calc_drag_induced_coeff(angle_alpha - (output_elevator + input_elevator_trim) * deflection_control_max)))
	force_drag_rudder = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_rudder, _calc_drag_induced_coeff(angle_beta + output_rudder * deflection_control_max)))
	
	force_drag_flaps = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_flaps, _calc_drag_induced_coeff(angle_alpha + angle_incidence + output_flaps * deflection_flaps_max)))
	
	# Output delays
	output_aileron = interpolate_linear(output_aileron, input_aileron, deflection_rate, delta)
	output_elevator = interpolate_linear(output_elevator, input_elevator, deflection_rate, delta)
	output_rudder = interpolate_linear(output_rudder, input_rudder, deflection_rate, delta)
	
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
	
	$LG_AttachPoint_Nose.rotation.x = (1 - gear_current) * -PI/2
	$LG_AttachPoint_Main_L.rotation.z = (1 - gear_current) * PI/2
	$LG_AttachPoint_Main_R.rotation.z = (1 - gear_current) * -PI/2

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
	add_force_local(Vector3(0, 0, -80 * throttle_input), Vector3(0, 0, 0))
	
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
			add_force_local((Vector3(vel_local.x * -weight/10 + input_rudder * weight * vel_total, 0, 0)), Vector3(0, -3, -3))
		else:
			add_force_local((Vector3(vel_local.x * -weight/10, 0, 0)), Vector3(0, -3, -3))
	if (ground_contact_MLG_L == true):
		add_force_local((Vector3(0, 0, input_braking * vel_local.z * 25)), Vector3(-5, -3, 1))
		add_force_local((Vector3(vel_local.x * -weight, 0, 0)), Vector3(-5, -3, 1))
	if (ground_contact_MLG_R == true):
		add_force_local((Vector3(0, 0, input_braking * vel_local.z * 25)), Vector3( 5, -3, 1))
		add_force_local((Vector3(vel_local.x * -weight, 0, 0)), Vector3( 5, -3, 1))
		
