extends RigidBody

class_name AeroBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Areas, cross-sectional, in m^3
export var area_planar : Vector3 = Vector3(0, 0, 0)

# Position of centre of pressure relative to centre of mass at origin 
export var pos_COP : Vector3 = Vector3(0, 0, 0)

# Lift forces, in N
var force_lift : Vector3 = Vector3(0, 0, 0)

# Drag forces, in N
var force_drag : Vector3 = Vector3(0, 0, 0)

# Lift scalar, dimensionless
export var scalar_lift : float = 1.00

# Drag (induced) scalar, dimensionless
export var scalar_drag_induced : float = 0.05

# Drag (parasite) scalar, dimensionless
export var scalar_drag_parasite : float = 0.02

# Angle of attack (alpha)
var angle_alpha : float = 0.00


# Angle of sideslip (beta)
var angle_beta : float = 0.00


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
	return abs(0.02 * cos(angle_rad))
	
func _calc_lift_force(air_density_current, airspeed_true, surface_area, lift_coeff):
	return 0.5 * air_density_current * pow(airspeed_true, 2) * surface_area * lift_coeff
	
func _calc_drag_force(air_density_current, airspeed_true, surface_area, drag_coeff):
	return 0.5 * air_density_current * pow(airspeed_true, 2) * surface_area * drag_coeff

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
