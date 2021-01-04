extends Node

signal select_piece(piece_pos)
signal move_piece(piece_pos)

var playing = false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func get_move(moves):
	pass


func select_piece(position):
	print('selecting piece ', position)
	emit_signal('select_piece', position)

func move_piece(position):
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_move_piece(pos, newpos, attpos, color):
	pass
