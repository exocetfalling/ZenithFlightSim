extends Spatial

class_name AeroSurface

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var length_chord_root : float = 1.00
export var length_chord_tip : float = 1.00
export var length_span : float = 1.00
export var angle_sweep : float = 0.00

# Position of centre of pressure
export var pos_COP : Vector3 = Vector3.ZERO

# Relative force position given control deflection
var pos_force_rel : Vector3 = Vector3.ZERO

# Surface translaion relative to body CG
var pos_body_rel : Vector3 = Vector3.ZERO

# Lift effeciency, varies by planform
# 0.7 for rectangular wings
export var surface_lift_effeciency : float = 0.7

var surface_area : float = 1.00

# Lift coeffecient, dimensionless
var coeffecient_lift : float = 0.00

# Drag coeffecient, dimensionless
var coeffecient_drag : float = 0.00

# Drag coeffecient at zero lift
var coeffecient_drag_zero_lift : float = 0.02

var vel_body : Vector3 = Vector3.ZERO
var vel_surface : Vector3 = Vector3.ZERO
var vel_total : float = 0.00

var vel_delta = Vector3.ZERO

var angle_alpha = 0
var angle_alpha_deg = 0
var angle_beta = 0
var angle_beta_deg = 0

# Air temperature, K
var air_temperature : float = 288.0

# Air pressure, Pa
var air_pressure : float = 101325

# Dynamic pressure, Pa
var air_pressure_dynamic : float = 0.00

# Air density, kg/m^3
var air_density = 1.2

# forces in N
var force_lift_surface_magnitude : float = 0.00
var force_drag_surface_magnitude : float = 0.00

var force_lift_surface_vector : Vector3 = Vector3.ZERO
var force_drag_surface_vector : Vector3 = Vector3.ZERO
var force_total_surface_vector : Vector3 = Vector3.ZERO

# Lift coeffecient calculation function
func _calc_lift_coeff(angle_alpha_rad):
#	var x1 = -PI
#	var y1 = 0
#	var x2 = -PI/12
#	var y2 = -1.5
#	var x3 = PI/12
#	var y3 = 1.5
#	var x4 = PI
#	var y4 = 0
#
#	var a = (y2 - y1) / (x2 - x1)
#	var b = (y3 - y2) / (x3 - x2)
#	var c = (y4 - y3) / (x4 - x3)
#
#	if (angle_alpha_rad < x1):
#		return (a * (angle_alpha_rad + 2 * PI - x1) + y1)
#
#	elif ((angle_alpha_rad > x1) and (angle_alpha_rad <= x2)):
#		return (a * (angle_alpha_rad - x1) + y1)
#
#	elif ((angle_alpha_rad > x2) and (angle_alpha_rad <= x3)):
#		return (b * (angle_alpha_rad - x2) + y2)
#
#	elif ((angle_alpha_rad > x3) and (angle_alpha_rad <= x4)):
#		return (c * (angle_alpha_rad - x3) + y3)
#
#	elif (angle_alpha_rad > x4):
#		return (a * (angle_alpha_rad - 2 * PI - x1) + y1)
#
#	else:
#		return 0

	if (angle_alpha_rad <= -PI):
		return 0
	
	elif ((angle_alpha_rad > -PI) && (angle_alpha_rad <= -PI/12)):
		return -3/2 * cos(6/11 * (angle_alpha_rad + PI/12))
	
	elif ((angle_alpha_rad > -PI/12) && (angle_alpha_rad <= PI/12)):
		return 3/2 * sin(6 * angle_alpha_rad)
	
	elif ((angle_alpha_rad > PI/12) && (angle_alpha_rad <= PI)):
		return 3/2 * cos(6/11 * (angle_alpha_rad - PI/12))
	
	elif (angle_alpha_rad > PI):
		return 0
	
	else:
		return 0

func _calc_drag_coeff(lift_coeff, drag_coeff_zero_lift, wing_span, wing_area, wing_effeciency):
	return (drag_coeff_zero_lift + (pow(lift_coeff, 2) / (PI * (pow(wing_span, 2) / wing_area) * wing_effeciency)))
	
func _calc_lift_force(air_density_current, airspeed_true, surface_area, lift_coeff):
	return 0.5 * air_density_current * pow(airspeed_true, 2) * surface_area * lift_coeff
	
func _calc_drag_force(air_density_current, airspeed_true, surface_area, drag_coeff):
	return 0.5 * air_density_current * pow(airspeed_true, 2) * surface_area * drag_coeff

func _calc_alpha(vel_up, vel_fwd):
	return atan2(-vel_up, vel_fwd)

func _calc_beta(vel_right, vel_fwd):
	return atan2(-vel_right, vel_fwd)

func _calc_atmo_properties(height_metres):
	# Store atmospheric properties as Vector3
	# X value is air temperature, deg C
	# Y value is air pressure, kPa
	# Z value is air density, kg m^-3
	
	# From https://en.wikipedia.org/wiki/Density_of_air#Variation_with_altitude
	
	var atmo_properties : Vector3 = Vector3(288.15, 101325, 1.20)
	
	var p_0 = 101325 # Sea level standard atmospheric pressure, Pa
	var T_0 = 288.15 # Sea level standard temperature, K
	var g = 9.80665 # Earth-surface gravitational acceleration, m s^-2
	var L = 0.0065 # Temperature lapse rate, K m^-1
	var R = 8.31446 # Ideal (universal) gas constant, J K^-1 mol^-1
	var M = 0.0289652 # molar mass of dry air, kg mol^-1
	
	
	atmo_properties.x = \
		T_0 - L * height_metres
	
	atmo_properties.y = \
		p_0 * pow((1 - (L * height_metres / T_0)), (g * M / R / L))
	
	atmo_properties.z = \
		(atmo_properties.y * M) / (R * atmo_properties.x)
	
	return atmo_properties

# Called when the node enters the scene tree for the first time.
func _ready():
	surface_area = (length_chord_root + length_chord_tip) / 2 * length_span
	
#	DebugOverlay.stats.add_property(self, "vel_surface", "round")
#	DebugOverlay.stats.add_property(self, "angle_alpha_deg", "round")
#	DebugOverlay.stats.add_property(self, "force_lift_surface_vector", "round")
#	DebugOverlay.stats.add_property(self, "force_drag_surface_vector", "round")
#	DebugOverlay.stats.add_property(self, "force_total_surface_vector", "round")
#	DebugOverlay.stats.add_property(self, "pos_force_rel", "")
	pass # Replace with function body.

func _physics_process(delta):
	air_temperature = _calc_atmo_properties(global_transform.origin.y).x
	air_pressure = _calc_atmo_properties(global_transform.origin.y).y
	air_density = _calc_atmo_properties(global_transform.origin.y).z
	
	air_pressure_dynamic = 0.5 * air_density * pow(vel_total, 2)
	
	vel_surface = (self.transform.basis.xform_inv(vel_body))
	vel_total = vel_surface.length()
	
	vel_delta = vel_surface - vel_body
	
	angle_alpha = _calc_alpha(vel_surface.y, -vel_surface.z)
	angle_beta = _calc_beta(vel_surface.x, -vel_surface.z)
	
	angle_alpha_deg = rad2deg(angle_alpha)
	angle_beta_deg = rad2deg(angle_beta)
	
	coeffecient_lift = _calc_lift_coeff(angle_alpha)
	coeffecient_drag = \
		_calc_drag_coeff(\
			coeffecient_lift, \
			coeffecient_drag_zero_lift, \
			length_span, \
			surface_area, \
			surface_lift_effeciency)
	
	force_lift_surface_magnitude = \
		_calc_lift_force(air_density, vel_total, surface_area, coeffecient_lift)
	force_drag_surface_magnitude = \
		_calc_drag_force(air_density, vel_total, surface_area, coeffecient_drag) 
	
	force_lift_surface_vector = \
		Vector3(0, force_lift_surface_magnitude, 0)
	
	force_drag_surface_vector = \
		Vector3(\
			(sin(angle_beta) * force_drag_surface_magnitude), \
			0, \
			(cos(angle_beta) * force_drag_surface_magnitude) \
			)
	
	force_total_surface_vector = \
		(force_lift_surface_vector + force_drag_surface_vector)
	
	force_drag_surface_vector = force_drag_surface_vector.rotated(Vector3.RIGHT, -angle_alpha)
	
	pos_force_rel.x = translation.x
	pos_force_rel.y = translation.y + sin(-rotation.x) * pos_COP.z
	pos_force_rel.z = translation.z + cos(-rotation.x) * pos_COP.z

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
