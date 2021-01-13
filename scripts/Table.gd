extends TileMap
signal win(color)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var white_wins = 0
var black_wins = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$UI/playerbtn0.connect("pressed", $ChessContainer/ChessGame, "_on_0player_pressed")
	$UI/playerbtn1.connect("pressed", $ChessContainer/ChessGame, "_on_1player_pressed")
	$UI/playerbtn2.connect("pressed", $ChessContainer/ChessGame, "_on_2player_pressed")
	$ChessContainer/ChessGame.connect("win", self, '_on_win')

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_win(color):
	if color == 'White':
		white_wins += 1
		$UI/Wins/White/WinCount.text = str(white_wins)
	else:
		black_wins += 1
		$UI/Wins/Black/WinCount.text = str(black_wins)
