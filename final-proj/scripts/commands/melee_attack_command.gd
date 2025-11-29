extends PlayerCommand
class_name MeleeAttackCommand

func execute(player, delta: float) -> void:
	if Input.is_action_just_pressed("attack_melee"):
		player._start_melee_attack()
