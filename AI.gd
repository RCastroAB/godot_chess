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
func evaluate_gamestate(gamestate, pcolor):
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
#		else:
#			piece_value += sqrt(board.calculate_moves(gamestate, piece).size())
#			piece_value += sqrt(board.calculate_attacks(gamestate, piece).size()*2)
		if piece.player == color:
			state_value += piece_value
		else:
			state_value -= piece_value
	if win:
		return 500
	elif lose:
		return -500
	else:
		return state_value
		

func min_gamestate(gamestate, color, alpha, beta, depth):
	if depth == MAX_DEPTH:
		return evaluate_gamestate(gamestate, self.color)
	var moves = board.get_all_moves(gamestate, color)
	moves = merge(moves[0], moves[1])
	var min_val = INF
	var value
	var next_gamestate
	var next_color = 'black' if color == 'white' else 'white'
	for piece in moves.keys():
		for move in moves[piece]:
			next_gamestate = board.get_gamestate_ifmove(gamestate, piece, move)
			value = max_gamestate(next_gamestate, next_color, alpha, beta, depth+1)
			if value <= min_val:
				min_val = value
			beta = min(value, beta)
			if alpha >= beta:
				break
		if alpha >= beta:
			break
	return min_val

func max_gamestate(gamestate, color, alpha, beta, depth):
	if depth == MAX_DEPTH:
		return evaluate_gamestate(gamestate, color)
	var moves = board.get_all_moves(gamestate, color)
	moves = merge(moves[0], moves[1])
	var value
	var next_gamestate
	var next_color = 'black' if color == 'white' else 'white'
	var max_val = -INF
	for piece in moves.keys():
		for move in moves[piece]:
			next_gamestate = board.get_gamestate_ifmove(gamestate, piece, move)
			value = min_gamestate(next_gamestate, next_color, alpha, beta, depth+1)
			if value >= max_val:
				max_val = value
			alpha = max(alpha, value)
			if alpha >= beta:
				break
		if alpha >= beta:
			break
	return max_val

func check_win(gamestate, color):
	var win = true
	for piece in gamestate.values():
		if piece.type == 'king' and piece.player != color:
			win = false
	return win

func thread_caller(params):
	if check_win(params[0], params[1]):
		return INF
	return max_gamestate(params[0], params[1], params[2], params[3], params[4])

func minmax_gamestate(gamestate, color):
	var moves = board.get_all_moves(gamestate, color)
	moves = merge(moves[0], moves[1])
	var max_val = -INF
	var best_move
	var movekeys = moves.keys()
	movekeys.shuffle()
	var threads = []
	for piece in movekeys:
		for move in moves[piece]:
			var thread = Thread.new()
			var ret = thread.start(self, "thread_caller", [gamestate, color, -INF, INF, 0])
			threads += [[piece, move, thread]]
	for thread in threads:
		var piece = thread[0]
		var move = thread[1]
		thread = thread[2]
		
		var value = thread.wait_to_finish()
		if value == INF:
			print(piece, move, value)
		if value >=  max_val:
			best_move = [piece, move]
			max_val = value
	print(color, max_val)
	return best_move

func process_turn(current_player):
	if current_player != color:
		return
	var current_gamestate = board.get_gamestate()
	
	var past = OS.get_ticks_msec()
	var candidate = minmax_gamestate(current_gamestate, color)
	var future = OS.get_ticks_msec()
#	print(future-past)
#	print(color, candidate)
	print(candidate)
	emit_signal('movement_choice', candidate[0], candidate[1])


class MoveSorter:
	static func sort_descending(a,b):
		return a[2] > b[2]
	static func sort_ascending(a,b):
		return a[2] < a[2]
