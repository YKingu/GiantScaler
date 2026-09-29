class_name TutorialBooklet

extends Node2D

@export var main_page_node : Node2D
@export var camera : Camera2D
@export var unlocked_pages : int = 0
@export var change_page_tutorial : Node2D
@export var change_page_tutorialL : Node2D
@export var change_page_tutorialR : Node2D

var pages : Array[Node2D]
var last_open_page : int 
var is_active : bool

var tutorial_show_times: int = 2

func _ready() -> void:
	get_pages()
	open_book(false)
	open_page(0)
	if unlocked_pages == 0:
		unlocked_pages = pages.size()

func get_pages():
	pages.assign(main_page_node.get_children())

func _input(event):
	
	if event.is_action_pressed("open_notebook"):
		open_book(!is_active)
	
	if is_active:
		if event.is_action_pressed("notebook_next_page"):
			open_page(last_open_page + 1)
		if event.is_action_pressed("notebook_prev_page"):
			open_page(last_open_page - 1)

func open_book( open_book : bool):
	
	change_page_tutorial.visible = false
	
	if open_book:
		for i in tutorial_show_times:
			var tutorial_show_string = "booklet_tutorial" + str(i)
			if !static_fields.check_custom_field(tutorial_show_string):
				change_page_tutorial.visible = true
				static_fields.add_custom_field(tutorial_show_string)
				break
	
	visible = open_book
	is_active = open_book
	get_tree().paused = open_book

func open_page(page_number : int):
	
	var max_page : int = min(pages.size(), unlocked_pages)
	
	if pages.size() <= 0:
		return
	
	page_number = clamp(page_number,0, max_page - 1 )
	
	for i in pages.size():
		pages[i].visible = false
	
	pages[page_number].visible = true
	last_open_page = page_number
	
	change_page_tutorialR.visible = !page_number == max_page -1
	change_page_tutorialL.visible = !page_number == 0

func unlock_page(page_number : int):
	
	if unlocked_pages < page_number:
		unlocked_pages = page_number
		for i in tutorial_show_times:
			var tutorial_show_string = "booklet_tutorial" + str(i)
			static_fields.remove_custom_field(tutorial_show_string)
	
	open_page(page_number - 1)
