extends TextureProgressBar

@onready var player: Player = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	player.health_changed.connect(update_health)
	update_health()

func update_health() -> void:
	value = player.health
	max_value = player.max_health
