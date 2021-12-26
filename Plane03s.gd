extends KinematicBody

var min_flight_speed = 10
var max_flight_speed = 20
var turn_speed = 0.75
var pitch_speed = 0.5
var level_speed = 3.0
var acceleration = 6.0

var forward_speed = 0
var target_speed = 0
var throttle_delta = 30

var velocity = Vector3.ZERO
var turn_input = 0
var pitch_input = 0

func _physics_process(delta):
	get_input(delta)
	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)
	transform.basis = transform.basis.rotated(Vector3.UP, turn_input * turn_speed * delta)
	$Mesh/Body.rotation.y = lerp($Mesh/Body.rotation.y, turn_input, level_speed * delta)
	forward_speed = lerp(forward_speed, target_speed, acceleration * delta)
	velocity = -transform.basis.z * forward_speed
	velocity = move_and_slide(velocity, Vector3.UP)

func get_input(delta):
	if Input.is_action_pressed("throttle_up"):
		target_speed = min(forward_speed + throttle_delta * delta, max_flight_speed)
	if Input.is_action_pressed("throttle_down"):
		target_speed = max(forward_speed - throttle_delta * delta, min_flight_speed)
	turn_input = Input.get_action_strength("roll_left") - Input.get_action_strength("roll_right")
	pitch_input = Input.get_action_strength("pitch_up") - Input.get_action_strength("pitch_down")

