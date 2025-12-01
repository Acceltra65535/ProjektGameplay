extends Control

# Reference to the user hotbar slots (bottom 6 slots)
@onready var hotbar_container: GridContainer = $User/Items

# Currently selected hotbar slot index (0-5)
var selected_slot_index: int = 0

# Style for selected slot
var selected_style: StyleBoxFlat
var normal_style: StyleBoxFlat

# Input action names for hotbar slots
const HOTBAR_ACTIONS: Array[String] = [
	"hotbar_1",
	"hotbar_2",
	"hotbar_3",
	"hotbar_4",
	"hotbar_5",
	"hotbar_6"
]


func _ready() -> void:
	# Create styles for visual feedback
	_create_slot_styles()
	
	# Apply initial selection
	_update_slot_visuals()


func _create_slot_styles() -> void:
	# Normal slot style (gray)
	normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.55, 0.55, 0.55, 1)
	
	# Selected slot style (highlighted)
	selected_style = StyleBoxFlat.new()
	selected_style.bg_color = Color(0.8, 0.7, 0.3, 1)  # Gold/yellow highlight
	selected_style.border_width_bottom = 3
	selected_style.border_width_top = 3
	selected_style.border_width_left = 3
	selected_style.border_width_right = 3
	selected_style.border_color = Color(1.0, 0.9, 0.4, 1)  # Bright gold border


func _unhandled_input(event: InputEvent) -> void:
	# Check each hotbar action
	for i in range(HOTBAR_ACTIONS.size()):
		if event.is_action_pressed(HOTBAR_ACTIONS[i]):
			_select_slot(i)
			get_viewport().set_input_as_handled()
			return


func _select_slot(index: int) -> void:
	if index < 0 or index >= 6:
		return
	
	selected_slot_index = index
	_update_slot_visuals()
	_on_slot_selected(index)


func _update_slot_visuals() -> void:
	if hotbar_container == null:
		return
	
	var slots := hotbar_container.get_children()
	for i in range(slots.size()):
		var slot := slots[i] as PanelContainer
		if slot == null:
			continue
		
		if i == selected_slot_index:
			slot.add_theme_stylebox_override("panel", selected_style)
		else:
			slot.add_theme_stylebox_override("panel", normal_style)


func _on_slot_selected(index: int) -> void:
	# Override this or connect a signal to handle item usage
	print("Hotbar slot %d selected" % (index + 1))
	
	# Here you would:
	# 1. Get the item in that slot
	# 2. Equip it, use it, or perform the appropriate action
	_use_item_in_slot(index)


func _use_item_in_slot(index: int) -> void:
	# Placeholder for item usage logic
	# You'll want to implement your actual inventory data here
	pass


# Public method to get currently selected slot
func get_selected_slot() -> int:
	return selected_slot_index


# Public method to select a slot programmatically
func select_slot(index: int) -> void:
	_select_slot(index)
