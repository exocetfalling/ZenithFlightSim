extends TabContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

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

# Called when the node enters the scene tree for the first time.
func _ready():
	$PFD/EADI/Tape_SPD/ABV.rect_position.y = \
		$PFD/EADI/Tape_SPD/REF.rect_position.y - tape_spd_spacing
	$PFD/EADI/Tape_SPD/BLW.rect_position.y = \
		$PFD/EADI/Tape_SPD/REF.rect_position.y + tape_spd_spacing
	
	$PFD/EADI/Tape_ALT/ABV.rect_position.y = \
		$PFD/EADI/Tape_ALT/REF.rect_position.y - tape_alt_spacing
	$PFD/EADI/Tape_ALT/BLW.rect_position.y = \
		$PFD/EADI/Tape_ALT/REF.rect_position.y + tape_alt_spacing
	
	$PFD/EADI/Tape_HDG/ABV.rect_position.x = \
		$PFD/EADI/Tape_HDG/REF.rect_position.x + tape_hdg_spacing
	$PFD/EADI/Tape_HDG/BLW.rect_position.x = \
		$PFD/EADI/Tape_HDG/REF.rect_position.x - tape_hdg_spacing
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_node("PFD/EADI/SPD").text = ("IAS\n%03d\n" % [FlightData.aircraft_spd_indicated] \
		+ "TAS\n%03d" % [FlightData.aircraft_spd_true])
	get_node("PFD/EADI/ALT").text = ("BALT\n%05d\n" % [FlightData.aircraft_alt_barometric] \
		+ "RALT\n%05d" % [FlightData.aircraft_alt_radio])
	get_node("PFD/EADI/HDG").text = ("HDG\n%03d" % [FlightData.aircraft_hdg])
	
	get_node("PFD/EADI/FLAP").text = ("FLAP\n%01d" % [FlightData.aircraft_flaps])
	
	if (FlightData.aircraft_ap == 0): 
		pass
	
	tape_spd_ref = stepify(FlightData.aircraft_spd_indicated, tape_spd_step)
	$PFD/EADI/Tape_SPD/REF.text = ("%03d -" % [tape_spd_ref])
	$PFD/EADI/Tape_SPD/ABV.text = ("%03d -" % [tape_spd_ref + tape_spd_step])
	$PFD/EADI/Tape_SPD/BLW.text = ("%03d -" % [tape_spd_ref - tape_spd_step])
	
	if(tape_spd_ref <= 0): 
		$PFD/EADI/Tape_SPD/BLW.visible = false
	else:
		$PFD/EADI/Tape_SPD/BLW.visible = true
	
	$PFD/EADI/Tape_SPD.position.y = 500 + \
		(FlightData.aircraft_spd_indicated - tape_spd_ref) * (tape_spd_spacing / tape_spd_step)
	
	tape_alt_ref = stepify(FlightData.aircraft_alt_barometric, tape_alt_step)
	$PFD/EADI/Tape_ALT/REF.text = ("- %05d" % [tape_alt_ref])
	$PFD/EADI/Tape_ALT/ABV.text = ("- %05d" % [tape_alt_ref + tape_alt_step])
	$PFD/EADI/Tape_ALT/BLW.text = ("- %05d" % [tape_alt_ref - tape_alt_step])
	
	if(tape_alt_ref <= 0): 
		$PFD/EADI/Tape_ALT/BLW.visible = false
	else:
		$PFD/EADI/Tape_ALT/BLW.visible = true
	
	$PFD/EADI/Tape_ALT.position.y = 500 + \
		(FlightData.aircraft_alt_barometric - tape_alt_ref) * (tape_alt_spacing / tape_alt_step)
	
	tape_hdg_ref = stepify(FlightData.aircraft_hdg, tape_hdg_step)
	
	tape_hdg_abv = fmod(tape_hdg_ref + tape_hdg_step + 360, 360)
	tape_hdg_blw = fmod(tape_hdg_ref - tape_hdg_step + 360, 360)
	
	$PFD/EADI/Tape_HDG/REF.text = ("%03d" % [tape_hdg_ref])
	$PFD/EADI/Tape_HDG/ABV.text = ("%03d" % [tape_hdg_abv])
	$PFD/EADI/Tape_HDG/BLW.text = ("%03d" % [tape_hdg_blw])
	
	$PFD/EADI/Tape_HDG.position.x = 500 - \
		(FlightData.aircraft_hdg - tape_hdg_ref) * (tape_hdg_spacing / tape_hdg_step)
	
	$PFD/EADI/Box_SPD/Value.text = ("%03d" % [FlightData.aircraft_spd_indicated])
	$PFD/EADI/Box_ALT/Value.text = ("%05d" % [FlightData.aircraft_alt_barometric])
	$PFD/EADI/Box_HDG/Value.text = ("%03d" % [FlightData.aircraft_hdg])
	
	get_node("PFD/EADI/Viewport/XForm_Roll").rotation_degrees = -FlightData.aircraft_roll
	get_node("PFD/EADI/Viewport/XForm_Roll/XForm_Pitch").position.y = FlightData.aircraft_pitch * 20
	
