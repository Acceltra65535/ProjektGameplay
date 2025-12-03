extends Node

signal inventory_changed
signal item_added(item: Item, quantity: int)
signal item_removed(item: Item, quantity: int)
signal hotbar_changed

# Main inventory slots (30 slots as shown in Inventory.tscn)
const INVENTORY_SIZE: int = 30
const HOTBAR_SIZE: int = 6

var inventory: Array[ItemStack] = []
var hotbar: Array[ItemStack] = []

func _ready() -> void:
	_initialize_inventory()


func _initialize_inventory() -> void:
	inventory.clear()
	hotbar.clear()
	
	# Initialize with empty slots
	for i in range(INVENTORY_SIZE):
		inventory.append(null)
	
	for i in range(HOTBAR_SIZE):
		hotbar.append(null)


func add_item(item: Item, quantity: int = 1) -> int:
	"""
	Add item to inventory. First tries hotbar, then main inventory.
	Returns the amount that couldn't be added (overflow).
	"""
	if item == null or quantity <= 0:
		return quantity
	
	var remaining: int = quantity
	
	# First, try to stack with existing items in hotbar
	remaining = _try_stack_in_array(hotbar, item, remaining)
	if remaining <= 0:
		emit_signal("item_added", item, quantity)
		emit_signal("hotbar_changed")
		emit_signal("inventory_changed")
		return 0
	
	# Then try to stack with existing items in inventory
	remaining = _try_stack_in_array(inventory, item, remaining)
	if remaining <= 0:
		emit_signal("item_added", item, quantity)
		emit_signal("inventory_changed")
		return 0
	
	# Then try empty slots in hotbar
	remaining = _try_add_to_empty_slots(hotbar, item, remaining)
	if remaining <= 0:
		emit_signal("item_added", item, quantity)
		emit_signal("hotbar_changed")
		emit_signal("inventory_changed")
		return 0
	
	# Finally try empty slots in inventory
	remaining = _try_add_to_empty_slots(inventory, item, remaining)
	
	var added: int = quantity - remaining
	if added > 0:
		emit_signal("item_added", item, added)
		emit_signal("inventory_changed")
	
	return remaining


func _try_stack_in_array(arr: Array[ItemStack], item: Item, quantity: int) -> int:
	"""Try to add to existing stacks. Returns remaining quantity."""
	var remaining: int = quantity
	
	for i in range(arr.size()):
		if arr[i] == null:
			continue
		if arr[i].item != item:
			continue
		if not arr[i].can_add(1):
			continue
		
		remaining = arr[i].add(remaining)
		if remaining <= 0:
			break
	
	return remaining


func _try_add_to_empty_slots(arr: Array[ItemStack], item: Item, quantity: int) -> int:
	"""Try to add to empty slots. Returns remaining quantity."""
	var remaining: int = quantity
	
	for i in range(arr.size()):
		if arr[i] != null:
			continue
		
		var to_add: int = min(remaining, item.max_stack)
		arr[i] = ItemStack.new(item, to_add)
		remaining -= to_add
		
		if remaining <= 0:
			break
	
	return remaining


func remove_item(item: Item, quantity: int = 1) -> int:
	"""
	Remove item from inventory. Returns actual amount removed.
	"""
	if item == null or quantity <= 0:
		return 0
	
	var to_remove: int = quantity
	var removed: int = 0
	
	# Remove from inventory first
	for i in range(inventory.size()):
		if inventory[i] == null:
			continue
		if inventory[i].item != item:
			continue
		
		var taken: int = inventory[i].remove(to_remove)
		removed += taken
		to_remove -= taken
		
		if inventory[i].is_empty():
			inventory[i] = null
		
		if to_remove <= 0:
			break
	
	# Then from hotbar
	if to_remove > 0:
		for i in range(hotbar.size()):
			if hotbar[i] == null:
				continue
			if hotbar[i].item != item:
				continue
			
			var taken: int = hotbar[i].remove(to_remove)
			removed += taken
			to_remove -= taken
			
			if hotbar[i].is_empty():
				hotbar[i] = null
			
			if to_remove <= 0:
				break
	
	if removed > 0:
		emit_signal("item_removed", item, removed)
		emit_signal("inventory_changed")
		emit_signal("hotbar_changed")
	
	return removed


func get_item_count(item: Item) -> int:
	"""Get total count of an item across all inventory and hotbar."""
	if item == null:
		return 0
	
	var count: int = 0
	
	for stack in inventory:
		if stack != null and stack.item == item:
			count += stack.quantity
	
	for stack in hotbar:
		if stack != null and stack.item == item:
			count += stack.quantity
	
	return count


func has_item(item: Item, quantity: int = 1) -> bool:
	"""Check if player has at least the specified quantity of an item."""
	return get_item_count(item) >= quantity


func get_inventory_slot(index: int) -> ItemStack:
	if index < 0 or index >= inventory.size():
		return null
	return inventory[index]


func get_hotbar_slot(index: int) -> ItemStack:
	if index < 0 or index >= hotbar.size():
		return null
	return hotbar[index]


func set_inventory_slot(index: int, stack: ItemStack) -> void:
	if index < 0 or index >= inventory.size():
		return
	inventory[index] = stack
	emit_signal("inventory_changed")


func set_hotbar_slot(index: int, stack: ItemStack) -> void:
	if index < 0 or index >= hotbar.size():
		return
	hotbar[index] = stack
	emit_signal("hotbar_changed")
	emit_signal("inventory_changed")


func swap_inventory_slots(from_index: int, to_index: int) -> void:
	if from_index < 0 or from_index >= inventory.size():
		return
	if to_index < 0 or to_index >= inventory.size():
		return
	
	var temp: ItemStack = inventory[from_index]
	inventory[from_index] = inventory[to_index]
	inventory[to_index] = temp
	emit_signal("inventory_changed")


func swap_hotbar_slots(from_index: int, to_index: int) -> void:
	if from_index < 0 or from_index >= hotbar.size():
		return
	if to_index < 0 or to_index >= hotbar.size():
		return
	
	var temp: ItemStack = hotbar[from_index]
	hotbar[from_index] = hotbar[to_index]
	hotbar[to_index] = temp
	emit_signal("hotbar_changed")


func move_to_hotbar(inv_index: int, hotbar_index: int) -> void:
	"""Move item from inventory to hotbar (swap)."""
	if inv_index < 0 or inv_index >= inventory.size():
		return
	if hotbar_index < 0 or hotbar_index >= hotbar.size():
		return
	
	var temp: ItemStack = inventory[inv_index]
	inventory[inv_index] = hotbar[hotbar_index]
	hotbar[hotbar_index] = temp
	emit_signal("inventory_changed")
	emit_signal("hotbar_changed")


func clear_inventory() -> void:
	_initialize_inventory()
	emit_signal("inventory_changed")
	emit_signal("hotbar_changed")
