// vsha-addon-BossVsBossGameMode.sp

#pragma semicolon 1
#include <sourcemod>
#include <sdkhooks>
#include <morecolors>
#include <vsha>
#include <vsha_stocks>

public Plugin myinfo =
{
	name 			= "Boss Game Modes Fight",
	author 			= "Valve",
	description 		= "Saxton Haaaaaaaaaaaaale",
	version 		= "1.0",
	url 			= "http://wiki.teamfortress.com/wiki/VS_Saxton_Hale_Mode"
}

ConVar ThisEnabled = null;
ConVar GameModeType = null;

// Themes
char BossVsBoss1[PATHX];
char DuoBoss1[PATHX];

bool ThemeMusicIsPlaying = false;

#define ThisConfigurationFile "configs/vsha/gamemodes.cfg"

#define DuoBossGameMode		1
#define BossVsBossGameMode	2
#define RandomBossGameMode	999

public void OnPluginStart()
{
	ThisEnabled = CreateConVar("vsha_gamemode_enabled", "0", "Enable Game Modes", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	GameModeType = CreateConVar("vsha_gamemode_type", "0", "0 - default, 1 - Duo Boss, 2 - Boss vs Boss, 999 - Random", FCVAR_PLUGIN, true, 0.0, true, 1.0);
}

public void OnAllPluginsLoaded()
{
	if(!VSHAHookEx(VSHAHook_OnGameMode_BossSetup, OnGameMode_BossSetup))
	{
		LogError("Error loading VSHAHook_OnGameMode_BossSetup forwards for gamemodes.");
	}
	if(!VSHAHookEx(VSHAHook_OnGameMode_WatchGameModeTimer, OnGameMode_WatchGameModeTimer))
	{
		LogError("Error loading VSHAHook_OnGameMode_WatchGameModeTimer forwards for gamemodes.");
	}

	if(!VSHAHookEx(VSHAHook_OnGameMode_ForceBossTeamChange, OnGameMode_ForceBossTeamChange))
	{
		LogError("Error loading VSHAHook_OnGameMode_ForceBossTeamChange forwards for gamemodes.");
	}
	if(!VSHAHookEx(VSHAHook_OnGameMode_ForcePlayerTeamChange, OnGameMode_ForcePlayerTeamChange))
	{
		LogError("Error loading VSHAHook_OnGameMode_ForcePlayerTeamChange forwards for gamemodes.");
	}

	//if(!VSHAHookEx(VSHAHook_OnBossWin, OnBossWin))
	//{
		//LogError("Error loading VSHAHook_OnBossWin forwards for gamemodes.");
	//}

	if(!VSHAUnhookEx(VSHAHook_OnMusic, OnMusic))
	{
		LogError("Error unloading VSHAHook_OnMusic forwards for gamemodes.");
	}

	if(!VSHAHookEx(VSHAHook_OnGameOver, OnGameOver))
	{
		LogError("Error loading VSHAHook_OnGameOver forwards for saxton hale.");
	}

	//VSHAHook(VSHAHook_OnEquipPlayer_Post, OnEquipPlayer_Post);

	VSHA_LoadConfiguration(ThisConfigurationFile);
}

public Action OnGameMode_ForceBossTeamChange(int iiBoss, int iTeam)
{
	if(!ThisEnabled.BoolValue) return Plugin_Continue;

	if(GameModeType.IntValue == DuoBossGameMode && VSHA_IsBossPlayer(iiBoss))
	{
		ForceTeamChange(iiBoss, TEAM_RED);
		TF2_RegeneratePlayer(iiBoss);
	}
	return Plugin_Handled;
}

public Action OnGameMode_ForcePlayerTeamChange(int iClient, int iTeam)
{
	if(!ThisEnabled.BoolValue) return Plugin_Continue;

	if(GameModeType.IntValue == DuoBossGameMode && !VSHA_IsBossPlayer(iClient))
	{
		ForceTeamChange(iClient, TEAM_BLUE);
		TF2_RegeneratePlayer(iClient);
	}
	return Plugin_Handled;
}

public Action OnGameMode_WatchGameModeTimer()
{
	if(!ThisEnabled.BoolValue) return Plugin_Continue;

	if(GameModeType.IntValue > 0)
	{
		return Plugin_Handled;
	}

	//if(VSHA_GetPlayerCount()>4)
	//{
	//return Plugin_Handled;
	//}
	//return Plugin_Continue;

	return Plugin_Continue;
}

public Action OnGameMode_BossSetup()
{
	if(!ThisEnabled.BoolValue) return Plugin_Continue;

	int iGameMode = -1;

	if(GameModeType.IntValue == RandomBossGameMode)
	{
		iGameMode = GetRandomInt(0,2);
	}
	else
	{
		iGameMode = GameModeType.IntValue;
	}

	if(iGameMode == DuoBossGameMode)
	{
		if(VSHA_GetPlayerCount()<3)
		{
			PrintToServer("%s Unable to play Duo Bosses with less than 3 players!",VSHA_COLOR);
			return Plugin_Continue;
		}
		else
		SetConVarInt(FindConVar("mp_teams_unbalance_limit"), 0);

		VSHA_SetPlayMusic(false);

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
		CPrintToChatAll("%s DUO BOSSES!",VSHA_COLOR);

		// will be adding duo boss theme music sometime soon
		//CreateTimer(9.1, MusicTimerStart);

		return Plugin_Handled;
	}
	else if(iGameMode == BossVsBossGameMode)
	{
		if(VSHA_GetPlayerCount()<2)
		{
			PrintToServer("%s Unable to play Boss Vs Boss with less than 2 players!",VSHA_COLOR);
			return Plugin_Continue;
		}
		else
		SetConVarInt(FindConVar("mp_teams_unbalance_limit"), 1); // balance the teams for boss vs boss

		VSHA_SetPlayMusic(false);

		// BOSS 1
		int boss = VSHA_AddBoss();

		if(boss == -1)
		{
			CPrintToChatAll("%s Unable to play Duo Bosses!  Not enough players.",VSHA_COLOR);
			return Plugin_Continue;
		}

		VSHA_BossSelected_Forward(boss);

		VSHA_SetClientQueuePoints(boss, 0);

		ForceTeamChange(boss, TEAM_RED);

		// BOSS 2

		boss = VSHA_AddBoss();

		if(boss == -1)
		{
			CPrintToChatAll("%s Unable to play Duo Bosses!  Not enough players.",VSHA_COLOR);
			return Plugin_Continue;
		}

		VSHA_BossSelected_Forward(boss);

		VSHA_SetClientQueuePoints(boss, 0);

		ForceTeamChange(boss, TEAM_BLUE);

		int iTeamColor = 2;

		if ( GetTeamPlayerCount(TEAM_BLUE) <= 0 || GetTeamPlayerCount(TEAM_RED) <= 0 )
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if ( IsValidClient(i) && IsOnBlueOrRedTeam(i) )
				{
					if (!VSHA_IsBossPlayer(i))
					{
						ForceTeamChange(i, iTeamColor);
						// toggle team colors
						iTeamColor = (iTeamColor == 2 ? 3 : 2);
					}
				}
			}
		}
		CPrintToChatAll("%s BOSS VS BOSS!",VSHA_COLOR);

		// will be adding duo boss theme music sometime soon
		//CreateTimer(9.1, MusicTimerStart);

		return Plugin_Handled;
	}
	return Plugin_Continue;
}
/*
public Action MusicTimerStart(Handle timer, int userid)
{
	LoopAlivePlayers(players)
	{
		if(VSHA_IsBossPlayer(players))
		{
			VSHA_CallModelTimer(2.0,GetClientUserId(players));
		}
	}
}*/

//public void OnEquipPlayer_Post(int iClient)
//{
	//if(ValidPlayer(iClient))
	//{

	//}
//}

public Action OnMusic(int iiBoss, char BossTheme[PATHX], float &time)
{
	if (iiBoss != -2) return Plugin_Continue;
	if (ThemeMusicIsPlaying)
	{
		return Plugin_Continue;
	}

	if(GameModeType.IntValue == BossVsBossGameMode)
	{
		ThemeMusicIsPlaying = true;
		BossTheme = BossVsBoss1;
		time = 94.0;
	}
	else if(GameModeType.IntValue == DuoBossGameMode)
	{
		ThemeMusicIsPlaying = true;
		BossTheme = DuoBoss1;
		time = 121.0;
	}

	return Plugin_Continue;
}

public void OnGameOver() // best play to reset all variables
{
	LoopMaxPLYR(players)
	{
		if(ValidPlayer(players))
		{
			StopSound(players, SNDCHAN_AUTO, BossVsBoss1);
			StopSound(players, SNDCHAN_AUTO, DuoBoss1);
		}
	}
	ThemeMusicIsPlaying = false;
	VSHA_SetPlayMusic(true);
}



// LOAD CONFIGURATION
public void OnConfiguration_Load_Sounds(char[] cFile, char[] skey, char[] value, bool &bPreCacheFile, bool &bAddFileToDownloadsTable)
{
	if(!StrEqual(cFile, ThisConfigurationFile)) return;

	if(StrEqual(skey, "BossVsBoss1"))
	{
		if(StrEqual(BossVsBoss1,"")) return;
		strcopy(STRING(BossVsBoss1), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "DuoBoss1"))
	{
		if(StrEqual(DuoBoss1,"")) return;
		strcopy(STRING(DuoBoss1), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}

	if(bPreCacheFile || bAddFileToDownloadsTable)
	{
		PrintToServer("Loading GAME MODE THEMES %s = %s",skey,value);
	}
}
