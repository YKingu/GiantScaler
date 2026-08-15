class_name MainScene

extends Node2D

var current_scene : Node
var current_scene_string : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelInfo.main_scene = self
	instantiate_level("res://Scenes/level1.tscn")


func _input(event):
	if event.is_action_pressed("next_level"):
		instantiate_level("res://Scenes/level2.tscn")
		

func instantiate_level(level_path : String):
	if current_scene != null:
		current_scene.queue_free()
	
	if current_scene_string != level_path:
		LevelInfo.resetState()
	
	current_scene_string = level_path
	var scene = load(current_scene_string)
	current_scene = scene.instantiate()
	add_child(current_scene)
	

func reload_level():
	instantiate_level(current_scene_string)
