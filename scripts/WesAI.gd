extends Node

# Whirlwind Wes: The High-Speed Momentum Fighter
signal animation_requested(anim_name: String)

enum Attack { JAB_FLURRY, SPIN_ATTACK, QUICK_LEFT, QUICK_RIGHT }

var stamina := 120
var current_attack : Attack = Attack.QUICK_LEFT
var flurry_count := 0
var vulnerable := false

func begin_fight() -> void:
	emit_signal("animation_requested", "idle_bouncing")
	choose_next_attack()

func choose_next_attack() -> void:
	vulnerable = false
	var rand = randf()
	
	if rand < 0.2:
		current_attack = Attack.SPIN_ATTACK
	elif rand < 0.5:
		current_attack = Attack.JAB_FLURRY
		flurry_count = 3
	elif rand < 0.75:
		current_attack = Attack.QUICK_LEFT
	else:
		current_attack = Attack.QUICK_RIGHT
	
	_execute_attack()

func _execute_attack() -> void:
	match current_attack:
		Attack.QUICK_LEFT:
			emit_signal("animation_requested", "telegraph_quick_left")
			await get_tree().create_timer(0.4).timeout # Fast!
			emit_signal("animation_requested", "punch_left")
		Attack.QUICK_RIGHT:
			emit_signal("animation_requested", "telegraph_quick_right")
			await get_tree().create_timer(0.4).timeout
			emit_signal("animation_requested", "punch_right")
		Attack.JAB_FLURRY:
			_run_flurry()
		Attack.SPIN_ATTACK:
			emit_signal("animation_requested", "telegraph_spin")
			await get_tree().create_timer(0.6).timeout
			emit_signal("animation_requested", "punch_spin_heavy")

func _run_flurry() -> void:
	for i in range(flurry_count):
		emit_signal("animation_requested", "jab_rapid")
		await get_tree().create_timer(0.3).timeout
	choose_next_attack()

func resolve_player_defense(direction: String) -> String:
	match current_attack:
		Attack.QUICK_LEFT:
			if direction == "right": return _dodge()
		Attack.QUICK_RIGHT:
			if direction == "left": return _dodge()
		Attack.SPIN_ATTACK:
			if direction == "duck": 
				vulnerable = true # Wes gets dizzy if he misses the spin
				emit_signal("animation_requested", "dizzy_stun")
				return "perfect_dodge"
		Attack.JAB_FLURRY:
			if direction == "block_low": return _dodge()
	
	emit_signal("animation_requested", "taunt_laugh")
	choose_next_attack()
	return "hit"

func _dodge() -> String:
	vulnerable = true
	emit_signal("animation_requested", "frustrated")
	return "safe_dodge"

func take_hit(damage: int) -> void:
	stamina -= damage
	if vulnerable: stamina -= 10 # Bonus damage while dizzy/frustrated
	emit_signal("animation_requested", "hit_impact")
	if stamina <= 0:
		emit_signal("animation_requested", "knockdown")
	else:
		choose_next_attack()
