extends Spatial

class_name AeroEngine

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Thrust in N
export var thrust_rated : float = 1000
var thrust_output : float = 0.00

var vel_freestream : float = 0.00
var vel_exhaust : float = 0.00

export var fan_radius : float = 1.00
var fan_area : float
var air_density : float
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	pass
