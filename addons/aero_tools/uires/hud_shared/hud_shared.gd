extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@export var use_IAS : bool = true

var hud_scale_vertical: float = 0

var hud_pitch: float = 0
var hud_roll: float = 0

var hud_spd: float = 0
var hud_hdg: float = 0
var hud_alt: float = 0
var hud_thr: float = 0
var hud_flaps: float = 0
var hud_trim: float = 0
var hud_gear: float = 1

var hud_angle_inertial_y: float = 0
var hud_angle_inertial_x: float = 0


# Called when the node enters the scene tree for the first time.
func _ready():
#	DebugOverlay.stats.add_property(self, "camera_rotation_degrees", "round")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	hud_scale_vertical = get_viewport().size.y / get_viewport().get_camera_3d().fov
	
	$GaugeSpeed.value_displayed = hud_spd
	$GaugeHeading.value_displayed = hud_hdg
	$GaugeAltitude.value_displayed = hud_alt
	$GaugeThrottle.value_displayed = hud_thr
	$GaugeFlaps.value_displayed = hud_flaps * 4
	$GaugeTrim.value_displayed = hud_trim
	$GaugeGear.value_displayed = hud_gear
	
	$Centre.global_position = get_viewport_rect().size / 2
	$Centre/Mask.scale = get_viewport_rect().size.y / 1080 * Vector2.ONE
	$Centre/Wings.position.y = \
		(rad_to_deg(get_viewport().get_camera_3d().global_rotation.x) - hud_pitch) \
		* hud_scale_vertical
	$Centre/Wings/FPM.position.x = hud_angle_inertial_x * hud_scale_vertical
	$Centre/Wings/FPM.position.y = hud_angle_inertial_y * hud_scale_vertical
	
	$Centre/Wings/FPM/AccTrend.position.y = -20 * $SpeedDeriv.calc_derivative(hud_spd, delta)
	
	#if hud_gear > 0.5:
		#$Centre/Wings/GearInd/Tris.visible = true
	#else:
		#$Centre/Wings/GearInd/Tris.visible = false
	
	#if hud_gear > 0 and hud_gear < 1:
		#$Centre/Wings/GearInd/Transit.visible = true
	#else:
		#$Centre/Wings/GearInd/Transit.visible = false
