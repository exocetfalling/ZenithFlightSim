extends MarginContainer

var display_active = 0
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
	# Visibility
	if (display_active == true):
		visible = true
	else:
		visible = false

	display_MFD_mode = $MFD/MFD_Mode.item_pressed
	display_nav_waypoint = $MFD/Page_NAV/Waypoint_Select.item_pressed
	
	$Speed_Data.text = ("SPD\n%03d" % [display_spd])
	$Alt_Data.text = ("ALT\n%05d" % [display_alt])
	$Heading_Data.text = ("HDG\n%03d" % [display_hdg])
	
	var centre_position = get_viewport_rect().size/2
	get_node("Boresight").position = centre_position
	
	# PFD 
	get_node("PFD/EADI_Image").rotation_degrees = -display_roll
	get_node("PFD/EADI_Image").position.y = (display_pitch / 90 * 260) * cos(deg2rad(display_roll))
	get_node("PFD/EADI_Image").position.x = get_node("PFD/EADI_Image").position.y * tan(deg2rad(display_roll))
	
	get_node("PFD/Box_SPD").text = ("SPD\n%03d" % [display_spd])
	get_node("PFD/Box_ALT").text = ("ALT\n%05d" % [display_alt])
	get_node("PFD/Box_HDG").text = ("HDG\n%03d" % [display_hdg])
	
	get_node("PFD/Box_TRIM").text = ("TRIM\n%.1f" % [display_trim])
	get_node("PFD/Box_FLAPS").text = ("FLAPS\n%01d" % [display_flaps])
	
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
