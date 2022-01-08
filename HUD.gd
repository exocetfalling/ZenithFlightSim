extends MarginContainer

var display_pitch = 0
var display_roll = 0
var display_spd = 0
var display_alt = 0
var display_hdg = 0
var display_flaps = 0
var display_trim = 0
var display_gear = 0
var display_throttle = 0
var display_ap = 0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if ($'../../'.HUD_active == true):
		visible = true
	else:
		visible = false
	
	display_pitch = $'../../'.pfd_pitch
	display_roll = $'../../'.pfd_roll
	display_spd = $'../../'.pfd_spd
	display_hdg = $'../../'.pfd_hdg
	display_alt = $'../../'.pfd_alt
	display_flaps = $'../../'.output_flaps
	display_trim = $'../../'.output_elevator_trim
	display_gear = $'../../'.gear_current
	display_throttle = $'../../'.throttle_input
	display_ap = $'../../'.autopilot_on
	
	$Text_Line_1/Speed_Data/Variable.text = "%03d" % stepify($'../../'.pfd_spd, 1)
	$Text_Line_1/Alt_Data/Variable.text = "%05d" % stepify($'../../'.pfd_alt, 1)
	$Text_Line_1/Heading_Data/Variable.text = "%03d" % stepify($'../../'.pfd_hdg, 1)
	$Text_Line_2/Flaps_Data/Variable.text = "%.2f" % stepify($'../../'.input_flaps, 0.01)
	$Text_Line_2/Gear_Data/Variable.text = "%.2f" % stepify($'../../'.gear_current, 0.01)
	
	var centre_position = get_viewport_rect().size/2
	get_node("Boresight").position = centre_position
	
	get_node("PFD/EADI_Image").rotation_degrees = -display_roll
	get_node("PFD/EADI_Image").position.y = display_pitch / 90 * 260
	get_node("PFD/EADI_Image").position.x = get_node("PFD/EADI_Image").position.y * tan(deg2rad($'../../'.pfd_roll))
	
	get_node("PFD/Box_SPD").text = "%03d" % stepify($'../../'.pfd_spd, 1)
	get_node("PFD/Box_ALT").text = "%05d" % stepify($'../../'.pfd_alt, 1)
	get_node("PFD/Box_HDG").text = "%03d" % stepify($'../../'.pfd_hdg, 1)
	
	get_node("PFD/Box_TRIM").text = "%.2f" % stepify(display_trim, 0.01)
	get_node("PFD/Box_FLAPS").text = "%.2f" % stepify(display_flaps, 0.01)
	
	if (display_gear == 1):
		get_node("ICAWS/Gear_Indicator").default_color = Color8(22, 222, 22)
	if ((display_gear > 0) && (display_gear < 1)):
		get_node("ICAWS/Gear_Indicator").default_color = Color8(222, 222, 22)
	if (display_gear == 0):
		get_node("ICAWS/Gear_Indicator").default_color = Color8(222, 22, 22)
	
	if (display_ap == 1):
		get_node("PFD/AP").visible = true
	else:
		get_node("PFD/AP").visible = false
		
	get_node("ICAWS/Throttle").value = display_throttle
