extends Node

var box_width = 50
var move_distance = box_width * 3
var box_start_position
var time = 0

func _ready():
	box_start_position = $StaticBody2D.global_position
	pass

func _physics_process(delta):
	time += delta
	$StaticBody2D.global_position.x = sin(time) * move_distance + box_start_position.x