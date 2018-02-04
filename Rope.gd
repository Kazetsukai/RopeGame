extends Node

const ROPE_SPEED = 20

var kn
var firing = false
var rope_pos
var rope_dir
var line

func _ready():
	kn = get_parent()
	line = $Line2D
	pass

func _input(event):
	if event.is_action_pressed("rope"):
		if firing:
			firing = false
		else:
			var target = event.position
			rope_pos = kn.global_position
			rope_dir = (target - rope_pos).normalized()
			firing = true
			
			print("firing rope: " + str(rope_dir))
	pass

func _process(delta):
	line.set_point_position(0, kn.global_position)

func _physics_process(delta):
	line.visible = firing
	
	if firing:
		line.set_point_position(1, rope_pos)
		
		rope_pos += rope_dir * ROPE_SPEED
		
		var length = (kn.global_position - rope_pos).length()
		if length > 200:
			firing = false
	
	pass