extends MarginContainer

var display_pitch = 0
var display_roll = 0
var display_spd = 0
var display_alt = 0
var display_hdg = 0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ($'../../'.HUD_active == true):
		visible = true
	else:
		visible = false
	
	display_pitch = $'../../'.pfd_pitch
	display_roll = $'../../'.pfd_roll
	display_spd = $'../../'.pfd_spd
	display_hdg = $'../../'.pfd_hdg
	display_alt = $'../../'.pfd_alt
	
	$Text_Line_1/Speed_Data/Variable.text = "%03d" % stepify($'../../'.pfd_spd, 1)
	$Text_Line_1/Alt_Data/Variable.text = "%05d" % stepify($'../../'.pfd_alt, 1)
	$Text_Line_1/Heading_Data/Variable.text = "%03d" % stepify($'../../'.pfd_hdg, 1)
	$Text_Line_2/Flaps_Data/Variable.text = "%03d" % stepify($'../../'.flaps_input, 0.01)
	$Text_Line_2/Gear_Data/Variable.text = "%03d" % stepify($'../../'.gear_pos, 0.01)
	
	get_node("EADI_Mask/EADI_Image").rotation_degrees = -display_roll
	get_node("EADI_Mask/EADI_Image").position.y = display_pitch / 90 * 260
	get_node("EADI_Mask/EADI_Image").position.x = get_node("EADI_Mask/EADI_Image").position.y * tan(deg2rad($'../../'.pfd_roll))
	
	get_node("EADI_Mask/Box_SPD").text = "%03d" % stepify($'../../'.pfd_spd, 1)
	get_node("EADI_Mask/Box_ALT").text = "%05d" % stepify($'../../'.pfd_alt, 1)
	get_node("EADI_Mask/Box_HDG").text = "%03d" % stepify($'../../'.pfd_hdg, 1)
