class_name MainScene

extends Node2D

var current_scene : Node
var current_scene_string : String = ""

var checkpoints : Array[Checkpoint] 
var current_checkpoint_index : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	static_fields.main_scene = self
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
	set_checkpoints_sprite()

func get_checkpoints():
	
	checkpoints.clear()
	
	for child in static_functions.get_all_child_nodes(current_scene):
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
	if current_checkpoint_index < checkpoints.size():
		checkpoints[current_checkpoint_index].load_from_this_checkpoint()

func set_checkpoints_sprite():
	for checkpoint in checkpoints:
		checkpoint.set_sprite_active()

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
	
	current_checkpoint_index = new_checkpoint_index
	load_checkpoint()

func set_checkpoint(new_checkpoint : Checkpoint):
	for i in checkpoints.size():
		if checkpoints[i] == new_checkpoint:
			if i > current_checkpoint_index:
				current_checkpoint_index = i
				return

func checkpoint_is_active(checkpoint_to_check : Checkpoint) -> bool:
	if current_checkpoint_index < checkpoints.size():
		return checkpoint_to_check == checkpoints[current_checkpoint_index]
	return false

func compare_checkpoint(checkpoint_to_check : Checkpoint) -> int:
	#returns -1 if checkpoint is before, 1 if it is after, 0 if it is the same
	#returns -2 on error
	if checkpoint_to_check == null || checkpoints.size() < 0:
		return -2
	
	var checkpoint_to_check_index = -1
	for i in checkpoints.size():
		if checkpoints[i] == checkpoint_to_check:
			checkpoint_to_check_index = i
			break
	
	if checkpoint_to_check_index < 0:
		return -2
	
	if  checkpoint_to_check_index < current_checkpoint_index:
		return -1
	
	if  checkpoint_to_check_index == current_checkpoint_index:
		return 0
	
	if  checkpoint_to_check_index > current_checkpoint_index:
		return 1
	
	return -2

func reload_level():
	instantiate_level(current_scene_string)
