extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$UI/playerbtn0.connect("pressed", $ChessContainer/ChessGame, "_on_0player_pressed")
	$UI/playerbtn1.connect("pressed", $ChessContainer/ChessGame, "_on_1player_pressed")
	$UI/playerbtn2.connect("pressed", $ChessContainer/ChessGame, "_on_2player_pressed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
