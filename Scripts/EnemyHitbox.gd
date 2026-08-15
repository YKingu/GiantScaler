class_name EnemyHitbox

extends CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _physics_process(delta: float) -> void:
	var collision_object = get_last_slide_collision()
	
	if collision_object != null:
		if collision_object.get_collider() is PCBehaviour:
			LevelInfo.main_scene.reload_level()
