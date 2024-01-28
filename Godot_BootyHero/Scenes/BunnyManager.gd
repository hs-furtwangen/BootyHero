extends Node3D

var action_last_use = {}
var currentTime = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	currentTime += delta
	pass
	
func _input(event):
	var action = ""
	if(event.is_action_pressed("LC")):
		action = "lc"
	if(event.is_action_pressed("LL")):
		action = "ll"
	if(event.is_action_pressed("LT")):
		action = "lt"
	if(event.is_action_pressed("LB")):
		action = "lb"
	if(event.is_action_pressed("RC")):
		action = "rc"
	if(event.is_action_pressed("RR")):
		action = "rr"
	if(event.is_action_pressed("RT")):
		action = "rt"
	if(event.is_action_pressed("RB")):
		action = "rb"
	if (!action): return
	if (!action_last_use.has(action)):
		action_last_use[action] = 0
	action_last_use[action] = currentTime

func is_action_active(action_to_check: String):
	var time_to_check = currentTime - 0.1
	for action in action_last_use:
		if(action.starts_with(action_to_check) && action_last_use[action] > time_to_check):
			return true
	return false
