extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Angles in radians unless stated otherwise

# Euler angles for body (pitch, yaw, roll) 
var body_angles : Vector3 = Vector3(0, 0, 0)
var body_angles_deg : Vector3 = Vector3(0, 0, 0)

# Euler angles for HMD relative to body (pitch, yaw, roll) 
var HMD_angles : Vector3 = Vector3(0, 0, 0)
var HMD_angles_deg : Vector3 = Vector3(0, 0, 0)

# FOV of camera the HMD is attached to 
var cam_fov : float = 70.0

# Scaling factor for spacing between adjacent markings, using FOV
var hmd_scale_factor : float = 1.00

# Viewport centre 
var viewport_centre : Vector2 = Vector2(960, 540)

# Visible only if outside HUD/panel FOV
@export var hmd_power : bool = true
var hmd_blanked : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
#	DebugOverlay.stats.add_property(self, "body_angles_deg", "round")
#	DebugOverlay.stats.add_property(self, "HMD_angles_deg", "round")
#	DebugOverlay.stats.add_property(self, "pfd_alt", "round")
#	DebugOverlay.stats.add_property(self, "pfd_fpa", "round")
#	DebugOverlay.stats.add_property(self, "pfd_trk", "round")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	hmd_scale_factor = 1 / (cam_fov / 2)
	
	viewport_centre = get_viewport_rect().size/2
	
	body_angles_deg.x = rad_to_deg(body_angles.x)
	body_angles_deg.y = rad_to_deg(body_angles.y)
	body_angles_deg.z = rad_to_deg(body_angles.z)
	
	HMD_angles_deg.x = rad_to_deg(HMD_angles.x)
	HMD_angles_deg.y = rad_to_deg(HMD_angles.y)
	HMD_angles_deg.z = rad_to_deg(HMD_angles.z)
	
	
	position = viewport_centre
	
	$EADI/XForm_Roll.rotation_degrees = -AeroDataBus.aircraft_roll
	$EADI/XForm_Roll/XForm_Pitch.position.y = AeroDataBus.aircraft_pitch * 1080/70


