extends Node

const FLOOR_NORMAL = Vector2(0, -1)
const GRAVITY = Vector2(0, 1500)
const GRAVITY_JUMP = Vector2(0, 100)
const MAX_SPEED = 500
const TARGET_MOVE_SPEED = 150
const ACCEL = 5000
const AIR_ACCEL = 1000

var velocity = Vector2(0, 0)
var ground_tangent = Vector2(1, 0)
var ground_normal = Vector2(1, 0)
var kn
var poly

const JUMP_HOLD_LENGTH = 0.25
var jump_hold = 0
var wall_jump_leeway = 0

func _ready():
	kn = get_parent()
	poly = get_parent().get_node("Polygon2D")
	pass

func _input(event):
	if event.is_action_pressed("jump"):
		if kn.is_on_floor():
			velocity -= GRAVITY / 7
			jump_hold = JUMP_HOLD_LENGTH
		elif wall_jump_leeway > 0:
			velocity += ground_normal * GRAVITY.length() / 7
			jump_hold = JUMP_HOLD_LENGTH
			velocity -= GRAVITY / 7
	pass
 
func _physics_process(delta):
	print(wall_jump_leeway)
	
	if kn.is_on_floor():
		poly.color = Color(0, 0, 1)
	else:
		poly.color = Color(1, 0, 1)
	
	if Input.is_action_pressed("jump") && jump_hold > 0:
		poly.color = Color(0, 1, 0)
		velocity += GRAVITY_JUMP * delta
	else:
		velocity += GRAVITY * delta
	jump_hold -= delta
	
	# Speed limit
	var length = velocity.length()
	if length > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED
	
	velocity = kn.move_and_slide(velocity, FLOOR_NORMAL)
	
	var move = 0
	if Input.is_action_pressed("left"):
		move += -TARGET_MOVE_SPEED
	if Input.is_action_pressed("right"):
		move += TARGET_MOVE_SPEED
	
	if kn.get_slide_count() > 0:
		var col = kn.get_slide_collision(0)
		ground_normal = col.get_normal()
		ground_tangent = ground_normal.rotated(PI * 0.5)
	
	if kn.is_on_wall() && !kn.is_on_floor() && velocity.y > 0:
		wall_jump_leeway = 5
		
	if wall_jump_leeway > 0:
		poly.color = Color(1, 0, 0)
		velocity.y = min(50, velocity.y)
		wall_jump_leeway -= 1
		
	if !kn.is_on_floor() || kn.is_on_wall():
		ground_tangent = Vector2(1, 0)
		
	var target_velocity = move * ground_tangent
	var plane_velocity = ground_tangent.dot(velocity) * ground_tangent
	var d = target_velocity - plane_velocity
	if kn.is_on_floor():
		d = d.normalized() * min(d.length(), ACCEL * delta)
	else:
		d = d.normalized() * min(d.length(), AIR_ACCEL * delta)
	velocity += d
	
	pass
