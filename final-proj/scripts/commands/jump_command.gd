extends PlayerCommand
class_name JumpCommand

func execute(player, delta: float) -> void:
	if player.state != player.State.NORMAL:
		return

	if Input.is_action_just_pressed("jump") and player.is_on_floor() and not player.is_jump_buffered:
		player._start_jump_buffer()
