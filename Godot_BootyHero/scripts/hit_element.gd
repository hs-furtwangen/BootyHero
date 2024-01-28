extends Node

var target_position: Vector2
var target_time: float
var current_time: float
var start_time: float
var movement_vector: Vector2
var start_position: Vector2
var type: String

var modifiers = {
	perfect = 0.050,
	good = 0.100,
	meh = 0.300,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	current_time += delta
	var progress = min((current_time - start_time) / (target_time - start_time), 1)
	$icon.position = start_position + movement_vector * progress
	
	if(current_time > target_time + modifiers["meh"]):
		get_node("..").hit("miss", type)
		queue_free()

func setup(start_pos: Vector2, target_pos: Vector2, target_t: float, time_now: float, t: String):
	start_position = start_pos
	$icon.position = start_position
	target_position = target_pos
	movement_vector = target_position - start_position
	target_time = target_t
	current_time = time_now
	start_time = time_now
	type = t

func hitMe():
	if current_time < target_time - modifiers["meh"]:
		return "miss"
	# TODO do something to show you've hit me
	
	var quality = "meh"
	if(current_time > target_time - modifiers["good"] && current_time < target_time + modifiers["good"]):
		quality = "good"
	if(current_time > target_time - modifiers["perfect"] && current_time < target_time + modifiers["perfect"]):
		quality = "perfect"
	queue_free()
	return quality
