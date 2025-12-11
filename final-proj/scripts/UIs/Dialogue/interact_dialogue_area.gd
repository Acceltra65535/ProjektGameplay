extends Area2D
class_name InteractDialogueArea

## Triggers dialogue when player presses interact key while in this area.
## Attach this script to an Area2D with a CollisionShape2D child.

@export_group("Dialogue Settings")
## The DialogueGroup resource to play when triggered (optional if using dynamic loading)
@export var dialogue_group: DialogueGroup

## Story key identifier for this dialogue trigger
@export var story_key: String = ""

@export_group("Dynamic Dialogue Loading")
## If true, loads dialogue dynamically based on scene_id, trigger_key, and current character
@export var use_dynamic_loading: bool = false

## Scene identifier for dynamic loading (e.g., "s1", "s2", "s3", "s4")
@export var scene_id: String = ""

## Trigger key for dynamic loading (e.g., "main", "terminal", "vendor")
@export var trigger_key: String = "main"

@export_group("Trigger Conditions")
## Leave empty to trigger for all characters, or set to "elias", "mira", or "jonah"
@export var only_for_character: String = ""

## If true, this dialogue only triggers once per game session
@export var one_shot: bool = true

## Optional: Story flag that must be set for this trigger to work
@export var requires_flag: String = ""

## Optional: The expected value of the required flag (default true)
@export var requires_flag_value: bool = true

## Optional: Story flag to set after dialogue finishes
@export var set_flag_on_complete: String = ""

@export_group("Interact Hint")
## The input action name for interaction (will try "interact", "ui_accept", or "E" key)
@export var interact_action: String = "interact"

## Text to show when player can interact
@export var interact_hint_text: String = "按 E 互动"

## Label node for showing the hint (optional - will create one if not assigned)
@export var hint_label: Label

var has_triggered: bool = false
var player_in_area: bool = false
var dialogue_manager: DialogueManager = null
var created_hint_label: Label = null


func _ready() -> void:
	# Connect area signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Set up collision to detect player
	collision_layer = 0
	collision_mask = 1


func _process(_delta: float) -> void:
	if not player_in_area:
		return
	
	# Check for interact input
	if _check_interact_input():
		_try_trigger_dialogue()


func _check_interact_input() -> bool:
	# Try the configured action first
	if InputMap.has_action(interact_action):
		if Input.is_action_just_pressed(interact_action):
			return true
	
	# Fallback: check ui_accept
	if Input.is_action_just_pressed("ui_accept"):
		return true
	
	# Fallback: check E key directly
	if Input.is_physical_key_pressed(KEY_E):
		# Use a simple flag to track key state for "just pressed"
		if not has_meta("e_was_pressed"):
			set_meta("e_was_pressed", true)
			return true
	else:
		remove_meta("e_was_pressed")
	
	return false


func _on_body_entered(body: Node2D) -> void:
	if not _is_player(body):
		return
	
	if has_triggered and one_shot:
		return
	
	if not _check_character_restriction():
		return
	
	if not _check_flag_requirements():
		return
	
	player_in_area = true
	_show_interact_hint()


func _on_body_exited(body: Node2D) -> void:
	if not _is_player(body):
		return
	
	player_in_area = false
	_hide_interact_hint()


func _is_player(body: Node2D) -> bool:
	return body.is_in_group("player") or body.is_in_group("Player")


func _check_character_restriction() -> bool:
	if only_for_character.is_empty():
		return true
	var current_character := _get_current_character_id()
	return current_character == only_for_character.to_lower()


func _get_current_character_id() -> String:
	match Global.selected_class:
		0: return "elias"
		1: return "mira"
		2: return "jonah"
	return "elias"


func _check_flag_requirements() -> bool:
	if requires_flag.is_empty():
		return true
	return Global.check_story_flag(requires_flag, requires_flag_value)


func _try_trigger_dialogue() -> void:
	if has_triggered and one_shot:
		return

	has_triggered = true
	player_in_area = false
	_hide_interact_hint()

	dialogue_manager = _find_dialogue_manager()
	if dialogue_manager == null:
		push_warning("InteractDialogueArea: DialogueManager not found!")
		return

	# Get the dialogue group (either static or dynamic)
	var active_dialogue := _get_active_dialogue()
	if active_dialogue == null:
		push_warning("InteractDialogueArea: No dialogue available for story_key: " + story_key)
		return

	if not set_flag_on_complete.is_empty():
		if not dialogue_manager.dialogue_finished.is_connected(_on_dialogue_finished):
			dialogue_manager.dialogue_finished.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)

	dialogue_manager.start_dialogue(active_dialogue)
	print("[InteractDialogueArea] Triggered dialogue for story_key: ", story_key)


func _get_active_dialogue() -> DialogueGroup:
	# If dynamic loading is enabled, fetch from StoryDialogueLibrary
	if use_dynamic_loading and not scene_id.is_empty():
		var character_id := _get_current_character_id()
		return StoryDialogueLibrary.build_dialogue(scene_id, character_id, trigger_key)

	# Otherwise use the statically assigned dialogue_group
	return dialogue_group


func _on_dialogue_finished() -> void:
	if not set_flag_on_complete.is_empty():
		Global.set_story_flag(set_flag_on_complete, true)


func _show_interact_hint() -> void:
	if hint_label != null:
		hint_label.text = interact_hint_text
		hint_label.visible = true
		return

	# Create a simple hint label if none assigned
	if created_hint_label == null:
		created_hint_label = Label.new()
		created_hint_label.text = interact_hint_text
		created_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		created_hint_label.position = Vector2(-50, -60)  # Above the area
		add_child(created_hint_label)
	else:
		created_hint_label.visible = true


func _hide_interact_hint() -> void:
	if hint_label != null:
		hint_label.visible = false
		return

	if created_hint_label != null:
		created_hint_label.visible = false


func _find_dialogue_manager() -> DialogueManager:
	var dm := get_tree().get_first_node_in_group("DialogueManager")
	if dm != null:
		return dm as DialogueManager

	var nodes = get_tree().get_nodes_in_group("UI")
	for node in nodes:
		if node is DialogueManager:
			return node

	return _find_node_by_class(get_tree().root, "DialogueManager")


func _find_node_by_class(node: Node, class_name_str: String) -> DialogueManager:
	if node is DialogueManager:
		return node
	for child in node.get_children():
		var result = _find_node_by_class(child, class_name_str)
		if result != null:
			return result
	return null


## Reset the trigger (useful for testing or re-enabling)
func reset_trigger() -> void:
	has_triggered = false
