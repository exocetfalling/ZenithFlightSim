extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var use_IAS : bool = true
var camera_rotation : Vector3 = Vector3.ZERO
var camera_rotation_degrees : Vector3 = Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	DebugOverlay.stats.add_property(self, "camera_rotation_degrees", "round")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (use_IAS == true):
		$GaugeSPD.value_displayed = AeroDataBus.aircraft_spd_indicated
	else:
		$GaugeSPD.value_displayed = AeroDataBus.aircraft_spd_true
	
	$GaugeHDG.value_displayed = AeroDataBus.aircraft_hdg
	$GaugeALT.value_displayed = AeroDataBus.aircraft_alt_barometric
	
	if (get_viewport().get_camera() != null):
		$GaugeFOV.value_displayed = get_viewport().get_camera().fov
		camera_rotation = get_viewport().get_camera().global_transform.basis.get_euler()
		
		camera_rotation_degrees.x = rad2deg(camera_rotation.x)
		camera_rotation_degrees.y = rad2deg(camera_rotation.y)
		camera_rotation_degrees.z = rad2deg(camera_rotation.z)

