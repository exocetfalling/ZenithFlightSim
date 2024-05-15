extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var use_IAS : bool = true

var hud_scale_vertical


# Called when the node enters the scene tree for the first time.
func _ready():
#	DebugOverlay.stats.add_property(self, "camera_rotation_degrees", "round")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	hud_scale_vertical = get_viewport().size.y / get_viewport().get_camera().fov
	
	if (use_IAS == true):
		$GaugeSPD.value_displayed = AeroDataBus.aircraft_spd_indicated
	else:
		$GaugeSPD.value_displayed = AeroDataBus.aircraft_spd_true
	
	$GaugeHDG.value_displayed = AeroDataBus.aircraft_hdg
	$GaugeALT.value_displayed = AeroDataBus.aircraft_alt_barometric
	
	$GaugeTHR.value_displayed = AeroDataBus.aircraft_throttle * 100
	
	$Centre.position = get_viewport_rect().size / 2
	$Centre/Mask.scale = get_viewport_rect().size.y / 1080 * Vector2.ONE
	$Centre/Wings.position.y = \
		(rad2deg(get_viewport().get_camera().global_rotation.x) - AeroDataBus.aircraft_pitch) \
		* hud_scale_vertical
