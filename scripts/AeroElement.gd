extends RigidBody

class_name AeroElement

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
