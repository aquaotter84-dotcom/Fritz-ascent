extends Node

# Global round flow manager
# Tracks current mode, round, and opponent progression

var current_mode = "main_circuit"  # main_circuit, world_circuit, title_defense
var current_round = 0
var opponents = ["dusty", "wes", "kaine"]
var current_opponent_index = 0

func _ready():
	add_to_group("singletons")

func set_mode(mode: String):
	current_mode = mode
	current_round = 0
	current_opponent_index = 0

func get_current_opponent() -> String:
	return opponents[current_opponent_index]

func advance_round():
	current_opponent_index += 1
	current_round += 1

func is_final_round() -> bool:
	return current_opponent_index >= opponents.size()

func on_victory(opponent: String):
	# Log win, unlock next mode if needed, advance to next opponent
	print("Victory over %s in %s mode" % [opponent, current_mode])
	advance_round()
	
	if is_final_round():
		# Mode complete
		_unlock_next_mode()
		get_tree().change_scene_to_file("res://scenes/CircuitComplete.tscn")
	else:
		# Next fight
		get_tree().change_scene_to_file("res://scenes/FightIntro.tscn")

func on_defeat(opponent: String):
	# Retry or return to mode select
	print("Defeat by %s in %s mode" % [opponent, current_mode])
	get_tree().change_scene_to_file("res://scenes/DefeatScreen.tscn")

func _unlock_next_mode():
	# Save unlock state
	if current_mode == "main_circuit":
		# Unlock world circuit
		pass
	elif current_mode == "world_circuit":
		# Unlock title defense
		pass

func restart_circuit():
	current_opponent_index = 0
	current_round = 0