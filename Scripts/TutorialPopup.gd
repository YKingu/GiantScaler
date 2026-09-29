class_name TutorialPopup

extends Area2D

@export var tutorial_booklet : TutorialBooklet
@export var input_popup : InputPopup
@export var tutorial_booklet_page : int = 0

var is_active : bool = true
var activation_field

enum Tutorial_Type {Book, Move}
@export var curr_tutorial_type : Tutorial_Type = Tutorial_Type.Book


func _ready() -> void:
	activation_field = str(curr_tutorial_type) + "TutorialPopup" + str(tutorial_booklet_page)
	
	is_active = !static_fields.check_custom_field(activation_field)
	body_entered.connect(player_entered)

func player_entered(body : Node2D):
	if !is_active:
		return
	
	if body is PCBehaviour:
		if curr_tutorial_type == Tutorial_Type.Book:
			tutorial_booklet.unlock_page(tutorial_booklet_page)
			input_popup.show_tutorial_popup()
		if curr_tutorial_type == Tutorial_Type.Move:
			input_popup.show_movement_popup()
		
		static_fields.add_custom_field(activation_field)
		is_active = false
