extends AeroElement


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	DebugOverlay.stats.add_property(self, "angle_alpha_deg", "round")
	DebugOverlay.stats.add_property(self, "angle_beta_deg", "round")
	DebugOverlay.stats.add_property(self, "linear_velocity_local", "round")
	DebugOverlay.stats.add_property(self, "linear_velocity_total", "round")
	DebugOverlay.stats.add_property(self, "force_lift_element_vector", "round")
	DebugOverlay.stats.add_property(self, "force_drag_element_vector", "round")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
