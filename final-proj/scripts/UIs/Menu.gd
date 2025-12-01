extends Control

@onready var start_button: Button = $Menu/VBoxContainer/Start
@onready var load_button: Button = $Menu/VBoxContainer/Load
@onready var exit_button: Button = $Menu/VBoxContainer/Exit
@onready var bgm_player: AudioStreamPlayer = $BgmPlayer

func _ready() -> void:
	bgm_player.play()

func _on_start_pressed() -> void:
	Global.pending_load_data = null  # Clear any pending load
	get_tree().change_scene_to_file("res://scenes/cutscene/Cutscene_Intro.tscn")

func _on_load_pressed() -> void:
	var save_path := "user://scene_data.tres"
	if not ResourceLoader.exists(save_path):
		print("No save file found!")
		return
	
	var data = ResourceLoader.load(save_path)
	if data == null:
		print("Failed to load save data!")
		return
	
	# Store in Global so the game scene can access it
	Global.pending_load_data = data
	
	# Go directly to the game scene (skip cutscene/character select)
	get_tree().change_scene_to_file("res://scenes/CityOutskirtsIntro.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
