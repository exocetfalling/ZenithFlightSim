extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
#	visible = false
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if($Options/ButtonMainMenu.button_pressed == true):
		get_tree().change_scene_to_file("res://uires/menu_main/menu_main.tscn")
