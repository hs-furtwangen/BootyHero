extends Node3D

var bootyLeft
var bootyRight

# Called when the node enters the scene tree for the first time.
func _ready():
	print("BootyReady")
	bootyLeft = get_node("Armature/Skeleton3D/JiggleboneL")
	bootyRight = get_node("Armature/Skeleton3D/JiggleboneR")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_booty_test_clap(cheek):
	if(cheek == "Left"):
		bootyLeft.translate(Vector3(40, 40, 40))
	if(cheek == "Right"):
		bootyRight.translate(Vector3(40, 40, 40))
		
