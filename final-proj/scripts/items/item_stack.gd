extends Resource
class_name ItemStack

@export var item: Item
@export var quantity: int = 1

func _init(p_item: Item = null, p_quantity: int = 1) -> void:
	item = p_item
	quantity = p_quantity


func can_add(amount: int) -> bool:
	if item == null:
		return false
	return quantity + amount <= item.max_stack


func add(amount: int) -> int:
	"""Add items to stack. Returns overflow amount."""
	if item == null:
		return amount
	
	var space_available: int = item.max_stack - quantity
	var to_add: int = min(amount, space_available)
	quantity += to_add
	return amount - to_add


func remove(amount: int) -> int:
	var to_remove: int = min(amount, quantity)
	quantity -= to_remove
	return to_remove


func is_empty() -> bool:
	return quantity <= 0 or item == null


func duplicate_stack() -> ItemStack:
	return ItemStack.new(item, quantity)
