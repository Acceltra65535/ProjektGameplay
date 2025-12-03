extends Resource
class_name LootTable

@export var entries: Array[LootEntry] = []
@export var guaranteed_drops: Array[LootEntry] = []  # Always drop these

func roll_loot() -> Array[ItemStack]:
	"""Roll the loot table and return array of ItemStacks to drop."""
	var results: Array[ItemStack] = []
	
	# Add guaranteed drops first
	for entry in guaranteed_drops:
		if entry.item != null:
			var qty: int = randi_range(entry.min_quantity, entry.max_quantity)
			if qty > 0:
				results.append(ItemStack.new(entry.item, qty))
	
	# Roll random drops
	for entry in entries:
		if entry.item == null:
			continue
		
		var roll: float = randf() * 100.0
		if roll <= entry.drop_chance:
			var qty: int = randi_range(entry.min_quantity, entry.max_quantity)
			if qty > 0:
				results.append(ItemStack.new(entry.item, qty))
	
	return results
