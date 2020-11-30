extends Node2D
export var attacks = []
export var moves = []
export var special_moves = []
export var repeat = false
var type
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var grid_position = Vector2()
var player;

const SPRITES = 'res://sprites/'

var moved = false
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


func knight_moves():
	var seed_vec = Vector2(2, 1)
	var rotation_matrix = Transform2D(
		Vector2(0,1), Vector2(-1,0), Vector2(0,0))
	var directions = [seed_vec]
	var vec = seed_vec
	var revec
	var rerevec
	for i in range(4):
		vec = rotation_matrix.basis_xform(vec)
		revec = vec * Vector2(-1,1)
		rerevec = vec * Vector2(1,-1)
		directions += [vec, revec, rerevec]
	return directions

func pawn_moves():
	if player == 'black':
		return [Vector2(0, 1)]
	else:
		return [Vector2(0, -1)]


func pawn_special_moves():
	if player == 'black':
		return [Vector2(0, 2)]
	else:
		return [Vector2(0, -2)]

func pawn_attacks():
	if player == 'black':
		return [Vector2(1,1), Vector2(-1,1)]
	else:
		return [Vector2(1, -1), Vector2(-1, -1)]

func bishop_moves():
	
	var dir = Vector2(1,1)
	var rot = Transform2D(
		Vector2(0,1), Vector2(-1,0), Vector2(0,0))
	var directions = [dir]	
	for i in range(3):
		dir = rot.basis_xform(dir)
		directions += [dir]
	return directions

func rook_moves():
	
	var dir = Vector2(0,1)
	var rot = Transform2D(
		Vector2(0,1), Vector2(-1,0), Vector2(0,0))
	var directions = [dir]	
	for i in range(3):
		dir = rot.basis_xform(dir)
		directions += [dir]
	return directions



func create_piece(piecename, color):
	var movesrepeat
	player = color
	var path = ''
	if color == 'white':
		path = 'white_'
	type = piecename
	match piecename:
		'king':
			moves = king_moves()
			attacks = king_moves()
			repeat = false
			$Sprite.texture = load(SPRITES +path+'WIP_king.png')
		'queen':
			moves = king_moves()
			attacks = king_moves()
			repeat = true
			$Sprite.texture = load(SPRITES +path+'WIP_queen.png')
		'knight':
			moves = knight_moves()
			attacks = knight_moves()
			repeat = false
			$Sprite.texture = load(SPRITES +path+'fuglier_horse.png')
		'pawn':
			moves = pawn_moves()
			attacks = pawn_attacks()
			special_moves = pawn_special_moves()
			repeat = false
			$Sprite.texture = load(SPRITES +path+'WIP_pawn.png')
		'bishop':
			moves = bishop_moves()
			attacks = bishop_moves()
			repeat = true
			$Sprite.texture = load(SPRITES +path+'WIP_pawn.png')
		'rook':
			moves = rook_moves()
			attacks = rook_moves()
			repeat = true
			$Sprite.texture = load(SPRITES + path + 'WIP_rook.png')
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func get_moves(randseed=0):
	#placeholder
	
#	for dir in directions:
#		moves += [grid_position + dir]
	return moves
	
func get_special_moves():
	if not moved:
		return special_moves
	else:
		return []

func get_attacks():
	return attacks

func move_repeat():
	return repeat
