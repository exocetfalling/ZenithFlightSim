tool
extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var mark_line_length : float = 1000
export var mark_line_width : float = 5
export var mark_pitch_value : float = 10
export var mark_pitch_value_visible : bool = true
export var mark_line_gap : float = 300

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		pass
		# Code to execute in editor.

	if not Engine.editor_hint:
		pass
		# Code to execute in game.

	# Code to execute both in editor and in game.
	$MarkLineL.width = mark_line_width
	$MarkLineL.points[0].x = -mark_line_length / 2
	$MarkLineL.points[1].x = -mark_line_length / 2 + (mark_line_length - mark_line_gap) / 2
	
	$MarkLineR.width = mark_line_width
	$MarkLineR.points[0].x = +mark_line_length / 2
	$MarkLineR.points[1].x = +mark_line_length / 2 - (mark_line_length - mark_line_gap) / 2
	
	$LabelNode1.position.x = -(mark_line_length/2 + 50)
	$LabelNode2.position.x = +(mark_line_length/2 + 50)
#	get_node("Speed_Data").text = ("SPD\n%03d" % [AeroDataBus.aircraft_spd_indicated])
	$LabelNode1/Label.text = ("%02d" % [mark_pitch_value])
	$LabelNode2/Label.text = ("%02d" % [mark_pitch_value])
	
	if (mark_pitch_value_visible == true):
		$LabelNode1.visible = true
		$LabelNode2.visible = true
	else:
		$LabelNode1.visible = false
		$LabelNode2.visible = false

