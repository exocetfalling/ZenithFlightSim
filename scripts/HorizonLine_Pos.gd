extends Node2D
var centre_position

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	centre_position = get_viewport_rect().size/2
	position.y = centre_position.y + $'../../../'.pfd_pitch * get_viewport_rect().size.y/100*1.5
	rotation_degrees = -$'../../../'.pfd_roll
	position.x = position.y * tan(deg2rad($'../../../'.pfd_roll)) - centre_position.x
