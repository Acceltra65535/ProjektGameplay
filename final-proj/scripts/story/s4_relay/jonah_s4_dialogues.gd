extends Resource
class_name JonahS4Dialogues

## S4 - Perimeter Relay Substation: Jonah's dialogues
## Jonah performs observation ritual: measuring, recording network instability
## Faces a critical choice: accept or reject the global stabilization patch

static var _avatars: Dictionary = {}


static func _ensure_avatars() -> void:
	if _avatars.is_empty():
		_avatars["jonah"] = preload("res://assets/Survivalist Sprite Sheet Pixel Art Pack/Survivalist_3/Talking.png")
		_avatars["echo"] = preload("res://assets/space_background_pack/Assets/Blue Version/layered/prop-planet-big.png")
		_avatars["recorder"] = preload("res://assets/PostApocalypse_AssetPack_v1.1.2/Objects/Washing-machine.png")
		_avatars["system"] = preload("res://assets/space_background_pack/Assets/Blue Version/layered/prop-planet-big.png")


## Main entrance dialogue - Jonah reflects on the relay
static func build_main() -> DialogueGroup:
	_ensure_avatars()
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []
	var d: Dialogue

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "Perimeter relay station. Last time I stood under one of these, we were celebrating the first successful trauma purge."
	d.avatar = _avatars["jonah"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "We toasted to 'healing at scale'. Clinical trials, clean graphs, neat little ethics reports. All the right words in all the wrong mouths."
	d.avatar = _avatars["jonah"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Recorder"
	d.content = "Diagnostic start. Signal noise: high. Echo interference: spreading. Structural integrity of memory lattice: compromised."
	d.avatar = _avatars["recorder"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "The lattice is collapsing faster than we predicted. The outskirts are resonating with memories that weren't born here."
	d.avatar = _avatars["jonah"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Memory Echo"
	d.content = "— I don't want to vote. I don't understand the question. Why is the sky that color —"
	d.avatar = _avatars["echo"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "This wasn't consent. It was mass panic dressed up as democracy. And the network locked the panic in like a fossil."
	d.avatar = _avatars["jonah"]
	d.show_on_left = true
	list.append(d)

	group.diaglogue_list = list
	return group


## Terminal scene - Jonah faces the patch choice
static func build_terminal() -> DialogueGroup:
	_ensure_avatars()
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []
	var d: Dialogue

	d = Dialogue.new()
	d.character_name = "System Voice"
	d.content = "Incoming patch: global memory stabilization routine. Approve to maintain network cohesion."
	d.avatar = _avatars["system"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "If I approve this patch, I help them tighten the mask. If I reject it, the cracks get wider, and more people start hearing voices that aren't theirs."
	d.avatar = _avatars["jonah"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Recorder"
	d.content = "Action required: patch ACCEPT or REJECT. Consequences: uncertain."
	d.avatar = _avatars["recorder"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "For once, I'd like to design a system that doesn't ask me to pick between two different ways of lying."
	d.avatar = _avatars["jonah"]
	d.show_on_left = true
	# This dialogue will have choices added
	list.append(d)

	group.diaglogue_list = list
	return group

