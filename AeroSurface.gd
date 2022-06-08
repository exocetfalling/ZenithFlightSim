extends Spatial

class_name AeroSurface

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var length_chord_root : float = 1.00
export var length_chord_tip : float = 1.00
export var length_span : float = 1.00
export var angle_sweep : float = 0.00

var area_element : float = 1.00

var vel_body : Vector3 = Vector3.ZERO
var vel_surface : Vector3 = Vector3.ZERO

var vel_delta = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	area_element = (length_chord_root + length_chord_tip) / 2 * length_span
	
	DebugOverlay.stats.add_property(self, "vel_surface", "round")
	DebugOverlay.stats.add_property(self, "vel_delta", "")
	pass # Replace with function body.

func _physics_process(delta):
	vel_surface = (self.transform.basis.xform_inv(vel_body))
	
	vel_delta = vel_surface - vel_body
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
