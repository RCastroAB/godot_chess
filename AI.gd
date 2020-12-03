extends Node

var board
signal movement_choice(piece, position)
const MAX_DEPTH = 3

export var piece_vals = {
	'king': 100,
	'queen': 10,
	'knight': 4,
	'bishop': 3,
	'rook': 5,
	'pawn': 1
}

var color
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func set_color(pcolor):
	color = pcolor

# Called when the node enters the scene tree for the first time.
func _ready():
	board = get_parent().get_node('PieceMap')


func merge(d1, d2):
	for key in d1.keys():
		if key in d2.keys():
			d1[key] += d2[key]
	
	for key in d2.keys():
		if not key in d1.keys():
			d1[key] = d2[key]
	return d1
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func evaluate_gamestate(gamestate, color):
	var state_value = 0
	var win = true
	var lose = true
	for piece in gamestate.values():
		var piece_value = 0
		piece_value += piece_vals[piece.type]
		if piece.type =='king':
			if piece.player == color:
				lose = false
			else:
				win = false
		if piece.player == color:
			state_value += piece_value
		else:
			state_value -= piece_value
	if win:
		return INF
	elif lose:
		return -INF
	else:
		return state_value
		

func min_gamestate(gamestate, color, depth):
	if depth == MAX_DEPTH:
		return evaluate_gamestate(gamestate, color)
	var moves = board.get_all_moves(gamestate, color)
	moves = merge(moves[0], moves[1])
	var candidate
	var candidates = []
	var value
	var next_gamestate
	var next_color = 'black' if color == 'white' else 'white'
	for piece in moves.keys():
		for move in moves[piece]:
			next_gamestate = board.get_gamestate_ifmove(gamestate, piece, move)
			value = max_gamestate(next_gamestate, next_color, depth+1)
			candidates += [[piece, move, value]]
	candidates.sort_custom(MoveSorter, 'sort_descending')
	var min_value = candidates[0][2]
	var i = 0
	while i < candidates.size() and min_value == candidates[i][2]:
		i += 1
	candidates = candidates.slice(0, i)
	candidates.shuffle()
	return candidates[0]

func max_gamestate(gamestate, color, depth):
	if depth == MAX_DEPTH:
		return evaluate_gamestate(gamestate, color)
	var moves = board.get_all_moves(gamestate, color)
	moves = merge(moves[0], moves[1])
	var candidates = []
	var value
	var next_gamestate
	var candidate
	var next_color = 'black' if color == 'white' else 'white'
	for piece in moves.keys():
		for move in moves[piece]:
			next_gamestate = board.get_gamestate_ifmove(gamestate, piece, move)
			value = min_gamestate(next_gamestate, next_color, depth+1)
			candidates += [[piece, move, value]]
	candidates.sort_custom(MoveSorter, 'sort_descending')
	var max_value = candidates[0][2]
	var i = 0
	while i < candidates.size() and max_value == candidates[i][2]:
		i += 1
	candidates = candidates.slice(0, i)
	candidates.shuffle()
	return candidates[0]

func minmax_gamestate(gamestate, color):
	var move =  max_gamestate(gamestate, color, 0)
	return move

func calculate_gamestate_value(gamestate, depth, color):
	if depth < MAX_DEPTH:
		color = 'black' if color == 'white' else 'white'
		var value = get_best_move(gamestate, color, depth+1)[0][2]
	var state_value = 0
	var no_king = true
	var no_enemy_king = true
	for piece in gamestate.values():
		if piece.player != color:
			if piece.type == 'king':
				no_enemy_king = false
			continue
		var piece_value = 0
		piece_value += piece_vals[piece.type]
		if piece.type != 'king':
#			var moves = board.calculate_moves(gamestate, piece)
#			piece_value += sqrt(moves.size())
			var attacks = board.calculate_attacks(gamestate, piece)
			piece_value += sqrt(attacks.size() * 2)
		else:
			no_king = false
		state_value += piece_value
	if no_king:
		state_value = - INF
	if no_enemy_king:
		state_value = INF
	
	return state_value


func get_best_move(gamestate, color, depth):
	var moves = board.get_all_moves(gamestate, color)
	var attacks = moves[1]
	moves = moves[0]
	var candidates = []
	
	var value
	for piece in moves.keys():
		for move in moves[piece]:
			gamestate = board.get_gamestate_ifmove(gamestate, piece, move)
			value = calculate_gamestate_value(gamestate, depth, color)
			candidates += [[piece, move, value]]
	
	for piece in attacks.keys():
		for attack in attacks[piece]:
			gamestate = board.get_gamestate_ifmove(gamestate, piece, attack)
			value = calculate_gamestate_value(gamestate, depth, color)
			value += 1
			candidates += [[piece, attack, value]]
	
	candidates.sort_custom(MoveSorter, 'sort_descending')
	var max_value = candidates[0][2]
	var i = 0
	while i < candidates.size() and max_value == candidates[i][2]:
		i += 1
	candidates.resize(i)
	candidates.shuffle()
	return candidates
	
	
func process_turn(current_player):
	if current_player != color:
		return
	var current_gamestate = board.get_gamestate()
	
	
	var candidate = minmax_gamestate(current_gamestate, color)
	print(candidate)
	print(candidate)
	emit_signal('movement_choice', candidate[0], candidate[1])


class MoveSorter:
	static func sort_descending(a,b):
		return a[2] > b[2]
	static func sort_ascending(a,b):
		return a[2] < a[2]
