extends Resource
class_name StoryDialogueLibrary

# =============================================================================
# Story Dialogue Library
# =============================================================================
# Scenes:
#   S1 - City Outskirts
#   S2 - Old Gate Checkpoint
#   S3 - Grey Bazaar Ruins
#   S4 - Perimeter Relay Substation
#
# Characters: elias, mira, jonah
# =============================================================================

# Shared avatar preloads
static var _avatars_loaded := false
static var avatar_elias: Texture2D
static var avatar_mira: Texture2D
static var avatar_jonah: Texture2D
static var avatar_echo: Texture2D
static var avatar_radio: Texture2D
static var avatar_recorder: Texture2D
static var avatar_vendor: Texture2D
static var avatar_system: Texture2D


static func _ensure_avatars() -> void:
	if _avatars_loaded:
		return
	avatar_elias = preload("res://assets/Survivalist Sprite Sheet Pixel Art Pack/Survivalist_1/talking.png")
	avatar_mira = preload("res://assets/Survivalist Sprite Sheet Pixel Art Pack/Survivalist_2/talk.png")
	avatar_jonah = preload("res://assets/Survivalist Sprite Sheet Pixel Art Pack/Survivalist_3/Talking.png")
	avatar_echo = preload("res://assets/space_background_pack/Assets/Blue Version/layered/prop-planet-big.png")
	avatar_radio = preload("res://assets/space_background_pack/RC Art - Orbital Cannon/Sprites/Type A Ion Cannon_5.png")
	avatar_recorder = preload("res://assets/PostApocalypse_AssetPack_v1.1.2/Objects/Washing-machine.png")
	avatar_vendor = avatar_radio  # Placeholder - can be changed
	avatar_system = avatar_echo   # Placeholder - can be changed
	_avatars_loaded = true


# =============================================================================
# Main Entry Points
# =============================================================================

## Build dialogue for a specific scene and character
## scene_id: "s1", "s2", "s3", "s4"
## character_id: "elias", "mira", "jonah"
## trigger_key: optional sub-trigger within scene (e.g., "entrance", "terminal", "npc_vendor")
static func build_dialogue(scene_id: String, character_id: String, trigger_key: String = "main") -> DialogueGroup:
	_ensure_avatars()

	var key := "%s_%s_%s" % [scene_id.to_lower(), character_id.to_lower(), trigger_key.to_lower()]

	match key:
		# S1 - City Outskirts (Intro scenes)
		"s1_elias_main", "s1_elias_intro":
			return _build_elias_intro()
		"s1_mira_main", "s1_mira_intro":
			return _build_mira_intro()
		"s1_jonah_main", "s1_jonah_intro":
			return _build_jonah_intro()

		# S1 - Scene transition (auto-selects based on character)
		"s1_elias_transition", "s1_mira_transition", "s1_jonah_transition", "s1_transition":
			return S1SceneTransitionDialogues.build_transition()

		# S2 - Old Gate Checkpoint (uses separate files)
		"s2_elias_main", "s2_elias_entrance":
			return EliasS2Dialogues.build_main()
		"s2_elias_terminal":
			return EliasS2Dialogues.build_terminal()
		"s2_mira_main", "s2_mira_entrance":
			return MiraS2Dialogues.build_main()
		"s2_mira_discovery":
			return MiraS2Dialogues.build_discovery()

		# S3 - Grey Bazaar Ruins (uses separate files)
		"s3_mira_main", "s3_mira_entrance":
			return MiraS3Dialogues.build_main()
		"s3_mira_vendor":
			return MiraS3Dialogues.build_vendor()
		"s3_jonah_main", "s3_jonah_entrance":
			return JonahS3Dialogues.build_main()
		"s3_jonah_rumors":
			return JonahS3Dialogues.build_rumors()

		# S4 - Perimeter Relay Substation (uses separate files)
		"s4_elias_main", "s4_elias_entrance":
			return EliasS4Dialogues.build_main()
		"s4_elias_memory_echo":
			return EliasS4Dialogues.build_echo()
		"s4_jonah_main", "s4_jonah_entrance":
			return JonahS4Dialogues.build_main()
		"s4_jonah_terminal":
			return JonahS4Dialogues.build_terminal()
		"s4_jonah_choice":
			return JonahS4Choice.build_choice()

		_:
			push_warning("StoryDialogueLibrary: Unknown dialogue key: " + key)
			return null


## Legacy function for S1 intro compatibility
static func build_intro_for(character_id: String) -> DialogueGroup:
	return build_dialogue("s1", character_id, "intro")


# =============================================================================
# S1 - City Outskirts Intro Dialogues
# =============================================================================

static func _build_elias_intro() -> DialogueGroup:
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []
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


static func _build_mira_intro() -> DialogueGroup:
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []
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


static func _build_jonah_intro() -> DialogueGroup:
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []
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
