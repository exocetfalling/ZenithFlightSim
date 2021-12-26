extends Spatial

func _process(_delta):
	$Camera2.look_at($Plane03.transform.origin, Vector3.UP)
