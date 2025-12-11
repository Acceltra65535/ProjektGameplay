extends Resource
class_name S1SceneTransitionDialogues

## S1 - City Outskirts: Scene transition dialogues
## Triggered when player reaches the exit area
## Provides different destination choices based on character's story route:
##   Elias: S1 → S2 (Old Gate Checkpoint)
##   Mira:  S1 → S3 (Grey Bazaar Ruins)
##   Jonah: S1 → S4 (Perimeter Relay)

static var _avatars: Dictionary = {}

# Scene paths - update these to match your actual scene files
const SCENE_S2_CHECKPOINT := "res://scenes/old_gate_checkpoint.tscn"
const SCENE_S3_BAZAAR := "res://scenes/grey_bazaar_ruins.tscn"
const SCENE_S4_RELAY := "res://scenes/perimeter_relay.tscn"


static func _ensure_avatars() -> void:
	if _avatars.is_empty():
		_avatars["elias"] = preload("res://assets/Survivalist Sprite Sheet Pixel Art Pack/Survivalist_1/talking.png")
		_avatars["mira"] = preload("res://assets/Survivalist Sprite Sheet Pixel Art Pack/Survivalist_2/talk.png")
		_avatars["jonah"] = preload("res://assets/Survivalist Sprite Sheet Pixel Art Pack/Survivalist_3/Talking.png")


## Build transition dialogue based on current character
static func build_transition() -> DialogueGroup:
	var character_id := _get_current_character_id()
	
	match character_id:
		"elias":
			return _build_elias_transition()
		"mira":
			return _build_mira_transition()
		"jonah":
			return _build_jonah_transition()
	
	return _build_elias_transition()  # Fallback


static func _get_current_character_id() -> String:
	match Global.selected_class:
		0: return "elias"
		1: return "mira"
		2: return "jonah"
	return "elias"


## Elias: Goes to S2 - Old Gate Checkpoint
static func _build_elias_transition() -> DialogueGroup:
	_ensure_avatars()
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []
	var d: Dialogue

	d = Dialogue.new()
	d.character_name = "Elias"
	d.content = "The old checkpoint… If I want to trace those deleted logs, that's where I need to start."
	d.avatar = _avatars["elias"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Elias"
	d.content = "It's not safe, but neither is staying here waiting for the Bureau to find me."
	d.avatar = _avatars["elias"]
	d.show_on_left = true
	d.has_choices = true

	var choice_go := DialogueChoice.new()
	choice_go.choice_text = "前往旧检查站"
	choice_go.change_scene_path = SCENE_S2_CHECKPOINT
	choice_go.set_flag = "s1_completed_elias"
	choice_go.flag_value = true

	var choice_stay := DialogueChoice.new()
	choice_stay.choice_text = "再看看这里"
	# No scene change - just closes dialogue

	d.choices = [choice_go, choice_stay]
	list.append(d)

	group.diaglogue_list = list
	return group


## Mira: Goes to S3 - Grey Bazaar Ruins
static func _build_mira_transition() -> DialogueGroup:
	_ensure_avatars()
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []
	var d: Dialogue

	d = Dialogue.new()
	d.character_name = "Mira"
	d.content = "If anyone knows what this package really is, it's the traders at Grey Bazaar. They see everything that moves through this city."
	d.avatar = _avatars["mira"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Mira"
	d.content = "Time to cash in some favors… or make new enemies. Same thing, usually."
	d.avatar = _avatars["mira"]
	d.show_on_left = true
	d.has_choices = true

	var choice_go := DialogueChoice.new()
	choice_go.choice_text = "前往灰市"
	choice_go.change_scene_path = SCENE_S3_BAZAAR
	choice_go.set_flag = "s1_completed_mira"
	choice_go.flag_value = true

	var choice_stay := DialogueChoice.new()
	choice_stay.choice_text = "再看看这里"

	d.choices = [choice_go, choice_stay]
	list.append(d)

	group.diaglogue_list = list
	return group


## Jonah: Goes to S4 - Perimeter Relay
static func _build_jonah_transition() -> DialogueGroup:
	_ensure_avatars()
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []
	var d: Dialogue

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "The perimeter relay station. If the network is truly collapsing, that's where I'll find the first cracks."
	d.avatar = _avatars["jonah"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "I designed part of that system. It's time to see what we really built."
	d.avatar = _avatars["jonah"]
	d.show_on_left = true
	d.has_choices = true

	var choice_go := DialogueChoice.new()
	choice_go.choice_text = "前往中继站"
	choice_go.change_scene_path = SCENE_S4_RELAY
	choice_go.set_flag = "s1_completed_jonah"
	choice_go.flag_value = true

	var choice_stay := DialogueChoice.new()
	choice_stay.choice_text = "再看看这里"

	d.choices = [choice_go, choice_stay]
	list.append(d)

	group.diaglogue_list = list
	return group

