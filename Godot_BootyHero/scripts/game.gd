extends Node2D

var real_booty_mode = false;

var song_data;
var fly_in_time = 1
var currentTime = -1 * fly_in_time * 2;
#var currentTime = -0.5
var notes_per_beat = 8
var hit_cooldown = 0.1

var hit_elements = {}
var active_elements = {}
var action_last_use = {}

var points = 0
var multiplier = 1
var heat = 0

var total_song_duration = 0

@onready var popup = preload("res://Scenes/hit_elements/popups/popup.tscn")
@onready var missSound = get_node("UI/FartSound")
@onready var hitSound = get_node("UI/ClapSound")

# Called when the node enters the scene tree for the first time.
func _ready():
	#if(!song_data):
		#read_data("res://songs/space_dandy/")
	#read_zip_file("res://songs/farting_around.zip")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(currentTime < 0 && currentTime + delta > 0):
		$AudioStreamPlayer.play()
	currentTime += delta
	var time_to_appear = currentTime + fly_in_time
	if(!song_data): return
	for section in song_data.sections:
		#print(currentTime, " ", section.start, " ", section.end)
		if(section.start > time_to_appear || section.end < time_to_appear):
			continue
		var section_time = time_to_appear - section.start
		var note_duration = (60 / section.bpm) / notes_per_beat
		var index = floor(section_time / note_duration)
		if(!section.has("last_beat")):
			section.last_beat = -1
		if(section.last_beat && section.last_beat == index):
			continue
		section.last_beat = index;
		if section.notes_to_spawn.size() > index:
			for note in section.notes_to_spawn[index]:
				spawn_note(note, time_to_appear)
	$song_progress.value = currentTime
	if (currentTime > total_song_duration + 4):
		var titlescreen = load("res://Scenes/titel_screen.tscn").instantiate()
		get_tree().root.add_child(titlescreen)
		queue_free()


func read_data(file):
	var music = load(file + "/music.mp3")
	$AudioStreamPlayer.stream = music
	
	var json_text = FileAccess.get_file_as_string(file + "/data.json")
	song_data = JSON.parse_string(json_text)
	
	for section in song_data.sections:
		section.notes_to_spawn = []
		var duration = section.end - section.start
		var beats_per_section = floor(duration / ((60 / section.bpm) / notes_per_beat))
		for beat in beats_per_section:
			var notes = []
			for note in section.notes:
				if(section.notes[note].has(beat)):
					notes.append(note)
			section.notes_to_spawn.append(notes)
		if section.end > total_song_duration:
			total_song_duration = section.end
	$song_progress.max_value = total_song_duration

func read_zip_file(file):
	var reader := ZIPReader.new();
	var err := reader.open(file);
	if(err) != OK:
		return PackedByteArray()
	var data := reader.read_file("data.json")
	var music := reader.read_file("music.ogg")
	$AudioStreamPlayer.play()
	
func spawn_note(note: String, time: float):
	#if(note != "lc"): return
	if(real_booty_mode):
		note = note.substr(0, 1) + "c"
	if(!hit_elements.has(note)):
		hit_elements[note] = load("res://Scenes/hit_elements/" + note + ".tscn")
	var scene = hit_elements[note]
	if(!scene): return
	var newNote = scene.instantiate()
	add_child(newNote)
	if(!active_elements.has(note)):
		active_elements[note] = []
	active_elements[note].append(newNote)
	
	var start_target_node = get_node("targets/target_" + note)
	var target_target_node = get_node("targets/target_" + note.substr(0, 1))
	newNote.setup(start_target_node.position, target_target_node.position, time, currentTime, note)

	

func hit(type: String, action: String):
	match type:
		"miss":
			missSound.play()
			if(heat == 0):
				if(multiplier > 5):
					multiplier = 6
				multiplier = max(multiplier - 1, 1)
			heat = 0
		"meh":
			hitSound.play()
			heat += 1
		"good":
			hitSound.play()
			heat += 2
		"perfect":
			hitSound.play()
			heat += 5
	
	if(heat >= 25 && multiplier < 10):
		multiplier += 1
		heat -= 25
		if(multiplier > 5):
			multiplier = 10
			heat += 25
	if(type != "miss"):
		points += floor((multiplier + min(heat / 25, 10)) * 10)
	
	get_node("Control/multiplier").text = "[center]%sx[/center]" % multiplier
	get_node("Control/heatBar").value = heat
	get_node("Control/points").text = "[center]%s[/center]" % points
	var newPopup = popup.instantiate()
	add_child(newPopup)
	newPopup.position = get_node("targets/target_" + action.substr(0, 1)).position
	newPopup.set_type(type)


func _on_input_manager_input_received(action: String):
	if(action == "l" || action == "lr" || action == "r"): return
	if(!active_elements.has(action)):
		hit("miss", action)
		return
	while active_elements[action].size() > 0 && !is_instance_valid(active_elements[action][0]):
		active_elements[action].pop_front()
	if(active_elements[action].size() == 0):
		hit("miss", action)
		return
	var accuracy = active_elements[action][0].hitMe()
	hit(accuracy, action)
