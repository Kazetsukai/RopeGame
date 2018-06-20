extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var players = []

func _ready():
	# Make N players
	for i in range(2):
		var player = preload("res://Scenes/Player.tscn").instance()
		player.player_num = String(i+1)
		var k = player.get_node("KinematicBody2D")
		k.transform = k.transform.translated(Vector2(200 + i * 50, 200))
		
		players.append(player)
		add_child(player)

func _physics_process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	var st = Engine.get_main_loop()
	pass
