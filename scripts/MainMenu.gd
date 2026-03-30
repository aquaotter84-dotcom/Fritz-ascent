extends Control

# Main menu for Fritz's Ascent
# Routes to ModeSelect when play is pressed

func _ready():
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$VBoxContainer/CreditsButton.pressed.connect(_on_credits_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/ModeSelect.tscn")

func _on_credits_pressed():
	# Simple credits overlay or scene
	print("Credits: Jeremy Bryan Perritt (Design) | Meli (Code Architecture)")

func _on_quit_pressed():
	get_tree().quit()