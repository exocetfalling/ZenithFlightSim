extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var flight_params_set : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	flight_params_set = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ($ButtonBack.button_pressed == true):
		get_tree().change_scene_to_file("res://uires/menu_main/menu_main.tscn")
	
	if ($ButtonConfirm.button_pressed == true):
		get_tree().change_scene_to_file("res://scenes/test_scene.tscn")
