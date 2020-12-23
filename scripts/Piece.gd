extends Node2D

export var speed = 1000
export var tolerance = 20
var type
var id
var target = position
var moving = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var grid_position = Vector2()
var player

const SPRITES = 'res://sprites/'

var moved = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func create_piece(piecename, color):
	var movesrepeat
	player = color
	var path = ''
	if color == 'white':
		path = 'white_'
	type = piecename
	match piecename:
		'king':
			$Sprite.texture = load(SPRITES +path+'WIP_king.png')
		'queen':
			$Sprite.texture = load(SPRITES +path+'WIP_queen.png')
		'knight':
			$Sprite.texture = load(SPRITES +path+'fuglier_horse.png')
		'pawn':
			$Sprite.texture = load(SPRITES +path+'WIP_pawn.png')
		'bishop':
			$Sprite.texture = load(SPRITES +path+'WIP_pawn.png')
		'rook':
			$Sprite.texture = load(SPRITES + path + 'WIP_rook.png')
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target != position:
		moving = true
	if moving == true:
		if (target - position).length() <= tolerance:
			position = target
			$Knock.pitch_scale *= rand_range(0.99, 1.01)
			$Knock.play()
			moving = false
		else:
			position += (target-position).normalized() * speed *delta

