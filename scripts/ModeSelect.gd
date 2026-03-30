extends Control

# Mode select screen
# Allows player to choose: Main Circuit, World Circuit (unlocked after beating main), Title Defense (unlocked after World)

var main_circuit_unlocked = true
var world_circuit_unlocked = false  # Unlocked after beating Main Circuit
var title_defense_unlocked = false  # Unlocked after beating World Circuit

func _ready():
	_load_unlock_state()
	
	$VBoxContainer/MainCircuitButton.pressed.connect(_on_main_circuit)
	$VBoxContainer/WorldCircuitButton.pressed.connect(_on_world_circuit)
	$VBoxContainer/TitleDefenseButton.pressed.connect(_on_title_defense)
	$VBoxContainer/BackButton.pressed.connect(_on_back)
	
	# Update button disabled states
	$VBoxContainer/WorldCircuitButton.disabled = not world_circuit_unlocked
	$VBoxContainer/TitleDefenseButton.disabled = not title_defense_unlocked

func _load_unlock_state():
	# Load from save file (PlayerData.save or similar)
	# For now: placeholder
	pass

func _on_main_circuit():
	RoundFlow.set_mode("main_circuit")
	get_tree().change_scene_to_file("res://scenes/FightIntro.tscn")

func _on_world_circuit():
	if not world_circuit_unlocked:
		print("World Circuit locked - beat Main Circuit first!")
		return
	RoundFlow.set_mode("world_circuit")
	get_tree().change_scene_to_file("res://scenes/FightIntro.tscn")

func _on_title_defense():
	if not title_defense_unlocked:
		print("Title Defense locked - beat World Circuit first!")
		return
	RoundFlow.set_mode("title_defense")
	get_tree().change_scene_to_file("res://scenes/FightIntro.tscn")

func _on_back():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")