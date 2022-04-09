extends HBoxContainer


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
#var UFC_FBW_button = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func get_input_keyboard(delta):
#	if Input.is_action_just_pressed("autopilot_toggle"):
#		$Modes_Main/FBW.pressed = true
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	get_input_keyboard(delta)
