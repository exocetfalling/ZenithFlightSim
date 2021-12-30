extends RigidBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var throttle_max = 100
var throttle_min = 0
var throttle_current = 0

var air_density = 1.2
var grounded = false

var pos_local = Vector3.ZERO

var corr_velocity = Vector3.ZERO

var vel_local_intermediate = Vector3.ZERO
var vel_local = Vector3.ZERO
var vel_total = 0
var roll_input = 0
var pitch_input = 0
var yaw_input = 0
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
var pos_wing = Vector3(0, 1, 0)
var pos_h_tail = Vector3(0, 3, 11)
var pos_v_tail = Vector3(0, 1.5, 10)
var pos_h_fuse = Vector3(0, 0, 3)
var pos_v_fuse = Vector3(0, 0, 3)
var pos_aileron_l = Vector3(-8, 1, 0)
var pos_aileron_r = Vector3( 8, 1, 0)
var pos_elevator = Vector3(0, 3, 11)
var pos_rudder = Vector3(0, 1.6, 11)

# Areas in m^2
var area_wing = 10 
var area_h_tail = 3
var area_v_tail = 1.5
var area_h_fuse = 20
var area_v_fuse = 20
var area_aileron = 4
var area_elevator = 4
var area_rudder = 4

# forces in N
var force_lift_wing = 0
var force_lift_h_tail = 0
var force_lift_v_tail = 0
var force_lift_h_fuse = 0
var force_lift_v_fuse = 0
var force_lift_aileron_l = 0
var force_lift_aileron_r = 0
var force_lift_elevator = 0
var force_lift_rudder = 0

var force_drag_wing = 0
var force_drag_h_tail = 0
var force_drag_v_tail = 0
var force_drag_h_fuse = 0
var force_drag_v_fuse = 0
var force_drag_aileron_l = 0
var force_drag_aileron_r = 0
var force_drag_elevator = 0
var force_drag_rudder = 0

var force_drag_rot = Vector3.ZERO

# Deflection in radians
var control_deflection = PI/12
var angle_incidence = 0.02

# Called when the node enters the scene tree for the first time.
func _ready():
	DebugOverlay.stats.add_property(self, "linear_velocity", "round")
	DebugOverlay.stats.add_property(self, "vel_local", "round")
	DebugOverlay.stats.add_property(self, "vel_total", "round")
	DebugOverlay.stats.add_property(self, "angular_velocity", "round")
	DebugOverlay.stats.add_property(self, "angle_alpha_deg", "round")
	DebugOverlay.stats.add_property(self, "angle_beta_deg", "round")
	DebugOverlay.stats.add_property(self, "force_lift_wing", "round")
	DebugOverlay.stats.add_property(self, "force_lift_elevator", "round")
	DebugOverlay.stats.add_property(self, "force_lift_aileron_l", "round")
	DebugOverlay.stats.add_property(self, "force_lift_aileron_r", "round")
	DebugOverlay.stats.add_property(self, "pitch_input", "round")
	DebugOverlay.stats.add_property(self, "roll_input", "round")
	DebugOverlay.stats.add_property(self, "yaw_input", "round")
	
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
		

func _calc_drag_induced_coeff(angle_rad):
	return 0.00001 * sin(angle_rad)
	
func _calc_lift_force(air_density, airspeed_true, surface_area, lift_coeff):
	if airspeed_true > 1:
		return 0.5 * air_density * pow(airspeed_true, 2) * surface_area * lift_coeff
	else:
		return 0
	
func _calc_drag_induced_force(air_density, airspeed_true, surface_area, drag_coeff):
	if airspeed_true > 1:
		return 0.5 * air_density * pow(airspeed_true, 2) * surface_area * drag_coeff
	else:
		return 0

func _calc_alpha(vel_up, vel_fwd):
	return atan2(-vel_up, vel_fwd)

func _calc_beta(vel_right, vel_fwd):
	return atan2(-vel_right, vel_fwd)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_input(delta)
	corr_velocity = Vector3(linear_velocity.x, linear_velocity.y, -linear_velocity.z)
	angle_alpha = _calc_alpha(vel_local.y, vel_local.z)
	angle_beta = _calc_beta(vel_local.x, vel_local.z)
	
	angle_alpha_deg = rad2deg(angle_alpha)
	angle_beta_deg = rad2deg(angle_beta)

	
func get_input(delta):
	# Throttle input
	if (Input.is_action_pressed("throttle_up") && throttle_current <= throttle_max):
		throttle_current = throttle_current + 1 
	if (Input.is_action_pressed("throttle_down") && throttle_current >= throttle_min):
		throttle_current = throttle_current - 1
	
	# Roll input
	roll_input = -Input.get_action_strength("roll_left") + Input.get_action_strength("roll_right")
	
	# Pitch (climb/dive) input
	pitch_input = -Input.get_action_strength("pitch_down") + Input.get_action_strength("pitch_up")
	
	# yaw input
	yaw_input = -Input.get_action_strength("yaw_left") + Input.get_action_strength("yaw_right")
	
	# Lift/drag calculations (helpers for add_force)
	force_lift_wing = _calc_lift_force(air_density, vel_total, area_wing, _calc_lift_coeff(angle_alpha + angle_incidence))
	
	force_lift_h_tail = _calc_lift_force(air_density, vel_total, area_h_tail, _calc_lift_coeff(angle_alpha))
	force_lift_v_tail = _calc_lift_force(air_density, vel_total, area_v_tail, _calc_lift_coeff(angle_beta))
	
	force_lift_h_fuse = _calc_lift_force(air_density, vel_total, area_h_fuse, _calc_lift_coeff(angle_alpha))
	force_lift_v_fuse = _calc_lift_force(air_density, vel_total, area_v_fuse, _calc_lift_coeff(angle_beta))

	force_drag_wing = _calc_drag_induced_force(air_density, vel_total, area_wing, _calc_drag_induced_coeff(angle_alpha + angle_incidence))
	
	force_drag_h_tail = _calc_drag_induced_force(air_density, vel_total, area_h_tail, _calc_drag_induced_coeff(angle_alpha))
	force_drag_v_tail = _calc_drag_induced_force(air_density, vel_total, area_v_tail, _calc_drag_induced_coeff(angle_beta))
	
	force_drag_h_fuse = _calc_drag_induced_force(air_density, vel_total, area_h_fuse, _calc_drag_induced_coeff(angle_alpha))
	force_drag_v_fuse = _calc_drag_induced_force(air_density, vel_total, area_v_tail, _calc_drag_induced_coeff(angle_beta))
	
	# Control forces calc.
	force_lift_aileron_l = _calc_lift_force(air_density, vel_total, area_aileron, _calc_lift_coeff(angle_alpha + angle_incidence + roll_input * control_deflection))
	force_lift_aileron_r = _calc_lift_force(air_density, vel_total, area_aileron, _calc_lift_coeff(angle_alpha + angle_incidence - roll_input * control_deflection))
	force_lift_elevator = _calc_lift_force(air_density, vel_total, area_elevator, _calc_lift_coeff(angle_alpha - pitch_input * control_deflection))
	force_lift_rudder = _calc_lift_force(air_density, vel_total, area_rudder, _calc_lift_coeff(angle_beta - yaw_input * control_deflection))
	
	force_drag_aileron_l = _calc_drag_induced_force(air_density, vel_total, area_aileron, _calc_drag_induced_coeff(angle_alpha + angle_incidence + roll_input * control_deflection))
	force_drag_aileron_r = _calc_drag_induced_force(air_density, vel_total, area_aileron, _calc_drag_induced_coeff(angle_alpha + angle_incidence - roll_input * control_deflection))
	force_drag_elevator = _calc_drag_induced_force(air_density, vel_total, area_elevator, _calc_drag_induced_coeff(angle_alpha + pitch_input * control_deflection))
	force_drag_rudder = _calc_drag_induced_force(air_density, vel_total, area_rudder, _calc_drag_induced_coeff(angle_alpha + yaw_input * control_deflection))
	
func _integrate_forces(state):
	forward_local = -get_global_transform().basis.z
	aft_local = get_global_transform().basis.z
	right_local = get_global_transform().basis.x
	left_local = -get_global_transform().basis.x
	up_local = get_global_transform().basis.y
	down_local = -get_global_transform().basis.y
	
	vel_total = abs(sqrt(pow(vel_local.x, 2) + pow(vel_local.y, 2) + pow(vel_local.z, 2)))
	
	vel_local_intermediate = (self.transform.basis.xform_inv(linear_velocity))
	vel_local = Vector3(vel_local_intermediate.x, vel_local_intermediate.y, -vel_local_intermediate.z)
	
	# Thrust forces
	add_force(forward_local * 9 * throttle_current, Vector3(0, 0, 0))
	
	# Lift forces from static elements (non-moving)
	add_force(up_local * force_lift_wing, pos_wing)
	add_force(up_local * force_lift_h_tail, pos_h_tail)
	add_force(right_local * force_lift_v_tail, pos_v_tail)
	
	add_force(up_local * force_lift_h_fuse, pos_h_fuse)
	add_force(right_local * force_lift_v_fuse, pos_v_fuse)
	
	# Lift forces from control surfaces
	add_force(up_local * force_lift_aileron_l, pos_aileron_l)
	add_force(up_local * force_lift_aileron_r, pos_aileron_r)
	add_force(up_local * force_lift_elevator, pos_elevator)
	add_force(right_local * force_lift_rudder, pos_rudder)
	
	# Drag forces
	add_force(aft_local * force_drag_wing, pos_wing)
	add_force(aft_local * force_drag_h_tail, pos_h_tail)
	add_force(aft_local * force_drag_v_tail, pos_v_tail)
	
	add_force(aft_local * force_drag_h_fuse, pos_h_fuse)
	add_force(aft_local * force_drag_v_fuse, pos_v_fuse)
	
	# Rot. drag
	force_drag_rot.x = -400 * pow(angular_velocity.x, 2)
	force_drag_rot.y = -100 * pow(angular_velocity.y, 2)
	force_drag_rot.z = -400 * pow(angular_velocity.z, 2)
	add_torque(force_drag_rot)
