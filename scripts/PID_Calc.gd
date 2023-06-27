extends Node

class_name PID_Calc
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var value_previous = 0.00
var value_delta = 0.00
var time_delta = 0.0167

var proportional = 0.00
var integral = 0.00
var derivative = 0.00

var value_error_current = 0.00
var value_error_previous = 0.00
var value_error_delta = 0.00

export var term_P = 0.00
export var term_I = 0.00
export var term_D = 0.00

# Maximum integral value, beyond whick clamping occurs
export var integral_max = 100.00

var output_P = 0.00
var output_I = 0.00
var output_D = 0.00
var output_total = 0.00

# Real-time tuning

# Will it be tuned at runtime?
export var param_tuning_active = true

# Enum-like thing?
# 0 = P
# 1 = I
# 2 = D 

var param_select = 0
var param_value = 0
var param_delta_step = 0.001
var param_default = 0

var param_default_p : float = 0.00
var param_default_i : float = 0.00
var param_default_d : float = 0.00

var reset_integral : bool = false

#func calc_proportional_output(value_setpoint, value_current, time_delta):
#	value_error = value_setpoint - value_current
#	proportional = value_error
#	output_P = term_P * proportional
#
#	return output_P
#
#func calc_integral_output(value_setpoint, value_current, time_delta):
#	value_previous = value_current
#	value_current = value_current
#
#	value_delta = (value_current - value_previous)
#
#	# Integral output 
#	integral = integral + value_delta * time_delta
#	output_I = term_I * integral
#
#	return output_I
#
#func calc_derivative_output(value_setpoint, value_current, time_delta):
#	value_previous = value_current
#	value_current = value_current
#
#	value_delta = (value_current - value_previous)
#	if (time_delta == 0):
#		time_delta = 0.0167
#	derivative = value_delta / time_delta
#	output_D = term_D * derivative
#	return output_D

func calc_PID_output(value_setpoint, value_current):
	
	# Output for proportional term 
	value_error_current = value_setpoint - value_current
	proportional = value_error_current
	output_P = term_P * proportional
	
	value_previous = value_current
	value_current = value_current
	
	value_delta = (value_current - value_previous)
	
#	if (time_delta == 0):
#		time_delta = 0.0167
	
	# Output for integral term 
	integral += value_error_current * time_delta
	integral = clamp(integral, -integral_max, integral_max)
	output_I = term_I * integral

	# Output for derivative term 

	value_error_delta = (value_error_current - value_error_previous)
	value_error_previous = value_error_current
	derivative = value_error_delta / time_delta

	output_D = term_D * derivative
	
	output_total = output_P + output_I + output_D

	return output_total


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	param_default_p = term_P
	param_default_i = term_I
	param_default_d = term_D
	
	if (param_tuning_active == true):
		DebugOverlay.stats.add_property(self, "output_P", "round")
		DebugOverlay.stats.add_property(self, "output_I", "round")
		DebugOverlay.stats.add_property(self, "output_D", "round")
		DebugOverlay.stats.add_property(self, "term_P", "round")
		DebugOverlay.stats.add_property(self, "term_I", "round")
		DebugOverlay.stats.add_property(self, "term_D", "round")
		DebugOverlay.stats.add_property(self, "output_total", "round")
		DebugOverlay.stats.add_property(self, "param_select", "")
		DebugOverlay.stats.add_property(self, "time_delta", "")
		DebugOverlay.stats.add_property(self, "reset_integral", "")
		pass # Replace with function body.
	

func get_input_keyboard(delta):
	if (param_tuning_active == true):
		
		# Select and loop params using events
		if Input.is_action_just_pressed("PID_term_next"):
			param_select += 1
			param_value = param_default
		if Input.is_action_just_pressed("PID_term_prev"):
			param_select -= 1
			param_value = param_default
			
		if (param_select > 2):
			param_select = 0
		if (param_select < 0):
			param_select = 2
		
		# Param inc/dec
		if Input.is_action_pressed("PID_term_inc"):
			param_value += param_delta_step
		if Input.is_action_pressed("PID_term_dec"):
			param_value -= param_delta_step
		
		# Set the parameter according to selection 
		if (param_select == 0):
			term_P = param_value
			param_default_p = term_P
		if (param_select == 1):
			term_I = param_value
			param_default_i = term_I
		if (param_select == 2):
			term_D = param_value
			param_default_d = term_D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	get_input_keyboard(delta)

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta): 
	time_delta = delta
