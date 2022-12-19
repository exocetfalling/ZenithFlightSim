extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# FOV of camera the HMD is attached to 
var cam_fov : float = 60.0

# Distance of imaginary display
var display_distance : float

# Scaling factor for spacing between adjacent markings, using FOV
var hmd_scale_factor : float = 1.00

# Viewport centre 
var viewport_centre : Vector2 = Vector2(960, 540)

export var hmd_power : bool = true
var hmd_blanked : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	viewport_centre = get_viewport_rect().size/2

	position = viewport_centre
	
	display_distance = viewport_centre.y / tan(deg2rad(cam_fov / 2))
	
	$EADI/XForm_Roll.rotation_degrees = -FlightData.aircraft_roll
	$EADI/XForm_Roll/XForm_Pitch.position.y = \
		FlightData.aircraft_pitch * get_viewport_rect().size.y/cam_fov
#		display_distance * tan(deg2rad(FlightData.aircraft_pitch))
	
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_P10.position.y = \
		-10 * get_viewport_rect().size.y/cam_fov
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_N10.position.y = \
		10 * get_viewport_rect().size.y/cam_fov
	
	$EADI/FPM.position.x = \
		display_distance * tan(deg2rad(-FlightData.aircraft_beta))
	$EADI/FPM.position.y = \
		display_distance * tan(deg2rad(FlightData.aircraft_alpha))


