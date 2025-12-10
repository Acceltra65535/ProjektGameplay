# Game Basic Information #
The game is a story-driven survival RPG set in a post-apocalyptic world where every choice affects the player’s fate
and the world’s state. Players must manage resources and health while exploring decayed cities, forests, and ruins. Combat uses a real-time action system blending melee, ranged, and improvised weapons. The survival mechanics emphasize scarcity and strategy—deciding when to fight, flee, trade, or rest can mean the difference between life and death. Environmental hazards like radiation, weather, and hunger add constant tension, requiring tactical planning and emotional resilience.
## Summary ##
The aesthetic design will be 2D retro-futuristic, pixel-art post-apocalyptic backgrounds with pixel main characters
Similar artistic designs are Long Gone, Kingdom. The action system will look like Celeste that includes dash and vertical movement, interacting with objects like doors/ladders will look like Rust so as long as you approach the instances you can interact. The crafting system will look like other survival games with a set of raw materials that you can collect then use them to synthesize a variety of gears, imaging how you can make different types of bullets in Resident Evil with only powder and metals. 

## Gameplay Explanation ##
Players can interact with the environment and other survivors. Each encounter presents multiple paths—helping 
strangers may earn allies or betrayals, while ignoring others might secure short-term safety but long-term loneliness. Players can scavenge materials and craft gears, shaping their personal survival space. The environment itself tells silent stories through abandoned buildings, graffiti, and remnants of the old world, inviting players to piece together humanity’s collapse. Dynamic AI ensures that NPCs and monsters react differently depending on the player’s actions and reputation, creating a living, reactive world.

The story follows a lone wanderer navigating the ruins of civilization, struggling to hold onto humanity in a world 
stripped of hope. Along the journey, the player meets other survivors—each with their own tragic pasts, motives, and moral boundaries. Through dialogue choices and branching decisions, the player uncovers hidden truths about the apocalypse and faces hard moral dilemmas: who to save, who to sacrifice, and what kind of person to become in the end. 

# Main Roles #
- User Interface & Narrative design: William Yu
- Map design: Fanxi Xu


## User Interface (William Yu)

### Main Menu

![](./Documentation_Images/Menu.png)

The main menu is the first interface the player encounters when launching the game, providing a clear and functional gateway into all major gameplay modes. It includes the Start, Load, Server Create, Join, and Exit buttons, all arranged in a centered vertical layout to maintain visual simplicity and ease of navigation. Each button uses Godot’s built-in theme and style properties to create a hover button effect, allowing the player to easily recognize interactive elements and improving overall usability. In addition to implementing the menu structure, I set up the scene hierarchy, configured each button’s signal connections, and ensured that every option transitions to the appropriate game state or scene. The background artwork, featuring a pixel-art ruined cityscape, establishes the game’s post-apocalyptic tone from the very beginning, immersing the player before gameplay starts.


### Save & load

The save and load interface provides players with a convenient way to manage their game progress and is fully integrated into the main menu system. When the player selects Load from the main menu, the interface communicates with the [save and load manager](final-proj/scripts/UIs/Save&Load/save_load_manager.gd) to retrieve stored save files and display them in a structured list. Each save entry is generated using the game’s SceneData format, which captures essential information about the player state, scene, and inventory at the time of saving. The interface then allows the player to select a save slot and seamlessly transition back into the corresponding scene. Similarly, when creating new progress, the Start button initializes a fresh game state managed by the same system, ensuring consistency between new sessions and loaded ones. By connecting UI button signals directly to the save/load system, the menu acts as the central hub that guides the player into either continuing past adventures or beginning a new one.

### Inventory

![](./Documentation_Images/Inventory.png)

The inventory system is designed as a simple and intuitive hotbar interface that allows the player to quickly access essential items during gameplay. It consists of a row of item slots placed at the bottom of the screen, giving the player a constant and unobtrusive view of their current equipment. Each slot is implemented using a PanelContainer, and the currently selected slot is visually distinguished with a yellow border and background, providing clear feedback about which item is active at any moment.

The core logic is handled by the Inventory.gd script, which maintains the player’s item stacks, updates slot icons and quantities, and manages switching between slots using keyboard shortcuts. When the player picks up items in the world, they are automatically added to the first available slot or stacked with existing items of the same type. The hotbar UI refreshes dynamically to reflect new items, removed items, or changes in quantity, ensuring the player always has accurate information during fast-paced gameplay.

Beyond the hotbar, the inventory system includes an expanded storage view that can be opened by pressing Tab. This full inventory holds additional items that do not fit in the hotbar and is designed for more detailed item management. Players can rearrange items freely—for example, dragging an item from the expanded inventory into an empty hotbar slot to quickly equip it for immediate use. This interaction between the hotbar and the full inventory creates a flexible and efficient workflow, enabling players to organize their equipment strategically while maintaining a clean, minimalist UI that supports both moment-to-moment action and broader inventory management.


### Chatbox

![](./Documentation_Images/Chatbox.gif)

The chatbox UI is implemented as a standalone chatbox.tscn scene controlled by the DialogueManager.gd script. The UI consists of a speaker-name label, a text label for dialogue content, and two avatar TextureRect nodes that let characters appear on either the left or right side depending on the current line. A choice container and a hidden template button allow the chatbox to display interactive dialogue choices when needed. All of these nodes are exposed as exported variables so the manager can update them at runtime.

Dialogue content is data-driven and stored in custom Resource files. A DialogueGroup resource contains an ordered list of Dialogue entries, each specifying the character name, dialogue text, avatar texture, and whether the avatar appears on the left or right. A line may also include a list of DialogueChoice resources, which define the text of each choice and can optionally require or set story flags, jump to a new DialogueGroup, or trigger a scene change. This structure allows conversations and branching paths to be authored visually in the editor without modifying code.

When the game calls start_dialogue(group), the manager becomes active, shows the chatbox, and begins presenting lines with display_next_dialogue(). Clicking on the chatbox advances the conversation unless choices are currently visible, in which case the player must select a button. When choices appear, the manager duplicates the template button for each valid choice and connects their signals to _on_choice_selected(), which handles flag updates, branching, or scene transitions.

A typewriter effect is handled using a [tween](https://github.com/Acceltra65535/ProjektGameplay/blob/c0e447c07cc68c0c91ea6e5e91f6eea011a16387/final-proj/scripts/UIs/Dialogue/dialogue_manager.gd#L21), which is an embedded system in godot. When displaying a new line, the manager clears the text label and schedules a series of tween callbacks—each appending one character at a short interval—so the dialogue appears gradually. If the player clicks while text is still typing, the tween is canceled and the full line is shown instantly.

## Subrole:
### Narration and dialogue

As the narrative designer on the project, I built a modular dialogue system designed to support character-specific introductions, branching scenes, and tone-sensitive storytelling. At the core is a custom architecture built around Dialogue, DialogueGroup, and DialogueChoice resources. This structure allows us to write and organize narrative content cleanly, without needing to dig into the gameplay logic—keeping things both scalable and writer-friendly.

To expand on that, I developed the StoryDialogueLibrary, a scriptable system that procedurally assembles the introductory sequences for our three main characters: Elias, Mira, and Jonah. Each intro is made up of hand-authored dialogue beats, deliberately arranged to express character voice, emotional tone, and narrative motif. For example: Elias’s intro leans into themes of memory loss and guilt; Mira’s reflects her survival instincts, distrust, and sharp-edged humor; and Jonah’s explores societal amnesia and quiet philosophical unease. Each line in these sequences carries metadata—like speaker name, avatar ID, and camera-side placement—so we can layer in visual storytelling cues such as shifting perspectives, mirrored dialogues, and echo-like voice overlays.

When dialogue lines include player choices, the system transitions smoothly into an interactive mode, displaying dynamically generated buttons based on DialogueChoice data. These choices feed directly into story flags and determine the path through future dialogue groups, creating branching interactions that feel meaningful. Because the entire system is data-driven and modular, we’re able to maintain a consistent pipeline from authored narrative to in-game presentation—where tone, pacing, and player interaction all work together. The result is a story layer that not only feels integrated with gameplay, but also preserves the distinct voice and thematic direction of each character.

A sample dialogue script I wrote to push the story forward: [DialogueScript](final-proj/dialogues/DialogueScipts.docx)

### Resources used:

- [Chatbox](https://youtu.be/7c7aZTUITD4?si=ime2pJTvMtp_OIQz)
- [Save&Load](https://youtu.be/wSq1QJ-g91M?si=ZH1QeEi7BJYlGch4)

## Main role:Props Zijian Li

#1 Item & Inventory System

The Item & Inventory System is a core component of gameplay experience, responsible for managing all resources and items players acquire, consume, and organize throughout the game. This system employs a modular architecture comprising four parts: Item, ItemStack, InventoryData, and ItemPickup. Together, they form a stable, scalable, and easily debugged item framework.

Item Data Structure (Item / ItemStack)

Each item is represented by an **Item resource file (.tres)** containing its unique ID, name, icon, description, and item type (e.g., consumable, weapon, building material). Items themselves do not store quantity information; quantities are managed by ItemStack objects.

Item: Describes the item's static data

ItemStack: Represents “Item × Quantity,” supporting stacking, splitting, and merging

This separation ensures the item system's data maintainability and scalability: Item definitions can be edited independently, while quantity logic is handled by runtime stack objects.

Inventory (InventoryData)

The inventory consists of two parts:

Main Inventory (30 slots)

Quickbar (6 slots)

System Support:

✔ Automatic stacking (merging identical items)
✔ Automatic slot detection
✔ Item removal and quantity updates
✔ Swapping between main inventory and hotbar
✔ UI refresh notification via signals

All logic is managed by the InventoryData.gd script, which includes functionalities like add_item, remove_item, swap, and get_item_count.

This system is designed with a separation of data and UI layers: the UI handles presentation, while InventoryData manages actual calculations and data updates.

World Pickup System (ItemPickup)

When enemies drop loot or players open chests, an interactive ItemPickup node is generated. This node features:

Floating animation (bob animation)

Automatic player magnetism (magnetic attraction)

Auto-pickup delay

Icon auto-binding to the Item's icon

When the player touches to pick up the item:

ItemPickup attempts to add the corresponding stack to InventoryData

If fully stored → Self-destructs automatically

If partially stored → Updates remaining quantity and continues hovering

If inventory is full → Remains stationary

This system provides instant feedback (sound effects + animations) and effectively supports the game's pacing.

#2 Buff Factory System

The Buff system grants players temporary stat boosts, such as increased movement speed, enhanced stamina regeneration, or boosted attack power. Designed as an independent functional module, it ensures decoupling from character and item systems.

Buff Data Structure

Each Buff contains:

Buff type (Speed, Attack, HP Regeneration, etc.)
Buff value (e.g., +20% Speed)
Duration
Remaining runtime

The BuffSystem maintains all active Buffs as an array, managing countdowns and cleanup in _process(delta).

Buff Calculation Model

When a character queries a specific ability (e.g., Speed buff):

get_total(BuffType.SPEED)

The system aggregates all active buffs of the same type and returns the final bonus value.

This design offers high composability—for example, two different drinks providing Speed buffs will stack their effects.

Buff Factory (Consumables) Integration

Each consumable invokes BuffSystem upon use:

Example: Energy drink provides +20% Speed for 30 seconds:

buff_system.add_buff(BuffType.SPEED, 0.2, 30.0)

Example: Nutrition supplement increases Stamina Regeneration:

buff_system.add_buff(BuffType.STAMINA_REGEN, 0.4, 20.0)


The Buff Factory design ensures:

Each consumable only needs to define its buff behavior

No modification to Player or Inventory logic

Future additions of new items require no changes to the underlying system, enabling high scalability.

#3 Health & Stamina UI System

#4 System Integration and Design Motivation

The Item System, Buff System, and UI form a complete feedback loop:

Player picks up an item

The item links to character attributes via the BuffSystem

Character attributes are reflected in real-time on the UI (health bar, stamina bar, speed, attack, etc.)

Player makes next action based on UI information

This closed-loop design creates natural, strong, and intuitive feedback, enhancing the overall player experience.

#5 Conclusion

These three systems collectively form the game's core feedback layer, tightly integrated with the combat system, character system, and level system. Their advantages include:

High scalability (easily add new items, buffs, or UI effects)

Data-driven (easy to debug and balance)

Architectural decoupling (each system has a single, clear responsibility)

Excellent gameplay experience (instant feedback + animated reinforcement + clear information)

Translated with DeepL.com (free version)


