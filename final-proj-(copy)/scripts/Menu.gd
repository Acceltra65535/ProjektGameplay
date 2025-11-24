extends Control

# 缓存三个按钮，方便在代码里访问
@onready var start_button: Button = $Menu/VBoxContainer/Start
@onready var save_button: Button = $Menu/VBoxContainer/Save
@onready var exit_button: Button = $Menu/VBoxContainer/Exit

func _ready() -> void:
	# 在场景载入完毕时，把按钮的 pressed 信号连接到对应函数
	start_button.pressed.connect(_on_start_pressed)
	save_button.pressed.connect(_on_save_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_start_pressed() -> void:
	# 切换到游戏主场景（稍后我们会创建 Game.tscn）
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_save_pressed() -> void:
	# 目前只是占位：将来会替换为真正的存档逻辑
	print("Save pressed - TODO: implement save system")

func _on_exit_pressed() -> void:
	# 退出游戏
	get_tree().quit()
