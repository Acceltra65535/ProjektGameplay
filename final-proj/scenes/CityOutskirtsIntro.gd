extends Node2D

var dialogue_manager: Node = null


func _ready() -> void:
	# 1) Find the DialogueManager in the scene tree
	dialogue_manager = _find_dialogue_manager()
	if dialogue_manager == null:
		push_warning("DialogueManager not found in scene tree. Check groups or node paths.")
		return

	# 2) Figure out which character is currently selected
	var character_id := _get_current_character_id()

	# 3) Build the correct intro DialogueGroup from the library
	var group: DialogueGroup = StoryDialogueLibrary.build_intro_for(character_id)
	if group == null:
		push_warning("StoryDialogueLibrary returned null intro DialogueGroup.")
		return

	# 4) Feed it into your existing dialogue_manager
	if not dialogue_manager.has_method("display_next_dialogue"):
		push_warning("DialogueManager does not have method display_next_dialogue().")
		return

	dialogue_manager.main_dialogue = group
	dialogue_manager.dialogue_index = 0
	dialogue_manager.display_next_dialogue()


func _find_dialogue_manager() -> Node:
	# First, try to find a direct child named "DialogueManager"
	if has_node("DialogueManager"):
		return get_node("DialogueManager")

	# Second, try to find any node in the tree that is in the "DialogueManager" group
	var dm := get_tree().get_first_node_in_group("DialogueManager")
	if dm != null:
		return dm

	# Nothing found
	return null


func _get_current_character_id() -> String:
	if Global.selected_class == 0:
		return "elias"
	elif Global.selected_class == 1:
		return "mira"
	elif Global.selected_class == 2:
		return "jonah"
	return "elias"
