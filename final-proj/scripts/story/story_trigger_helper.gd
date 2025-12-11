extends Resource
class_name StoryTriggerHelper

## Helper class to create DialogueGroups for Area2D triggers
## Usage: In your AutoDialogueArea or InteractDialogueArea, call:
##   dialogue_group = StoryTriggerHelper.get_dialogue("s2", "elias", "terminal")

static func get_dialogue(scene_id: String, character_id: String, trigger_key: String = "main") -> DialogueGroup:
	return StoryDialogueLibrary.build_dialogue(scene_id, character_id, trigger_key)


## Check if a dialogue exists for the given parameters
static func has_dialogue(scene_id: String, character_id: String, trigger_key: String = "main") -> bool:
	var result = StoryDialogueLibrary.build_dialogue(scene_id, character_id, trigger_key)
	return result != null


## Get the current character ID based on Global.selected_class
static func get_current_character_id() -> String:
	match Global.selected_class:
		0: return "elias"
		1: return "mira"
		2: return "jonah"
	return "elias"


# =============================================================================
# AREA2D TRIGGER CONFIGURATION REFERENCE
# =============================================================================
# This section documents all the Area2D triggers and their configurations.
# Copy these configurations when setting up triggers in scenes.
# =============================================================================

# -----------------------------------------------------------------------------
# S1 - CITY OUTSKIRTS (城市荒郊)
# -----------------------------------------------------------------------------
# Scene: res://scenes/city_outskirts.tscn (or similar)
#
# TRIGGER: s1_intro_auto (Area2D at spawn point)
#   Type: AutoDialogueArea
#   story_key: "s1_intro"
#   only_for_character: "" (all characters)
#   one_shot: true
#   use_dynamic_loading: true
#   scene_id: "s1"
#   trigger_key: "intro"
#   Notes: Auto-triggers intro dialogue based on selected character
#
# TRIGGER: s1_exit_transition (Area2D at scene exit/edge)
#   Type: AutoDialogueArea
#   story_key: "s1_transition"
#   only_for_character: "" (all characters, different destinations)
#   one_shot: false (player can revisit if they choose "再看看这里")
#   use_dynamic_loading: true
#   scene_id: "s1"
#   trigger_key: "transition"
#   Notes: Shows character-specific dialogue with scene change choice
#     - Elias → 旧检查站 (S2)
#     - Mira  → 灰市 (S3)
#     - Jonah → 中继站 (S4)

# -----------------------------------------------------------------------------
# S2 - OLD GATE CHECKPOINT (旧记忆关卡口)
# -----------------------------------------------------------------------------
# Scene: res://scenes/old_gate_checkpoint.tscn
#
# TRIGGER: s2_entrance_auto (Area2D at scene entrance)
#   Type: AutoDialogueArea
#   story_key: "s2_entrance"
#   only_for_character: "" (both Elias and Mira have S2 dialogues)
#   one_shot: true
#   For Elias: StoryDialogueLibrary.build_dialogue("s2", "elias", "main")
#   For Mira:  StoryDialogueLibrary.build_dialogue("s2", "mira", "main")
#
# TRIGGER: s2_terminal_interact (Area2D near the old terminal)
#   Type: InteractDialogueArea
#   story_key: "s2_terminal"
#   only_for_character: "elias" (only Elias interacts with terminal)
#   one_shot: true
#   dialogue_group: StoryDialogueLibrary.build_dialogue("s2", "elias", "terminal")
#   set_flag_on_complete: "elias_found_coverup"
#
# TRIGGER: s2_scanner_auto (Area2D near Bureau equipment)
#   Type: AutoDialogueArea
#   story_key: "s2_discovery"
#   only_for_character: "mira" (only Mira gets scanned)
#   one_shot: true
#   dialogue_group: StoryDialogueLibrary.build_dialogue("s2", "mira", "discovery")
#   set_flag_on_complete: "mira_marked_by_bureau"

# -----------------------------------------------------------------------------
# S3 - GREY BAZAAR RUINS (灰市残骸)
# -----------------------------------------------------------------------------
# Scene: res://scenes/grey_bazaar_ruins.tscn
#
# TRIGGER: s3_entrance_auto (Area2D at bazaar entrance)
#   Type: AutoDialogueArea
#   story_key: "s3_entrance"
#   only_for_character: "" (both Mira and Jonah have S3 dialogues)
#   one_shot: true
#   For Mira:  StoryDialogueLibrary.build_dialogue("s3", "mira", "main")
#   For Jonah: StoryDialogueLibrary.build_dialogue("s3", "jonah", "main")
#
# TRIGGER: s3_vendor_interact (Area2D near remaining vendor NPC)
#   Type: InteractDialogueArea
#   story_key: "s3_vendor"
#   only_for_character: "" (both can talk to vendor)
#   one_shot: true
#   For Mira:  StoryDialogueLibrary.build_dialogue("s3", "mira", "vendor")
#   For Jonah: StoryDialogueLibrary.build_dialogue("s3", "jonah", "rumors")
#   interact_hint_text: "按 E 与摊贩交谈"

# -----------------------------------------------------------------------------
# S4 - PERIMETER RELAY SUBSTATION (外环中继站)
# -----------------------------------------------------------------------------
# Scene: res://scenes/perimeter_relay.tscn
#
# TRIGGER: s4_entrance_auto (Area2D at relay entrance)
#   Type: AutoDialogueArea
#   story_key: "s4_entrance"
#   only_for_character: "" (both Elias and Jonah have S4 dialogues)
#   one_shot: true
#   For Elias: StoryDialogueLibrary.build_dialogue("s4", "elias", "main")
#   For Jonah: StoryDialogueLibrary.build_dialogue("s4", "jonah", "main")
#
# TRIGGER: s4_terminal_interact (Area2D near main terminal)
#   Type: InteractDialogueArea
#   story_key: "s4_terminal"
#   only_for_character: "" (both interact with terminal)
#   one_shot: true
#   For Elias: StoryDialogueLibrary.build_dialogue("s4", "elias", "memory_echo")
#   For Jonah: StoryDialogueLibrary.build_dialogue("s4", "jonah", "terminal")
#              Then: StoryDialogueLibrary.build_dialogue("s4", "jonah", "choice")
#   set_flag_on_complete: "accessed_relay_terminal"
#   interact_hint_text: "按 E 接入终端"

