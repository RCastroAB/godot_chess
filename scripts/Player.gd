extends "res://scripts/Agent.gd"

var piece_selected = false
var piecemap
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	piecemap = get_parent().get_node('PieceMap')


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	if event is InputEventMouseButton and not event.pressed:
		var mousepos = event.position
		mousepos = piecemap.world_to_map(mousepos)
		if piece_selected:
			move_piece(mousepos)
		else:
			select_piece(mousepos)
