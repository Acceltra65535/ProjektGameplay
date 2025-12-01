extends Node2D

var dialogue_manager: DialogueManager = null
var intro_group: DialogueGroup = null

var intro_started: bool = false
var intro_finished: bool = false


func _ready() -> void:
	# 1) Find the DialogueManager node in this scene
	dialogue_manager = _find_dialogue_manager()
	if dialogue_manager == null:
		push_warning("DialogueManager not found in scene tree.")
		return

	# 2) Connect signals so we can freeze/unfreeze actors
	#    These signals are defined in DialogueManager.
	dialogue_manager.dialogue_started.connect(_on_dialogue_started)
	dialogue_manager.dialogue_finished.connect(_on_dialogue_finished)

	# 3) Build the intro DialogueGroup based on the current character
	var character_id := _get_current_character_id()
	intro_group = StoryDialogueLibrary.build_intro_for(character_id)
	if intro_group == null:
		push_warning("StoryDialogueLibrary returned null intro DialogueGroup.")
		return

	# 4) Make sure dialogue UI is hidden at scene start.
	#    DialogueManager._ready() already sets visible = false and is_active = false,
	#    so we do not need to touch is_active here.
	dialogue_manager.visible = false


func _unhandled_input(event: InputEvent) -> void:
	# Before the intro has started:
	# any key press will start the intro dialogue once.
	if intro_started:
		return
	if intro_group == null:
		return

	if event.is_pressed() and not event.is_echo():
		intro_started = true
		dialogue_manager.start_dialogue(intro_group)

		# Godot 4.x: mark this input as handled
		get_viewport().set_input_as_handled()


func _find_dialogue_manager() -> DialogueManager:
	# First, try direct child named "DialogueManager"
	if has_node("DialogueManager"):
		return get_node("DialogueManager") as DialogueManager

	# Second, try any node in the "DialogueManager" group
	var dm := get_tree().get_first_node_in_group("DialogueManager")
	if dm != null:
		return dm as DialogueManager

	return null


func _get_current_character_id() -> String:
	# Map your existing character selection to story ids
	if Global.selected_class == 0:
		return "elias"   # Balanced
	elif Global.selected_class == 1:
		return "mira"    # Speed
	elif Global.selected_class == 2:
		return "jonah"   # Tank

	return "elias"


func _on_dialogue_started() -> void:
	# Freeze the player and enemies while dialogue is active.
	# You must implement set_frozen(true/false) on those scripts
	# and make sure they are in the correct groups.

	var player := get_tree().get_first_node_in_group("Player")
	if player != null and player.has_method("set_frozen"):
		player.set_frozen(true)

	var enemies := get_tree().get_nodes_in_group("Enemy")
	for e in enemies:
		if e.has_method("set_frozen"):
			e.set_frozen(true)


func _on_dialogue_finished() -> void:
	intro_finished = true

	# Unfreeze the player and enemies after dialogue ends
	var player := get_tree().get_first_node_in_group("Player")
	if player != null and player.has_method("set_frozen"):
		player.set_frozen(false)

	var enemies := get_tree().get_nodes_in_group("Enemy")
	for e in enemies:
		if e.has_method("set_frozen"):
			e.set_frozen(false)
