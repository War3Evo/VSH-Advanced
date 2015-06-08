

#pragma semicolon 1

#include <sourcemod>
#include <morecolors>
#include <tf2_stocks>
#include <tf2items>
#include <adt_array>
#include <clientprefs>

#undef REQUIRE_PLUGIN
//#tryinclude <goomba>
//#tryinclude <rtd>
#tryinclude <tf2attributes>
//#tryinclude <updater>
#define REQUIRE_PLUGIN

#include <vsha>
#include <freak_fortress_2>

#define PLUGIN_VERSION "1.0"

ArrayList hArrayBossSubplugins = null;
ArrayList hArrayDownloads = null;

bool areSubPluginsEnabled = false;

#define MAXRANDOMS 16

enum Operators
{
	Operator_None=0,
	Operator_Add,
	Operator_Subtract,
	Operator_Multiply,
	Operator_Divide,
	Operator_Exponent,
};

/*
int Specials;
Handle PreAbility;
Handle OnAbility;
Handle OnMusic;
Handle OnTriggerHurt;
Handle OnSpecialSelected;
Handle OnAddQueuePoints;
Handle OnLoadCharacterSet;
Handle OnLoseLife;
Handle OnAlivePlayersChanged;
*/



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
		return APLRes_Failure;
	}
/*
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


	PreAbility=CreateForward("FF2_PreAbility", ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell, Param_CellByRef);  //Boss, plugin name, ability name, slot, enabled
	OnAbility=CreateForward("FF2_OnAbility", ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell);  //Boss, plugin name, ability name, status
	OnMusic=CreateForward("FF2_OnMusic", ET_Hook, Param_String, Param_FloatByRef);
	OnTriggerHurt=CreateForward("FF2_OnTriggerHurt", ET_Hook, Param_Cell, Param_Cell, Param_FloatByRef);
	OnSpecialSelected=CreateForward("FF2_OnSpecialSelected", ET_Hook, Param_Cell, Param_CellByRef, Param_String);  //Boss, character index, character name
	OnAddQueuePoints=CreateForward("FF2_OnAddQueuePoints", ET_Hook, Param_Array);
	OnLoadCharacterSet=CreateForward("FF2_OnLoadCharacterSet", ET_Hook, Param_CellByRef, Param_String);
	OnLoseLife=CreateForward("FF2_OnLoseLife", ET_Hook, Param_Cell, Param_CellByRef, Param_Cell);  //Boss, lives left, max lives
	OnAlivePlayersChanged=CreateForward("FF2_OnAlivePlayersChanged", ET_Hook, Param_Cell, Param_Cell);  //Players, bosses
*/
	RegPluginLibrary("freak_fortress_2");

	return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
	if(!VSHAHookEx(VSHAHook_AddToDownloads, OnAddToDownloads))
	{
		LogError("Error loading VSHAHook_AddToDownloads forwards for saxton hale.");
	}

	if(!FindCharacters())
	{
		LogError("[VSHA] FindCharacters Failed!");
	}
}

public void OnPluginStart()
{
	hArrayBossSubplugins = new ArrayList();
	hArrayDownloads = new ArrayList(ByteCountToCells(PATHX));

	LoadTranslations("freak_fortress_2.phrases");
	LoadTranslations("common.phrases");
}

public void OnPluginEnd()
{
	DisableSubPlugins();
}

public void OnMapEnd()
{
	DisableSubPlugins();
}

public void OnAddToDownloads()
{
	PrecacheSound("vo/announcer_ends_5min.mp3", true);

	char cbuffer[PATHX];
	for (int i = 0; i < hArrayDownloads.Length; i++)
	{
		hArrayDownloads.GetString(i, STRING(cbuffer));
		AddFileToDownloadsTable(cbuffer);
	}

	EnableSubPlugins();
}

public bool FindCharacters()  //TODO: Investigate KvGotoFirstSubKey; KvGotoNextKey
{
	char config[PATHX];
	char key[4];
	//char charset[42];
	BuildPath(Path_SM, config, PATHX, "configs/freak_fortress_2/characters.cfg");

	if(!FileExists(config))
	{
		LogError("[FF2] Freak Fortress 2 disabled-can not find characters.cfg!");
		return false;
	}

	Handle Kv=CreateKeyValues("");
	FileToKeyValues(Kv, config);

	// probably don't need this
	/*
	int NumOfCharSet=FF2CharSet;

	Action action=Plugin_Continue;
	Call_StartForward(OnLoadCharacterSet);
	Call_PushCellRef(NumOfCharSet);
	strcopy(charset, sizeof(charset), FF2CharSetString);
	Call_PushStringEx(charset, sizeof(charset), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish(action);
	if(action==Plugin_Changed)
	{
		int i=-1;
		if(strlen(charset))
		{
			KvRewind(Kv);
			for(i=0; ; i++)
			{
				KvGetSectionName(Kv, config, sizeof(config));
				if(!strcmp(config, charset, false))
				{
					FF2CharSet=i;
					strcopy(FF2CharSetString, PLATFORM_MAX_PATH, charset);
					KvGotoFirstSubKey(Kv);
					break;
				}

				if(!KvGotoNextKey(Kv))
				{
					i=-1;
					break;
				}
			}
		}

		if(i==-1)
		{
			FF2CharSet=NumOfCharSet;
			for(i=0; i<FF2CharSet; i++)
			{
				KvGotoNextKey(Kv);
			}
			KvGotoFirstSubKey(Kv);
			KvGetSectionName(Kv, FF2CharSetString, sizeof(FF2CharSetString));
		}
	}

	KvRewind(Kv);
	for(int i; i<FF2CharSet; i++)
	{
		KvGotoNextKey(Kv);
	}*/
	KvRewind(Kv);

	//for(int i=1; i<MAXSPECIALS; i++)
	for(int i=1; ; i++)
	{
		IntToString(i, key, sizeof(key));
		KvGetString(Kv, key, config, PLATFORM_MAX_PATH);
		if(!config[0])  //TODO: Make this more user-friendly (don't immediately break-they might have missed a number)
		{
			break;
		}
		LoadCharacter(Kv,config);
	}

	CloseHandle(Kv);
	return true;
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

	directory=OpenDirectory(path);
	while(ReadDirEntry(directory, filename, PLATFORM_MAX_PATH, filetype))
	{
		if(filetype==FileType_File && StrContains(filename, ".ff2", false)!=-1)
		{
			ServerCommand("sm plugins load freaks/%s", filename);
		}
	}
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

public void LoadCharacter(Handle BossKV, const char[] character)
{
	char extensions[][]={".mdl", ".dx80.vtx", ".dx90.vtx", ".sw.vtx", ".vvd"};
	char config[PLATFORM_MAX_PATH];

	BuildPath(Path_SM, config, PLATFORM_MAX_PATH, "configs/freak_fortress_2/%s.cfg", character);
	if(!FileExists(config))
	{
		LogError("[FF2] Character %s does not exist!", character);
		return;
	}

	StringMap BossSubplug = new StringMap(); //CreateTrie();

	BossSubplug.SetString("character", character);

	BossKV=CreateKeyValues("character");
	FileToKeyValues(BossKV, config);

	int version=KvGetNum(BossKV, "version", 1);
	if(version!=1)
	{
		LogError("[FF2] Character %s is only compatible with FF2 v%i!", character, version);
		return;
	}

	// Checker to see if all plugins required for ff2 exists
	for(int i=1; ; i++)
	{
		Format(config, 10, "ability%i", i);
		if(KvJumpToKey(BossKV, config))
		{
			char plugin_name[64];
			KvGetString(BossKV, "plugin_name", plugin_name, 64);
			BuildPath(Path_SM, config, PLATFORM_MAX_PATH, "plugins/freaks/%s.ff2", plugin_name);
			if(!FileExists(config))
			{
				LogError("[FF2] Character %s needs plugin %s!", character, plugin_name);
				return;
			}
		}
		else
		{
			break;
		}
	}
	KvRewind(BossKV);

	char key[PLATFORM_MAX_PATH]; char section[64];
	KvSetString(BossKV, "filename", character);
	KvGetString(BossKV, "name", config, PLATFORM_MAX_PATH);

	BossSubplug.SetString("filename", character);
	BossSubplug.SetString("name", config);

	BossSubplug.SetValue("bBlockVoice", KvGetNum(BossKV, "sound_block_vo", 0));
	BossSubplug.SetValue("BossSpeed", KvGetFloat(BossKV, "maxspeed", 340.0));
	//BossRageDamage=KvGetFloat(BossKV, "ragedamage", 1900.0);

	// For Downloads
	KvGotoFirstSubKey(BossKV);
	while(KvGotoNextKey(BossKV))
	{
		KvGetSectionName(BossKV, section, sizeof(section));
		if(!strcmp(section, "download"))
		{
			for(int i=1; ; i++)
			{
				IntToString(i, key, sizeof(key));
				KvGetString(BossKV, key, config, PLATFORM_MAX_PATH);
				if(!config[0])
				{
					break;
				}
				//AddFileToDownloadsTable(config);
				hArrayDownloads.PushString(config);
			}
		}
		else if(!strcmp(section, "mod_download"))
		{
			for(int i=1; ; i++)
			{
				IntToString(i, key, sizeof(key));
				KvGetString(BossKV, key, config, PLATFORM_MAX_PATH);
				if(!config[0])
				{
					break;
				}

				for(int extension; extension<sizeof(extensions); extension++)
				{
					Format(key, PLATFORM_MAX_PATH, "%s%s", config, extensions[extension]);
					//AddFileToDownloadsTable(key);
					hArrayDownloads.PushString(key);
				}
			}
		}
		else if(!strcmp(section, "mat_download"))
		{
			for(int i=1; ; i++)
			{
				IntToString(i, key, sizeof(key));
				KvGetString(BossKV, key, config, PLATFORM_MAX_PATH);
				if(!config[0])
				{
					break;
				}
				Format(key, PLATFORM_MAX_PATH, "%s.vtf", config);
				//AddFileToDownloadsTable(key);
				hArrayDownloads.PushString(key);
				Format(key, PLATFORM_MAX_PATH, "%s.vmt", config);
				//AddFileToDownloadsTable(key);
				hArrayDownloads.PushString(key);
			}
		}
	}

	// Cache Abilities
	KvRewind(BossKV);
	char sAbility[10];
	char sStoreString[32];
	int ArgNum;
	char s[10];
	for(int i=1; i<MAXRANDOMS; i++)
	{
		Format(sAbility,10,"ability%i",i);
		if(KvJumpToKey(BossKV,sAbility))
		{
			char ability_name2[64];
			KvGetString(BossKV, "name",ability_name2,64);

			char plugin_name2[64];
			KvGetString(BossKV, "plugin_name",plugin_name2,64);

			// example: ability1name
			Format(sStoreString,32,"%sname",sAbility);
			BossSubplug.SetString(sStoreString, ability_name2);

			// example: ability1plugin_name
			Format(sStoreString,32,"%splugin_name",sAbility);
			BossSubplug.SetString(sStoreString, plugin_name2);

			for(int x=1; ; x++)
			{
				Format(s,10,"arg%i",x);
				ArgNum = KvGetNum(BossKV, s, -1);

				if(ArgNum == -1)
				{
					break;
				}

				// example: ability1arg0
				Format(sStoreString,32,"%sarg%i",sAbility,ArgNum);
				BossSubplug.SetValue(sStoreString, ArgNum);
			}
		}
	}

	hArrayBossSubplugins.Push(BossSubplug);
}

