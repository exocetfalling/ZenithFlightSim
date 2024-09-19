extends AeroBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var forceWingl : Vector3 = Vector3.ZERO
var forceWingr : Vector3 = Vector3.ZERO

var force_control_L1 : Vector3 = Vector3.ZERO
var force_control_L2 : Vector3 = Vector3.ZERO
var force_control_R1 : Vector3 = Vector3.ZERO
var force_control_R2 : Vector3 = Vector3.ZERO

var posWingl : Vector3 = Vector3.ZERO
var posWingr : Vector3 = Vector3.ZERO

var pos_control_L1 : Vector3 = Vector3.ZERO
var pos_control_L2 : Vector3 = Vector3.ZERO
var pos_control_R1 : Vector3 = Vector3.ZERO
var pos_control_R2 : Vector3 = Vector3.ZERO

var output_rudder_l : float = 0
var output_rudder_r : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
#	control_type = 1
	DebugOverlay.stats.add_property(self, "linear_velocity_local", "round")
	DebugOverlay.stats.add_property(self, "forceWingl", "round")
	DebugOverlay.stats.add_property(self, "forceWingr", "round")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta): 
	super(delta)
	
	if (control_type == 1):
		# Panel updates
		AeroDataBus.aircraft_pitch = adc_pitch
		AeroDataBus.aircraft_roll = adc_roll
		AeroDataBus.aircraft_alpha = adc_alpha
		AeroDataBus.aircraft_beta = adc_beta
		
		if (Global.setting_units == 0):
			AeroDataBus.aircraft_spd_indicated = adc_spd_indicated
			AeroDataBus.aircraft_spd_true = adc_spd_true
			AeroDataBus.aircraft_alt_barometric = adc_alt_asl
		if (Global.setting_units == 1):
			AeroDataBus.aircraft_spd_indicated = adc_spd_indicated * 2
			AeroDataBus.aircraft_spd_true = adc_spd_true * 2
			AeroDataBus.aircraft_alt_barometric = adc_alt_asl * 3.2809
		
		AeroDataBus.aircraft_hdg = adc_hdg
		AeroDataBus.aircraft_flaps = input_flaps * 4
		AeroDataBus.aircraft_trim = output_elevator_trim
		AeroDataBus.aircraft_gear = gear_current
		AeroDataBus.aircraft_throttle = input_throttle
		AeroDataBus.aircraft_ap = autopilot_on
	
	# Aero forces
	$AeroSurfaceWingL.vel_body = airspeed_true_vector
	forceWingl = \
		calc_force_rotated_from_surface( \
			$AeroSurfaceWingL.force_total_surface_vector, \
			$AeroSurfaceWingL.rotation \
			)
	$AeroSurfaceWingR.vel_body = airspeed_true_vector
	forceWingr = \
		calc_force_rotated_from_surface( \
			$AeroSurfaceWingR.force_total_surface_vector, \
			$AeroSurfaceWingR.rotation \
			)
	
	$AeroSurfaceCtrlL1.vel_body = airspeed_true_vector
	force_control_L1 = \
		calc_force_rotated_from_surface( \
			$AeroSurfaceCtrlL1.force_total_surface_vector, \
			$AeroSurfaceCtrlL1.rotation \
			)
	$AeroSurfaceCtrlL2.vel_body = airspeed_true_vector
	force_control_L2 = \
		calc_force_rotated_from_surface( \
			$AeroSurfaceCtrlL2.force_total_surface_vector, \
			$AeroSurfaceCtrlL2.rotation \
			)
	$AeroSurfaceCtrlR1.vel_body = airspeed_true_vector
	force_control_R1 = \
		calc_force_rotated_from_surface( \
			$AeroSurfaceCtrlR1.force_total_surface_vector, \
			$AeroSurfaceCtrlR1.rotation \
			)
	$AeroSurfaceCtrlR2.vel_body = airspeed_true_vector
	force_control_R2 = \
		calc_force_rotated_from_surface( \
			$AeroSurfaceCtrlR2.force_total_surface_vector, \
			$AeroSurfaceCtrlR2.rotation \
			)
			
	
	posWingl = $AeroSurfaceWingL.pos_force_rel
	posWingr = $AeroSurfaceWingR.pos_force_rel
	
	pos_control_L1 = $AeroSurfaceCtrlL1.pos_force_rel
	pos_control_L2 = $AeroSurfaceCtrlL2.pos_force_rel
	pos_control_R1 = $AeroSurfaceCtrlR1.pos_force_rel
	pos_control_R2 = $AeroSurfaceCtrlR2.pos_force_rel
	
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
	
	$AeroSurfaceCtrlL1.rotation.x = 0.2 * (+output_aileron - output_elevator - 1 * output_rudder_l)
	$AeroSurfaceCtrlL2.rotation.x = 0.2 * (+output_aileron - output_elevator + 1 * output_rudder_l)
	$AeroSurfaceCtrlR1.rotation.x = 0.2 * (-output_aileron - output_elevator - 1 * output_rudder_r)
	$AeroSurfaceCtrlR2.rotation.x = 0.2 * (-output_aileron - output_elevator + 1 * output_rudder_r)
	
	get_input(delta)
	
	# Thrust forces
	apply_force_local(Vector3(0, 0, -mass * 10 * input_throttle), Vector3(0, 0, 0))
	
	# Forces from surfaces 
	
	for child in get_children():
		if child is AeroSurface:
			apply_force_local(child.force_total_surface_vector, child.position)
	
	apply_force_local(forceWingl, posWingl)
	apply_force_local(forceWingr, posWingr)
	
	apply_force_local(force_control_L1, pos_control_L1)
	apply_force_local(force_control_L2, pos_control_L2)
	apply_force_local(force_control_R1, pos_control_R1)
	apply_force_local(force_control_R2, pos_control_R2)

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
