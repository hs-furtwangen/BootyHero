extends Node

var target_position: Vector2
var target_time: float
var current_time: float
var start_time: float
var movement_vector: Vector2
var start_position: Vector2

var modifiers = {
	perfect = 10,
	good = 50,
	meh = 100,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	current_time += delta
	var progress = (current_time - start_time) / (target_time - start_time)
	$icon.position = start_position + movement_vector * progress

func setup(start_pos: Vector2, target_pos: Vector2, target_t: float, time_now: float):
	start_position = start_pos
	$icon.position = start_position
	target_position = target_pos
	movement_vector = target_position - start_position
	target_time = target_t
	current_time = time_now
	start_time = time_now
