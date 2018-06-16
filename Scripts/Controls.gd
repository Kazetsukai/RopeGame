extends Node

const FLOOR_NORMAL = Vector2(0, -1)
const GRAVITY = Vector2(0, 1500)
const GRAVITY_JUMP = Vector2(0, 100)
const MAX_SPEED = 500
const MAX_FALL_SPEED = 300
const MAX_ROPE_SPEED = 500
const TARGET_MOVE_SPEED = 150
const ACCEL = 5000
const AIR_ACCEL = 1000
const JUMP_IMPULSE = GRAVITY / 5

var velocity = Vector2(0, 0)
var ground_tangent = Vector2(1, 0)
var ground_normal = Vector2(1, 0)
var kn
var poly
var hook_point
var hook_length
var hook_relative
var rope_normal
var move
var dir = Vector2(1, 0) # Direction vector, left or right

# SFX
var sfx_jump
var sfx_thud
var thuddable = false
var sfx_thump
var thumpable = false
var sfx_slide
var sliding = false

const JUMP_HOLD_LENGTH = 0.20
var jump_hold = 0
var wall_jump_leeway = 0

func _ready():
	# Get SFX
	sfx_jump = get_node("../sfx/jump")
	sfx_thud = get_node("../sfx/thud")
	sfx_thump = get_node("../sfx/thump")
	sfx_slide = get_node("../sfx/slide")
	
	kn = get_parent()
	poly = get_parent().get_node("Polygon2D")
	pass

func _input(event):
	if event.is_action_pressed("jump"):
		if kn.is_on_floor():
			sfx_jump.play()
			velocity -= JUMP_IMPULSE
			jump_hold = JUMP_HOLD_LENGTH
		elif wall_jump_leeway > 0:
			sfx_jump.play()
			velocity += ground_normal * JUMP_IMPULSE.length() / 2
			velocity -= JUMP_IMPULSE
			jump_hold = JUMP_HOLD_LENGTH
		elif hook_point:
			velocity += Vector2(move.x, 0) * JUMP_IMPULSE.length()
			velocity -= JUMP_IMPULSE
			jump_hold = JUMP_HOLD_LENGTH
			
	pass
 
func _physics_process(delta):
	if kn.is_on_wall():
		if !sfx_slide.playing:
			sfx_slide.play()
	else:
		sfx_slide.stop()
		
	if !kn.is_on_floor():
		thuddable = true
		if !kn.is_on_wall():
			thumpable = true
	
	if kn.is_on_floor():
		poly.color = Color(0, 0, 1)
		if thuddable:
			sfx_thud.play()
			thuddable = false
			thumpable = false
	else:
		poly.color = Color(1, 0, 1)
	
	if Input.is_action_pressed("jump") && jump_hold > 0:
		poly.color = Color(0, 1, 0)
		velocity += GRAVITY_JUMP * delta		
	else:
		velocity += GRAVITY * delta
	jump_hold -= delta
	
	# Speed limit
	if velocity.y > MAX_FALL_SPEED:
		velocity.y = MAX_FALL_SPEED
	var length = velocity.length()
	if length > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED
	
	velocity = kn.move_and_slide(velocity, FLOOR_NORMAL)
	if hook_point:
		var hp = hook_point + hook_relative.global_position
		var rope_vec = hp - kn.global_position
		var rope_dir = rope_vec.normalized()
		var ideal = hp - rope_dir * hook_length
		var rope_diff = ideal - kn.global_position
		rope_normal = rope_dir.rotated(PI * 0.5)
		kn.move_and_slide(rope_diff / delta, FLOOR_NORMAL)
		velocity = rope_normal.dot(velocity) * rope_normal
	
	move = Vector2(0,0)
	if Input.is_action_pressed("left"):
		move += Vector2(-1, 0)
		dir = Vector2(-1, 0)
	if Input.is_action_pressed("right"):
		move += Vector2(1, 0)
		dir = Vector2(1, 0)
	if Input.is_action_pressed("up"):
		move += Vector2(0, -1)
	if Input.is_action_pressed("down"):
		move += Vector2(0, 1)
	
	if !hook_point || move.x != 0:
		if kn.get_slide_count() > 0:
			var col = kn.get_slide_collision(0)
			ground_normal = col.get_normal()
			ground_tangent = ground_normal.rotated(PI * 0.5)
		
		if kn.is_on_wall() && !kn.is_on_floor() && velocity.y > 0:
			wall_jump_leeway = 5
			if thumpable:
				sfx_thump.play()
				thumpable = false
			
			
		if wall_jump_leeway > 0:
			poly.color = Color(1, 0, 0)
			velocity.y = min(50, velocity.y)
			wall_jump_leeway -= 1
			
		if !kn.is_on_floor() || kn.is_on_wall():
			ground_tangent = Vector2(1, 0)
		if hook_point:
			ground_tangent = rope_normal
		
		# Apply acceleration
		var move_speed = TARGET_MOVE_SPEED
		if hook_point:
			move_speed = min(move_speed + velocity.length(), MAX_ROPE_SPEED)
		var target_velocity = move * ground_tangent * move_speed
		var plane_velocity = ground_tangent.dot(velocity) * ground_tangent
		var d = target_velocity - plane_velocity
		if kn.is_on_floor():
			d = d.normalized() * min(d.length(), ACCEL * delta)
		else:
			d = d.normalized() * min(d.length(), AIR_ACCEL * delta)
		velocity += d
	
	pass
