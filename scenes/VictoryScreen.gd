extends Control

# Victory screen - shown after player wins a fight

func _ready():
	var opponent = RoundFlow.get_current_opponent()
	var mode = RoundFlow.current_mode
	
	$VBoxContainer/VictoryLabel.text = "VICTORY!"
	$VBoxContainer/OpponentLabel.text = "You defeated %s" % _get_opponent_name(opponent)
	
	if RoundFlow.is_final_round():
		$VBoxContainer/NextLabel.text = "%s circuit complete!" % mode.to_upper()
	else:
		$VBoxContainer/NextLabel.text = "Next: %s" % _get_next_opponent_name()
	
	$VBoxContainer/ContinueButton.pressed.connect(_on_continue)

func _get_opponent_name(opponent: String) -> String:
	match opponent:
		"dusty": return "Dusty"
		"wes": return "Whirlwind Wes"
		"kaine": return "King Kaine"
	return ""

func _get_next_opponent_name() -> String:
	var next_idx = RoundFlow.current_opponent_index + 1
	if next_idx < RoundFlow.opponents.size():
		return _get_opponent_name(RoundFlow.opponents[next_idx])
	return "???"

func _on_continue():
	RoundFlow.on_victory(RoundFlow.get_current_opponent())