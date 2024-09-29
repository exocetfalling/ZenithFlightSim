@tool
extends EditorPlugin

# Replace this value with a PascalCase autoload name, as per the GDScript style guide.
const AUTOLOAD_NAME_01 = "AeroHelper"
const AUTOLOAD_NAME_02 = "AeroDataBus"


func _enter_tree():
	# The autoload can be a scene or script file.
	add_autoload_singleton(AUTOLOAD_NAME_01, "res://addons/aero_tools/scripts/aero_helper.gd")
	add_autoload_singleton(AUTOLOAD_NAME_02, "res://addons/aero_tools/scripts/aero_data_bus.gd")


func _exit_tree():
	remove_autoload_singleton(AUTOLOAD_NAME_01)
	remove_autoload_singleton(AUTOLOAD_NAME_02)
