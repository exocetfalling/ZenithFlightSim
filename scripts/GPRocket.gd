extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var force_local
var pos_local

var launched = false
var fuel = 100
var explosion_scene = preload("res://scenes/Explosion.tscn")
signal exploded

# Called when the node enters the scene tree for the first time.
func _ready():
	$Particles.visible = false

func add_force_local(force: Vector3, pos: Vector3):
	pos_local = self.transform.basis.xform(pos)
	force_local = self.transform.basis.xform(force)
	self.add_force(force_local, pos_local)

func _on_body_entered(_body):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (launched == true):
		if (fuel > 0):
			$Particles.visible = true
			fuel = fuel - 20 * delta
		if (fuel <= 0):
			$Particles.visible = false
	
	if ($RayCast.is_colliding() == true):
		emit_signal("exploded", transform.origin)
		fuel = 0
		var clone = explosion_scene.instance()
		var scene_root = get_tree().root.get_children()[0]
		scene_root.add_child(clone)
		clone.global_transform = self.global_transform
		queue_free()

func _integrate_forces(_state):
	if ((fuel > 0) && (launched == true)):
		add_force_local(Vector3(0, 0, -5000), Vector3(0, 0, 2))
