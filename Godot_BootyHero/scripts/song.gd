class_name SongToLoad
extends Node

var folder: String
var author: String
var songname: String

func setup(_folder: String, _name: String, _author: String):
	folder = _folder
	songname = _name
	author = _author
	$RichTextLabel.text = "[center]" + _name + "\nby " + _author

func is_song():
	return true
