extends TileMap
var selected = null
var walking = false
var velocity = Vector2()
var target = Vector2()
export var speed = 0.2
var tolerance = cell_size.x/4
var valid_moves
var valid_attacks
var move_repeat
var shape = Vector2(8,8)
var game_end = false
var piece_positions = {}

var Piece = load('res://Piece.tscn')

var current_player = 'white'

func place_piece(piece, x,y):
	var position = map_to_world(Vector2(x,y))
	piece.position = position + Vector2(1,1) * cell_size/2	
	piece.grid_position = Vector2(x,y)
	print(piece.grid_position)
	piece_positions[[x,y]] = piece

func create_piece(piecename, x, y, color):
	var piece = Piece.instance()
	place_piece(piece, x, y)
	piece.create_piece(piecename, color)
	add_child(piece)


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
	
	
	print(get_children())



func _ready():
	fill_board('black')
	fill_board('white')
	walking = false


func _process(delta):
	var direction = Vector2()
	
	#TODO: implement piece selection
	#TODO: implement piece move sampling

	if walking and selected != null:
		if target == selected.position:
			selected.grid_position = world_to_map(target)
			walking = false
			selected.moved = true
			selected = null
		elif target.length() > 0:
			velocity = (target - selected.position).normalized() * speed
			selected.position += velocity
			print(velocity)
			if (target - selected.position).length() < tolerance:
				selected.position = target
				velocity = Vector2()
			

func process_attacks(initial_position, attacks, repeat):
	var end_positions = []
	var intermediate_position = Vector2()
	var num_steps = shape.x if repeat else 1
	
	for attack in attacks:
		var colision = false
		intermediate_position = initial_position
		for steps in range(1, num_steps+1):
			intermediate_position = intermediate_position + attack
			if intermediate_position.x >= shape.x or intermediate_position.x < 0:
				break
			if intermediate_position.y >= shape.y or intermediate_position.y < 0:
				break
			if check_colision(intermediate_position):
				for child in get_children():
					if child.grid_position == intermediate_position:
						if child.player != selected.player:
							print('attack',intermediate_position)
							end_positions += [intermediate_position]
						print('collision', intermediate_position)
						colision = true
						break
			if colision == true:
				break
	return end_positions

func proccess_moves(initial_position, moves, repeat):
	var end_positions = []
	var intermediate_position = Vector2()
	var num_steps = shape.x if repeat else 1
	for move in moves:
		intermediate_position = initial_position
		for steps in range(1, num_steps+1):
			intermediate_position = intermediate_position + move
			if intermediate_position.x >= shape.x or intermediate_position.x < 0:
				break
			if intermediate_position.y >= shape.y or intermediate_position.y < 0:
				break
			if check_colision(intermediate_position):
				break
			end_positions += [intermediate_position]
				
			

	return end_positions

func _input(event):
	if game_end:
		return
	if event is InputEventMouseButton and event.pressed:
		var mousepos
		if not walking:
			mousepos = get_local_mouse_position()
			print(mousepos)
			if selected != null:
				if disable_selection(mousepos):
					if world_to_map(mousepos) in valid_moves:
						walking = true
						target = (cell_size* Vector2(1,1)/2) + map_to_world(world_to_map(mousepos))
						for move in valid_moves:
							var cellv = get_cellv(move)
							set_cellv(move, cellv-2)
						for move in valid_attacks:
							var cellv = get_cellv(move)
							set_cellv(move, cellv-4)
						current_player = 'black' if current_player == 'white' else 'white'
						return
					if world_to_map(mousepos) in valid_attacks:
						walking = true
						target = (cell_size* Vector2(1,1)/2) + map_to_world(world_to_map(mousepos))
						for child in get_children():
							if child.grid_position == world_to_map(mousepos):
								if child.type == 'king':
									game_end =true
									print('GAME OVER')
								remove_child(child)
						for move in valid_moves:
							var cellv = get_cellv(move)
							set_cellv(move, cellv-2)
						for move in valid_attacks:
							var cellv = get_cellv(move)
							set_cellv(move, cellv-4)
						current_player = 'black' if current_player == 'white' else 'white'
						
			else:
				if select(mousepos):
					if selected.player != current_player:
						selected = null
						return
					# var list_of_valid_moves = []
					valid_moves = selected.get_moves() + selected.get_special_moves()
					valid_attacks = selected.get_attacks()
					move_repeat = selected.move_repeat()
					valid_moves = proccess_moves(selected.grid_position, valid_moves, move_repeat)
					valid_attacks = process_attacks(selected.grid_position, valid_attacks, move_repeat)
#					print(list_of_valid_moves)
					for move in valid_moves:
						var cellv = get_cellv(move)
						set_cellv(move, cellv+2)
					for move in valid_attacks:
						var cellv = get_cellv(move)
						set_cellv(move, cellv+4)
					print(valid_moves)
					print(move_repeat)
					print(valid_attacks)
					
				

func check_colision(gridpos):
	for child in get_children():
		if child.grid_position == gridpos:
			return true
	return false

func select(mousepos):
	if selected == null:
		for child in get_children():
			if child.grid_position == world_to_map(mousepos):
				selected = child
				return true
	return false

func disable_selection(mousepos):
	if selected.grid_position == world_to_map(mousepos):
		selected = null
		return false
	return true
		
