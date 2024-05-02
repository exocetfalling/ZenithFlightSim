tool
extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# 1 deg of pitch equals how many px?
export var hud_scale_vertical : float = 20

var camera_fov : float = 60

var display_distance : float = 100

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
	if (get_viewport().get_camera() != null):
		camera_fov = get_viewport().get_camera().fov
		display_distance = get_viewport().size.y / 2 / tan(deg2rad(camera_fov) / 2)
		hud_scale_vertical = get_viewport().size.y / get_viewport().get_camera().fov
		rect_rotation = rad2deg(get_viewport().get_camera().global_rotation.z)
#		rect_position.y = rad2deg(get_viewport().get_camera().global_rotation.x * hud_scale_vertical)
		rect_position.y = \
			rad2deg(get_viewport().get_camera().global_rotation.x \
			* hud_scale_vertical) \
			* cos(get_viewport().get_camera().global_rotation.z)
		rect_position.x = -rect_position.y * tan(get_viewport().get_camera().global_rotation.z)
	else:
		camera_fov = 60
		display_distance = 500
	# for child in get_child():
	$MarkP10.rect_position.y = -hud_scale_vertical * +10
	$MarkN10.rect_position.y = -hud_scale_vertical * -10
	
	$MarkP20.rect_position.y = -hud_scale_vertical * +20
	$MarkN20.rect_position.y = -hud_scale_vertical * -20
