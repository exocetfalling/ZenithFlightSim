@tool
extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# 1 deg of pitch equals how many px?
@export var hud_scale_vertical : float = 20

var camera_fov : float = 60

var display_distance : float = 100
var centre_position: Vector2 = Vector2(960, 540)


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
	if (get_viewport().get_camera_3d() != null):
		camera_fov = get_viewport().get_camera_3d().fov
		display_distance = get_viewport().size.y / 2 / tan(deg_to_rad(camera_fov) / 2)
		hud_scale_vertical = get_viewport().size.y / get_viewport().get_camera_3d().fov
		rotation = get_viewport().get_camera_3d().global_rotation.z
#		rect_position.y = rad2deg(get_viewport().get_camera().global_rotation.x * hud_scale_vertical)
		global_position = centre_position
		$Pivot.position.y = rad_to_deg(get_viewport().get_camera_3d().global_rotation.x) * hud_scale_vertical
	else:
		camera_fov = 60
		display_distance = 500
	# for child in get_child():
	$Pivot/MarkP05.position.y = -hud_scale_vertical * +5
	$Pivot/MarkN05.position.y = -hud_scale_vertical * -5
	
	$Pivot/MarkP10.position.y = -hud_scale_vertical * +10
	$Pivot/MarkN10.position.y = -hud_scale_vertical * -10
	
	$Pivot/MarkP20.position.y = -hud_scale_vertical * +20
	$Pivot/MarkN20.position.y = -hud_scale_vertical * -20
