class_name checkpoint

extends Node

@export var check_point_number : int = 1
var save_trigger : Area2D
var prev_checkpoint : int = -1
var next_checkpoint : int = -1

var player_character : PCBehaviour
var respawn_point : Node2D

@export var sprite_active : Node2D
@export var sprite_inactive : Node2D

var main_scene : MainScene

func _input(event):
	if !is_active():
		return
	
	if event.is_action_pressed("restart_level"):
		LevelInfo.main_scene.reload_level()
	if event.is_action_pressed("prev_checkpoint"):
		print("action pressed prev")
		load_checkpoint(false)
	if event.is_action_pressed("next_checkpoint"):
		load_checkpoint(true)

func _ready() -> void:
	
	print(is_active())
	print(LevelInfo.current_checkpoint)
	#get reference to player character
	#for child in get_tree().root.find_children("*", "", true, false):
	#	if child is PCBehaviour:
	#		player_character = child
	#		break
	
	set_sprite_active()
	get_other_checkpoints()
	
	if LevelInfo.player_character == null:
		print("waiting..")
		await get_tree().process_frame
	
	player_character = LevelInfo.player_character
	
	respawn_point = find_child("RespawnPoint", false) 
	
	if player_character == null or respawn_point == null:
		set_process(false)
		return
	
	# get the area of the save trigger
	for child in get_children():
		if child is Area2D:
			save_trigger = child
			break;
	if save_trigger != null:
		save_trigger.body_entered.connect(activate_checkpoint)
	
	if is_active():
		load_from_this_checkpoint()
	

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
	
	set_sprite_active()

func load_checkpoint( load_next_checkpoint : bool):
	print("checkpoint loaded")
	print(check_point_number)
	print("checkpoint loaded")

	
	var checkpoint_to_load = prev_checkpoint
	if load_next_checkpoint:
		checkpoint_to_load = next_checkpoint
	
	if checkpoint_to_load > 0:
		LevelInfo.current_checkpoint = checkpoint_to_load
		LevelInfo.main_scene.reload_level()

func load_from_this_checkpoint():
	
	player_character.position = respawn_point.global_position
	player_character.reset()

func is_active() ->bool:
	return LevelInfo.current_checkpoint == check_point_number

func set_sprite_active():
	var temp_bool : bool = LevelInfo.current_checkpoint >= check_point_number
	sprite_active.visible = temp_bool
	sprite_inactive.visible = !temp_bool
	
