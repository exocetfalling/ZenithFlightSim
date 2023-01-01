extends Node

class_name Derivative_Calc
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var x_previous = 0
var x_current = 0
var x_delta = 0
var time_delta
var derivative

func calc_derivative(value_current, delta):
	x_previous = x_current
	x_current = value_current
	
	x_delta = (x_current - x_previous)
	time_delta = delta
	if (time_delta == 0):
		time_delta = 0.0167
	derivative = x_delta / time_delta
	return derivative

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
