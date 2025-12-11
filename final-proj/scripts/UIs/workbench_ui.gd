extends Control
class_name WorkbenchUI

@export var player: Player   
@onready var panel := $Panel
@onready var melee_info := $Panel/Container/MeleeSection/MeleeInfo
@onready var melee_button := $Panel/Container/MeleeSection/MeleeButton
@onready var ranged_info := $Panel/Container/RangedSection/RangedInfo
@onready var ranged_button := $Panel/Container/RangedSection/RangedButton

@onready var close_button := $Panel/CloseButton

var is_open := false


func _ready():
	visible = false
	close_button.pressed.connect(close)
	melee_button.pressed.connect(_on_melee_upgrade)
	ranged_button.pressed.connect(_on_ranged_upgrade)


func open(_player: Player):
	player = _player
	is_open = true
	visible = true
	refresh_ui()
	set_process_unhandled_input(true)


func close():
	is_open = false
	visible = false
	set_process_unhandled_input(false)


func _unhandled_input(event):
	if event.is_action_pressed("open_crafting"):
		if is_open:
			close()
		else:
			var p = get_tree().get_first_node_in_group("Player")
			if p:
				open(p)
		get_viewport().set_input_as_handled()




func refresh_ui():
	if player == null:
		return

	# --- Melee Upgrade ---
	var wood_cost := 5 * player.melee_level
	var new_melee_damage := player.melee_damage + 5

	melee_info.text = "Melee Weapon\nLV %d → %d\nDamage: %d → %d\nCost: %d Wood" % [
		player.melee_level, player.melee_level + 1,
		player.melee_damage, new_melee_damage,
		wood_cost
	]

	melee_button.disabled = InventoryData.get_item_count(Items.WOOD) < wood_cost

	# --- Ranged Upgrade ---
	var metal_cost := int(3 * player.ranged_level)
	var new_range_damage := player.weapon_base_damage + 8

	ranged_info.text = "Ranged Weapon\nLV %d → %d\nDamage: %d → %d\nCost: %d Metal" % [
		player.ranged_level, player.ranged_level + 1,
		player.weapon_base_damage, new_range_damage,
		metal_cost
	]

	ranged_button.disabled = InventoryData.get_item_count(Items.METAL) < metal_cost


func _on_melee_upgrade():
	var cost := 5 * player.melee_level

	if InventoryData.get_item_count(Items.WOOD) < cost:
		print("Not enough wood")
		return

	InventoryData.remove_item(Items.WOOD, cost)

	player.melee_level += 1
	player.melee_damage += 5

	refresh_ui()


func _on_ranged_upgrade():
	var cost :int = 3 * player.ranged_level

	if InventoryData.get_item_count(Items.METAL) < cost:
		print("Not enough metal")
		return

	InventoryData.remove_item(Items.METAL, cost)

	player.ranged_level += 1
	player.weapon_base_damage += 8

	refresh_ui()
