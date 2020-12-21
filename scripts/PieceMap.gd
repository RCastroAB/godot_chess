extends TileMap
# Role: rendering pieces and movements
# and getting player input

var Piece = load('res://scenes/Piece.tscn')

const player_num =1
signal ai_turn(current_player)
const test_num = 0

var winner

export var speed = 2.0
export var tolerance = 5.0

var position_pieces = {}
var selected

var walking
var target
var velocity

var valid_moves = []
var valid_attacks = []

var current_player = 'white'

var piece_moves = {}

func place_piece(piece, pos):
	var position = map_to_world(pos)
	piece.position = position + Vector2(1,1) * cell_size/2	
	piece.grid_position = pos
	position_pieces[pos] = piece

func create_piece(piecename, x, y, color):
	var piece = Piece.instance()
	place_piece(piece, Vector2(x,y))
	piece.create_piece(piecename, color)
	add_child(piece)
#	print(piece.type, piece.get_moves())


func fill_board(color):
	var yoffset
	var piecename
	
	if color == 'black':
		yoffset = 0
	else:
		yoffset = 7
	var piecenames = [
		'rook', 
		'knight',
		'bishop',
		'king',
		'queen',
		'bishop',
		'knight',
		'rook'
	]
	
	for i in range(piecenames.size()):
		piecename = piecenames[i]
		create_piece(piecename, i, yoffset, color)
	
	
	for i in range(8):
		create_piece('pawn', i, abs(1- yoffset), color)
	

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	if not test_num:
		fill_board('white')
		fill_board('black')
	else:
		match (test_num):
			1:
				create_piece('king', 0, 1, 'black')
				create_piece('queen', 1, 7, 'white')
				create_piece('king', 2, 2, 'white')
			2:
				create_piece('king', 0, 1, 'black')
				create_piece('queen', 1, 1, 'white')
				create_piece('king', 2, 2, 'white')
	
	if player_num == 0:
		yield(get_tree(), "idle_frame")
		emit_signal("ai_turn", current_player)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not walking:
		return
	if (selected.position - target).length() < tolerance:
		selected.position = target
		walking = false
		selected.grid_position = world_to_map(target)
		$AudioStreamPlayer2D.position = target
		$AudioStreamPlayer2D.play()
		$AudioStreamPlayer2D.pitch_scale = rand_range(0.99, 1.1)
#		print($AudioStreamPlayer2D.pitch_scale)
		current_player = 'black' if current_player == 'white' else 'white'
		if player_num == 1 and current_player == 'black' and not winner:
			yield(get_tree(), "idle_frame")
#			print("aiturn")
			emit_signal("ai_turn", current_player)
		elif player_num == 0 and not winner:
			yield(get_tree(), "idle_frame")
			emit_signal("ai_turn", current_player)
		return

	selected.position += velocity

func _on_piece_selected(pos):
	if selected:
		return
	if pos in piece_moves.keys():
		valid_moves = piece_moves[pos]
		draw_overlay()


func _on_moves_processed(moves):
	piece_moves = {}
	for move in moves:
		var start_pos = Vector2(move[0], move[1])
		var end_pos = Vector2(move[2], move[3])
		var att_pos = Vector2(move[4], move[5])
		if start_pos in piece_moves.keys():
			piece_moves[start_pos].append([end_pos, att_pos])
		else:
			piece_moves[start_pos] = [[end_pos, att_pos]]

func draw_overlay():
	for move in valid_moves:
		set_cellv(move[0], 3)
		set_cellv(move[1], 2)

func get_gamestate():
	return position_pieces

func get_gamestate_ifmove(gamestate, piece, move):
	var new_gamestate = gamestate.duplicate()
	for pos in gamestate.keys():
		if gamestate[pos] == piece:
			new_gamestate.erase(pos)
			break
	new_gamestate[move] = piece
	return new_gamestate

func get_all_moves(gamestate, color):
	var lose = true
	for piece in gamestate.values():
		if piece.type=='king' and piece.player==color:
			lose = false
	if lose:
		return [{}, {}]
	var all_moves = {}
	var all_attacks = {}
	for piece in gamestate.values():
		if piece.player != color:
			continue
	
	return [all_moves, all_attacks]


func win():
	if winner == null:
		return
	for pos in position_pieces.keys():
		var piece = position_pieces[pos]
		position_pieces.erase(pos)
		create_piece(piece.type, pos.x, pos.y, winner)


