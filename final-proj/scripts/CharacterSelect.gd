extends Control

@onready var btn_balanced: Button = $Panel/LayoutRoot/PortraitBalanced/BtnBalanced
@onready var btn_speed: Button = $Panel/LayoutRoot/PortraitSpeed/BtnSpeed
@onready var btn_tank: Button = $Panel/LayoutRoot/PortraitTank/BtnTank
@onready var bgm_player: AudioStreamPlayer  = $BgmPlayer


func _ready() -> void:
	btn_balanced.pressed.connect(_on_balanced_pressed)
	btn_speed.pressed.connect(_on_speed_pressed)
	btn_tank.pressed.connect(_on_tank_pressed)
	bgm_player.play()


func _on_balanced_pressed() -> void:
	Global.selected_class = 0
	print("0")
	_start_game()


func _on_speed_pressed() -> void:
	Global.selected_class = 1
	print("1")
	_start_game()


func _on_tank_pressed() -> void:
	Global.selected_class = 2
	print("2")
	_start_game()


func _start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
