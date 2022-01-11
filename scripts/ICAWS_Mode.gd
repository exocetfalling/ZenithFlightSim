extends MenuButton
var popup
var item_pressed

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	popup = get_popup()
	popup.connect("id_pressed", self, "_on_item_pressed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_item_pressed(ID):
	print(popup.get_item_text(ID), " pressed")
	item_pressed = popup.get_item_text(ID)
