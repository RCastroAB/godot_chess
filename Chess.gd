extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var engine  = load("res://lib/bin/libengine.gdns").new()
# Called when the node enters the scene tree for the first time.
func _ready():
	$PieceMap.connect('ai_turn', $AI, 'process_turn')
	$PieceMap.connect('ai_turn', $AI2, 'process_turn')
	$AI.connect("movement_choice", $PieceMap, 'ai_move')
	$AI2.connect("movement_choice", $PieceMap, 'ai_move')
	$AI.set_color('white')
	$AI2.set_color('black')
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
