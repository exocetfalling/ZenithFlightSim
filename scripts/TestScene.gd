extends Spatial

var start_mode = 'air'

# Called when the node enters the scene tree for the first time.
func _ready():
	start_mode = 'ground'
	
	if (start_mode == 'air'):
		$Plane/Plane03.mode = 3
		$Plane/Plane03.translation = Vector3(0, 1000, 0)
		$Plane/Plane03.linear_velocity = Vector3(0, 0, -100)
		$Plane/Plane03.angular_velocity = Vector3(0, 0, 0)
		$Plane/Plane03.mode = 0


func _process(_delta):
#	$Plane03/Camera_Ext.look_at($Plane03.transform.origin, Vector3.UP)
	pass

func get_input(delta):
	pass
