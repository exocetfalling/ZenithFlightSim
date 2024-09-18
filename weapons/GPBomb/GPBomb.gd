extends RigidBody3D
var fuel = 100

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
	pos_local = self.transform.basis * (pos)
	force_local = self.transform.basis * (force)
	self.apply_force(pos_local, force_local)

func _on_bomb_body_entered(body):
	emit_signal("exploded", transform.origin)
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _integrate_forces(_state):
	add_force_local(Vector3(0, 0, -5000), Vector3.ZERO)
