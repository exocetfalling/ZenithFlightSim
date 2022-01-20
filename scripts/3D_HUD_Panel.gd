extends MarginContainer

var display_active = true
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
	
var current_viewport_size = get_viewport_rect().size/2	
var current_centre_position = get_viewport_rect().size/2

func ui_element_dynamic_pos(res_current, res_native, position_design, size_design):
	var scale_factor
	var offset_design
	var position_dynamic
	
	scale_factor = res_current / res_native
	position_dynamic = position_design * scale_factor
	return position_dynamic

func ui_element_dynamic_scale(res_current, res_native, position_design, size_design):
	var scale_factor
	var offset_design
	var scale_dynamic 
	var position_dynamic
	
	scale_dynamic = Vector2((res_current.y / res_native.y), (res_current.y / res_native.y))
	return scale_dynamic

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
	
	current_viewport_size = get_viewport_rect().size
	current_centre_position = get_viewport_rect().size/2

	
	$Speed_Data.text = ("SPD\n%03d" % [display_spd])
	$Alt_Data.text = ("ALT\n%05d" % [display_alt])
	$Heading_Data.text = ("HDG\n%03d" % [display_hdg])

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
