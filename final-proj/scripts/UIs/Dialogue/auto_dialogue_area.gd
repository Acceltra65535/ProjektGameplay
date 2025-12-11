extends Area2D
class_name AutoDialogueArea

## Automatically triggers dialogue when player enters this area.
## Attach this script to an Area2D with a CollisionShape2D child.

@export_group("Dialogue Settings")
## The DialogueGroup resource to play when triggered (optional if using dynamic loading)
@export var dialogue_group: DialogueGroup

## Story key identifier for this dialogue trigger (e.g., "city_outskirts_memory_1")
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

var has_triggered: bool = false
var dialogue_manager: DialogueManager = null


func _ready() -> void:
	# Connect area signals
	body_entered.connect(_on_body_entered)
	
	# Set up collision to detect player
	collision_layer = 0
	collision_mask = 1  # Assuming player is on layer 1


func _on_body_entered(body: Node2D) -> void:
	# Already triggered and one_shot is enabled
	if has_triggered and one_shot:
		return
	
	# Check if it's the player
	if not _is_player(body):
		return
	
	# Check character restriction
	if not _check_character_restriction():
		return
	
	# Check flag requirements
	if not _check_flag_requirements():
		return
	
	# All checks passed, trigger the dialogue
	_trigger_dialogue()


func _is_player(body: Node2D) -> bool:
	# Check if the body is in the player group
	return body.is_in_group("player") or body.is_in_group("Player")


func _check_character_restriction() -> bool:
	# No restriction if empty
	if only_for_character.is_empty():
		return true
	
	# Get current character id
	var current_character := _get_current_character_id()
	return current_character == only_for_character.to_lower()


func _get_current_character_id() -> String:
	# Map Global.selected_class to character id
	match Global.selected_class:
		0:
			return "elias"   # Balanced
		1:
			return "mira"    # Speed
		2:
			return "jonah"   # Tank
	return "elias"


func _check_flag_requirements() -> bool:
	if requires_flag.is_empty():
		return true
	return Global.check_story_flag(requires_flag, requires_flag_value)


func _trigger_dialogue() -> void:
	has_triggered = true

	# Find the dialogue manager
	dialogue_manager = _find_dialogue_manager()
	if dialogue_manager == null:
		push_warning("AutoDialogueArea: DialogueManager not found!")
		return

	# Get the dialogue group (either static or dynamic)
	var active_dialogue := _get_active_dialogue()
	if active_dialogue == null:
		push_warning("AutoDialogueArea: No dialogue available for story_key: " + story_key)
		return

	# Connect to dialogue finished signal to set flag
	if not set_flag_on_complete.is_empty():
		if not dialogue_manager.dialogue_finished.is_connected(_on_dialogue_finished):
			dialogue_manager.dialogue_finished.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)

	# Start the dialogue
	dialogue_manager.start_dialogue(active_dialogue)
	print("[AutoDialogueArea] Triggered dialogue for story_key: ", story_key)


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


func _find_dialogue_manager() -> DialogueManager:
	# Try the DialogueManager group first
	var dm := get_tree().get_first_node_in_group("DialogueManager")
	if dm != null:
		return dm as DialogueManager
	
	# Try finding by class name in the tree
	var nodes = get_tree().get_nodes_in_group("UI")
	for node in nodes:
		if node is DialogueManager:
			return node
	
	# Last resort: search all nodes
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
