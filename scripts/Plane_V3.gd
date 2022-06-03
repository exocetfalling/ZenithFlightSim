extends AeroRootNode


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	DebugOverlay.stats.add_property(self, "input_roll", "round")
	pass # Replace with function body.

func _unhandled_input(event):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Called every frame. 'delta' is the elapsed time since the previous physics frame.
func _physics_process(delta):
	$AeroJoint_Aileron_L_1.input_command_value = -input_roll
	$AeroJoint_Aileron_L_2.input_command_value = -input_roll
	$AeroJoint_Aileron_R_1.input_command_value =  input_roll
	$AeroJoint_Aileron_R_2.input_command_value =  input_roll
	pass
