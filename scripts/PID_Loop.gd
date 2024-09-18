extends Node

class_name PID_Loop
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var value_previous = 0.00
var value_delta = 0.00

var proportional = 0.00
var integral = 0.00
var derivative = 0.00

@export var term_P = 0.00
@export var term_I = 0.00
@export var term_D = 0.00

var output_P = 0.00
var output_I = 0.00
var output_D = 0.00
var output_total = 0.00

func calc_PID(value_setpoint, value_current, time_delta):
	value_previous = value_current
	value_current = value_current
	
	value_delta = (value_current - value_previous)
	
	# Proportional output
	proportional = value_setpoint - value_current
	output_P = term_P * proportional
	
	# Integral output 
	integral = integral + value_delta * time_delta
	output_I = term_I * integral
	
	# Derivative output
	derivative = value_delta / time_delta
	output_D = term_D * derivative
	
	# Total output
	output_total = output_P + output_I + output_D
	
	return output_total

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	DebugOverlay.stats.add_property(self, "proportional", "round")
#	DebugOverlay.stats.add_property(self, "proportional", "round")
#	DebugOverlay.stats.add_property(self, "output_P", "round")
#	DebugOverlay.stats.add_property(self, "output_I", "round")
#	DebugOverlay.stats.add_property(self, "output_D", "round")
#	DebugOverlay.stats.add_property(self, "output_total", "round")
	pass # Replace with function body.
	
