extends MarginContainer

var panel_active = true
var panel_pitch = 0
var panel_roll = 0
var panel_spd = 0
var panel_alt = 0
var panel_hdg = 0
var panel_flaps = 0
var panel_trim = 0
var panel_gear = 0
var panel_throttle = 0
var panel_ap = 0
var panel_MFD_mode = 0
var panel_nav_brg = 0
var panel_nav_range = 0
var panel_nav_waypoint = 0

var slider_throttle = 0
var slider_flaps = 0

var button_FBW = 0
	
var current_viewport_size = get_viewport_rect().size/2	
var current_centre_position = get_viewport_rect().size/2

#func ui_element_dynamic_pos(res_current, res_native, position_design, size_design):
#	var scale_factor
#	var offset_design
#	var position_dynamic
#
#	scale_factor = res_current / res_native
#	position_dynamic = position_design * scale_factor
#	return position_dynamic
#
#func ui_element_dynamic_scale(res_current, res_native, position_design, size_design):
#	var scale_factor
#	var offset_design
#	var scale_dynamic 
#	var position_dynamic
#
#	scale_dynamic = Vector2((res_current.y / res_native.y), (res_current.y / res_native.y))
#	return scale_dynamic

# Called when the node enters the scene tree for the first time.
func _ready():
#	DebugOverlay.stats.add_property(self, "panel_MFD_mode", "")
	pass # Replace with function body.

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Visibility
	if (panel_active == true):
		visible = true
	else:
		visible = false
	
	current_viewport_size = get_viewport_rect().size
	current_centre_position = get_viewport_rect().size/2
	
	panel_MFD_mode = $MFD/MFD_Mode.item_pressed
	panel_nav_waypoint = $MFD/Page_NAV/Waypoint_Select.item_pressed
	
	$Speed_Data.text = ("SPD\n%03d" % [panel_spd])
	$Alt_Data.text = ("ALT\n%05d" % [panel_alt])
	$Heading_Data.text = ("HDG\n%03d" % [panel_hdg])

	get_node("Boresight").position = current_centre_position
	
#	# Dynamic sizing
#	get_node('PFD').position = \
#		ui_element_dynamic_pos(current_viewport_size, \
#		Vector2(1920, 1080), \
#		Vector2(254, 819), \
#		Vector2(600, 600))
#	get_node('PFD').scale = \
#		ui_element_dynamic_scale(current_viewport_size, \
#		Vector2(1920, 1080), \
#		Vector2(254, 819), \
#		Vector2(600, 600))
#
#	get_node('MFD').position = \
#		ui_element_dynamic_pos(current_viewport_size, \
#		Vector2(1920, 1080), \
#		Vector2(1650, 819), \
#		Vector2(600, 600))
#	get_node('MFD').scale = \
#		ui_element_dynamic_scale(current_viewport_size, \
#		Vector2(1920, 1080), \
#		Vector2(1650, 819), \
#		Vector2(600, 600))
	# PFD 
	
#	get_node("PFD/EADI_Image").rotation_degrees = -panel_roll
#	get_node("PFD/EADI_Image").position.y = (panel_pitch / 90 * 260) * cos(deg2rad(panel_roll))
#	get_node("PFD/EADI_Image").position.x = get_node("PFD/EADI_Image").position.y * tan(deg2rad(panel_roll))
#
#	get_node("PFD/Box_SPD").text = ("SPD\n%03d" % [panel_spd])
#	get_node("PFD/Box_ALT").text = ("ALT\n%05d" % [panel_alt])
#	get_node("PFD/Box_HDG").text = ("HDG\n%03d" % [panel_hdg])
#
#	get_node("PFD/Box_TRIM").text = ("TRIM\n%.1f" % [panel_trim])
#	get_node("PFD/Box_FLAPS").text = ("FLAPS\n%01d" % [panel_flaps])
#
#	if (panel_gear == 1):
#		get_node("PFD/Gear_Indicator").default_color = Color8(22, 222, 22)
#		get_node("PFD/Gear_Status").text = "GEAR DN"
#	if ((panel_gear > 0) && (panel_gear < 1)):
#		get_node("PFD/Gear_Indicator").default_color = Color8(222, 222, 22)
#		get_node("PFD/Gear_Status").text = "GEAR TR"
#	if (panel_gear == 0):
#		get_node("PFD/Gear_Indicator").default_color = Color8(222, 22, 22)
#		get_node("PFD/Gear_Status").text = "GEAR UP"
#	if (panel_ap == 1):
#		get_node("PFD/AP").visible = true
#	else:
#		get_node("PFD/AP").visible = false

	# PFD 
	get_node("MFD_V3_L/Display").display_roll = panel_roll
	get_node("MFD_V3_L/Display").display_pitch = panel_pitch
	
	get_node("MFD_V3_L/Display").display_spd = panel_spd
	get_node("MFD_V3_L/Display").display_alt = panel_alt
	get_node("MFD_V3_L/Display").display_hdg = panel_hdg
	
	# MFD
	get_node("MFD/Thrust_Indicator").value = panel_throttle
	
	if (panel_MFD_mode == "KEYS"):
		$MFD/Page_KEYS.visible = true
		$MFD/Page_CHECKLIST.visible = false
		$MFD/Page_MEMO.visible = false
		$MFD/Page_NAV.visible = false
	if (panel_MFD_mode == "CHECKLIST"):
		$MFD/Page_KEYS.visible = false
		$MFD/Page_CHECKLIST.visible = true
		$MFD/Page_MEMO.visible = false
		$MFD/Page_NAV.visible = false
	if (panel_MFD_mode == "MEMO"):
		$MFD/Page_KEYS.visible = false
		$MFD/Page_CHECKLIST.visible = false
		$MFD/Page_MEMO.visible = true
		$MFD/Page_NAV.visible = false
	if (panel_MFD_mode == "NAV"):
		$MFD/Page_KEYS.visible = false
		$MFD/Page_CHECKLIST.visible = false
		$MFD/Page_MEMO.visible = false
		$MFD/Page_NAV.visible = true
	
	# ND
	get_node("MFD/Page_NAV/ND_Rose").rotation_degrees = - panel_hdg
	get_node("MFD/Page_NAV/ND_Rose/NAV1_Pointer").rotation_degrees = panel_nav_brg
	get_node("MFD/Page_NAV/Waypoint_ID").text = panel_nav_waypoint
	get_node("MFD/Page_NAV/Waypoint_Dist").text = ("%0.1f KM" % [panel_nav_range/1000])

	# UFC Buttons
	
	if (get_node("UpFrontControls/Modes_Main/FBW").pressed == true):
		button_FBW = 1
	
