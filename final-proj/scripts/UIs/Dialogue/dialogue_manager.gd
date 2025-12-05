extends Control
class_name DialogueManager

@export_group("UI")
@export var character_name_text : Label
@export var text_box : Label
@export var left_avatar : TextureRect
@export var right_avatar : TextureRect

@export_group("Choice UI")
## Container that holds the choice buttons (VBoxContainer recommended)
@export var choice_container : Container
## Template button to duplicate for each choice (will be hidden)
@export var choice_button_template : Button

@export_group("Dialogue")
@export var main_dialogue : DialogueGroup


var dialogue_index : int = 0
var typing_tween : Tween
var is_active : bool = false
var is_showing_choices : bool = false  # True when waiting for player to pick a choice

signal dialogue_started
signal dialogue_finished
signal choice_made(choice_index: int, choice: DialogueChoice)  # Emitted when player selects a choice


func _ready() -> void:
	# At scene start, the chatbox is hidden and inactive.
	# External scripts (like CityOutskirtsIntro) will call start_dialogue().
	visible = false
	is_active = false
	dialogue_index = 0

	# Hide choice UI elements
	_hide_choices()


func start_dialogue(group: DialogueGroup) -> void:
	# Called by external scripts to begin a dialogue sequence.
	if group == null:
		return

	main_dialogue = group
	dialogue_index = 0
	is_active = true
	visible = true
	is_showing_choices = false

	emit_signal("dialogue_started")
	# Show the first line
	display_next_dialogue()


func display_next_dialogue() -> void:
	# If dialogue is not active or showing choices, ignore click-to-advance
	if not is_active or is_showing_choices:
		return

	if main_dialogue == null:
		return

	var list := main_dialogue.diaglogue_list
	if list.is_empty():
		_end_dialogue()
		return

	# Skip dialogues that don't meet flag requirements
	while dialogue_index < list.size():
		var check_dialogue: Dialogue = list[dialogue_index]
		if _check_dialogue_requirements(check_dialogue):
			break
		dialogue_index += 1

	# If we are beyond the last line, end the dialogue and hide the chatbox.
	if dialogue_index >= list.size():
		_end_dialogue()
		return

	var dialogue: Dialogue = list[dialogue_index]

	# If we are currently typing the line, skip to its end on click.
	if typing_tween and typing_tween.is_running():
		typing_tween.kill()
		text_box.text = dialogue.content
		# After text is shown, check if we need to show choices
		if dialogue.has_choices and dialogue.choices.size() > 0:
			_show_choices(dialogue.choices)
		else:
			dialogue_index += 1
	else:
		# Start typing animation for this line
		character_name_text.text = dialogue.character_name

		if typing_tween and typing_tween.is_running():
			typing_tween.kill()

		typing_tween = get_tree().create_tween()
		text_box.text = ""

		for character in dialogue.content:
			typing_tween.tween_callback(append_character.bind(character)).set_delay(0.04)

		# After typing finishes, either show choices or advance
		if dialogue.has_choices and dialogue.choices.size() > 0:
			typing_tween.tween_callback(_show_choices.bind(dialogue.choices))
		else:
			typing_tween.tween_callback(func(): dialogue_index += 1)

		# Update avatars based on which side the speaker is on
		_update_avatars(dialogue)


func append_character(character : String) -> void:
	if text_box:
		text_box.text += character


func _update_avatars(dialogue: Dialogue) -> void:
	if dialogue.show_on_left:
		if left_avatar:
			left_avatar.texture = dialogue.avatar
		if right_avatar:
			right_avatar.texture = null
	else:
		if left_avatar:
			left_avatar.texture = null
		if right_avatar:
			right_avatar.texture = dialogue.avatar


func _check_dialogue_requirements(dialogue: Dialogue) -> bool:
	# Check if this dialogue meets the flag requirements
	if dialogue.requires_flag.is_empty():
		return true
	return Global.check_story_flag(dialogue.requires_flag, dialogue.requires_flag_value)


func _end_dialogue() -> void:
	# Stop any running tween
	if typing_tween and typing_tween.is_running():
		typing_tween.kill()

	_hide_choices()
	is_active = false
	is_showing_choices = false
	visible = false
	emit_signal("dialogue_finished")


# ============================================================
# Choice System
# ============================================================

func _show_choices(choices: Array[DialogueChoice]) -> void:
	if choice_container == null or choice_button_template == null:
		push_warning("DialogueManager: Choice UI not configured! Set choice_container and choice_button_template.")
		# Fallback: just advance to next dialogue
		dialogue_index += 1
		return

	is_showing_choices = true

	# Clear existing choice buttons (except template)
	for child in choice_container.get_children():
		if child != choice_button_template:
			child.queue_free()

	# Create buttons for each valid choice
	var valid_choice_index := 0
	for i in range(choices.size()):
		var choice: DialogueChoice = choices[i]

		# Check if this choice meets flag requirements
		if not choice.requires_flag.is_empty():
			if not Global.check_story_flag(choice.requires_flag, choice.requires_flag_value):
				continue

		# Create button from template
		var button: Button = choice_button_template.duplicate()
		button.text = choice.choice_text
		button.visible = true
		button.pressed.connect(_on_choice_selected.bind(i, choice))
		choice_container.add_child(button)
		valid_choice_index += 1

	# Show the choice container
	choice_container.visible = true
	choice_button_template.visible = false


func _hide_choices() -> void:
	is_showing_choices = false
	if choice_container:
		# Remove all choice buttons except template
		for child in choice_container.get_children():
			if child != choice_button_template:
				child.queue_free()
		choice_container.visible = false
	if choice_button_template:
		choice_button_template.visible = false


func _on_choice_selected(choice_index: int, choice: DialogueChoice) -> void:
	# Set flag if specified
	if not choice.set_flag.is_empty():
		Global.set_story_flag(choice.set_flag, choice.flag_value)

	# Emit signal for external listeners
	emit_signal("choice_made", choice_index, choice)

	# Hide choices
	_hide_choices()

	# Handle scene change if specified
	if not choice.change_scene_path.is_empty():
		_end_dialogue()
		get_tree().change_scene_to_file(choice.change_scene_path)
		return

	# Handle branching dialogue
	if choice.next_dialogue_group != null:
		# Start the new dialogue group
		main_dialogue = choice.next_dialogue_group
		dialogue_index = 0
		display_next_dialogue()
	else:
		# Just continue to next dialogue line
		dialogue_index += 1
		display_next_dialogue()


func _on_click(event: InputEvent) -> void:
	# This should be connected to the root Control's "gui_input" signal
	# or to a Panel that covers the whole chatbox.
	if not is_active:
		return

	# Don't advance dialogue if showing choices (player must click a choice button)
	if is_showing_choices:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		display_next_dialogue()
		# Godot 4.x: mark this input as handled so it does not leak to gameplay
		get_viewport().set_input_as_handled()


# ============================================================
# Utility Functions for External Use
# ============================================================

## Show a standalone choice menu (for scene transitions, etc.)
## This can be called without a dialogue - just shows choices directly
func show_standalone_choices(choices: Array[DialogueChoice], title: String = "") -> void:
	is_active = true
	visible = true
	is_showing_choices = false  # Will be set true by _show_choices

	# Show title if provided
	if character_name_text:
		character_name_text.text = title
	if text_box:
		text_box.text = ""

	# Hide avatars for standalone choices
	if left_avatar:
		left_avatar.texture = null
	if right_avatar:
		right_avatar.texture = null

	emit_signal("dialogue_started")
	_show_choices(choices)
