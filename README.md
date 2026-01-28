# AFK Manager

A fork of [Rothgar's plugin](https://forums.alliedmods.net/showthread.php?t=79904).

## Information

This plugin has been designed to manage AFK players, it has a General AFK check along with a Spawn AFK check. It checks player commands for button changes and mouse movements to determine if a player is "AFK". If the player is not "typing/chatting", pressing any buttons or performing any movements of their mouse, they are deemed "AFK" and the plugin can move and/or kick them after a specified amount of time. It will warn players who are detected as "AFK" before being moved or kicked based on specific variables in 5 second intervals.

This plugin has been designed to utilize a translation file for use of other languages.

## Requirements
* SourceMod v1.4.0+ (Previous version 3 branch)
* SourceMod v1.7.0+ (Latest version 4 branch)

For Automatic Update support you need to do the following:
You need to compile the plugin manually with the "updater.inc" as per the compile instructions below.

You can download the latest version of the SourceMod "Updater" include file and plugin from:

http://forums.alliedmods.net/showthread.php?t=169095

For Color support you need to do the following:
You need to compile the plugin manually either with "Multi Colors" (preferred), "morecolors.inc" or "colors.inc" as per the compile instructions below.

Multi Colors:
Note: Latest "Multi Colors" version requires SourceMod 1.7.0+
Old Release Commit (Working with SourceMod 1.5.0 if you are using version 3): https://git.tf/Bara/Multi-Colors/tree/89cdb804ffc6544b72ec239ea4c507af68de14c8/addons/sourcemod/scripting/include

You can download the latest version of the SourceMod "Multi Colors" include file(s) from:

https://forums.alliedmods.net/showthread.php?t=247770


More Colors (morecolors.inc):
Note: Latest "More Colors" version now requires compiling with SourceMod 1.5.0+ and does not work properly for at least CS:GO

You can download the latest version of the SourceMod "More Colors" include file from:

https://forums.alliedmods.net/showthread.php?t=185016

Colors (colors.inc):
Note: This include is no longer supported and fails on some newer mods/servers

You can download the latest version of the SourceMod "Colors" include file from:

https://forums.alliedmods.net/showthread.php?t=96831

## Installation Details

Download the "afk_manager.phrases.txt" and save to your addons\sourcemod\translations directory.

Pre-compiled:
Download using the "Get Plugin" link and save to your addons\sourcemod\plugins directory.

Self-Compile:
Download the "afk_manager4.sp" using the "Get Source" link and save to your addons\sourcemod\scripting directory.

Quote:
If you want Automatic Update support you need to:

A) Have the "Updater" plugin already loaded/running
B) Compile the AFK Manager with the corresponding "updater.inc" include file. *
* The "updater.inc" file should be saved in the addons\sourcemod\scripting\include directory before compile.

Please read the requirements section for more details.
Quote:
If you want Color support you need to compile with the color include file(s), please read the requirements section for more details.

For "Multi Colors" there are currently 3 include files that need to be used:
"multicolors.inc" should be installed to addons\sourcemod\scripting\include directory.
"colors.inc" (From Multi Colors) should be saved to addons\sourcemod\scripting\include\multicolor s directory.
"morecolors.inc" (From Multi Colors) should be saved to addons\sourcemod\scripting\include\multicolor s directory.

Otherwise for "More Colors" or "Colors", download the corresponding include file and save to addons\sourcemod\scripting\include directory.
Quote:
To Compile with Debug Enabled:

Open the "afk_manager(3 or 4).sp" in a text editor and set "_DEBUG" to 1
Compile the plugin and install as per normal.

NOTE: If you get an error I would first recommend updating your SourceMod.


## Server Console Variables (ConVars)

    sm_afkm_version - Current version of the AFK Manager. (No edit)
    sm_afk_enable - Is the AFK Manager enabled or disabled? [0 = FALSE, 1 = TRUE, DEFAULT: 1]
    sm_afk_autoupdate - Is the AFK Manager automatic plugin update enabled or disabled? (Requires SourceMod Autoupdate plugin) [0 = FALSE, 1 = TRUE]
    sm_afk_prefix_short - Should the AFK Manager use a short prefix? [0 = FALSE, 1 = TRUE, DEFAULT: 0]
    sm_afk_prefix_color - Should the AFK Manager use color for the prefix tag? [0 = DISABLED, 1 = ENABLED, DEFAULT: 1] (Requires compiling with SourceMod Colors include)
    sm_afk_force_language - Should the AFK Manager force all message language to the server default? [0 = DISABLED, 1 = ENABLED, DEFAULT: 0]
    sm_afk_log_warnings - Should the AFK Manager log plugin warning messages. [0 = FALSE, 1 = TRUE, DEFAULT: 1]
    sm_afk_log_moves - Should the AFK Manager log client moves. [0 = FALSE, 1 = TRUE, DEFAULT: 1]
    sm_afk_log_kicks - Should the AFK Manager log client kicks. [0 = FALSE, 1 = TRUE, DEFAULT: 1]
    sm_afk_log_days - How many days should we keep AFK Manager log files. [0 = INFINITE, DEFAULT: 0]
    sm_afk_move_min_players - Minimum number of connected clients required for AFK move to be enabled. [DEFAULT: 4]
    sm_afk_kick_min_players - Minimum number of connected clients required for AFK kick to be enabled. [DEFAULT: 6]
    sm_afk_admins_immune - Should admins be immune to the AFK Manager? [0 = DISABLED, 1 = COMPLETE IMMUNITY, 2 = KICK IMMUNITY, 3 = MOVE IMMUNITY]
    sm_afk_admins_flag - Admin Flag for immunity? Leave Blank for any flag.
    sm_afk_move_spec - Should the AFK Manager move AFK clients to spectator team? [0 = FALSE, 1 = TRUE, DEFAULT: 1]
    sm_afk_move_announce - Should the AFK Manager announce AFK moves to the server? [0 = DISABLED, 1 = EVERYONE, 2 = ADMINS ONLY, DEFAULT: 1]
    sm_afk_move_time - Time in seconds (total) client must be AFK before being moved to spectator. [0 = DISABLED, DEFAULT: 60.0 seconds]
    sm_afk_move_warn_time - Time in seconds remaining, player should be warned before being moved for AFK. [DEFAULT: 30.0 seconds]
    sm_afk_kick_players - Should the AFK Manager kick AFK clients? [0 = DISABLED, 1 = KICK ALL, 2 = ALL EXCEPT SPECTATORS, 3 = SPECTATORS ONLY]
    sm_afk_kick_announce - Should the AFK Manager announce AFK kicks to the server? [0 = DISABLED, 1 = EVERYONE, 2 = ADMINS ONLY, DEFAULT: 1]
    sm_afk_kick_time - Time in seconds (total) client must be AFK before being kicked. [0 = DISABLED, DEFAULT: 120.0 seconds]
    sm_afk_kick_warn_time - Time in seconds remaining, player should be warned before being kicked for AFK. [DEFAULT: 30.0 seconds]
    sm_afk_spawn_time - Time in seconds (total) that player should have moved from their spawn position. [0 = DISABLED, DEFAULT: 20.0 seconds]
    sm_afk_spawn_warn_time - Time in seconds remaining, player should be warned for being AFK in spawn. [DEFAULT: 15.0 seconds]
    sm_afk_exclude_dead - Should the AFK Manager exclude checking dead players? [0 = FALSE, 1 = TRUE, DEFAULT: 0]
    sm_afk_move_warn_unassigned - Should the AFK Manager warn team 0 (Usually unassigned) players? (Disabling may not work for some games) [0 = FALSE, 1 = TRUE, DEFAULT: 1]
    sm_afk_buttons - How many button changes should the AFK Manager track before resetting AFK status? [0 = DISABLED, DEFAULT: 5]

* Note: The cfg file should be automatically created when the plugin is first loaded in cfg\sourcemod\afk_manager.cfg. If you delete this file it will re-create with the correct (default) cvars on plugin start/map change.

## Server Commands

    sm_afk_spec - Usage: sm_afk_spec <#userid|name>

## Plugin Developer Information & Examples

If you are a plugin developer who wants to add mod specific or server specific functionality to the AFK Manager or to be able to detect AFK status in your own plugin you can now use the Native and Forwards I have created to do so. If you want a generic AFK feature to be added which would be beneficial to any mod, post in the thread so I can review.

Information can be found in the afk_manager.inc and the features are currently implemented in the latest release, I believe the functions are about 80% complete, so be aware they could change in the future. I am open to any feedback on whether you want to get more information from the AFK Manager or whether you think any of the current functions should change.

### Example Plugins for Developers

I have written a couple of small example plugins for Counter-Strike/CS:GO to show a few methods of how you can use the AFK Manager natives and forwards:

#### Example Plugin #1

This plugin does not use any of the forwards: http://afkmanager.dawgclan.net/scrip...ger_cstrike.sp

The plugin was based off RedSwords original AFK Bomb plugin (https://forums.alliedmods.net/showthread.php?t=152329).

In the example you can see how I check for "Active" Terrorist players (Not marked as AFK for even 1 second) in the AFK_RandomBomb() function using AFKM_IsClientAFK().

You can also see how I have created a timer for any players with the Bomb and take action after a certain amount of AFK time in the Timer_CheckPlayer() function using AFKM_GetClientAFKTime().

Please note while I was making this I found there was a bug in the CS_DropWeapon() function for CS:GO where the toss was not working which has been fixed in release 1.8.0.6009 and 1.9.0.6101, thanks to the #SourceMod guys for their input help and fixes.

#### Example Plugin #2

This plugin is more specific to CS:GO around Team Swapping Issues/Modifications: http://afkmanager.dawgclan.net/scrip..._teamchange.sp

In this example you can see how I use the "AFK" forward events for "afk_move" and "afk_kick" to mark the player as "Moved" so that we can allow them to join a team again straight away by bypassing the "Pending" team change mode that Valve has implemented.

I have also on request added a couple of additional options to:

Provided a variable to override the pending team change for all players irrespective of whether they were moved by the AFK manager.

Provided a variable to block players from changing directly between Terrorist and Counter-Terrorist Teams.

Again these plugin are examples, there are no current translations or anything to notify players about the actions taken in these plugins.

If people are interested in me enhancing these to actually be a full blown sister plugin with certain features or want to take the projects on yourself let me know.

## Change Log

* See the afk_manager.changelog.txt for old version information.

    4.3.0

Added:
- Added new AFK buttons variable which will allow you to disable button change detection completely (Would rely on mouse movements only) or track a certain number of unique buttons.

Please let me know if you experience any issues or problems.

## Credits

    Asherkin - For finding the CSGO team change limit offset.
    Psychonic & Asherkin - For fixing mouse detection functionality in the SourceMod core.


## Completed Language Translations

    English (By Rothgar)
    French (By Cadav0r)
    Russian (By Snake60 & SelaX)
    Spanish (By eradeejay)
    German (By Guggie & Spawn86)
    Portuguese (By away000 & paulo_crash)
    Hungarian (By KhyrOO & blue zebra)
    Polish (By Zuko & Arcy)
    Turkish (By ZuCChiNi)
    Norwegian (By checkster)
    Norwegian (By checkster)
    Italian (By Obyboby)
    Czech (By Wooky_)


## Other plugins made by me:

Anti-TK Manager: http://forums.alliedmods.net/showthread.php?t=80554


## File Information

afk_manager-compat - This is an old release which is no longer kept up-to-date and only available for older SourceMod releases. It can be found in the afk_manager_old.zip
afk_manager3 - This was the previous version. It can be found in the afk_manager_old.zip
afk_manager4 - This is the current version.

Most people should use the new version that is NOT in the zip file.

Compiled Download with Multi Colors and Updater
If you are looking for a compiled download of the latest version of the AFK Manager which includes both "Multi Colors" and "Updater" include files, you can use the Updater download URL
Must User Right Click Save As: http://afkmanager.dawgclan.net/plugins/afk_manager4.smx

The compiled download URL should be static and contain the latest version of the plugin if you for example want to add to server provisioning scripts or similar, please also make sure you get the translation file either through the forum or via the Updater download URL http://afkmanager.dawgclan.net/trans...er.phrases.txt 
