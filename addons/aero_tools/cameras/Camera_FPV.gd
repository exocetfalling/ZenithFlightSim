extends Camera3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Viewport centre 
var viewport_centre : Vector2 = Vector2(960, 540)
var mouse_delta : Vector2 = Vector2(960, 540)

var timer_elapsed : float = 0
var timer_running : bool = false

var fpv_angles : Vector3 = Vector3.ZERO
var fpv_angles_deg : Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
#	DebugOverlay.stats.add_property(self, "mouse_delta", "round")
#	DebugOverlay.stats.add_property(self, "timer_running", "")
#	DebugOverlay.stats.add_property(self, "timer_elapsed", "round")
#	DebugOverlay.stats.add_property(self, "fpv_angles_deg", "round")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_input(delta)
	viewport_centre = get_viewport().size / 2
	
	AeroDataBus.aircraft_cam_rotation_deg = rotation_degrees
	fpv_angles = global_transform.basis.get_euler()
	
	if (fpv_angles.y >= 0):
		fpv_angles.y = -fpv_angles.y + 2 * PI
	else:
		fpv_angles.y = -fpv_angles.y
	
	fpv_angles_deg.x = rad_to_deg(fpv_angles.x)
	fpv_angles_deg.y = rad_to_deg(fpv_angles.y)
	fpv_angles_deg.z = rad_to_deg(fpv_angles.z)
	
	AeroDataBus.aircraft_cam_global_rotation_deg = fpv_angles_deg
	
	if (timer_running == true):
		timer_elapsed += delta


func get_input(delta):
	if (Input.is_action_pressed("cam_zoom_in")):
		fov -= 10 * delta 
	if (Input.is_action_pressed("cam_zoom_out")):
		fov += 10 * delta
	
	# Modified for mouse zoom
	if (Input.is_action_just_released("cam_zoom_in")):
		fov -= 30 * delta
	if (Input.is_action_just_released("cam_zoom_out")):
		fov += 30 * delta
	
	# Slew camera
	if (Input.is_action_just_pressed("cam_slew")):
		timer_elapsed = 0
		timer_running = true
		get_viewport().warp_mouse(viewport_centre)
	
	# If 0.05 secs pass between initial press, enable mouse look
	if (Input.is_action_pressed("cam_slew")):
		if (timer_elapsed >= 0.05):
			get_viewport().warp_mouse(viewport_centre)
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			
			mouse_delta = get_viewport().get_mouse_position() - viewport_centre
			rotation_degrees.x -= mouse_delta.y * delta
			rotation_degrees.y -= mouse_delta.x * delta
			
			# Prevent rotation from exceeding 90 deg
			rotation_degrees.x = clamp(rotation_degrees.x , -90, +90)
			rotation_degrees.y = clamp(rotation_degrees.y , -90, +90)
			mouse_delta = Vector2.ZERO
	else:
		# If rotation is less than 5 deg total, centre view
		if (rotation_degrees.length() <= 5):
			rotation_degrees.x = lerp(rotation_degrees.x, 0.0, 0.2)
			rotation_degrees.y = lerp(rotation_degrees.y, 0.0, 0.2)
		
		timer_running = false
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
