extends Node2D

# Role: In charge of running the chess logic
# and connecting to the engine


var current_player = 0
var current_moves = [PoolIntArray()]
var num_players = 1

signal select_piece(piece_pos)
signal move_piece(piece_pos)
signal moves_processed(moves)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var engine = preload('res://lib/bin/libengine.gdns').new()

var players = []


func _ready():
	if num_players == 1:
		players.append(load('res://scenes/Player.tscn').instance())
		players.append(load('res://scenes/AI.tscn').instance())
	add_child(players[0])
	add_child(players[1])
	
	players[0].connect('select_piece', $PieceMap, '_on_piece_selected')
	players[1].connect('select_piece', $PieceMap, '_on_piece_selected')
	
	connect("moves_processed", $PieceMap, '_on_moves_processed')
	call_deferred('turn')
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func turn():
	current_moves = get_all_moves(current_player)
	emit_signal("moves_processed", current_moves)

func toggle_player():
	current_player = 1 if current_player == 0 else 0


func process_moves(player):
	current_moves = engine.get_moves(player)

func get_all_moves(player):
	return engine.get_moves(player)
