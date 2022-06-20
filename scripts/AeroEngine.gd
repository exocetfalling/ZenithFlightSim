extends Spatial

class_name AeroEngine

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Thrust in N
export var thrust_rated : float = 1000
var thrust_output : float = 0.00
var thrust_output_vector : Vector3 = Vector3.ZERO

var throttle_current : float = 0.00

var vel_freestream : float = 0.00
export var vel_exhaust : float = 0.00
var vel_delta : float = 0.00

export var fan_radius : float = 1.00
var fan_area : float = 3.14
var air_density : float = 1.2 


# Called when the node enters the scene tree for the first time.
func _ready():
	fan_area = PI * pow(fan_radius, 2)
	pass # Replace with function body.

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	thrust_output = 0.5 * air_density * fan_area * vel_delta * throttle_current
	thrust_output_vector = Vector3(0, 0, -thrust_output)
	pass
