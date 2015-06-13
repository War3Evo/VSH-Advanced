// vsha-addon-ff2-subplugin-interface-engine.sp



#pragma semicolon 1

#include <sourcemod>
#include <morecolors>
#include <tf2_stocks>
#include <tf2items>
#include <adt_array>
#include <clientprefs>
#include <sdkhooks>

#undef REQUIRE_PLUGIN
//#tryinclude <goomba>
//#tryinclude <rtd>
#tryinclude <tf2attributes>
//#tryinclude <updater>
#define REQUIRE_PLUGIN

#include <vsha>
#include <vsha_stocks>
#include <vsha_ff2_interface>

#define MAJOR_REVISION "1"
#define MINOR_REVISION "10"
#define STABLE_REVISION "6"

#define PLUGIN_VERSION "1.0"

bool PluginsFound = false;

bool areSubPluginsEnabled = false;

ArrayList hArrayPluginList = null;

int FF2flags[PLYR+1];

Handle p_PreAbility;
Handle p_OnAbility;
Handle p_OnMusic;
Handle p_OnTriggerHurt;
Handle p_OnSpecialSelected;
Handle p_OnAddQueuePoints;
Handle p_OnLoadCharacterSet;
Handle p_OnLoseLife;
Handle p_OnAlivePlayersChanged;

Handle p_OnFF2_GetAbilityArgument;
Handle p_OnFF2_GetAbilityArgumentFloat;
Handle p_OnFF2_GetAbilityArgumentString;
Handle p_OnFF2_HasAbility;
Handle p_OnFF2_GetBossCharge;
Handle p_OnFF2_SetBossCharge;


public Plugin myinfo = {
	name = "VSHA - Freak Fortress 2",
	author = "Rainbolt Dash, FlaminSarge, Powerlord, the 50DKP team, El Diablo",
	description = "RUUUUNN!! COWAAAARRDSS!",
	version = PLUGIN_VERSION,
	url = ""
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	char plugin[PLATFORM_MAX_PATH];
	GetPluginFilename(myself, plugin, sizeof(plugin));
	if(!StrContains(plugin, "freaks/"))  //Prevent plugins/freaks/freak_fortress_2.ff2 from loading if it exists -.-
	{
		strcopy(error, err_max, "There is a duplicate copy of Freak Fortress 2 inside the /plugins/freaks folder.  Please remove it");
		//return APLRes_Failure;
	}

	CreateNative("FF2toVSHAHook", Native_Hook);
	CreateNative("FF2toVSHAHookEx", Native_HookEx);
	CreateNative("FF2toVSHAUnhook", Native_Unhook);
	CreateNative("FF2toVSHAUnhookEx", Native_UnhookEx);

	CreateNative("FF2_IsFF2Enabled", Native_IsEnabled);
	CreateNative("FF2_GetFF2Version", Native_FF2Version);
	CreateNative("FF2_GetBossUserId", Native_GetBoss);
	CreateNative("FF2_GetBossIndex", Native_GetIndex);
	CreateNative("FF2_GetBossTeam", Native_GetTeam);
	CreateNative("FF2_GetBossSpecial", Native_GetSpecial);
	CreateNative("FF2_GetBossHealth", Native_GetBossHealth);
	CreateNative("FF2_SetBossHealth", Native_SetBossHealth);
	CreateNative("FF2_GetBossMaxHealth", Native_GetBossMaxHealth);
	CreateNative("FF2_SetBossMaxHealth", Native_SetBossMaxHealth);
	CreateNative("FF2_GetBossLives", Native_GetBossLives);
	CreateNative("FF2_SetBossLives", Native_SetBossLives);
	CreateNative("FF2_GetBossMaxLives", Native_GetBossMaxLives);
	CreateNative("FF2_SetBossMaxLives", Native_SetBossMaxLives);
	CreateNative("FF2_GetBossCharge", Native_GetBossCharge);
	CreateNative("FF2_SetBossCharge", Native_SetBossCharge);
	CreateNative("FF2_GetBossRageDamage", Native_GetBossRageDamage);
	CreateNative("FF2_SetBossRageDamage", Native_SetBossRageDamage);
	CreateNative("FF2_GetClientDamage", Native_GetDamage);
	CreateNative("FF2_GetRoundState", Native_GetRoundState);
	CreateNative("FF2_GetSpecialKV", Native_GetSpecialKV);
	CreateNative("FF2_StopMusic", Native_StopMusic);
	CreateNative("FF2_GetRageDist", Native_GetRageDist);
	CreateNative("FF2_HasAbility", Native_HasAbility);
	CreateNative("FF2_DoAbility", Native_DoAbility);
	CreateNative("FF2_GetAbilityArgument", Native_GetAbilityArgument);
	CreateNative("FF2_GetAbilityArgumentFloat", Native_GetAbilityArgumentFloat);
	CreateNative("FF2_GetAbilityArgumentString", Native_GetAbilityArgumentString);
	CreateNative("FF2_RandomSound", Native_RandomSound);
	CreateNative("FF2_GetFF2flags", Native_GetFF2flags);
	CreateNative("FF2_SetFF2flags", Native_SetFF2flags);
	CreateNative("FF2_GetQueuePoints", Native_GetQueuePoints);
	CreateNative("FF2_SetQueuePoints", Native_SetQueuePoints);
	CreateNative("FF2_GetClientGlow", Native_GetClientGlow);
	CreateNative("FF2_SetClientGlow", Native_SetClientGlow);
	CreateNative("FF2_GetAlivePlayers", Native_GetAlivePlayers);  //TODO: Deprecated, remove in 2.0.0
	CreateNative("FF2_GetBossPlayers", Native_GetBossPlayers);  //TODO: Deprecated, remove in 2.0.0
	CreateNative("FF2_Debug", Native_Debug);


	//"FF2_PreAbility"
	p_PreAbility = CreateForward( ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell, Param_CellByRef);  //Boss, plugin name, ability name, slot, enabled

	//"FF2_OnAbility"
	p_OnAbility = CreateForward( ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell);  //Boss, plugin name, ability name, status

	//"FF2_OnMusic"
	p_OnMusic = CreateForward( ET_Hook, Param_String, Param_FloatByRef);

	//"FF2_OnTriggerHurt"
	p_OnTriggerHurt = CreateForward( ET_Hook, Param_Cell, Param_Cell, Param_FloatByRef);

	//"FF2_OnSpecialSelected"
	p_OnSpecialSelected = CreateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_String);  //Boss, character index, character name

	//"FF2_OnAddQueuePoints"
	p_OnAddQueuePoints = CreateForward( ET_Hook, Param_Array);

	//"FF2_OnLoadCharacterSet"
	p_OnLoadCharacterSet = CreateForward( ET_Hook, Param_CellByRef, Param_String);

	//"FF2_OnLoseLife"
	p_OnLoseLife = CreateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_Cell);  //Boss, lives left, max lives

	//"FF2_OnAlivePlayersChanged"
	p_OnAlivePlayersChanged = CreateForward( ET_Hook, Param_Cell, Param_Cell);  //Players, bosses


	p_OnFF2_GetAbilityArgument = CreateForward( ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell, Param_CellByRef);

	p_OnFF2_GetAbilityArgumentFloat = CreateForward( ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell, Param_FloatByRef);

	p_OnFF2_GetAbilityArgumentString = CreateForward( ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell, Param_String, Param_Cell);

	p_OnFF2_HasAbility = CreateForward( ET_Hook, Param_Cell, Param_String, Param_String, Param_CellByRef);

	p_OnFF2_GetBossCharge = CreateForward( ET_Hook, Param_Cell, Param_String, Param_FloatByRef);

	p_OnFF2_SetBossCharge = CreateForward( ET_Ignore, Param_Cell, Param_String, Param_Float);

	RegPluginLibrary("freak_fortress_2");

	//return APLRes_Success;
}

public void Load_VSHAHooks()
{
	/*
	if(!VSHAHookEx(VSHAHook_OnBossIntroTalk, OnBossIntroTalk))
	{
		LogError("Error loading VSHAHook_OnBossIntroTalk forwards for miku.");
	}
	if(!VSHAHookEx(VSHAHook_OnPlayerKilledByBoss, OnPlayerKilledByBoss))
	{
		LogError("Error loading VSHAHook_OnPlayerKilledByBoss forwards for miku.");
	}
	if(!VSHAHookEx(VSHAHook_OnKillingSpreeByBoss, OnKillingSpreeByBoss))
	{
		LogError("Error loading VSHAHook_OnKillingSpreeByBoss forwards for miku.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossKilled, OnBossKilled))
	{
		LogError("Error loading VSHAHook_OnBossKilled forwards for miku.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossWin, OnBossWin))
	{
		LogError("Error loading VSHAHook_OnBossWin forwards for miku.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossAirblasted, OnBossAirblasted))
	{
		LogError("Error loading VSHAHook_OnBossAirblasted forwards for miku.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossChangeClass, OnChangeClass))
	{
		LogError("Error loading VSHAHook_OnBossChangeClass forwards for miku.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossSetHP, OnBossSetHP))
	{
		LogError("Error loading VSHAHook_OnBossSetHP forwards for miku.");
	}
	if(!VSHAHookEx(VSHAHook_OnLastSurvivor, OnLastSurvivor))
	{
		LogError("Error loading VSHAHook_OnLastSurvivor forwards for miku.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossTimer, OnBossTimer))
	{
		LogError("Error loading VSHAHook_OnBossTimer forwards for miku.");
	}
	if(!VSHAHookEx(VSHAHook_OnPrepBoss, OnPrepBoss))
	{
		LogError("Error loading VSHAHook_OnPrepBoss forwards for miku.");
	}
	if(!VSHAHookEx(VSHAHook_OnMusic, OnMusic))
	{
		LogError("Error loading VSHAHook_OnMusic forwards for miku.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossRage, OnBossRage))
	{
		LogError("Error loading VSHAHook_OnBossRage forwards for miku.");
	}
	if(!VSHAHookEx(VSHAHook_ShowBossHelpMenu, OnShowBossHelpMenu))
	{
		LogError("Error loading VSHAHook_ShowBossHelpMenu forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossRage, OnBossRage))
	{
		LogError("Error loading VSHAHook_OnBossRage forwards for ff2.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossTimer, OnBossTimer))
	{
		LogError("Error loading VSHAHook_OnBossTimer forwards for ff2.");
	}
	if(!VSHAHookEx(VSHAHook_ShowBossHelpMenu, OnShowBossHelpMenu))
	{
		LogError("Error loading VSHAHook_ShowBossHelpMenu forwards for saxton hale.");
	}*/
}
public void OnAllPluginsLoaded()
{
	if(!VSHAHookEx(VSHAHook_AddToDownloads, OnAddToDownloads))
	{
		LogError("Error loading VSHAHook_AddToDownloads forwards for vsha-ff2.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossIntroTalk, OnBossIntroTalk))
	{
		LogError("Error loading VSHAHook_OnBossIntroTalk forwards for vsha-ff2.");
	}
}

public void OnPluginStart()
{
	hArrayPluginList = new ArrayList(ByteCountToCells(PATHX));
}

public void OnPluginEnd()
{
	DisableSubPlugins();
}

public void OnMapEnd()
{
	DisableSubPlugins();
}

public void OnBossIntroTalk()
{
//forward Action FF2_OnAlivePlayersChanged(int players, int bosses);

	int iBosscount = 0;
	int iPlayercount = 0;
	LoopAlivePlayers(target)
	{
		if(VSHA_IsBossPlayer(target))
		{
			iBosscount++;
		}
		else
		{
			iPlayercount++;
		}
	}

	Action result = Plugin_Continue;
	Call_StartForward(p_OnAlivePlayersChanged);
	Call_PushCell(iBosscount);
	Call_PushCell(iPlayercount);
	Call_Finish(result);
}

public void OnAddToDownloads()
{
	EnableSubPlugins();
}

stock void EnableSubPlugins(bool force=false)
{
	if(areSubPluginsEnabled && !force)
	{
		return;
	}

	areSubPluginsEnabled=true;
	char path[PLATFORM_MAX_PATH]; char filename[PLATFORM_MAX_PATH]; char filename_old[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, PLATFORM_MAX_PATH, "plugins/freaks");
	FileType filetype;
	Handle directory=OpenDirectory(path);
	while(ReadDirEntry(directory, filename, PLATFORM_MAX_PATH, filetype))
	{
		if(filetype==FileType_File && StrContains(filename, ".smx", false)!=-1)
		{
			Format(filename_old, PLATFORM_MAX_PATH, "%s/%s", path, filename);
			ReplaceString(filename, PLATFORM_MAX_PATH, ".smx", ".ff2", false);
			Format(filename, PLATFORM_MAX_PATH, "%s/%s", path, filename);
			DeleteFile(filename);
			RenameFile(filename, filename_old);
		}
	}

	StringMap PluginList = new StringMap(); //CreateTrie();

	int count = 0;
	//bool found = false;
	char sNumberedString[16];

	directory=OpenDirectory(path);
	while(ReadDirEntry(directory, filename, PLATFORM_MAX_PATH, filetype))
	{
		if(filetype==FileType_File && StrContains(filename, ".ff2", false)!=-1)
		{
			ServerCommand("sm plugins load freaks/%s", filename);
			Format(sNumberedString,16,"%d",count);
			PluginList.SetString(sNumberedString, filename);
			hArrayPluginList.Push(PluginList);
			count++;
		}
	}
	if(count>0)
	{
		PluginsFound = true;
	}
	else
	{
		PluginsFound = false;
	}

	//if(found)
	//{
		//ServerExecute();
	//}

	//LoadPluginForwards();
	CreateTimer(10.0, LoadPluginForwardsTimer, _);
}
public Action LoadPluginForwardsTimer(Handle timer, any data)
{
	LoadPluginForwards();
}
stock void DisableSubPlugins(bool force=false)
{
	if(!areSubPluginsEnabled && !force)
	{
		return;
	}

	char path[PLATFORM_MAX_PATH]; char filename[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, PLATFORM_MAX_PATH, "plugins/freaks");
	FileType filetype;
	Handle directory=OpenDirectory(path);
	while(ReadDirEntry(directory, filename, PLATFORM_MAX_PATH, filetype))
	{
		if(filetype==FileType_File && StrContains(filename, ".ff2", false)!=-1)
		{
			InsertServerCommand("sm plugins unload freaks/%s", filename);  //ServerCommand will not work when switching maps
		}
	}
	ServerExecute();
	areSubPluginsEnabled=false;
}
public void LoadPluginForwards()
{
	char sGetString[16];
	char sPluginNameString[PATHX];

	bool found = false;

	char cFilePath[PATHX];

	Handle PluginHandle;
	Function funcID;

	int count = hArrayPluginList.Length;

	PrintToServer("CREATING PRIVATE FOWARDS VSHA --> FF2");

	StringMap ArrayPluginList = null;

	for (int i = 0; i < count; i++)
	{
		ArrayPluginList = hArrayPluginList.Get(i);

		Format(sGetString,16,"%d",i);
		ArrayPluginList.GetString(sGetString, sPluginNameString, PATHX);

		Format(cFilePath,PATHX,"freaks/%s",sPluginNameString);

		PrintToServer("cFilePath %s",cFilePath);

		PluginHandle = FindPluginByFile(cFilePath);
		if(PluginHandle != null)
		{
			PrintToServer("Found %s plugin for hooking FF2 Functions!",sPluginNameString);
			funcID = GetFunctionByName(PluginHandle, "FF2_PreAbility");
			if(funcID != INVALID_FUNCTION)
			{
				found = true;
				PrintToServer("Found %s FF2_PreAbility FF2 Function!",sPluginNameString);
				// hook function
				if(AddToForward(p_PreAbility, PluginHandle, funcID))
				{
					PrintToServer("AddToForward SuccessFul!");
				}
			}
			funcID = GetFunctionByName(PluginHandle, "FF2_OnAbility");
			if(funcID != INVALID_FUNCTION)
			{
				found = true;
				PrintToServer("Found %s FF2_OnAbility FF2 Function!",sPluginNameString);
				// hook function
				if(AddToForward(p_OnAbility, PluginHandle, funcID))
				{
					PrintToServer("FF2_OnAbility AddToForward SuccessFul!");
				}
			}
			funcID = GetFunctionByName(PluginHandle, "FF2_OnMusic");
			if(funcID != INVALID_FUNCTION)
			{
				found = true;
				PrintToServer("Found %s FF2_OnMusic FF2 Function!",sPluginNameString);
				// hook function
				if(AddToForward(p_OnMusic, PluginHandle, funcID))
				{
					PrintToServer("FF2_OnMusic AddToForward SuccessFul!");
				}
			}
			funcID = GetFunctionByName(PluginHandle, "FF2_OnTriggerHurt");
			if(funcID != INVALID_FUNCTION)
			{
				found = true;
				PrintToServer("Found %s FF2_OnTriggerHurt FF2 Function!",sPluginNameString);
				// hook function
				if(AddToForward(p_OnTriggerHurt, PluginHandle, funcID))
				{
					PrintToServer("FF2_OnTriggerHurt AddToForward SuccessFul!");
				}
			}
			funcID = GetFunctionByName(PluginHandle, "FF2_OnSpecialSelected");
			if(funcID != INVALID_FUNCTION)
			{
				found = true;
				PrintToServer("Found %s FF2_OnSpecialSelected FF2 Function!",sPluginNameString);
				// hook function
				if(AddToForward(p_OnSpecialSelected, PluginHandle, funcID))
				{
					PrintToServer("FF2_OnSpecialSelected AddToForward SuccessFul!");
				}
			}
			funcID = GetFunctionByName(PluginHandle, "FF2_OnAddQueuePoints");
			if(funcID != INVALID_FUNCTION)
			{
				found = true;
				PrintToServer("Found %s FF2_OnAddQueuePoints FF2 Function!",sPluginNameString);
				// hook function
				if(AddToForward(p_OnAddQueuePoints, PluginHandle, funcID))
				{
					PrintToServer("FF2_OnAddQueuePoints AddToForward SuccessFul!");
				}
			}
			funcID = GetFunctionByName(PluginHandle, "FF2_OnLoadCharacterSet");
			if(funcID != INVALID_FUNCTION)
			{
				found = true;
				PrintToServer("Found %s FF2_OnLoadCharacterSet FF2 Function!",sPluginNameString);
				// hook function
				if(AddToForward(p_OnLoadCharacterSet, PluginHandle, funcID))
				{
					PrintToServer("FF2_OnLoadCharacterSet AddToForward SuccessFul!");
				}
			}
			funcID = GetFunctionByName(PluginHandle, "FF2_OnLoseLife");
			if(funcID != INVALID_FUNCTION)
			{
				found = true;
				PrintToServer("Found %s FF2_OnLoseLife FF2 Function!",sPluginNameString);
				// hook function
				if(AddToForward(p_OnLoseLife, PluginHandle, funcID))
				{
					PrintToServer("FF2_OnLoseLife AddToForward SuccessFul!");
				}
			}
			funcID = GetFunctionByName(PluginHandle, "FF2_OnAlivePlayersChanged");
			if(funcID != INVALID_FUNCTION)
			{
				found = true;
				PrintToServer("Found %s FF2_OnAlivePlayersChanged FF2 Function!",sPluginNameString);
				// hook function
				if(AddToForward(p_OnAlivePlayersChanged, PluginHandle, funcID))
				{
					PrintToServer("FF2_OnAlivePlayersChanged AddToForward SuccessFul!");
				}
			}
		}
	}
	if(found)
	{
		PrintToServer("FF2 FUNCTIONS FOUND!");
	}
	else
	{
		PrintToServer("FF2 FUNCTIONS F A I L!");
	}
}

//===============================================================================================================================

//=================================================== [ N A T I V E S ] =========================================================


public int Native_IsEnabled(Handle plugin, int numParams)
{
	//return true;
	return PluginsFound;
}

public int Native_FF2Version(Handle plugin, int numParams)
{
	int version[3];  //Blame the compiler for this mess -.-
	version[0]=StringToInt(MAJOR_REVISION);
	version[1]=StringToInt(MINOR_REVISION);
	version[2]=StringToInt(STABLE_REVISION);
	SetNativeArray(1, version, sizeof(version));
	#if !defined DEV_REVISION
		return false;
	#else
		return true;
	#endif
}

public int Native_GetBoss(Handle plugin, int numParams)
{
	/*
	int boss=GetNativeCell(1);
	if(boss>=0 && boss<=MaxClients && IsValidClient(boss))
	{
		return GetClientUserId(boss);
	}*/
	int boss=GetNativeCell(1);
	if (VSHA_IsBossPlayer(boss)) return GetClientUserId(boss);
	return -1;
}

public int Native_GetIndex(Handle plugin, int numParams)
{
	//return BossIndex[GetNativeCell(1)];
	return VSHA_GetBossArrayListIndex(GetNativeCell(1));
}

public int Native_GetTeam(Handle plugin, int numParams)
{
	//return BossTeam;
	return 0;
}

/**
 * Gets the character name of the Boss
 *
 * @param boss	 			Boss's index
 * @param buffer			Buffer for boss' character name
 * @param bufferLength		Length of buffer string
 * @param clientMeaning		0 - "client" parameter means index of current Boss
 *							1 - "client" parameter means number of Boss in characters.cfg-1
 * @return					True if boss exists, false if not
 */
//native bool FF2_GetBossSpecial(int boss=0, char[] buffer, int bufferLength, int clientMeaning=0);
public int Native_GetSpecial(Handle plugin, int numParams)
{
	/*
	char BossShortName[16];

	VSHA_GetBossName(iiBoss, BossShortName, 16);

	int iBossIndex = FindBossIndexByShortName(BossShortName);

	if(iBossIndex > -1)
	{

	int index=GetNativeCell(1), dstrlen=GetNativeCell(3), see=GetNativeCell(4);
	char s[dstrlen];
	if(see)
	{
		if(index<0) return false;
		if(!index) return false;
		VSHA_GetBossName(index, BossShortName, 16);


		KvRewind(BossKV[index]);
		KvGetString(BossKV[index], "name", s, dstrlen);
		SetNativeString(2, s,dstrlen);
	}
	else
	{
		if(index<0) //return false;
		if(Special[index]<0) //return false;
		if(!BossKV[Special[index]]) //return false;
		KvRewind(BossKV[Special[index]]);
		KvGetString(BossKV[Special[index]], "name", s, dstrlen);
		SetNativeString(2, s,dstrlen);
	}*/

	SetNativeString(2, "",16);
	return 1;
}

public int Native_GetBossHealth(Handle plugin, int numParams)
{
	////return BossHealth[GetNativeCell(1)];
	return VSHA_GetBossHealth(GetNativeCell(1));
}

public int Native_SetBossHealth(Handle plugin, int numParams)
{
	//BossHealth[GetNativeCell(1)]=GetNativeCell(2);
	VSHA_SetBossHealth(GetNativeCell(1), GetNativeCell(2));
}

public int Native_GetBossMaxHealth(Handle plugin, int numParams)
{
	//return BossHealthMax[GetNativeCell(1)];
	return VSHA_GetBossMaxHealth(GetNativeCell(1));
}

public int Native_SetBossMaxHealth(Handle plugin, int numParams)
{
	//BossHealthMax[GetNativeCell(1)]=GetNativeCell(2);
	VSHA_SetBossMaxHealth(GetNativeCell(1), GetNativeCell(2));
}

public int Native_GetBossLives(Handle plugin, int numParams)
{
	//return BossLives[GetNativeCell(1)];
	return VSHA_GetLives(GetNativeCell(1));
}

public int Native_SetBossLives(Handle plugin, int numParams)
{
	//BossLives[GetNativeCell(1)]=GetNativeCell(2);
	VSHA_SetLives(GetNativeCell(1), GetNativeCell(2));
}

public int Native_GetBossMaxLives(Handle plugin, int numParams)
{
	//return BossLivesMax[GetNativeCell(1)];
	return VSHA_GetMaxLives(GetNativeCell(1));
}

public int Native_SetBossMaxLives(Handle plugin, int numParams)
{
	//BossLivesMax[GetNativeCell(1)]=GetNativeCell(2);
	VSHA_SetMaxLives(GetNativeCell(1), GetNativeCell(2));
}
//native float FF2_GetBossCharge(int boss, int slot);
public int Native_GetBossCharge(Handle plugin, int numParams)
{
	//return _:BossCharge[GetNativeCell(1)][GetNativeCell(2)];
	int slot = GetNativeCell(2);
	if(slot == 0)
	{
		return view_as<int>(VSHA_GetBossRage(GetNativeCell(1)));
	}
	else
	{
		float FloatReturned = 0.0;
		Action result = Plugin_Continue;
		Call_StartForward(p_OnFF2_GetBossCharge);
		Call_PushCell(GetNativeCell(1));
		Call_PushCell(slot);
		Call_PushFloatRef(FloatReturned);
		Call_Finish(result);

		return view_as<int>(FloatReturned);
	}
}

public int Native_SetBossCharge(Handle plugin, int numParams)
{
	//BossCharge[GetNativeCell(1)][GetNativeCell(2)]=Float:GetNativeCell(3);
	int slot = GetNativeCell(2);
	if(slot == 0)
	{
		VSHA_SetBossRage(GetNativeCell(1), view_as<float>(GetNativeCell(3)));
	}
	else
	{
		Call_StartForward(p_OnFF2_SetBossCharge);
		Call_PushCell(GetNativeCell(1));
		Call_PushCell(slot);
		Call_PushFloat(GetNativeCell(3));
		Call_Finish();
	}
}

public int Native_GetBossRageDamage(Handle plugin, int numParams)
{
	//return BossRageDamage[GetNativeCell(1)];
	return VSHA_GetDamage(GetNativeCell(1));
}

public int Native_SetBossRageDamage(Handle plugin, int numParams)
{
	//BossRageDamage[GetNativeCell(1)]=GetNativeCell(2);
	VSHA_SetDamage(GetNativeCell(1), GetNativeCell(2));
}

public int Native_GetRoundState(Handle plugin, int numParams)
{
	if(CheckRoundState()<=0)
	{
		return 0;
	}
	return CheckRoundState();
}

public int Native_GetRageDist(Handle plugin, int numParams)
{
	/*
	int index=GetNativeCell(1);
	char plugin_name[64];
	GetNativeString(2,plugin_name,64);
	char ability_name[64];
	GetNativeString(3,ability_name,64);

	if(!BossKV[Special[index]]) //return _:0.0;
	KvRewind(BossKV[Special[index]]);
	decl Float:see;
	if(!ability_name[0])
	{
		//return _:KvGetFloat(BossKV[Special[index]],"ragedist",400.0);
	}
	char s[10];
	for(int i=1; i<MAXRANDOMS; i++)
	{
		Format(s,10,"ability%i",i);
		if(KvJumpToKey(BossKV[Special[index]],s))
		{
			char ability_name2[64];
			KvGetString(BossKV[Special[index]], "name",ability_name2,64);
			if(strcmp(ability_name,ability_name2))
			{
				KvGoBack(BossKV[Special[index]]);
				continue;
			}
			if((see=KvGetFloat(BossKV[Special[index]],"dist",-1.0))<0)
			{
				KvRewind(BossKV[Special[index]]);
				see=KvGetFloat(BossKV[Special[index]],"ragedist",400.0);
			}
			//return _:see;
		}
	}
	return _:0.0;
*/
	return view_as<int>(400.0);
}
//native bool FF2_HasAbility(int boss, const char[] pluginName, const char[] abilityName);
public int Native_HasAbility(Handle plugin, int numParams)
{
	char plugin_name[64]; char ability_name[64];

	GetNativeString(2, plugin_name, sizeof(plugin_name));
	GetNativeString(3, ability_name, sizeof(ability_name));

	bool BooleanReturned = false;

	Action result = Plugin_Continue;
	Call_StartForward(p_OnFF2_HasAbility);
	Call_PushCell(GetNativeCell(1));
	Call_PushString(plugin_name);
	Call_PushString(ability_name);
	Call_PushCellRef(BooleanReturned);
	Call_Finish(result);

	return BooleanReturned;
}

public int Native_DoAbility(Handle plugin, int numParams)
{
	char plugin_name[64];
	char ability_name[64];
	GetNativeString(2,plugin_name,64);
	GetNativeString(3,ability_name,64);
	UseAbility(ability_name,plugin_name, GetNativeCell(1), GetNativeCell(4), GetNativeCell(5));
}
/**
 * FF2_ONABILITY IS KNOWN TO BE BUGGED AND WILL NOT BE FIXED TO PRESERVE BACKWARDS COMPATABILITY.  DO NOT USE IT.
 * Called when a Boss uses an ability (Rage, jump, teleport, etc)
 * Called every 0.2 seconds for charge abilities
 *
 * Use FF2_PreAbility with enabled=false ONLY to prevent FF2_OnAbility!
 *
 * @param boss	 		Boss's index
 * @param pluginName	Name of plugin with this ability
 * @param abilityName 	Name of ability
 * @param slot			Slot of ability (THIS DOES NOT RETURN WHAT YOU THINK IT RETURNS FOR FF2_ONABILITY-if you insist on using this, refer to freak_fortress_2.sp to see what it actually does)
 * 							0 - Rage or life-loss
 * 							1 - Jump or teleport
 * 							2 - Other
 * @param status		Status of ability (DO NOT ACCESS THIS.  IT DOES NOT EXIST AND MIGHT CRASH YOUR SERVER)
 * @return				Plugin_Stop can not prevent the ability. Use FF2_PreAbility with enabled=false
 */
//forward void FF2_PreAbility(int boss, const char[] pluginName, const char[] abilityName, int slot, bool &enabled);

stock void UseAbility(const char[] ability_name, const char[] plugin_name, int iiBoss, int slot, int buttonMode=0)
{
	bool enabled=true;
	Call_StartForward(p_PreAbility);
	Call_PushCell(iiBoss);
	Call_PushString(plugin_name);
	Call_PushString(ability_name);
	Call_PushCell(slot);
	Call_PushCellRef(enabled);
	Call_Finish();

	if(!enabled)
	{
		return;
	}

	Action action=Plugin_Continue;
	Call_StartForward(p_OnAbility);
	Call_PushCell(iiBoss);
	Call_PushString(plugin_name);
	Call_PushString(ability_name);
	Call_PushCell(slot);
	Call_Finish(action);
}

//native int FF2_GetAbilityArgument(int boss, const char[] pluginName, const char[]abilityName, int argument, int defValue=0);
public int Native_GetAbilityArgument(Handle plugin, int numParams)
{
	char plugin_name[64];
	char ability_name[64];
	GetNativeString(2,plugin_name,64);
	GetNativeString(3,ability_name,64);

	Action result = Plugin_Continue;

	Call_StartForward(p_OnFF2_GetAbilityArgument);
	Call_PushCell(GetNativeCell(1));
	Call_PushString(plugin_name);
	Call_PushString(ability_name);
	Call_PushCell(GetNativeCell(4));

	int IntegerReturned = GetNativeCell(5);
	Call_PushCellRef(IntegerReturned);
	Call_Finish(result);

	return IntegerReturned;
}
//native float FF2_GetAbilityArgumentFloat(int boss, const char[] plugin_name, const char[] ability_name, int argument, float defValue=0.0);
public int Native_GetAbilityArgumentFloat(Handle plugin, int numParams)
{
	char plugin_name[64];
	char ability_name[64];
	GetNativeString(2,plugin_name,64);
	GetNativeString(3,ability_name,64);

	Action result = Plugin_Continue;

	Call_StartForward(p_OnFF2_GetAbilityArgumentFloat);
	Call_PushCell(GetNativeCell(1));
	Call_PushString(plugin_name);
	Call_PushString(ability_name);
	Call_PushCell(GetNativeCell(4));

	float FloatReturned = view_as<float>(GetNativeCell(5));
	Call_PushFloatRef(FloatReturned);
	Call_Finish(result);

	return view_as<int>(FloatReturned);
}
//native void FF2_GetAbilityArgumentString(int boss, const char[] pluginName, const char[] abilityName, int argument, char[] buffer, int bufferLength);
public int Native_GetAbilityArgumentString(Handle plugin, int numParams)
{
	char plugin_name[64];
	GetNativeString(2,plugin_name,64);
	char ability_name[64];
	GetNativeString(3,ability_name,64);
	int dstrlen=GetNativeCell(6);
	char[] TheCopyBackString = new char[dstrlen+1];

	Action result = Plugin_Continue;
	Call_StartForward(p_OnFF2_GetAbilityArgumentString);
	Call_PushCell(GetNativeCell(1));
	Call_PushString(plugin_name);
	Call_PushString(ability_name);
	Call_PushCell(GetNativeCell(4));
	Call_PushStringEx(TheCopyBackString, dstrlen, 0, SM_PARAM_COPYBACK);
	Call_PushCell(GetNativeCell(6));
	Call_Finish(result);

	SetNativeString(5,TheCopyBackString,dstrlen);
}

public int Native_GetDamage(Handle plugin, int numParams)
{
	int client=GetNativeCell(1);
	if(!IsValidClient(client))
	{
		return 0;
	}
	return VSHA_GetDamage(client);
}

public int Native_GetFF2flags(Handle plugin, int numParams)
{
	return FF2flags[GetNativeCell(1)];
}

public int Native_SetFF2flags(Handle plugin, int numParams)
{
	FF2flags[GetNativeCell(1)]=GetNativeCell(2);
}

public int Native_GetQueuePoints(Handle plugin, int numParams)
{
	//return GetClientQueuePoints(GetNativeCell(1));
	return VSHA_GetClientQueuePoints(GetNativeCell(1));
}

public int Native_SetQueuePoints(Handle plugin, int numParams)
{
	//SetClientQueuePoints(GetNativeCell(1), GetNativeCell(2));
	VSHA_SetClientQueuePoints(GetNativeCell(1), GetNativeCell(2));
}

public int Native_GetSpecialKV(Handle plugin, int numParams)
{
	/*
	int index=GetNativeCell(1);
	bool isNumOfSpecial=bool:GetNativeCell(2);
	if(isNumOfSpecial)
	{
		if(index!=-1 && index<Specials)
		{
			if(BossKV[index]!=INVALID_HANDLE)
			{
				KvRewind(BossKV[index]);
			}
			//return _:BossKV[index];
		}
	}
	else
	{
		if(index!=-1 && index<=MaxClients && Special[index]!=-1 && Special[index]<MAXSPECIALS)
		{
			if(BossKV[Special[index]]!=INVALID_HANDLE)
			{
				KvRewind(BossKV[Special[index]]);
			}
			//return _:BossKV[Special[index]];
		}
	}
	return _:INVALID_HANDLE;
	*/
	return -1;
}

public int Native_StartMusic(Handle plugin, int numParams)
{
	//Timer_MusicPlay(INVALID_HANDLE,GetNativeCell(1));
}

public int Native_StopMusic(Handle plugin, int numParams)
{
	//StopMusic(GetNativeCell(1));
}

public int Native_RandomSound(Handle plugin, int numParams)
{
	/*
	int length=GetNativeCell(3)+1;
	int boss=GetNativeCell(4);
	int slot=GetNativeCell(5);
	char sound[length];
	int kvLength;

	GetNativeStringLength(1, kvLength);
	kvLength++;

	char keyvalue[kvLength];
	GetNativeString(1, keyvalue, kvLength);

	bool soundExists;
	if(!strcmp(keyvalue, "sound_ability"))
	{
		soundExists=RandomSoundAbility(keyvalue, sound, length, boss, slot);
	}
	else
	{
		soundExists=RandomSound(keyvalue, sound, length, boss);
	}
	SetNativeString(2, sound, length);
	return soundExists;*/
	return 0;
}

public int Native_GetClientGlow(Handle plugin, int numParams)
{
	int client=GetNativeCell(1);
	if(IsValidClient(client))
	{
		return view_as<int>(VSHA_GetGlowTimer(client));
	}
	else
	{
		return -1;
	}
}

public int Native_SetClientGlow(Handle plugin, int numParams)
{
	//SetClientGlow(GetNativeCell(1), GetNativeCell(2), GetNativeCell(3));
	int client = GetNativeCell(1);

	float iTimer2 = GetNativeCell(3);
	float iTimer;
	if(iTimer2 > 0.0)
	{
		iTimer = iTimer2;
	}
	else
	{
		iTimer = VSHA_GetGlowTimer(client) + GetNativeCell(2);
	}
	VSHA_SetGlowTimer(client, iTimer);
}

public int Native_GetAlivePlayers(Handle plugin, int numParams)
{
	//return RedAlivePlayers;
}

public int Native_GetBossPlayers(Handle plugin, int numParams)
{
	//return BlueAlivePlayers;
}

public int Native_Debug(Handle plugin, int numParams)
{
	//return GetConVarBool(cvarDebug);
	return false;
}

public int Native_IsVSHMap(Handle plugin, int numParams)
{
	//return false;
	return IsVSHMap();
}

//===========================================================================================================================

//=================================================== [ H O O K S ] =========================================================

stock Handle GetVSHAHookType(FF2toVSHAHookType vshaHOOKtype)
{
	switch(vshaHOOKtype)
	{
		case FF2toVSHAHook_OnFF2_GetAbilityArgument:
		{
			return p_OnFF2_GetAbilityArgument;
		}
		case FF2toVSHAHook_OnFF2_GetAbilityArgumentFloat:
		{
			return p_OnFF2_GetAbilityArgumentFloat;
		}
		case FF2toVSHAHook_OnFF2_GetAbilityArgumentString:
		{
			return p_OnFF2_GetAbilityArgumentString;
		}
		case FF2toVSHAHook_OnFF2_HasAbility:
		{
			return p_OnFF2_HasAbility;
		}
		case FF2toVSHAHook_OnFF2_GetBossCharge:
		{
			return p_OnFF2_GetBossCharge;
		}
		case FF2toVSHAHook_OnFF2_SetBossCharge:
		{
			return p_OnFF2_SetBossCharge;
		}
	}
	return null;
}


public int Native_Hook(Handle plugin, int numParams)
{
	FF2toVSHAHookType vshaHOOKtype = GetNativeCell(1);

	Handle FwdHandle = GetVSHAHookType(vshaHOOKtype);
	Function Func = GetNativeFunction(2);

	if(FwdHandle != null)
	{
		/*
		if(GetNativeCell(3))
		{
			// if true to automatic hooking

			StringMap MapHooking = new StringMap();
			MapHooking.SetValue("Plugin", plugin);
			MapHooking.SetValue("VSHAHookType", vshaHOOKtype);

			hArrayAutomaticHooking.Push(MapHooking);
		}*/
		AddToForward(FwdHandle, plugin, Func);
	}
}

public int Native_HookEx(Handle plugin, int numParams)
{
	FF2toVSHAHookType vshaHOOKtype = GetNativeCell(1);

	Handle FwdHandle = GetVSHAHookType(vshaHOOKtype);
	Function Func = GetNativeFunction(2);

	if(FwdHandle != null)
	{
		/*
		if(GetNativeCell(3))
		{
			// if true to automatic hooking
			StringMap MapHooking = new StringMap();
			MapHooking.SetValue("Plugin", plugin);
			MapHooking.SetValue("VSHAHookType", vshaHOOKtype);
			MapHooking.SetValue("Function", Func);

			hArrayAutomaticHooking.Push(MapHooking);
		}*/
		return AddToForward(FwdHandle, plugin, Func);
	}
	return 0;
}

public int Native_Unhook(Handle plugin, int numParams)
{
	FF2toVSHAHookType vshaHOOKtype = GetNativeCell(1);

	Handle FwdHandle = GetVSHAHookType(vshaHOOKtype);

	if(FwdHandle != null)
	{
		//RemoveAutomaticHooking(plugin);
		RemoveFromForward(FwdHandle, plugin, GetNativeFunction(2));
	}
}
public int Native_UnhookEx(Handle plugin, int numParams)
{
	FF2toVSHAHookType vshaHOOKtype = GetNativeCell(1);

	Handle FwdHandle = GetVSHAHookType(vshaHOOKtype);

	if(FwdHandle != null)
	{
		//RemoveAutomaticHooking(plugin);
		return RemoveFromForward(FwdHandle, plugin, GetNativeFunction(2));
	}
	return 0;
}
