extends Node

const ROPE_SPEED = 20

var kn
var firing = false
var hooked = false
var rope_pos
var rope_dir
var line
var controls
var rope_time

func _ready():
	kn = get_parent()
	line = $Line2D
	controls = $"../Controls"
	pass

func _input(event):
	if event.is_action_pressed("rope"):
		if firing || hooked:
			firing = false
			hooked = false
			controls.hook_point = null
		else:
			rope_pos = kn.global_position
			if controls.velocity.x > 0:
				rope_dir = Vector2(1, -1).normalized()
			else:
				rope_dir = Vector2(-1, -1).normalized()
			firing = true
			
			print("firing rope: " + str(rope_dir))
	pass

func _process(delta):
	line.set_point_position(0, kn.global_position)

func _physics_process(delta):
	line.visible = firing || hooked
	if rope_pos:
		line.set_point_position(1, rope_pos)
	
	if firing:
		
		rope_pos += rope_dir * ROPE_SPEED
		
		var length = (kn.global_position - rope_pos).length()
		if length > 200:
			firing = false
		
		var space_state = kn.get_world_2d().get_direct_space_state()
		var result = space_state.intersect_ray( rope_pos - rope_dir, rope_pos)
		if !result.empty():
			rope_time = 0.5
			controls.hook_point = result.position
			controls.hook_length = length
			hooked = true
			firing = false
			
	if rope_time && rope_time > 0:
		rope_time -= delta
		if rope_time <= 0:
			hooked = false
			controls.hook_point = null
	
	pass