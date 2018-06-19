extends Node

const ROPE_SPEED = 20
const ENABLED = false

var kn
var firing = false
var hooked = false
var rope_pos
var rope_dir
var line
var controls
var rope_time

func _ready():
	if !ENABLED: return
	kn = get_parent()
	line = $Line2D
	controls = $"../Controls"

func _input(event):
	if !ENABLED: return
	
	if event.is_action_pressed("jump"):
		if hooked:
			firing = false
			hooked = false
			controls.hook_point = null
		
	if event.is_action_pressed("rope"):
		if firing || hooked:
			firing = false
			hooked = false
			controls.hook_point = null
		else:
			rope_pos = kn.global_position
			rope_dir = (controls.dir + Vector2(0, -1)).normalized()
			firing = true
			
			print("firing rope: " + str(rope_dir))

func _process(delta):
	if !ENABLED: return
	
	line.set_point_position(0, kn.global_position)

func _physics_process(delta):
	if !ENABLED: return
	
	line.visible = firing || hooked
	
	if hooked:
		rope_pos = controls.hook_relative.global_position + controls.hook_point
	
	if rope_pos:
		line.set_point_position(1, rope_pos)
	
	if firing:
		
		rope_pos += rope_dir * ROPE_SPEED
		
		var length = (kn.global_position - rope_pos).length()
		if length > 200:
			firing = false
		
		var space_state = kn.get_world_2d().get_direct_space_state()
		var result = space_state.intersect_ray( kn.global_position, rope_pos, [ RID(get_parent()) ])
		if !result.empty():
			rope_time = 0.5
			controls.hook_point = result.position - result.collider.global_position
			controls.hook_relative = result.collider
			controls.hook_length = (result.position - kn.global_position).length()
			hooked = true
			firing = false
			
	if rope_time && rope_time > 0:
		#rope_time -= delta
		if rope_time <= 0:
			hooked = false
			controls.hook_point = null