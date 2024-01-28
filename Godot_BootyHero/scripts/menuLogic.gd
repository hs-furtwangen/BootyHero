extends ScrollContainer


@export var usb_scale = 1 # (float, 0.5, 1, 0.1)
@export var usb_current_scale = 1.3 # (float, 1, 1.5, 0.1)
@export var scroll_duration = 1.3 # (float, 0.1, 1, 0.1)
@export var scenes: Array[PackedScene]

var usb_current_index: int = 0
var usb_x_positions: Array = []

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
	for _index in range(usb_x_positions.size()):
		var _usb_pos_x: float = usb_x_positions[_index]
		var _swipe_length: float = (usb_nodes[_index].size.x / 2) + (usb_space / 2)
		var _swipe_current_length: float = abs(_usb_pos_x - scroll_horizontal)

func got_input(_pressedKey) -> void:
	if _pressedKey == 4194309:
		load_scene()
	else: scroll(_pressedKey)

func scroll(_pressedKey) -> void:
	var scroll_direction = 25
	if _pressedKey == 68:
		usb_nodes[usb_current_index].get_child(0).visible = false
		usb_current_index += 1	
		if usb_current_index > usb_x_positions.size()-1:
			usb_current_index = 0
		usb_nodes[usb_current_index].get_child(0).visible = true
	elif _pressedKey == 65:
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
			
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var keycode = DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
		##65 == A
		if event.is_echo():
			scroll_tween.stop()
		elif event.pressed:
			print(keycode)
			##print(OS.get_keycode_string(keycode))
			got_input(keycode)
			
