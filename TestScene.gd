extends Spatial

func _process(_delta):
	$Plane03/Camera2.look_at($Plane03.transform.origin, Vector3.UP)

func get_input(delta):
	pass
