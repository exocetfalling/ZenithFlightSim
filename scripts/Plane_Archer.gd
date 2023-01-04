extends AeroBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var force_wing_l : Vector3 = Vector3.ZERO
var force_wing_r : Vector3 = Vector3.ZERO

var force_control_L1 : Vector3 = Vector3.ZERO
var force_control_L2 : Vector3 = Vector3.ZERO
var force_control_R1 : Vector3 = Vector3.ZERO
var force_control_R2 : Vector3 = Vector3.ZERO

var pos_wing_l : Vector3 = Vector3.ZERO
var pos_wing_r : Vector3 = Vector3.ZERO

var pos_control_L1 : Vector3 = Vector3.ZERO
var pos_control_L2 : Vector3 = Vector3.ZERO
var pos_control_R1 : Vector3 = Vector3.ZERO
var pos_control_R2 : Vector3 = Vector3.ZERO

var output_rudder_l : float = 0
var output_rudder_r : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	control_type = 1
	DebugOverlay.stats.add_property(self, "vel_local", "round")
	DebugOverlay.stats.add_property(self, "force_wing_l", "round")
	DebugOverlay.stats.add_property(self, "force_wing_r", "round")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta): 
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
	
	# Aero forces
	$AeroSurface_Wing_L.vel_body = vel_airspeed_true
	force_wing_l = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Wing_L.force_total_surface_vector, \
			$AeroSurface_Wing_L.rotation \
			)
	$AeroSurface_Wing_R.vel_body = vel_airspeed_true
	force_wing_r = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Wing_R.force_total_surface_vector, \
			$AeroSurface_Wing_R.rotation \
			)
	
	$AeroSurface_Control_L1.vel_body = vel_airspeed_true
	force_control_L1 = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Control_L1.force_total_surface_vector, \
			$AeroSurface_Control_L1.rotation \
			)
	$AeroSurface_Control_L2.vel_body = vel_airspeed_true
	force_control_L2 = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Control_L2.force_total_surface_vector, \
			$AeroSurface_Control_L2.rotation \
			)
	$AeroSurface_Control_R1.vel_body = vel_airspeed_true
	force_control_R1 = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Control_R1.force_total_surface_vector, \
			$AeroSurface_Control_R1.rotation \
			)
	$AeroSurface_Control_R2.vel_body = vel_airspeed_true
	force_control_R2 = \
		calc_force_rotated_from_surface( \
			$AeroSurface_Control_R2.force_total_surface_vector, \
			$AeroSurface_Control_R2.rotation \
			)
			
	
	pos_wing_l = $AeroSurface_Wing_L.pos_force_rel
	pos_wing_r = $AeroSurface_Wing_R.pos_force_rel
	
	pos_control_L1 = $AeroSurface_Control_L1.pos_force_rel
	pos_control_L2 = $AeroSurface_Control_L2.pos_force_rel
	pos_control_R1 = $AeroSurface_Control_R1.pos_force_rel
	pos_control_R2 = $AeroSurface_Control_R2.pos_force_rel
	
	output_aileron = lerp(input_joystick.x, output_aileron, 0.50)
	output_elevator = lerp(input_joystick.y, output_elevator, 0.50)
	output_rudder = lerp(input_rudder, output_rudder, 0.50)
	
	if (output_rudder < 0): 
		output_rudder_l = -output_rudder
		output_rudder_r = 0
	if (output_rudder > 0):
		output_rudder_r = +output_rudder
		output_rudder_l = 0
	if (output_rudder == 0):
		output_rudder_l = 0
		output_rudder_r = 0
	
	$AeroSurface_Control_L1.rotation.x = 0.2 * (+output_aileron -output_elevator -5 * output_rudder_l)
	$AeroSurface_Control_L2.rotation.x = 0.2 * (+output_aileron -output_elevator +5 * output_rudder_l)
	$AeroSurface_Control_R1.rotation.x = 0.2 * (-output_aileron -output_elevator -5 * output_rudder_r)
	$AeroSurface_Control_R2.rotation.x = 0.2 * (-output_aileron -output_elevator +5 * output_rudder_r)

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
		input_rudder = -Input.get_axis("yaw_right", "yaw_left")

func _integrate_forces(_state):
	# Gravity
#	add_central_force(Vector3(0, -weight, 0))
	# Thrust forces
	add_force_local(Vector3(0, 0, -weight/1 * input_throttle), Vector3(0, -0.1, 0))
	
	# Forces from surfaces 
	add_force_local(force_wing_l, pos_wing_l)
	add_force_local(force_wing_r, pos_wing_r)
	
	add_force_local(force_control_L1, pos_control_L1)
	add_force_local(force_control_L2, pos_control_L2)
	add_force_local(force_control_R1, pos_control_R1)
	add_force_local(force_control_R2, pos_control_R2)
