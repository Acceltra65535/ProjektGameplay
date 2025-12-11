extends Resource
class_name MiraS3Dialogues

## S3 - Grey Bazaar Ruins: Mira's dialogues
## Mira tries to find her black market contact to learn about the package
## Discovers the contact has been "cleaned" and the market is evacuating

static var _avatars: Dictionary = {}


static func _ensure_avatars() -> void:
	if _avatars.is_empty():
		_avatars["mira"] = preload("res://assets/Survivalist Sprite Sheet Pixel Art Pack/Survivalist_2/talk.png")
		_avatars["vendor"] = preload("res://assets/space_background_pack/RC Art - Orbital Cannon/Sprites/Type A Ion Cannon_5.png")


## Main entrance dialogue - Mira surveys the abandoned bazaar
static func build_main() -> DialogueGroup:
	_ensure_avatars()
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []
	var d: Dialogue

	d = Dialogue.new()
	d.character_name = "Mira"
	d.content = "Last week this place was noise and neon. Now it's just burnt cloth and footprints. Grey Bazaar doesn't die, it just sheds a skin."
	d.avatar = _avatars["mira"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Mira"
	d.content = "Hey, Branko. You still owe me three filters and a radio that doesn't explode on startup. You better not have skipped town without paying."
	d.avatar = _avatars["mira"]
	d.show_on_left = true
	list.append(d)

	group.diaglogue_list = list
	return group


## Vendor interaction - Mira learns about the Bureau raid
static func build_vendor() -> DialogueGroup:
	_ensure_avatars()
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []
	var d: Dialogue

	d = Dialogue.new()
	d.character_name = "Vendor"
	d.content = "If you're looking for Branko, you're late. Tax Bureau came through yesterday. Questions, scanners, then… nothing."
	d.avatar = _avatars["vendor"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Mira"
	d.content = "Bureau doesn't walk this far out just to ask questions. What were they hunting?"
	d.avatar = _avatars["mira"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Vendor"
	d.content = "Something that came in from the outskirts. Big payout, no description, no barcode. Route ran through you couriers, right?"
	d.avatar = _avatars["vendor"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Mira"
	d.content = "Great. So I've been babysitting the only parcel in the city important enough to clean out an entire market."
	d.avatar = _avatars["mira"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Vendor"
	d.content = "People say they're recalibrating the whole network. Wiping glitches. Wiping anyone who remembers the glitches."
	d.avatar = _avatars["vendor"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Mira"
	d.content = "If this box is part of that 'recalibration', I've got two options: hand it to the Bureau and watch everyone forget… or open it and find out what they shouldn't be selling."
	d.avatar = _avatars["mira"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Vendor"
	d.content = "Just… don't open it here. We still have to sleep near this place."
	d.avatar = _avatars["vendor"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Mira"
	d.content = "Relax. I'll find a nice quiet checkpoint to ruin instead."
	d.avatar = _avatars["mira"]
	d.show_on_left = true
	list.append(d)

	group.diaglogue_list = list
	return group

