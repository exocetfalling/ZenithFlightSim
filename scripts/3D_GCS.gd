extends Spatial
onready var viewport = get_node("Viewport")
func _ready():
#	preload("res://scenes/TestScene.tscn")
	# Clear the viewport.
	viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)

	# Let two frames pass to make sure the vieport is captured.
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

	# Retrieve the texture and set it to the viewport quad.
	$PillarBack/ViewportQuad.material_override.albedo_texture = viewport.get_texture()
	set_process_input(true)
	
func _unhandled_input(event):
	viewport.input(event)
