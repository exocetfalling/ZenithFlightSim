extends RigidBody

var HUD_active = true
var rocket_scene = preload("GPRocket.tscn")
#signal flight_data
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var air_density = 1.2
var grounded = false

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

var roll_input = 0
var pitch_input = 0
var yaw_input = 0

var throttle_max = 100
var throttle_min = 0
var throttle_input = 0

var flaps_max = 1
var flaps_min = -1
var flaps_input = 0

var trim_pitch_max = 1
var trim_pitch_min = -1
var trim_pitch_input = 0

var gear_max = 1
var gear_min = 0
var gear_pos = 1
var gear_tgt = 1
enum gear_state {GEAR_UP, GEAR_EXTENDING, GEAR_DOWN, GEAR_RETRACTING}

var autopilot_on = 0
var tgt_pitch = 0

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
var pos_h_fuse = Vector3(0, 0, 3)
var pos_v_fuse = Vector3(0, 0, 3)
var pos_aileron_l = Vector3(-8, -0.75, 1)
var pos_aileron_r = Vector3( 8, -0.75, 1)
var pos_elevator = Vector3(0, 0, 11)
var pos_rudder = Vector3(0, 1.6, 11)
var pos_flaps = Vector3( 0, -0.75, 2)
var pos_gear = Vector3(0, -1.6, 11)


# Areas in m^2
var area_wing = 7 
var area_h_tail = 3
var area_v_tail = 1.5
var area_h_fuse = 8
var area_v_fuse = 8
var area_aileron = 1.5
var area_elevator = 1.5
var area_rudder = 1
var area_flaps = 2
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
var force_drag_h_fuse = Vector3.ZERO
var force_drag_v_fuse = Vector3.ZERO
var force_drag_aileron_l = Vector3.ZERO
var force_drag_aileron_r = Vector3.ZERO
var force_drag_elevator = Vector3.ZERO
var force_drag_rudder = Vector3.ZERO
var force_drag_flaps = Vector3.ZERO

var force_drag_rot = Vector3.ZERO

# Deflection in radians
var control_deflection = PI/12
var angle_incidence = 0.02

# Called when the node enters the scene tree for the first time.
func _ready():
#	DebugOverlay.stats.add_property(self, "pfd_spd", "round")
#	DebugOverlay.stats.add_property(self, "pfd_hdg", "round")
#	DebugOverlay.stats.add_property(self, "pfd_alt", "round")
#	DebugOverlay.stats.add_property(self, "pfd_pitch", "round")
#	DebugOverlay.stats.add_property(self, "pfd_roll", "round")
#	DebugOverlay.stats.add_property(self, "pfd_stall", "")
#	DebugOverlay.stats.add_property(self, "pitch_input", "round")
#	DebugOverlay.stats.add_property(self, "roll_input", "round")
#	DebugOverlay.stats.add_property(self, "yaw_input", "round")
#	DebugOverlay.stats.add_property(self, "throttle_input", "round")
#	DebugOverlay.stats.add_property(self, "flaps_input", "round")
#	DebugOverlay.stats.add_property(self, "pfd_pitch", "round")
#	DebugOverlay.stats.add_property(self, "tgt_pitch", "round")
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
		
	if ((angle_alpha_rad > x1) and (angle_alpha_rad <= x2)):
		return (a * (angle_alpha_rad - x1) + y1)
	
	if ((angle_alpha_rad > x2) and (angle_alpha_rad <= x3)):
		return (b * (angle_alpha_rad - x2) + y2)

	if ((angle_alpha_rad > x3) and (angle_alpha_rad <= x4)):
		return (c * (angle_alpha_rad - x3) + y3)
	
	if (angle_alpha_rad > x4):
		return (a * (angle_alpha_rad - 2 * PI - x1) + y1)
		

func _calc_drag_coeff(angle_rad):
	return 0.01 * sin(angle_rad) + 0.01 * cos(angle_rad)
	
func _calc_lift_force(air_density, airspeed_true, surface_area, lift_coeff):
	if airspeed_true > 1:
		return 0.5 * air_density * pow(airspeed_true, 2) * surface_area * lift_coeff
	else:
		return 0
	
func _calc_drag_force(air_density, airspeed_true, surface_area, drag_coeff):
	if airspeed_true > 1:
		return 0.5 * air_density * pow(airspeed_true, 2) * surface_area * drag_coeff
	else:
		return 0

func _calc_alpha(vel_up, vel_fwd):
	return atan2(-vel_up, vel_fwd)

func _calc_beta(vel_right, vel_fwd):
	return atan2(-vel_right, vel_fwd)
	
func add_force_local(force: Vector3, pos: Vector3):
	pos_local = self.transform.basis.xform(pos)
	force_local = self.transform.basis.xform(force)
	self.add_force(force_local, pos_local)

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
	
	if (gear_pos < gear_tgt):
		gear_pos = gear_pos + 0.2 * delta
	if (gear_pos > gear_tgt):
		gear_pos = gear_pos - 0.2 * delta
	if (abs(gear_pos - gear_tgt) < 0.01):
		gear_pos = gear_tgt
	
	if (autopilot_on == 1):
		if (pfd_stall == false):
			if (abs(pitch_input) < 0.1):
				trim_pitch_input = (tgt_pitch - pfd_pitch) / 5
			else:
				tgt_pitch = pfd_pitch
		else:
			autopilot_on == 0
	
	if (trim_pitch_input > trim_pitch_max):
		trim_pitch_input = trim_pitch_max
	if (trim_pitch_input < trim_pitch_min):
		trim_pitch_input = trim_pitch_min
func get_input(delta):
	# Throttle input
	if (Input.is_action_pressed("throttle_up")):
		if (throttle_input < throttle_max):
			throttle_input = throttle_input + 1 
	if (Input.is_action_pressed("throttle_down")):
		if (throttle_input > throttle_min):
			throttle_input = throttle_input - 1
			
	if (Input.is_action_pressed("ui_left")):
		$Camera.current = true
		HUD_active = true
	if (Input.is_action_pressed("ui_right")):
		$Camera2.current = true
		HUD_active = false
	
	# Roll input
	roll_input = -Input.get_action_strength("roll_left") + Input.get_action_strength("roll_right")
	
	# Pitch (climb/dive) input
	pitch_input = -Input.get_action_strength("pitch_down") + Input.get_action_strength("pitch_up")
	
	# yaw input
	yaw_input = -Input.get_action_strength("yaw_left") + Input.get_action_strength("yaw_right")
	
	# Flaps input
	if (Input.is_action_pressed("flaps_down")):
		if (flaps_input < flaps_max):
			flaps_input = flaps_input + 0.25 * delta 
	if (Input.is_action_pressed("flaps_up")):
		if (flaps_input > flaps_min):
			flaps_input = flaps_input - 0.25 * delta 
			
	# Trim input
	if (Input.is_action_pressed("trim_pitch_up")):
		if (trim_pitch_input < trim_pitch_max):
			trim_pitch_input = trim_pitch_input + 0.25 * delta 
	if (Input.is_action_pressed("trim_pitch_down")):
		if (trim_pitch_input > trim_pitch_min):
			trim_pitch_input = trim_pitch_input - 0.25 * delta

	# Gear input
	if (Input.is_action_just_pressed("gear_toggle")):
		if (gear_tgt == 0):
			gear_tgt = 1
		else:
			gear_tgt = 0
	
	# AP input
	if (Input.is_action_just_pressed("autopilot_toggle")):
		if (autopilot_on == 0):
			autopilot_on = 1
			tgt_pitch = pfd_pitch
		else:
			autopilot_on = 0
	
	if Input.is_action_just_pressed("fire_sta_1"):
		var clone = rocket_scene.instance()
		var scene_root = get_tree().root.get_children()[0]
		scene_root.add_child(clone)
		clone.global_transform = $Glider_CSG_Mesh/Fuse_Mid/Wing_Origin/WpnRack_1.global_transform
		clone.linear_velocity = self.linear_velocity
	
	if Input.is_action_just_pressed("fire_sta_2"):
		var clone = rocket_scene.instance()
		var scene_root = get_tree().root.get_children()[0]
		scene_root.add_child(clone)
		clone.global_transform = $Glider_CSG_Mesh/Fuse_Mid/Wing_Origin/WpnRack_2.global_transform
		clone.linear_velocity = self.linear_velocity

	if Input.is_action_just_pressed("fire_sta_3"):
		var clone = rocket_scene.instance()
		var scene_root = get_tree().root.get_children()[0]
		scene_root.add_child(clone)
		clone.global_transform = $Glider_CSG_Mesh/Fuse_Mid/Wing_Origin/WpnRack_3.global_transform
		clone.linear_velocity = self.linear_velocity
	
	if Input.is_action_just_pressed("fire_sta_4"):
		var clone = rocket_scene.instance()
		var scene_root = get_tree().root.get_children()[0]
		scene_root.add_child(clone)
		clone.global_transform = $Glider_CSG_Mesh/Fuse_Mid/Wing_Origin/WpnRack_4.global_transform
		clone.linear_velocity = self.linear_velocity
	# Lift/drag calculations (helpers for add_force_local)
	
	#Static, non-moving elements
	force_lift_wing = Vector3(0, _calc_lift_force(air_density, vel_total, area_wing, _calc_lift_coeff(angle_alpha + angle_incidence)), 0)

	force_lift_h_tail = Vector3(0, _calc_lift_force(air_density, vel_total, area_h_tail, _calc_lift_coeff(angle_alpha)), 0)
	force_lift_v_tail = Vector3(_calc_lift_force(air_density, vel_total, area_v_tail, _calc_lift_coeff(angle_beta)), 0, 0)

	force_lift_h_fuse = Vector3(0, _calc_lift_force(air_density, vel_total, area_h_fuse, _calc_lift_coeff(angle_alpha)), 0)
	force_lift_v_fuse = Vector3(_calc_lift_force(air_density, vel_total, area_v_fuse, _calc_lift_coeff(angle_beta)), 0, 0)

	force_drag_wing = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_wing, _calc_drag_coeff(angle_alpha + angle_incidence)))

	force_drag_h_tail = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_h_tail, _calc_drag_coeff(angle_alpha)))
	force_drag_v_tail = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_v_tail, _calc_drag_coeff(angle_beta)))

	force_drag_h_fuse = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_h_fuse, _calc_drag_coeff(angle_alpha)))
	force_drag_v_fuse = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_v_tail, _calc_drag_coeff(angle_beta)))
	
	# Control forces calc.
	force_lift_aileron_l = Vector3(0, _calc_lift_force(air_density, vel_total, area_aileron, _calc_lift_coeff(angle_alpha + angle_incidence + roll_input * control_deflection)), 0)
	force_lift_aileron_r = Vector3(0, _calc_lift_force(air_density, vel_total, area_aileron, _calc_lift_coeff(angle_alpha + angle_incidence - roll_input * control_deflection)), 0)
	force_lift_elevator = Vector3(0, _calc_lift_force(air_density, vel_total, area_elevator, _calc_lift_coeff(angle_alpha - (pitch_input + trim_pitch_input) * control_deflection)), 0)
	force_lift_rudder = Vector3(_calc_lift_force(air_density, vel_total, area_rudder, _calc_lift_coeff(angle_beta - yaw_input * control_deflection)), 0, 0)
	
	force_lift_flaps = Vector3(0, _calc_lift_force(air_density, vel_total, area_flaps, _calc_lift_coeff(angle_alpha + angle_incidence + flaps_input * control_deflection)), 0)
	
	force_drag_aileron_l = Vector3(0, 0, -_calc_drag_force(air_density, vel_total, area_aileron, _calc_drag_coeff(angle_alpha + angle_incidence + roll_input * control_deflection)))
	force_drag_aileron_r = Vector3(0, 0, -_calc_drag_force(air_density, vel_total, area_aileron, _calc_drag_coeff(angle_alpha + angle_incidence - roll_input * control_deflection)))
	force_drag_elevator = Vector3(0, 0, -_calc_drag_force(air_density, vel_total, area_elevator, _calc_drag_coeff(angle_alpha - (pitch_input + trim_pitch_input) * control_deflection)))
	force_drag_rudder = Vector3(0, 0, -_calc_drag_force(air_density, vel_total, area_rudder, _calc_drag_coeff(angle_alpha + yaw_input * control_deflection)))
	
	force_drag_flaps = Vector3(0, 0, -_calc_drag_force(air_density, vel_total, area_flaps, _calc_drag_coeff(angle_alpha + angle_incidence + flaps_input * control_deflection)))
	
	# Animations
	$Glider_CSG_Mesh/Fuse_Mid/Wing_Origin/Hinge_Aileron_L.rotation.x =  roll_input * control_deflection + PI/2
	$Glider_CSG_Mesh/Fuse_Mid/Wing_Origin/Hinge_Aileron_R.rotation.x = -roll_input * control_deflection + PI/2
	$Glider_CSG_Mesh/Hinge_Elevator_L.rotation.x = -(pitch_input + trim_pitch_input) * control_deflection
	$Glider_CSG_Mesh/Hinge_Elevator_R.rotation.x = -(pitch_input + trim_pitch_input) * control_deflection
	$Glider_CSG_Mesh/Hinge_Rudder.rotation.y =  yaw_input * control_deflection

	$Glider_CSG_Mesh/Fuse_Mid/Wing_Origin/Hinge_Flap_L.rotation.x = flaps_input * control_deflection + PI/2
	$Glider_CSG_Mesh/Fuse_Mid/Wing_Origin/Hinge_Flap_R.rotation.x = flaps_input * control_deflection + PI/2
	
	$LG_AttachPoint_Nose.rotation.x = (1 - gear_pos) * -PI/2
	$LG_AttachPoint_Main_L.rotation.z = (1 - gear_pos) * PI/2
	$LG_AttachPoint_Main_R.rotation.z = (1 - gear_pos) * -PI/2

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
#	add_central_force(Vector3(0, -weight, 0))
	
	# Thrust forces
	add_force_local(Vector3(0, 0, -2 * throttle_input), Vector3(0, 0, 0))
	
	# Lift forces from static elements (non-moving)
	add_force_local(force_lift_wing, pos_wing)
	add_force_local(force_lift_h_tail, pos_h_tail)
	add_force_local(force_lift_v_tail, pos_v_tail)
	
	add_force_local(force_lift_h_fuse, pos_h_fuse)
	add_force_local(force_lift_v_fuse, pos_v_fuse)
	
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
	
	add_force_local(force_drag_h_fuse, pos_h_fuse)
	add_force_local(force_drag_v_fuse, pos_v_fuse)
	
#	# Rot. drag
#	force_drag_rot.x = -4000 * pow(angular_velocity.x, 2)
#	force_drag_rot.y = -4000 * pow(angular_velocity.y, 2)
#	force_drag_rot.z = -4000 * pow(angular_velocity.z, 2)
#	add_torque(force_drag_rot)
