extends Node3D

var start_mode = 'air'

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("WPT_03").global_transform.origin = get_node("Target").global_transform.origin
	
	start_mode = 'ground'
	
	if (start_mode == 'air'):
		$Plane/Plane03.mode = 3
		$Plane/Plane03.global_transform.origin = Vector3(0, 1000, 0)
		$Plane/Plane03.linear_velocity = Vector3(0, 0, -100)
		$Plane/Plane03.angular_velocity = Vector3(0, 0, 0)
		$Plane/Plane03.mode = 0


func _process(_delta):
	$Plane/Plane03.WPT_01_coodinates = get_node("WPT_01").global_transform.origin
	$Plane/Plane03.WPT_02_coodinates = get_node("WPT_02").global_transform.origin
	$Plane/Plane03.WPT_03_coodinates = get_node("WPT_03").global_transform.origin
	
#	if ($Plane/Plane03.wpt_current == 'WPT 01'):
#		$WPT_01.visible = true
#		$WPT_02.visible = false
#		$WPT_03.visible = false
#	if ($Plane/Plane03.wpt_current == 'WPT 02'):
#		$WPT_01.visible = false
#		$WPT_02.visible = true
#		$WPT_03.visible = false
#	if ($Plane/Plane03.wpt_current == 'WPT 03'):
#		$WPT_01.visible = false
#		$WPT_02.visible = false
#		$WPT_03.visible = true
func get_input(delta):
	pass
