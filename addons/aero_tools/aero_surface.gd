extends Spatial

# Class for aerodynamic surfaces
# Be sure to set vel_body variable using parent velocity data
# Also provide atmospheric data by setting atmo_data variable
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
var coeffecient_drag_zero_lift : float = 0.005

var vel_body : Vector3 = Vector3.ZERO
var vel_surface : Vector3 = Vector3.ZERO
var linear_velocity_total : float = 0.00

var vel_delta = Vector3.ZERO

var angle_alpha = 0
var angle_alpha_deg = 0
var angle_beta = 0
var angle_beta_deg = 0

var atmo_data : Vector3 = Vector3(288, 101325, 1.2)

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
	
	# Piecewise sine functions for smoothness
	# From - PI to + PI
	# Cl_max is 1.5, at 15 deg. (PI/12) AOA
	# Symmetric aerofoil
	
	if (angle_alpha_rad <= -PI):
		return 0
	
	elif ((angle_alpha_rad > -PI) && (angle_alpha_rad <= -11 * PI/12)):
		return -1.5 * sin(6 * angle_alpha_rad + PI)
	
	elif ((angle_alpha_rad > -11 * PI/12) && (angle_alpha_rad <= -PI/12)):
		return -1.5 * sin(1.2 * (angle_alpha_rad + PI/2))
	
	elif ((angle_alpha_rad > -PI/12) && (angle_alpha_rad <= PI/12)):
		return 1.5 * sin(6 * angle_alpha_rad)
	
	elif ((angle_alpha_rad > PI/12) && (angle_alpha_rad <= 11 * PI/12)):
		return -1.5 * sin(1.2 * (angle_alpha_rad - PI/2))
	
	elif ((angle_alpha_rad > 11 * PI/12) && (angle_alpha_rad <= PI)):
		return -1.5 * sin(6 * angle_alpha_rad - PI)
	
	elif (angle_alpha_rad > PI):
		return 0
	
	else:
		return 0

func _calc_drag_coeff(lift_coeff, drag_coeff_zero_lift, wing_span, wing_area, wing_effeciency):
	return \
		( \
			drag_coeff_zero_lift + (pow(lift_coeff, 2) / (PI * (pow(wing_span, 2) / wing_area) * wing_effeciency))
		)
	
func _calc_lift_force(air_density_current, airspeed_true, surface_area, lift_coeff):
	return 0.5 * air_density_current * pow(airspeed_true, 2) * surface_area * lift_coeff
	
func _calc_drag_force(air_density_current, airspeed_true, surface_area, drag_coeff):
	return 0.5 * air_density_current * pow(airspeed_true, 2) * surface_area * drag_coeff

func _calc_alpha(vel_up, vel_fwd):
	return atan2(-vel_up, vel_fwd)

func _calc_beta(vel_right, vel_fwd):
	return atan2(-vel_right, vel_fwd)

# Called when the node enters the scene tree for the first time.
func _ready():
	surface_area = (length_chord_root + length_chord_tip) / 2 * length_span
	
#	DebugOverlay.stats.add_property(self, "surface_area", "round")
#	DebugOverlay.stats.add_property(self, "angle_alpha_deg", "round")
#	DebugOverlay.stats.add_property(self, "coeffecient_lift", "round")
#	DebugOverlay.stats.add_property(self, "coeffecient_drag", "round")
#	DebugOverlay.stats.add_property(self, "force_lift_surface_vector", "round")
#	DebugOverlay.stats.add_property(self, "force_drag_surface_vector", "round")
#	DebugOverlay.stats.add_property(self, "force_total_surface_vector", "round")
#	DebugOverlay.stats.add_property(self, "pos_force_rel", "")
#	DebugOverlay.stats.add_property(self, "atmo_data", "round")
	pass # Replace with function body.

func _physics_process(delta):
	air_temperature = atmo_data.x
	air_pressure = atmo_data.y
	air_density = atmo_data.z
	
	air_pressure_dynamic = 0.5 * air_density * pow(linear_velocity_total, 2)
	
	vel_surface = (self.transform.basis.xform_inv(vel_body))
	linear_velocity_total = vel_surface.length()
	
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
		_calc_lift_force(air_density, linear_velocity_total, surface_area, coeffecient_lift)
	force_drag_surface_magnitude = \
		_calc_drag_force(air_density, linear_velocity_total, surface_area, coeffecient_drag) 
	
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
