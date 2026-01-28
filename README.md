# AFK Manager

A fork of [Rothgar's plugin](https://forums.alliedmods.net/showthread.php?t=79904).

This plugin has been designed to manage AFK players, it has a General AFK check along with a Spawn AFK check. It checks player commands for button changes and mouse movements to determine if a player is "AFK". If the player is not "typing/chatting", pressing any buttons or performing any movements of their mouse, they are deemed "AFK" and the plugin can move and/or kick them after a specified amount of time. It will warn players who are detected as "AFK" before being moved or kicked based on specific variables in 5 second intervals.

This plugin has been designed to utilize a translation file for use of other languages.

## Installation

- Add the compiled plugins `afk_manager.smx` to `tf/addons/sourcemod/plugins/`:
    - `afk_manager.smx`.
    - `multicolors.smx`.
- Add the translations file `afk_manager.phrases.txt` to `/tf/addons/sourcemod/translations/`.
- Reload all plugins or restart the server.

For debug functionality, compile the plugin with `_DEBUG` set to `1`.

### Dependencies
- [SourceMod v1.7.0+](https://www.sourcemod.net/downloads.php)
- [Multi Colors](https://forums.alliedmods.net/showthread.php?t=247770)

## Configuration

The plugin automatically generates a new configuration file `tf/cfg/sourcemod/plugin.afk_manager.cfg` if one does not already exist.

```
// Admin Flag for immunity? Leave Blank for any flag.
// -
// Default: ""
sm_afk_admins_flag ""

// Should admins be immune to the AFK Manager? [0 = DISABLED, 1 = COMPLETE IMMUNITY, 2 = KICK IMMUNITY, 3 = MOVE IMMUNITY]
// -
// Default: "1"
sm_afk_admins_immune "1"

// How many button changes should the AFK Manager track before resetting AFK status? [0 = DISABLED, DEFAULT: 5]
// -
// Default: "5"
// Minimum: "0.000000"
// Maximum: "30.000000"
sm_afk_buttons "5"

// Is the AFK Manager enabled or disabled? [0 = FALSE, 1 = TRUE, DEFAULT: 1]
// -
// Default: "1"
// Minimum: "0.000000"
// Maximum: "1.000000"
sm_afk_enable "1"

// Should the AFK Manager exclude checking dead players? [0 = FALSE, 1 = TRUE, DEFAULT: 0]
// -
// Default: "0"
// Minimum: "0.000000"
// Maximum: "1.000000"
sm_afk_exclude_dead "0"

// Should the AFK Manager force all message language to the server default? [0 = DISABLED, 1 = ENABLED, DEFAULT: 0]
// -
// Default: "0"
// Minimum: "0.000000"
// Maximum: "1.000000"
sm_afk_force_language "0"

// Should the AFK Manager announce AFK kicks to the server? [0 = DISABLED, 1 = EVERYONE, 2 = ADMINS ONLY, DEFAULT: 1]
// -
// Default: "1"
// Minimum: "0.000000"
// Maximum: "2.000000"
sm_afk_kick_announce "1"

// Minimum number of connected clients required for AFK kick to be enabled. [DEFAULT: 6]
// -
// Default: "6"
sm_afk_kick_min_players "6"

// Should the AFK Manager kick AFK clients? [0 = DISABLED, 1 = KICK ALL, 2 = ALL EXCEPT SPECTATORS, 3 = SPECTATORS ONLY]
// -
// Default: "1"
sm_afk_kick_players "1"

// Time in seconds (total) client must be AFK before being kicked. [0 = DISABLED, DEFAULT: 120.0 seconds]
// -
// Default: "120.0"
sm_afk_kick_time "120.0"

// Time in seconds remaining, player should be warned before being kicked for AFK. [DEFAULT: 30.0 seconds]
// -
// Default: "30.0"
sm_afk_kick_warn_time "30.0"

// How many days should we keep AFK Manager log files. [0 = INFINITE, DEFAULT: 0]
// -
// Default: "0"
sm_afk_log_days "0"

// Should the AFK Manager log client kicks. [0 = FALSE, 1 = TRUE, DEFAULT: 1]
// -
// Default: "1"
// Minimum: "0.000000"
// Maximum: "1.000000"
sm_afk_log_kicks "1"

// Should the AFK Manager log client moves. [0 = FALSE, 1 = TRUE, DEFAULT: 1]
// -
// Default: "1"
// Minimum: "0.000000"
// Maximum: "1.000000"
sm_afk_log_moves "1"

// Should the AFK Manager log plugin warning messages. [0 = FALSE, 1 = TRUE, DEFAULT: 1]
// -
// Default: "1"
// Minimum: "0.000000"
// Maximum: "1.000000"
sm_afk_log_warnings "1"

// Should the AFK Manager announce AFK moves to the server? [0 = DISABLED, 1 = EVERYONE, 2 = ADMINS ONLY, DEFAULT: 1]
// -
// Default: "1"
// Minimum: "0.000000"
// Maximum: "2.000000"
sm_afk_move_announce "1"

// Minimum number of connected clients required for AFK move to be enabled. [DEFAULT: 4]
// -
// Default: "4"
sm_afk_move_min_players "4"

// Should the AFK Manager move AFK clients to spectator team? [0 = FALSE, 1 = TRUE, DEFAULT: 1]
// -
// Default: "1"
// Minimum: "0.000000"
// Maximum: "1.000000"
sm_afk_move_spec "1"

// Time in seconds (total) client must be AFK before being moved to spectator. [0 = DISABLED, DEFAULT: 60.0 seconds]
// -
// Default: "60.0"
sm_afk_move_time "60.0"

// Time in seconds remaining, player should be warned before being moved for AFK. [DEFAULT: 30.0 seconds]
// -
// Default: "30.0"
sm_afk_move_warn_time "30.0"

// Should the AFK Manager warn team 0 (Usually unassigned) players? (Disabling may not work for some games) [0 = FALSE, 1 = TRUE, DEFAULT: 1]
// -
// Default: "1"
// Minimum: "0.000000"
// Maximum: "1.000000"
sm_afk_move_warn_unassigned "1"

// Should the AFK Manager use color for the prefix tag? [0 = DISABLED, 1 = ENABLED, DEFAULT: 1]
// -
// Default: "1"
// Minimum: "0.000000"
// Maximum: "1.000000"
sm_afk_prefix_color "1"

// Should the AFK Manager use a short prefix? [0 = FALSE, 1 = TRUE, DEFAULT: 0]
// -
// Default: "0"
// Minimum: "0.000000"
// Maximum: "1.000000"
sm_afk_prefix_short "0"

// Time in seconds (total) that player should have moved from their spawn position. [0 = DISABLED, DEFAULT: 20.0 seconds]
// -
// Default: "20.0"
sm_afk_spawn_time "20.0"

// Time in seconds remaining, player should be warned for being AFK in spawn. [DEFAULT: 15.0 seconds]
// -
// Default: "15.0"
sm_afk_spawn_warn_time "15.0"
```

## Commands

* `sm_afk_spec`:
  * **Description:** Spectate an AFK player.
  * **Required Admin Flags**: ban.
  * **Parameters:**
    * **Player name:** (*Mandatory*) Player's user ID or display name on the server.

## Credits

- Asherkin - For finding the CSGO team change limit offset.
- Psychonic & Asherkin - For fixing mouse detection functionality in the SourceMod core.


### Completed Language Translations

- English (By Rothgar)
- French (By Cadav0r)
- Russian (By Snake60 & SelaX)
- Spanish (By eradeejay)
- German (By Guggie & Spawn86)
- Portuguese (By away000 & paulo_crash)
- Hungarian (By KhyrOO & blue zebra)
- Polish (By Zuko & Arcy)
- Turkish (By ZuCChiNi)
- Norwegian (By checkster)
- Norwegian (By checkster)
- Italian (By Obyboby)
- Czech (By Wooky_)
