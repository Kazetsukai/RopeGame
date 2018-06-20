extends Node

const ENABLED = true

var dir = Vector2(0, 0)
var face_left = false
var lightAttackPrefab = preload("res://Scenes/LightAttack.tscn")

var kn
var player

var refractory = 0

var sfx_thud
var sfx_thump

func _ready():
	kn = get_parent()
	player = get_parent().get_parent()
	sfx_thud = get_node("../sfx/thud")
	sfx_thump = get_node("../sfx/thump")

func _input(event):
	
	if event.is_action_pressed("action_a_" + player.player_num) and refractory <= 0:
		print("Fire!")
		var attack = lightAttackPrefab.instance()
		attack.transform.origin = kn.transform.origin
		
		var ball = attack.get_node("Area2D")
		ball.move_vector = dir.normalized() * 10
		ball.transform = ball.transform.rotated(-dir.angle_to(Vector2(1, 0)))
		ball.player_num = player.player_num
		ball.sfx = sfx_thud
		
		player.add_child(attack)
		
		sfx_thump.play()
		refractory = 0.4
	pass
	
func _process(delta):
	if !ENABLED: return
	
	dir = Vector2(0, 0)
	if Input.is_action_pressed("left_" + player.player_num):
		dir += Vector2(-1, 0)
		face_left = true
	if Input.is_action_pressed("right_" + player.player_num):
		dir += Vector2(1, 0)
		face_left = false
	if Input.is_action_pressed("up_" + player.player_num):
		dir += Vector2(0, -1)
	if Input.is_action_pressed("down_" + player.player_num):
		dir += Vector2(0, 1)
	
	if dir == Vector2(0, 0):
		if face_left:
			dir = Vector2(-1, 0)
		else:
			dir = Vector2(1, 0)
	
func _physics_process(delta):
	if refractory > 0:
		refractory -= delta
