class_name InputManager
extends Node

signal input_received(type)

static var currentTime : float = 0
static var action_last_use : Dictionary = {}
static var cooldown: float = 0.1

func _process(delta):
	currentTime += delta

func _input(event):
	if(event.is_action_pressed("LC")):
		checkAction("lc")
		checkAction("l")
	if(event.is_action_pressed("LL")):
		checkAction("ll")
		checkAction("l")
	if(event.is_action_pressed("LT")):
		checkAction("lt")
		checkAction("l")
	if(event.is_action_pressed("LB")):
		checkAction("lb")
		checkAction("l")
	if(event.is_action_pressed("RC")):
		checkAction("rc")
		checkAction("r")
	if(event.is_action_pressed("RR")):
		checkAction("rr")
		checkAction("r")
	if(event.is_action_pressed("RT")):
		checkAction("rt")
		checkAction("r")
	if(event.is_action_pressed("RB")):
		checkAction("rb")
		checkAction("r")
	checkLRAction()
	
func checkAction(action: String):
	if(!isActionUsable(action)): return
	action_last_use[action] = currentTime
	input_received.emit(action)

func isActionUsable(action) -> bool:
	if (!action): return false
	if (!action_last_use.has(action)):
		action_last_use[action] = 0
	if (action_last_use[action] > currentTime - cooldown):
		return false
	return true

func checkLRAction():
	if (!isActionUsable("l") && !isActionUsable("r")):
		checkAction("lr")

static func is_action_active(action_to_check: String) -> bool:
	var time_to_check = currentTime - cooldown
	for action in action_last_use:
		if(action.begins_with(action_to_check) && action_last_use[action] > time_to_check):
			return true
	return false

static func what_is_currently_active():
	if is_action_active("lr"):
		return "lr"
	if is_action_active("l"):
		return "l"
	if is_action_active("r"):
		return "r"
	return ""

