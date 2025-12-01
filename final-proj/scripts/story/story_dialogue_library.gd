extends Resource
class_name StoryDialogueLibrary

# This uses your existing Dialogue / DialogueGroup classes
# Make sure dialogue.gd and dialogue_group.gd have:
#   class_name Dialogue
#   class_name DialogueGroup

static func build_intro_for(character_id: String) -> DialogueGroup:
	# Select which intro to build depending on the character id
	match character_id:
		"elias":
			return _build_elias_intro()
		"mira":
			return _build_mira_intro()
		"jonah":
			return _build_jonah_intro()
		_:
			return _build_elias_intro()  # Fallback


# ---------------- Elias intro ----------------

static func _build_elias_intro() -> DialogueGroup:
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []

	# Change these paths to your actual avatar textures
	var avatar_elias := preload("res://assets/Survivalist Sprite Sheet Pixel Art Pack/Survivalist_1/talking.png")
	var avatar_echo  := preload("res://assets/space_background_pack/Assets/Blue Version/layered/prop-planet-big.png")

	var d: Dialogue

	d = Dialogue.new()
	d.character_name = "Elias"
	d.content = "Power’s dead, logs are wiped… and they still call this place a ‘service station’."
	d.avatar = avatar_elias
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Elias"
	d.content = "Half the city lined up here once, begging to forget. I kept the machines alive. Kept the line moving."
	d.avatar = avatar_elias
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Memory Echo"
	d.content = "— Please, just take last year. I don’t want to remember the sirens —"
	d.avatar = avatar_echo
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Elias"
	d.content = "…That voice again. This terminal’s been dead for years. The memories shouldn’t still be leaking."
	d.avatar = avatar_elias
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Elias"
	d.content = "If the Bureau finds out this station is still echoing, they’ll send a cleanup squad. And I’m standing right in the middle of it."
	d.avatar = avatar_elias
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Elias"
	d.content = "I should walk away. Pretend I never worked here. Pretend I never helped them erase anyone."
	d.avatar = avatar_elias
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Elias"
	d.content = "…Or I open up the core, pull out whatever’s growing inside, and finally see what they hid from us."
	d.avatar = avatar_elias
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Memory Echo"
	d.content = "— Someone has to remember why the world went quiet —"
	d.avatar = avatar_echo
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Elias"
	d.content = "Fine. One last repair job. This time, I’m not erasing anything."
	d.avatar = avatar_elias
	d.show_on_left = true
	list.append(d)

	group.diaglogue_list = list
	return group


# ---------------- Mira intro ----------------

static func _build_mira_intro() -> DialogueGroup:
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []

	var avatar_mira := preload("res://assets/Survivalist Sprite Sheet Pixel Art Pack/Survivalist_2/talk.png")
	var avatar_radio := preload("res://assets/space_background_pack/RC Art - Orbital Cannon/Sprites/Type A Ion Cannon_5.png")

	var d: Dialogue

	d = Dialogue.new()
	d.character_name = "Mira"
	d.content = "No stalls, no guards, no drunks arguing over rations. Just ash and footprints. Guess the market finally moved on without me."
	d.avatar = avatar_mira
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Mira"
	d.content = "They said this run was ‘urgent, delicate, triple pay’. Should’ve known that meant ‘you’ll arrive after everyone’s already dead or gone’."
	d.avatar = avatar_mira
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Mira"
	d.content = "Package says: ‘Deliver to City Outskirts, Old Gate… do not open, do not connect’. That’s exactly the kind of thing you open and connect."
	d.avatar = avatar_mira
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Mira"
	d.content = "Last time I trusted a sealed crate, it turned out to be a live turret. This one better not be worse than that."
	d.avatar = avatar_mira
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Unknown Voice"
	d.content = "— Courier ID: Kessler, Mira. Delivery route flagged. Memory tax overdue —"
	d.avatar = avatar_radio
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Mira"
	d.content = "…That’s not funny. This radio’s been dead for weeks. And I don’t owe them anything except a broken bike."
	d.avatar = avatar_mira
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Mira"
	d.content = "Alright, mystery box. If you’re what they’re hunting, either I sell you to the highest bidder… or I finally learn what everyone’s so afraid of remembering."
	d.avatar = avatar_mira
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Unknown Voice"
	d.content = "— If delivered, the city forgets. If opened, the city remembers —"
	d.avatar = avatar_radio
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Mira"
	d.content = "Perfect. Another choice nobody paid me enough to make."
	d.avatar = avatar_mira
	d.show_on_left = true
	list.append(d)

	group.diaglogue_list = list
	return group


# ---------------- Jonah intro ----------------

static func _build_jonah_intro() -> DialogueGroup:
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []

	var avatar_jonah    := preload("res://assets/Survivalist Sprite Sheet Pixel Art Pack/Survivalist_3/Talking.png")
	var avatar_echo     := preload("res://assets/space_background_pack/Assets/Blue Version/layered/prop-planet-big.png")
	var avatar_recorder := preload("res://assets/PostApocalypse_AssetPack_v1.1.2/Objects/Washing-machine.png")

	var d: Dialogue

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "The city still glows at night. Duller than before, but it glows. Like a patient pretending the fever is gone."
	d.avatar = avatar_jonah
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "We scrubbed their nightmares, their guilt, their memories of the vote… and expected them to rebuild something kinder on top."
	d.avatar = avatar_jonah
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "Instead, they built taller walls and louder broadcasts. Less memory, more noise."
	d.avatar = avatar_jonah
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Recorder"
	d.content = "Test log: Subject— myself. Symptom: recurring echoes of foreign memories near city perimeter. Hypothesis: the network’s decay is accelerating."
	d.avatar = avatar_recorder
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "If the outskirts are already leaking, the core won’t hold much longer. When it breaks, everyone remembers everything… or nothing at all."
	d.avatar = avatar_jonah
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Memory Echo"
	d.content = "— We agreed to forget. We signed the waiver. We pressed ‘Confirm’ —"
	d.avatar = avatar_echo
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "No. We agreed under duress, under sirens, under a sky that wouldn’t stop burning. That is not consent. That is panic."
	d.avatar = avatar_jonah
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "If I can reach the city’s main relay before the final collapse… maybe I can choose which truth comes back first."
	d.avatar = avatar_jonah
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Memory Echo"
	d.content = "— Someone must remember how we chose silence —"
	d.avatar = avatar_echo
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "Then I’ll start here, at the edge. Where the silence is already cracking."
	d.avatar = avatar_jonah
	d.show_on_left = true
	list.append(d)

	group.diaglogue_list = list
	return group
