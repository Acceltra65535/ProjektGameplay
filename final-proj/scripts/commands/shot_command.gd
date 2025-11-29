extends PlayerCommand
class_name ShotCommand

func execute(player, delta: float) -> void:
	if Input.is_action_just_pressed("attack_ranged"):
		player._start_shot()
