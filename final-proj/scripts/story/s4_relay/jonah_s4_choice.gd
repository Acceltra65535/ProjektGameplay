extends Resource
class_name JonahS4Choice

## S4 - Perimeter Relay: Jonah's critical choice
## Accept patch: Short-term fewer enemies, network stable, but truth harder to dig
## Reject patch: Short-term more Overflow enemies, but memories easier to unlock later

static var _avatars: Dictionary = {}


static func _ensure_avatars() -> void:
	if _avatars.is_empty():
		_avatars["jonah"] = preload("res://assets/Survivalist Sprite Sheet Pixel Art Pack/Survivalist_3/Talking.png")
		_avatars["system"] = preload("res://assets/space_background_pack/Assets/Blue Version/layered/prop-planet-big.png")
		_avatars["recorder"] = preload("res://assets/PostApocalypse_AssetPack_v1.1.2/Objects/Washing-machine.png")


## Build the choice dialogue with branching options
static func build_choice() -> DialogueGroup:
	_ensure_avatars()
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []
	var d: Dialogue

	# Setup the choice
	d = Dialogue.new()
	d.character_name = "System Voice"
	d.content = "Awaiting authorization. ACCEPT stabilization patch or REJECT to allow natural network decay."
	d.avatar = _avatars["system"]
	d.show_on_left = false
	d.has_choices = true

	# Create the two choices
	var choice_accept := DialogueChoice.new()
	choice_accept.choice_text = "ACCEPT - Stabilize the network"
	choice_accept.set_flag = "jonah_accepted_patch"
	choice_accept.flag_value = true
	choice_accept.next_dialogue_group = _build_accept_result()

	var choice_reject := DialogueChoice.new()
	choice_reject.choice_text = "REJECT - Let the cracks widen"
	choice_reject.set_flag = "jonah_rejected_patch"
	choice_reject.flag_value = true
	choice_reject.next_dialogue_group = _build_reject_result()

	d.choices = [choice_accept, choice_reject]
	list.append(d)

	group.diaglogue_list = list
	return group


## Result if Jonah accepts the patch
static func _build_accept_result() -> DialogueGroup:
	_ensure_avatars()
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []
	var d: Dialogue

	d = Dialogue.new()
	d.character_name = "System Voice"
	d.content = "Patch accepted. Memory stabilization in progress. Network cohesion restored to 78%."
	d.avatar = _avatars["system"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "The echoes are fading. The voices are quieter. Everything feels… flatter."
	d.avatar = _avatars["jonah"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "I bought the city more time to sleep. But I also helped them forget why they should wake up."
	d.avatar = _avatars["jonah"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Recorder"
	d.content = "Note: Subject chose stability over truth. Ethical implications… pending."
	d.avatar = _avatars["recorder"]
	d.show_on_left = false
	list.append(d)

	group.diaglogue_list = list
	return group


## Result if Jonah rejects the patch
static func _build_reject_result() -> DialogueGroup:
	_ensure_avatars()
	var group := DialogueGroup.new()
	var list: Array[Dialogue] = []
	var d: Dialogue

	d = Dialogue.new()
	d.character_name = "System Voice"
	d.content = "Patch rejected. Network decay accelerating. WARNING: Echo interference will increase across all sectors."
	d.avatar = _avatars["system"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "The echoes are louder now. More voices, more fragments. The city is starting to remember."
	d.avatar = _avatars["jonah"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "It will hurt. People will hear things they don't want to hear. But maybe pain is the price of truth."
	d.avatar = _avatars["jonah"]
	d.show_on_left = true
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Recorder"
	d.content = "Note: Subject chose truth over stability. Ethical implications… also pending."
	d.avatar = _avatars["recorder"]
	d.show_on_left = false
	list.append(d)

	d = Dialogue.new()
	d.character_name = "Jonah"
	d.content = "Whatever comes next, at least it will be real."
	d.avatar = _avatars["jonah"]
	d.show_on_left = true
	list.append(d)

	group.diaglogue_list = list
	return group

