extends Node2D


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
	
	var ret = engine.print_moves()
	print(ret)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
