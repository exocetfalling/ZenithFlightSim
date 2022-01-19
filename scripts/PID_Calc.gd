extends Node

class_name PID_Calc
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var value_previous = 0.00
var value_delta = 0.00

var proportional = 0.00
var integral = 0.00
var derivative = 0.00

var value_error = 0.00

export var term_P = 0.00
export var term_I = 0.00
export var term_D = 0.00

var output_P = 0.00
var output_I = 0.00
var output_D = 0.00

func calc_proportional_output(value_setpoint, value_current, time_delta):
	value_error = value_setpoint - value_current
	proportional = value_error
	output_P = term_P * proportional
	
	return output_P

func calc_integral_output(value_setpoint, value_current, time_delta):
	value_previous = value_current
	value_current = value_current
	
	value_delta = (value_current - value_previous)
	
	# Integral output 
	integral = integral + value_delta * time_delta
	output_I = term_I * integral
	
	return output_I

func calc_derivative_output(value_setpoint, value_current, time_delta):
	value_previous = value_current
	value_current = value_current
	
	value_delta = (value_current - value_previous)
	if (time_delta == 0):
		time_delta = 0.0167
	derivative = value_delta / time_delta
	output_D = term_D * derivative
	return output_D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	DebugOverlay.stats.add_property(self, "proportional", "round")
#	DebugOverlay.stats.add_property(self, "proportional", "round")
#	DebugOverlay.stats.add_property(self, "output_P", "round")
#	DebugOverlay.stats.add_property(self, "output_I", "round")
#	DebugOverlay.stats.add_property(self, "output_D", "round")
#	DebugOverlay.stats.add_property(self, "output_total", "round")
	pass # Replace with function body.
	
