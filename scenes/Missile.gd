extends AeroBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var force_fin_f1 : Vector3 = Vector3.ZERO
var force_fin_f2 : Vector3 = Vector3.ZERO
var force_fin_f3 : Vector3 = Vector3.ZERO
var force_fin_f4 : Vector3 = Vector3.ZERO

var force_fin_r1 : Vector3 = Vector3.ZERO
var force_fin_r2 : Vector3 = Vector3.ZERO
var force_fin_r3 : Vector3 = Vector3.ZERO
var force_fin_r4 : Vector3 = Vector3.ZERO

var pos_fin_f1 : Vector3 = Vector3.ZERO
var pos_fin_f2 : Vector3 = Vector3.ZERO
var pos_fin_f3 : Vector3 = Vector3.ZERO
var pos_fin_f4 : Vector3 = Vector3.ZERO

var pos_fin_r1 : Vector3 = Vector3.ZERO
var pos_fin_r2 : Vector3 = Vector3.ZERO
var pos_fin_r3 : Vector3 = Vector3.ZERO
var pos_fin_r4 : Vector3 = Vector3.ZERO

var cmd_vector : Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	control_type = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
	# Aero forces

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta): 
	$AeroSurface_Fin_F1.vel_body = vel_airspeed_true
	force_fin_f1 = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Fin_F1.force_total_surface_vector, \
			$AeroSurface_Fin_F1.rotation \
			)
	$AeroSurface_Fin_F2.vel_body = vel_airspeed_true
	force_fin_f2 = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Fin_F2.force_total_surface_vector, \
			$AeroSurface_Fin_F2.rotation \
			)
	$AeroSurface_Fin_F3.vel_body = vel_airspeed_true
	force_fin_f3 = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Fin_F3.force_total_surface_vector, \
			$AeroSurface_Fin_F3.rotation \
			)
	$AeroSurface_Fin_F4.vel_body = vel_airspeed_true
	force_fin_f4 = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Fin_F4.force_total_surface_vector, \
			$AeroSurface_Fin_F4.rotation \
			)
	
	$AeroSurface_Fin_R1.vel_body = vel_airspeed_true
	force_fin_r1 = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Fin_R1.force_total_surface_vector, \
			$AeroSurface_Fin_R1.rotation \
			)
	$AeroSurface_Fin_R2.vel_body = vel_airspeed_true
	force_fin_r2 = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Fin_R2.force_total_surface_vector, \
			$AeroSurface_Fin_R2.rotation \
			)
	$AeroSurface_Fin_R3.vel_body = vel_airspeed_true
	force_fin_r3 = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Fin_R3.force_total_surface_vector, \
			$AeroSurface_Fin_R3.rotation \
			)
	$AeroSurface_Fin_R4.vel_body = vel_airspeed_true
	force_fin_r4 = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Fin_R4.force_total_surface_vector, \
			$AeroSurface_Fin_R4.rotation \
			)

	pos_fin_f1 = $AeroSurface_Fin_F1.pos_force_rel
	pos_fin_f2 = $AeroSurface_Fin_F2.pos_force_rel
	pos_fin_f3 = $AeroSurface_Fin_F3.pos_force_rel
	pos_fin_f4 = $AeroSurface_Fin_F4.pos_force_rel

	pos_fin_r1 = $AeroSurface_Fin_R1.pos_force_rel
	pos_fin_r2 = $AeroSurface_Fin_R2.pos_force_rel
	pos_fin_r3 = $AeroSurface_Fin_R3.pos_force_rel
	pos_fin_r4 = $AeroSurface_Fin_R4.pos_force_rel
	
	cmd_vector.z = -0.01 * calc_autopilot_factor(air_pressure_dynamic) * adc_roll
	
	$AeroSurface_Fin_F1.rotation = \
		Vector3( \
			(0.1 * (output_elevator - output_rudder)), \
			0, \
			($AeroSurface_Fin_F1.rotation.z) \
			)\
			.rotated(Vector3.FORWARD, \
		-$AeroSurface_Fin_F1.rotation.z)
	
	$AeroSurface_Fin_F2.rotation = \
		Vector3( \
			(0.1 * (output_elevator + output_rudder)), \
			0, \
			($AeroSurface_Fin_F2.rotation.z) \
			)\
			.rotated(Vector3.FORWARD, \
		-$AeroSurface_Fin_F2.rotation.z)
	
	$AeroSurface_Fin_F3.rotation = \
		Vector3( \
			(0.1 * (output_elevator + output_rudder)), \
			0, \
			($AeroSurface_Fin_F3.rotation.z) \
			)\
			.rotated(Vector3.FORWARD, \
		-$AeroSurface_Fin_F3.rotation.z)
	
	$AeroSurface_Fin_F4.rotation = \
		Vector3( \
			(0.1 * (output_elevator - output_rudder)), \
			0, \
			($AeroSurface_Fin_F4.rotation.z) \
			)\
			.rotated(Vector3.FORWARD, \
		-$AeroSurface_Fin_F4.rotation.z)
	
	$AeroSurface_Fin_R1.rotation = \
		Vector3( \
			(-0.1 * (cmd_vector.z)), \
			0, \
			($AeroSurface_Fin_R1.rotation.z) \
			)\
			.rotated(Vector3.FORWARD, \
		-$AeroSurface_Fin_F1.rotation.z)
	
	$AeroSurface_Fin_R2.rotation = \
		Vector3( \
			(+0.1 * (cmd_vector.z)), \
			0, \
			($AeroSurface_Fin_R2.rotation.z) \
			)\
			.rotated(Vector3.FORWARD, \
		-$AeroSurface_Fin_R2.rotation.z)
	
	$AeroSurface_Fin_R3.rotation = \
		Vector3( \
			(-0.1 * (cmd_vector.z)), \
			0, \
			($AeroSurface_Fin_R3.rotation.z) \
			)\
			.rotated(Vector3.FORWARD, \
		-$AeroSurface_Fin_R3.rotation.z)
	
	$AeroSurface_Fin_R4.rotation = \
		Vector3( \
			(+0.001 * (cmd_vector.z)), \
			0, \
			($AeroSurface_Fin_R4.rotation.z) \
			)\
			.rotated(Vector3.FORWARD, \
		-$AeroSurface_Fin_R4.rotation.z)
	
	if (control_type == 1):
		# Panel updates
		FlightData.aircraft_pitch = adc_pitch
		FlightData.aircraft_roll = adc_roll
		FlightData.aircraft_alpha = adc_alpha
		FlightData.aircraft_beta = adc_beta
		
		if (Global.setting_units == 0):
			FlightData.aircraft_spd_indicated = adc_spd_indicated
			FlightData.aircraft_spd_true = adc_spd_true
			FlightData.aircraft_alt_barometric = adc_alt_barometric
		if (Global.setting_units == 1):
			FlightData.aircraft_spd_indicated = adc_spd_indicated * 2
			FlightData.aircraft_spd_true = adc_spd_true * 2
			FlightData.aircraft_alt_barometric = adc_alt_barometric * 3.2809
		
		FlightData.aircraft_hdg = adc_hdg
		FlightData.aircraft_flaps = input_flaps * 4
		FlightData.aircraft_trim = output_elevator_trim
		FlightData.aircraft_gear = gear_current
		FlightData.aircraft_throttle = input_throttle
		FlightData.aircraft_ap = autopilot_on
	
func _integrate_forces(_state):
	# Gravity
	add_central_force(Vector3(0, -weight, 0))
	
	# Thrust forces
	add_force_local(Vector3(0, 0, -weight/3 * input_throttle), Vector3(0, 0, 0))
	
	# Forces from surfaces 
	add_force_local(force_fin_f1, pos_fin_f1)
	add_force_local(force_fin_f2, pos_fin_f2)
	add_force_local(force_fin_f3, pos_fin_f3)
	add_force_local(force_fin_f4, pos_fin_f4)
	
	add_force_local(force_fin_r1, pos_fin_r1)
	add_force_local(force_fin_r2, pos_fin_r2)
	add_force_local(force_fin_r3, pos_fin_r3)
	add_force_local(force_fin_r4, pos_fin_r4)

func get_input(delta):
	# Check if aircraft is under player control
	if (control_type == 1):
			# Throttle input
		if (Input.is_action_pressed("throttle_up")):
			if (input_throttle < throttle_max):
				input_throttle += 0.5 * delta 
		if (Input.is_action_pressed("throttle_down")):
			if (input_throttle > throttle_min):
				input_throttle -= 0.5 * delta

		# Joystick input (as vector) 
		input_joystick = Input.get_vector("roll_left", "roll_right", "pitch_down", "pitch_up")
		
		# Yaw input
		input_rudder = -Input.get_action_strength("yaw_left") + Input.get_action_strength("yaw_right")
		
