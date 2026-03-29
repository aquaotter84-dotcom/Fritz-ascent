extends Node

# Signals for the AnimationPlayer or Sprite to hook into
signal animation_requested(anim_name: String)

enum Attack { LEFT_JAB, RIGHT_JAB, HAYMAKER, BODY_BLOW }

var stamina := 100
var knockdowns := 0
var current_attack : Attack = Attack.LEFT_JAB
var vulnerable := false
var exchange_count := 0

func begin_fight() -> void:
	emit_signal("animation_requested", "idle")
	choose_next_attack()

func choose_next_attack() -> void:
	exchange_count += 1
	vulnerable = false
	
	# Determine next move
	if knockdowns > 0:
		current_attack = Attack.HAYMAKER
	elif exchange_count % 3 == 0:
		current_attack = Attack.HAYMAKER
	elif exchange_count % 2 == 0:
		current_attack = Attack.RIGHT_JAB
	else:
		current_attack = Attack.LEFT_JAB
	
	_telegraph_attack()

func _telegraph_attack() -> void:
	# dusty's readable tells
	match current_attack:
		Attack.LEFT_JAB:
			emit_signal("animation_requested", "telegraph_left_jab")
			await get_tree().create_timer(0.8).timeout # Dusty is slow
			emit_signal("animation_requested", "punch_left_jab")
		Attack.RIGHT_JAB:
			emit_signal("animation_requested", "telegraph_right_jab")
			await get_tree().create_timer(0.8).timeout
			emit_signal("animation_requested", "punch_right_jab")
		Attack.HAYMAKER:
			emit_signal("animation_requested", "telegraph_haymaker")
			await get_tree().create_timer(1.2).timeout # The big wind-up
			emit_signal("animation_requested", "punch_haymaker")
		Attack.BODY_BLOW:
			emit_signal("animation_requested", "telegraph_body_blow")
			await get_tree().create_timer(0.9).timeout
			emit_signal("animation_requested", "punch_body_blow")

func resolve_player_defense(direction: String) -> String:
	match current_attack:
		Attack.LEFT_JAB:
			if direction == "right":
				vulnerable = true
				emit_signal("animation_requested", "missed_punch")
				return "safe_dodge"
		Attack.RIGHT_JAB:
			if direction == "left":
				vulnerable = true
				emit_signal("animation_requested", "missed_punch")
				return "safe_dodge"
		Attack.HAYMAKER:
			if direction in ["left", "right", "duck"]:
				vulnerable = true
				emit_signal("animation_requested", "staggered")
				return "perfect_haymaker_dodge"
		Attack.BODY_BLOW:
			if direction == "block_low":
				vulnerable = true
				emit_signal("animation_requested", "blocked")
				return "safe_dodge"
	
	emit_signal("animation_requested", "successful_hit")
	choose_next_attack()
	return "hit"

func take_counter_hit() -> void:
	stamina -= 12
	emit_signal("animation_requested", "hit_light")
	_check_knockdown()

func take_star_hit() -> void:
	stamina -= 25
	emit_signal("animation_requested", "hit_heavy")
	_check_knockdown()

func _check_knockdown() -> void:
	if stamina <= 0:
		knockdowns += 1
		stamina = 55 if knockdowns < 2 else 35
		emit_signal("animation_requested", "knockdown")
		if knockdowns >= 3:
			emit_signal("animation_requested", "tko")
	else:
		choose_next_attack()
