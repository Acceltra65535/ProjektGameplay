extends Control

# 缓存三个按钮，方便在代码里访问
@onready var start_button: Button = $Menu/VBoxContainer/Start
@onready var save_button: Button = $Menu/VBoxContainer/Save
@onready var exit_button: Button = $Menu/VBoxContainer/Exit

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	save_button.pressed.connect(_on_save_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/CharacterSelect.tscn")

func _on_save_pressed() -> void:
	print("Save pressed - TODO: implement save system")

func _on_exit_pressed() -> void:
	get_tree().quit()
