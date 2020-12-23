extends TileMap
# Role: rendering pieces and movements
# and getting player input

var Piece = load('res://scenes/Piece.tscn')

signal move_piece(old_pos, new_pos, color)

const player_num =2
const test_num = 0

var winner

var board 
export var speed = 2.0
export var tolerance = 5.0

var position_pieces = {}
var pieces = {}
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
	piece.target = piece.position

func create_piece(piecename, x, y, color, id):
	var piece = Piece.instance()
	place_piece(piece, Vector2(x,y))
	piece.create_piece(piecename, color)
	piece.id = id
	pieces[id] = piece
	add_child(piece)


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not walking:
		return
	if (selected.position - target).length() < tolerance:
		selected.position = target
		walking = false
		selected.grid_position = world_to_map(target)
#		$AudioStreamPlayer2D.position = target
#		$AudioStreamPlayer2D.play()
#		$AudioStreamPlayer2D.pitch_scale = rand_range(0.99, 1.1)
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
	print('moves processed')
	print(piece_moves)

func check_valid_move(pos):
	for move in valid_moves:
		if pos == move[0]:
			return true
	return false

func _on_piece_selected(pos):
	if selected:
		if selected == pos:
			selected = null
			clear_overlay(pos)
		elif check_valid_move(pos):
			var color = board[selected][2]
			emit_signal('move_piece', selected, pos, color)
			clear_overlay(selected)
			selected = null
	elif pos in piece_moves.keys():
		selected = pos
		valid_moves = piece_moves[pos]
		draw_overlay(pos)

func set_moving_mode(selected, pos):
	print('moving mode')
	var piece = position_pieces[selected]
	position_pieces.erase(selected)
	position_pieces[pos] = piece
	
	piece.target = map_to_world(pos) + Vector2(1,1) * cell_size/2

func draw_overlay(pos):
	print(board.keys())
	for move in valid_moves:
		set_cellv(move[0], 3)
		if  move[1] in board.keys():
			set_cellv(move[1], 2)
	set_cellv(pos, 4)

func clear_overlay(pos):
	for move in valid_moves:
		set_cellv(move[0], -1)
		set_cellv(move[1], -1)
	set_cellv(pos, -1)


func set_board(board):
	var piecenames = {
		1: 'pawn',
		2: 'rook',
		3: 'knight',
		4: 'bishop',
		5: 'queen',
		6: 'king'
	}
	
	self.board = board
	for pos in board.keys():
		var piece_data = board[pos]
		var piecename = piecenames[int(piece_data[1])]
		var color = 'white' if piece_data[2] == 1 else 'black'
		create_piece(piecename, pos.x, pos.y, color, piece_data[0])


func _on_new_board(board):
	for child in get_children():
		var exists = false
		for piece_pos in board.keys():
			if child.id == board[piece_pos][0]:
				exists = true
				child.target = map_to_world(piece_pos) + cell_size/2
		if not exists:
			pieces.erase(child.id)
			remove_child(child)
	self.board = board
