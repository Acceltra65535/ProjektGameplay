# Game Basic Information #

## Summary ##


## Gameplay Explanation ##


# Main Roles #
Type our roles here


## User Interface (William Yu)

### Main Menu

![](./Documentation_Images/Menu.png)

The main menu is the first interface the player encounters when launching the game, providing a clear and functional gateway into all major gameplay modes. It includes the Start, Load, Server Create, Join, and Exit buttons, all arranged in a centered vertical layout to maintain visual simplicity and ease of navigation. Each button uses Godot’s built-in theme and style properties to create a hover button effect, allowing the player to easily recognize interactive elements and improving overall usability. In addition to implementing the menu structure, I set up the scene hierarchy, configured each button’s signal connections, and ensured that every option transitions to the appropriate game state or scene. The background artwork, featuring a pixel-art ruined cityscape, establishes the game’s post-apocalyptic tone from the very beginning, immersing the player before gameplay starts.


### Save & load

The save and load interface provides players with a convenient way to manage their game progress and is fully integrated into the main menu system. When the player selects Load from the main menu, the interface communicates with the SaveLoadManager to retrieve stored save files and display them in a structured list. Each save entry is generated using the game’s SceneData format, which captures essential information about the player state, scene, and inventory at the time of saving. The interface then allows the player to select a save slot and seamlessly transition back into the corresponding scene. Similarly, when creating new progress, the Start button initializes a fresh game state managed by the same system, ensuring consistency between new sessions and loaded ones. By connecting UI button signals directly to the save/load system, the menu acts as the central hub that guides the player into either continuing past adventures or beginning a new one.

### Inventory

![](./Documentation_Images/Inventory.png)

The inventory system is designed as a simple and intuitive hotbar interface that allows the player to quickly access essential items during gameplay. It consists of a row of item slots placed at the bottom of the screen, giving the player a constant and unobtrusive view of their current equipment. Each slot is implemented using a PanelContainer, and the currently selected slot is visually distinguished with a yellow border and background, providing clear feedback about which item is active at any moment.

The core logic is handled by the Inventory.gd script, which maintains the player’s item stacks, updates slot icons and quantities, and manages switching between slots using keyboard shortcuts. When the player picks up items in the world, they are automatically added to the first available slot or stacked with existing items of the same type. The hotbar UI refreshes dynamically to reflect new items, removed items, or changes in quantity, ensuring the player always has accurate information during fast-paced gameplay.

Beyond the hotbar, the inventory system includes an expanded storage view that can be opened by pressing Tab. This full inventory holds additional items that do not fit in the hotbar and is designed for more detailed item management. Players can rearrange items freely—for example, dragging an item from the expanded inventory into an empty hotbar slot to quickly equip it for immediate use. This interaction between the hotbar and the full inventory creates a flexible and efficient workflow, enabling players to organize their equipment strategically while maintaining a clean, minimalist UI that supports both moment-to-moment action and broader inventory management.


### Chatbox

**Path to image**

The chatbox UI is implemented as a standalone chatbox.tscn scene controlled by the DialogueManager.gd script. The UI consists of a speaker-name label, a text label for dialogue content, and two avatar TextureRect nodes that let characters appear on either the left or right side depending on the current line. A choice container and a hidden template button allow the chatbox to display interactive dialogue choices when needed. All of these nodes are exposed as exported variables so the manager can update them at runtime.

Dialogue content is data-driven and stored in custom Resource files. A DialogueGroup resource contains an ordered list of Dialogue entries, each specifying the character name, dialogue text, avatar texture, and whether the avatar appears on the left or right. A line may also include a list of DialogueChoice resources, which define the text of each choice and can optionally require or set story flags, jump to a new DialogueGroup, or trigger a scene change. This structure allows conversations and branching paths to be authored visually in the editor without modifying code.

When the game calls start_dialogue(group), the manager becomes active, shows the chatbox, and begins presenting lines with display_next_dialogue(). Clicking on the chatbox advances the conversation unless choices are currently visible, in which case the player must select a button. When choices appear, the manager duplicates the template button for each valid choice and connects their signals to _on_choice_selected(), which handles flag updates, branching, or scene transitions.

A typewriter effect is handled using a tween, which is an embedded system in godot. When displaying a new line, the manager clears the text label and schedules a series of tween callbacks—each appending one character at a short interval—so the dialogue appears gradually. If the player clicks while text is still typing, the tween is canceled and the full line is shown instantly.

## Subrole:
### Narration and dialogue

As the narrative designer on the project, I built a modular dialogue system designed to support character-specific introductions, branching scenes, and tone-sensitive storytelling. At the core is a custom architecture built around Dialogue, DialogueGroup, and DialogueChoice resources. This structure allows us to write and organize narrative content cleanly, without needing to dig into the gameplay logic—keeping things both scalable and writer-friendly.

To expand on that, I developed the StoryDialogueLibrary, a scriptable system that procedurally assembles the introductory sequences for our three main characters: Elias, Mira, and Jonah. Each intro is made up of hand-authored dialogue beats, deliberately arranged to express character voice, emotional tone, and narrative motif. For example: Elias’s intro leans into themes of memory loss and guilt; Mira’s reflects her survival instincts, distrust, and sharp-edged humor; and Jonah’s explores societal amnesia and quiet philosophical unease. Each line in these sequences carries metadata—like speaker name, avatar ID, and camera-side placement—so we can layer in visual storytelling cues such as shifting perspectives, mirrored dialogues, and echo-like voice overlays.

When dialogue lines include player choices, the system transitions smoothly into an interactive mode, displaying dynamically generated buttons based on DialogueChoice data. These choices feed directly into story flags and determine the path through future dialogue groups, creating branching interactions that feel meaningful. Because the entire system is data-driven and modular, we’re able to maintain a consistent pipeline from authored narrative to in-game presentation—where tone, pacing, and player interaction all work together. The result is a story layer that not only feels integrated with gameplay, but also preserves the distinct voice and thematic direction of each character.