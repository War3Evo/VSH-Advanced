#undef REQUIRE_EXTENSIONS
#tryinclude <steamtools>
#define REQUIRE_EXTENSIONS

//#include <sourcemod>
#include <clientprefs>
#include <tf2attributes>
#include <morecolors>
#include <sdkhooks>
#include <vsha>

#define PLUGIN_VERSION			"1.0"

public Plugin myinfo = {
	name = "Versus Saxton Hale Engine",
	author = "Diablo, Nergal, Chdata, Cookies, with special props to Powerlord + Flamin' Sarge",
	description = "Es Sexy-time beyechez",
	version = PLUGIN_VERSION,
	url = "https://github.com/War3Evo/VSH-Advanced"
};

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
//#include "vsha/"
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
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"

#include "vsha/vsha_CacheDownloads.inc"
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

#include "vsha/vsha_OnWeaponSpawned.inc"
#include "vsha/vsha_PlayerHUD.inc"
#include "vsha/vsha_BossHUD.inc"
#include "vsha/vsha_UpdateHealthBar.inc"
//#include "vsha/"
//#include "vsha/"

#include "vsha/vsha_PawnTimer_MakeModelTimer.inc"
#include "vsha/vsha_PawnTimer_BossStart.inc"
#include "vsha/vsha_PawnTimer_InitBoss.inc"
#include "vsha/vsha_PawnTimer_BossResponse.inc"
#include "vsha/vsha_PawnTimer_DoMessage.inc"
#include "vsha/vsha_PawnTimer_CheckAlivePlayers.inc"
#include "vsha/vsha_PawnTimer_MakeBoss.inc"
#include "vsha/vsha_PawnTimer_EquipPlayers.inc"
#include "vsha/vsha_PawnTimer_CalcScores.inc"
#include "vsha/vsha_PawnTimer_MusicPlay.inc"
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
#include "vsha/vsha_CreateTimer_ClientTimer.inc"
#include "vsha/vsha_CreateTimer_Timer_Uber.inc"
#include "vsha/vsha_CreateTimer_Timer_RemoveHonorBound.inc"
#include "vsha/vsha_CreateTimer_BossTimer.inc"
//#include "vsha/"
//#include "vsha/"
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

#include "vsha/vsha_RegConsoleCmd.inc"
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
	for (int i = 1; i <= MaxClients; i++)
	{
		if ( IsValidClient(i) && GetClientTeam(i) > view_as<int>(TFTeam_Spectator) && GetClientQueuePoints(i) >= GetClientQueuePoints(inBoss) && !array[i] ) inBoss = i;
	}
	return inBoss;
}

public Action VSHA_Private_Forward(const char[] EventString)
{
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

		Function FuncBossKillToy = GetFunctionByName(Storage[BossID], EventString);
		if (FuncBossKillToy != nullfunc)
		{
			Call_StartFunction(Storage[BossID], FuncBossKillToy);
			Call_Finish(result);
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
	CreateNative("VSHA_RegisterBoss", Native_RegisterBossSubplugin);
	CreateNative("VSHA_UnRegisterBoss", Native_UnRegisterBossSubplugin);

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

	// may use in future.. depends
	//vsha_Events_AskPluginLoad2();

	//===========================================================================================================================

	RegPluginLibrary("vsha");
#if defined _steamtools_included
	MarkNativeAsOptional("Steam_SetGameDescription");
#endif
	return APLRes_Success;
}

public int Native_RegisterBossSubplugin(Handle plugin, int numParams)
{
	char BossSubPluginName[32];
	GetNativeString(1, BossSubPluginName, sizeof(BossSubPluginName));
	VSHAError erroar;
	Handle BossHandle = RegisterBoss( plugin, BossSubPluginName, erroar ); //ALL PROPS TO COOKIES.NET AKA COOKIES.IO
	return view_as<int>( BossHandle );
}
public int Native_UnRegisterBossSubplugin(Handle plugin, int numParams)
{
	char BossSubPluginName[32];
	GetNativeString(1, BossSubPluginName, sizeof(BossSubPluginName));
	UnRegisterBoss( plugin, BossSubPluginName );
	return 0;
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
public int FindBossBySubPluginByID(Handle plugin)
{
	int count = hArrayBossSubplugins.Length; //GetArraySize(hArrayBossSubplugins);
	for (int i = 0; i < count; i++)
	{
		StringMap bossub = hArrayBossSubplugins.Get(i);
		if (GetBossSubPlugin(bossub) == plugin) return i;
	}
	return -1;
}
public Handle FindBossBySubPlugin(Handle plugin)
{
	int count = hArrayBossSubplugins.Length; //GetArraySize(hArrayBossSubplugins);
	for (int i = 0; i < count; i++)
	{
		StringMap bossub = hArrayBossSubplugins.Get(i);
		if (GetBossSubPlugin(bossub) == plugin) return bossub;
	}
	return null;
}
public Handle FindBossName(const char[] name)
{
	Handle GotBossName;
	if ( GetTrieValueCaseInsensitive(hTrieBossSubplugins, name, GotBossName) ) return GotBossName;
	return null;
}
public Handle RegisterBoss(Handle pluginhndl, const char[] name, VSHAError &error)
{
	if (!ValidateName(name))
	{
		LogError("**** RegisterBoss - Invalid Name ****");
		error = Error_InvalidName;
		return null;
	}
	if (FindBossBySubPlugin(pluginhndl) != null)
	{
		LogError("**** RegisterBoss - Boss Subplugin Already Registered ****");
		error = Error_SubpluginAlreadyRegistered;
		return null;
	}
	if (FindBossName(name) != null)
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
	BossSubplug.SetString("BossName", name); //SetTrieString(BossSubplug, "BossName", name);

	// Then push it to the global array and trie
	// Don't forget to convert the string to lower cases!
	hArrayBossSubplugins.Push(BossSubplug); //PushArrayCell(hArrayBossSubplugins, BossSubplug);
	SetTrieValueCaseInsensitive(hTrieBossSubplugins, name, BossSubplug);

	error = Error_None;
	return pluginhndl;
}

public void UnRegisterBoss(Handle pluginhndl, const char[] name)
{
	if (!ValidateName(name))
	{
		LogError("**** UnRegisterBoss - Invalid Name ****");
		return;
	}
	int BossID = FindBossBySubPluginByID(pluginhndl);
	if (BossID > -1 && FindBossName(name) != null)
	{
		// Create the trie to hold the data about the boss
		StringMap BossSubplug = new StringMap(); //CreateTrie();

		BossSubplug.SetValue("Subplugin", pluginhndl); //SetTrieValue(BossSubplug, "Subplugin", pluginhndl);
		BossSubplug.SetString("BossName", name); //SetTrieString(BossSubplug, "BossName", name);

		// Then push it to the global array and trie
		// Don't forget to convert the string to lower cases!
		hArrayBossSubplugins.Erase(BossID); //PushArrayCell(hArrayBossSubplugins, BossSubplug);
		RemoveFromTrie(hTrieBossSubplugins, name);
		return;
	}
	return;
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
