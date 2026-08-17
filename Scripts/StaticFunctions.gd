class_name StaticFunctions

extends Node


func get_all_child_nodes(node : Node) -> Array[Node]:
	
	var return_array := node.get_children()
	
	for child in node.get_children():
		if child.get_child_count() > 0:
			return_array.append_array(get_all_child_nodes(child))
	
	return return_array
