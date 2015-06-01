#undef REQUIRE_EXTENSIONS
#tryinclude <steamtools>
#define REQUIRE_EXTENSIONS

//#include <sourcemod>
#include <clientprefs>
#include <tf2attributes>
#include <morecolors>
#include <sdkhooks>
#include <vsha>
#include <vsha_stocks>

#define PLUGIN_VERSION			"0.1"

public Plugin myinfo = {
	name = "Versus Saxton Hale Engine",
	author = "Diablo, Nergal, Chdata, Cookies, with special props to Powerlord + Flamin' Sarge",
	description = "Es Sexy-time beyechez",
	version = PLUGIN_VERSION,
	url = "https://github.com/War3Evo/VSH-Advanced"
};

ArrayList hArrayNonBossSubplugins = null;	// List <Subplugin Addon> Not a boss addon, just an external extra


ArrayList hArrayBossSubplugins = null;	// List <Subplugin>
StringMap hTrieBossSubplugins = null;	// Map <Boss Name, Subplugin Handle>

enum VSHAError
{
	Error_None,				// All-Clear :>
	Error_InvalidName,			// Invalid name for Boss
	Error_AlreadyExists,			// Boss Already Exists....
	Error_SubpluginAlreadyRegistered,	// The plugin registering a boss already has a boss registered
}

#include "vsha/vsha_variables.inc"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"

#include "vsha/vsha_SDKHooks_OnPreThink.inc"
#include "vsha/vsha_SDKHooks_OnEntityCreated.inc"
#include "vsha/vsha_SDKHooks_OnGetMaxHealth.inc"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"

#include "vsha/vsha_000_OnPluginStart.inc"
#include "vsha/vsha_000_OnClientPutInServer.inc"
#include "vsha/vsha_000_OnClientDisconnect.inc"
#include "vsha/vsha_000_OnMapStart.inc"
#include "vsha/vsha_000_OnMapEnd.inc"
#include "vsha/vsha_000_OnLibraryAdded.inc"
#include "vsha/vsha_000_OnLibraryRemoved.inc"
#include "vsha/vsha_000_OnConfigsExecuted.inc"
#include "vsha/vsha_000_RegConsoleCmd.inc"
#include "vsha/vsha_000_RegAdminCmd.inc"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"

//#include "vsha/"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"

#include "vsha/vsha_CommandListener_DoTaunt.inc"
#include "vsha/vsha_CommandListener_DoSuicide.inc"
#include "vsha/vsha_CommandListener_DoSuicide2.inc"
#include "vsha/vsha_CommandListener_clDestroy.inc"
#include "vsha/vsha_CommandListener_CallMedVoiceMenu.inc"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"

#include "vsha/vsha_Engine_OnWeaponSpawned.inc"
#include "vsha/vsha_Engine_PlayerHUD.inc"
#include "vsha/vsha_Engine_BossHUD.inc"
#include "vsha/vsha_Engine_UpdateHealthBar.inc"
#include "vsha/vsha_Engine_SubPlugin_Configuration_File.inc"
#include "vsha/vsha_Engine_ClearVariables.inc"
#include "vsha/vsha_Engine_CacheDownloads.inc"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"

#include "vsha/vsha_PawnTimer_MakeModelTimer.inc"
#include "vsha/vsha_PawnTimer_BossStart.inc"
#include "vsha/vsha_PawnTimer_InitBoss.inc"
#include "vsha/vsha_PawnTimer_DoMessage.inc"
#include "vsha/vsha_PawnTimer_CheckAlivePlayers.inc"
#include "vsha/vsha_PawnTimer_MakeBoss.inc"
#include "vsha/vsha_PawnTimer_EquipPlayers.inc"
#include "vsha/vsha_PawnTimer_CalcScores.inc"
#include "vsha/vsha_PawnTimer_tTenSecStart.inc"
#include "vsha/vsha_PawnTimer_TimerNineThousand.inc"
#include "vsha/vsha_PawnTimer_ResetUberCharge.inc"
#include "vsha/vsha_PawnTimer_CleanScreen.inc"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"

#include "vsha/vsha_CreateTimer_Timer_CheckDoors.inc"
#include "vsha/vsha_CreateTimer_Timer_DrawGame.inc"
#include "vsha/vsha_CreateTimer_Timer_SkipHalePanel.inc"
#include "vsha/vsha_CreateTimer_HaleTimer.inc"
#include "vsha/vsha_CreateTimer_Timer_Uber.inc"
#include "vsha/vsha_CreateTimer_Timer_RemoveHonorBound.inc"
#include "vsha/vsha_CreateTimer_BossTimer.inc"
#include "vsha/vsha_CreateTimer_WatchGameMode.inc"
#include "vsha/vsha_CreateTimer_MusicPlay.inc"
#include "vsha/vsha_CreateTimer_TimerBossResponse.inc"
//#include "vsha/"
//#include "vsha/"


#include "vsha/vsha_CreateDataTimer_TimerMusicTheme.inc"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"

#include "vsha/vsha_HookEvent_RoundStart.inc"
#include "vsha/vsha_HookEvent_RoundEnd.inc"
#include "vsha/vsha_HookEvent_PlayerSpawn.inc"
#include "vsha/vsha_HookEvent_UberDeployed.inc"
#include "vsha/vsha_HookEvent_JumpHook.inc"
#include "vsha/vsha_HookEvent_PlayerDeath.inc"
#include "vsha/vsha_HookEvent_PlayerHurt.inc"
#include "vsha/vsha_HookEvent_Destroyed.inc"
#include "vsha/vsha_HookEvent_Deflected.inc"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"

//#include "vsha/"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"
#include "vsha/vsha_TF2Items_OnGiveNamedItem.inc"

// may or may not use in future
//#include "vsha/vsha_Events.inc"

#include "vsha/vsha_misc_functions.inc"
#include "vsha/vsha_UnUsed_Functions.inc"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"

//#include "vsha/"
//#include "vsha/"
//#include "vsha/"

public Handle PickBossSpecial(int &select)
{
	int pick = -1;
	if (select == -1) pick = GetRandomInt( 0, hArrayBossSubplugins.Length-1 ); //GetArraySize(hArrayBossSubplugins)-1 );
	else
	{
		pick = select;
		select = -1;
	}
	//Storage[client] = GetBossSubPlugin(hArrayBossSubplugins.Get(pick)); //GetArrayCell(hArrayBossSubplugins, iBoss[client]));

	return ( GetBossSubPlugin(hArrayBossSubplugins.Get(pick)) );
}

public void SearchForItemPacks()
{
	//bool foundAmmo = false, foundHealth = false;
	int ent = -1;
	//float pos[3];
	/*while ((ent = FindEntityByClassname2(ent, "item_ammopack_full")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
		if (Enabled)
		{
			GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
			AcceptEntityInput(ent, "Kill");
			int ent2 = CreateEntityByName("item_ammopack_small");
			DispatchSpawn(ent2);
			TeleportEntity(ent2, pos, nullvec, nullvec);
			SetEntProp(ent2, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
			//foundAmmo = true;
		}
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "item_ammopack_medium")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
		if (Enabled)
		{
			GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
			AcceptEntityInput(ent, "Kill");
			int ent2 = CreateEntityByName("item_ammopack_small");
			TeleportEntity(ent2, pos, nullvec, nullvec);
			DispatchSpawn(ent2);
			SetEntProp(ent2, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
		}
		//foundAmmo = true;
	}
	ent = -1;*/
	while ((ent = FindEntityByClassname2(ent, "item_ammopack_small")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
		//foundAmmo = true;
	}

	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "item_healthkit_small")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
		//foundHealth = true;
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "item_healthkit_medium")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
		//foundHealth = true;
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "item_healthkit_large")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
		//foundHealth = true;
	}
//#if defined DEBUG
//	DEBUGPRINT1("VSH Engine::SearchForItemPacks() **** item kits are set! ****");
//#endif
}

public void LoadSubPlugins() //"stolen" from ff2 lol
{
	char path[PATHX], filename[PATHX];
	BuildPath(Path_SM, path, PATHX, "plugins/");
	FileType filetype;
	DirectoryListing directory = OpenDirectory(path);
	//while ( ReadDirEntry(directory, filename, PATHX, filetype) )
	while ( directory.GetNext(filename, PATHX, filetype) )
	{
		if ( filetype == FileType_File && StrContains(filename, ".smx", false) != -1 )
		{
			ServerCommand("sm plugins load %s", filename);
		}
	}
#if defined DEBUG
	DEBUGPRINT1("VSH Engine::LoadSubPlugins() **** LoadSubPlugins() Called ****");
#endif
}

public int GetFirstBossIndex() //purpose is for the Storage client Handle
{
	int i = 0;
	for ( i = 1; i <= MaxClients; i++ )
	{
		if ( IsClientValid(i) && bIsBoss[i] ) return i;
	}
	return -1;
}

public int FindNextBoss(bool[] array) //why force specs to Boss? They're prob AFK...
{
	int inBoss = -1;
	//LoopIngameClients(i) // no bots for now
	LoopIngamePlayers(i)
	{
		if ( IsValidClient(i) )
		{
			if ( IsOnBlueOrRedTeam(i) )
			{
				if (GetClientQueuePoints(i) >= GetClientQueuePoints(inBoss))
				{
					if( !array[i] )
					{
						inBoss = i;
					}
				}
			 }
		 }
	}
	return inBoss;
}

public Action VSHA_Private_Forward(const char[] EventString)
{
	if(InternalPause) return Plugin_Continue;

	Handle TempStorage[PLYR];
	int TmpNum = 0;
	bool found = false;
	int iTmp;
	Action result = Plugin_Continue;

	// Loop thru all active boss sub plugins
	LoopActiveBosses(BossID)
	{
		// Make sure we don't call the same boss twice
		found = false;
		for ( iTmp = 0; iTmp < PLYR; iTmp++ )
		{
			if(Storage[BossID] == Storage[TempStorage[iTmp]])
			{
				found = true;
				break;
			}
		}
		if(found)
		{
			continue;
		}

		TempStorage[TmpNum] = Storage[BossID];
		TmpNum++;

		if(Storage[BossID] != null)
		{
			Function FuncBossKillToy = GetFunctionByName(Storage[BossID], EventString);
			if (FuncBossKillToy != nullfunc)
			{
				Call_StartFunction(Storage[BossID], FuncBossKillToy);
				Call_Finish(result);
			}
		}
	}
	return result;
}

public Action VSHA_Registered_Global_Forward(const char[] EventString)
{
	if(InternalPause) return Plugin_Continue;

	Action result = Plugin_Continue;

	if(hArrayNonBossSubplugins != null)
	{
		int count = hArrayNonBossSubplugins.Length; //GetArraySize(hMyArray);
		Handle MyPlugin = null;
		Function FuncRegisteredGlobal = nullfunc;
		for (int i = 0; i < count; i++)
		{
			MyPlugin = hArrayNonBossSubplugins.Get(i);

			if(MyPlugin != null)
			{
				FuncRegisteredGlobal = GetFunctionByName(MyPlugin, EventString);
				if (FuncRegisteredGlobal != nullfunc)
				{
					Call_StartFunction(MyPlugin, FuncRegisteredGlobal);
					Call_Finish(result);
					if(result == Plugin_Stop) break;
				}
			}
		}
	}

	return result;
}
//===================================================================================================================================

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////// N A T I V E S  &  F O R W A R D S //////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// Special Graphics for loading screen
	PrintToServer("");
	PrintToServer("");
	PrintToServer(" #     #  #####  #     #    #    ");
	PrintToServer(" #     # #     # #     #   # #   ");
	PrintToServer(" #     # #       #     #  #   #  ");
	PrintToServer(" #     #  #####  ####### #     # ");
	PrintToServer("  #   #        # #     # ####### ");
	PrintToServer("   # #   #     # #     # #     # ");
	PrintToServer("    #     #####  #     # #     # ");
	PrintToServer("");
	PrintToServer("");

	// F O R W A R D S ==============================================================================================
	AddToDownloads = CreateGlobalForward("VSHA_AddToDownloads", ET_Ignore);
	//===========================================================================================================================

	// N A T I V E S ============================================================================================================
	CreateNative("VSHA_LoadConfiguration", Native_LoadConfigurationSubplugin);

	CreateNative("VSHA_RegisterNonBossAddon", Native_RegisterNonBossAddon);
	CreateNative("VSHA_UnRegisterNonBossAddon", Native_UnRegisterNonBossAddon);

	CreateNative("VSHA_RegisterBoss", Native_RegisterBossSubplugin);

	CreateNative("VSHA_GetBossUserID", Native_GetBossUserID);
	CreateNative("VSHA_SetBossUserID", Native_SetBossUserID);

	CreateNative("VSHA_GetDifficulty", Native_GetDifficulty);
	CreateNative("VSHA_SetDifficulty", Native_SetDifficulty);

	CreateNative("VSHA_GetLives", Native_GetLives);
	CreateNative("VSHA_SetLives", Native_SetLives);

	CreateNative("VSHA_GetPresetBoss", Native_GetPresetBoss);
	CreateNative("VSHA_SetPresetBoss", Native_SetPresetBoss);

	CreateNative("VSHA_GetBossHealth", Native_GetBossHealth);
	CreateNative("VSHA_SetBossHealth", Native_SetBossHealth);

	CreateNative("VSHA_GetBossMaxHealth", Native_GetBossMaxHealth);
	CreateNative("VSHA_SetBossMaxHealth", Native_SetBossMaxHealth);

	CreateNative("VSHA_GetBossPlayerKills", Native_GetBossPlayerKills);
	CreateNative("VSHA_SetBossPlayerKills", Native_SetBossPlayerKills);

	CreateNative("VSHA_GetBossKillstreak", Native_GetBossKillstreak);
	CreateNative("VSHA_SetBossKillstreak", Native_SetBossKillstreak);

	CreateNative("VSHA_GetPlayerBossKills", Native_GetPlayerBossKills);
	CreateNative("VSHA_SetPlayerBossKills", Native_SetPlayerBossKills);

	CreateNative("VSHA_GetDamage", Native_GetDamage);
	CreateNative("VSHA_SetDamage", Native_SetDamage);

	CreateNative("VSHA_GetBossMarkets", Native_GetBossMarkets);
	CreateNative("VSHA_SetBossMarkets", Native_SetBossMarkets);

	CreateNative("VSHA_GetBossStabs", Native_GetBossStabs);
	CreateNative("VSHA_SetBossStabs", Native_SetBossStabs);

	CreateNative("VSHA_GetHits", Native_GetHits);
	CreateNative("VSHA_SetHits", Native_SetHits);

	CreateNative("VSHA_GetMaxWepAmmo", Native_GetMaxWepAmmo);
	CreateNative("VSHA_SetMaxWepAmmo", Native_SetMaxWepAmmo);

	CreateNative("VSHA_GetMaxWepClip", Native_GetMaxWepClip);
	CreateNative("VSHA_SetMaxWepClip", Native_SetMaxWepClip);

	CreateNative("VSHA_GetPresetBossPlayer", Native_GetPresetBossPlayer);
	CreateNative("VSHA_SetPresetBossPlayer", Native_SetPresetBossPlayer);

	CreateNative("VSHA_GetAliveRedPlayers", Native_GetAliveRedPlayers);
	CreateNative("VSHA_GetAliveBluPlayers", Native_GetAliveBluePlayers);

	CreateNative("VSHA_GetBossRage", Native_GetBossRage);
	CreateNative("VSHA_SetBossRage", Native_SetBossRage);

	CreateNative("VSHA_GetGlowTimer", Native_GetGlowTimer);
	CreateNative("VSHA_SetGlowTimer", Native_SetGlowTimer);

	CreateNative("VSHA_IsBossPlayer", Native_IsBossPlayer);
	CreateNative("VSHA_SetIsBossPlayer", Native_SetIsBossPlayer);

	CreateNative("VSHA_IsPlayerInJump", Native_IsPlayerInJump);
	CreateNative("VSHA_CanBossTaunt", Native_CanBossTaunt);

	CreateNative("VSHA_FindNextBoss", Native_FindNextBoss);

	CreateNative("VSHA_CountScoutsLeft", Native_CountScoutsLeft);

	CreateNative("VSHA_GetPlayerCount", Native_GetPlayerCount);

	CreateNative("VSHA_GetVar",Native_VSHA_GetVar);
	CreateNative("VSHA_SetVar",Native_VSHA_SetVar);

	CreateNative("VSHA_CallModelTimer",Native_CallModelTimer);

	// may use in future.. depends
	//vsha_Events_AskPluginLoad2();

	//===========================================================================================================================

	RegPluginLibrary("vsha");
#if defined _steamtools_included
	MarkNativeAsOptional("Steam_SetGameDescription");
#endif
	return APLRes_Success;
}

public int Native_LoadConfigurationSubplugin(Handle plugin, int numParams)
{
	char cFileName[64];
	GetNativeString(1, STRING(cFileName));
	return VSHA_Load_Configuration(plugin, cFileName);
}


public int Native_RegisterNonBossAddon(Handle plugin, int numParams)
{
	Handle BossHandle = RegisterNonBossAddon( plugin );
	return view_as<int>( BossHandle );
}
public int Native_UnRegisterNonBossAddon(Handle plugin, int numParams)
{
	UnRegisterNonBossAddon( plugin );
	return 0;
}

public int Native_RegisterBossSubplugin(Handle plugin, int numParams)
{
	char ShortBossSubPluginName[16];
	GetNativeString(1, ShortBossSubPluginName, sizeof(ShortBossSubPluginName));
	char BossSubPluginName[32];
	GetNativeString(2, BossSubPluginName, sizeof(BossSubPluginName));
	VSHAError erroar;
	Handle BossHandle = RegisterBoss( plugin, ShortBossSubPluginName, BossSubPluginName, erroar ); //ALL PROPS TO COOKIES.NET AKA COOKIES.IO
	return view_as<int>( BossHandle );
}

public int Native_GetBossUserID(Handle plugin, int numParams)
{
	return iBossUserID[GetNativeCell(1)];
}
public int Native_SetBossUserID(Handle plugin, int numParams)
{
	iBossUserID[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetDifficulty(Handle plugin, int numParams)
{
	return iDifficulty[GetNativeCell(1)];
}
public int Native_SetDifficulty(Handle plugin, int numParams)
{
	iDifficulty[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetLives(Handle plugin, int numParams)
{
	return iLives[GetNativeCell(1)];
}
public int Native_SetLives(Handle plugin, int numParams)
{
	iLives[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetPresetBoss(Handle plugin, int numParams)
{
	return iPresetBoss[GetNativeCell(1)];
}
public int Native_SetPresetBoss(Handle plugin, int numParams)
{
	iPresetBoss[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetBossHealth(Handle plugin, int numParams)
{
	return iBossHealth[GetNativeCell(1)];
}
public int Native_SetBossHealth(Handle plugin, int numParams)
{
	iBossHealth[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetBossMaxHealth(Handle plugin, int numParams)
{
	return iBossMaxHealth[GetNativeCell(1)];
}
public int Native_SetBossMaxHealth(Handle plugin, int numParams)
{
	iBossMaxHealth[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetBossPlayerKills(Handle plugin, int numParams)
{
	return iPlayerKilled[GetNativeCell(1)][0];
}
public int Native_SetBossPlayerKills(Handle plugin, int numParams)
{
	iPlayerKilled[GetNativeCell(1)][0] = GetNativeCell(2);
	return 0;
}

public int Native_GetBossKillstreak(Handle plugin, int numParams)
{
	return iPlayerKilled[GetNativeCell(1)][1];
}
public int Native_SetBossKillstreak(Handle plugin, int numParams)
{
	iPlayerKilled[GetNativeCell(1)][1] = GetNativeCell(2);
	return 0;
}

public int Native_GetPlayerBossKills(Handle plugin, int numParams)
{
	return iBossesKilled[GetNativeCell(1)];
}
public int Native_SetPlayerBossKills(Handle plugin, int numParams)
{
	iBossesKilled[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetDamage(Handle plugin, int numParams)
{
	return iDamage[GetNativeCell(1)];
}
public int Native_SetDamage(Handle plugin, int numParams)
{
	iDamage[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetBossMarkets(Handle plugin, int numParams)
{
	return iMarketed[GetNativeCell(1)];
}
public int Native_SetBossMarkets(Handle plugin, int numParams)
{
	iMarketed[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetBossStabs(Handle plugin, int numParams)
{
	return iStabbed[GetNativeCell(1)];
}
public int Native_SetBossStabs(Handle plugin, int numParams)
{
	iStabbed[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetHits(Handle plugin, int numParams)
{
	return iHits[GetNativeCell(1)];
}
public int Native_SetHits(Handle plugin, int numParams)
{
	iHits[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetMaxWepAmmo(Handle plugin, int numParams)
{
	return AmmoTable[GetNativeCell(1)];
}
public int Native_SetMaxWepAmmo(Handle plugin, int numParams)
{
	AmmoTable[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetMaxWepClip(Handle plugin, int numParams)
{
	return ClipTable[GetNativeCell(1)];
}
public int Native_SetMaxWepClip(Handle plugin, int numParams)
{
	ClipTable[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetPresetBossPlayer(Handle plugin, int numParams)
{
	return iNextBossPlayer;
}
public int Native_SetPresetBossPlayer(Handle plugin, int numParams)
{
	iNextBossPlayer = GetNativeCell(1);
	return 0;
}

public int Native_GetAliveRedPlayers(Handle plugin, int numParams)
{
	return iRedAlivePlayers;
}
public int Native_GetAliveBluePlayers(Handle plugin, int numParams)
{
	return iBluAlivePlayers;
}

public int Native_GetBossRage(Handle plugin, int numParams)
{
	return view_as<int>(flCharge[GetNativeCell(1)]);
}
public int Native_SetBossRage(Handle plugin, int numParams)
{
	flCharge[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetGlowTimer(Handle plugin, int numParams)
{
	return view_as<int>(flGlowTimer[GetNativeCell(1)]);
}
public int Native_SetGlowTimer(Handle plugin, int numParams)
{
	flGlowTimer[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_IsBossPlayer(Handle plugin, int numParams)
{
	return view_as<int>(bIsBoss[GetNativeCell(1)]);
}
public int Native_SetIsBossPlayer(Handle plugin, int numParams)
{
	bIsBoss[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_IsPlayerInJump(Handle plugin, int numParams)
{
	return bInJump[GetNativeCell(1)];
}
public int Native_CanBossTaunt(Handle plugin, int numParams)
{
	return bNoTaunt[GetNativeCell(1)];
}

public int Native_FindNextBoss(Handle plugin, int numParams)
{
	int size = GetNativeCell(2);
	if (size < 1)
	{
		LogError("VSH Engine::Native_FindNextBoss() **** Invalid Array Size (size = %i) ****", size);
		return -1;
	}
	bool[] array = new bool[size]; GetNativeArray(1, array, size);
	return FindNextBoss(array);
}

public int Native_CountScoutsLeft(Handle plugin, int numParams)
{
	return CountScoutsLeft();
}

public int Native_GetPlayerCount(Handle plugin, int numParams)
{
	return iPlaying;
}

public int FindByBossSubPluginByID(Handle plugin)
{
	int count = hArrayBossSubplugins.Length; //GetArraySize(hArrayBossSubplugins);
	for (int i = 0; i < count; i++)
	{
		StringMap MyStringMap = hArrayBossSubplugins.Get(i);
		if (GetBossSubPlugin(MyStringMap) == plugin) return i;
	}
	return -1;
}
public Handle FindByBossSubPlugin(Handle plugin)
{
	int count = hArrayBossSubplugins.Length; //GetArraySize(hMyArray);
	for (int i = 0; i < count; i++)
	{
		StringMap MyStringMap = hArrayBossSubplugins.Get(i);
		if (GetBossSubPlugin(MyStringMap) == plugin) return MyStringMap;
	}
	return null;
}
public Handle FindByNonBossSubPlugin(Handle plugin)
{
	int count = hArrayNonBossSubplugins.Length; //GetArraySize(hMyArray);
	Handle MyPlugin = null;
	for (int i = 0; i < count; i++)
	{
		MyPlugin = hArrayNonBossSubplugins.Get(i);
		if (MyPlugin == plugin) return MyPlugin;
	}
	return null;
}
public int FindByNonBossSubPluginByID(Handle plugin)
{
	for (int i = 0; i < hArrayNonBossSubplugins.Length; i++)
	{
		if (hArrayNonBossSubplugins.Get(i) == plugin) return i;
	}
	return -1;
}
public Handle FindBossName(const char[] name)
{
	Handle GotBossName;
	if ( GetTrieValueCaseInsensitive(hTrieBossSubplugins, name, GotBossName) ) return GotBossName;
	return null;
}
public Handle RegisterNonBossAddon(Handle pluginhndl)
{
	Handle MyPluginHandle = FindByNonBossSubPlugin(pluginhndl);

	if (MyPluginHandle != null)
	{
		LogError("**** RegisterNonBossAddon - Non-Boss Subplugin Already Registered / Returned current handle ****");
		return MyPluginHandle;
	}

	hArrayNonBossSubplugins.Push(pluginhndl);

	return pluginhndl;
}
public void UnRegisterNonBossAddon(Handle pluginhndl)
{
	int iPlugin = FindByNonBossSubPluginByID(pluginhndl);

	if (iPlugin == -1)
	{
		LogError("**** UnRegisterNonBossAddon - Unable to unregister ****");
		return;
	}

	hArrayNonBossSubplugins.Erase(iPlugin);
}
public Handle RegisterBoss(Handle pluginhndl, const char shortname[16], const char longname[32], VSHAError &error)
{
	if (!ValidateName(shortname))
	{
		LogError("**** RegisterBoss - Invalid Name ****");
		error = Error_InvalidName;
		return null;
	}
	if (FindByBossSubPlugin(pluginhndl) != null)
	{
		LogError("**** RegisterBoss - Boss Subplugin Already Registered ****");
		error = Error_SubpluginAlreadyRegistered;
		return null;
	}
	if (FindBossName(shortname) != null)
	{
		LogError("**** RegisterBoss - Boss Name Already Exists ****");
		error = Error_AlreadyExists;
		return null;
	}
	// Create the trie to hold the data about the boss
	StringMap BossSubplug = new StringMap(); //CreateTrie();
#if defined DEBUG
	if (BossSubplug == null) DEBUGPRINT1("VSH Engine::RegisterBoss() **** BossSubplug StringMap Trie is Null ****");
#endif
	BossSubplug.SetValue("Subplugin", pluginhndl); //SetTrieValue(BossSubplug, "Subplugin", pluginhndl);
	BossSubplug.SetString("BossShortName", shortname); //SetTrieString(BossSubplug, "BossName", name);
	BossSubplug.SetString("BossLongName", longname);

	// Then push it to the global array and trie
	// Don't forget to convert the string to lower cases!
	hArrayBossSubplugins.Push(BossSubplug); //PushArrayCell(hArrayBossSubplugins, BossSubplug);
	SetTrieValueCaseInsensitive(hTrieBossSubplugins, shortname, BossSubplug);

	bool pluginupdated = false;

	InternalPause = false;

	if(StrEqual(ReloadBossShortName,shortname))
	{
		LoopMaxPLYR(plyrBoss)
		{
			if(ReloadPlayer[plyrBoss])
			{
				pluginupdated = true;
				ReloadPlayer[plyrBoss] = false;
				if(ValidPlayer(plyrBoss,true))
				{
					Storage[plyrBoss] = pluginhndl;

					INTERNAL_VSHA_OnBossSelected(Storage[plyrBoss], plyrBoss);

					CreateTimer(0.2, MakeModelTimer, GetClientUserId(plyrBoss));
				}
			}
		}
	}

	if(pluginupdated)
	{
		PrintToChatAll("%s updated.",longname);
	}

	error = Error_None;
	return pluginhndl;
}


public int Native_VSHA_GetVar(Handle plugin, int numParams)
{
	return view_as<int>(VSHA_VarArr[GetNativeCell(1)]);
}
public int Native_VSHA_SetVar(Handle plugin, int numParams)
{
	VSHA_VarArr[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_CallModelTimer(Handle plugin, int numParams)
{
	float time = view_as<float>(GetNativeCell(1));
	int userid = GetNativeCell(2);

	CreateTimer(time, MakeModelTimer, userid);
	return 0;
}

// Global Forwards

public void INTERNAL_VSHA_OnBossIntroTalk(Handle hThisBoss)
{
	Call_StartForward(p_OnBossIntroTalk);
	Call_PushCell(hThisBoss);
	Call_Finish();
}

public void INTERNAL_VSHA_AddToDownloads()
{
	Call_StartForward(p_AddToDownloads);
	Call_Finish();
}

public void INTERNAL_VSHA_OnPlayerKilledByBoss(int iiBoss, int attacker)
{
	Call_StartForward(p_OnPlayerKilledByBoss);
	Call_PushCell(iiBoss);
	Call_PushCell(attacker);
	Call_Finish();
}

public void INTERNAL_VSHA_OnKillingSpreeByBoss(int iiBoss, int attacker)
{
	Call_StartForward(p_OnKillingSpreeByBoss);
	Call_PushCell(iiBoss);
	Call_PushCell(attacker);
	Call_Finish();
}

public void INTERNAL_VSHA_OnBossKilled(int iiBoss, int attacker)
{
	Call_StartForward(p_OnBossKilled);
	Call_PushCell(iiBoss);
	Call_PushCell(attacker);
	Call_Finish();
}

public void INTERNAL_VSHA_OnBossWin(Event event, int iiBoss)
{
	Call_StartForward(p_OnBossWin);
	Call_PushCell(event);
	Call_PushCell(iiBoss);
	Call_Finish();
}

public void INTERNAL_VSHA_OnBossKillBuilding(Event event, int iiBoss)
{
	Call_StartForward(p_OnBossKillBuilding);
	Call_PushCell(event);
	Call_PushCell(iiBoss);
	Call_Finish();
}

public void INTERNAL_VSHA_OnMessageTimer()
{
	Call_StartForward(p_OnMessageTimer);
	Call_Finish();
}

public void INTERNAL_VSHA_OnBossAirblasted(Event event, int attacker)
{
	Call_StartForward(p_OnBossAirblasted);
	Call_PushCell(event);
	Call_PushCell(attacker);
	Call_Finish();
}

public void INTERNAL_VSHA_OnBossSelected(Handle hThisBoss, int iiBoss)
{
	Call_StartForward(p_OnBossSelected);
	Call_PushCell(hThisBoss);
	Call_PushCell(iiBoss);
	Call_Finish();
}

public Action INTERNAL_VSHA_OnBossSetHP(int BossEntity, int &BossMaxHealth)
{
	Action result = Plugin_Continue;
	Call_StartForward(p_OnBossSetHP);
	Call_PushCell(BossEntity);
	Call_PushCellRef(BossMaxHealth);
	Call_Finish(result);
	return result;
}

public void INTERNAL_VSHA_OnLastSurvivor()
{
	Call_StartForward(p_OnLastSurvivor);
	Call_Finish();
}

public void INTERNAL_VSHA_OnBossTimer (int iiBoss)
{
	Call_StartForward(p_OnBossTimer);
	Call_PushCell(iiBoss);
	Call_PushCellRef(iBossHealth[iiBoss]);
	Call_PushCellRef(iBossMaxHealth[iiBoss]);
	Call_Finish();
}

public void INTERNAL_VSHA_OnPrepBoss(int iiBoss)
{
	Call_StartForward(p_OnPrepBoss);
	Call_PushCell(iiBoss);
	Call_Finish();
}

public Action INTERNAL_VSHA_OnMusic(Handle hPluginHndl, char BossTheme[PATHX], float &time)
{
	Action result = Plugin_Continue;
	Call_StartForward(p_OnMusic);
	Call_PushCell(hPluginHndl);
	Call_PushStringEx(STRING(BossTheme),0, SM_PARAM_COPYBACK);
	Call_PushFloatRef(time);
	Call_Finish(result);
	return result;
}

public Action INTERNAL_VSHA_OnModelTimer(int iClient, char modelpath[PATHX])
{
	Action result = Plugin_Continue;
	Call_StartForward(p_OnModelTimer);
	Call_PushCell(iClient);
	Call_PushStringEx(STRING(modelpath),0, SM_PARAM_COPYBACK);
	Call_Finish(result);
	return result;
}

public void INTERNAL_VSHA_OnBossRage(int iiBoss)
{
	Call_StartForward(p_OnBossRage);
	Call_PushCell(iiBoss);
	Call_Finish();
}

public void INTERNAL_VSHA_OnConfiguration_Load_Sounds(char[] cfile, char[] skey, char[] value, bool &bPreCacheFile, bool &bAddFileToDownloadsTable)
{
	Call_StartForward(p_OnConfiguration_Load_Sounds);
	Call_PushString(cfile);
	Call_PushString(skey);
	Call_PushString(value);
	Call_PushCellRef(bPreCacheFile);
	Call_PushCellRef(bAddFileToDownloadsTable);
	Call_Finish();
}

public void INTERNAL_VSHA_OnConfiguration_Load_Materials(char[] cfile, char[] skey, char[] value, bool &bPreCacheFile, bool &bAddFileToDownloadsTable)
{
	Call_StartForward(p_OnConfiguration_Load_Materials);
	Call_PushString(cfile);
	Call_PushString(skey);
	Call_PushString(value);
	Call_PushCellRef(bPreCacheFile);
	Call_PushCellRef(bAddFileToDownloadsTable);
	Call_Finish();
}

public void INTERNAL_VSHA_OnConfiguration_Load_Models(char[] cfile, char[] skey, char[] value, bool &bPreCacheFile, bool &bAddFileToDownloadsTable)
{
	Call_StartForward(p_OnConfiguration_Load_Models);
	Call_PushString(cfile);
	Call_PushString(skey);
	Call_PushString(value);
	Call_PushCellRef(bPreCacheFile);
	Call_PushCellRef(bAddFileToDownloadsTable);
	Call_Finish();
}

public void INTERNAL_VSHA_OnConfiguration_Load_Misc(char[] cfile, char[] skey, char[] value)
{
	Call_StartForward(p_OnConfiguration_Load_Misc);
	Call_PushString(cfile);
	Call_PushString(skey);
	Call_PushString(value);
	Call_Finish();
}

public Action INTERNAL_VSHA_OnEquipPlayer_Pre(int iEntity)
{
	Action result = Plugin_Continue;
	Call_StartForward(p_OnEquipPlayer_Pre);
	Call_PushCell(iEntity);
	Call_Finish(result);
	return result;
}

public void INTERNAL_VSHA_ShowPlayerHelpMenu(int iEntity)
{
	Call_StartForward(p_ShowPlayerHelpMenu);
	Call_PushCell(iEntity);
	Call_Finish();
}

public void INTERNAL_VSHA_OnEquipPlayer_Post(int iEntity)
{
	Call_StartForward(p_OnEquipPlayer_Post);
	Call_PushCell(iEntity);
	Call_Finish();
}

public void INTERNAL_VSHA_ShowBossHelpMenu(int iEntity)
{
	Call_StartForward(p_ShowBossHelpMenu);
	Call_PushCell(iEntity);
	Call_Finish();
}

public void INTERNAL_VSHA_OnUberTimer(int iMedic, int iTarget)
{
	Call_StartForward(p_OnUberTimer);
	Call_PushCell(iMedic);
	Call_PushCell(iTarget);
	Call_Finish();
}

public void INTERNAL_VSHA_OnLastSurvivorLoop(int iEntity)
{
	Call_StartForward(p_OnLastSurvivorLoop);
	Call_PushCell(iEntity);
	Call_Finish();
}
