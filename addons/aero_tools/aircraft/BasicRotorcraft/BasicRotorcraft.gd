extends AeroBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var cmd_sas : Vector3 = Vector3.ZERO
var sas_mode : int = 2

var rotation_target : Vector3 = Vector3.ZERO

var thrust_rated : float = 500

var output_throttle : float = 0

var linear_velocity_target : Vector3 = Vector3.ZERO

var linear_velocity_rotated : Vector3 = Vector3.ZERO

var camera_mode : int = 0
var camera_mouse_delta = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	DebugOverlay.stats.add_property(self, "adc_rates", "round")
	DebugOverlay.stats.add_property(self, "tgt_rates", "round")
	DebugOverlay.stats.add_property(self, "tgt_pitch", "round")
	DebugOverlay.stats.add_property(self, "tgt_roll", "round")
	DebugOverlay.stats.add_property(self, "cmd_sas", "round")
	
	DebugOverlay.stats.add_property(self, "tgt_vs", "round")
	DebugOverlay.stats.add_property(self, "linear_velocity", "round")
	DebugOverlay.stats.add_property(self, "linear_velocity_rotated", "round")
	DebugOverlay.stats.add_property(self, "linear_velocity_target", "round")
	DebugOverlay.stats.add_property(self, "output_throttle", "round")
	
	linear_velocity_wind = Vector3(10, 0, 0)
	pass # Replace with function body.

func throttle_map(input_throttle):
	var p1 : Vector2 = Vector2(0, 0)
	var p2 : Vector2 = Vector2(0.4, 0.5)
	var p3 : Vector2 = Vector2(0.4, 0.5)
	var p4 : Vector2 = Vector2(1, 1)
	
	if ((input_throttle >= p1.x) && (input_throttle < p2.x)):
		return (((p2.y - p1.y) / (p2.x - p1.x)) * (input_throttle - p1.x) + p1.y)
	if ((input_throttle >= p2.x) && (input_throttle < p3.x)):
		return (((p3.y - p2.y) / (p3.x - p2.x)) * (input_throttle - p2.x) + p2.y)
	if ((input_throttle >= p3.x) && (input_throttle < p4.x)):
		return (((p4.y - p3.y) / (p4.x - p3.x)) * (input_throttle - p3.x) + p3.y)
	
	
# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta): 
#	angular_velocity_local = (angular_velocity)
	if (control_type == 1):
		# Panel updates
		AeroDataBus.aircraft_pitch = adc_pitch
		AeroDataBus.aircraft_roll = adc_roll
		AeroDataBus.aircraft_alpha = adc_alpha
		AeroDataBus.aircraft_beta = adc_beta
		
		AeroDataBus.aircraft_mu = adc_mu
		AeroDataBus.aircraft_nu = adc_nu
		
		if (Global.setting_units == 0):
			AeroDataBus.aircraft_spd_indicated = adc_spd_indicated
			AeroDataBus.aircraft_spd_true = adc_spd_true
			AeroDataBus.aircraft_alt_barometric = adc_alt_barometric
			AeroDataBus.aircraft_alt_radio = adc_alt_radio
		if (Global.setting_units == 1):
			AeroDataBus.aircraft_spd_indicated = adc_spd_indicated * 2
			AeroDataBus.aircraft_spd_true = adc_spd_true * 2
			AeroDataBus.aircraft_alt_barometric = adc_alt_barometric * 3.2809
			AeroDataBus.aircraft_alt_radio = adc_alt_radio * 3.2809
		
		AeroDataBus.aircraft_hdg = adc_hdg
		AeroDataBus.aircraft_flaps = input_flaps
		AeroDataBus.aircraft_trim = output_elevator_trim
		AeroDataBus.aircraft_gear = gear_current
		AeroDataBus.aircraft_throttle = input_throttle
		AeroDataBus.aircraft_cws = autopilot_on
		
		AeroDataBus.aircraft_nav_waypoint_data = find_angles_and_distance_to_target(Vector3(0, 200, 0))
	
		$RadioAltimeter.rotation_degrees.x = clamp(-adc_pitch, -30, +30)
		$RadioAltimeter.rotation_degrees.z = clamp(+adc_roll, -30, +30)
		
		
		if ($RadioAltimeter.is_colliding() == true):
			adc_alt_radio = (global_position - $RadioAltimeter.get_collision_point()).length()
		else:
			# Set value to show sensor is out of range
			adc_alt_radio = 9999
		
		if (camera_mode == 0):
			$Camera_FPV/FPV_HUD.visible = true
		if (camera_mode == 1):
			$Camera_FPV/FPV_HUD.visible = false
		
		tgt_rates.x = deg_to_rad(input_joystick.y * 10)
		tgt_rates.y = deg_to_rad(input_rudder * 10)
		tgt_rates.z = deg_to_rad(input_joystick.x * 10)
		
#		cmd_sas = 5 * (tgt_rates - adc_rates)
		
		linear_velocity_rotated = linear_velocity.rotated(Vector3.UP, -global_rotation.y)
		
		if (sas_mode == 1):
			tgt_pitch = 20 * input_joystick.y
			tgt_roll = 20 * input_joystick.x
			
		if (sas_mode == 2):
			tgt_pitch = $PID_Calc_Velocity_Z.calc_PID_output(linear_velocity_target.z, linear_velocity_rotated.z)
			tgt_roll = $PID_Calc_Velocity_X.calc_PID_output(linear_velocity_target.x, linear_velocity_rotated.x)
		
		linear_velocity_target.x = 15 * input_joystick.x
		linear_velocity_target.y = 10 * (input_throttle - 0.5)
		linear_velocity_target.z = 15 * input_joystick.y
		
		input_throttle = clamp(input_throttle, 0, 1)
		
		output_throttle = clamp($PID_Calc_Thrust.calc_PID_output(linear_velocity_target.y, linear_velocity.y), 0, 1)
		
		cmd_sas.x = $PID_Calc_Pitch.calc_PID_output(tgt_pitch, adc_pitch)
		cmd_sas.y = input_rudder * 50
		cmd_sas.z = $PID_Calc_Roll.calc_PID_output(tgt_roll, adc_roll)
		
		add_force_local(Vector3(0, thrust_rated * output_throttle, 0), Vector3.ZERO)
		
#		add_torque_local(20 * Vector3(input_joystick.y, -input_rudder, -input_joystick.x))
		add_torque_local(Vector3(cmd_sas.x, -cmd_sas.y, -cmd_sas.z))
		
		# Basic drag
		apply_central_force(-0.2 * air_density * (linear_velocity + linear_velocity_wind).length_squared() * (linear_velocity + linear_velocity_wind).normalized())
		
		# Simplistic camera motion
		$Camera_Ext.position.x = - 0.2 * linear_velocity_local.x
		$Camera_Ext.position.y = 2 - 0.2 * linear_velocity_local.y
		$Camera_Ext.position.z = 10 - 0.2 * linear_velocity_local.z
		
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

		# Cameras
		if (Input.is_action_just_pressed("camera_toggle")):
			camera_mode = camera_mode + 1
		if (camera_mode == 0):
			$Camera_FPV.current = true
		if (camera_mode == 1):
			$Camera_Ext.current = true
		if (camera_mode > 1):
			camera_mode = 0
