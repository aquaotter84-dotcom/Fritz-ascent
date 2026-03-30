extends Control

# Defeat screen - shown after player loses a fight

func _ready():
	var opponent = RoundFlow.get_current_opponent()
	
	$VBoxContainer/DefeatLabel.text = "KNOCKOUT"
	$VBoxContainer/OpponentLabel.text = "You were defeated by %s" % _get_opponent_name(opponent)
	$VBoxContainer/MessageLabel.text = "Back to training?"
	
	$VBoxContainer/RetryButton.pressed.connect(_on_retry)
	$VBoxContainer/ModeSelectButton.pressed.connect(_on_mode_select)

func _get_opponent_name(opponent: String) -> String:
	match opponent:
		"dusty": return "Dusty"
		"wes": return "Whirlwind Wes"
		"kaine": return "King Kaine"
	return ""

func _on_retry():
	# Restart same fight (resets opponent, keeps mode)
	get_tree().change_scene_to_file("res://scenes/FightIntro.tscn")

func _on_mode_select():
	RoundFlow.restart_circuit()
	get_tree().change_scene_to_file("res://scenes/ModeSelect.tscn")