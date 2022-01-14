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
var display_MFD_mode = 0
var display_nav_brg = 0
var display_nav_range = 0
var display_nav_waypoint = 0


# Called when the node enters the scene tree for the first time.
func _ready():
#	DebugOverlay.stats.add_property(self, "display_MFD_mode", "")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
#	# Visibility
#	if ($'../../'.Main_Panel_active == true):
#		visible = true
#	else:
#		visible = false

	display_MFD_mode = $MFD/MFD_Mode.item_pressed
	display_nav_waypoint = $MFD/Page_NAV/Waypoint_Select.item_pressed
	
	$Text_Line_1/Speed_Data/Variable.text = "%03d" % stepify(display_spd, 1)
	$Text_Line_1/Alt_Data/Variable.text = "%05d" % stepify(display_alt, 1)
	$Text_Line_1/Heading_Data/Variable.text = "%03d" % stepify(display_hdg, 1)
	$Text_Line_2/Flaps_Data/Variable.text = "%01d" % stepify(display_flaps, 1)
#	$Text_Line_2/Gear_Data/Variable.text = "%.2f" % stepify($'../../'.gear_current, 0.01)
	
	var centre_position = get_viewport_rect().size/2
	get_node("Boresight").position = centre_position
	
	# PFD 
	get_node("PFD/EADI_Image").rotation_degrees = -display_roll
	get_node("PFD/EADI_Image").position.y = (display_pitch / 90 * 260) * cos(deg2rad(display_roll))
	get_node("PFD/EADI_Image").position.x = get_node("PFD/EADI_Image").position.y * tan(deg2rad(display_roll))
	
	get_node("PFD/Box_SPD").text = "%03d" % stepify(display_spd, 1)
	get_node("PFD/Box_ALT").text = "%05d" % stepify(display_alt, 1)
	get_node("PFD/Box_HDG").text = "%03d" % stepify(display_hdg, 1)
	
	get_node("PFD/Box_TRIM").text = "%.1f" % stepify(display_trim, 0.1)
	get_node("PFD/Box_FLAPS").text = "%01d" % stepify(display_flaps, 1)
	
	if (display_gear == 1):
		get_node("PFD/Gear_Indicator").default_color = Color8(22, 222, 22)
		get_node("PFD/Gear_Status").text = "GEAR DN"
	if ((display_gear > 0) && (display_gear < 1)):
		get_node("PFD/Gear_Indicator").default_color = Color8(222, 222, 22)
		get_node("PFD/Gear_Status").text = "GEAR TR"
	if (display_gear == 0):
		get_node("PFD/Gear_Indicator").default_color = Color8(222, 22, 22)
		get_node("PFD/Gear_Status").text = "GEAR UP"
	if (display_ap == 1):
		get_node("PFD/AP").visible = true
	else:
		get_node("PFD/AP").visible = false
	
	# MFD
	get_node("MFD/Thrust_Indicator").value = display_throttle
	
	if (display_MFD_mode == "KEYS"):
		$MFD/Page_KEYS.visible = true
		$MFD/Page_CHECKLIST.visible = false
		$MFD/Page_MEMO.visible = false
		$MFD/Page_NAV.visible = false
	if (display_MFD_mode == "CHECKLIST"):
		$MFD/Page_KEYS.visible = false
		$MFD/Page_CHECKLIST.visible = true
		$MFD/Page_MEMO.visible = false
		$MFD/Page_NAV.visible = false
	if (display_MFD_mode == "MEMO"):
		$MFD/Page_KEYS.visible = false
		$MFD/Page_CHECKLIST.visible = false
		$MFD/Page_MEMO.visible = true
		$MFD/Page_NAV.visible = false
	if (display_MFD_mode == "NAV"):
		$MFD/Page_KEYS.visible = false
		$MFD/Page_CHECKLIST.visible = false
		$MFD/Page_MEMO.visible = false
		$MFD/Page_NAV.visible = true
	
	# ND
	get_node("MFD/Page_NAV/ND_Rose").rotation_degrees = - display_hdg
	get_node("MFD/Page_NAV/ND_Rose/NAV1_Pointer").rotation_degrees = display_nav_brg
	get_node("MFD/Page_NAV/Waypoint_ID").text = display_nav_waypoint
	get_node("MFD/Page_NAV/Waypoint_Dist").text = ("%0.1f KM" % [display_nav_range/1000])
