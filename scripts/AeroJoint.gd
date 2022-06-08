extends Generic6DOFJoint

class_name AeroJoint

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Is it a servo? 
export var is_servo : bool = false

# Location of hinge relative to centre of gravity (root)
var hinge_pos : Vector3 = Vector3.ZERO

# Hinge limits 
export (float, -90.0,  0.0) var angle_lower_limit : float = -15.0
export (float,   0.0, 90.0) var angle_upper_limit : float =  15.0


# Inputs to the control surface will be scaled by these values 
# Useful for mixed controls (elevons, spoilerons, etc.)
export var scalar_control_pitch : float = 1.00
export var scalar_control_roll : float = 1.00
export var scalar_control_yaw : float = 1.00

# Commanded values from the FBW/player/AI 
var input_command_value : float = 0.00

#var command_pitch : float = 0.00
#var command_roll : float = 0.00
#var command_yaw : float = 0.00

var output_node : Node

# Deflection rate
var output_deflection_rate = 0.5

# Target angle
var output_angle : float =  0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	if (is_servo == true):
#		DebugOverlay.stats.add_property(self, "input_command_value", "round")
#		DebugOverlay.stats.add_property(self, "output_deflection_rate", "round")
#		DebugOverlay.stats.add_property(self, "output_angle", "round")
		hinge_pos = self.translation
		output_node = get_node(self.get("nodes/node_b"))
		self.set("angular_limit_x/lower_angle", angle_lower_limit)
		self.set("angular_limit_x/upper_angle", angle_upper_limit)
		self.set("angular_motor_x/enabled", true)
		self.set("angular_motor_x/force_limit", 50000)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Called every frame. 'delta' is the elapsed time since the previous physics frame.
func _physics_process(delta):
	if (is_servo == true):
		output_angle = -input_command_value * (angle_upper_limit - angle_lower_limit) / 2
		
#		if (output_node.rotation_degrees.x < output_angle):
#			self.set("angular_motor_x/target_velocity", -output_deflection_rate)
#		if (output_node.rotation_degrees.x > output_angle):
#			self.set("angular_motor_x/target_velocity",  output_deflection_rate)
		
		self.set(\
			"angular_motor_x/target_velocity", \
			(output_deflection_rate * (output_node.rotation_degrees.x - output_angle)) \
			)
	pass
