extends Resource
class_name DialogueChoice

## The text displayed on the choice button
@export var choice_text: String = ""

## Optional: Flag to set when this choice is selected (e.g., "chose_to_help")
@export var set_flag: String = ""

## Optional: Value to set for the flag (default true)
@export var flag_value: bool = true

## Optional: Required flag to show this choice (leave empty to always show)
@export var requires_flag: String = ""

## Optional: Required flag value (default true)
@export var requires_flag_value: bool = true

## The next DialogueGroup to play after selecting this choice
## If null, the dialogue will simply continue to next line or end
@export var next_dialogue_group: DialogueGroup = null

## Optional: Scene to change to after this choice (for map transitions)
## Format: "res://scenes/YourScene.tscn"
@export var change_scene_path: String = ""

