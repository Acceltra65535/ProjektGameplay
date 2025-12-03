extends Control

## Updated Inventory UI that displays actual inventory data from InventoryData autoload.

@onready var inventory_panel: Panel = $Panel
@onready var inventory_container: GridContainer = $Panel/Items
@onready var hotbar_container: GridContainer = $User/Items

# Currently selected hotbar slot index (0-5)
var selected_slot_index: int = 0

# Style for selected slot
var selected_style: StyleBoxFlat
var normal_style: StyleBoxFlat
var has_item_style: StyleBoxFlat

# Input action names for hotbar slots
const HOTBAR_ACTIONS: Array[String] = [
	"hotbar_1",
	"hotbar_2",
	"hotbar_3",
	"hotbar_4",
	"hotbar_5",
	"hotbar_6"
]

# Is inventory panel open?
var is_inventory_open: bool = false


func _ready() -> void:
	# Create styles for visual feedback
	_create_slot_styles()
	
	# Connect to inventory data signals
	if InventoryData:
		InventoryData.inventory_changed.connect(_on_inventory_changed)
		InventoryData.hotbar_changed.connect(_on_hotbar_changed)
	
	# Initially hide inventory panel
	if inventory_panel:
		inventory_panel.visible = false
	
	# Initial update
	_update_all_slots()
	_update_slot_selection()


func _create_slot_styles() -> void:
	# Normal slot style (gray, empty)
	normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.55, 0.55, 0.55, 1)
	
	# Selected slot style (highlighted)
	selected_style = StyleBoxFlat.new()
	selected_style.bg_color = Color(0.8, 0.7, 0.3, 1)
	selected_style.border_width_bottom = 3
	selected_style.border_width_top = 3
	selected_style.border_width_left = 3
	selected_style.border_width_right = 3
	selected_style.border_color = Color(1.0, 0.9, 0.4, 1)
	
	# Has item style (slightly different)
	has_item_style = StyleBoxFlat.new()
	has_item_style.bg_color = Color(0.45, 0.45, 0.5, 1)


func _unhandled_input(event: InputEvent) -> void:
	# Toggle inventory with Tab or I
	if event.is_action_pressed("toggle_inventory"):
		_toggle_inventory()
		get_viewport().set_input_as_handled()
		return
	
	# Check each hotbar action
	for i in range(HOTBAR_ACTIONS.size()):
		if event.is_action_pressed(HOTBAR_ACTIONS[i]):
			_select_slot(i)
			get_viewport().set_input_as_handled()
			return


func _toggle_inventory() -> void:
	is_inventory_open = not is_inventory_open
	if inventory_panel:
		inventory_panel.visible = is_inventory_open
	
	# Optionally pause game when inventory is open
	# get_tree().paused = is_inventory_open


func _select_slot(index: int) -> void:
	if index < 0 or index >= 6:
		return
	
	selected_slot_index = index
	_update_slot_selection()
	_on_slot_selected(index)


func _update_slot_selection() -> void:
	if hotbar_container == null:
		return
	
	var slots := hotbar_container.get_children()
	for i in range(slots.size()):
		var slot := slots[i] as PanelContainer
		if slot == null:
			continue
		
		var stack: ItemStack = InventoryData.get_hotbar_slot(i) if InventoryData else null
		
		if i == selected_slot_index:
			slot.add_theme_stylebox_override("panel", selected_style)
		elif stack != null and not stack.is_empty():
			slot.add_theme_stylebox_override("panel", has_item_style)
		else:
			slot.add_theme_stylebox_override("panel", normal_style)


func _on_slot_selected(index: int) -> void:
	print("Hotbar slot %d selected" % (index + 1))
	_use_item_in_slot(index)


func _use_item_in_slot(index: int) -> void:
	if not InventoryData:
		return
	
	var stack: ItemStack = InventoryData.get_hotbar_slot(index)
	if stack == null or stack.item == null:
		return
	
	# Handle item usage based on type
	match stack.item.item_type:
		Item.ItemType.CONSUMABLE:
			_use_consumable(stack, index)
		Item.ItemType.WEAPON:
			_equip_weapon(stack)
		Item.ItemType.AMMO:
			# Ammo is usually auto-used
			pass
		_:
			print("Used item: %s" % stack.item.name)


func _use_consumable(stack: ItemStack, _hotbar_index: int) -> void:
	# Implement consumable logic here
	# For now, just remove one from stack
	print("Used consumable: %s" % stack.item.name)
	InventoryData.remove_item(stack.item, 1)


func _equip_weapon(stack: ItemStack) -> void:
	# Implement weapon equipping
	print("Equipped weapon: %s" % stack.item.name)


func _on_inventory_changed() -> void:
	_update_all_slots()


func _on_hotbar_changed() -> void:
	_update_hotbar_slots()
	_update_slot_selection()


func _update_all_slots() -> void:
	_update_inventory_slots()
	_update_hotbar_slots()


func _update_inventory_slots() -> void:
	if inventory_container == null:
		return
	if not InventoryData:
		return
	
	var slots := inventory_container.get_children()
	for i in range(slots.size()):
		var slot := slots[i] as PanelContainer
		if slot == null:
			continue
		
		var stack: ItemStack = InventoryData.get_inventory_slot(i)
		_update_slot_visual(slot, stack)


func _update_hotbar_slots() -> void:
	if hotbar_container == null:
		return
	if not InventoryData:
		return
	
	var slots := hotbar_container.get_children()
	for i in range(slots.size()):
		var slot := slots[i] as PanelContainer
		if slot == null:
			continue
		
		var stack: ItemStack = InventoryData.get_hotbar_slot(i)
		_update_slot_visual(slot, stack)


func _update_slot_visual(slot: PanelContainer, stack: ItemStack) -> void:
	# Find or create icon and label children
	var icon: TextureRect = _get_or_create_icon(slot)
	var quantity_label: Label = _get_or_create_quantity_label(slot)
	
	if stack == null or stack.is_empty():
		icon.texture = null
		icon.visible = false
		quantity_label.visible = false
	else:
		if stack.item and stack.item.icon:
			icon.texture = stack.item.icon
			icon.visible = true
		else:
			icon.visible = false
		
		if stack.quantity > 1:
			quantity_label.text = str(stack.quantity)
			quantity_label.visible = true
		else:
			quantity_label.visible = false


func _get_or_create_icon(slot: PanelContainer) -> TextureRect:
	var icon := slot.get_node_or_null("Icon") as TextureRect
	if icon == null:
		icon = TextureRect.new()
		icon.name = "Icon"
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(50, 50)
		icon.anchors_preset = Control.PRESET_FULL_RECT
		slot.add_child(icon)
	return icon


func _get_or_create_quantity_label(slot: PanelContainer) -> Label:
	var label := slot.get_node_or_null("Quantity") as Label
	if label == null:
		label = Label.new()
		label.name = "Quantity"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		label.anchors_preset = Control.PRESET_FULL_RECT
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_color_override("font_shadow_color", Color.BLACK)
		label.add_theme_constant_override("shadow_offset_x", 1)
		label.add_theme_constant_override("shadow_offset_y", 1)
		slot.add_child(label)
	return label


# Public method to get currently selected slot
func get_selected_slot() -> int:
	return selected_slot_index


# Public method to select a slot programmatically
func select_slot(index: int) -> void:
	_select_slot(index)


# Add test item (for debugging)
func _on_add_item_pressed() -> void:
	# This requires having a test item resource
	# For debugging purposes
	print("Add item button pressed - create item resources to test")
