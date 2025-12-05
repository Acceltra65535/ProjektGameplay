extends Resource
class_name Dialogue

@export var character_name : String
@export_multiline var content : String
@export var avatar : Texture
@export var show_on_left : bool

## If true, this dialogue will show choices instead of continuing on click
@export var has_choices : bool = false

## List of choices to display (only used if has_choices is true)
@export var choices : Array[DialogueChoice] = []

## Optional: Only show this dialogue if a specific flag is set
@export var requires_flag : String = ""

## Optional: Required flag value (default true)
@export var requires_flag_value : bool = true
