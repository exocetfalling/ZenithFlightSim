@tool
extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@export var label_displayed : String = "Label"
@export var value_displayed : float = 0
@export var value_maximum : float = 999
@export var value_minimum : float = -999
@export var value_digits : int = 3 # (int, 3, 5)

var value_format_string : String = "%03d"

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
	
	value_format_string = "%0" + var_to_str(value_digits) + "d"
	
	$Label.text = label_displayed
	$Value.text = (value_format_string % [value_displayed])
