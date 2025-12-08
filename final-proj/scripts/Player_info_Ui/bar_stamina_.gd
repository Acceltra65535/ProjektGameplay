extends TextureProgressBar

@onready var player: Player = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	player.stamina_changed.connect(update_stamina)
	update_stamina()

func update_stamina() -> void:
	value = player.stamina
	max_value = player.max_stamina
