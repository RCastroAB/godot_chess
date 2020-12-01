extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$PieceMap.connect('ai_turn', $AI, 'process_turn')
	$AI.connect("movement_choice", $PieceMap, 'ai_move')


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
