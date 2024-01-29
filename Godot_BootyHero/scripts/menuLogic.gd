extends ScrollContainer


@export var usb_scale = 1 # (float, 0.5, 1, 0.1)
@export var usb_current_scale = 1.3 # (float, 1, 1.5, 0.1)
@export var scroll_duration = 1.3 # (float, 0.1, 1, 0.1)
@export var mainMenu: Node
@export var rootObject: Node
@export var scenes: Array[PackedScene]

var usb_current_index: int = 2
var usb_x_positions: Array = []
var action_last_use = {}
var currentTime = 0

@onready var scroll_tween: Tween
@onready var margin_r: int = $CenterContainer2/MarginContainer.get("theme_override_constants/margin_right")
@onready var usb_space: int = $CenterContainer2/MarginContainer/HBoxContainer.get("theme_override_constants/separation")
@onready var usb_nodes: Array = $CenterContainer2/MarginContainer/HBoxContainer.get_children()

var usb_stick = load("res://Scenes/song.tscn")
@onready var game_scene = load("res://Scenes/game.tscn")

func _ready() -> void:
	setup_files_in_user_dir()
	load_custom_songs()
	
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
	scroll("r")

func _process(delta: float) -> void:
	currentTime += delta
	
	for _index in range(usb_x_positions.size()):
		var _usb_pos_x: float = usb_x_positions[_index]
		var _swipe_length: float = (usb_nodes[_index].size.x / 2) + (usb_space / 2)
		var _swipe_current_length: float = abs(_usb_pos_x - scroll_horizontal)

func got_input(_pressedKey) -> void:
	#print(_pressedKey)
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
	# load built-in songs
	if usb_nodes[usb_current_index].name.contains("game"):
		if usb_nodes[usb_current_index].name.contains("game_1"):
			start_song("res://songs/space_dandy/")
		elif usb_nodes[usb_current_index].name.contains("game_2"):
			start_song("res://songs/Take_It_Off_Vs_Shake_That/")
		elif usb_nodes[usb_current_index].name.contains("game_3"):
			start_song("res://songs/Shake_Your_Booty/")
		elif usb_nodes[usb_current_index].name.contains("game_4"):
			start_song("res://songs/farting_around/")
	# load sideloaded songs
	elif usb_nodes[usb_current_index] is SongToLoad:
		start_song(usb_nodes[usb_current_index].folder)
	elif usb_nodes[usb_current_index].name == "quit":
		get_tree().quit()
	# load non-game scenes
	for scene in scenes:
		if scene.resource_path.contains(usb_nodes[usb_current_index].name):
				var newScene = load(scene.resource_path).instantiate()
				rootObject.add_child(newScene)
				mainMenu.queue_free()
		

func start_song(folder: String):
	var gameScene = game_scene.instantiate()
	print(folder)
	rootObject.add_child(gameScene)
	gameScene.read_data(folder)
	mainMenu.queue_free()

func _on_inputmanager_input_received(type):
	got_input(type)

func load_custom_songs():
	var folders = DirAccess.get_directories_at("user://sounds/")
	# check if folder has the required files in it
	var folders_with_files = []
	for folder in folders:
		if (FileAccess.file_exists("user://sounds/" + folder + "/music.mp3") && 
			FileAccess.file_exists("user://sounds/" + folder + "/data.json")):
			folders_with_files.append(folder)
	var container = $CenterContainer2/MarginContainer/HBoxContainer;
	for folder in folders_with_files:
		var json_text = FileAccess.get_file_as_string("user://sounds/" + folder + "/data.json")
		var song_data = JSON.parse_string(json_text)
		if(!song_data.name || !song_data.author): continue
		var newSong = usb_stick.instantiate()
		container.add_child(newSong)
		usb_nodes.append(newSong)
		newSong.setup("user://sounds/" + folder, song_data.name, song_data.author)
	
func setup_files_in_user_dir():
	var folder = DirAccess.open("user://");
	if(!folder.dir_exists("sounds")):
		folder.make_dir("sounds")
	if(!FileAccess.file_exists("user://sounds/README.txt")):
		var file = FileAccess.open("user://sounds/README.txt", FileAccess.WRITE)
		file.store_string("You can sideload your own songs here.

1. go to http://bootyhero.plagiatus.net/
2. create your own beat map
3. put the exported .booty file into this folder

In case that won't get recognized by the game, that means we didn't implement custom file reading yet. If that's the case, follow these steps:
4. rename the song_name.booty file to song_name.zip file. For this, make sure to enable file endings.
5. unzip the .zip file so that now you have a folder with the music and data files inside this sounds folder.
The file structure should look like this:

sounds
└ song_name
 ├ music.mp3
 └ data.json")
