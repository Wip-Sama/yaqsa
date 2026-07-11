# Yaqsa: Yet Another Quickstart Attempt

Configure your multiplayer quickstarts dynamically in-game! No more editing lua files or tweaking mod settings to get the exact items you want to start with.

### Features:
* **Customizable Quickstart**: Pick the exact items and quantities you want to start your playthrough with, using an intuitive in-game GUI.
* **Presets System**: Quickly load built-in presets (like basic automation or equipment) directly into your quickstart configuration.
* **Configure Once for Multiplayer**: Once the admin configures the quickstart, all connecting players will receive it automatically.
* **Death Quickstart**: Configure a specific set of items for players to receive upon respawning to help them recover their corpse!
* **Mid-Game Safe**: You can safely add this mod to an existing playthrough.

### How to Use the Configurator:
* When the game starts (or when using `/edit_quickstart`), the GUI will appear for admins.
* Select empty slots to add items you want to spawn with.
* Modify the quantity using the text fields.
* The counter at the top shows how much inventory space your configured items will consume.
* Close or hit "Save" on the window to finalize the quickstart. New players will receive it instantly!

### Commands:
**Player Commands:**
* `/quickstart <me/all>` : Receive the quickstart items (only works once per player).
* `/death_quickstart` : Manually receive the death quickstart items.
* `/no_quickstart` : Forfeit your right to the quickstart, marking you as having received it.

**Admin Commands:**
* `/edit_quickstart` : Re-opens the main quickstart configurator UI.
* `/edit_death_quickstart` : Opens the death quickstart configurator UI.
* `/force_quickstart <me/all/player_index>` : Forces a player to receive the quickstart again (WARNING: clears their current inventory).
* `/retract_quickstart <me/all/player_index>` : Clears the "already received" status for a player so they can get the items again.

### Planned Features:
* Export quickstart to string to share it or store it for later use.
* Save quickstart to blueprint/+combinators.
* Basic quickstart presets for major overhaul mods (like Krastorio).
* Support for quality items.
