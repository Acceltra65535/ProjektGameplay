extends Control
class_name DialogueManager

@export_group("UI")
@export var character_name_text : Label
@export var text_box : Label
@export var left_avatar : TextureRect
@export var right_avatar : TextureRect

@export_group("Dialogue")
@export var main_dialogue : DialogueGroup


var dialogue_index : int = 0
var typing_tween : Tween
var is_active : bool = false

signal dialogue_started
signal dialogue_finished


func _ready() -> void:
	# At scene start, the chatbox is hidden and inactive.
	# External scripts (like CityOutskirtsIntro) will call start_dialogue().
	visible = false
	is_active = false
	dialogue_index = 0


func start_dialogue(group: DialogueGroup) -> void:
	# Called by external scripts to begin a dialogue sequence.
	if group == null:
		return

	main_dialogue = group
	dialogue_index = 0
	is_active = true
	visible = true

	emit_signal("dialogue_started")
	# Show the first line
	display_next_dialogue()


func display_next_dialogue() -> void:
	# If dialogue is not active, ignore any requests.
	if not is_active:
		return

	if main_dialogue == null:
		return

	var list := main_dialogue.diaglogue_list
	if list.is_empty():
		_end_dialogue()
		return

	# If we are beyond the last line, end the dialogue and hide the chatbox.
	if dialogue_index >= list.size():
		_end_dialogue()
		return

	var dialogue: Dialogue = list[dialogue_index]

	# If we are currently typing the line, skip to its end on click.
	if typing_tween and typing_tween.is_running():
		typing_tween.kill()
		text_box.text = dialogue.content
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

		typing_tween.tween_callback(func(): dialogue_index += 1)

		# Update avatars based on which side the speaker is on
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


func append_character(character : String) -> void:
	if text_box:
		text_box.text += character


func _end_dialogue() -> void:
	# Stop any running tween
	if typing_tween and typing_tween.is_running():
		typing_tween.kill()

	is_active = false
	visible = false
	emit_signal("dialogue_finished")


func _on_click(event: InputEvent) -> void:
	# This should be connected to the root Control's "gui_input" signal
	# or to a Panel that covers the whole chatbox.
	if not is_active:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		display_next_dialogue()
		# Godot 4.x: mark this input as handled so it does not leak to gameplay
		get_viewport().set_input_as_handled()
