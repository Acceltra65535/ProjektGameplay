extends Resource
class_name LootTable

@export var entries: Array[LootEntry] = []
@export var guaranteed_drops: Array[LootEntry] = []

func roll_loot() -> Array[ItemStack]:
	var results: Array[ItemStack] = []
	
	for entry in guaranteed_drops:
		if entry.item != null:
			print("[LootTable] ENTRY ", entry.item.name,
				" min=", entry.min_quantity,
				" max=", entry.max_quantity)
			
			var qty: int = randi_range(entry.min_quantity, entry.max_quantity)
			print("[LootTable] rolled ", qty, " x ", entry.item.name)
			
			if qty > 0:
				var stack := ItemStack.new()
				stack.item = entry.item
				stack.quantity = qty
				results.append(stack)
	
	for entry in entries:
		if entry.item == null:
			continue
		
		print("[LootTable] ENTRY ", entry.item.name,
			" min=", entry.min_quantity,
			" max=", entry.max_quantity)
		
		var roll: float = randf() * 100.0
		if roll <= entry.drop_chance:
			var qty: int = randi_range(entry.min_quantity, entry.max_quantity)
			print("[LootTable] rolled ", qty, " x ", entry.item.name)
			
			if qty > 0:
				var stack := ItemStack.new()
				stack.item = entry.item
				stack.quantity = qty
				results.append(stack)
	
	return results
