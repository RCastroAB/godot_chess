extends "res://scripts/Agent.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var ai = preload("res://lib/bin/libai.gdns").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	ai.init_board()
	ai.print_board()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
