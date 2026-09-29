class_name InputPopup

extends Node2D

@export var tutorial_popup : Node2D
@export var movement_popup : Node2D

func _input(event):
	if event.is_action_pressed("open_notebook"):
		show_popup(tutorial_popup, false)
	
	if event.is_action_pressed("move_up") || event.is_action_pressed("move_down"):
		show_popup(movement_popup, false)
	if event.is_action_pressed("move_left") || event.is_action_pressed("move_right"):
		show_popup(movement_popup, false)

func show_popup( popup : Node2D, activate : bool):
	popup.visible = activate

func show_tutorial_popup():
	show_popup(tutorial_popup, true)

func show_movement_popup():
	show_popup(movement_popup, true)

	
