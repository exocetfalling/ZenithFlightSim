extends AeroRootNode


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Called every frame. 'delta' is the elapsed time since the previous physics frame.
func _physics_process(delta):
	$AeroJoint_Aileron_L_1.set("angular_limit_x/lower_angle", (input_roll * 90))
	pass
