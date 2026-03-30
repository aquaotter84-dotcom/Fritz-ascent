extends Control

# Circuit complete screen - shown when player beats all three opponents in a mode

func _ready():
	var mode = RoundFlow.current_mode
	
	$VBoxContainer/TitleLabel.text = "%s CIRCUIT COMPLETE!" % mode.to_upper()
	$VBoxContainer/MessageLabel.text = _get_completion_message(mode)
	
	$VBoxContainer/NextModeButton.pressed.connect(_on_next_mode)
	$VBoxContainer/MenuButton.pressed.connect(_on_menu)

func _get_completion_message(mode: String) -> String:
	match mode:
		"main_circuit":
			return "You've learned to read the patterns.
World Circuit unlocked."
		"world_circuit":
			return "You've proven your mastery.
Title Defense unlocked."
		"title_defense":
			return "You are the undefeated champion.
The belt is yours."
	return ""

func _on_next_mode():
	get_tree().change_scene_to_file("res://scenes/ModeSelect.tscn")

func _on_menu():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")