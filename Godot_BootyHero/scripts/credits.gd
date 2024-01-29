extends Node2D

@onready var titlescreen = load("res://Scenes/titel_screen.tscn")

func _on_input_manager_input_received(type):
	if(type == "lr"):
		var newTitlescreen = titlescreen.instantiate()
		get_tree().root.add_child(newTitlescreen)
		queue_free()
