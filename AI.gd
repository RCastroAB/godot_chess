extends Node

var board
signal movement_choice(piece, position)

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


func calculate_gamestate_value(gamestate):
	var state_value = 0
	for piece in gamestate.values():
		if piece.player == 'black':
			state_value += piece_vals[piece.type]
		else:
			state_value -= piece_vals[piece.type]
	return state_value

func get_best_move():
	pass

func process_turn():
	var current_gamestate = board.get_gamestate()
	var moves = board.get_all_moves('black')
	var attacks = moves[1]
	var gamestate
	var value
	moves = moves[0]
	var candidates = []
	
	for piece in moves.keys():
		for move in moves[piece]:
			gamestate = board.get_gamestate_ifmove(piece, move)
			value = calculate_gamestate_value(gamestate)
			candidates += [[piece, move, value]]
	
	for piece in attacks.keys():
		for attack in attacks[piece]:
			gamestate = board.get_gamestate_ifmove(piece, attack)
			value = calculate_gamestate_value(gamestate)
			value += 1
			candidates += [[piece, attack, value]]
	candidates.sort_custom(MoveSorter, 'sort_descending')
	candidates = candidates.slice(0, 3)
	candidates.shuffle()
	emit_signal('movement_choice', candidates[0][0], candidates[0][1])


class MoveSorter:
	static func sort_descending(a,b):
		return a[2] > b[2]
