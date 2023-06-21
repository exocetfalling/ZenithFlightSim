extends AeroBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta): 
#	vel_angular_local = (angular_velocity)
	if (control_type == 1):
		# Panel updates
		FlightData.aircraft_pitch = adc_pitch
		FlightData.aircraft_roll = adc_roll
		FlightData.aircraft_alpha = adc_alpha
		FlightData.aircraft_beta = adc_beta
		
		FlightData.aircraft_mu = adc_mu
		FlightData.aircraft_nu = adc_nu
		
		if (Global.setting_units == 0):
			FlightData.aircraft_spd_indicated = adc_spd_indicated
			FlightData.aircraft_spd_true = adc_spd_true
			FlightData.aircraft_alt_barometric = adc_alt_barometric
			FlightData.aircraft_alt_radio = adc_alt_radio
		if (Global.setting_units == 1):
			FlightData.aircraft_spd_indicated = adc_spd_indicated * 2
			FlightData.aircraft_spd_true = adc_spd_true * 2
			FlightData.aircraft_alt_barometric = adc_alt_barometric * 3.2809
			FlightData.aircraft_alt_radio = adc_alt_radio * 3.2809
		
		FlightData.aircraft_hdg = adc_hdg
		FlightData.aircraft_flaps = input_flaps
		FlightData.aircraft_trim = output_elevator_trim
		FlightData.aircraft_gear = gear_current
		FlightData.aircraft_throttle = input_throttle
		FlightData.aircraft_cws = autopilot_on
		
		FlightData.aircraft_nav_waypoint_data = find_angles_and_distance_to_target(Vector3(0, 200, 0))
		
		add_force_local(Vector3(0, 400 * input_throttle, 0), Vector3.ZERO)
		
		add_torque_local(Vector3(input_joystick.y, -input_rudder, -input_joystick.x))
		
func get_input(delta):
	# Check if aircraft is under player control
	if (control_type == 1):
			# Throttle input
		if (Input.is_action_pressed("throttle_up")):
			input_throttle += 0.5 * delta 
		if (Input.is_action_pressed("throttle_down")):
			input_throttle -= 0.5 * delta

		# Joystick input as axes
		input_joystick.x = Input.get_axis("roll_left", "roll_right")
		input_joystick.y = Input.get_axis("pitch_down", "pitch_up")
		
		# Yaw input
		input_rudder = Input.get_axis("yaw_left", "yaw_right")
