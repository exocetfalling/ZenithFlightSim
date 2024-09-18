extends Node3D

func _ready():
#	preload("res://scenes/TestScene.tscn")
	# Clear the viewport.
	var viewport = $SubViewport
	$SubViewport.set_clear_mode(SubViewport.CLEAR_MODE_ONCE)

	# Let two frames pass to make sure the vieport is captured.
	await get_tree().idle_frame
	await get_tree().idle_frame

	# Retrieve the texture and set it to the viewport quad.
	$ViewportQuad.material_override.albedo_texture = viewport.get_texture()
