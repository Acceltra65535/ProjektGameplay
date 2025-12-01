extends CanvasLayer

@export var player : Node2D

func _on_save_pressed() -> void:
	var data = SceneData.new()
	data.player_position = player.global_position
	data.is_facing_left = player.get_node("Anim").flip_h
	data.selected_class = Global.selected_class
	ResourceSaver.save(data, "user://scene_data.tres" )
	print("saved!")
 

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("save_shortcut"):
		_on_save_pressed()
		
