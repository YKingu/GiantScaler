class_name EnergyDisplay

extends Node2D

@export var sprite_small_reference : Sprite2D
@export var sprite_big_reference : Sprite2D

@export var energy_sprites : Array[Sprite2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if energy_sprites.size() < 10:
		print("Energy Display Configured Incorrectly")
		set_process(false)
		return

func set_energy(new_energy : int):
	new_energy = clamp(new_energy, 0, 20)
	var whole_energies : int = new_energy / 2
	var rest_energy : int = new_energy % 2
	
	for i in range(10):
		if i < whole_energies:
			energy_sprites[i].texture = sprite_big_reference.texture
			energy_sprites[i].visible = true
		else:
			energy_sprites[i].visible = false
	
	if whole_energies < 10 && rest_energy > 0:
		energy_sprites[whole_energies].texture = sprite_small_reference.texture
		energy_sprites[whole_energies].visible = true
