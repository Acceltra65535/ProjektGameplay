extends PlayerCommand
class_name MoveCommand

func execute(player, delta: float) -> void:
	if player.state != player.State.NORMAL:
		return

	var input_dir: float = Input.get_axis("move_left", "move_right")
	var wants_run: bool = Input.is_action_pressed("run_mode")
	player.handle_move(input_dir, wants_run, delta)
