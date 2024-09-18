extends Node3D

@export var target: NodePath

@export var rotation_speed = PI/2 # (float, 0.0, 2.0)

# mouse properties
@export var mouse_control: bool = false
@export var mouse_sensitivity = 0.005 # (float, 0.001, 0.1)
@export var invert_y: bool = false
@export var invert_x: bool = false

# zoom settings
@export var max_zoom: float = 3.0
@export var min_zoom: float = 0.4
@export var zoom_speed = 0.09 # (float, 0.05, 1.0)

var zoom = 1.0

func _unhandled_input(event):
	if Input.is_action_pressed("cam_slew"):
#		Input.warp_mouse_position(Vector2(960, 540))
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return

	if mouse_control and event is InputEventMouseMotion:
		if event.relative.x != 0:
			var dir = 1 if invert_x else -1
			$Gimbal_X.rotate_object_local(Vector3.UP, dir * event.relative.x * mouse_sensitivity)
		if event.relative.y != 0:
			var dir = 1 if invert_y else -1
			var y_rotation = clamp(event.relative.y, -30, 30)
			$Gimbal_X/Gimbal_Y.rotate_object_local(Vector3.RIGHT, dir * y_rotation * mouse_sensitivity)

func get_input_keyboard(delta):
	# Rotate outer gimbal around y axis
	if Input.is_action_pressed("cam_right"):
		$Gimbal_X/Gimbal_Y.rotation.y += 0.01
	if Input.is_action_pressed("cam_left"):
		$Gimbal_X/Gimbal_Y.rotation.y -= 0.01

	# Rotate inner gimbal around local x axis
	if Input.is_action_pressed("cam_up"):
		$Gimbal_X.rotation.x += 0.01
	if Input.is_action_pressed("cam_down"):
		$Gimbal_X.rotation.x -= 0.01
	if Input.is_action_pressed("cam_zoom_in"):
		zoom += zoom_speed
	if Input.is_action_pressed("cam_zoom_out"):
		zoom -= zoom_speed
	zoom = clamp(zoom, min_zoom, max_zoom)
func _process(delta):
	get_input_keyboard(delta)
	$Gimbal_X.rotation.x = clamp($Gimbal_X.rotation.x, -1.0, 1.0)
	$Gimbal_X/Gimbal_Y.rotation.y = clamp($Gimbal_X/Gimbal_Y.rotation.y, -1.0, 1.0)
	$Gimbal_X/Gimbal_Y/Camera_FPV.fov = 70 / zoom
	if target:
		global_transform.origin = get_node(target).global_transform.origin

	$HMD.HMD_angles.x = $Gimbal_X.rotation.x
	$HMD.HMD_angles.y = -$Gimbal_X/Gimbal_Y.rotation.y
	$HMD.cam_fov = $Gimbal_X/Gimbal_Y/Camera_FPV.fov
