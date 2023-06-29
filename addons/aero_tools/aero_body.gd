extends VehicleBody

# Class for aircraft
# For different atmospheres override calc_atmo_properties()
# Mars, Titan etc.
class_name AeroBody

# Type of control
# 0 - none
# 1 - player
# 2 - AI
export var control_type : int = 0

# Air temperature, K
var air_temperature : float = 288.0

# Air pressure, Pa
var air_pressure : float = 101325

# Dynamic pressure, Pa
var air_pressure_dynamic : float = 0.00

# Air density, kg/m^3
var air_density = 1.2

var ground_contact_NLG = false
var ground_contact_MLG_L = false
var ground_contact_MLG_R = false

var linear_velocity_corrected = Vector3.ZERO

var linear_velocity_local = Vector3.ZERO
var airspeed_true_vector : Vector3 = Vector3.ZERO
var airspeed_true_total : float = 0.00

var linear_velocity_wind : Vector3 = Vector3.ZERO

var linear_velocity_total = 0

var angular_velocity_local = Vector3.ZERO
var angular_velocity_local_deg = Vector3.ZERO

var adc_spd_indicated = 0
var adc_spd_true = 0
var adc_spd_ground = 0

var adc_alt_barometric = 0
var adc_alt_radio = 0

var adc_hdg = 0

var adc_pitch = 0
var adc_roll = 0

var adc_alpha = 0
var adc_beta = 0

var adc_mu = 0
var adc_nu = 0

var adc_fpa = 0
var tgt_fpa = 0
var adc_trk = 0
var tgt_trk = 0

var adc_stall = false

var throttle_max = 1
var throttle_min = 0
var input_throttle = 0

var autopilot_on = 0
var tgt_pitch = 0
var tgt_roll = 0

var angle_alpha = 0
var angle_alpha_deg = 0
var angle_beta = 0
var angle_beta_deg = 0 

# Inertial-derived angles to calculate trajectory offset by wind
var angle_mu = 0
var angle_mu_deg = 0
var angle_nu = 0
var angle_nu_deg = 0 

# Deflection in radians
var deflection_control_max = PI/12
var deflection_flaps_max = PI/6
var angle_incidence = 0.02

var input_elevator = 0
var current_elevator = 0
var output_elevator = 0

var current_aileron = 0
var input_aileron = 0
var output_aileron = 0

var current_rudder = 0
var input_rudder = 0
var output_rudder = 0
var output_yaw_damper = 0

var current_flaps = 0
var input_flaps = 0
var output_flaps = 0
var flaps_max = 1
var flaps_min = 0

var current_elevator_trim = 0
var input_elevator_trim = 0
var output_elevator_trim = 0

var input_trim_pitch_max = 1
var input_trim_pitch_min = -1

var input_braking = 0

var input_joystick : Vector2 = Vector2.ZERO

var gear_max = 1
var gear_min = 0
var gear_current = 1
var gear_input = 1

var deflection_rate = 1/(PI/6)
var deflection_rate_flaps = 1/(2 * PI)

# FBW variables

# Pitch, yaw, roll
# Roll inverted from Godot convention
# So roll rate is +ve for roll right

var adc_rates = Vector3.ZERO
var tgt_rates = Vector3.ZERO

# Pitch, yaw, roll, to be sent to servos
var fbw_output = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

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
	return abs(0.05 * sin(angle_rad)) 

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
	var force_local
	var pos_local
	
	pos_local = self.transform.basis.xform(pos)
	force_local = self.transform.basis.xform(force)
	self.add_force(force_local, pos_local)

func add_torque_local(torque: Vector3):
	var torque_local

	torque_local = self.transform.basis.xform(torque)
	self.add_torque(torque_local)

func calc_atmo_properties(height_metres):
	# Store atmospheric properties as Vector3
	# X value is air temperature, deg C
	# Y value is air pressure, kPa
	# Z value is air density, kg m^-3
	
	# From https://en.wikipedia.org/wiki/Density_of_air#Variation_with_altitude
	
	var atmo_properties : Vector3 = Vector3(288.15, 101325, 1.20)
	
	var p_0 = 101325 # Sea level standard atmospheric pressure, Pa
	var T_0 = 288.15 # Sea level standard temperature, K
	var g = 9.80665 # Earth-surface gravitational acceleration, m s^-2
	var L = 0.0065 # Temperature lapse rate, K m^-1
	var R = 8.31446 # Ideal (universal) gas constant, J K^-1 mol^-1
	var M = 0.0289652 # molar mass of dry air, kg mol^-1
	
	
	atmo_properties.x = \
		T_0 - L * height_metres
	
	atmo_properties.y = \
		p_0 * pow((1 - (L * height_metres / T_0)), (g * M / R / L))
	
	atmo_properties.z = \
		(atmo_properties.y * M) / (R * atmo_properties.x)
	
	return atmo_properties

func interpolate_linear(value_current, value_target, rate, delta_time):
	if (abs(value_current - value_target) > delta_time):
		if (value_current < value_target):
			return value_current + rate * delta_time
		if (value_current > value_target):
			return value_current - rate * delta_time
		else:
			return value_target
	else:
		return value_target

func calc_braking_force(vel_fwd, weight_craft, commanded_braking):
	var braking_coeff
	var braking_force
	
	if (vel_fwd > 0):
		braking_coeff = 0.5

	elif (vel_fwd < 0):
		braking_coeff = -0.5
	
	else:
		braking_coeff = 0
	
	braking_force = braking_coeff * weight_craft * input_braking
	return braking_force

func find_bearing_and_range_to(vec_pos_target, vec_pos_source):
	var vec_delta_pos = vec_pos_target - vec_pos_source
	var vec_delta_pos_2d = Vector2(vec_delta_pos.x, vec_delta_pos.z)
	var vec_delta_pos_2d_norm = vec_delta_pos_2d.normalized()
	var bearing_to = fmod(-rad2deg(atan2(vec_delta_pos_2d_norm.x, vec_delta_pos_2d_norm.y)) + 360, 360)
	var range_to = vec_delta_pos_2d.length()
	return Vector2(bearing_to, range_to)

func find_angles_and_distance_to_target(vec_pos_target):
	var vec_delta_local = to_local(vec_pos_target)
	var pitch_to = rad2deg(atan2(vec_delta_local.y, -vec_delta_local.z))
	var yaw_to = rad2deg(atan2(vec_delta_local.x, -vec_delta_local.z))
	var range_to = vec_delta_local.length()
	return Vector3(yaw_to, pitch_to, range_to)

func calc_fcs_gains(dyn_press):
	if (dyn_press > 0):
		return 1 / dyn_press * 500
	else:
		return 1

func calc_vel_local_with_offset(vel_linear_local, angular_velocity_local, pos_offset):
	var vel_local_with_offset : Vector3
	vel_local_with_offset.x = vel_linear_local.x + angular_velocity_local.x * pos_offset.x
	vel_local_with_offset.y = vel_linear_local.y + angular_velocity_local.y * pos_offset.y
	vel_local_with_offset.z = vel_linear_local.z + angular_velocity_local.z * pos_offset.z
	
	return vel_local_with_offset

func calc_force_rotated_from_surface(force_vector, surface_node_rotation):
	return force_vector.rotated(Vector3(0, 0, -1), -surface_node_rotation.z)
	
# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	get_input(delta)
	
	linear_velocity_total = self.linear_velocity.length()
	linear_velocity_local = (self.transform.basis.xform_inv(linear_velocity))
	
	airspeed_true_vector = linear_velocity_local + self.transform.basis.xform_inv(linear_velocity_wind)
	airspeed_true_total = airspeed_true_vector.length()
	
	angular_velocity_local = global_transform.basis.z * (angular_velocity)
	angular_velocity_local_deg = Vector3(rad2deg(angular_velocity_local.x), rad2deg(angular_velocity_local.y), rad2deg(angular_velocity_local.z))
	
	air_temperature = calc_atmo_properties(global_transform.origin.y).x
	air_pressure = calc_atmo_properties(global_transform.origin.y).y
	air_density = calc_atmo_properties(global_transform.origin.y).z
	
	air_pressure_dynamic = 0.5 * air_density * pow(airspeed_true_total, 2)

	# Output delays
	output_aileron = interpolate_linear(output_aileron, input_joystick.x, deflection_rate, delta)
	output_elevator = interpolate_linear(output_elevator, input_joystick.y, deflection_rate, delta)
	output_rudder = interpolate_linear(output_rudder, input_rudder + output_yaw_damper, deflection_rate, delta)
	
	output_flaps = interpolate_linear(output_flaps, input_flaps, deflection_rate_flaps, delta)
	output_elevator_trim = input_elevator_trim
	
	# Key angles
	angle_alpha = atan2(-airspeed_true_vector.y, -airspeed_true_vector.z)
	angle_beta = atan2(-airspeed_true_vector.x, -airspeed_true_vector.z)
	
	angle_alpha_deg = rad2deg(angle_alpha)
	angle_beta_deg = rad2deg(angle_beta)
	
	angle_mu = atan2(-linear_velocity_local.y, -linear_velocity_local.z)
	angle_nu = atan2(-linear_velocity_local.x, -linear_velocity_local.z)
	
	angle_mu_deg = rad2deg(angle_mu)
	angle_nu_deg = rad2deg(angle_nu)
	
	# KTAS to KIAS 
	adc_spd_indicated = sqrt(2 * air_pressure_dynamic / 1.225)
	adc_spd_true = airspeed_true_vector.length()
	adc_spd_ground = linear_velocity_total
	

	if ((rotation_degrees.y) >= 0):
		adc_hdg = -rotation_degrees.y + 360
	else:
		adc_hdg = -rotation_degrees.y
		
	adc_alt_barometric = global_transform.origin.y
	
	adc_pitch = rotation_degrees.x
	adc_roll = -rotation_degrees.z
	
	adc_alpha = angle_alpha_deg
	adc_beta = angle_beta_deg
	
	adc_mu = angle_mu_deg
	adc_nu = angle_nu_deg
	
	adc_fpa = adc_pitch - adc_alpha
	adc_trk = fmod((adc_hdg - adc_beta) + 360, 360)

	# FBW
	adc_rates.x = -angular_velocity_local_deg.x
	adc_rates.y = angular_velocity_local_deg.y
	adc_rates.z = -angular_velocity_local_deg.z
	
	if (angle_alpha_deg > 15):
		adc_stall = true
	else:
		adc_stall = false
	
	if (gear_current < gear_input):
		gear_current = gear_current + 0.2 * delta
	if (gear_current > gear_input):
		gear_current = gear_current - 0.2 * delta
	if (abs(gear_current - gear_input) < 0.01):
		gear_current = gear_input
	
	input_elevator_trim = clamp(input_elevator_trim, input_trim_pitch_min, input_trim_pitch_max)
	
	output_rudder = clamp(output_rudder, -1, 1)

func get_input(delta):
	pass
