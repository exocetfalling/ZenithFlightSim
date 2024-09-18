@tool
# Copyright © 2021 Kasper Arnklit Frandsen - MIT License
# See `LICENSE.md` included in the source distribution for details.
extends HBoxContainer

var menu

func _enter_tree() -> void:
	menu = $WaterSystemMenu
