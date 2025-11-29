extends PlayerCommand
class_name RechargeCommand

func execute(player, delta: float) -> void:
	if Input.is_action_just_pressed("recharge"):
		player._start_recharge()
