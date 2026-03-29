extends Node2D
## King Kaine Striker - Final Boss AI
## Fast, precise, relentless champion with micro-patterns and combo chains
## Reference: Mike Tyson from classic Punch-Out!!

class_name KaineAI

signal kaine_attacked(attack_type: String)
signal kaine_combo_chain(combo_length: int)

@export var health: float = 300.0  # Champion-tier stamina
@export var base_combo_speed: float = 0.8  # Fast inherent speed
@export var tell_window: float = 0.15  # Tight tells—micro-patterns only

var current_health: float
var is_attacking: bool = false
var combo_chain: int = 0
var pressure_active: bool = false
var attack_timer: float = 0.0
var reset_timer: float = 0.0

var attack_count_since_flurry: int = 0
var knockdown_count: int = 0
var is_staggered: bool = false

func _ready() -> void:
	current_health = health
	randomize()

func _process(delta: float) -> void:
	if is_staggered:
		reset_timer -= delta
		if reset_timer <= 0:
			is_staggered = false
	
	if not is_attacking and not pressure_active:
		attack_timer -= delta
		if attack_timer <= 0:
			initiate_attack()

func initiate_attack() -> void:
	"""Kaine opens immediately with pressure—no warmup"""
	if knockdown_count < 1:
		# Initial round: standard combo pressure
		var attack_choice = randi() % 4
		match attack_choice:
			0: rapid_fire_body_jabs()
			1: head_combo()
			2: if attack_count_since_flurry >= 3:
				signature_uppercut_flurry()
			3: pressure_rush()
	else:
		# Post-knockdown: faster, more aggressive
		var attack_choice = randi() % 3
		match attack_choice:
			0: rapid_fire_body_jabs()
			1: head_combo()
			2: if attack_count_since_flurry >= 2:
				signature_uppercut_flurry()

func rapid_fire_body_jabs() -> void:
	"""2-3 quick jabs with a tiny window between 2nd and 3rd"""
	is_attacking = true
	pressure_active = true
	
	# Tell: slight shoulder drop + quick breath (0.15s)
	await get_tree().create_timer(tell_window).timeout
	
	# Jab 1
	emit_signal("kaine_attacked", "body_jab_1")
	combo_chain = 1
	await get_tree().create_timer(0.25).timeout
	
	# Jab 2
	emit_signal("kaine_attacked", "body_jab_2")
	combo_chain = 2
	await get_tree().create_timer(0.25).timeout
	
	# Small counter window here
	await get_tree().create_timer(tell_window).timeout
	
	# Jab 3 (if combo not interrupted)
	if is_attacking:
		emit_signal("kaine_attacked", "body_jab_3")
		combo_chain = 3
		emit_signal("kaine_combo_chain", 3)
	
	await get_tree().create_timer(0.3).timeout
	finish_attack()

func head_combo() -> void:
	"""Left-Right-Left with rhythm the player can learn"""
	is_attacking = true
	pressure_active = true
	
	# Tell: eyes narrow, jaw tightens
	await get_tree().create_timer(tell_window).timeout
	
	# Left punch
	emit_signal("kaine_attacked", "head_left")
	combo_chain = 1
	await get_tree().create_timer(0.3).timeout
	
	# Right punch
	emit_signal("kaine_attacked", "head_right")
	combo_chain = 2
	await get_tree().create_timer(0.3).timeout
	
	# Left punch (if not interrupted)
	if is_attacking:
		emit_signal("kaine_attacked", "head_left_2")
		combo_chain = 3
		emit_signal("kaine_combo_chain", 3)
	
	await get_tree().create_timer(tell_window).timeout
	finish_attack()

func signature_uppercut_flurry() -> void:
	"""Signature move: 4-5 rapid uppercuts with massive stagger window if interrupted"""
	is_attacking = true
	pressure_active = true
	attack_count_since_flurry = 0
	
	# Tell: drops stance low, inhales sharply (0.15s—tight!)
	await get_tree().create_timer(tell_window).timeout
	
	combo_chain = 0
	for i in range(5):
		if not is_attacking:
			break
		
		emit_signal("kaine_attacked", "uppercut_%d" % i)
		combo_chain += 1
		await get_tree().create_timer(0.25).timeout
	
	emit_signal("kaine_combo_chain", combo_chain)
	
	# If Fritz didn't interrupt, Kaine recovers
	if is_attacking:
		await get_tree().create_timer(0.5).timeout
		finish_attack()

func pressure_rush() -> void:
	"""Aggressive forward momentum—block or sidestep to counter"""
	is_attacking = true
	pressure_active = true
	
	# Tell: leans forward aggressively
	await get_tree().create_timer(tell_window).timeout
	
	emit_signal("kaine_attacked", "pressure_rush")
	combo_chain = 1
	
	# Forward momentum window: 0.8s
	await get_tree().create_timer(0.8).timeout
	finish_attack()

func take_counter(damage: float) -> void:
	"""Fritz landed a counter"""
	current_health -= damage
	
	# If counter during flurry, stagger Kaine
	if combo_chain > 0 and "uppercut" in str(combo_chain):
		stagger()

func stagger() -> void:
	"""Kaine staggers after an interrupted flurry—Fritz's main exploit"""
	is_staggered = true
	is_attacking = false
	pressure_active = false
	reset_timer = 1.2  # Long vulnerable window
	current_health -= 20.0  # Stamina penalty

func finish_attack() -> void:
	"""Reset after attack completes"""
	is_attacking = false
	pressure_active = false
	attack_count_since_flurry += 1
	combo_chain = 0
	
	# 0.5s reset window before next attack
	attack_timer = 0.5
	if knockdown_count > 0:
		attack_timer = 0.3  # Faster resets post-knockdown

func on_knockdown() -> void:
	"""Kaine gets knocked down—comes back angrier"""
	knockdown_count += 1
	is_attacking = false
	pressure_active = false
	attack_count_since_flurry = 0
	
	# Post-knockdown: reduced reset timer, faster tells
	base_combo_speed = max(0.5, base_combo_speed - 0.1)
	tell_window = max(0.08, tell_window - 0.02)
	
	# Immediate counter: desperation flurry if health is low
	if current_health < 100:
		await get_tree().create_timer(1.0).timeout
		signature_uppercut_flurry()

func is_ko() -> bool:
	return current_health <= 0
