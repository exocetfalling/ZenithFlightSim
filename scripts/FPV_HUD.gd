extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# FOV of camera the HMD is attached to 
var cam_fov : float = 60.0

# Distance of imaginary display
var display_distance : float

# Scaling factors for spacing between elements
var hud_scale_factor : Vector2 = Vector2.ONE

# Viewport centre 
var viewport_centre : Vector2 = Vector2(960, 540)

var tape_spd_ref = 0
var tape_spd_step = 5
var tape_spd_spacing = 100

var tape_alt_ref = 0
var tape_alt_step = 50
var tape_alt_spacing = 100

var tape_hdg_ref = 0
var tape_hdg_abv1 = 0
var tape_hdg_abv2 = 0
var tape_hdg_blw1 = 0
var tape_hdg_blw2 = 0

var tape_hdg_step = 10
var tape_hdg_spacing = 200

export var hmd_power : bool = true
var hmd_blanked : bool = false

var fpv_angles : Vector3 = Vector3.ZERO

func _format_hdg(heading):
	if (heading  <= 0):
		heading += 360
	if (heading > 360):
		heading -= 360
	
	return heading


# Called when the node enters the scene tree for the first time.
func _ready():
	$HUD_Centre/Tape_SPD/ABV1.rect_position.y = \
		$HUD_Centre/Tape_SPD/REF0.rect_position.y - 1 * tape_spd_spacing
	$HUD_Centre/Tape_SPD/ABV2.rect_position.y = \
		$HUD_Centre/Tape_SPD/REF0.rect_position.y - 2 * tape_spd_spacing
	$HUD_Centre/Tape_SPD/BLW1.rect_position.y = \
		$HUD_Centre/Tape_SPD/REF0.rect_position.y + 1 * tape_spd_spacing
	$HUD_Centre/Tape_SPD/BLW2.rect_position.y = \
		$HUD_Centre/Tape_SPD/REF0.rect_position.y + 2 * tape_spd_spacing

	
	$HUD_Centre/Tape_ALT/ABV1.rect_position.y = \
		$HUD_Centre/Tape_ALT/REF0.rect_position.y - 1 * tape_alt_spacing
	$HUD_Centre/Tape_ALT/ABV2.rect_position.y = \
		$HUD_Centre/Tape_ALT/REF0.rect_position.y - 2 * tape_alt_spacing
	$HUD_Centre/Tape_ALT/BLW1.rect_position.y = \
		$HUD_Centre/Tape_ALT/REF0.rect_position.y + 1 * tape_alt_spacing
	$HUD_Centre/Tape_ALT/BLW2.rect_position.y = \
		$HUD_Centre/Tape_ALT/REF0.rect_position.y + 2 * tape_alt_spacing



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	viewport_centre = get_viewport_rect().size/2

	$EADI.position = viewport_centre
	$HUD_Centre.position = viewport_centre
	$Boresight.position = \
		viewport_centre - 5 * hud_scale_factor * Vector2(-fpv_angles.y, -fpv_angles.x)
	
	hud_scale_factor = get_viewport_rect().size / Vector2(1920, 1080)
	
	$HUD_Centre.scale = hud_scale_factor
	
	fpv_angles = FlightData.aircraft_cam_rotation_deg
	
	display_distance = viewport_centre.y / tan(deg2rad(cam_fov / 2))
	
	if (FlightData.aircraft_cam_rotation_deg.length() <= 5):
		$EADI.visible = true
		$Boresight.visible = false
	else:
		$EADI.visible = false
		$Boresight.visible = true
	
	$EADI/XForm_Roll.rotation_degrees = -FlightData.aircraft_roll
	$EADI/XForm_Roll/XForm_Pitch.position.y = \
		FlightData.aircraft_pitch * get_viewport_rect().size.y/cam_fov
#		display_distance * tan(deg2rad(FlightData.aircraft_pitch))

	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_P02.position.y = \
		-2.5 * get_viewport_rect().size.y/cam_fov
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_N02.position.y = \
		2.5 * get_viewport_rect().size.y/cam_fov
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_P05.position.y = \
		-5 * get_viewport_rect().size.y/cam_fov
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_N05.position.y = \
		5 * get_viewport_rect().size.y/cam_fov
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_P10.position.y = \
		-10 * get_viewport_rect().size.y/cam_fov
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_N10.position.y = \
		10 * get_viewport_rect().size.y/cam_fov
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_P20.position.y = \
		-20 * get_viewport_rect().size.y/cam_fov
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Ladder_N20.position.y = \
		20 * get_viewport_rect().size.y/cam_fov
	$EADI/XForm_Roll/XForm_Pitch/Horizon/Waterline.position.y = \
		3 * get_viewport_rect().size.y/cam_fov
	
	if (FlightData.aircraft_gear == 0):
		$EADI/XForm_Roll/XForm_Pitch/Horizon/Waterline.visible = false
	else:
		$EADI/XForm_Roll/XForm_Pitch/Horizon/Waterline.visible = true
	
	$EADI/FPM.position.x = \
		display_distance * tan(deg2rad(-FlightData.aircraft_beta))
	$EADI/FPM.position.y = \
		display_distance * tan(deg2rad(FlightData.aircraft_alpha))
	
	# Waypoint indications
	if (\
	(FlightData.aircraft_nav_active == true) && \
	(abs(FlightData.aircraft_nav_waypoint_data.x) <= 90) && \
	(abs(FlightData.aircraft_nav_waypoint_data.y) <= 90) \
		):
		$EADI/Aircraft/Marker_WPT.visible = true
		$EADI/Aircraft/Marker_WPT.position.x = \
			display_distance * tan(deg2rad(FlightData.aircraft_nav_waypoint_data.x))
		$EADI/Aircraft/Marker_WPT.position.y = \
			display_distance * tan(deg2rad(-FlightData.aircraft_nav_waypoint_data.y))
		$EADI/Aircraft/Marker_WPT.rotation_degrees = -FlightData.aircraft_roll
	else:
		$EADI/Aircraft/Marker_WPT.visible = false
		$EADI/Aircraft/Marker_WPT.position = Vector2.ZERO
		$EADI/Aircraft/Marker_WPT.rotation = 0
	
	$Compass.position.x = viewport_centre.x
	$Compass.position.y = viewport_centre.y + 400 * (get_viewport_rect().size.y / 1080)
	$Compass/Rose.rotation_degrees = -FlightData.aircraft_hdg
	$Compass/Needle.rotation_degrees = FlightData.aircraft_nav_waypoint_data.x
	
#	get_node("Speed_Data").text = ("SPD\n%03d" % [FlightData.aircraft_spd_indicated])
#	get_node("Alt_Data").text = ("ALT\n%05d" % [FlightData.aircraft_alt_barometric])
#	get_node("Heading_Data").text = ("HDG\n%03d" % [FlightData.aircraft_hdg])

	tape_spd_ref = stepify(FlightData.aircraft_spd_indicated, tape_spd_step)
	$HUD_Centre/Tape_SPD/REF0.text = ("%03d -" % [tape_spd_ref])
	$HUD_Centre/Tape_SPD/ABV1.text = ("%03d -" % [tape_spd_ref + 1 * tape_spd_step])
	$HUD_Centre/Tape_SPD/ABV2.text = ("%03d -" % [tape_spd_ref + 2 * tape_spd_step])
	$HUD_Centre/Tape_SPD/BLW1.text = ("%03d -" % [tape_spd_ref - 1 * tape_spd_step])
	$HUD_Centre/Tape_SPD/BLW2.text = ("%03d -" % [tape_spd_ref - 2 * tape_spd_step])
	
	if(tape_spd_ref <= 5): 
		$HUD_Centre/Tape_SPD/BLW1.visible = false
		$HUD_Centre/Tape_SPD/BLW2.visible = false
	else:
		$HUD_Centre/Tape_SPD/BLW1.visible = true
		$HUD_Centre/Tape_SPD/BLW2.visible = true
	
	$HUD_Centre/Tape_SPD.position.y = \
		(FlightData.aircraft_spd_indicated - tape_spd_ref) * (tape_spd_spacing / tape_spd_step)
	
	tape_alt_ref = stepify(FlightData.aircraft_alt_barometric, tape_alt_step)
	$HUD_Centre/Tape_ALT/REF0.text = ("- %05d" % [tape_alt_ref])
	$HUD_Centre/Tape_ALT/ABV1.text = ("- %05d" % [tape_alt_ref + 1 * tape_alt_step])
	$HUD_Centre/Tape_ALT/ABV2.text = ("- %05d" % [tape_alt_ref + 2 * tape_alt_step])
	$HUD_Centre/Tape_ALT/BLW1.text = ("- %05d" % [tape_alt_ref - 1 * tape_alt_step])
	$HUD_Centre/Tape_ALT/BLW2.text = ("- %05d" % [tape_alt_ref - 2 * tape_alt_step])
	
	if(tape_alt_ref <= 0): 
		$HUD_Centre/Tape_ALT/BLW1.visible = false
		$HUD_Centre/Tape_ALT/BLW2.visible = false
	else:
		$HUD_Centre/Tape_ALT/BLW1.visible = true
		$HUD_Centre/Tape_ALT/BLW2.visible = true
	
	$HUD_Centre/Tape_ALT.position.y = \
		(FlightData.aircraft_alt_barometric - tape_alt_ref) * (tape_alt_spacing / tape_alt_step)
	

	tape_hdg_ref = stepify(FlightData.aircraft_hdg, tape_hdg_step)
	tape_hdg_abv1 = _format_hdg(tape_hdg_ref + 1 * tape_hdg_step)
	tape_hdg_abv2 = _format_hdg(tape_hdg_ref + 2 * tape_hdg_step)
	tape_hdg_blw1 = _format_hdg(tape_hdg_ref - 1 * tape_hdg_step)
	tape_hdg_blw2 = _format_hdg(tape_hdg_ref - 2 * tape_hdg_step)
	
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/REF0.text = ("%03d\n|" % [_format_hdg(tape_hdg_ref)])
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/ABV1.text = ("%03d\n|" % [tape_hdg_abv1])
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/ABV2.text = ("%03d\n|" % [tape_hdg_abv2])
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/BLW1.text = ("%03d\n|" % [tape_hdg_blw1])
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/BLW2.text = ("%03d\n|" % [tape_hdg_blw2])
	
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG.position.x = \
		-(FlightData.aircraft_hdg - tape_hdg_ref) * (tape_hdg_spacing / tape_hdg_step)
	
	tape_hdg_spacing = 10 * get_viewport_rect().size.y/cam_fov
	
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/ABV1.rect_position.x = \
		$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/REF0.rect_position.x + 1 * tape_hdg_spacing
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/ABV2.rect_position.x = \
		$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/REF0.rect_position.x + 2 * tape_hdg_spacing
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/BLW1.rect_position.x = \
		$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/REF0.rect_position.x - 1 * tape_hdg_spacing
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/BLW2.rect_position.x = \
		$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/REF0.rect_position.x - 2 * tape_hdg_spacing
	
	$HUD_Centre/Indicator_THR.value = FlightData.aircraft_throttle * 100
	$HUD_Centre/Indicator_FLAPS.value = FlightData.aircraft_flaps
	
	$HUD_Centre/Indicator_TRIM/Caret.position.y = FlightData.aircraft_trim * 50
	$HUD_Centre/Indicator_TRIM/Label.text = ("TRIM %+0.1f" % [FlightData.aircraft_trim])
	
	if (FlightData.aircraft_cws == 0):
		$HUD_Centre/Status_CWS.visible = false
	if (FlightData.aircraft_cws == 1):
		$HUD_Centre/Status_CWS.visible = true
	
	if (FlightData.aircraft_alt_radio < 2500):
		$HUD_Centre/RadioAlt.visible = true
	else:
		$HUD_Centre/RadioAlt.visible = false
	
	$HUD_Centre/RadioAlt/Label.text = ("RA\n%d" % [FlightData.aircraft_alt_radio])
