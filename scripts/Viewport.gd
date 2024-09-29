extends SubViewport


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func _input(event):
   # Mouse in viewport coordinates.
   if event is InputEventMouseButton:
	   print("Mouse Click/Unclick at: ", event.position)
   elif event is InputEventMouseMotion:
	   print("Mouse Motion at: ", event.position)

   # Print the size of the viewport.
#   print("Viewport Resolution is: ", get_viewport_rect().size)
