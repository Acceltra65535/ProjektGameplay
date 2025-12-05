extends Node

# 0 balanced, 1 speed, 2 tank
var selected_class: int = 0

var pending_load_data: Resource = null

# ============================================================
# Story Flags System
# ============================================================
# Dictionary to store story flags that affect dialogue and game progression
# Example flags: "helped_survivor", "chose_violence", "found_secret_key"
var story_flags: Dictionary = {}


## Set a story flag to a specific value
func set_story_flag(flag_name: String, value: bool = true) -> void:
	story_flags[flag_name] = value
	print("[Global] Story flag set: ", flag_name, " = ", value)


## Get a story flag value (returns false if not set)
func get_story_flag(flag_name: String) -> bool:
	return story_flags.get(flag_name, false)


## Check if a story flag matches a specific value
func check_story_flag(flag_name: String, expected_value: bool = true) -> bool:
	if flag_name.is_empty():
		return true  # No requirement means always pass
	return story_flags.get(flag_name, false) == expected_value


## Clear all story flags (for new game)
func clear_story_flags() -> void:
	story_flags.clear()
	print("[Global] All story flags cleared")


## Get all flags as a dictionary (for saving)
func get_all_flags() -> Dictionary:
	return story_flags.duplicate()


## Load flags from a dictionary (for loading saves)
func load_flags(flags: Dictionary) -> void:
	story_flags = flags.duplicate()
	print("[Global] Story flags loaded: ", story_flags.keys())
