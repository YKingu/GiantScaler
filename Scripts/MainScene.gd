class_name MainScene

extends Node2D

var current_scene : Node
var current_scene_string : String = ""

var checkpoints : Array[Checkpoint] 
var current_checkpoint_index : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelInfo.main_scene = self
	instantiate_level("res://Scenes/level1.tscn")

func _input(event):
	
	if event.is_action_pressed("restart_level"):
		reload_level()
	if event.is_action_pressed("prev_checkpoint"):
		load_new_checkpoint(false)
	if event.is_action_pressed("next_checkpoint"):
		load_new_checkpoint(true)
	
	if event.is_action_pressed("prev_level"):
		instantiate_level("res://Scenes/level1.tscn")
	if event.is_action_pressed("next_level"):
		instantiate_level("res://Scenes/level2.tscn")

func instantiate_level(level_path : String):
	if current_scene != null:
		current_scene.queue_free()
	
	if current_scene_string != level_path:
		current_checkpoint_index = 0
	
	current_scene_string = level_path
	var scene = load(current_scene_string)
	current_scene = scene.instantiate()
	add_child(current_scene)
	
	get_checkpoints()
	load_checkpoint()

func get_checkpoints():
	
	checkpoints.clear()
	
	for child in get_all_child_nodes(current_scene):
		if child is Checkpoint:
			var added_checkpoint = false
			for i in checkpoints.size():
				if checkpoints[i].check_point_number > child.check_point_number:
					checkpoints.insert(i,child)
					added_checkpoint = true
					break 
			if not added_checkpoint:
				checkpoints.append(child)

func load_checkpoint():
	print("load checkpoint")
	print(checkpoints.size())
	if current_checkpoint_index < checkpoints.size():
		print("checkpoint loaded")
		LevelInfo.current_checkpoint_number = checkpoints[current_checkpoint_index].check_point_number
		checkpoints[current_checkpoint_index].load_from_this_checkpoint()

func load_new_checkpoint(load_next_checkpoint : bool):
	var new_checkpoint_index : int = current_checkpoint_index
	if load_next_checkpoint:
		new_checkpoint_index += 1
		if new_checkpoint_index >= checkpoints.size():
			new_checkpoint_index = checkpoints.size()
	else:
		new_checkpoint_index -= 1
		if new_checkpoint_index < 0: 
			new_checkpoint_index = 0
	
	load_checkpoint()

func set_checkpoint(new_checkpoint : Checkpoint):
	for i in checkpoints.size():
		if checkpoints[i] == new_checkpoint:
			if i < current_checkpoint_index:
				LevelInfo.current_checkpoint = checkpoints[i].check_point_number
				current_checkpoint_index = i
				return

func reload_level():
	instantiate_level(current_scene_string)

func get_all_child_nodes(node : Node) -> Array[Node]:
	
	var return_array := node.get_children()
	
	for child in node.get_children():
		if child.get_child_count() > 0:
			return_array.append_array(get_all_child_nodes(child))
	
	return return_array
