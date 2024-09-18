extends Camera3D

@export var lerp_speed = 3.0

@export var target_path: NodePath = null
@export var offset: Vector3 = Vector3.ZERO
var target = null

func _ready():
	if target_path:
		target = get_node(target_path)

func _physics_process(delta):
	if !target:
		return
	var target_pos = target.global_transform.translated(offset)
	global_transform = global_transform.interpolate_with(target_pos, lerp_speed * delta)
	look_at(target.global_transform.origin, target.transform.basis.y)
