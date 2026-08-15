extends Node2D

var startpoint : Vector2
var chase_player : bool = false
var playerNode : Node2D

@export var trigger_area : Area2D
@export var spider_character_body : CharacterBody2D
@export var speed : float = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startpoint = spider_character_body.global_position
	trigger_area.body_entered.connect(trigger_body_entered)
	trigger_area.body_exited.connect(trigger_body_exited)

func trigger_body_entered(body: Node2D ):
	if body is PCBehaviour:
		chase_player = true
		playerNode = body

func trigger_body_exited(body: Node2D ):
	if body is PCBehaviour:
		chase_player = false

func _physics_process(delta: float) -> void:
	var movementVector : Vector2 = Vector2.ZERO
	
	if chase_player:
		movementVector = (playerNode.global_position - spider_character_body.global_position).normalized()
	else:
		if (startpoint - spider_character_body.global_position).length() < .1:
			return
		movementVector = (startpoint - spider_character_body.global_position).normalized()
	spider_character_body.velocity = movementVector * speed
	spider_character_body.move_and_slide()
	var collision_object = spider_character_body.get_last_slide_collision()
	
	if collision_object != null:
		if collision_object.get_collider() is PCBehaviour:
			LevelInfo.main_scene.reload_level()
