extends Node

enum Attack { LEFT_JAB, RIGHT_JAB, HAYMAKER, BODY_BLOW }

var stamina := 100
var knockdowns := 0
var current_attack : Attack = Attack.LEFT_JAB
var vulnerable := false
var exchange_count := 0

func begin_fight() -> void:
	choose_next_attack()

func choose_next_attack() -> void:
	exchange_count += 1
	vulnerable = false
	if knockdowns > 0:
		current_attack = Attack.HAYMAKER
	elif exchange_count % 3 == 0:
		current_attack = Attack.HAYMAKER
	elif exchange_count % 2 == 0:
		current_attack = Attack.RIGHT_JAB
	else:
		current_attack = Attack.LEFT_JAB

func resolve_player_defense(direction: String) -> String:
	match current_attack:
		Attack.LEFT_JAB:
			if direction == "right":
				vulnerable = true
				choose_next_attack()
				return "safe_dodge"
		Attack.RIGHT_JAB:
			if direction == "left":
				vulnerable = true
				choose_next_attack()
				return "safe_dodge"
		Attack.HAYMAKER:
			if direction in ["left", "right", "duck"]:
				vulnerable = true
				choose_next_attack()
				return "perfect_haymaker_dodge"
		Attack.BODY_BLOW:
			if direction == "block_low":
				vulnerable = true
				choose_next_attack()
				return "safe_dodge"
	choose_next_attack()
	return "hit"

func is_vulnerable() -> bool:
	return vulnerable

func take_counter_hit() -> void:
	stamina -= 12
	_check_knockdown()

func take_star_hit() -> void:
	stamina -= 25
	_check_knockdown()

func _check_knockdown() -> void:
	if stamina <= 0:
		knockdowns += 1
		stamina = 55 if knockdowns < 2 else 35