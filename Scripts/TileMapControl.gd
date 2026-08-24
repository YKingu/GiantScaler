class_name TileMapControl

extends Node2D

@export var tilemaps : Array[TileMapLayer]

func get_tile_bool(tile_position : Vector2, tile_data_name : String) -> bool:
	var tile_data = get_tile_data_at_point(tile_position)
	
	if tile_data == null:
		return false
	
	return tile_data.get_custom_data(tile_data_name)

func get_energy_consumption(tile_position : Vector2, movement_direction:String) -> int:
	var propertyName : String = ""
	
	var tile_data = get_tile_data_at_point(tile_position)
	
	if tile_data == null:
		return -100
	
	match movement_direction:
		"move_up":
			propertyName = "climb_up"
		"move_down":
			propertyName = "climb_down"
		"move_left", "move_right":
			propertyName = "climb_sideways"
	
	return tile_data.get_custom_data(propertyName)

func point_is_traversable(tile_position : Vector2) -> bool:
	return get_tile_bool(tile_position, "traversable")

func point_is_floor(tile_position : Vector2) -> bool:
	return get_tile_bool(tile_position, "floor")

func get_special_tile_name(tile_position : Vector2) -> String:
	if !get_tile_bool(tile_position, "special_tile"):
		return ""
	
	var tile_data = get_tile_data_at_point(tile_position)
	
	if tile_data == null:
		return ""
	
	return tile_data.get_custom_data("special_tile_name")

func get_tile_data_at_point(tile_position : Vector2) -> TileData:
	
	var return_data : TileData
	
	for i in range(tilemaps.size() - 1, 0 - 1, -1):
		var cell := tilemaps[i].local_to_map(tile_position)
		return_data = tilemaps[i].get_cell_tile_data(cell)
		if return_data != null:
			break
	
	return return_data

func step_is_traversable(tile_from :Vector2, tile_to :Vector2, movement_direction : String) -> bool:
	
	if( !point_is_traversable(tile_from) )||( !point_is_traversable(tile_to) ):
		return false
	
	#ensures you can't walk sideways from floor to wall
	if movement_direction == "move_left" || movement_direction == "move_right":
		if point_is_floor(tile_from) != point_is_floor(tile_to):
			return false
	
	return true
