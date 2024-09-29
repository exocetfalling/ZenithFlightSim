extends RigidBody3D

class_name AeroElement

# editor_description = 'Aerodynamic element (wing, fuselage, etc.).' 

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

@export var element_length : float = 1.00
@export var element_radius : float = 1.00
var element_ref_area : float = 0

# Position of centre of pressure
@export var pos_COP : Vector3 = Vector3.ZERO

# Relative force position given control deflection
var pos_force_rel : Vector3 = Vector3.ZERO

# Surface translaion relative to body CG
var pos_body_rel : Vector3 = Vector3.ZERO

# Drag coeffecient, dimensionless
var coeffecient_drag : float = 0.00

var vel_body : Vector3 = Vector3.ZERO
var vel_surface : Vector3 = Vector3.ZERO
var linear_velocity_total : float = 0.00

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
var force_drag_element_magnitude : float = 0.00

var force_drag_element_vector : Vector3 = Vector3.ZERO
var force_total_element_vector : Vector3 = Vector3.ZERO

func _calc_drag_coeff(alpha_rad, beta_rad):
	return \
		( \
			0.2 * sin(sqrt(pow(alpha_rad, 2) + pow(beta_rad, 2)))
		)

func _calc_drag_force(air_density_current, airspeed_true, surface_area, drag_coeff):
	return 0.5 * air_density_current * pow(airspeed_true, 2) * surface_area * drag_coeff

func _calc_alpha(vel_up, vel_fwd):
	return atan2(-vel_up, vel_fwd)

func _calc_beta(vel_right, vel_fwd):
	return atan2(-vel_right, vel_fwd)

# Called when the node enters the scene tree for the first time.
func _ready():
	element_ref_area = PI * pow(element_radius, 2)
	
#	DebugOverlay.stats.add_property(self, "surface_area", "round")
#	DebugOverlay.stats.add_property(self, "angle_alpha_deg", "round")
#	DebugOverlay.stats.add_property(self, "coeffecient_lift", "round")
#	DebugOverlay.stats.add_property(self, "coeffecient_drag", "round")
#	DebugOverlay.stats.add_property(self, "force_lift_surface_vector", "round")
#	DebugOverlay.stats.add_property(self, "force_drag_surface_vector", "round")
#	DebugOverlay.stats.add_property(self, "force_total_surface_vector", "round")
#	DebugOverlay.stats.add_property(self, "pos_force_rel", "")
	pass # Replace with function body.

func _physics_process(delta):	
	air_pressure_dynamic = 0.5 * air_density * pow(linear_velocity_total, 2)
	
	vel_surface = ((vel_body) * self.transform.basis)
	linear_velocity_total = vel_surface.length()
	
	vel_delta = vel_surface - vel_body
	
	angle_alpha = _calc_alpha(vel_surface.y, -vel_surface.z)
	angle_beta = _calc_beta(vel_surface.x, -vel_surface.z)
	
	angle_alpha_deg = rad_to_deg(angle_alpha)
	angle_beta_deg = rad_to_deg(angle_beta)
	
	coeffecient_drag = \
		_calc_drag_coeff(angle_alpha, angle_beta)
	
	force_drag_element_magnitude = \
		_calc_drag_force(air_density, linear_velocity_total, element_ref_area, coeffecient_drag) 
	
	force_drag_element_vector = \
		Vector3(\
			(sin(angle_beta) * force_drag_element_magnitude), \
			0, \
			(cos(angle_beta) * force_drag_element_magnitude) \
			)
		
	force_drag_element_vector = force_drag_element_vector.rotated(Vector3.RIGHT, -angle_alpha)
	
	force_total_element_vector = force_drag_element_vector
	
	pos_force_rel.x = position.x
	pos_force_rel.y = position.y + sin(-rotation.x) * pos_COP.z
	pos_force_rel.z = position.z + cos(-rotation.x) * pos_COP.z

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
