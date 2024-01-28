extends Node2D

var totalLifeDuration = 0.5
var lifeDuration = totalLifeDuration
var target_scale = 1.4
var current_scale = 1
var target_rotation = randf_range(-0.7, 0.7)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_type(type: String):
	$icon.texture = load("res://Sprites/hit_elements/popups/%s.png" % type)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	lifeDuration -= delta
	if(lifeDuration < 0):
		queue_free()
	var progress = (totalLifeDuration - lifeDuration) / totalLifeDuration
	var scale = 1 + progress * (target_scale - current_scale)
	$icon.scale = Vector2(scale, scale)
	$icon.rotation = progress * target_rotation
	$icon.modulate.a = 1 - progress
