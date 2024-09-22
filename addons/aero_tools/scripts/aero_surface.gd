extends Node3D

# Class for aerodynamic surfaces
# Be sure to set vel_body variable using parent velocity data
# Also provide atmospheric data by setting atmo_data variable
class_name AeroSurface

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

@export var length_chord_root : float = 1.00
@export var length_chord_tip : float = 1.00
@export var length_span : float = 1.00
@export var angle_sweep : float = 0.00

# Position of centre of pressure
@export var pos_COP : Vector3 = Vector3.ZERO

# Relative force position given control deflection
var pos_force_rel : Vector3 = Vector3.ZERO

# Surface translaion relative to body CG
var pos_body_rel : Vector3 = Vector3.ZERO

# Lift effeciency, varies by planform
# 0.7 for rectangular wings
@export var surface_lift_effeciency : float = 0.7

var area_surface : float = 1.00

# Lift coeffecient, dimensionless
var coeffecient_lift : float = 0.00

# Drag coeffecient, dimensionless
var coeffecient_drag : float = 0.00

# Drag coeffecient at zero lift
var coeffecient_drag_zero_lift : float = 0.005

var vel_body : Vector3 = Vector3.ZERO
var vel_surface : Vector3 = Vector3.ZERO
var vel_total : float = 0.00

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


func update_atmo_data():
	air_temperature = atmo_data.x
	air_pressure = atmo_data.y
	air_density = atmo_data.z
	
	vel_surface = ((vel_body) * self.transform.basis)
	vel_total = vel_surface.length()
	air_pressure_dynamic = 0.5 * air_density * pow(vel_total, 2)
	
	vel_delta = vel_surface - vel_body


# Lift coeffecient calculation function
func calc_lift_coeff():
	
	# Piecewise sine functions for smoothness
	# From - PI to + PI
	# Cl_max is 1.5, at 15 deg. (PI/12) AOA
	# Symmetric aerofoil
	
	if (angle_alpha <= -PI):
		coeffecient_lift = 0
	
	elif ((angle_alpha > -PI) && (angle_alpha <= -11 * PI/12)):
		coeffecient_lift = -1.5 * sin(6 * angle_alpha + PI)
	
	elif ((angle_alpha > -11 * PI/12) && (angle_alpha <= -PI/12)):
		coeffecient_lift = -1.5 * sin(1.2 * (angle_alpha + PI/2))
	
	elif ((angle_alpha > -PI/12) && (angle_alpha <= PI/12)):
		coeffecient_lift = 1.5 * sin(6 * angle_alpha)
	
	elif ((angle_alpha > PI/12) && (angle_alpha <= 11 * PI/12)):
		coeffecient_lift = -1.5 * sin(1.2 * (angle_alpha - PI/2))
	
	elif ((angle_alpha > 11 * PI/12) && (angle_alpha <= PI)):
		coeffecient_lift = -1.5 * sin(6 * angle_alpha - PI)
	
	elif (angle_alpha > PI):
		coeffecient_lift = 0
	
	else:
		coeffecient_lift = 0

func calc_drag_coeff():
	coeffecient_drag = \
		coeffecient_drag_zero_lift + (pow(coeffecient_lift, 2) / (PI * (pow(length_span, 2) / area_surface) * surface_lift_effeciency))
	
func calc_lift_magnitude():
	force_lift_surface_magnitude = \
		0.5 * air_density * pow(vel_total, 2) * area_surface * coeffecient_lift
	
func calc_drag_magnitude():
	force_drag_surface_magnitude = \
		0.5 * air_density * pow(vel_total, 2) * area_surface * coeffecient_drag


func calc_alpha_beta():
	angle_alpha = atan2(-vel_surface.y, -vel_surface.z)
	angle_beta = atan2(-vel_surface.x, -vel_surface.z)
	
	angle_alpha_deg = rad_to_deg(angle_alpha)
	angle_beta_deg = rad_to_deg(angle_beta)


func calc_force_vectors():
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
	
	pos_force_rel.x = position.x
	pos_force_rel.y = position.y + sin(-rotation.x) * pos_COP.z
	pos_force_rel.z = position.z + cos(-rotation.x) * pos_COP.z


# Called when the node enters the scene tree for the first time.
func _ready():
	area_surface = (length_chord_root + length_chord_tip) / 2 * length_span
	
	#DebugOverlay.stats.add_property(self, "surface_area", "round")
	#DebugOverlay.stats.add_property(self, "angle_alpha_deg", "round")
	#DebugOverlay.stats.add_property(self, "angle_beta_deg", "round")
	#DebugOverlay.stats.add_property(self, "coeffecient_lift", "round")
	#DebugOverlay.stats.add_property(self, "coeffecient_drag", "round")
	#DebugOverlay.stats.add_property(self, "force_lift_surface_vector", "round")
	#DebugOverlay.stats.add_property(self, "force_drag_surface_vector", "round")
	#DebugOverlay.stats.add_property(self, "force_total_surface_vector", "round")
	#DebugOverlay.stats.add_property(self, "pos_force_rel", "")
	#DebugOverlay.stats.add_property(self, "atmo_data", "round")
	pass # Replace with function body.

func _physics_process(delta):
	update_atmo_data()
	calc_alpha_beta()
	calc_lift_coeff()
	calc_drag_coeff()
	calc_lift_magnitude()
	calc_drag_magnitude()
	calc_force_vectors()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
