extends Node2D

# Role: In charge of running the chess logic
# and connecting to the engine


var current_player
var current_moves = [PoolIntArray()]
var num_players = 0
signal new_board(board)

signal moves_processed(moves)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var engineloader = preload('res://lib/bin/libengine.gdns')
var engine
var players = []


func delete_old_players():
	for child in players:
		if is_connected("moves_processed", child, '_on_moves_processed'):
			disconnect("moves_processed", child, '_on_moves_processed')
		if $PieceMap.is_connected("move_piece", child, '_on_move_piece'):
			$PieceMap.disconnect("move_piece", child, '_on_move_piece')
		remove_child(child)
		child.queue_free()
	players = []
	
	engine = load('res://lib/bin/libengine.gdns').new()
	
	
	
	

func players_ready():
	add_child(players[0])
	add_child(players[1])
	players[0].set_color(1)
	players[1].set_color(2)

	$PieceMap.set_board(engine.get_board())
	current_player = 1
	
	call_deferred('turn')

func _on_0player_pressed():
	_on_2player_pressed()
	
	var t = Timer.new()
	t.set_wait_time(0.5)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	
	
	
	delete_old_players()
	
	players.append(load('res://scenes/AI.tscn').instance())
	players.append(load('res://scenes/AI.tscn').instance())
	connect("moves_processed", players[0], '_on_moves_processed')
	$PieceMap.connect('move_piece', players[0], '_on_move_piece')
	connect("moves_processed", players[1], '_on_moves_processed')
	$PieceMap.connect('move_piece', players[1], '_on_move_piece')
	
	players_ready()
	

func _on_1player_pressed():
	delete_old_players()
	
	players.append(load('res://scenes/Player.tscn').instance())
	players.append(load('res://scenes/AI.tscn').instance())
	connect("moves_processed", players[1], '_on_moves_processed')
	$PieceMap.connect('move_piece', players[1], '_on_move_piece')
	
	
	players_ready()

func _on_2player_pressed():
	delete_old_players()
	
	players.append(load('res://scenes/Player.tscn').instance())
	players.append(load('res://scenes/Player.tscn').instance())
	
	
	players_ready()



func _ready():
	

	connect("moves_processed", $PieceMap, '_on_moves_processed')
	
	$PieceMap.connect('move_piece', self, '_on_move_piece')
	
	connect("new_board", $PieceMap, '_on_new_board')


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
	print(current_moves)
#	print('it broke there')
	if current_moves == []:
		$Win/Label.text = "DRAW"
		$Win.visible = true
		return
	var t = Timer.new()
	t.set_wait_time(0.5)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")

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
