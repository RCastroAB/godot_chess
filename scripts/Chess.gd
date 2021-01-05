extends Node2D

# Role: In charge of running the chess logic
# and connecting to the engine


var current_player = 1
var current_moves = [PoolIntArray()]
var num_players = 2
signal new_board(board)

signal moves_processed(moves)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var engine = preload('res://lib/bin/libengine.gdns')

var players = []

func _ready():
	engine = engine.new()
	if num_players == 1:
		players.append(load('res://scenes/Player.tscn').instance())
		players.append(load('res://scenes/AI.tscn').instance())
		connect("moves_processed", players[1], '_on_moves_processed')
		$PieceMap.connect('move_piece', players[1], '_on_move_piece')
	elif num_players == 2:
		players.append(load('res://scenes/Player.tscn').instance())
		players.append(load('res://scenes/Player.tscn').instance())
	add_child(players[0])
	add_child(players[1])
	
	
	connect("moves_processed", $PieceMap, '_on_moves_processed')
	
	$PieceMap.set_board(engine.get_board())
	$PieceMap.connect('move_piece', self, '_on_move_piece')
	
	connect("new_board", $PieceMap, '_on_new_board')
	
	call_deferred('turn')


func emit_from_agent(pos):
	emit_signal("select_piece", pos)

func turn():
	players[current_player-1].connect('select_piece', $PieceMap, '_on_piece_selected')
	players[other_player()-1].disconnect('select_piece', $PieceMap, '_on_piece_selected')
	players[current_player-1].playing = true
	players[other_player()-1].playing = false
	
	var checkmate = engine.get_checkmate(current_player)
	print('checkmate: ', checkmate)
	if checkmate:
		$Win/Label.text = "Player " + str(other_player()) + " Wins!"
		$Win.visible = true
		return
	current_moves = get_all_moves(current_player)
	
	emit_signal("moves_processed", current_moves)
	
	
func toggle_player():
	current_player = 1 if current_player == 2 else 2

func other_player():
	return 1 if current_player == 2 else 2

func process_moves(player):
	current_moves = engine.get_moves(player)

func get_all_moves(player):
	return engine.get_moves(player)

func _on_move_piece(old_place, new_place, att_place, color):
	engine.move_piece(old_place.x, old_place.y,
	new_place.x, new_place.y, color)
	toggle_player()
	emit_signal('new_board', engine.get_board())
	call_deferred('turn')
