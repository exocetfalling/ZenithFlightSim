extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Speed_Data/Variable.text = str(stepify($'../../'.pfd_spd, 1))
	$Alt_Data/Variable.text = str(stepify($'../../'.pfd_alt, 1))
	$Heading_Data/Variable.text = str(stepify($'../../'.pfd_hdg, 1))
	$Flaps_Data/Variable.text = str(stepify($'../../'.flaps_input, 0.01))
	$Gear_Data/Variable.text = str(stepify($'../../'.gear_pos, 0.01))
