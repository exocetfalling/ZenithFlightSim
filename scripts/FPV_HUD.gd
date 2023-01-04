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

var tape_spd_ref = 0
var tape_spd_step = 10
var tape_spd_spacing = 200

var tape_alt_ref = 0
var tape_alt_step = 100
var tape_alt_spacing = 200

var tape_hdg_ref = 0
var tape_hdg_abv = 0
var tape_hdg_blw = 0
var tape_hdg_step = 10
var tape_hdg_spacing = 200

export var hmd_power : bool = true
var hmd_blanked : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Tape_SPD/ABV.rect_position.y = \
		$Tape_SPD/REF.rect_position.y - tape_spd_spacing
	$Tape_SPD/BLW.rect_position.y = \
		$Tape_SPD/REF.rect_position.y + tape_spd_spacing
	
	$Tape_ALT/ABV.rect_position.y = \
		$Tape_ALT/REF.rect_position.y - tape_alt_spacing
	$Tape_ALT/BLW.rect_position.y = \
		$Tape_ALT/REF.rect_position.y + tape_alt_spacing



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	viewport_centre = get_viewport_rect().size/2

	$EADI.position = viewport_centre
	
	display_distance = viewport_centre.y / tan(deg2rad(cam_fov / 2))
	
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
	
	$EADI/FPM.position.x = \
		display_distance * tan(deg2rad(-FlightData.aircraft_beta))
	$EADI/FPM.position.y = \
		display_distance * tan(deg2rad(FlightData.aircraft_alpha))
	
	get_node("Speed_Data").text = ("SPD\n%03d" % [FlightData.aircraft_spd_indicated])
	get_node("Alt_Data").text = ("ALT\n%05d" % [FlightData.aircraft_alt_barometric])
	get_node("Heading_Data").text = ("HDG\n%03d" % [FlightData.aircraft_hdg])

	tape_spd_ref = stepify(FlightData.aircraft_spd_indicated, tape_spd_step)
	$Tape_SPD/REF.text = ("%03d -" % [tape_spd_ref])
	$Tape_SPD/ABV.text = ("%03d -" % [tape_spd_ref + tape_spd_step])
	$Tape_SPD/BLW.text = ("%03d -" % [tape_spd_ref - tape_spd_step])
	
	if(tape_spd_ref <= 0): 
		$Tape_SPD/BLW.visible = false
	else:
		$Tape_SPD/BLW.visible = true
	
	$Tape_SPD.position.y = 540 + \
		(FlightData.aircraft_spd_indicated - tape_spd_ref) * (tape_spd_spacing / tape_spd_step)
	
	tape_alt_ref = stepify(FlightData.aircraft_alt_barometric, tape_alt_step)
	$Tape_ALT/REF.text = ("- %05d" % [tape_alt_ref])
	$Tape_ALT/ABV.text = ("- %05d" % [tape_alt_ref + tape_alt_step])
	$Tape_ALT/BLW.text = ("- %05d" % [tape_alt_ref - tape_alt_step])
	
	if(tape_alt_ref <= 0): 
		$Tape_ALT/BLW.visible = false
	else:
		$Tape_ALT/BLW.visible = true
	
	$Tape_ALT.position.y = 540 + \
		(FlightData.aircraft_alt_barometric - tape_alt_ref) * (tape_alt_spacing / tape_alt_step)
	
	tape_hdg_ref = stepify(FlightData.aircraft_hdg, tape_hdg_step)
	
	tape_hdg_abv = fmod(tape_hdg_ref + tape_hdg_step + 360, 360)
	tape_hdg_blw = fmod(tape_hdg_ref - tape_hdg_step + 360, 360)
	
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/REF.text = ("|\n%03d" % [tape_hdg_ref])
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/ABV.text = ("|\n%03d" % [tape_hdg_abv])
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/BLW.text = ("|\n%03d" % [tape_hdg_blw])
	
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG.position.x = \
		-(FlightData.aircraft_hdg - tape_hdg_ref) * (tape_hdg_spacing / tape_hdg_step)
	
	tape_hdg_spacing = 10 * get_viewport_rect().size.y/cam_fov
	
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/ABV.rect_position.x = \
		$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/REF.rect_position.x + tape_hdg_spacing
	$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/BLW.rect_position.x = \
		$EADI/XForm_Roll/XForm_Pitch/Tape_HDG/REF.rect_position.x - tape_hdg_spacing
	
	$Indicantor_THR.value = FlightData.aircraft_throttle * 100
