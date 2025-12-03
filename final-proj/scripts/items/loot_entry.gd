extends Resource
class_name LootEntry

@export var item: Item
@export_range(0.0, 100.0) var drop_chance: float = 100.0  # Percentage
@export var min_quantity: int = 1
@export var max_quantity: int = 1
