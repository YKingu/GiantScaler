class_name PCBehaviour

extends CharacterBody2D

const tile_size : int = 16
const walking_speed = 100.0
const climbing_speed = 75.0
const falling_speed = 400.0
const max_energy = 20

enum Player_State {IDLE, WALKING, CLIMBING, FALLING}
var curr_player_state : Player_State = Player_State.IDLE

var last_tile_position : Vector2 = Vector2.ZERO
var movement_vector : Vector2 = Vector2.ZERO
var movement_direction : String = ""
var curr_energy : int = 0

@export var tilemap : TileMapLayer
@export var energy_label : Label
@export var scream_Image : Node

var movement_inputs = {
	"move_up" = Vector2.UP,
	"move_down" = Vector2.DOWN,
	"move_left" = Vector2.LEFT,
	"move_right" = Vector2.RIGHT,
}

func _ready() -> void:
	last_tile_position = position
	set_energy(max_energy)

func move_step(movement_direction: String) -> bool:
	self.movement_direction = movement_direction
	movement_vector = movement_inputs[movement_direction]
	
	var next_tile_position : Vector2 = last_tile_position + (movement_vector *tile_size)
	
	var tile_data : TileData = get_tile_data_at_point(next_tile_position)
	
	if tile_data == null:
		reset_position_and_speed()
		return false
	
	if tile_data.get_custom_data("walkable"):
		if tile_data.get_custom_data("floor"):
			curr_player_state = Player_State.WALKING
			set_energy(max_energy)
		else:
			curr_player_state = Player_State.CLIMBING
			if tile_data.get_custom_data("special_tile"):
				handle_special_tile_pre(tile_data)
			else:
				var energy_consumption := get_energy_consumption(tile_data, movement_direction)
				set_energy(curr_energy - energy_consumption)
		
	else:
		reset_position_and_speed()
		return false
	
	return true

func _physics_process(delta: float) -> void:
	
	match curr_player_state:
		Player_State.IDLE:
			move_to_input()
		Player_State.WALKING, Player_State.CLIMBING:
			velocity = movement_vector * walking_speed
			if curr_player_state == Player_State.CLIMBING:
				velocity = movement_vector * climbing_speed
			
			var velocity_this_frame: Vector2 = velocity * delta
			var position_next_frame: Vector2 = position + velocity_this_frame
			if (position_next_frame - last_tile_position).length() > tile_size:
				arrive_at_tile(last_tile_position + (movement_vector * tile_size))
			else:
				move_and_slide()
		Player_State.FALLING:
			velocity = falling_speed * Vector2.DOWN
			
			var velocity_this_frame: Vector2 = velocity * delta
			var position_next_frame: Vector2 = position + velocity_this_frame
			if (position_next_frame - last_tile_position).length() > tile_size:
				last_tile_position += Vector2.DOWN * tile_size
				var new_tile_data := get_tile_data_at_point(last_tile_position)
				if new_tile_data.get_custom_data("floor"):
					scream_Image.visible = false
					set_energy(max_energy)
					reset_position_and_speed()
				else:
					move_and_slide()
			else:
				move_and_slide()

func arrive_at_tile(new_tile_position : Vector2):
	last_tile_position = new_tile_position
	if curr_energy <= 0:
		reset_position_and_speed()
		fall_down()
		return
	
	var tile_data = get_tile_data_at_point(new_tile_position)
	
	if tile_data.get_custom_data("special_tile"):
		if handle_special_tile_post(tile_data.get_custom_data("special_tile_name")):
			return
	
	if Input.is_action_pressed(movement_direction):
		if move_step(movement_direction):
			move_and_slide()
	else:
		reset_position_and_speed()

func fall_down():
	scream_Image.visible = true
	curr_player_state = Player_State.FALLING

func reset_position_and_speed():
	position = last_tile_position
	curr_player_state = Player_State.IDLE
	movement_vector = Vector2.ZERO

func move_to_input():
	for movement_input in movement_inputs.keys():
		if Input.is_action_just_pressed(movement_input):
			if move_step(movement_input):
				break
	
	if curr_player_state == Player_State.IDLE:
		for movement_input in movement_inputs.keys():
			if Input.is_action_pressed(movement_input):
				if move_step(movement_input):
					break

func get_tile_data_at_point(cell_data_point : Vector2) -> TileData:
	var cell := tilemap.local_to_map(cell_data_point)
	var return_data : TileData = tilemap.get_cell_tile_data(cell)
	
	return return_data

func get_energy_consumption(tile_data : TileData, ovement_direction:String) -> int:
	var propertyName : String = ""
	match movement_direction:
		"move_up":
			propertyName = "climb_up"
		"move_down":
			propertyName = "climb_down"
		"move_left", "move_right":
			propertyName = "climb_sideways"
			
	return tile_data.get_custom_data(propertyName)

func set_energy(energy : int):
	energy = clamp(energy, 0, max_energy)
	curr_energy = energy
	energy_label.text = str(curr_energy/2.0)

func handle_special_tile_pre(tile_data : TileData):
	
	var special_tile_name : String = tile_data.get_custom_data("special_tile_name")
	var energy_consumption := get_energy_consumption(tile_data, movement_direction)
	
	match special_tile_name:
		"crack_tile":
			var tile_data_of_last_tile := get_tile_data_at_point(last_tile_position)
			if tile_data_of_last_tile.get_custom_data("special_tile_name") == "crack_tile":
				energy_consumption = 0
			set_energy(curr_energy - energy_consumption)
		_:
			set_energy(curr_energy - energy_consumption)

func handle_special_tile_post(special_tile_name : String) -> bool:
	
	#return bool prevents further movement if true
	
	match special_tile_name:
		"slide_tile":
			if movement_direction == "move_down":
				var next_tile_position: Vector2 = last_tile_position + (Vector2.DOWN * tile_size)
				var tile_data = get_tile_data_at_point(next_tile_position)
				if tile_data.get_custom_data("walkable"):
					move_step("move_down")
				else:
					fall_down()
				return true
	
	return false

func reset():
	last_tile_position = position
	curr_player_state = Player_State.IDLE
	movement_vector = Vector2.ZERO
	
