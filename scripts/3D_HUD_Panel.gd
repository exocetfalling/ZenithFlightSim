extends MarginContainer

var display_HUD_scale = 1
var display_FD_commands = Vector2.ZERO
	
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
#	DebugOverlay.stats.add_property(self, "display_pitch", "")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Visibility
	if (AeroDataBus.aircraft_active == true):
		visible = true
	else:
		visible = false
	
	current_viewport_size = get_viewport_rect().size
	current_centre_position = get_viewport_rect().size/2

	
	$Speed_Data.text = ("SPD\n%03d" % [AeroDataBus.aircraft_spd_indicated])
	$Alt_Data.text = ("ALT\n%05d" % [AeroDataBus.aircraft_alt_barometric])
	$Heading_Data.text = ("HDG\n%03d" % [AeroDataBus.aircraft_hdg])

	get_node("Boresight").position = current_centre_position
	
#	# Dynamic sizing
#	get_node('AeroDataBus.aircraft').position = \
#		ui_element_dynamic_pos(current_viewport_size, \
#		Vector2(1920, 1080), \
#		Vector2(254, 819), \
#		Vector2(600, 600))
#	get_node('AeroDataBus.aircraft').scale = \
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
	
	# HUD
	
	get_node('HUD/HUD_Ladder').rotation_degrees = -AeroDataBus.aircraft_roll
	get_node('HUD/HUD_Ladder').position.y = (AeroDataBus.aircraft_pitch / 90 * 3200) * cos(deg2rad(AeroDataBus.aircraft_roll))
	get_node('HUD/HUD_Ladder').position.x = get_node('HUD/HUD_Ladder').position.y * tan(deg2rad(AeroDataBus.aircraft_roll))
	
	get_node("Speed_Data").text = ("SPD\n%03d" % [AeroDataBus.aircraft_spd_indicated])
	get_node("Alt_Data").text = ("ALT\n%05d" % [AeroDataBus.aircraft_alt_barometric])
	get_node("Heading_Data").text = ("HDG\n%03d" % [AeroDataBus.aircraft_hdg])
	

	get_node("HUD/FlightPathVector").position.y = display_HUD_scale * (AeroDataBus.aircraft_alpha / 90 * 3200)
	get_node("HUD/FlightPathVector").position.x = -display_HUD_scale * (AeroDataBus.aircraft_beta / 90 * 3200)
	get_node("HUD/FlightDirector").position.y = -display_HUD_scale * (display_FD_commands.y / 90 * 3200)
	get_node("HUD/FlightDirector").position.x = display_HUD_scale * (display_FD_commands.x / 90 * 3200)
	if (AeroDataBus.aircraft_spd_indicated > 2):
		get_node('HUD/FlightPathVector').visible = true
	else:
		get_node('HUD/FlightPathVector').visible = false
		
	if (AeroDataBus.aircraft_ap == 1):
		get_node('HUD/FlightDirector').visible = true
	else:
		get_node('HUD/FlightDirector').visible = false
	
#	$HUD/FlightPathVector/EnergyCaret.position.y = 5 * display_accel_z
	$HUD/FlightPathVector/E_Bracket.position.y = 4 * (AeroDataBus.aircraft_alpha - 5)
	
	if (AeroDataBus.aircraft_flaps > 0):
		$HUD/FlightPathVector/E_Bracket.visible = true
	else:
		$HUD/FlightPathVector/E_Bracket.visible = false
