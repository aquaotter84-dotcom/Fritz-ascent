extends Control

# Fight intro screen - displays opponent info and personality before each match

func _ready():
	var opponent = RoundFlow.get_current_opponent()
	var mode = RoundFlow.current_mode
	var round_num = RoundFlow.current_round + 1
	
	$VBoxContainer/Title.text = "Round %d" % round_num
	$VBoxContainer/OpponentName.text = _get_opponent_display_name(opponent)
	$VBoxContainer/OpponentNickname.text = _get_opponent_nickname(opponent)
	$VBoxContainer/OpponentStats.text = _get_opponent_flavor(opponent, mode)
	
	$VBoxContainer/StartButton.pressed.connect(_on_start_fight)

func _get_opponent_display_name(opponent: String) -> String:
	match opponent:
		"dusty": return "Dusty Dale Harmon"
		"wes": return "Whirlwind Wes"
		"kaine": return "King Kaine Striker"
	return ""

func _get_opponent_nickname(opponent: String) -> String:
	match opponent:
		"dusty": return "The Rust-Bucket Veteran"
		"wes": return "High-Speed Momentum Fighter"
		"kaine": return "The Undefeated Champion"
	return ""

func _get_opponent_flavor(opponent: String, mode: String) -> String:
	var base = ""
	match opponent:
		"dusty":
			base = "An aging local boxer who should've retired years ago.
Heavy, slow, predictable—but dangerous if he lands."
		"wes":
			base = "Hyperactive, cocky, relentless jabs and spins.
His speed is his weapon—but his spin leaves him vulnerable."
		"kaine":
			base = "The undefeated heavyweight champion.
Fast, precise, relentless pressure. The ultimate test."
	
	if mode == "world_circuit":
		base += "
[REMATCH] This time, they're faster and meaner."
	elif mode == "title_defense":
		base += "
[TITLE DEFENSE] They've studied you. New tricks. Everything on the line."
	
	return base

func _on_start_fight():
	# Load the main fight scene with the current opponent
	var opponent = RoundFlow.get_current_opponent()
	var scene_path = "res://scenes/Fight_%s.tscn" % opponent
	get_tree().change_scene_to_file(scene_path)