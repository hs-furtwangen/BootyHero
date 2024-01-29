extends Node3D

signal clap(cheek)

var action_last_use = {}
var currentTime = 0
var gameNode
var animationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Bunny Ready") # Replace with function body.
	gameNode = get_node("../../../../game")
	animationPlayer = get_node("BootyBunny/AnimationPlayer")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	currentTime += delta
	if (gameNode != null):
		var state = InputManager.what_is_currently_active()
		if(state == "l"):
			animationPlayer.play("PawDownRight")
			emit_signal("clap", "Right")
		elif(state == "r"):
			animationPlayer.play("PawDownLeft")
			emit_signal("clap", "Left")
		elif(state == "lr"):
			animationPlayer.play("PawDownBoth")
			emit_signal("clap", "Left")
			emit_signal("clap", "Right")
		else:
			animationPlayer.play("PawIdle")
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
	


