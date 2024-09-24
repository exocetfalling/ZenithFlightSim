@tool
extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@export var label_displayed : String = "Label"
@export var value_displayed : float = 0
@export var value_maximum : float = 999
@export var value_minimum : float = -999


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
	
	$Label.text = label_displayed
	
	if value_displayed == 0:
		$Value.text = "UP"
	elif value_displayed == 1:
		$Value.text = "DOWN"
	else:
		$Value.text = "TRANSIT"
