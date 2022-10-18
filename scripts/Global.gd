extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Units of measure
# Metric = 0
# Aviation = 1
var setting_units : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.add_joy_mapping("030000001d2300000002000000000000,VKB-Sim Gladiator NXT R,platform:Windows,a:b12,b:b11,x:b13,y:b10,guide:b60,leftstick:b29,rightstick:b9,leftshoulder:b22,rightshoulder:b24,dpup:b5,dpdown:b7,dpleft:b8,dpright:b6,-leftx:b18,+leftx:b19,-lefty:b17,+lefty:b16,rightx:a0,righty:a1,lefttrigger:b23,righttrigger:b25,", true)
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
