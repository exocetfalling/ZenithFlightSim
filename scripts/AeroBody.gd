extends RigidBody

class_name AeroBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var air_density = 1.2

# Lift scalar, dimensionless
export var scalar_lift : float = 1.00

# Drag (induced) scalar, dimensionless
export var scalar_drag_induced : float = 0.05

# Drag (parasite) scalar, dimensionless
export var scalar_drag_parasite : float = 0.02

# Angle of attack (alpha)
var angle_alpha : float = 0.00
var angle_alpha_deg : float = 0.00

# Angle of sideslip (beta)
var angle_beta : float = 0.00
var angle_beta_deg : float = 0.00

# Positions as (x, y, z) m, z reversed
export var pos_wing : Vector3 = Vector3(0, -0.75, 0)
export var pos_h_tail : Vector3 = Vector3(0, 0, 11)
export var pos_v_tail : Vector3 = Vector3(0, 1.5, 10)
export var pos_fuse : Vector3 = Vector3(0, 0, 3)
export var pos_aileron_l : Vector3 = Vector3(-8, -0.75, 1)
export var pos_aileron_r : Vector3 = Vector3( 8, -0.75, 1)
export var pos_elevator : Vector3 = Vector3(0, 0, 11)
export var pos_rudder : Vector3 = Vector3(0, 1.6, 11)
export var pos_flaps : Vector3 = Vector3( 0, -0.75, 2)
export var pos_gear : Vector3 = Vector3(0, -0.5, 0)


# Areas in m^2
export var area_wing : float = 7 
export var area_h_tail : float = 3
export var area_v_tail : float = 1.5
export var area_fuse : float = 3.5
export var area_aileron : float = 3
export var area_elevator : float = 3
export var area_rudder : float = 3
export var area_flaps : float = 3
export var area_gear : float = 2

# forces in N
var force_lift_wing : Vector3 = Vector3.ZERO
var force_lift_h_tail : Vector3 = Vector3.ZERO
var force_lift_v_tail : Vector3 = Vector3.ZERO
var force_lift_h_fuse : Vector3 = Vector3.ZERO
var force_lift_v_fuse : Vector3 = Vector3.ZERO
var force_lift_aileron_l : Vector3 = Vector3.ZERO
var force_lift_aileron_r : Vector3 = Vector3.ZERO
var force_lift_elevator : Vector3 = Vector3.ZERO
var force_lift_rudder : Vector3 = Vector3.ZERO
var force_lift_flaps : Vector3 = Vector3.ZERO

var force_drag_wing : Vector3 = Vector3.ZERO
var force_drag_h_tail : Vector3 = Vector3.ZERO
var force_drag_v_tail : Vector3 = Vector3.ZERO
var force_drag_fuse : Vector3 = Vector3.ZERO
var force_drag_aileron_l : Vector3 = Vector3.ZERO
var force_drag_aileron_r : Vector3 = Vector3.ZERO
var force_drag_elevator : Vector3 = Vector3.ZERO
var force_drag_rudder : Vector3 = Vector3.ZERO
var force_drag_flaps : Vector3 = Vector3.ZERO
var force_drag_gear : Vector3 = Vector3.ZERO

# Deflection in radians
export var deflection_control_max = PI/12
export var deflection_flaps_max = PI/6
export var angle_wing_incidence = 0.02

# Current position/state 
var current_aileron = 0
var current_elevator = 0
var current_rudder = 0
var current_flaps = 0
var current_elevator_trim = 0
var gear_current = 1

# Input values 
var input_aileron = 0
var input_elevator = 0
var input_rudder = 0
var input_flaps = 0
var input_elevator_trim = 0
var input_throttle = 0
var input_braking = 0
var gear_input = 1

# Output values
var output_aileron = 0
var output_elevator = 0
var output_rudder = 0
var output_yaw_damper = 0
var output_flaps = 0
var output_elevator_trim = 0

var flaps_max = 1
var flaps_min = -1
var input_trim_pitch_max = 1
var input_trim_pitch_min = -1
var throttle_max = 1
var throttle_min = 0
var gear_max = 1
var gear_min = 0


var deflection_rate = 1/(PI/6)
var deflection_rate_flaps = 1/(2 * PI)

var vel_local_intermediate = Vector3.ZERO
var vel_local = Vector3.ZERO
var vel_total = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_force_local(force: Vector3, pos: Vector3):
	var pos_local : Vector3
	var force_local : Vector3
	
	pos_local = self.transform.basis.xform(pos)
	force_local = self.transform.basis.xform(force)
	self.add_force(force_local, pos_local)

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
	return abs(scalar_drag_induced * sin(angle_rad)) 

func _calc_drag_parasite_coeff(angle_rad):
	return abs(scalar_drag_parasite * cos(angle_rad))
	
func _calc_lift_force(air_density_current, airspeed_true, surface_area, lift_coeff):
	return 0.5 * air_density_current * pow(airspeed_true, 2) * surface_area * lift_coeff
	
func _calc_drag_force(air_density_current, airspeed_true, surface_area, drag_coeff):
	return 0.5 * air_density_current * pow(airspeed_true, 2) * surface_area * drag_coeff


func _calc_alpha(vel_up, vel_fwd):
	return atan2(-vel_up, vel_fwd)

func _calc_beta(vel_right, vel_fwd):
	return atan2(-vel_right, vel_fwd)
	
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
func _physics_process(delta):
	
	angle_alpha = _calc_alpha(vel_local.y, vel_local.z)
	angle_beta = _calc_beta(vel_local.x, vel_local.z)
	
	angle_alpha_deg = rad2deg(angle_alpha)
	angle_beta_deg = rad2deg(angle_beta)
	
	# Lift/drag calculations (helpers for add_force_local)
	
	#Static, non-moving elements
	force_lift_wing = Vector3(0, _calc_lift_force(air_density, vel_total, area_wing, _calc_lift_coeff(angle_alpha + angle_wing_incidence)), 0)

	force_lift_h_tail = Vector3(0, _calc_lift_force(air_density, vel_total, area_h_tail, _calc_lift_coeff(angle_alpha)), 0)
	force_lift_v_tail = Vector3(_calc_lift_force(air_density, vel_total, area_v_tail, _calc_lift_coeff(angle_beta)), 0, 0)


	force_drag_wing = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_wing, _calc_drag_induced_coeff(angle_alpha + angle_wing_incidence)))

	force_drag_h_tail = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_h_tail, _calc_drag_induced_coeff(angle_alpha)))
	force_drag_v_tail = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_v_tail, _calc_drag_induced_coeff(angle_beta)))

	force_drag_fuse = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_fuse, _calc_drag_parasite_coeff(angle_alpha)))
	
#	force_drag_gear = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_gear * gear_current, _calc_drag_parasite_coeff(angle_alpha)))
	# Control forces calc.
	force_lift_aileron_l = Vector3(0, _calc_lift_force(air_density, vel_total, area_aileron, _calc_lift_coeff(angle_alpha + angle_wing_incidence + output_aileron * deflection_control_max)), 0)
	force_lift_aileron_r = Vector3(0, _calc_lift_force(air_density, vel_total, area_aileron, _calc_lift_coeff(angle_alpha + angle_wing_incidence - output_aileron * deflection_control_max)), 0)
	force_lift_elevator = Vector3(0, _calc_lift_force(air_density, vel_total, area_elevator, _calc_lift_coeff(angle_alpha - (output_elevator + input_elevator_trim) * deflection_control_max)), 0)
	force_lift_rudder = Vector3(_calc_lift_force(air_density, vel_total, area_rudder, _calc_lift_coeff(angle_beta - output_rudder * deflection_control_max)), 0, 0)
	
	force_lift_flaps = Vector3(0, _calc_lift_force(air_density, vel_total, area_flaps, _calc_lift_coeff(angle_alpha + angle_wing_incidence + output_flaps * deflection_flaps_max)), 0)
	
	force_drag_aileron_l = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_aileron, _calc_drag_induced_coeff(angle_alpha + angle_wing_incidence + output_aileron * deflection_control_max)))
	force_drag_aileron_r = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_aileron, _calc_drag_induced_coeff(angle_alpha + angle_wing_incidence - output_aileron * deflection_control_max)))
	force_drag_elevator = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_elevator, _calc_drag_induced_coeff(angle_alpha - (output_elevator + input_elevator_trim) * deflection_control_max)))
	force_drag_rudder = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_rudder, _calc_drag_induced_coeff(angle_beta + output_rudder * deflection_control_max)))
	
	force_drag_flaps = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_flaps, _calc_drag_induced_coeff(angle_alpha + angle_wing_incidence + output_flaps * deflection_flaps_max)))
	
	# Output delays
	output_aileron = interpolate_linear(output_aileron, input_aileron, deflection_rate, delta)
	output_elevator = interpolate_linear(output_elevator, input_elevator, deflection_rate, delta)
	output_rudder = interpolate_linear(output_rudder, input_rudder + output_yaw_damper, deflection_rate, delta)
	
	output_flaps = interpolate_linear(output_flaps, input_flaps, deflection_rate_flaps, delta)
	output_elevator_trim = input_elevator_trim

func _integrate_forces(_state):
	vel_total = abs(sqrt(pow(vel_local.x, 2) + pow(vel_local.y, 2) + pow(vel_local.z, 2)))
	
	vel_local_intermediate = (self.transform.basis.xform_inv(linear_velocity))
	vel_local = Vector3(vel_local_intermediate.x, vel_local_intermediate.y, -vel_local_intermediate.z)
	
	# Gravity
	add_central_force(Vector3(0, -weight, 0))
	
	# Thrust forces
	add_force_local(Vector3(0, 0, -weight/3 * input_throttle), Vector3(0, 0, 0))
	
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
