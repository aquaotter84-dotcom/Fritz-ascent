extends Node

# FritzInput.gd
# Reads player input and routes calls to FightController.
#
# Input actions to register in Project Settings > Input Map:
#   dodge_left   → keyboard: A / Left Arrow  | on-screen: Left button
#   dodge_right  → keyboard: D / Right Arrow | on-screen: Right button
#   duck         → keyboard: S / Down Arrow  | on-screen: Duck button
#   block_low    → keyboard: Q              | on-screen: Block button
#   counter      → keyboard: Space / J      | on-screen: Counter button
#   star_punch   → keyboard: K / Shift      | on-screen: Star button

@onready var fight_controller: Node2D = get_parent()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dodge_left"):
		fight_controller.player_dodge("left")
	elif event.is_action_pressed("dodge_right"):
		fight_controller.player_dodge("right")
	elif event.is_action_pressed("duck"):
		fight_controller.player_dodge("duck")
	elif event.is_action_pressed("block_low"):
		fight_controller.player_dodge("block_low")
	elif event.is_action_pressed("counter"):
		fight_controller.player_counter()
	elif event.is_action_pressed("star_punch"):
		fight_controller.player_star_punch()

# ── Mobile on-screen button hooks ──────────────────────────────────────────
# Wire these to Button.pressed signals in your HUD scene.

func on_btn_dodge_left() -> void:
	fight_controller.player_dodge("left")

func on_btn_dodge_right() -> void:
	fight_controller.player_dodge("right")

func on_btn_duck() -> void:
	fight_controller.player_dodge("duck")

func on_btn_block_low() -> void:
	fight_controller.player_dodge("block_low")

func on_btn_counter() -> void:
	fight_controller.player_counter()

func on_btn_star_punch() -> void:
	fight_controller.player_star_punch()
