extends "res://scripts/Agent.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var ai = preload("res://lib/bin/libai.gdns").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	ai.init_board()

func _on_move_piece(pos, new_pos, att_pos, color):
	print('called')
	ai.move_oponent(pos.x, pos.y, new_pos.x, new_pos.y,
		att_pos.x, att_pos.y)
	ai.print_board()
	

func _on_moves_processed(moves):
	ai.set_moves(moves)
	var move = ai.get_move()
	var pos = Vector2(move[0], move[1])
	select_piece(pos)
	var movepos = Vector2(move[2], move[3])
	move_piece(movepos)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
