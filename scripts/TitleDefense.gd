extends Node

# ============================================================
# TitleDefense.gd
# Fritz's Ascent - Title Defense Mode
#
# Fritz is now the champion. They're coming for him.
# All three opponents return with REVENGE builds:
#   - New signature moves not in Main or World Circuit
#   - They've studied Fritz — they bait his counters
#   - No carries: Fritz starts each defense fresh (no star bank)
#   - Stamina is champion-tier across the board
# ============================================================

signal defense_complete
signal defense_failed

var defense_order := ["Dusty_Revenge", "Wes_Revenge", "Kaine_Revenge"]
var current_defense_index := 0
var title_defenses_won := 0

const TITLE_DIFFICULTY := {
	"tell_speed_multiplier": 0.50,     # Tells are 50% faster — near-instant reads required
	"counter_window_multiplier": 0.55,  # Counter windows are very tight
	"stamina_multiplier": 1.65,         # 65% more HP — these are revenge-fueled
	"bait_counter_chance": 0.45         # They fake vulnerabilities to trap Fritz
}

func start_defense():
	current_defense_index = 0
	title_defenses_won = 0
	print("[TitleDefense] They're coming for the belt. Dusty. Wes. Kaine. In that order.")
	_load_next_challenger()

func _load_next_challenger():
	if current_defense_index >= defense_order.size():
		_on_defense_complete()
		return

	var name = defense_order[current_defense_index]
	print("[TitleDefense] Challenger %d: %s" % [current_defense_index + 1, name])

	match name:
		"Dusty_Revenge":
			_start_dusty_revenge()
		"Wes_Revenge":
			_start_wes_revenge()
		"Kaine_Revenge":
			_start_kaine_revenge()

# ─────────────────────────────────────────────
# DUSTY - Title Defense "The Last Stand"
#
# Dusty is DONE being embarrassed. He's been training
# for nothing but this rematch. New move: The Desperation
# Double — two haymakers back-to-back with a half-second gap.
# Counter after the first and you eat the second.
# Wait for the second, and there's a punish window.
# ─────────────────────────────────────────────
func _start_dusty_revenge():
	var dusty = load("res://scripts/DustyAI.gd").new()
	dusty.stamina_max = int(dusty.stamina_max * TITLE_DIFFICULTY["stamina_multiplier"])
	dusty.tell_duration = dusty.tell_duration * TITLE_DIFFICULTY["tell_speed_multiplier"]
	dusty.counter_window = dusty.counter_window * TITLE_DIFFICULTY["counter_window_multiplier"]

	# Title Defense exclusive
	dusty.revenge_mode = true
	dusty.double_haymaker_enabled = true     # The Desperation Double
	dusty.baits_counter_after_jab = true     # Lets Fritz counter, then fires immediately

	dusty.connect("fight_over", self, "_on_defense_over")
	add_child(dusty)

# ─────────────────────────────────────────────
# WES - Title Defense "Full Throttle"
#
# Wes has zero chill now. New move: The Chain Spin — 
# he chains TWO spinning attacks in a row with different
# timings. Duck the first, and the second comes faster.
# Also: he's added a backwards dodge to reset spacing,
# making Fritz chase him and waste stamina.
# ─────────────────────────────────────────────
func _start_wes_revenge():
	var wes = load("res://scripts/WesAI.gd").new()
	wes.stamina_max = int(wes.stamina_max * TITLE_DIFFICULTY["stamina_multiplier"])
	wes.tell_duration = wes.tell_duration * TITLE_DIFFICULTY["tell_speed_multiplier"]
	wes.counter_window = wes.counter_window * TITLE_DIFFICULTY["counter_window_multiplier"]

	# Title Defense exclusive
	wes.revenge_mode = true
	wes.chain_spin_enabled = true            # Double spin with varied timing
	wes.reset_dodge_enabled = true           # Backwards dodge to reset pressure
	wes.feint_spin_enabled = true
	wes.feint_chance = 0.55                  # More feints than World Circuit

	wes.connect("fight_over", self, "_on_defense_over")
	add_child(wes)

# ─────────────────────────────────────────────
# KAINE - Title Defense "The Reckoning"
#
# Kaine has one goal: take the belt back by any means.
# New move: The Bait Flurry — he starts the Signature
# Uppercut Flurry, pauses at peak vulnerability, WAITS
# for Fritz to counter, then sidesteps and counters Fritz's
# counter. Players must learn a new timing to beat him.
# Also: he now varies his combo lengths (2, 3, or 4 hit)
# so Fritz can't muscle-memory his way through.
# ─────────────────────────────────────────────
func _start_kaine_revenge():
	var kaine = load("res://scripts/KaineAI.gd").new()
	kaine.stamina_max = int(kaine.stamina_max * TITLE_DIFFICULTY["stamina_multiplier"])
	kaine.tell_duration = kaine.tell_duration * TITLE_DIFFICULTY["tell_speed_multiplier"]
	kaine.counter_window = kaine.counter_window * TITLE_DIFFICULTY["counter_window_multiplier"]

	# Title Defense exclusive
	kaine.revenge_mode = true
	kaine.bait_flurry_enabled = true         # Fake vulnerability window
	kaine.variable_combo_length = true       # 2, 3, or 4-hit combos randomly
	kaine.punish_early_counter = true        # Sidestep + punish premature counters

	kaine.connect("fight_over", self, "_on_defense_over")
	add_child(kaine)

# ─────────────────────────────────────────────
# Defense resolution
# ─────────────────────────────────────────────
func _on_defense_over(result: String, _stars_earned: int):
	if result == "win":
		title_defenses_won += 1
		print("[TitleDefense] Belt defended! %d down." % title_defenses_won)
		current_defense_index += 1
		_load_next_challenger()
	else:
		print("[TitleDefense] Belt lost. Fritz is no longer champion.")
		emit_signal("defense_failed", current_defense_index)

func _on_defense_complete():
	print("[TitleDefense] All three challengers defeated. Fritz is the undisputed champion.")
	emit_signal("defense_complete", title_defenses_won)
