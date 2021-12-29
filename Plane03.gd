extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var throttle_max = 100
var throttle_min = 0
var throttle_current = 0

# Can't fly below this speed
var min_flight_speed = 0
# Maximum airspeed
var max_flight_speed = 30
# Turn rate
var turn_speed = 0.75
# Climb/dive rate
var pitch_speed = 0.5
# Lerp speed returning wings to level
var level_speed = 3.0
# Throttle change speed
var throttle_delta = 30
# Acceleration/deceleration
var acceleration = 6.0

# Current speed
var forward_speed = 20
# Throttle input speed
var target_speed = 0
# Lets us change behavior when grounded
var grounded = false

var pos_local = Vector3.ZERO

var corr_velocity = Vector3.ZERO

var vel_local = Vector3.ZERO
var turn_input = 0
var pitch_input = 0
var yaw_input = 0
var angle_alpha = 0
var angle_beta = 0

var forward_local = Vector3.ZERO
var aft_local = Vector3.ZERO
var right_local = Vector3.ZERO
var left_local = Vector3.ZERO
var up_local = Vector3.ZERO
var down_local = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	DebugOverlay.stats.add_property(self, "grounded", "")
	DebugOverlay.stats.add_property(self, "target_speed", "round")
	DebugOverlay.stats.add_property(self, "linear_velocity", "round")
	DebugOverlay.stats.add_property(self, "vel_local", "round")
	DebugOverlay.stats.add_property(self, "angular_velocity", "round")
	
# Lift coeffecient calculation function
func _calc_lift_coeff(angle_alpha_rad):
	var x1 = -PI
	var y1 = 0
	var x2 = -PI/12
	var y2 = -1.5
	var x3 = PI/12
	var y3 = 1.5
	var x4 = PI
	var y4 = 0

	var a = (y2 - y1) / (x2 - x1)
	var b = (y3 - y2) / (x3 - x2)
	var c = (y4 - y3) / (x4 - x3)

	if ((angle_alpha_rad > x1) and (angle_alpha_rad <= x2)):
		return (a * (angle_alpha_rad - x1) + y1)
	
	elif ((angle_alpha_rad > x2) and (angle_alpha_rad <= x3)):
		return (b * (angle_alpha_rad - x2) + y2)

	elif ((angle_alpha_rad > x3) and (angle_alpha_rad <= x4)):
		return (c * (angle_alpha_rad - x3) + y3)

func _calc_drag_coeff(angle_rad):
	return 0.05 * sin(angle_rad)
	
func _calc_lift_force(air_density, airspeed_true, surface_area, lift_coeff):
	return 0.5 * air_density * pow(airspeed_true, 2) * surface_area * lift_coeff

func _calc_drag_force(air_density, airspeed_true, surface_area, drag_coeff):
	return 0.5 * air_density * pow(airspeed_true, 2) * surface_area * drag_coeff

func _calc_alpha(vel_forward, vel_down):
	return atan2(vel_down, vel_forward)

func _calc_beta(vel_forward, vel_left):
	return atan2(vel_left, vel_forward)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_input(delta)
	corr_velocity = Vector3(linear_velocity.x, linear_velocity.y, -linear_velocity.z)

	
func get_input(delta):
	# Throttle input
	if Input.is_action_pressed("throttle_up"):
		throttle_current = throttle_current + 1 
	if Input.is_action_pressed("throttle_down"):
		throttle_current = throttle_current - 1
	# Turn (roll/yaw) input
	turn_input = 0
	turn_input -= Input.get_action_strength("roll_right")
	turn_input += Input.get_action_strength("roll_left")
	# Pitch (climb/dive) input
	pitch_input = -Input.get_action_strength("pitch_down") + Input.get_action_strength("pitch_up")
	
	# yaw input
	yaw_input = -Input.get_action_strength("yaw_left") + Input.get_action_strength("yaw_right")
	
	

func _integrate_forces(state):
	forward_local = -get_global_transform().basis.z
	aft_local = get_global_transform().basis.z
	right_local = get_global_transform().basis.x
	left_local = -get_global_transform().basis.x
	up_local = get_global_transform().basis.y
	down_local = -get_global_transform().basis.y
	
	vel_local = self.transform.basis.xform_inv(linear_velocity)
	
	add_force(forward_local * throttle_current, Vector3(0, 0, 0))
	add_torque(Vector3(pitch_input, -yaw_input, turn_input))
