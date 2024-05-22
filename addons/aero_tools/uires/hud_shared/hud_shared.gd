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

func set_display_spd(value):
	$GaugeSPD.value_displayed = value


func set_display_hdg(value):
	$GaugeHDG.value_displayed = value


func set_display_alt(value):
	$GaugeALT.value_displayed = value


func set_display_thr(value):
	$GaugeTHR.value_displayed = value


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	hud_scale_vertical = get_viewport().size.y / get_viewport().get_camera().fov
	
	$Centre.position = get_viewport_rect().size / 2
	$Centre/Mask.scale = get_viewport_rect().size.y / 1080 * Vector2.ONE
	$Centre/Wings.position.y = \
		(rad2deg(get_viewport().get_camera().global_rotation.x) - AeroDataBus.aircraft_pitch) \
		* hud_scale_vertical
