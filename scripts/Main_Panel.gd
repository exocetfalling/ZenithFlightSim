extends MarginContainer

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
#	DebugOverlay.stats.add_property(self, "FlightData.aircraft_MFD_mode", "")
	$MFD_V3_L/Display.current_tab = 0
	$MFD_V3_R/Display.current_tab = 2
	pass # Replace with function body.

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Visibility
	if (FlightData.aircraft_active == true):
		visible = true
	else:
		visible = false
	
	current_viewport_size = get_viewport_rect().size
	current_centre_position = get_viewport_rect().size/2
#
#	FlightData.aircraft_MFD_mode = $MFD/MFD_Mode.item_pressed
#	FlightData.aircraft_nav_waypoint = $MFD/Page_NAV/Waypoint_Select.item_pressed
#
	$Speed_Data.text = ("SPD\n%03d" % [FlightData.aircraft_spd_indicated])
	$Alt_Data.text = ("ALT\n%05d" % [FlightData.aircraft_alt_barometric])
	$Heading_Data.text = ("HDG\n%03d" % [FlightData.aircraft_hdg])

	get_node("Boresight").position = current_centre_position
	
