extends ScrollContainer


@export var usb_scale = 1 # (float, 0.5, 1, 0.1)
@export var usb_current_scale = 1.3 # (float, 1, 1.5, 0.1)
@export var scroll_duration = 1.3 # (float, 0.1, 1, 0.1)
@export var mainMenu: Node
@export var rootObject: Node
@export var scenes: Array[PackedScene]

var usb_current_index: int = 0
var usb_x_positions: Array = []
var action_last_use = {}
var currentTime = 0

@onready var scroll_tween: Tween
@onready var margin_r: int = $CenterContainer2/MarginContainer.get("theme_override_constants/margin_right")
@onready var usb_space: int = $CenterContainer2/MarginContainer/HBoxContainer.get("theme_override_constants/separation")
@onready var usb_nodes: Array = $CenterContainer2/MarginContainer/HBoxContainer.get_children()


func _ready() -> void:
	##add_child(scroll_tween)
	##await get_tree().idle_frame
	scroll_tween = get_tree().create_tween().bind_node(self)
	get_h_scroll_bar().modulate.a = 0
	var _usb_pos_x: float
	
	for _usb in usb_nodes:
		_usb_pos_x = (margin_r + _usb.position.x) - ((size.x - _usb.size.x) / 2)
		_usb.pivot_offset = (_usb.size / 2)
		usb_x_positions.append(_usb_pos_x)
		
	scroll_horizontal = usb_x_positions[usb_current_index]
	##scroll()


func _process(delta: float) -> void:
	currentTime += delta
	
	for _index in range(usb_x_positions.size()):
		var _usb_pos_x: float = usb_x_positions[_index]
		var _swipe_length: float = (usb_nodes[_index].size.x / 2) + (usb_space / 2)
		var _swipe_current_length: float = abs(_usb_pos_x - scroll_horizontal)

func got_input(_pressedKey) -> void:
	print(_pressedKey)
	if _pressedKey == "lr":
		load_scene()
	else: scroll(_pressedKey)

func scroll(_pressedKey) -> void:
	var scroll_direction = 25
	if _pressedKey == "r":
		usb_nodes[usb_current_index].get_child(0).visible = false
		usb_current_index += 1	
		if usb_current_index > usb_x_positions.size()-1:
			usb_current_index = 0
		usb_nodes[usb_current_index].get_child(0).visible = true
	elif _pressedKey == "l":
		usb_nodes[usb_current_index].get_child(0).visible = false
		usb_current_index -= 1
		if usb_current_index < 0:
			usb_current_index = usb_x_positions.size()-1
		usb_nodes[usb_current_index].get_child(0).visible = true
	scroll_tween = get_tree().create_tween().bind_node(self)
	scroll_tween.tween_property(
		self,
		"scroll_horizontal",
		usb_x_positions[usb_current_index]*(scroll_direction*usb_current_index),
		scroll_duration)
		
	scroll_tween.play()

func load_scene() -> void:
	for scene in scenes:
		if scene.resource_path.contains(usb_nodes[usb_current_index].name):
				var newScene = load(scene.resource_path).instantiate()
				rootObject.add_child(newScene)
				mainMenu.queue_free()
		elif usb_nodes[usb_current_index].name.contains("game") && scene.resource_path.contains("game"):
			
			if usb_nodes[usb_current_index].name.contains("game_1"):
				var gameScene = load(scene.resource_path).instantiate()
				print("res://songs/space_dandy/")
				rootObject.add_child(gameScene)
				gameScene.read_data("res://songs/space_dandy/")
				mainMenu.queue_free()
			elif usb_nodes[usb_current_index].name.contains("game_2"):
				var gameScene = load(scene.resource_path).instantiate()
				print("res://songs/Take_It_Off_Vs_Shake_That/")
				rootObject.add_child(gameScene)
				gameScene.read_data("res://songs/Take_It_Off_Vs_Shake_That/")
				mainMenu.queue_free()
			elif usb_nodes[usb_current_index].name.contains("game_3"):
				var gameScene = load(scene.resource_path).instantiate()
				print("res://songs/Shake_Your_Booty/")
				rootObject.add_child(gameScene)
				gameScene.read_data("res://songs/Shake_Your_Booty/")
				mainMenu.queue_free()
			else:
				var gameScene = load(scene.resource_path).instantiate()
				print("res://songs/farting_around/")
				rootObject.add_child(gameScene)
				gameScene.read_data("res://songs/farting_around/")
				mainMenu.queue_free()
			
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

	if event.is_echo():
		scroll_tween.stop()
	elif event.pressed:
		got_input(what_is_currently_active())
			
func is_action_active(action_to_check: String):
	var time_to_check = currentTime - 0.1
	for action in action_last_use:
		if(action.begins_with(action_to_check) && action_last_use[action] > time_to_check):
			return true
	return false

func what_is_currently_active():
	var result = ""
	if is_action_active("lr"):
		result += "lr"
	if is_action_active("l"):
		result += "l"
	if is_action_active("r"):
		result += "r"
	return result

	
