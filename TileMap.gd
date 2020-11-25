extends TileMap
var selected = null
var walking = false
var velocity = Vector2()
var target = Vector2()
export var speed = 0.2
var tolerance = cell_size.x/4
var valid_moves
var move_repeat
var shape = Vector2(8,8)

var Piece = load('res://Piece.tscn')

func place_piece(piece, x,y):
	var position = map_to_world(Vector2(x,y))
	piece.position = position + Vector2(1,1) * cell_size/2	
	piece.grid_position = Vector2(x,y)

func _ready():
	print(Piece)
	
	var piece = Piece.instance()
	place_piece(piece, 3, 0)
	piece.create_piece('king')
	add_child(piece)
	print(piece.position)
	piece = Piece.instance()
	place_piece(piece, 4, 0)
	piece.create_piece('queen')
	add_child(piece)
	print(piece.position)
	
	
	print(get_children())
	walking = false


func _process(delta):
	var direction = Vector2()
	
	#TODO: implement piece selection
	#TODO: implement piece move sampling

	if walking and selected != null:
		if target == selected.position:
			selected.grid_position = world_to_map(target)
			walking = false
			selected = null
		elif target.length() > 0:
			velocity = (target - selected.position).normalized() * speed
			selected.position += velocity
			print(velocity)
			if (target - selected.position).length() < tolerance:
				selected.position = target
				velocity = Vector2()
			

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
			end_positions += [intermediate_position]
			

	return end_positions

func _input(event):
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
						print(target)
			else:
				if select(mousepos):
					# var list_of_valid_moves = []
					valid_moves = selected.get_moves()
					move_repeat = selected.move_repeat()
					valid_moves = proccess_moves(selected.grid_position, valid_moves, move_repeat)
#					print(list_of_valid_moves)
					print(valid_moves)
					print(move_repeat)
					
				


func select(mousepos):
	if selected == null:
		for child in get_children():
			if child.grid_position == world_to_map(mousepos):
				selected = child
				return true
	return false

func disable_selection(mousepos):
	if selected.position == world_to_map(mousepos):
		selected = null
		return false
	return true
		
