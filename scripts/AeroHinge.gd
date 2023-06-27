extends Generic6DOFJoint

class_name AeroJoint

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Location of hinge relative to centre of gravity (root)
var hinge_pos : Vector3 = Vector3.ZERO

# Inputs to the control surface will be scaled by these values 
# Useful for mixed controls (elevons, spoilerons, etc.)
export var scalar_control_pitch : float = 1.00
export var scalar_control_roll : float = 1.00
export var scalar_control_yaw : float = 1.00

# Commanded values from the FBW/player/AI 
var command_pitch : float = 0.00
var command_roll : float = 0.00
var command_yaw : float = 0.00

# Called when the node enters the scene tree for the first time.
func _ready():
	DebugOverlay.stats.add_property(self, "hinge_pos", "round")
	hinge_pos = self.translation
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Called every frame. 'delta' is the elapsed time since the previous physics frame.
func _physics_process(delta):
	
	pass
