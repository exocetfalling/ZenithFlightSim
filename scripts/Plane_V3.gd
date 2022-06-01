extends AeroRootNode


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	DebugOverlay.stats.add_property(self, "input_roll", "round")
	pass # Replace with function body.

func get_input(delta):
	input_pitch = Input.get_axis("pitch_up", "pitch_down")
	input_roll = Input.get_axis("roll_left", "roll_right")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Called every frame. 'delta' is the elapsed time since the previous physics frame.
func _physics_process(delta):
	$AeroJoint_Aileron_L_1.set("angular_limit_x/lower_angle", (input_roll * 20))
	$AeroJoint_Aileron_L_1.set("angular_limit_x/upper_angle", (input_roll * 20))
	$AeroJoint_Aileron_L_2.set("angular_limit_x/lower_angle", (input_roll * 20))
	$AeroJoint_Aileron_L_2.set("angular_limit_x/upper_angle", (input_roll * 20))
	pass
