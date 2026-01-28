/**
 * vim: set ts=4 :
 * =============================================================================
 * AFK Manager
 * Handles AFK Players
 *
 * SourceMod (C)2004-2007 AlliedModders LLC.  All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 */

#pragma semicolon			1
#include <sourcemod>
#include <sdktools>

#define VERSION				"3.1.4-compat"

#define AFK_CHECK_INTERVAL	5.0
#define _DEBUG 				0 // set to 1 to enable debug

// Arrays


// Global variables
new Handle:g_AFK_Timers[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
new Float:g_Eye_Position[MAXPLAYERS+1][3];
new Float:g_Map_Position[MAXPLAYERS+1][3];

new g_Spec_FL_Mode = 0;

new g_Spec_Mode[MAXPLAYERS+1] = {0, ...};
new g_Spec_Target[MAXPLAYERS+1] = {0, ...};

new Float:g_TimeAFK[MAXPLAYERS+1] = {0.0, ...};
new g_sTeam_Index = 1;

new g_WaitRound = false;

// Cvars
new Handle:g_Cvar_Enabled = INVALID_HANDLE;
new Handle:g_Cvar_MinPlayersMove = INVALID_HANDLE;
new Handle:g_Cvar_MinPlayersKick = INVALID_HANDLE;
new Handle:g_Cvar_AdminsImmune = INVALID_HANDLE;
new Handle:g_Cvar_AdminsFlag = INVALID_HANDLE;
new Handle:g_Cvar_MoveSpec = INVALID_HANDLE;
new Handle:g_Cvar_KickPlayers = INVALID_HANDLE;
new Handle:g_Cvar_TimeToMove = INVALID_HANDLE;
new Handle:g_Cvar_TimeToKick = INVALID_HANDLE;
new Handle:g_Cvar_WarnTimeToMove = INVALID_HANDLE;
new Handle:g_Cvar_WarnTimeToKick = INVALID_HANDLE;
new Handle:g_Cvar_ExcludeDead = INVALID_HANDLE;

// Mod AFK Cvars
new Handle:g_Cvar_AFK = INVALID_HANDLE;

// Mods
new bool:Insurgency = false;
new bool:Synergy = false;
new bool:TF2 = false;
new bool:L4D = false;

new SDKEngine = 0;

// Compat
new Max_Players;


public Plugin:myinfo =
{
    name = "AFK Manager",
    author = "Rothgar",
    description = "Handles AFK Players",
    version = VERSION,
    url = "http://www.dawgclan.net"
};

LogDebug(bool:Translation, String:text[], any:...)
{
	new String:message[255];
	if (Translation)
		VFormat(message, sizeof(message), "%T", 2);
	else
		if (strlen(text) > 0)
			VFormat(message, sizeof(message), text, 3);
		else
			return false;
#if _DEBUG
	LogAction(0, -1, "[AFK Manager] %s", message);
	return true;
#else
	return false;
#endif
}

public OnPluginStart()
{
	LogDebug(false, "AFK Plugin Started!");
	LoadTranslations("common.phrases");
	LoadTranslations("afk_manager.phrases");

	RegisterCvars();

	AutoExecConfig(true, "afk_manager");

	// Check Mods
	new String:game_mod[32];
	GetGameFolderName(game_mod, sizeof(game_mod));
	if (strcmp(game_mod, "insurgency", false) == 0)
	{
		LogAction(0, -1, "[AFK Manager] %T", "Insurgency", LANG_SERVER);
		Insurgency = true;
		g_sTeam_Index = 3;
	}
	else if (strcmp(game_mod, "synergy", false) == 0)
	{
		LogAction(0, -1, "[AFK Manager] %T", "Synergy", LANG_SERVER);
		Synergy = true;
	}
	else if (strcmp(game_mod, "tf", false) == 0)
	{
		LogAction(0, -1, "[AFK Manager] %T", "TF2", LANG_SERVER);
		TF2 = true;
		// Hook AFK Convar
		g_Cvar_AFK = FindConVar("mp_idledealmethod");
		if (g_Cvar_AFK != INVALID_HANDLE)
		{
			HookConVarChange(g_Cvar_AFK, CvarChange_AFK);
			SetConVarInt(g_Cvar_AFK, 0);
		}
	}
	else if (strcmp(game_mod, "left4dead", false) == 0)
	{
		LogAction(0, -1, "[AFK Manager] %T", "L4D", LANG_SERVER);
		L4D = true;
	}

	// Check Engine
	SDKEngine = GuessSDKVersion();

	if (SDKEngine > 30)
	{
		// Left 4 Dead
		g_Spec_FL_Mode = 6;
	}
	else if (SDKEngine > 20)
	{
		// OrangeBox
		g_Spec_FL_Mode = 6;
	}
	else
	{
		// Source/Other
		g_Spec_FL_Mode = 5;
	}

	// Register Hooks
	RegisterHooks();

	// Compat
	Max_Players = MAXPLAYERS;

	// Initialize Settings & late Load
	AFK_Initialize();

	RegAdminCmd("sm_afk_test", Command_Test, ADMFLAG_ROOT);
}

public CvarChange_AFK(Handle:cvar, const String:oldvalue[], const String:newvalue[])
{
	LogDebug(false, "CvarChange_AFK - AFK cvar has been changed. Old value: %s New value: %s", oldvalue[0], newvalue[0]);

	if (StringToInt(newvalue) > 0)
	{
			LogDebug(false, "CvarChange_AFK - Disabling Mod AFK handler.");
			SetConVarInt(cvar, 0);
	}	
}


public Action:Command_Test(client, args)
{
	PrintToChat(client, "Team Number: %i", GetClientTeam(client));

	if (IsClientObserver(client))
		PrintToChat(client, "You are an observer");
	else
		PrintToChat(client, "You are NOT an observer");

	new Entity = GetEntProp(client, Prop_Send, "m_iObserverMode");
	PrintToChat(client, "Spectator Mode: %i", Entity);

	new Entity2 = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
	PrintToChat(client, "Spectator Target: %i", Entity2);

	return Plugin_Handled;
}

public OnMapStart()
{
	// Execute Config
	AutoExecConfig(true, "afk_manager");

	// Initialize Settings
	AFK_Initialize();
}

InitializePlayer(index)
{
	if (!IsFakeClient(index))
	{
		LogDebug(false, "InitializePlayer - Initializing client: %i", index);

		// Check Timers and Destroy Them?
		if (g_AFK_Timers[index] != INVALID_HANDLE)
		{
			LogDebug(false, "InitializePlayer - Closing Old AFK timer for client: %i", index);

			CloseHandle(g_AFK_Timers[index]);
			g_AFK_Timers[index] = INVALID_HANDLE;
		}

		// Check Admin immunity
		new bool:FullImmunity = false;

		if (GetConVarInt(g_Cvar_AdminsImmune) == 1)
			if (CheckImmune(index))
				FullImmunity = true;
		if (!FullImmunity)
		{
			// Create AFK Timer
			LogDebug(false, "InitializePlayer - Creating AFK timer for client: %i", index);
			g_AFK_Timers[index] = CreateTimer(AFK_CHECK_INTERVAL, Timer_CheckPlayer, index, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

			ResetPlayer(index);
		}
		else
			LogDebug(false, "InitializePlayer - Not creating AFK timer for client: %i due to admin immunity?", index);
	}
}

UnInitializePlayer(index)
{
	// Check Timers and Destroy Them?
	if (g_AFK_Timers[index] != INVALID_HANDLE)
	{
		LogDebug(false, "UnInitializePlayer - Closing AFK timer for client: %i", index);

		CloseHandle(g_AFK_Timers[index]);
		g_AFK_Timers[index] = INVALID_HANDLE;
	}
	ResetPlayer(index);
}

ResetPlayer(index)
{
	LogDebug(false, "ResetPlayer - Reseting arrays for index: %i", index);

	// Reset Player Values
	g_TimeAFK[index] = 0.0;
	g_Eye_Position[index] = Float:{0.0,0.0,0.0};
	g_Map_Position[index] = Float:{0.0,0.0,0.0};

	g_Spec_Mode[index] = 0;
	g_Spec_Target[index] = 0;
}

AFK_Initialize()
{
	LogDebug(false, "AFK_Initialize - AFK Plugin Initializing!");

	// Make Sure Timers Are Reset
	new NumPlayers = GetClientCount(false);

	for(new i = 1; i <= NumPlayers; i++)
		if (IsClientInGame(i))
			InitializePlayer(i);

	LogDebug(false, "AFK_Initialize - Finished Reseting Clients!");	
}


public OnClientPostAdminCheck(client)
{
	// Initialize Player once they are put in the server and post-connection authorizations have been performed.
	InitializePlayer(client);
}

public OnClientDisconnect(client)
{
	// UnInitializePlayer since they are leaving the server.
	UnInitializePlayer(client);
}

RegisterHooks()
{
	// Register Game Hooks
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_team", Event_PlayerTeam);
	HookEvent("player_death",Event_PlayerDeath);

	if (TF2)
	{
		HookEvent("teamplay_round_start", Event_RoundStart);
		HookEvent("teamplay_round_stalemate", Event_StaleMate);
	}

	RegConsoleCmd("say", SayCommand);
	RegConsoleCmd("say_team", SayCommand);
}

public Action:Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetConVarBool(g_Cvar_Enabled))
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
		if (client > 0)
		{
			if (!IsFakeClient(client))
			{
				LogDebug(false, "Event_PlayerSpawn - Client spawned: %i", client);
				ResetPlayer(client);
			}
		}
	}
	return Plugin_Continue;
}

public Action:Event_PlayerTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetConVarBool(g_Cvar_Enabled))
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));

		if (client > 0)
		{
			if (!IsFakeClient(client))
			{
				new team = GetEventInt(event, "team");

				// Lets reset their AFK timer if they join a team.
				if(team != g_sTeam_Index)
				{
					LogDebug(false, "Event_PlayerTeam - Client: %d joined team: %d", client, team);

					if (g_AFK_Timers[client] == INVALID_HANDLE)
					{
						LogDebug(false, "Event_PlayerTeam - Client: %d joined a team and does not have a valid timer? Re-Initializing client", client);
						InitializePlayer(client);
					}
					else
						ResetPlayer(client);
				}
				else
				{
					// Player joined or was moved to spectator team?
					LogDebug(false, "Event_PlayerTeam - Client: %d joined spectator team", client);
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action:Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast){
	if (GetConVarBool(g_Cvar_Enabled))
	{
		new client = GetClientOfUserId(GetEventInt(event,"attacker"));

		// Reset timers once player has killed someone.
		ResetPlayer(client);
	}
	return Plugin_Continue;
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Round Started
	LogDebug(false, "Event_RoundStart - Round Started");

	g_WaitRound = false;
	return Plugin_Continue;
}

public Action:Event_StaleMate(Handle:event, const String:name[], bool:dontBroadcast)
{
	// TF2 Stalemate?
	LogDebug(false, "Event_StaleMate - StaleMate Started");

	g_WaitRound = true;
	return Plugin_Continue;
}

public Action:SayCommand(client, argc)
{
	if (GetConVarBool(g_Cvar_Enabled))
	{
		// Reset timers once player has said something in chat.
		ResetPlayer(client);
	}
	return Plugin_Continue;
}

RegisterCvars()
{
	CreateConVar("sm_afkm_version", VERSION, "Current version of the AFK Manager", FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_Cvar_Enabled = CreateConVar("sm_afk_enable", "1", "Is the AFK manager enabled or disabled? [0 = FALSE, 1 = TRUE]");
	g_Cvar_MinPlayersMove = CreateConVar("sm_afk_move_min_players", "4", "Minimum amount of connected clients needed to move clients to spectator.");
	g_Cvar_MinPlayersKick = CreateConVar("sm_afk_kick_min_players", "6", "Minimum amount of connected clients needed to kick AFK clients.");
	g_Cvar_KickPlayers = CreateConVar("sm_afk_kick_players", "1", "Should the AFK manager kick clients? [0 = DISABLED, 1 = KICK ALL, 2 = ALL EXCEPT SPECTATORS, 3 = SPECTATORS ONLY]");
	g_Cvar_AdminsImmune = CreateConVar("sm_afk_admins_immune", "1", "Are Admins immune to to the AFK Manager? [0 = DISABLED, 1 = COMPLETE IMMUNITY, 2 = KICK IMMUNITY, 3 = MOVE IMMUNITY]");
	g_Cvar_AdminsFlag = CreateConVar("sm_afk_admins_flag", "", "Admin Flag for immunity? Leave Blank for any flag.");
	g_Cvar_MoveSpec = CreateConVar("sm_afk_move_spec", "0", "Move AFK clients to spec before kicking them? [0 = FALSE, 1 = TRUE]");
	g_Cvar_WarnTimeToMove = CreateConVar("sm_afk_move_warn_time", "30.0", "Time in seconds remaining, player should be warned before being moved for AFK. [DEFAULT: 30.0 seconds]");
	g_Cvar_TimeToMove = CreateConVar("sm_afk_move_time", "60.0", "Time in seconds (total) client must be AFK before being moved to spectator.");
	g_Cvar_WarnTimeToKick = CreateConVar("sm_afk_kick_warn_time", "30.0", "Time in seconds remaining, player should be warned before being kicked for AFK. [DEFAULT: 30.0 seconds]");
	g_Cvar_TimeToKick = CreateConVar("sm_afk_kick_time", "120.0", "Time in seconds (total) client must be AFK before being kicked.");
	g_Cvar_ExcludeDead = CreateConVar("sm_afk_exclude_dead", "0", "Should the AFK manager exclude checking dead players? [0 = FALSE, 1 = TRUE]");
}


public Action:Timer_CheckPlayer(Handle:Timer, any:client)
{
	LogDebug(false, "RUNNING TIMER #1");
	if(GetConVarBool(g_Cvar_Enabled))
	{
		if (g_WaitRound)
			return Plugin_Continue;

		new NumPlayers = GetClientCount(false);

		if ( (NumPlayers < GetConVarInt(g_Cvar_MinPlayersMove)) && (NumPlayers < GetConVarInt(g_Cvar_MinPlayersKick)) )
		{
			// Not enough players halting check
			return Plugin_Continue;
		}

		LogDebug(false, "RUNNING TIMER #2");
		if (IsClientInGame(client))
		{
			new Action:timer_result = CheckForAFK(client, NumPlayers);
			if (timer_result != Plugin_Stop)
				return timer_result;
		}
		else
			return Plugin_Continue;
	}

	g_AFK_Timers[client] = INVALID_HANDLE;
	return Plugin_Stop;
}

bool:CheckObserverAFK(client)
{
	// Store Previous Eye Angle/Origin Values
	decl Float:f_Eye_Loc[3], Float:f_Map_Loc[3];
	f_Eye_Loc = g_Eye_Position[client];
	f_Map_Loc = g_Map_Position[client];

	// Store Last Spec Mode
	new g_Last_Mode = g_Spec_Mode[client];

	g_Spec_Mode[client] = GetEntProp(client, Prop_Send, "m_iObserverMode");

	if (g_Last_Mode > 0)
	{
		if (g_Spec_Mode[client] != g_Last_Mode)
		{
			LogDebug(false, "Observer has changed modes? Old: %i New: %i Not AFK?", g_Last_Mode, g_Spec_Mode[client]);
			return false;
		}
	}

	if (g_Spec_Mode[client] == g_Spec_FL_Mode)
	{
		// Free-Look Mode
		// Get New Player Eye Angles
		GetPlayerEye(client, g_Eye_Position[client]);

		// Get New Player Map Origin
		GetClientAbsOrigin(client, g_Map_Position[client]);
	}
	else
	{
		// Store Last Spec Target
		new g_Last_Spec = g_Spec_Target[client];
		g_Spec_Target[client] = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");

		// Check if player was just moved to Spectator?
		if ((g_Last_Mode == 0) && (g_Last_Spec == 0))
			return true;

		if (g_Last_Spec > 0)
		{
			if (g_Spec_Target[client] != g_Last_Spec)
			{
				LogDebug(false, "Observer looking at new target? Old: %i New: %i Not AFK?", g_Last_Spec, g_Spec_Target[client]);
				return false;
			}
		}
	}

	// Check Location (Origin)
	if ((g_Map_Position[client][0] == f_Map_Loc[0]) &&
		(g_Map_Position[client][1] == f_Map_Loc[1]) &&
		(g_Map_Position[client][2] == f_Map_Loc[2]))
	{
		// Check Eye Angles
		if ((g_Eye_Position[client][0] == f_Eye_Loc[0]) &&
			(g_Eye_Position[client][1] == f_Eye_Loc[1]) &&
			(g_Eye_Position[client][2] == f_Eye_Loc[2]))
		{
			return true;
		}
	}
	return false;
}

bool:CheckSamePosition(client)
{
	// Store Previous Eye Angle/Origin Values
	decl Float:f_Eye_Loc[3], Float:f_Map_Loc[3];
	f_Eye_Loc = g_Eye_Position[client];
	f_Map_Loc = g_Map_Position[client];

	// Get New Player Eye Angles
	if (!Insurgency)
		GetPlayerEye(client, g_Eye_Position[client]);

	// Get New Player Map Origin
	GetClientAbsOrigin(client, g_Map_Position[client]);

	LogDebug(false, "CheckSamePosition - Checking Player Positions: Client: %d Old Angle: %f %f %f New Angle: %f %f %f", client, f_Eye_Loc[0], f_Eye_Loc[1], f_Eye_Loc[2], g_Eye_Position[client][0], g_Eye_Position[client][1], g_Eye_Position[client][2]);

	// Check Location (Origin)
	if ((g_Map_Position[client][0] == f_Map_Loc[0]) &&
		(g_Map_Position[client][1] == f_Map_Loc[1]) &&
		(g_Map_Position[client][2] == f_Map_Loc[2]))
	{
		// Check for Synergy Turret?
		if (Synergy)
		{
			decl UseEntity;
			UseEntity = GetEntPropEnt(client, Prop_Send, "m_hUseEntity");

			if (UseEntity != -1)
			{
				// Check Turret Angles?
				LogDebug(false, "CheckSamePosition - Checking Player Turret Angles");
				GetEntPropVector(UseEntity, Prop_Send, "m_angRotation", g_Eye_Position[3]);
				LogDebug(false, "CheckSamePosition - Turret Angles: %f %f %f", g_Eye_Position[client][0], g_Eye_Position[client][1], g_Eye_Position[client][2]);
			}
		}

		// Check Eye Angles
		if ((g_Eye_Position[client][0] == f_Eye_Loc[0]) &&
			(g_Eye_Position[client][1] == f_Eye_Loc[1]) &&
			(g_Eye_Position[client][2] == f_Eye_Loc[2]))
		{
			if (Insurgency)
			{
				if (!IsPlayerAlive(client))
				{
					// Check Re-Inforcements
					new waves = FindSendPropInfo("CPlayTeam", "numwaves");
					LogDebug(false, "CheckSamePosition - Checking Waves? %i", waves);
					new time = GetEntPropEnt(client, Prop_Send, "m_flDeathTime");
					LogDebug(false, "CheckSamePosition - Checking Death Time? %i", time);
					if (waves <= 0)
						return false;
				}
				else
					return true;
			}
			else
				return true;
		}
	}
	return false;
}

Action:CheckForAFK(client, NumPlayers)
{
	new Float:f_KickTime = GetConVarFloat(g_Cvar_TimeToKick);
	new Float:f_MoveTime = GetConVarFloat(g_Cvar_TimeToMove);

	new g_TeamNum = GetClientTeam(client);

	if (IsClientObserver(client))
	{
		if ((Synergy) || (g_TeamNum > 0))
		{
			// Check Excluding Dead Players?
			if (!IsPlayerAlive(client))
				if (g_TeamNum != g_sTeam_Index)
					if (GetConVarBool(g_Cvar_ExcludeDead))
						return Plugin_Continue;

			if (CheckObserverAFK(client))
				g_TimeAFK[client] = (g_TimeAFK[client] + AFK_CHECK_INTERVAL);
			else
				g_TimeAFK[client] = 0.0;
		}
		else
			g_TimeAFK[client] = (g_TimeAFK[client] + AFK_CHECK_INTERVAL);
	}
	else
	{
		if (CheckSamePosition(client))
			g_TimeAFK[client] = (g_TimeAFK[client] + AFK_CHECK_INTERVAL);
		else
			g_TimeAFK[client] = 0.0;
	}

	// Check Admin immunity
	new AdminsImmune = GetConVarInt(g_Cvar_AdminsImmune);

	if (g_TimeAFK[client] > 0.0)
	{
		if (GetConVarBool(g_Cvar_MoveSpec))
		{
			if (g_TeamNum != g_sTeam_Index)
			{
				if (NumPlayers >= GetConVarInt(g_Cvar_MinPlayersMove))
				{
					if ( (!AdminsImmune) || (AdminsImmune == 2) || (!CheckImmune(client)) )
					{
						new Float:afk_move_timeleft = (f_MoveTime - g_TimeAFK[client]);

						// Client Warning
						new Float:f_MoveWarnTime = GetConVarFloat(g_Cvar_WarnTimeToMove);

						if (afk_move_timeleft <= f_MoveWarnTime)
						{
							if (afk_move_timeleft > 0.0)
							{
								LogDebug(false, "CheckForAFK - Checking AFK Time (Move): Client: %d Timeleft: %f", client, afk_move_timeleft);
								PrintToChat(client, "[AFK Manager] %t", "Spectate_Warning", RoundToFloor(afk_move_timeleft));
							}
							else
								return MoveAFKClient(client);
						}
						else	
							return Plugin_Continue;
					}
				}
			}
		}

		// Handle Client Kick Checking
		new KickPlayers = GetConVarInt(g_Cvar_KickPlayers);
		if (KickPlayers)
		{
			if (NumPlayers >= GetConVarInt(g_Cvar_MinPlayersKick))
			{
				if ( (!AdminsImmune) || (AdminsImmune == 3) || (!CheckImmune(client)) )
				{
					if (KickPlayers == 3)
					{
						// Kicking is set to spectator only? Check players team?
						if (g_TeamNum != g_sTeam_Index)
						{
							// Player is not on the spectator team? Spectators should only be kicked? Check timers?

							// Player should not be kicked (Spectators only)? and is not currently on and will not be moved to Spectator team?
							// Timer is still running on the client? Error?
							LogDebug(false, "CheckForAFK - ERROR: Client %s has an active timer but should not be moved or kicked? This should probably not happen.", client);
							return Plugin_Continue;
						}
					}

					new Float:afk_kick_timeleft = (f_KickTime - g_TimeAFK[client]);

					// Added Client Warnings
					new Float:f_KickWarnTime = GetConVarFloat(g_Cvar_WarnTimeToKick);

					if (afk_kick_timeleft <= f_KickWarnTime)
						if (afk_kick_timeleft > 0.0)
						{
							LogDebug(false, "CheckForAFK - Checking AFK Time (Kick): Client: %d Timeleft: %f", client, afk_kick_timeleft);
							if (IsClientObserver(client))
								PrintToChat(client, "[AFK Manager] %t", "Kick_Warning", RoundToFloor(afk_kick_timeleft));
							else
								PrintToChat(client, "[AFK Manager] %t", "Kick_Warning", RoundToFloor(afk_kick_timeleft));
						}
						else
							KickAFKClient(client);
				}
			}
		}
	}
	return Plugin_Continue;
}

Action:MoveAFKClient(client)
{
	decl String:f_Name[MAX_NAME_LENGTH];
	GetClientName(client, f_Name, sizeof(f_Name));

	PrintToChatAll("[AFK Manager] %T", "Spectate_Announce", LANG_SERVER, f_Name);
	LogAction(0, -1, "[AFK Manager] %T", "Spectate_Log", LANG_SERVER, client);

	// Move AFK Player to Spectator
	ChangeClientTeam(client, g_sTeam_Index);
	if (IsPlayerAlive(client))
		if (Insurgency)
			ClientCommand(client, "kill");

	new KickPlayers = GetConVarInt(g_Cvar_KickPlayers);
	if( (!KickPlayers) || (KickPlayers == 2) )
	{
		LogDebug(false, "Spectators should not be kicked due to settings? Stop Timer?");
		// Reset Client Variables because timer will halt?
		ResetPlayer(client);
		return Plugin_Stop;
	}
	else
		return Plugin_Continue;
}

KickAFKClient(client)
{
	decl String:f_Name[MAX_NAME_LENGTH];
	GetClientName(client, f_Name, sizeof(f_Name));

	PrintToChatAll("[AFK Manager] %T", "Kick_Announce", LANG_SERVER, f_Name);
	LogAction(0, -1, "[AFK Manager] %T", "Kick_Log", LANG_SERVER, client);

	// Kick AFK Player
	KickClient(client, "[AFK Manager] %T", "Kick_Message", client);
}

// This code was borrowed from Nican's spraytracer
bool:GetPlayerEye(client, Float:pos[3])
{
	new Float:vAngles[3], Float:vOrigin[3];
	GetClientEyePosition(client, vOrigin);
	if ( GetClientEyeAngles(client, vAngles) )
	{
		new Handle:trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);

		if(TR_DidHit(trace))
		{
			TR_GetEndPosition(pos, trace);
			CloseHandle(trace);
			return true;
		}
		else
			CloseHandle(trace);
	}
	return false;
}

public bool:TraceEntityFilterPlayer(entity, contentsMask)
{
	return entity > Max_Players;
}

bool:CheckImmunePlayer(client)
{
	new AdminId:admin = GetUserAdmin(client);

	decl String:name[MAX_NAME_LENGTH];
	GetClientName(client, name, sizeof(name));

	if(admin != INVALID_ADMIN_ID)
	{
		decl String:flags[8];
		decl AdminFlag:flag;

		GetConVarString(g_Cvar_AdminsFlag, flags, sizeof(flags));

		if (!StrEqual(flags, "", false))
		{
			if (!FindFlagByChar(flags[0], flag))
				LogDebug(false, "CheckImmunePlayer - ERROR: Admin Immunity flag is not valid? %s", flags[0]);
			else
			{
				if (!GetAdminFlag(admin, flag))
					LogDebug(false, "CheckImmunePlayer - Client %s has a valid Admin ID but does NOT have required immunity flag %s admin is NOT immune.", name, flags[0]);
				else
				{
					LogDebug(false, "CheckImmunePlayer - Client %s has required immunity flag %s admin is immune.", name, flags[0]);
					return true;
				}
			}
		}
		else
		{
			LogDebug(false, "CheckImmunePlayer - Client %s is a valid Admin and is immune.", name);
			return true;
		}
	}
	else
		LogDebug(false, "CheckImmunePlayer - Client %s has an invalid Admin ID.", name);

	return false;
}

bool:CheckImmune(client)
{
	LogDebug(false, "CheckImmune - Checking client: %i for admin immunity.", client);

	return CheckImmunePlayer(client);
}