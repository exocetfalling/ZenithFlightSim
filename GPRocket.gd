extends RigidBody
var fuel = 100
var explosion_scene = preload("Explosion.tscn")
signal exploded


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var force_local
var pos_local

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_force_local(force: Vector3, pos: Vector3):
	pos_local = self.transform.basis.xform(pos)
	force_local = self.transform.basis.xform(force)
	self.add_force(force_local, pos_local)

func _on_body_entered(_body):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (fuel > 0):
		fuel = fuel - 20 * delta
	if (fuel <= 0):
		emit_signal("exploded", transform.origin)
		queue_free()
	
	if ($RayCast.is_colliding() == true):
		emit_signal("exploded", transform.origin)
		fuel = 0
		var clone = explosion_scene.instance()
		add_child(clone)
		clone.global_transform = self.global_transform
		queue_free()

func _integrate_forces(_state):
	if (fuel > 0):
		add_force_local(Vector3(0, 0, -5000), Vector3(0, 0, 2))
