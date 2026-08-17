class_name Checkpoint

extends Node

@export var check_point_number : int = 1
var save_trigger : Area2D
var respawn_point : Node2D

@export var sprite_active : Node2D
@export var sprite_inactive : Node2D

var main_scene : MainScene

func _ready() -> void:
	
	main_scene = static_fields.main_scene 
	respawn_point = find_child("RespawnPoint", false) 
	
	if respawn_point == null:
		set_process(false)
		return
	
	# get the area of the save trigger
	for child in get_children():
		if child is Area2D:
			save_trigger = child
			break;
	
	if save_trigger != null:
		save_trigger.body_entered.connect(activate_checkpoint)

func activate_checkpoint(body: Node2D):
	main_scene.set_checkpoint(self)
	set_sprite_active()

func load_from_this_checkpoint():
	
	var player_character : PCBehaviour
	
	if static_fields.player_character == null:
		await get_tree().process_frame
	
	player_character = static_fields.player_character
	
	if player_character == null:
		return
	
	player_character.position = respawn_point.global_position
	player_character.reset()

func is_active() ->bool:
	return main_scene.checkpoint_is_active(self)

func set_sprite_active():
	var temp_int := main_scene.compare_checkpoint(self)
	
	var temp_bool : bool = temp_int == 0 || temp_int == -1
	sprite_active.visible = temp_bool
	sprite_inactive.visible = !temp_bool
