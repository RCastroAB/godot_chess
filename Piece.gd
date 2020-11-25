extends Node2D
export var moves = []
export var repeat = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var grid_position = Vector2()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func king_moves():
	var directions = [
		Vector2(-1,0),
		Vector2(1,0),
		Vector2(-1,-1),
		Vector2(1,-1),
		Vector2(-1,1),
		Vector2(1,1),
		Vector2(0,0),
		Vector2(0,-1),
		Vector2(0,1),
	]
	return directions



func create_piece(piecename):
	var movesrepeat
	match piecename:
		'king':
			moves = king_moves()
			repeat = false
		'queen':
			moves = king_moves()
			repeat = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func get_moves(randseed=0):
	#placeholder
	
#	for dir in directions:
#		moves += [grid_position + dir]
	return moves


func move_repeat():
	return repeat
