extends Resource
class_name JonahS3Dialogues

## S3 - Grey Bazaar Ruins: Jonah's dialogues
## Jonah comes to collect civilian "symptoms" and rumors
## He hears about the other two protagonists' activities

static var _avatars: Dictionary = {}


static func _ensure_avatars() -> void:
	if _avatars.is_empty():
		_avatars["jonah"] = preload("res://assets/Survivalist Sprite Sheet Pixel Art Pack/Survivalist_3/Talking.png")
		_avatars["vendor"] = preload("res://assets/space_background_pack/RC Art - Orbital Cannon/Sprites/Type A Ion Cannon_5.png")
		_avatars["recorder"] = preload("res://assets/PostApocalypse_AssetPack_v1.1.2/Objects/Washing-machine.png")


## Main entrance dialogue - Jonah observes the bazaar's state
static func build_main() -> DialogueGroup:
	_ensure_avatars()
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []
	var d: Dialogue

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "The grey market. Where people trade what they can't afford to remember for things they shouldn't have forgotten."
	d.avatar = _avatars["jonah"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Recorder"
	d.content = "Field note: Bazaar population reduced by approximately 70%. Remaining inhabitants show signs of acute memory disturbance."
	d.avatar = _avatars["recorder"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "The symptoms are spreading faster than the official models predicted. We designed the network to contain trauma, not multiply it."
	d.avatar = _avatars["jonah"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "I need firsthand accounts. If I can map the pattern of these echoes, maybe I can trace them back to the source."
	d.avatar = _avatars["jonah"]
	d.show_on_left = true
	list.append(d)

	group.diaglogue_list = list
	return group


## Rumors scene - Jonah hears about Elias and Mira
static func build_rumors() -> DialogueGroup:
	_ensure_avatars()
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []
	var d: Dialogue

	d = Dialogue.new()
	d.character_name = "Vendor"
	d.content = "You're asking about the echoes? Join the club. Two others came through asking the same thing this week."
	d.avatar = _avatars["vendor"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "Two others? Who?"
	d.avatar = _avatars["jonah"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Vendor"
	d.content = "Some technician type, poking around the old checkpoint. Said he used to work the memory stations. Looked like he hadn't slept in days."
	d.avatar = _avatars["vendor"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "A station technician… interesting. And the other?"
	d.avatar = _avatars["jonah"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Vendor"
	d.content = "Courier. Young, fast, carrying something the Bureau wants badly enough to raid the whole market. She went dark after the sweep."
	d.avatar = _avatars["vendor"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "A technician and a courier, both circling the same anomaly. This isn't random decay. Someone is pulling threads."
	d.avatar = _avatars["jonah"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Recorder"
	d.content = "Hypothesis updated: Multiple actors investigating network failure. Convergence probability increasing."
	d.avatar = _avatars["recorder"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "If our paths cross, I hope they're looking for answers too. And not just trying to bury more questions."
	d.avatar = _avatars["jonah"]
	d.show_on_left = true
	list.append(d)

	group.diaglogue_list = list
	return group
