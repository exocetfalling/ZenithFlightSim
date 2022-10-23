extends TabContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
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
	
	get_node("PFD/EADI/Viewport/XForm_Roll").rotation_degrees = -FlightData.aircraft_roll
	get_node("PFD/EADI/Viewport/XForm_Roll/XForm_Pitch").position.y = FlightData.aircraft_pitch * 20
	
