extends RigidBody

class_name AeroElement

# editor_description = 'Aerodynamic element (wing, fuselage, etc.).' 

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Air temperature, K
var air_temperature : float = 288.0

# Air pressure, Pa
var air_pressure : float = 101325

# Air density, kg/m^3
var air_density = 1.2

# Is the element an airfoil?
# If it is, calculate aero forces for airfoil shapes
# If not, use a non-airfoil approximation
export var is_airfoil : bool = true 

# Wing span in m
export var element_span : float = 1.00

# Areas in m^2
export var element_area_side : float = 1.00
export var element_area_top : float = 1.00
export var element_area_front : float = 1.00

# Position of centre of pressure relative to centre of mass
export var pos_COP : Vector3 = Vector3(0, 0, 0)

# Lift scalar, dimensionless
export var scalar_lift : float = 1.00

# Drag (induced) scalar, dimensionless
export var scalar_drag_induced : float = 1.00

# Lift effeciency, varies by planform
# 0.7 for rectangular wings
export var element_lift_effeciency : float = 0.7

# Lift coeffecient, dimensionless
var coeffecient_lift : float = 0.00

# Drag coeffecient, dimensionless
var coeffecient_drag : float = 0.00

# Drag coeffecient at zero lift
var coeffecient_drag_zero_lift : float = 0.02

# Angle of attack (alpha)
var angle_alpha : float = 0.00
var angle_alpha_deg : float = 0.00

# Angle of sideslip (beta)
var angle_beta : float = 0.00
var angle_beta_deg : float = 0.00

# forces in N
var force_lift_element_magnitude : float = 0.00
var force_drag_element_magnitude : float = 0.00

var force_lift_element_vector : Vector3 = Vector3.ZERO
var force_drag_element_vector : Vector3 = Vector3.ZERO

# Velocities in m s^-1
var vel_local : Vector3 = Vector3.ZERO
var vel_total : float = 0.00

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
		

func _calc_drag_coeff(lift_coeff, drag_coeff_zero_lift, wing_span, wing_area, wing_effeciency):
	return ((pow(lift_coeff, 2) / (PI * (pow(wing_span, 2) / wing_area) * wing_effeciency)))
	
func _calc_lift_force(air_density_current, airspeed_true, surface_area, lift_coeff):
	return 0.5 * air_density_current * pow(airspeed_true, 2) * surface_area * lift_coeff
	
func _calc_drag_force(air_density_current, airspeed_true, surface_area, drag_coeff):
	return 0.5 * air_density_current * pow(airspeed_true, 2) * surface_area * drag_coeff
	
func _calc_atmo_properties(height_metres):
	# Store atmospheric properties as Vector3
	# X value is air temperature, deg K
	# Y value is air pressure, Pa
	# Z value is air density, kg m^-3
	
	# From https://www.grc.nasa.gov/www/k-12/airplane/atmosmet.html
	
	var atmo_properties : Vector3
	if (height_metres <= 11000):
		atmo_properties.x = 288.19 - 0.00649 * height_metres
		atmo_properties.y = 101.29 * pow((atmo_properties.x/288.08), 5.256)
		
	elif ((height_metres > 11000) && (height_metres <= 25000)): 
		atmo_properties.x = 216.69
		atmo_properties.y = 22.65 * exp(1.73 - 0.000157 * height_metres)
	
	elif (height_metres > 25000):
		atmo_properties.x = 141.94 + .00299 * height_metres
		atmo_properties.y = 2.488 * pow((atmo_properties.x/ 216.6), -11.388)
	
	else:
		atmo_properties.x = 101290
		atmo_properties.y = 288.19
	
	atmo_properties.z = atmo_properties.y / (0.2869 * atmo_properties.y)
	
	return atmo_properties

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Called every frame. 'delta' is the elapsed time since the previous physics frame.
func _physics_process(delta):
	vel_local = self.transform.basis.xform(linear_velocity)
	vel_total = vel_local.length()
	
	air_temperature = _calc_atmo_properties(global_transform.origin.y).x
	air_pressure = _calc_atmo_properties(global_transform.origin.y).y
	air_density = _calc_atmo_properties(global_transform.origin.y).z
	
	angle_alpha = atan2(-vel_local.y, vel_local.z)
	angle_beta = atan2(-vel_local.x, vel_local.z)
	
	angle_alpha_deg = rad2deg(angle_alpha)
	angle_beta_deg = rad2deg(angle_beta)
	
	coeffecient_lift = _calc_lift_coeff(angle_alpha)
	coeffecient_drag = \
		_calc_drag_coeff(\
			coeffecient_lift, \
			coeffecient_drag_zero_lift, \
			element_span, \
			element_area_top, \
			element_lift_effeciency)
	
	force_lift_element_magnitude = \
		_calc_lift_force(air_density, vel_total, element_area_top, coeffecient_lift)
	force_drag_element_magnitude = \
		_calc_drag_force(air_density, vel_total, element_area_top, coeffecient_drag) 
	
	force_lift_element_vector = \
		Vector3(0, force_lift_element_magnitude, 0)
	
	force_drag_element_vector = \
		Vector3(\
			(sin(angle_beta) * force_drag_element_magnitude), \
			0, \
			(cos(angle_beta) * force_drag_element_magnitude) \
			)
	
	add_force_local(force_lift_element_vector, pos_COP)
	add_force_local(force_drag_element_vector, pos_COP)
	pass
