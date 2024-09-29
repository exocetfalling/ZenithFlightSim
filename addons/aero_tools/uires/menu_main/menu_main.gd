extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if($Options/ButtonFreeFlight.button_pressed == true):
		get_tree().change_scene_to_file("res://uires/menu_free_flight/menu_free_flight.tscn")
	pass
