extends Node

var board
signal movement_choice(piece, position)
const MAX_DEPTH = 2

export var piece_vals = {
	'king': 100,
	'queen': 10,
	'knight': 4,
	'bishop': 3,
	'rook': 5,
	'pawn': 1
}

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	board = get_parent().get_node('PieceMap')


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func calculate_gamestate_value(gamestate, depth, color):
	if depth < MAX_DEPTH:
		color = 'black' if color == 'white' else 'white'
		return -get_best_move(gamestate, color, depth+1)[2]
	var state_value = 0
	for piece in gamestate.values():
		if piece.player == 'black':
			state_value += piece_vals[piece.type]
		else:
			state_value -= piece_vals[piece.type]
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
	return candidates[0]
	
func process_turn():
	var current_gamestate = board.get_gamestate()
	
	
	var candidate = get_best_move(current_gamestate, 'black', 0)
	print(candidate)
	emit_signal('movement_choice', candidate[0], candidate[1])


class MoveSorter:
	static func sort_descending(a,b):
		return a[2] > b[2]
