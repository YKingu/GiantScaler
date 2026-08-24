class_name PCBehaviour

extends CharacterBody2D

const tile_size : int = 16
const walking_speed := 100.0
const climbing_speed := 75.0
const falling_speed := 400.0
const max_energy := 20
const tile_position_walking_offset := Vector2(0,-7)

enum Player_State {IDLE, WALKING, CLIMBING, FALLING, FLAT}
var curr_player_state : Player_State = Player_State.IDLE
var movement_forced := false

var last_tile_position : Vector2 = Vector2.ZERO
var tile_position_offset : Vector2 = Vector2.ZERO
var movement_vector : Vector2 = Vector2.ZERO
var movement_direction : String = ""
var curr_energy : int = 0

@export var tilemap_control : TileMapControl
@export var energy_label : Label
@export var sprite_animation : AnimatedSprite2D
@export var camera : Camera2D
@export var energy_display : EnergyDisplay

var fall_start_tile_position : Vector2 = Vector2.ZERO

var movement_inputs = {
	"move_up" = Vector2.UP,
	"move_down" = Vector2.DOWN,
	"move_left" = Vector2.LEFT,
	"move_right" = Vector2.RIGHT,
}

func _ready() -> void:
	static_fields.player_character = self
	reset()

func _physics_process(delta: float) -> void:
	
	if curr_player_state == Player_State.IDLE:
		move_to_input()
	
	if curr_player_state != Player_State.FALLING && curr_player_state != Player_State.FLAT:
		camera.position = self.position
		
	handle_animation()
	handle_energy_display_visibility()

func move_to_input():
	if curr_player_state == Player_State.IDLE:
		for movement_input in movement_inputs.keys():
			if Input.is_action_pressed(movement_input):
				if move_step(movement_input):
					break

func move_step(new_movement_direction: String) -> bool:
	
	var new_movement_vector : Vector2 = movement_inputs[new_movement_direction]
	
	var next_tile_position : Vector2 = last_tile_position + (new_movement_vector *tile_size)
	
	#can't move to empty tile
	if !tilemap_control.step_is_traversable(last_tile_position, next_tile_position, new_movement_direction):
		reset_position_and_speed()
		return false
	
	if tilemap_control.point_is_traversable(next_tile_position):
		
		#set new movement direction
		movement_direction = new_movement_direction
		movement_vector = new_movement_vector
		
		if tilemap_control.point_is_floor(next_tile_position):
			curr_player_state = Player_State.WALKING
			set_energy(max_energy)
			move_coroutine(next_tile_position, walking_speed)
		else:
			curr_player_state = Player_State.CLIMBING
			move_coroutine(next_tile_position, climbing_speed)
		
	else:
		reset_position_and_speed()
		return false
	
	return true

func move_coroutine(next_tile_position : Vector2, movement_speed : float):
	
	set_position_offset(next_tile_position)
	
	var destination := next_tile_position + tile_position_offset
	var distance_to_destination : Vector2 = destination - position
	var delta_speed : float = get_physics_process_delta_time() * movement_speed
	var local_movement_forced := movement_forced
	
	var i := 0
	
	while( distance_to_destination.length() > delta_speed ):
		
		#two frames of bullet time, to cancel input so you don't climb automatically
		if i <= 2:
			if !local_movement_forced && curr_player_state == Player_State.CLIMBING:
				if !Input.is_action_pressed(movement_direction):
					reset_position_and_speed()
					return
			if i == 2:
				handle_tile_behaviour(next_tile_position)
		
		velocity = (destination - position).normalized() * movement_speed
		move_and_slide()
		await get_tree().physics_frame
		delta_speed = get_physics_process_delta_time() * movement_speed
		distance_to_destination = destination - position
		i+=1
	
	arrive_at_tile(next_tile_position)

func handle_tile_behaviour(next_tile_position : Vector2):
	
	var special_tile_name := tilemap_control.get_special_tile_name(next_tile_position)
	
	if special_tile_name != "":
		handle_special_tile_pre(next_tile_position, special_tile_name)
	else:
		var energy_consumption := tilemap_control.get_energy_consumption(next_tile_position, movement_direction)
		set_energy(curr_energy - energy_consumption)

func arrive_at_tile(new_tile_position : Vector2):
	
	set_last_tile_position( new_tile_position )
	
	if curr_player_state == Player_State.FALLING:
		if tilemap_control.point_is_floor(new_tile_position):
			set_energy(max_energy)
			movement_forced = false
			reset_position_and_speed()
			move_camera_coroutine()
		else:
			move_coroutine(last_tile_position + (Vector2.DOWN * tile_size), falling_speed)
			if abs((fall_start_tile_position - last_tile_position).y) > 9 * tile_size:
				die()
		return
	
	if curr_energy <= 0:
		reset_position_and_speed()
		camera.position = position
		fall_down()
		return
	
	var special_tile_name := tilemap_control.get_special_tile_name(new_tile_position)
	
	if special_tile_name != "":
		if handle_special_tile_post(new_tile_position, special_tile_name):
			return
	
	#only reset speed, if you arent proceeding in the same direction
	if movement_direction != "":
		if Input.is_action_pressed(movement_direction):
			move_step(movement_direction)
		else:
			reset_position_and_speed()
	else:
		reset_position_and_speed()

func move_camera_coroutine():
	var camera_movement_speed := 300.0
	curr_player_state = Player_State.FLAT
	
	while (position - camera.position).y > get_physics_process_delta_time() * camera_movement_speed:
		camera.move_local_y(get_physics_process_delta_time() * camera_movement_speed)
		await get_tree().physics_frame
	
	reset_position_and_speed()

func handle_energy_display_visibility():
	if tilemap_control.point_is_floor(self.position):
		energy_display.visible = false
	else:
		energy_display.visible = true

func handle_animation():
	match curr_player_state:
		Player_State.IDLE:
			if tilemap_control.point_is_floor(self.position):
				change_animation_if_different("Idle")
			else:
				change_animation_if_different("ClimbIdle")
		Player_State.WALKING:
			change_animation_if_different("Idle")
		Player_State.CLIMBING:
			change_animation_if_different("Climb")
		Player_State.FALLING:
			change_animation_if_different("Falling")
		Player_State.FLAT:
			change_animation_if_different("Idle")

func change_animation_if_different(new_animation: String):
	
	if sprite_animation.animation != new_animation:
		sprite_animation.animation = new_animation
		sprite_animation.play()

func fall_down():
	fall_start_tile_position = last_tile_position
	curr_player_state = Player_State.FALLING
	movement_forced = true
	move_coroutine(last_tile_position + (Vector2.DOWN * tile_size), falling_speed)

func reset_position_and_speed():
	set_position_offset(last_tile_position)
	position = last_tile_position + tile_position_offset
	curr_player_state = Player_State.IDLE
	movement_vector = Vector2.ZERO

func set_energy(energy : int):
	energy = clamp(energy, 0, max_energy)
	energy_display.set_energy(energy)
	curr_energy = energy
	energy_label.text = str(curr_energy/2.0)

func handle_special_tile_pre(tile_location : Vector2, special_tile_name : String):
	
	var energy_consumption := tilemap_control.get_energy_consumption(tile_location, movement_direction)
	
	match special_tile_name:
		"crack_tile":
			if tilemap_control.get_special_tile_name(last_tile_position) == "crack_tile":
				energy_consumption = 0
			set_energy(curr_energy - energy_consumption)
		_:
			set_energy(curr_energy - energy_consumption)

func handle_special_tile_post(tile_location : Vector2, special_tile_name : String) -> bool:
	
	#return bool prevents further input movement if true
	match special_tile_name:
		"slide_tile":
			if movement_direction == "move_down":
				var next_tile_position: Vector2 = last_tile_position + (Vector2.DOWN * tile_size)
				if tilemap_control.point_is_traversable(next_tile_position):
					movement_forced = true
					move_step("move_down")
					movement_forced = false
				else:
					fall_down()
				return true
	
	return false

func reset():
	#resets playercharacter
	set_last_tile_position(position)
	curr_player_state = Player_State.IDLE
	movement_vector = Vector2.ZERO
	set_energy(max_energy)
	set_position_offset(last_tile_position)
	arrive_at_tile(last_tile_position)

func set_position_offset(offset_at : Vector2):
	if tilemap_control.point_is_floor(offset_at):
		tile_position_offset = tile_position_walking_offset
	else:
		tile_position_offset = Vector2.ZERO

func die():
	static_fields.main_scene.reload_level()

func set_last_tile_position(new_position : Vector2):
	#makes sure the tile position is always in the grid
	last_tile_position = align_coordinates_to_grid(new_position)

func align_coordinates_to_grid(coordinates : Vector2) -> Vector2:
	#aligns coordinate, so they are in the middle of a grid square
	
	coordinates.x = align_number_to_grid(coordinates.x)
	coordinates.y = align_number_to_grid(coordinates.y)
	
	return coordinates

func align_number_to_grid(number : float) -> float:
	#aligns number, so it is a coordinate in the middle of a grid square
	var rest_number := fposmod( number, tile_size )
	rest_number -= (tile_size * 1.0) / 2.0
	
	return number - rest_number
