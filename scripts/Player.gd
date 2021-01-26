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
	if not playing:
		return
	if event is InputEventMouseButton and not event.pressed:
		var mousepos = event.position
		mousepos = piecemap.world_to_map(mousepos -Vector2(8,8)-get_parent().get_parent().rect_position +get_parent().position)
		if piece_selected:
			move_piece(mousepos)
		else:
			print(mousepos)
			select_piece(mousepos)
