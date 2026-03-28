extends Node2D

@onready var dusty = $Dusty
var stars := 0
var player_open := false

func _ready() -> void:
	dusty.begin_fight()

func player_dodge(direction: String) -> void:
	var result = dusty.resolve_player_defense(direction)
	if result == "perfect_haymaker_dodge":
		stars += 1
		player_open = true
	elif result == "safe_dodge":
		player_open = true
	else:
		player_open = false

func player_counter() -> bool:
	if player_open:
		player_open = false
		dusty.take_counter_hit()
		return true
	return false

func player_star_punch() -> bool:
	if stars > 0 and dusty.is_vulnerable():
		stars -= 1
		dusty.take_star_hit()
		return true
	return false