# Changelog

## [4.2.5] 

### Fixed
- Plugin now checks minimum players required when variable changes in addition to client connect/disconnects.

## [4.2.4]

### Fixed

- Small bug on map change event where the last client may not have properly had AFK time modified.
- Fixed IsValidClient function to treat client ID 0 as Invalid.

## [4.2.3]

### Added
- Added Tracking Client User ID's

### Fixed

- Fixed a bug where the "player_disconnect" was firing and returning a Client ID of 0. I believe this may happen if a player is connecting to the server but times out before they fully connected. However there seemed to be a bug at least in Insurgency where a fully connected player "timed out" and the "player_disconnect" returned 0 for the client this then caused issues where if a bot connected and took over the timed out client number it would be affected by their timers, so now there is a backup function to check User ID's if the Client is 0 to Uninitialize.
By tracking User ID's I was able to change the connect function (which fires on Map Changes) to not reset AFK status, so AFK status will continue over map changes.
- Fix TF2 Arena Round Start Detection to not mark invalid players as AFK.

### Changed

- I also attempt to track the time it takes over map changes (Time Between MapEnd and MapStart) and shift players AFK time forward so Map Change time is not counted as "AFK".

## [4.2.2]

### Fixed

- Full Admin Immunity no longer calls UninitializePlayer() to stop any timers etc. Calling UnInitializePlayer() was resetting the Immunity Variable which was of course breaking Full Admin Immunity.

## [4.2.1]

### Changed

- Changed UnItializePlayer() to fire during the player_disconnect Game Event rather than OnClientDisconnect_Post to avoid it firing during map changes, this allows for external plugin settings i.e. Setting Client Immunity to transverse map changes.
- Changed the InitializePlayer() to not set Immunity if one already exists for the player.
- If AFK Move is enabled globally yet an individual client has Kick Immunity, we no longer kick the immune client during AFK Spawn checking.

### Fixed

- The default Immunity variable was not being set to the proper default which may have caused some issues with Admin Immunity, this has been fixed.
- Changed InitializePlayer() to fire inside OnClientPostAdminCheck instead of OnClientPutInServer to fix Admin Immunity checks.
- Fixed AFKM_SetClientImmunity Native as the function was picking up the immunity parameter as the client id.
- AFK Move functions were not working if the move time was exceeded, this could happen in instances where Immunity types are changed ad-lib, this should now be fixed.

## [4.2.0]

### Added

- Added new Native AFKM_GetSpectatorTeam which will retrieve the currently detected AFK Team Number, details can be found in the afk_manager.inc
- Added new Native AFKM_SetClientImmunity which will allow third party plugin developers to set the immunity mode of players. Details can be found in the afk_manager.inc
- Added new Forward AFKM_OnInitializePlayer which fires during the InitializePlayer event. Details can be found in the afk_manager.inc

### Changed

- Changed Admin immunity functions and checks to be more flexible and allow for the new Natives.

### Fixed

- Fixed a bug where players who were AFK while the MOTD dialog was up and moved to Spectator team were afterwards unable to join any team.

## [4.1.7]

### Fixed

- Removed warmup round check for CS:S as it seems to only be in CS:GO.
- Found a bug where when the plugin was paused i.e. during RoundStart freezetime if the Spawn AFK timer was active it was not pausing the time for the Spawn AFK.

## [4.1.6]

### Added

- Re-added some code to check for CS warmup round and pause AFK checks until full rounds start.

### Fixed

- There was a bug where at least in CS:GO when a player was changed to Freezecam and death checking was enabled, timers were sometimes getting reset. I now treat "Freezecam" like "Deathcam" which should stop timers from resetting while in the Freeze/Deatchcam states.
- There was a bug while checking dead players where if all players were killed using sm_slay @all for instance you were set to spectate an invalid target and it was resetting timers, if the camera is set to a chase mode and the target is invalid it now returns as AFK to fix this.

## [4.1.5]

### Fixed

- There was an old engine define check that was causing the roaming mode to not set properly, this has now been removed.

## [4.1.4]

### Fixed

- psychonic found that the ROAMING/Freelook mode had changed on some source engines such as TF2 and CSS, have updated the detection which should fix some bugs around observer modes.

### Changed

- Changed CS:GO back to using mouse detection as it seems to be fixed in the new update >_<
- Changed some deathcam code slightly.

## [4.1.3]

### Added

- Added detection of Freeze Time in Counter-Strike to pause the plugin, which should fix some of the spam of messages during buy time and some people might of had longer freeze times not sure.

### Changed

- Changed CS:GO back to using Eye Angles for movement detection over mouse because it seems Valve has removed the mouse movements. I have added the check just for horizontal movements to see if it helps combat Anti-AFK scripts.

## [4.1.2]

### Fixed

- Fixed admin immunity flags checking, there was a bug where previously only the first flag character was being checked, they should now all be checked individually.

## [4.1.1]

### Fixed

- Changed Golden Eye Source to Suicide player before moving to spectator to fix some bugs.

## [4.1.0]

### Changed

- Changed the AFK Manager to detect mouse movements instead of eye angles which should as a result stop Anti-AFK macro scripts.

## [4.0.5]

### Added

- Added a fix for CSGO team change limit, big thanks to Asherkin for finding the offset.
- CSGO Translation (You will need to download the latest translation file)

## [4.0.4]

### Added

- Attempted to add/fix late loading of the plugin, if you have problems late loading let me know.
- Added some warning logs for the new forward event if the return is going to affect the plugin handling.

### Changed

- Made some small optimizations of the overall code.

### Fixed
- Fixed TF2 Arena Mode handling in the new version 4 (This includes Saxton Hale which seems to also be fixed).
- Fixed Waiting for Player hooking, to pause the AFK checks during WFP event.
- Fixed the Arena Mode spectator move function with original fixes from the old plugin.

## [4.0.3]

### Added

- Added new global forward "AFKM_OnAFKEvent" this is a first pass, I will need some feedback on suggested ways people might want to use this so it can be completed.

### Fixed

- Fixed Language variable hook, it was linked to plugin enable probably when I was re-writing.
- Fixed Team Changes (Other than spectator team) now reset AFK status, this was having adverse affects in some cases.
- Fixed Language functions to properly work, re-wrote the functions and merged them into one.
- Removed dormant spawn timer code, for some reason it was still lingering.

## [4.0.2]

### Fixed

- API Include file had incorrect definitions for forwards, thanks for asherkin pointing this out.
- Added timer handle checks in various functions in the plugin to check for a valid timer, this is to ensure values do not get defined for invalid clients such as immune admins or bots etc and should remove unnecessary function parsing.
- Improved the native functions to sanitize data to avoid invalid data being parsed.

## [4.0.1]

### Added

- Added some API features for other plugins to use. 2 Natives (AFKM_IsClientAFK & AFKM_GetClientAFKTime) and 2 Forwards (AFKM_OnClientAFK & AFKM_OnClientBack).

### Fixed

- Source/GO TV in the new plugin version was getting checked for AFK. This has now been fixed.
- Also added a potential fix for Synergy Spawn checking.

## [4.0.0]

### Changed

- This is a full re-write of the AFK Manager which uses new methods of detecting AFK players.

## [3.6.2]

### Added

- Support for "Multi Colors"

### Changed

- Auto-update plugin now compiled with "Multi Colors" instead of morecolors.inc which caused display/weird messages in CS:GO.

### Fixed

- The Auto-update version is now compiled with "Updater" includes >_< since when I moved to 1.5 I forgot to add them...

## [3.6.1]

### Changed

- Auto-update plugin now compiled with morecolors.inc instead of colors.inc which caused the plugin to fail on some newer mods.
- Auto-update version now compiled against Source Mod 1.5.0 (To work with morecolors.inc)

### Fixed

- Source TV client should no longer get checked for AFK.

## [3.6.0]

### Added

- Due to request I have now added options for announcement of Move/Kick messages.
- Added a new option to not reset AFK on team change events as some mods shift players between teams?
- Added extra print to console for PrintToChat Debug messages (Not relevant for most)

### Changed

- Split the Spawn AFK Check into a separate timer which was part of fixes for continuity of AFK Status between death/spawn events.
- Reverted the arena move code to my original one, had false report last version that it was not working in all instances when in fact it probably was working the whole time.

### Fixed

- Fixed the forced language option, it should now work as intended.
- Fixed bug where suicide was resetting timers, especially since some mods needed suicide before player move.
- Fixed various bugs with AFK continuity between death/spawn etc.
- Fixes various checks to ensure timers do not reset on death.
- Fixed various spectator target issues that may have cause problems if previous target became invalid before check.

## [3.5.3]

### Added

- New variable to advertise only in local server language.
- New variable to disable spectator target change check from resetting AFK status.
- Updated support for new Engine Version detection. I have attempted to make this backward compatible for what it's worth.

### Changed

- Added new Arena mode checking system based on Powerlord controlpoints.inc
- TF2 Arena detection is now forced to use "FakeClientCommand" to fix various issues with VSH Mod. My initial fixes did not seem to be 100%
- TF2 now forces a Suicide when moving players to spectator since this is the default when moving manually and also to fix Arena mode issues.
- Now required SourceMod version 1.4.0+

## Fixed

- Issue with Insurgency using old settings since moving from a Mod to being released as a retail game.
- Bugs related to not kicking spectators, old code was incorrectly stopping timers and not checking manual spectator joins.

## [3.5.2]

### Fixed

- Fixed issue with not including the morecolors include file during compile and also a define clash when including with morecolors.

## [3.5.1]

### Added

- New variable for short AFK Manager tag/prefix.
- New variable for adding color to the AFK Manager tag/prefix (Requires compiling with colors include.)

### Fixed

- Fixed a bug with CTF/Intelligence Maps where AFK players were not dropping the intelligence. I now look through all intelligence objects and drop them if the AFK player is holding it.

## [3.5.0]

### Added

- Hooking for default Counter-Strike AFK cvar to disable Valve's AFK Checking.
- Integration of new Updater Plugin to allow for Automatic Plugin Updates

### Fixed

- Issue for missing SourceMod log folder (We now create a log folder if it does not exist?)
- Fix Unassigned players from being able to idle forever. At least in CS:GO players who joined the Server were forced to various camera points around the map each of which was a different "observer target". This was causing timers to reset. We now treat Unassigned players as AFK regardless of whether they are active or not, it will detect Unassigned as AFK until a team is joined.
- Stopped the AFK Manager from creating a log file if logging is completely disabled.
- The player_team event hook had code which was designed as TF2 centric but not being applied to other mods, have now changed this to apply to other mods in case it was causing weird issues.
- Fixed the AFK timers being reset when being moved to the Spectator team. This was causing timers to start from 0 again instead of continuing...
- Fixed support for CS:GO it has the same weird issues as CS:S and by the look of it more-so.

## [3.4.3]

### Fixed

- A few messages to use the correct client language rather than defaulted Server language (i.e. Move & Kick messages when advertised).
- Also added admin name & steam ID to logged message for sm_afk_spec command.

## [3.4.2]

### Fixed

- Fixed cases where on map change player team information was not calculated correctly and throwing errors.

## [3.4.1]

### Fixed

- Fixed error in spectator check for invalid player ID's.

## [3.4.0]

### Changed

- Hooking methods of say commands for chat AFK resets.
- All AFK logging is now done in its own file separate from SourceMod and has a purge interval cvar to allow deleting of old logs.

### Added

- Cvar for excluding bots from player counts.
- AutoUpdate plugin integration.
- Cvars to disable logging of move and kick messages.

### Fixed

- An issue with AFK timers getting reset if the player you were spectating died or disconnected.

## [3.3.0]

This plugin now requires SourceMod 1.3.1+

### Changed

- Waiting for Players checking mechanisms, have not properly tested this so not sure if i ended up making improvements or not.
- All console variable and event hooking methods to hopefully eliminate any potential double hooking not that this was an issue I was aware of.

### Added

- Log Warning variable for those that said the logs were getting spammed by the checking messages.
- Spawn Warning variable to try and eliminate spam messages for deathmatch type servers.

### Fixed

- Error that was related to bad TF2 variable checking that may have caused the AFK Manager to not work properly on other mods.
- Plugin player count inaccuracies.
- Re-Fixed Valves fucked up Unassigned bug for Counter-Strike where for some reason players that join the server end up firing player_spawn, return true for IsPlayerAlive() and GetClientHealth() returns 100 HP? Like w t f?

## [3.2.9]

### Fixed

- Fixed potential bug in AFK move command.
- Added more comments to code for future reference.
- Improved debug mode to be more efficient when disabled.
- Added a SourceMod log message when player counts are too low and when they have been reached to avoid confusion.

## [3.2.8]

### Fixed

- Fix for Valve firing player_spawn on spectator team? Fixed an issue with not marking players as not "Spawn AFK" after moving then causing a kick straight after.

## [3.2.7]

### Fixed

- Changed the Spawn AFK to use a different message so as to distinguish that it's actually a "spawn" check. Need people to update the translation file.
- Added a new cvar from request of people to exclude warning players who are being moved from "Unassigned" to spectator.
- Also fixed a bug in CS:S where the round would not end if the last player was moved by AFK. We now use Valve's method of suiciding players before moving to Spectator.

## [3.2.6]

### Fixed

- Fixed error that caused recurring moving client messages instead of kicking.

## [3.2.5]

### Fixed

- Changed Spawn AFK function to use the move and kick warning time so it doesn't spam messages the whole time.
- Fixed an issue where setting "move" or "kick" time to 0 did not mean disabled in the event you may want spawn timer only.

## [3.2.4]

### Added

- Added new Spawn AFK cvar and new location threshold cvar.

### Changed

- Changed AFK Location check methods. 

## [3.2.3]

### Changed

- Change Admin flag required for sm_afk_spec command from ADMFLAG_SLAY to ADMFLAG_KICK.

## [3.2.2]

### Fixed

- Fixed a small problem with the sm_afk_spec command possibly not killing timers properly if Spectator kick was disabled?

## [3.2.1]

### Added

- Added new command by request sm_afk_spec which will force a player to the spectator team. Requires new translation file and if possible updates to other languages.

## [3.2.0]

This version is no longer a "compat" build, meaning it will not compile on SourceMod 1.0.x anymore, you will need the latest Stable SourceMod version or higher (Should compile on anything higher than 1.1.x).

I would like to thank Atreus and his players for helping test numerous versions of the AFK Manager to try and fix the Arena issues. Made some good progress with this. I would also like to thank predcrab for in the end showing me how I could look at all entity changes for a given entity. With this I was able to compare my move function against the proper one to see differences of a few core entities.

### Changed

- Disable the AFK Manager on OnMapEnd() and Re-enable on OnMapStart()
- Now hooking TF2 WaitingForPlayers at start of map and disables the AFK Manager during this time.
- Now hooking TF2 Arena mode properly (Hopefully) to implement certain Hooks/Fixes due to valve majorly fucking this up.
- After a LONG time of testing and checking just what the hell Valve broke when implementing a very stupidly designed "Arena Spectator" mode which uses weird player properties to deem whether a player is an actual spectator or a "Waiting to play" person, which I think is very stupid, they should have made it the other way around imo so that spectator is normal and "waiting to play" required changes. However after extensive testing I think I have finally found a work-around to fix this.

## [3.1.4-compat]

### Changed 

- Fixed bug with plugin creating two timers for each player causing everything to happen twice as fast. Mostly due to plugin which automatically puts players on a team as soon as they join but could potentially happen in other scenario's as well. Previously initialize function did not check for existing timers as did not think this was necessary. Thanks to dann for providing info.
- Updated translation file to include Polish thanks to Zuko for the submission.
- Updated Russian translation file thanks to SelaX.
- Updated French translation file with proper accents thanks to Cadav0r.

## [3.1.3-compat]

### Changed

- Un-commented Kick announce line, thought this was commented previously because of double-printing, however Atreus believes after a map change the double-print disappears.
- Also made printed messages more consistent, so you will know they are from the AFK Manager.

## [3.1.2-compat]

### Fixed

- Fixed a bug with timers getting reset when moved to Spectator team and also people sitting at MOTD not being kicked. Thanks to Atreus for finding the problem and helping test the fix.

## [3.1.0-compat]

### Fixed

- Fixed a bug with partial admin immunity causing the plugin to make everyone immune.

## [3.0.12-compat]

### Added

- Added extra immunity options due to multiple requests, you can now change sm_afk_admins_immune to determine whether admins are fully immune, immune to being kick or immune to being moved.

## [3.0.10-compat]

### Added

- Added dead player exclusion variable. Automatically disabled TF2 AFK cvar if it's enabled. Added a few additional checks to prepare for future translation updates.

### Changed

- Updated translation file to include French thanks to Cadav0r for the submission.
- Updated translation file to include Russian thanks to Snake60 for the submission.
- Updated translation file in correct format? UTF-8 without BOM. Thanks to niask for pointing this out.

## [3.0.9-compat]

### Fixed

- Fixed bug with timer executing a function twice causing the script to run twice as fast. Also fixed the immunity description thanks to retsam for helping fix both problems.

### Changed

* Updated translation file to include Danish thanks to OziOn for the submission.

## [3.0.8-compat]

### Fixed

- Fixed problem with sm_afk_kick_players (Was checking for Bool instead of Int)

## [3.0.7-compat]

### Fixed

- Fixed a bug with Timers sometimes failing and with Stalemate round causing timers to kill instead of pause. Thanks to Antithasys for help in fixing general timer closing issues.

## [3.0.6-compat]

### Changed

- Changed convar flags as ADMFLAG_ROOT (thanks for Tsunami for pointing this out)

## [3.0.5-compat]

### Changed

- With some basic checking I have found the free-look mode is different on OB engine vs Non-OB, If you find this is not the case let me know but until then without any more data I will assume this is correct.
- Also thanks to Brizad who has suggested an additional Stalemate round check for TF2 which is also included. Updated Phrases file with TF2.

## [3.0.4-compat]

### Fixed

- Quick fix for missing "!" in a admin check which would have caused it to always return false.
 
## [3.0.3-compat]

### Added

- Added two new convars for the time before players should be warned for move or kick.

### Removed

- Removed a print message about players being kicked from the server as the actual kick message shows up in chat as well.

## [3.0.2-compat] 

### Added

- Added new translation file to make the plugin multi-lingual capable?
- Added some Turret/Entity use checks for Synergy to check eye angles when in a static location using turret machine guns etc.
- Started looking into Insurgency Wave counts.
- Added Spectator move warning message.

## [3.0.1-compat]

### Fixed

- Fixed a bug with timers not closing properly which could have caused issues as a timer was closed before it was finished. Have changed a few of the functions to hopefully fix this.
- Also due to request have added in a death hook to reset player timers once they have killed someone for mods like Insurgency where it can't check player angles.

## [3.0.0-compat]

I moved plugin to 3.x now, decided this plugin should be for the most part complete now?

### Added

- Added in a new cvar sm_afk_admins_flag which allows you to specify which admin flag to check to make certain admins immune.

## [2.5.12-compat]

### Added

- Added some checks for Insurgency to get it to work, Eye Angles doesn't currently work for Insurgency (causes crashes) so for now only location is checked. Also have to manually kill players after changing their team at least for Insurgency when players are moved to spec, let me know if it doesn't work for other mods.

### Changed

- Changed the Spectator team check back to a ugly static team id of 1 except for Insurgency so far which I have found it uses an id of 3. Let me know if the Spectator move is wrong for other mods.

### Removed
- Removed FindTeamByName() calls because they seemed to error on Team ID's that I believe should be valid? In any case thanks goes to predcrab for suggesting IsClientObserver() which will work for most instances but not all but allowed me to get further for mods that threw errors on FindTeamByName().

## [2.5.11-compat]

### Fixed

- Take 2 of fixing id 0 being called for what I believe bots? Functions now check for an id > 0.
- Tidy'd up Debug Logging messages.

## [2.5.10-compat]

### Fixed

- Fixed SourceMod bug with checking for spectator team not being case insensitive? https://bugs.alliedmods.net/show_bug.cgi?id=3446

## [2.5.9-compat]

### Added

- Added Additional checks for spawn and team change event to ensure a client is in the game? Should eliminate odd occurrences where id 0 (console) was calling these events and causing errors?

## [2.5.8-compat]

### Added

- Added new cvar to determine which players should be kicked (All, Spectators, Not Spectators)
 
## [2.5.7-compat]

### Fixed

- Fixed Admin immunity not working properly, Thanks to Tsunami and FlyingMongoose changed OnClientPutInServer to OnClientPostAdminCheck.
- Also changed cvars please delete the config file so it automatically generates or update with the new commands.

## [2.5.6-compat]

### Changed

- Reverted to a "compat" build which works in older SourceMod releases.
- Also added a few more debug messages, optimized some code and decided to stop timers running on Admins at all.

## [2.5.5]

### Fixed

- Fixed some errors that occured with timers starting before a player was fully in the game during map changes.
- Also added a few more debug messages.

## [2.5.4]

### Fixed

- Fixed Late Start Error messages? and disabled Debug by default.

## [2.5.3]

Determined all these things trying to make this plugin work with 1.0.x branch was most likely not going to work due to some necessary changed needed for new mods such as Synergy which are reliant on features only available in the 1.1 trunk. 

### Changed

- I have changed the MaxClient changes back, made a note of the required SourceMod version and this plugin will not work with 1.0.x

## [2.5.2]

### Changed

- Changed the MaxClients variable to use older method that should be supported by 1.0 SourceMod branch and added new Debug line.

## [2.5.1]

### Changed

- Took Liam's "Basic AFK Plugin" version 2.5 and modified it to work with Synergy, along the way found there was some bugs looping through all players through a single timer and so I have made this plugin create a separate timer for each individual player. Timers are dynamic as they will be created/destroyed based on number of players in game.
- Also removed seemingly un-necessary additional eye checks and tried to make spectator checking more mod-independent by searching for team names rather than set ID numbers.
- Finally I created a player warning count-down from 30 seconds before kick in TIMER_INTERVAL interval which is default every 5 seconds. Example: 30,25,20,15,10,5 seconds before kick the player is warned.
