extends ScrollContainer


@export var usb_scale = 1 # (float, 0.5, 1, 0.1)
@export var usb_current_scale = 1.3 # (float, 1, 1.5, 0.1)
@export var scroll_duration = 1.3 # (float, 0.1, 1, 0.1)

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
	
	for _usb in usb_nodes:
		var _usb_pos_x: float = (margin_r + _usb.position.x) - ((size.x - _usb.size.x) / 2)
		_usb.pivot_offset = (_usb.size / 2)
		usb_x_positions.append(_usb_pos_x)
		
	scroll_horizontal = usb_x_positions[usb_current_index]
	scroll()


func _process(delta: float) -> void:
	for _index in range(usb_x_positions.size()):
		var _usb_pos_x: float = usb_x_positions[_index]
		var _swipe_length: float = (usb_nodes[_index].size.x / 2) + (usb_space / 2)
		var _swipe_current_length: float = abs(_usb_pos_x - scroll_horizontal)
		var _usb_scale: float = remap(_swipe_current_length, _swipe_length, 0, usb_scale, usb_current_scale)
		var _usb_opacity: float = remap(_swipe_current_length, _swipe_length, 0, 0.3, 1)
		
		_usb_scale = clamp(_usb_scale, usb_scale, usb_current_scale)
		_usb_opacity = clamp(_usb_opacity, 0.3, 1)
		
		usb_nodes[_index].scale = Vector2(_usb_scale, _usb_scale)
		usb_nodes[_index].modulate.a = _usb_opacity
		
		if _swipe_current_length < _swipe_length:
			usb_current_index = _index


func scroll() -> void:
	scroll_tween = get_tree().create_tween().bind_node(self)
	scroll_tween.tween_property(
		self,
		"scroll_horizontal",
		##scroll_horizontal,
		usb_x_positions[usb_current_index],
		scroll_duration)
		##Tween.TRANS_BACK,
		##Tween.EASE_OUT)
		
	for _index in range(usb_nodes.size()):
		var _usb_scale: float = usb_current_scale if _index ==usb_current_index else usb_scale
		scroll_tween.tween_property(
			usb_nodes[_index],
			"scale",
			##card_nodes[_index].scale,
			Vector2(_usb_scale,_usb_scale),
			scroll_duration)
			##Tween.TRANS_QUAD,
			##Tween.EASE_OUT)
		
	scroll_tween.play()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var keycode = DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
		##65 == A
		if event.is_released() && keycode == 65:
			print("Click")
			print(keycode)
			print(OS.get_keycode_string(keycode))
			scroll_tween.stop()
		else:
			scroll()
