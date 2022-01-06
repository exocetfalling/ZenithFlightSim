extends Spatial

func _process(_delta):
	$Plane03/Camera_Ext.look_at($Plane03.transform.origin, Vector3.UP)

func get_input(delta):
	pass
