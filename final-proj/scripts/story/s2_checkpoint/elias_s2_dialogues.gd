extends Resource
class_name EliasS2Dialogues

## S2 - Old Gate Checkpoint: Elias's dialogues
## Elias comes here to check if other recovery points are also "leaking memories"
## He discovers remotely deleted logs, indicating cover-up from above

static var _avatars: Dictionary = {}


static func _ensure_avatars() -> void:
	if _avatars.is_empty():
		_avatars["elias"] = preload("res://assets/Survivalist Sprite Sheet Pixel Art Pack/Survivalist_1/talking.png")
		_avatars["echo"] = preload("res://assets/space_background_pack/Assets/Blue Version/layered/prop-planet-big.png")


## Main entrance dialogue - Elias reflects on the old checkpoint
static func build_main() -> DialogueGroup:
	_ensure_avatars()
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []
	var d: Dialogue

	d = Dialogue.new()
	d.character_name = "Elias"
	d.content = "They used to queue all the way down the road. Scan your ID, sign the waiver, smile for the camera. Then walk out with a lighter head and a heavier silence."
	d.avatar = _avatars["elias"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Elias"
	d.content = "Back then, I told myself it was mercy. Now it just looks like a machine that eats anything we regret."
	d.avatar = _avatars["elias"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Memory Echo"
	d.content = "— Citizen 03-274B, requested removal: 'fear, guilt, fire' — approved —"
	d.avatar = _avatars["echo"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Elias"
	d.content = "Same script, same categories. Fear, guilt, fire. They never bothered to ask why we felt them in the first place."
	d.avatar = _avatars["elias"]
	d.show_on_left = true
	list.append(d)

	group.diaglogue_list = list
	return group


## Terminal interaction - Elias discovers the cover-up
static func build_terminal() -> DialogueGroup:
	_ensure_avatars()
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []
	var d: Dialogue

	d = Dialogue.new()
	d.character_name = "Elias"
	d.content = "Connection log… scrambled. Someone wiped the records after the network started leaking."
	d.avatar = _avatars["elias"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Elias"
	d.content = "So the Bureau knows the echoes are back. And instead of fixing the system, they're erasing the evidence again."
	d.avatar = _avatars["elias"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Memory Echo"
	d.content = "— We voted. We chose this. We wanted to forget —"
	d.avatar = _avatars["echo"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Elias"
	d.content = "Did we? Or did we just pick the only box that wasn't on fire?"
	d.avatar = _avatars["elias"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Elias"
	d.content = "If I can reroute one of these old lines to the outskirts relay… maybe I can see what they buried under that 'vote'."
	d.avatar = _avatars["elias"]
	d.show_on_left = true
	# Set flag to indicate Elias has discovered the cover-up
	d.has_choices = false
	list.append(d)

	group.diaglogue_list = list
	return group

