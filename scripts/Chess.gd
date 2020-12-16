extends Node2D

var current_player = 1
var current_moves = [PoolIntArray()]

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var engine = preload('res://lib/bin/libengine.gdns').new()
# Called when the node enters the scene tree for the first time.
func _ready():
	$PieceMap.connect('ai_turn', $AI, 'process_turn',[], CONNECT_DEFERRED)
	$PieceMap.connect('ai_turn', $AI2, 'process_turn',[], CONNECT_DEFERRED)
	$AI.connect("movement_choice", $PieceMap, 'ai_move')
	$AI2.connect("movement_choice", $PieceMap, 'ai_move')
	$AI.set_color('white')
	$AI2.set_color('black')
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func toggle_player():
	current_player = 2 if current_player == 1 else 1


func process_moves(player):
	current_moves = engine.get_moves(player)

func get_all_moves(player):
	return engine.get_moves(player)
