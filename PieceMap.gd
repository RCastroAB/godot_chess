extends TileMap
var Piece = load('res://Piece.tscn')

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
		deselect()
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

func _input(event):
	if walking or winner:
		return
	if player_num == 1 and current_player == 'black':
		return
	
	if event is InputEventMouseButton and event.pressed:
		var mousepos
		mousepos = get_local_mouse_position()
		mousepos = world_to_map(mousepos)
		if selected:
			try_move(mousepos)
		else:
			try_select(mousepos)

func try_select(mousepos):
	if not mousepos in position_pieces.keys():
		return
	var piece = position_pieces[mousepos]
	if piece.player != current_player:
		return
	selected = piece
	valid_moves = calculate_moves(position_pieces, selected)
	valid_attacks = calculate_attacks(position_pieces, selected)
	draw_overlay()

func check_valid_move(endpos):
	if endpos.x < 0 or endpos.x > 7:
		return false
	if endpos.y < 0 or endpos.y > 7:
		return false
	return true

func calculate_moves(gamestate, selected):
	var moves = selected.get_moves()
	var possible_moves =[]
	if not selected.moved:
		moves += selected.get_special_moves()
	for move in moves:
		var endpos = selected.grid_position
		while check_valid_move(endpos+ move):
			endpos += move
			if endpos in gamestate.keys():
				break
			possible_moves += [endpos]
			if not selected.repeat:
				break
	return possible_moves

func calculate_attacks(gamestate, selected):
	var possible_attacks = []
	var attacks = selected.get_attacks()
	for attack in attacks:
		var endpos = selected.grid_position
		while true:
			endpos = endpos + attack
			if not check_valid_move(endpos):
				break
			if endpos in gamestate.keys():
				if gamestate[endpos].player != selected.player:
					possible_attacks += [endpos]
				break
			if not selected.repeat:
				break
	return possible_attacks

func try_move(mousepos):
	if mousepos in valid_moves:
		move(mousepos)
	elif mousepos in valid_attacks:
		attack(mousepos)
	elif mousepos == selected.grid_position:
		deselect()

func deselect():
	clear_overlay()
	selected = null
	valid_attacks = []
	valid_moves = []
	win()

func move(endpos):
	target = map_to_world(endpos) + cell_size/2
	velocity = (target - selected.position) * speed
	walking = true
	selected.moved = true
	position_pieces[endpos] = selected
	position_pieces.erase(selected.grid_position)
	

func attack(endpos):
	if position_pieces[endpos].type == 'king':
		winner = current_player
	remove_child(position_pieces[endpos])
	move(endpos)

func clear_overlay():
	for move in valid_moves:
		set_cellv(move, 4)
	for attack in valid_attacks:
		set_cellv(attack, 4)



func draw_overlay():
	for move in valid_moves:
		set_cellv(move, 3)
	for attack in valid_attacks:
		set_cellv(attack, 2)

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
		all_moves[piece] = calculate_moves(position_pieces, piece)
		all_attacks[piece] = calculate_attacks(position_pieces, piece)
	
	return [all_moves, all_attacks]


func ai_move(piece, move):
	try_select(piece.grid_position)
	try_move(move)
	
func win():
	if winner == null:
		return
	for pos in position_pieces.keys():
		var piece = position_pieces[pos]
		position_pieces.erase(pos)
		create_piece(piece.type, pos.x, pos.y, winner)
