extends Area2D

var move_vector = Vector2(0,0)
var player_num
var sfx

func _ready():
	pass

func _process(delta):
	pass

func _physics_process(delta):
	transform.origin += move_vector

func _on_Area2D_body_entered(body):
	var p = body.get_parent()
	if p and "player_num" in p and p.player_num == player_num:
		print("IUJBEGFJUKIB")
	else:
		sfx.play()
		get_parent().queue_free()
