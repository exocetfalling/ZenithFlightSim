@tool
extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@export var label_displayed : String = "Label"
@export var value_displayed : float = 0
@export var value_maximum : float = 999
@export var value_minimum : float = -999
@export var value_digits_int : int = 3 # (int, 3, 5)
@export var value_digits_frac : int = 0 # (int, 3, 5)
@export var value_signed: bool = false
@export var value_float: bool = false

#var value_signed_str: String = ""
var format_string : String = "%03d"
var format_string_sign : String = "%0"
var format_string_type : String = "d"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		pass
		# Code to execute in editor.

	if not Engine.is_editor_hint():
		pass
		# Code to execute in game.

	# Code to execute both in editor and in game.
	value_displayed = clamp(value_displayed, value_minimum, value_maximum)
	
	if value_signed == false:
		format_string_sign = "%0"
	else:
		format_string_sign = "%+0"
	
	if value_digits_frac < 1:
		format_string_type = "d"
	else:
		format_string_type = "f"
	
	format_string = format_string_sign + var_to_str(value_digits_int) + "." + var_to_str(value_digits_frac) + "f"
	
	$Label.text = label_displayed
	$Value.text = (format_string % [value_displayed])
