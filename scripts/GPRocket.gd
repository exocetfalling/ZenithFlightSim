extends RigidBody

#var DerivCalc1 = preload("res://scripts/Derivative_Calc.gd").new()
#var DerivCalc2 = preload("res://scripts/Derivative_Calc.gd").new()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var air_density = 1.2

var angle_alpha = 0
var angle_alpha_deg = 0
var angle_beta = 0
var angle_beta_deg = 0

var forward_local = Vector3.ZERO
var aft_local = Vector3.ZERO
var right_local = Vector3.ZERO
var left_local = Vector3.ZERO
var up_local = Vector3.ZERO
var down_local = Vector3.ZERO

# Specs from CollisionShape measurements

# Positions as (x, y, z) m, z reversed
var pos_wing = Vector3(0, 0, 0)
var pos_h_tail = Vector3(0, 0, 2)
var pos_v_tail = Vector3(0, 1.5, 10)
var pos_fuse = Vector3(0, 0, 1)


var corr_velocity = Vector3.ZERO

var vel_local_intermediate = Vector3.ZERO
var vel_local = Vector3.ZERO
var vel_total = 0

var angle_incidence = 0

# Areas in m^2
var area_wing = 2 
var area_h_tail = 1
var area_v_tail = 1
var area_fuse = 0.05
var area_aileron = 1
var area_elevator = 1
var area_rudder = 1

var force_local
var pos_local

# forces in N
var force_lift_wing = Vector3.ZERO
var force_lift_h_tail = Vector3.ZERO
var force_lift_v_tail = Vector3.ZERO
var force_lift_h_fuse = Vector3.ZERO
var force_lift_v_fuse = Vector3.ZERO
var force_lift_aileron_l = Vector3.ZERO
var force_lift_aileron_r = Vector3.ZERO
var force_lift_elevator = Vector3.ZERO
var force_lift_rudder = Vector3.ZERO
var force_lift_flaps = Vector3.ZERO

var force_drag_wing = Vector3.ZERO
var force_drag_h_tail = Vector3.ZERO
var force_drag_v_tail = Vector3.ZERO
var force_drag_fuse = Vector3.ZERO
var force_drag_aileron_l = Vector3.ZERO
var force_drag_aileron_r = Vector3.ZERO
var force_drag_elevator = Vector3.ZERO
var force_drag_rudder = Vector3.ZERO
var tgt_vector = Vector3.ZERO
var cmd_vector = Vector3.ZERO
var tgt_coordinates = Vector3.ZERO

var launched = false
var fuel = 100
var explosion_scene = preload("res://scenes/Explosion.tscn")
signal exploded

# Called when the node enters the scene tree for the first time.
func _ready():
#	DebugOverlay.stats.add_property(self, "tgt_vector", "round")
#	DebugOverlay.stats.add_property(self, "cmd_vector", "round")
	$Particles.visible = false

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

	if (angle_alpha_rad < x1):
		return (a * (angle_alpha_rad + 2 * PI - x1) + y1)
		
	elif ((angle_alpha_rad > x1) and (angle_alpha_rad <= x2)):
		return (a * (angle_alpha_rad - x1) + y1)
	
	elif ((angle_alpha_rad > x2) and (angle_alpha_rad <= x3)):
		return (b * (angle_alpha_rad - x2) + y2)

	elif ((angle_alpha_rad > x3) and (angle_alpha_rad <= x4)):
		return (c * (angle_alpha_rad - x3) + y3)
	
	elif (angle_alpha_rad > x4):
		return (a * (angle_alpha_rad - 2 * PI - x1) + y1)
	
	else:
		return 0
		

func _calc_drag_induced_coeff(angle_rad):
	return abs(0.1 * sin(angle_rad)) 

func _calc_drag_parasite_coeff(angle_rad):
	return abs(0.02 * cos(angle_rad))
	
func _calc_lift_force(air_density_current, airspeed_true, surface_area, lift_coeff):
	return 0.5 * air_density_current * pow(airspeed_true, 2) * surface_area * lift_coeff
	
func _calc_drag_force(air_density_current, airspeed_true, surface_area, drag_coeff):
	return 0.5 * air_density_current * pow(airspeed_true, 2) * surface_area * drag_coeff

func _calc_alpha(vel_up, vel_fwd):
	return atan2(-vel_up, vel_fwd)

func _calc_beta(vel_right, vel_fwd):
	return atan2(-vel_right, vel_fwd)
	
func add_force_local(force: Vector3, pos: Vector3):
	pos_local = self.transform.basis.xform(pos)
	force_local = self.transform.basis.xform(force)
	self.add_force(force_local, pos_local)


func find_angles_and_distance_to_target(vec_pos_target):
	var vec_delta_local = to_local(vec_pos_target)
	var pitch_to = rad2deg(atan2(vec_delta_local.y, -vec_delta_local.z))
	var yaw_to = rad2deg(atan2(vec_delta_local.x, -vec_delta_local.z))
	var range_to = vec_delta_local.length()
	return Vector3(yaw_to, pitch_to, range_to)

func _on_body_entered(_body):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	angle_alpha = _calc_alpha(vel_local.y, vel_local.z)
	angle_beta = _calc_beta(vel_local.x, vel_local.z)
	
	angle_alpha_deg = rad2deg(angle_alpha)
	angle_beta_deg = rad2deg(angle_beta)

	# Lift/drag calculations (helpers for add_force_local)
	
	#Static, non-moving elements
	force_lift_wing = Vector3(0, _calc_lift_force(air_density, vel_total, area_wing, _calc_lift_coeff(angle_alpha + angle_incidence)), 0)

	force_lift_h_tail = Vector3(0, _calc_lift_force(air_density, vel_total, area_h_tail, _calc_lift_coeff(angle_alpha)), 0)
	force_lift_v_tail = Vector3(_calc_lift_force(air_density, vel_total, area_v_tail, _calc_lift_coeff(angle_beta)), 0, 0)


	force_drag_wing = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_wing, _calc_drag_induced_coeff(angle_alpha + angle_incidence)))

	force_drag_h_tail = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_h_tail, _calc_drag_induced_coeff(angle_alpha)))
	force_drag_v_tail = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_v_tail, _calc_drag_induced_coeff(angle_beta)))

	force_drag_fuse = Vector3(0, 0, _calc_drag_force(air_density, vel_total, area_fuse, _calc_drag_parasite_coeff(angle_alpha)))
	if (launched == true):
		tgt_vector = find_angles_and_distance_to_target(tgt_coordinates)
		cmd_vector.x = 5 * (tgt_vector.x + 3 * angle_beta_deg)
		cmd_vector.y = 5 * (tgt_vector.y + 3 * angle_alpha_deg)
#		cmd_vector.x = 0.1 * DerivCalc1.find_derivative(tgt_coordinates.x, delta)
#		cmd_vector.y = 0.1 * DerivCalc2.find_derivative(tgt_coordinates.y, delta)
		
		if (fuel > 0):
			$Particles.visible = true
			fuel = fuel - 75 * delta
		if (fuel <= 0):
			$Particles.visible = false
	
	if (($RayCast.is_colliding() == true) && (launched == true)):
		emit_signal("exploded", transform.origin)
		fuel = 0
		var clone = explosion_scene.instance()
		var scene_root = get_tree().root.get_children()[0]
		scene_root.add_child(clone)
		clone.global_transform = self.global_transform
		queue_free()


func _integrate_forces(_state):
	# Lift forces from static elements (non-moving)
	add_force_local(force_lift_wing, pos_wing)
	add_force_local(force_lift_h_tail, pos_h_tail)
	add_force_local(force_lift_v_tail, pos_v_tail)
	
	# Drag forces
	add_force_local(force_drag_wing, pos_wing)
	add_force_local(force_drag_h_tail, pos_h_tail)
	add_force_local(force_drag_v_tail, pos_v_tail)
	
	if (launched == true):
#		add_force_local(Vector3(-0 * cmd_vector.x, -0 * cmd_vector.y, -5000), Vector3(0, 0, 2))
		add_force_local(Vector3(cmd_vector.x, cmd_vector.y, 0), Vector3(0, 0, -2))
		if (fuel > 0):
			add_force_local(Vector3(0, 0, -8000), Vector3(0, 0, 2))
