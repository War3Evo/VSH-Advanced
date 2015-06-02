// vsha-addon-DuoBossFightGameMode.sp

#pragma semicolon 1
#include <sourcemod>
#include <sdkhooks>
#include <morecolors>
#include <vsha>
#include <vsha_stocks>

public Plugin myinfo =
{
	name 			= "Duo Boss Fight",
	author 			= "Valve",
	description 		= "Saxton Haaaaaaaaaaaaale",
	version 		= "1.0",
	url 			= "http://wiki.teamfortress.com/wiki/VS_Saxton_Hale_Mode"
}

ConVar ThisEnabled = null;

public void OnPluginStart()
{
	ThisEnabled = CreateConVar("vsha_duo_boss", "1", "Enable Duo Boss Fighting Mode", FCVAR_PLUGIN, true, 0.0, true, 1.0);
}

public void OnAllPluginsLoaded()
{
	if(!VSHAHookEx(VSHAHook_OnGameMode_BossSetup, OnGameMode_BossSetup))
	{
		LogError("Error loading VSHAHook_OnGameMode_BossSetup forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnGameMode_WatchGameModeTimer, OnGameMode_WatchGameModeTimer))
	{
		LogError("Error loading VSHAHook_OnGameMode_WatchGameModeTimer forwards for saxton hale.");
	}

	if(!VSHAHookEx(VSHAHook_OnGameMode_ForceBossTeamChange, OnGameMode_ForceBossTeamChange))
	{
		LogError("Error loading VSHAHook_OnGameMode_ForceBossTeamChange forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnGameMode_ForcePlayerTeamChange, OnGameMode_ForcePlayerTeamChange))
	{
		LogError("Error loading VSHAHook_OnGameMode_ForcePlayerTeamChange forwards for saxton hale.");
	}

	if(!VSHAHookEx(VSHAHook_OnBossWin, OnBossWin))
	{
		LogError("Error loading VSHAHook_OnBossWin forwards for saxton hale.");
	}
}

public Action OnGameMode_ForceBossTeamChange(int iiBoss, int iTeam)
{
	if(!ThisEnabled.BoolValue) return Plugin_Continue;

	if(VSHA_IsBossPlayer(iiBoss))
	{
		ForceTeamChange(iiBoss, TEAM_RED);
		TF2_RegeneratePlayer(iiBoss);
	}
	return Plugin_Handled;
}

public Action OnGameMode_ForcePlayerTeamChange(int iClient, int iTeam)
{
	if(!ThisEnabled.BoolValue) return Plugin_Continue;

	if(!VSHA_IsBossPlayer(iClient))
	{
		ForceTeamChange(iClient, TEAM_BLUE);
		TF2_RegeneratePlayer(iClient);
	}
	return Plugin_Handled;
}

public Action OnGameMode_WatchGameModeTimer()
{
	if(!ThisEnabled.BoolValue) return Plugin_Continue;

	//if(VSHA_GetPlayerCount()>4)
	//{
	return Plugin_Handled;
	//}
	//return Plugin_Continue;
}

public Action OnGameMode_BossSetup()
{
	if(!ThisEnabled.BoolValue) return Plugin_Continue;

	if(VSHA_GetPlayerCount()<4)
	{
		CPrintToChatAll("%s Unable to play Duo Bosses with less than 4 players!",VSHA_COLOR);
		return Plugin_Continue;
	}
	SetConVarInt(FindConVar("mp_teams_unbalance_limit"), 0);

	// BOSS 1
	int boss = VSHA_AddBoss();

	if(boss == -1)
	{
		CPrintToChatAll("%s Unable to play Duo Bosses!  Not enough players.",VSHA_COLOR);
		return Plugin_Continue;
	}

	VSHA_BossSelected_Forward(boss);

	VSHA_SetClientQueuePoints(boss, 0);

	// BOSS 2

	boss = VSHA_AddBoss();

	if(boss == -1)
	{
		CPrintToChatAll("%s Unable to play Duo Bosses!  Not enough players.",VSHA_COLOR);
		return Plugin_Continue;
	}

	VSHA_BossSelected_Forward(boss);

	VSHA_SetClientQueuePoints(boss, 0);

	if ( GetTeamPlayerCount(TEAM_BLUE) <= 0 || GetTeamPlayerCount(TEAM_RED) <= 0 )
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if ( IsValidClient(i) && IsOnBlueOrRedTeam(i) )
			{
				if (VSHA_IsBossPlayer(i))
				{
					ForceTeamChange(i, TEAM_RED);
				}
				else
				{
					ForceTeamChange(i, TEAM_BLUE);
				}
			}
		}
	}
	VSHA_SetPlayMusic(false);
	CPrintToChatAll("%s DUO BOSSES!",VSHA_COLOR);

	// will be adding duo boss theme music sometime soon
	//CreateTimer(9.1, MusicTimerStart);

	return Plugin_Handled;
}

//public Action MusicTimerStart(Handle timer, int userid)
//{
//}

public void OnBossWin(Event event, int iiBoss)
{
	// set defaults back
	VSHA_SetPlayMusic(true);
}
