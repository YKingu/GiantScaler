
class_name StaticFields

extends Node

var custom_field_list : Array[String]

var main_scene :MainScene
var player_character :PCBehaviour

func add_custom_field(custom_field : String):
	if custom_field_list.has(custom_field):
		return
	
	custom_field_list.append(custom_field)

func remove_custom_field(custom_field : String):
	custom_field_list.erase(custom_field)

func check_custom_field(custom_field : String) -> bool:
	return custom_field_list.has(custom_field)
