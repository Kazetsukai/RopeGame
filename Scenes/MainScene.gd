extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var players = []

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	for i in range(2):
		var player = preload("res://Scenes/Player.tscn").instance()
		player.player_num = String(i+1)
		var k = player.get_node("KinematicBody2D")
		k.transform = k.transform.translated(Vector2(200 + i * 50, 200))
		
		players.append(player)
		add_child(player)
	
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
