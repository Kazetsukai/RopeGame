extends Node

const ENABLED = true

var dir = Vector2(0, 0)
var lightAttackPrefab = preload("res://Scenes/LightAttack.tscn")

var kn
var player

func _ready():
	kn = get_parent()
	player = get_parent().get_parent()
	pass

func _input(event):
	
	if event.is_action_pressed("action_a_" + player.player_num):
		print("Fire!")
		var attack = lightAttackPrefab.instance()
		attack.transform.origin = kn.transform.origin
		player.add_child(attack)
	pass
	
func _process(delta):
	if !ENABLED: return
	
	dir = Vector2(0, 0)
	if Input.is_action_pressed("left_" + player.player_num):
		dir += Vector2(-1, 0)
	if Input.is_action_pressed("right_" + player.player_num):
		dir += Vector2(1, 0)
	if Input.is_action_pressed("up_" + player.player_num):
		dir += Vector2(0, -1)
	if Input.is_action_pressed("down_" + player.player_num):
		dir += Vector2(0, 1)
		
	pass
