class_name checkpoint

extends Node

@export var check_point_number : int = 1
var save_trigger : Area2D
var prev_checkpoint : int = -1
var next_checkpoint : int = -1

var player_character : PCBehaviour
var respawn_point : Node2D

func _input(event):
	if !is_active():
		return
	
	if event.is_action_pressed("restart_level"):
		get_tree().reload_current_scene()
	if event.is_action_pressed("prev_checkpoint"):
		print("prev")
		load_checkpoint(false)
	if event.is_action_pressed("next_checkpoint"):
		print("next")
		load_checkpoint(true)

func _ready() -> void:
	
	#get reference to player character
	for child in get_tree().root.find_children("*", "", true, false):
		if child is PCBehaviour:
			player_character = child
			break
	
	respawn_point = find_child("RespawnPoint", false) 
	
	if player_character == null or respawn_point == null:
		set_process(false)
	
	# get the area of the save trigger
	for child in get_children():
		if child is Area2D:
			save_trigger = child
			break;
	if save_trigger != null:
		save_trigger.body_entered.connect(activate_checkpoint)
	
	if is_active():
		load_from_this_checkpoint()
	
	get_other_checkpoints()

func get_other_checkpoints():
	
	for child in get_tree().root.find_children("*", "", true, false):
		if child is checkpoint:
			if child.check_point_number < check_point_number:
				if prev_checkpoint == -1 or prev_checkpoint < child.check_point_number:
					prev_checkpoint = child.check_point_number
			if child.check_point_number > check_point_number:
				if next_checkpoint == -1 or next_checkpoint > child.check_point_number:
					next_checkpoint = child.check_point_number

func activate_checkpoint(body: Node2D):
	if LevelInfo.current_checkpoint < check_point_number:
		LevelInfo.current_checkpoint = check_point_number

func load_checkpoint( load_next_checkpoint : bool):
	var checkpoint_to_load = prev_checkpoint
	if load_next_checkpoint:
		checkpoint_to_load = next_checkpoint
	
	print(checkpoint_to_load)
	if checkpoint_to_load > 0:
		LevelInfo.current_checkpoint = checkpoint_to_load
		get_tree().reload_current_scene()

func load_from_this_checkpoint():
	player_character.position = respawn_point.global_position
	player_character.reset()

func is_active() ->bool:
	return LevelInfo.current_checkpoint == check_point_number
