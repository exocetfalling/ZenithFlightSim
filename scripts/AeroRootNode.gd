extends Node

class_name AeroRootNode

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Control mode
# 0 = player controlled 
# 1 = AI
var control_mode = 0

# Input variables
var input_pitch = 0.00
var input_roll = 0.00
var input_yaw = 0.00
var input_thrust = 0.00

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_input(delta):
#		$'../Joint_NLG_1'.set("angular_limit_x/lower_angle", ((1 - gear_current) * 90))
#		$'../Joint_NLG_1'.set("angular_limit_x/upper_angle", ((1 - gear_current) * 90))
		pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
