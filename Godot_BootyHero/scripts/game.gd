extends Node2D

var song_data;
var fly_in_time = 3;
#var currentTime = -1 * fly_in_time * 2;
var currentTime = -0.5;
var notes_per_beat = 8

# Called when the node enters the scene tree for the first time.
func _ready():
	read_data("res://songs/farting_around/")
	#read_zip_file("res://songs/farting_around.zip")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(currentTime < 0 && currentTime + delta > 0):
		$AudioStreamPlayer.play()
	currentTime += delta
	var time_to_appear = currentTime + fly_in_time
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
		for note in section.notes_to_spawn[index]:
			spawn_note(note)


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

func read_zip_file(file):
	var reader := ZIPReader.new();
	var err := reader.open(file);
	if(err) != OK:
		return PackedByteArray()
	var data := reader.read_file("data.json")
	var music := reader.read_file("music.ogg")
	$AudioStreamPlayer.play()
	
func spawn_note(note):
	var scene = load("res://Scenes/hit_elements/" + note + ".tscn")
	var newNote = scene.instance()
	add_child(newNote)
