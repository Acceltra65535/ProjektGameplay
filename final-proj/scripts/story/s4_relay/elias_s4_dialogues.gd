extends Resource
class_name EliasS4Dialogues

## S4 - Perimeter Relay Substation: Elias's dialogues
## Elias attempts to access the relay station to see what they buried
## Triggers a severe Memory Echo, seeing fragments of the vote day

static var _avatars: Dictionary = {}


static func _ensure_avatars() -> void:
	if _avatars.is_empty():
		_avatars["elias"] = preload("res://assets/Survivalist Sprite Sheet Pixel Art Pack/Survivalist_1/talking.png")
		_avatars["echo"] = preload("res://assets/space_background_pack/Assets/Blue Version/layered/prop-planet-big.png")
		_avatars["system"] = preload("res://assets/space_background_pack/Assets/Blue Version/layered/prop-planet-big.png")


## Main entrance dialogue - Elias approaches the relay
static func build_main() -> DialogueGroup:
	_ensure_avatars()
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []
	var d: Dialogue

	d = Dialogue.new()
	d.character_name = "Elias"
	d.content = "The perimeter relay. Last time I was here, we were installing the emergency broadcast override. 'For public safety', they said."
	d.avatar = _avatars["elias"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Elias"
	d.content = "Safety. Right. Because nothing says 'safe' like a system that can erase panic from an entire city in real time."
	d.avatar = _avatars["elias"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Elias"
	d.content = "The access codes should still work. If the Bureau hasn't locked me out yet."
	d.avatar = _avatars["elias"]
	d.show_on_left = true
	list.append(d)

	group.diaglogue_list = list
	return group


## Memory Echo scene - Elias sees the vote day fragments
static func build_echo() -> DialogueGroup:
	_ensure_avatars()
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []
	var d: Dialogue

	d = Dialogue.new()
	d.character_name = "System Voice"
	d.content = "— Connection established. Memory lattice synchronizing… WARNING: Echo contamination detected —"
	d.avatar = _avatars["system"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Memory Echo"
	d.content = "— The sky was wrong. The color was wrong. They told us to vote but the question didn't make sense —"
	d.avatar = _avatars["echo"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Elias"
	d.content = "This… this isn't someone else's memory. This is—"
	d.avatar = _avatars["elias"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Memory Echo"
	d.content = "— Press CONFIRM to forget. Press CONFIRM to start over. CONFIRM. CONFIRM. CONFIRM —"
	d.avatar = _avatars["echo"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Elias"
	d.content = "I remember pressing that button. I remember thinking it was the only way. But I can't remember why."
	d.avatar = _avatars["elias"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Memory Echo"
	d.content = "— Technician Reyes, Elias. Memory purge: complete. Guilt index: zeroed. Welcome to the new beginning —"
	d.avatar = _avatars["echo"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Elias"
	d.content = "They erased my guilt. The guilt of helping them erase everyone else."
	d.avatar = _avatars["elias"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Elias"
	d.content = "I don't know what I did before the vote. But I'm starting to remember why I forgot."
	d.avatar = _avatars["elias"]
	d.show_on_left = true
	list.append(d)

	group.diaglogue_list = list
	return group

