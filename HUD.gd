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
var display_ICAWS_mode = 0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	DebugOverlay.stats.add_property(self, "display_ICAWS_mode", "")
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
	display_flaps = $'../../'.input_flaps * 4
	display_trim = $'../../'.output_elevator_trim
	display_gear = $'../../'.gear_current
	display_throttle = $'../../'.throttle_input
	display_ap = $'../../'.autopilot_on
	
	display_ICAWS_mode = $ICAWS/ICAWS_Mode.item_pressed
	
	$Text_Line_1/Speed_Data/Variable.text = "%03d" % stepify($'../../'.pfd_spd, 1)
	$Text_Line_1/Alt_Data/Variable.text = "%05d" % stepify($'../../'.pfd_alt, 1)
	$Text_Line_1/Heading_Data/Variable.text = "%03d" % stepify($'../../'.pfd_hdg, 1)
	$Text_Line_2/Flaps_Data/Variable.text = "%01d" % stepify(display_flaps, 1)
	$Text_Line_2/Gear_Data/Variable.text = "%.2f" % stepify($'../../'.gear_current, 0.01)
	
	var centre_position = get_viewport_rect().size/2
	get_node("Boresight").position = centre_position
	
	get_node("PFD/EADI_Image").rotation_degrees = -display_roll
	get_node("PFD/EADI_Image").position.y = display_pitch / 90 * 260
	get_node("PFD/EADI_Image").position.x = get_node("PFD/EADI_Image").position.y * tan(deg2rad($'../../'.pfd_roll))
	
	get_node("PFD/Box_SPD").text = "%03d" % stepify($'../../'.pfd_spd, 1)
	get_node("PFD/Box_ALT").text = "%05d" % stepify($'../../'.pfd_alt, 1)
	get_node("PFD/Box_HDG").text = "%03d" % stepify($'../../'.pfd_hdg, 1)
	
	get_node("PFD/Box_TRIM").text = "%.1f" % stepify(display_trim, 0.1)
	get_node("PFD/Box_FLAPS").text = "%01d" % stepify(display_flaps, 1)
	
	# ICAWS
	if (display_gear == 1):
		get_node("ICAWS/Gear_Indicator").default_color = Color8(22, 222, 22)
		get_node("ICAWS/Gear_Status").text = "GEAR DN"
	if ((display_gear > 0) && (display_gear < 1)):
		get_node("ICAWS/Gear_Indicator").default_color = Color8(222, 222, 22)
		get_node("ICAWS/Gear_Status").text = "GEAR TR"
	if (display_gear == 0):
		get_node("ICAWS/Gear_Indicator").default_color = Color8(222, 22, 22)
		get_node("ICAWS/Gear_Status").text = "GEAR UP"
	if (display_ap == 1):
		get_node("PFD/AP").visible = true
	else:
		get_node("PFD/AP").visible = false
		
	get_node("ICAWS/Thrust_Indicator").value = display_throttle
	
	if (display_ICAWS_mode == "KEYS"):
		$ICAWS/Page_KEYS.visible = true
		$ICAWS/Page_CHECKLIST.visible = false
		$ICAWS/Page_MEMO.visible = false
	if (display_ICAWS_mode == "CHECKLIST"):
		$ICAWS/Page_KEYS.visible = false
		$ICAWS/Page_CHECKLIST.visible = true
		$ICAWS/Page_MEMO.visible = false
	if (display_ICAWS_mode == "MEMO"):
		$ICAWS/Page_KEYS.visible = false
		$ICAWS/Page_CHECKLIST.visible = false
		$ICAWS/Page_MEMO.visible = true
