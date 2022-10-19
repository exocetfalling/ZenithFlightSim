extends TabContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var display_active = true
var display_pitch = 0
var display_roll = 0
var display_spd_indicated = 0
var display_spd_true = 0
var display_alt_barometric = 0
var display_alt_radio = 0
var display_hdg = 0
var display_flaps = 0
var display_trim = 0
var display_gear = 0
var display_throttle = 0
var display_ap = 0
var display_MFD_mode = 0
var display_nav_brg = 0
var display_nav_range = 0
var display_nav_waypoint = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_node("PFD/EADI/SPD").text = ("IAS\n%03d\n" % [display_spd_indicated] \
		+ "TAS\n%03d" % [display_spd_true])
	get_node("PFD/EADI/ALT").text = ("BALT\n%05d\n" % [display_alt_barometric] \
		+ "RALT\n%05d" % [display_alt_radio])
	get_node("PFD/EADI/HDG").text = ("HDG\n%03d" % [display_hdg])
	
	get_node("PFD/EADI/FLAP").text = ("FLAP\n%01d" % [display_flaps])
	
	if (display_ap == 0): 
		pass
	
	get_node("PFD/EADI/Viewport/XForm_Roll").rotation_degrees = -display_roll
	get_node("PFD/EADI/Viewport/XForm_Roll/XForm_Pitch").position.y = display_pitch * 20
	
