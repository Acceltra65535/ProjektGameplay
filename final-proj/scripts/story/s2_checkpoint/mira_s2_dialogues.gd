extends Resource
class_name MiraS2Dialogues

## S2 - Old Gate Checkpoint: Mira's dialogues
## Mira takes the abandoned passage through the old checkpoint to bypass into the city
## She encounters Memory Tax Bureau equipment and realizes she's been "marked"

static var _avatars: Dictionary = {}


static func _ensure_avatars() -> void:
	if _avatars.is_empty():
		_avatars["mira"] = preload("res://assets/Survivalist Sprite Sheet Pixel Art Pack/Survivalist_2/talk.png")
		_avatars["radio"] = preload("res://assets/space_background_pack/RC Art - Orbital Cannon/Sprites/Type A Ion Cannon_5.png")
		_avatars["system"] = preload("res://assets/space_background_pack/Assets/Blue Version/layered/prop-planet-big.png")


## Main entrance dialogue - Mira sneaks through the checkpoint
static func build_main() -> DialogueGroup:
	_ensure_avatars()
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []
	var d: Dialogue

	d = Dialogue.new()
	d.character_name = "Mira"
	d.content = "Old Gate checkpoint. They sealed the main road years ago, but couriers always find a way through the cracks."
	d.avatar = _avatars["mira"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Mira"
	d.content = "Branko said this passage was clean. Of course, Branko also said the package was 'just old books'. Look how that turned out."
	d.avatar = _avatars["mira"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Mira"
	d.content = "The walls still have those old posters: 'Memory Correction Makes Life Lighter'. Someone scratched 'LIES' across every single one."
	d.avatar = _avatars["mira"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Mira"
	d.content = "Can't argue with vandalism that accurate."
	d.avatar = _avatars["mira"]
	d.show_on_left = true
	list.append(d)

	group.diaglogue_list = list
	return group


## Discovery scene - Mira finds Bureau equipment and gets scanned
static func build_discovery() -> DialogueGroup:
	_ensure_avatars()
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []
	var d: Dialogue

	d = Dialogue.new()
	d.character_name = "System Voice"
	d.content = "— Proximity scan active. Courier ID detected: Kessler, Mira. Flagged cargo in range —"
	d.avatar = _avatars["system"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Mira"
	d.content = "What the— This thing is still running? The whole checkpoint is supposed to be dead!"
	d.avatar = _avatars["mira"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "System Voice"
	d.content = "— Alert dispatched. Memory Tax Bureau field unit en route. Estimated arrival: 4 minutes —"
	d.avatar = _avatars["system"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Mira"
	d.content = "Four minutes. Great. Just enough time to panic and make bad decisions."
	d.avatar = _avatars["mira"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Mira"
	d.content = "They've been tracking this package the whole time. Which means they let me walk right into their trap."
	d.avatar = _avatars["mira"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Unknown Voice"
	d.content = "— The box knows the way. The box remembers what you forgot —"
	d.avatar = _avatars["radio"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Mira"
	d.content = "Okay, creepy cargo, I get it. You're important. Now shut up and let me find a back exit before I become evidence."
	d.avatar = _avatars["mira"]
	d.show_on_left = true
	list.append(d)

	group.diaglogue_list = list
	return group

