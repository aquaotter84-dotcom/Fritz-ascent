extends Node

# ============================================================
# WorldCircuit.gd
# Fritz's Ascent - World Circuit Mode
#
# Rematch gauntlet: Dusty → Wes → Kaine
# All opponents fight at elevated difficulty:
#   - Faster tells (reduced telegraph window)
#   - Tighter counter windows
#   - Higher stamina
#   - New combo chains not seen in Main Circuit
# ============================================================

signal circuit_complete
signal circuit_failed

const WORLD_DIFFICULTY := {
	"tell_speed_multiplier": 0.65,    # Tells are 35% faster
	"counter_window_multiplier": 0.70, # Counter windows are 30% tighter
	"stamina_multiplier": 1.40,        # 40% more HP
	"combo_chance": 0.55               # Higher combo frequency
}

var opponent_order := ["Dusty", "Wes", "Kaine"]
var current_fight_index := 0
var circuit_wins := 0

# Fritz carries star punches earned across fights — reward mastery
var carried_stars := 0

func start_circuit():
	current_fight_index = 0
	circuit_wins = 0
	carried_stars = 0
	print("[WorldCircuit] World Circuit begins. Three opponents. No mercy.")
	_load_next_opponent()

func _load_next_opponent():
	if current_fight_index >= opponent_order.size():
		_on_circuit_complete()
		return

	var name = opponent_order[current_fight_index]
	print("[WorldCircuit] Fight %d: %s (World Circuit difficulty)" % [current_fight_index + 1, name])

	match name:
		"Dusty":
			_start_dusty_world()
		"Wes":
			_start_wes_world()
		"Kaine":
			_start_kaine_world()

# ─────────────────────────────────────────────
# DUSTY - World Circuit
# New wrinkle: Dusty stops telegraphing The Haymaker after 1 KD.
# His pride kicks in — he starts throwing it *without* the full exhale.
# ─────────────────────────────────────────────
func _start_dusty_world():
	var dusty = load("res://scripts/DustyAI.gd").new()
	dusty.stamina_max = int(dusty.stamina_max * WORLD_DIFFICULTY["stamina_multiplier"])
	dusty.tell_duration = dusty.tell_duration * WORLD_DIFFICULTY["tell_speed_multiplier"]
	dusty.counter_window = dusty.counter_window * WORLD_DIFFICULTY["counter_window_multiplier"]

	# World Circuit exclusive: suppressed haymaker tell after first KD
	dusty.world_circuit_mode = true
	dusty.connect("fight_over", self, "_on_fight_over")
	add_child(dusty)

# ─────────────────────────────────────────────
# WES - World Circuit
# New wrinkle: Wes adds a fake-spin feint — he winds up the spin
# then cuts it short and throws a jab instead. Tests muscle memory.
# ─────────────────────────────────────────────
func _start_wes_world():
	var wes = load("res://scripts/WesAI.gd").new()
	wes.stamina_max = int(wes.stamina_max * WORLD_DIFFICULTY["stamina_multiplier"])
	wes.tell_duration = wes.tell_duration * WORLD_DIFFICULTY["tell_speed_multiplier"]
	wes.counter_window = wes.counter_window * WORLD_DIFFICULTY["counter_window_multiplier"]

	# World Circuit exclusive: feint spin enabled
	wes.feint_spin_enabled = true
	wes.feint_chance = 0.40  # 40% of spin wind-ups are feints
	wes.connect("fight_over", self, "_on_fight_over")
	add_child(wes)

# ─────────────────────────────────────────────
# KAINE - World Circuit
# New wrinkle: Kaine adds a delayed uppercut — he pauses mid-flurry
# for a split second to bait the counter, then finishes the flurry.
# Players who counter too early get punished hard.
# ─────────────────────────────────────────────
func _start_kaine_world():
	var kaine = load("res://scripts/KaineAI.gd").new()
	kaine.stamina_max = int(kaine.stamina_max * WORLD_DIFFICULTY["stamina_multiplier"])
	kaine.tell_duration = kaine.tell_duration * WORLD_DIFFICULTY["tell_speed_multiplier"]
	kaine.counter_window = kaine.counter_window * WORLD_DIFFICULTY["counter_window_multiplier"]

	# World Circuit exclusive: delayed flurry bait
	kaine.delayed_flurry_enabled = true
	kaine.connect("fight_over", self, "_on_fight_over")
	add_child(kaine)

# ─────────────────────────────────────────────
# Fight resolution
# ─────────────────────────────────────────────
func _on_fight_over(result: String, stars_earned: int):
	if result == "win":
		circuit_wins += 1
		carried_stars += stars_earned
		print("[WorldCircuit] Fight won. Stars carried: %d" % carried_stars)
		current_fight_index += 1
		_load_next_opponent()
	else:
		print("[WorldCircuit] Fritz goes down in World Circuit. No retry — that's the game.")
		emit_signal("circuit_failed", current_fight_index)

func _on_circuit_complete():
	print("[WorldCircuit] World Circuit complete! Fritz is the World Champion.")
	emit_signal("circuit_complete", carried_stars)
