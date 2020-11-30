extends TileMap
var Piece = load('res://Piece.tscn')

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
	print(piece.type, piece.get_moves())


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
	fill_board('white')
	fill_board('black')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not walking:
		return
	if (selected.position - target).length() < tolerance:
		selected.position = target
		walking = false
		selected.grid_position = world_to_map(target)
		deselect()
		return

	selected.position += velocity

func _input(event):
	if walking:
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
	calculate_moves(selected)
	calculate_attacks(selected)
	draw_overlay()

func check_valid_move(endpos):
	if endpos.x < 0 or endpos.x > 7:
		return false
	if endpos.y < 0 or endpos.y > 7:
		return false
	return true

func calculate_moves(selected):
	var moves = selected.get_moves()
	if not selected.moved:
		moves += selected.get_special_moves()
	for move in moves:
		var endpos = selected.grid_position
		while check_valid_move(endpos+ move):
			endpos += move
			if endpos in position_pieces.keys():
				break
			valid_moves += [endpos]
			if not selected.repeat:
				break

func calculate_attacks(selected):
	var attacks = selected.get_attacks()
	for attack in attacks:
		var endpos = selected.grid_position
		while true:
			endpos = endpos + attack
			if not check_valid_move(endpos):
				break
			if endpos in position_pieces.keys():
				if position_pieces[endpos].player != selected.player:
					valid_attacks += [endpos]
				break
			if not selected.repeat:
				break

func try_move(mousepos):
	if mousepos in valid_moves:
		move(mousepos)
	if mousepos in valid_attacks:
		attack(mousepos)
	if mousepos == selected.grid_position:
		deselect()

func deselect():
	clear_overlay()
	selected = null
	valid_attacks = []
	valid_moves = []

func move(endpos):
	target = map_to_world(endpos) + cell_size/2
	velocity = (target - selected.position) * speed
	walking = true
	selected.moved = true
	position_pieces[endpos] = selected
	position_pieces.erase(selected.grid_position)
	
	current_player = 'black' if current_player == 'white' else 'white'

func attack(endpos):
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
