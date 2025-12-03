extends CanvasLayer

func _on_save_pressed() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		player = get_tree().get_first_node_in_group("Player")
	
	if player == null:
		push_warning("Cannot save: Player not found!")
		return
	
	var data = SceneData.new()
	data.player_position = player.global_position
	data.is_facing_left = player.get_node("Anim").flip_h
	data.selected_class = Global.selected_class
	ResourceSaver.save(data, "user://scene_data.tres")
	print("Saved!")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("save_shortcut"):
		_on_save_pressed()
