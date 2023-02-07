extends Camera


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Viewport centre 
var viewport_centre : Vector2 = Vector2(960, 540)
var mouse_delta : Vector2 = Vector2(960, 540)
# Called when the node enters the scene tree for the first time.
func _ready():
	DebugOverlay.stats.add_property(self, "mouse_delta", "round")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_input(delta)
	viewport_centre = get_viewport().size / 2

func get_input(delta):
	if (Input.is_action_pressed("cam_zoom_in")):
		fov -= 10 * delta 
	if (Input.is_action_pressed("cam_zoom_out")):
		fov += 10 * delta
	
	if (Input.is_action_pressed("cam_slew")):
		get_viewport().warp_mouse(viewport_centre)
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

		mouse_delta = get_viewport().get_mouse_position() - viewport_centre
		
		rotation_degrees.x -= mouse_delta.y * delta
		rotation_degrees.y -= mouse_delta.x * delta
		
		rotation_degrees.x = clamp(rotation_degrees.x , -90, +90)
		rotation_degrees.y = clamp(rotation_degrees.y , -90, +90)
		mouse_delta = Vector2.ZERO
	else:
		mouse_delta = Vector2.ZERO
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if (Input.is_action_pressed("ui_left")):
		rotation_degrees.y += 20 * delta
	if (Input.is_action_pressed("ui_right")):
		rotation_degrees.y -= 20 * delta
	if (Input.is_action_pressed("ui_up")):
		rotation_degrees.x += 20 * delta
	if (Input.is_action_pressed("ui_down")):
		rotation_degrees.x -= 20 * delta
