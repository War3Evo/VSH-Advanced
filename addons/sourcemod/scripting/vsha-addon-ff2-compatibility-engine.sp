

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
#include <freak_fortress_2>

#define PLUGIN_VERSION "1.0"

ArrayList hArrayBossSubplugins = null;
ArrayList hArrayDownloads = null;

bool areSubPluginsEnabled = false;

//int iThisPlugin = -1;

bool InRage[PLYR];

int BossIndex[PLYR]; // boss index

#define MAJOR_REVISION "1"
#define MINOR_REVISION "10"
#define STABLE_REVISION "6"

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

float BossCharge[PLYR+1][8];
float Marketed[PLYR+1];
int FF2flags[PLYR+1];

int detonations[PLYR+1];

float circuitStun;
int allowedDetonations;

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

Handle p_PreAbility;
Handle p_OnAbility;
Handle p_OnMusic;
Handle p_OnTriggerHurt;
Handle p_OnSpecialSelected;
Handle p_OnAddQueuePoints;
Handle p_OnLoadCharacterSet;
Handle p_OnLoseLife;
Handle p_OnAlivePlayersChanged;

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
	p_PreAbility=CreateForward( ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell, Param_CellByRef);  //Boss, plugin name, ability name, slot, enabled

	//"FF2_OnAbility"
	p_OnAbility=CreateForward( ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell);  //Boss, plugin name, ability name, status

	//"FF2_OnMusic"
	p_OnMusic=CreateForward( ET_Hook, Param_String, Param_FloatByRef);

	//"FF2_OnTriggerHurt"
	p_OnTriggerHurt=CreateForward( ET_Hook, Param_Cell, Param_Cell, Param_FloatByRef);

	//"FF2_OnSpecialSelected"
	p_OnSpecialSelected=CreateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_String);  //Boss, character index, character name

	//"FF2_OnAddQueuePoints"
	p_OnAddQueuePoints=CreateForward( ET_Hook, Param_Array);

	//"FF2_OnLoadCharacterSet"
	p_OnLoadCharacterSet=CreateForward( ET_Hook, Param_CellByRef, Param_String);

	//"FF2_OnLoseLife"
	p_OnLoseLife=CreateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_Cell);  //Boss, lives left, max lives

	//"FF2_OnAlivePlayersChanged"
	p_OnAlivePlayersChanged=CreateForward( ET_Hook, Param_Cell, Param_Cell);  //Players, bosses

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
	}*/
}

public void UnLoad_VSHAHooks()
{
	/*
	if(!VSHAUnhookEx(VSHAHook_OnBossIntroTalk, OnBossIntroTalk))
	{
		LogError("Error unloading VSHAHook_OnBossIntroTalk forwards for miku.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnPlayerKilledByBoss, OnPlayerKilledByBoss))
	{
		LogError("Error unloading VSHAHook_OnPlayerKilledByBoss forwards for miku.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnKillingSpreeByBoss, OnKillingSpreeByBoss))
	{
		LogError("Error unloading VSHAHook_OnKillingSpreeByBoss forwards for miku.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnBossKilled, OnBossKilled))
	{
		LogError("Error unloading VSHAHook_OnBossKilled forwards for miku.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnBossWin, OnBossWin))
	{
		LogError("Error unloading VSHAHook_OnBossWin forwards for miku.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnBossAirblasted, OnBossAirblasted))
	{
		LogError("Error unloading VSHAHook_OnBossAirblasted forwards for miku.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossChangeClass, OnChangeClass))
	{
		LogError("Error loading VSHAHook_OnBossChangeClass forwards for saxton hale.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnBossSetHP, OnBossSetHP))
	{
		LogError("Error unloading VSHAHook_OnBossSetHP forwards for miku.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnLastSurvivor, OnLastSurvivor))
	{
		LogError("Error unloading VSHAHook_OnLastSurvivor forwards for miku.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnBossTimer, OnBossTimer))
	{
		LogError("Error unloading VSHAHook_OnBossTimer forwards for miku.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnPrepBoss, OnPrepBoss))
	{
		LogError("Error unloading VSHAHook_OnPrepBoss forwards for miku.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnMusic, OnMusic))
	{
		LogError("Error unloading VSHAHook_OnMusic forwards for miku.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnBossRage, OnBossRage))
	{
		LogError("Error unloading VSHAHook_OnBossRage forwards for miku.");
	}
	if(!VSHAUnhookEx(VSHAHook_ShowBossHelpMenu, OnShowBossHelpMenu))
	{
		LogError("Error unloading VSHAHook_ShowBossHelpMenu forwards for saxton hale.");
	}*/
}
public void OnAllPluginsLoaded()
{
	if(!VSHAHookEx(VSHAHook_AddToDownloads, OnAddToDownloads))
	{
		LogError("Error loading VSHAHook_AddToDownloads forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossSelected, OnBossSelected))
	{
		LogError("Error loading VSHAHook_OnBossSelected forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnGameOver, OnGameOver))
	{
		LogError("Error loading VSHAHook_OnGameOver forwards for miku.");
	}

	if(!FindCharacters())
	{
		LogError("[VSHA] FindCharacters Failed!");
		LogError("[VSHA] FindCharacters Failed!");
		LogError("[VSHA] FindCharacters Failed!");
		LogError("[VSHA] FindCharacters Failed!");
		LogError("[VSHA] FindCharacters Failed!");
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
		//return false;
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

	int count = hArrayBossSubplugins.Length;
	char sAbility[10];
	char sFindString[64];
	char sPluginNameString[PATHX];
	bool found = false;

	directory=OpenDirectory(path);
	while(ReadDirEntry(directory, filename, PLATFORM_MAX_PATH, filetype))
	{
		if(filetype==FileType_File && StrContains(filename, ".ff2", false)!=-1)
		{
			for(int i=1; ; i++)
			{
				Format(sAbility,10,"ability%i",i);
				Format(sFindString,64,"%splugin_name",sAbility);

				for (int x = 0; x < count; x++)
				{
					StringMap MyStringMap3 = hArrayBossSubplugins.Get(x);

					if(MyStringMap3.GetString(sFindString, sPluginNameString, 64))
					{
						if(StrContains(filename, sPluginNameString, false)!=-1)
						{
							// load only needed plugins
							//ServerCommand("sm plugins load freaks/%s", filename);
							found = true;
							InsertServerCommand("sm plugins load freaks/%s", filename);
							break;
						}
					}
				}
			}
			//ServerCommand("sm plugins load freaks/%s", filename);
		}
	}
	if(found)
	{
		ServerExecute();
	}

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

	PrintToServer("character %s",character);
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

	char characterShortName[16];
	char characterLongName[32];

	strcopy(STRING(characterLongName), character);

	ReplaceString(STRING(characterShortName), characterLongName, " ", false);

	BossSubplug.SetString("shortname", characterShortName);
	int BossArrayListIndex = VSHA_RegisterBoss(characterShortName,characterLongName);

	BossSubplug.SetValue("BossArrayListIndex", BossArrayListIndex);

	KvSetString(BossKV, "model", section);
	BossSubplug.SetString("model", section);
	VSHA_SetPluginModel(BossArrayListIndex,characterShortName);


	PrintToServer("filename %s",character);
	PrintToServer("name %s",config);

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
	//int ArgNum;
	char s[10];

	char life_name[32];
	char ability_name2[64];
	char plugin_name2[64];
	char arg_string[64];

	for(int i=1; i<MAXRANDOMS; i++)
	{
		Format(sAbility,10,"ability%i",i);
		if(KvJumpToKey(BossKV,sAbility))
		{
			KvGetString(BossKV, "name",ability_name2,64);

			KvGetString(BossKV, "plugin_name",plugin_name2,64);

			KvGetString(BossKV, "life",life_name,64);
			BossSubplug.SetString("life", life_name);

			// example: ability1name
			Format(sStoreString,32,"%sname",sAbility);
			BossSubplug.SetString(sStoreString, ability_name2);
			LogError("ability name %s",sStoreString);

			// example: ability1plugin_name
			Format(sStoreString,32,"%splugin_name",sAbility);
			BossSubplug.SetString(sStoreString, plugin_name2);
			LogError("plugin_name %s",sStoreString);

			for(int x=1; ; x++)
			{
				Format(s,10,"arg%i",x);
				//ArgNum = KvGetNum(BossKV, s, -1);

				KvGetString(BossKV, s ,arg_string,64, "notfound");

				if(StrEqual(arg_string,"notfound"))
				{
					break;
				}

				// example: ability1arg0
				Format(sStoreString,32,"%s%s",sAbility,s);
				BossSubplug.SetString(sStoreString, arg_string);
				LogError("sStoreString %s",sStoreString);
			}
		}
	}

	hArrayBossSubplugins.Push(BossSubplug);
}


public void LoadPluginForwards()
{
	char sAbility[10];
	char sGetString[64];
	char sPluginNameString[PATHX];

	bool found = false;

	char cFilePath[PATHX];

	Handle PluginHandle;
	Function funcID;

	// Load Character Plugin Forwards
	int count = hArrayBossSubplugins.Length; //GetArraySize(hArrayBossSubplugins);
	for (int x = 0; x < count; x++)
	{
		StringMap MyStringMap2 = hArrayBossSubplugins.Get(x);

//sm plugins load freaks/shadow93_bosses.ff2

		for(int i=1; ; i++)
		{
			Format(sAbility,10,"ability%i",i);
			Format(sGetString,64,"%splugin_name",sAbility);

			LogError("LOOKING FOR sGetString %s FF2 Functions!",sGetString);

			if(MyStringMap2.GetString(sGetString, sPluginNameString, 64))
			{
				LogError("LOOKING FOR sPluginNameString %s FF2 Functions!",sPluginNameString);

				Format(cFilePath,PATHX,"freaks/%s.ff2",sPluginNameString);
				//Format(cFilePath,PATHX,"%s.ff2",sPluginNameString);

				//LogError("sPluginNameString %s",sPluginNameString);

				//BuildPath(Path_SM, cFilePath, PLATFORM_MAX_PATH, "plugins/freaks/%s.ff2", sPluginNameString);

				LogError("cFilePath %s",cFilePath);

				PluginHandle = FindPluginByFile(cFilePath);
				if(PluginHandle != null)
				{
					LogError("Found %s plugin for hooking FF2 Functions!",sPluginNameString);
					funcID = GetFunctionByName(PluginHandle, "FF2_PreAbility");
					if(funcID != INVALID_FUNCTION)
					{
						found = true;
						LogError("Found %s FF2_PreAbility FF2 Function!",sPluginNameString);
						// hook function
						if(AddToForward(p_PreAbility, PluginHandle, funcID))
						{
							LogError("AddToForward SuccessFul!");
						}
					}
					funcID = GetFunctionByName(PluginHandle, "FF2_OnAbility");
					if(funcID != INVALID_FUNCTION)
					{
						found = true;
						LogError("Found %s FF2_OnAbility FF2 Function!",sPluginNameString);
						// hook function
						if(AddToForward(p_OnAbility, PluginHandle, funcID))
						{
							LogError("FF2_OnAbility AddToForward SuccessFul!");
						}
					}
					funcID = GetFunctionByName(PluginHandle, "FF2_OnMusic");
					if(funcID != INVALID_FUNCTION)
					{
						found = true;
						LogError("Found %s FF2_OnMusic FF2 Function!",sPluginNameString);
						// hook function
						if(AddToForward(p_OnMusic, PluginHandle, funcID))
						{
							LogError("FF2_OnMusic AddToForward SuccessFul!");
						}
					}
					funcID = GetFunctionByName(PluginHandle, "FF2_OnTriggerHurt");
					if(funcID != INVALID_FUNCTION)
					{
						found = true;
						LogError("Found %s FF2_OnTriggerHurt FF2 Function!",sPluginNameString);
						// hook function
						if(AddToForward(p_OnTriggerHurt, PluginHandle, funcID))
						{
							LogError("FF2_OnTriggerHurt AddToForward SuccessFul!");
						}
					}
					funcID = GetFunctionByName(PluginHandle, "FF2_OnSpecialSelected");
					if(funcID != INVALID_FUNCTION)
					{
						found = true;
						LogError("Found %s FF2_OnSpecialSelected FF2 Function!",sPluginNameString);
						// hook function
						if(AddToForward(p_OnSpecialSelected, PluginHandle, funcID))
						{
							LogError("FF2_OnSpecialSelected AddToForward SuccessFul!");
						}
					}
					funcID = GetFunctionByName(PluginHandle, "FF2_OnAddQueuePoints");
					if(funcID != INVALID_FUNCTION)
					{
						found = true;
						LogError("Found %s FF2_OnAddQueuePoints FF2 Function!",sPluginNameString);
						// hook function
						if(AddToForward(p_OnAddQueuePoints, PluginHandle, funcID))
						{
							LogError("FF2_OnAddQueuePoints AddToForward SuccessFul!");
						}
					}
					funcID = GetFunctionByName(PluginHandle, "FF2_OnLoadCharacterSet");
					if(funcID != INVALID_FUNCTION)
					{
						found = true;
						LogError("Found %s FF2_OnLoadCharacterSet FF2 Function!",sPluginNameString);
						// hook function
						if(AddToForward(p_OnLoadCharacterSet, PluginHandle, funcID))
						{
							LogError("FF2_OnLoadCharacterSet AddToForward SuccessFul!");
						}
					}
					funcID = GetFunctionByName(PluginHandle, "FF2_OnLoseLife");
					if(funcID != INVALID_FUNCTION)
					{
						found = true;
						LogError("Found %s FF2_OnLoseLife FF2 Function!",sPluginNameString);
						// hook function
						if(AddToForward(p_OnLoseLife, PluginHandle, funcID))
						{
							LogError("FF2_OnLoseLife AddToForward SuccessFul!");
						}
					}
					funcID = GetFunctionByName(PluginHandle, "FF2_OnAlivePlayersChanged");
					if(funcID != INVALID_FUNCTION)
					{
						found = true;
						LogError("Found %s FF2_OnAlivePlayersChanged FF2 Function!",sPluginNameString);
						// hook function
						if(AddToForward(p_OnAlivePlayersChanged, PluginHandle, funcID))
						{
							LogError("FF2_OnAlivePlayersChanged AddToForward SuccessFul!");
						}
					}
				}
			}
			else
			{
				break;
			}
		}

		if(found)
		{
			LogError("FF2 FUNCTIONS FOUND!");
		}
		else
		{
			LogError("FF2 FUNCTIONS F A I L!");
		}
	}
}





public int Native_IsEnabled(Handle plugin, int numParams)
{
	return true;
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
	return BossIndex[GetNativeCell(1)];
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
		return view_as<int>(BossCharge[GetNativeCell(1)][GetNativeCell(2)]);
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
		BossCharge[GetNativeCell(1)][GetNativeCell(2)]=view_as<float>(GetNativeCell(3));
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

public int Native_HasAbility(Handle plugin, int numParams)
{
	int boss=GetNativeCell(1);

	if(boss==-1 || BossIndex[boss]==-1)
	{
		return false;
	}

	int index = BossIndex[boss];

	if(index > hArrayBossSubplugins.Length)
	{
		return 0;
	}

	char pluginName[64]; char abilityName[64];

	GetNativeString(2, pluginName, sizeof(pluginName));
	GetNativeString(3, abilityName, sizeof(abilityName));

	char sAbility[10];
	char sFindString[10];

	char sStringHolder[64];
	char sStringHolder2[64];

	//int count = hArrayBossSubplugins.Length;
	//for (int index = 0; index < count; index++)
	//{
	StringMap MyStringMap = hArrayBossSubplugins.Get(index);

	for(int i=1; i<MAXRANDOMS ; i++)
	{
		Format(sAbility,10,"ability%i",i);
		Format(sFindString,64,"%sname",sAbility);

		MyStringMap.GetString(sFindString, sStringHolder, 64);

		Format(sFindString,64,"%splugin_name",sAbility);

		MyStringMap.GetString(sFindString, sStringHolder2, 64);

		if(StrEqual(sStringHolder,abilityName) && StrEqual(sStringHolder2,pluginName))
		{
			return true;
		}
	}

	return false;
}

public int Native_DoAbility(Handle plugin, int numParams)
{
	char plugin_name[64];
	char ability_name[64];
	GetNativeString(2,plugin_name,64);
	GetNativeString(3,ability_name,64);
	UseAbility(ability_name,plugin_name, GetNativeCell(1), GetNativeCell(4), GetNativeCell(5));
}

public int Native_GetAbilityArgument(Handle plugin, int numParams)
{
	char plugin_name[64];
	char ability_name[64];
	GetNativeString(2,plugin_name,64);
	GetNativeString(3,ability_name,64);
	return GetAbilityArgument(GetNativeCell(1),plugin_name,ability_name,GetNativeCell(4),GetNativeCell(5));
}

public int Native_GetAbilityArgumentFloat(Handle plugin, int numParams)
{
	char plugin_name[64];
	char ability_name[64];
	GetNativeString(2,plugin_name,64);
	GetNativeString(3,ability_name,64);
	return view_as<int>(GetAbilityArgumentFloat(GetNativeCell(1),plugin_name,ability_name,GetNativeCell(4),GetNativeCell(5)));
}

public int Native_GetAbilityArgumentString(Handle plugin, int numParams)
{
	char plugin_name[64];
	GetNativeString(2,plugin_name,64);
	char ability_name[64];
	GetNativeString(3,ability_name,64);
	int dstrlen=GetNativeCell(6);
	char[] s = new char[dstrlen+1];
	GetAbilityArgumentString(GetNativeCell(1),plugin_name,ability_name,GetNativeCell(4),s,dstrlen);
	SetNativeString(5,s,dstrlen);
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

///////////////// VSHA interface ///////////////////////////////////////
///////////////// VSHA interface ///////////////////////////////////////
///////////////// VSHA interface ///////////////////////////////////////
///////////////// VSHA interface ///////////////////////////////////////
///////////////// VSHA interface ///////////////////////////////////////
///////////////// VSHA interface ///////////////////////////////////////
///////////////// VSHA interface ///////////////////////////////////////
///////////////// VSHA interface ///////////////////////////////////////
///////////////// VSHA interface ///////////////////////////////////////
///////////////// VSHA interface ///////////////////////////////////////
///////////////// VSHA interface ///////////////////////////////////////
///////////////// VSHA interface ///////////////////////////////////////


public void OnBossRage(int iBossArrayListIndex, int iiBoss)
{
	if (hThisPlugin != BossPlugin) return;

	// Helps prevent multiple rages
	InRage[iiBoss] = true;

	char sAbility[10];
	char sGetString[10];
	char sStringHolder[10];
	char lives[MAXRANDOMS][3];

	int count = hArrayBossSubplugins.Length;
	for (int x = 0; x < count; x++)
	{
		StringMap MyStringMap = hArrayBossSubplugins.Get(x);

		for(int i=1; ; i++)
		{
			Format(sAbility,10,"ability%i",i);
			Format(sGetString,64,"%sarg0",sAbility);

			if(MyStringMap.GetString(sGetString, sStringHolder, 64))
			{
				if(StringToInt(sStringHolder)>0)
				{
					continue;
				}

				if(MyStringMap.GetString("life", sStringHolder, 64))
				{
					if(!sStringHolder[0])
					{
						char abilityName[64]; char pluginName[64];
						Format(sGetString,64,"%sname",sAbility);
						MyStringMap.GetString(sGetString, abilityName, 64);
						Format(sGetString,64,"%splugin_name",sAbility);
						MyStringMap.GetString(sGetString, pluginName, 64);
						UseAbility(abilityName, pluginName, iiBoss, 0);
					}
					else
					{
						int mycount=ExplodeString(sStringHolder, " ", lives, MAXRANDOMS, 3);
						for(int j; j<mycount; j++)
						{
							if(StringToInt(lives[j])==VSHA_GetLives(iiBoss))
							{
								char abilityName[64]; char pluginName[64];
								Format(sGetString,64,"%sname",sAbility);
								MyStringMap.GetString(sGetString, abilityName, 64);
								Format(sGetString,64,"%splugin_name",sAbility);
								MyStringMap.GetString(sGetString, pluginName, 64);
								UseAbility(abilityName, pluginName, iiBoss, 0);
								break;
							}
						}
					}
				}
			}
		}
	}
	/*

	float position[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", position);

	char sound[PLATFORM_MAX_PATH];
	if(RandomSoundAbility("sound_ability", sound, PLATFORM_MAX_PATH, boss))
	{
		//FF2flags[Boss[boss]]|=FF2FLAG_TALKING;
		EmitSoundToAll(sound, client, _, _, _, _, _, client, position);
		EmitSoundToAll(sound, client, _, _, _, _, _, client, position);

		for(int target=1; target<=MaxClients; target++)
		{
			if(IsClientInGame(target) && target!=Boss[boss])
			{
				EmitSoundToClient(target, sound, client, _, _, _, _, _, client, position);
				EmitSoundToClient(target, sound, client, _, _, _, _, _, client, position);
			}
		}
		//FF2flags[Boss[boss]]&=~FF2FLAG_TALKING;
	}
	//emitRageSound[boss]=true;
	*/
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
	if(slot==-1)
	{
		Call_PushCell(3);  //Status - we're assuming here a life-loss ability will always be in use if it gets called
		Call_Finish(action);
	}
	else if(!slot) // not 0 ... means 0 is changed to true.. slot is 0
	{
		FF2flags[iiBoss]&=~FF2FLAG_BOTRAGE;
		Call_PushCell(3);  //Status - we're assuming here a rage ability will always be in use if it gets called
		Call_Finish(action);
		BossCharge[iiBoss][slot]=0.0;
		VSHA_SetBossRage(iiBoss, 0.0);
	}
	else // slot is anything from 1+
	{
		SetHudTextParams(-1.0, 0.88, 0.15, 255, 255, 255, 255);
		int button;
		switch(buttonMode)
		{
			case 2:
			{
				button=IN_RELOAD;
			}
			default:
			{
				button=IN_DUCK|IN_ATTACK2;
			}
		}

		if(GetClientButtons(iiBoss) & button)
		{
			if(!(FF2flags[iiBoss] & FF2FLAG_USINGABILITY))
			{
				FF2flags[iiBoss]|=FF2FLAG_USINGABILITY;
				switch(buttonMode)
				{
					case 2:
					{
						//SetInfoCookies(iiBoss, 0, CheckInfoCookies(iiBoss, 0)-1);
					}
					default:
					{
						//SetInfoCookies(iiBoss, 1, CheckInfoCookies(iiBoss, 1)-1);
					}
				}
			}

			if(BossCharge[iiBoss][slot]>=0.0)
			{
				Call_PushCell(2);  //Status
				Call_Finish(action);
				float charge=100.0*0.2/GetAbilityArgumentFloat(iiBoss, plugin_name, ability_name, 1, 1.5);
				if(BossCharge[iiBoss][slot]+charge<100.0)
				{
					BossCharge[iiBoss][slot]+=charge;
				}
				else
				{
					BossCharge[iiBoss][slot]=100.0;
				}
			}
			else
			{
				Call_PushCell(1);  //Status
				Call_Finish(action);
				BossCharge[iiBoss][slot]+=0.2;
			}
		}
		else if(BossCharge[iiBoss][slot]>0.3)
		{
			float angles[3];
			GetClientEyeAngles(iiBoss, angles);
			if(angles[0]<-45.0)
			{
				Call_PushCell(3);
				Call_Finish(action);
				Handle data;
				CreateDataTimer(0.1, Timer_UseBossCharge, data);
				WritePackCell(data, iiBoss);
				WritePackCell(data, slot);
				WritePackFloat(data, -1.0*GetAbilityArgumentFloat(iiBoss, plugin_name, ability_name, 2, 5.0));
				ResetPack(data);
			}
			else
			{
				Call_PushCell(0);  //Status
				Call_Finish(action);
				BossCharge[iiBoss][slot]=0.0;
			}
		}
		else if(BossCharge[iiBoss][slot]<0.0)
		{
			Call_PushCell(1);  //Status
			Call_Finish(action);
			BossCharge[iiBoss][slot]+=0.2;
		}
		else
		{
			Call_PushCell(0);  //Status
			Call_Finish(action);
		}
	}
}

public Action Timer_UseBossCharge(Handle timer, Handle data)
{
	BossCharge[ReadPackCell(data)][ReadPackCell(data)]=ReadPackFloat(data);
	return Plugin_Continue;
}

stock int GetAbilityArgument(int client, const char[] plugin_name, const char[] ability_name, int arg, int defvalue=0)
{
	if(client==-1)
		return 0;

	int index = BossIndex[client];

	if(index > hArrayBossSubplugins.Length)
	{
		return 0;
	}

	char sAbility[10];
	char sFindString[10];

	char sStringHolder[64];
	char sStringHolder2[64];

	//int count = hArrayBossSubplugins.Length;
	//for (int x = 0; x < count; x++)
	//{
	StringMap MyStringMap = hArrayBossSubplugins.Get(index);

	for(int i=1; i<MAXRANDOMS ; i++)
	{
		Format(sAbility,10,"ability%i",i);
		Format(sFindString,64,"%sname",sAbility);

		MyStringMap.GetString(sFindString, sStringHolder, 64);

		Format(sFindString,64,"%splugin_name",sAbility);

		MyStringMap.GetString(sFindString, sStringHolder2, 64);

		if(StrEqual(sStringHolder,ability_name) && StrEqual(sStringHolder2,plugin_name))
		{
			Format(sFindString,64,"%sarg%i",sAbility,arg);
			if(MyStringMap.GetString(sFindString, sStringHolder, 64))
			{
				return (StringToInt(sStringHolder));
			}
		}
	}
	//}
	return 0;
}

stock float GetAbilityArgumentFloat(int client, const char[] plugin_name, const char[] ability_name, int arg, float defvalue=0.0)
{
	if(client==-1)
		return 0.0;

	int index = BossIndex[client];

	if(index > hArrayBossSubplugins.Length)
	{
		return 0.0;
	}

	char sAbility[10];
	char sFindString[10];

	char sStringHolder[64];
	char sStringHolder2[64];

	//int count = hArrayBossSubplugins.Length;
	//for (int index = 0; index < count; index++)
	//{
	StringMap MyStringMap = hArrayBossSubplugins.Get(index);

	for(int i=1; i<MAXRANDOMS ; i++)
	{
		Format(sAbility,10,"ability%i",i);
		Format(sFindString,64,"%sname",sAbility);

		MyStringMap.GetString(sFindString, sStringHolder, 64);

		Format(sFindString,64,"%splugin_name",sAbility);

		MyStringMap.GetString(sFindString, sStringHolder2, 64);

		if(StrEqual(sStringHolder,ability_name) && StrEqual(sStringHolder2,plugin_name))
		{
			Format(sFindString,64,"%sarg%i",sAbility,arg);
			if(MyStringMap.GetString(sFindString, sStringHolder, 64))
			{
				return (StringToFloat(sStringHolder));
			}
		}
	}
	//}
	return 0.0;
}

stock void GetAbilityArgumentString(int client,const char[] plugin_name,const char[] ability_name, int arg, char[] buffer, int buflen,const char[] defvalue="")
{
	if(client==-1)
	{
		strcopy(buffer,buflen,"");
		return;
	}

	int index = BossIndex[client];

	if(index > hArrayBossSubplugins.Length)
	{
		return;
	}

	char sAbility[10];
	char sFindString[10];

	char sStringHolder[64];
	char sStringHolder2[64];

	//int count = hArrayBossSubplugins.Length;
	//for (int index = 0; index < count; index++)
	//{
	StringMap MyStringMap = hArrayBossSubplugins.Get(index);

	for(int i=1; ; i++)
	{
		Format(sAbility,10,"ability%i",i);
		Format(sFindString,64,"%sname",sAbility);

		MyStringMap.GetString(sFindString, sStringHolder, 64);

		Format(sFindString,64,"%splugin_name",sAbility);

		MyStringMap.GetString(sFindString, sStringHolder2, 64);

		if(StrEqual(sStringHolder,ability_name) && StrEqual(sStringHolder2,plugin_name))
		{
			Format(sFindString,64,"%sarg%i",sAbility,arg);
			if(MyStringMap.GetString(sFindString, sStringHolder, 64))
			{
				strcopy(buffer, buflen, sStringHolder);
			}
		}
	}
	//}
}

stock int FindBossIndexByShortName(char BossShortName[16])
{
	char sStringHolder[64];
	int count = hArrayBossSubplugins.Length;
	for (int x = 0; x < count; x++)
	{
		StringMap MyStringMap = hArrayBossSubplugins.Get(x);

		for(int i=1; ; i++)
		{
			if(MyStringMap.GetString("shortname", sStringHolder, 64))
			{
				if(StrEqual(sStringHolder,BossShortName))
				{
					return x;
				}
			}
		}
	}
	return -1;
}


public void OnBossSelected(int iBossArrayListIndex, int iiBoss)
{
	if(iBossArrayListIndex!=iThisPlugin)
	{
		// reset variables
		SDKUnhook(iiBoss, SDKHook_OnTakeDamage, OnTakeDamage);
		//HaleCharge[iiBoss]=0;
		InRage[iiBoss]=false;
		BossIndex[iiBoss]=-1;
		return;
	}

	char BossShortName[16];

	VSHA_GetBossName(iiBoss, BossShortName, 16);

	int iBossIndex = FindBossIndexByShortName(BossShortName);

	if(iBossIndex > -1)
	{
		BossIndex[iiBoss] = iBossIndex;

		//CPrintToChatAll("%s, Miku Boss Selected!",VSHA_COLOR);

		// Dynamically load private forwards
		Load_VSHAHooks();
		SDKHook(iiBoss, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}
public void OnGameOver() // best play to reset all variables
{
	LoopMaxPLYR(players)
	{
		//HaleCharge[players]=0;
		InRage[players]=false;
		BossIndex[players]=-1;

		//if(ValidPlayer(players))
		//{
			//StopSound(players, SNDCHAN_AUTO, MIKUTheme);
		//}
	}
	// Dynamically unload private forwards
	UnLoad_VSHAHooks();
}

public Action OnTakeDamage(int client, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(!IsValidEdict(attacker))
	{
		return Plugin_Continue;
	}

	static bool foundDmgCustom; bool dmgCustomInOTD;
	if(!foundDmgCustom)
	{
		dmgCustomInOTD=(GetFeatureStatus(FeatureType_Capability, "SDKHook_DmgCustomInOTD")==FeatureStatus_Available);
		foundDmgCustom=true;
	}

	if((attacker<=0 || client==attacker) && VSHA_GetBossPluginHandle(client)==hThisPlugin)
	{
		return Plugin_Handled;
	}

	if(TF2_IsPlayerInCondition(client, TFCond_Ubercharged))
	{
		return Plugin_Continue;
	}

	if(!CheckRoundState() && VSHA_GetBossPluginHandle(client)==hThisPlugin)
	{
		damage*=0.0;
		return Plugin_Changed;
	}

	float position[3];
	GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", position);
	if(VSHA_IsBossPlayer(attacker))
	{
		if(IsValidClient(client) && VSHA_GetBossPluginHandle(client)!=hThisPlugin && !TF2_IsPlayerInCondition(client, TFCond_Bonked))
		{
			if(TF2_IsPlayerInCondition(client, TFCond_DefenseBuffed))
			{
				ScaleVector(damageForce, 9.0);
				damage*=0.3;
				return Plugin_Changed;
			}

			if(TF2_IsPlayerInCondition(client, TFCond_DefenseBuffMmmph))
			{
				damage*=9;
				TF2_AddCondition(client, TFCond_Bonked, 0.1);
				return Plugin_Changed;
			}

			if(TF2_IsPlayerInCondition(client, TFCond_CritMmmph))
			{
				damage*=0.25;
				return Plugin_Changed;
			}

			int shield = VSHA_HasShield(client);

			if(shield && damage)
			{
				TF2_RemoveWearable(client, shield);
				EmitSoundToClient(client, "player/spy_shield_break.wav", _, _, _, _, 0.7, _, _, position, _, false);
				EmitSoundToClient(client, "player/spy_shield_break.wav", _, _, _, _, 0.7, _, _, position, _, false);
				EmitSoundToClient(attacker, "player/spy_shield_break.wav", _, _, _, _, 0.7, _, _, position, _, false);
				EmitSoundToClient(attacker, "player/spy_shield_break.wav", _, _, _, _, 0.7, _, _, position, _, false);
				TF2_AddCondition(client, TFCond_Bonked, 0.1);
				VSHA_SetShield(client, 0);
				return Plugin_Continue;
			}

			switch(TF2_GetPlayerClass(client))
			{
				case TFClass_Spy:
				{
					if(GetEntProp(client, Prop_Send, "m_bFeignDeathReady") && !TF2_IsPlayerInCondition(client, TFCond_Cloaked))
					{
						if(damagetype & DMG_CRIT)
						{
							damagetype&=~DMG_CRIT;
						}
						damage=620.0;
						return Plugin_Changed;
					}

					if(TF2_IsPlayerInCondition(client, TFCond_Cloaked) && TF2_IsPlayerInCondition(client, TFCond_DeadRingered))
					{
						if(damagetype & DMG_CRIT)
						{
							damagetype&=~DMG_CRIT;
						}
						damage=850.0;
						return Plugin_Changed;
					}

					if(GetEntProp(client, Prop_Send, "m_bFeignDeathReady") || TF2_IsPlayerInCondition(client, TFCond_DeadRingered))
					{
						if(damagetype & DMG_CRIT)
						{
							damagetype&=~DMG_CRIT;
						}
						damage=620.0;
						return Plugin_Changed;
					}
				}
				case TFClass_Soldier:
				{
					if(IsValidEdict((weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary))) && GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex")==226 && !(FF2flags[client] & FF2FLAG_ISBUFFED))  //Battalion's Backup
					{
						SetEntPropFloat(client, Prop_Send, "m_flRageMeter", 100.0);
					}
				}
			}

			if(damage<=160.0)  //TODO: Wat
			{
				damage*=3;
				return Plugin_Changed;
			}
		}
	}
	else
	{
		//int boss=GetBossIndex(client);
		//if(boss!=-1)
		if(VSHA_GetBossPluginHandle(client)==hThisPlugin)
		{
			int boss=client;
			if(attacker<=MaxClients)
			{
				bool bIsTelefrag; bool bIsBackstab;
				if(dmgCustomInOTD)
				{
					if(damagecustom==TF_CUSTOM_BACKSTAB)
					{
						bIsBackstab=true;
					}
					else if(damagecustom==TF_CUSTOM_TELEFRAG)
					{
						bIsTelefrag=true;
					}
				}
				else if(weapon!=4095 && IsValidEdict(weapon) && weapon==GetPlayerWeaponSlot(attacker, TFWeaponSlot_Melee) && damage>1000.0)
				{
					char classname[32];
					if(GetEdictClassname(weapon, classname, sizeof(classname)) && !strcmp(classname, "tf_weapon_knife", false))
					{
						bIsBackstab=true;
					}
				}
				else if(!IsValidEntity(weapon) && (damagetype & DMG_CRUSH)==DMG_CRUSH && damage==1000.0)
				{
					bIsTelefrag=true;
				}

				if(bIsTelefrag)
				{
					damagecustom=0;
					if(!IsPlayerAlive(attacker))
					{
						damage=1.0;
						return Plugin_Changed;
					}
					damage=(VSHA_GetBossHealth(boss)>9001 ? 9001.0 : float(GetEntProp(boss, Prop_Send, "m_iHealth"))+90.0);

					int teleowner=FindTeleOwner(attacker);
					if(IsValidClient(teleowner) && teleowner!=attacker)
					{
						//Damage[teleowner]+=9001*3/5;
						int tmpdmg = VSHA_GetDamage(teleowner)+(9001*3/5);
						VSHA_SetDamage(teleowner,tmpdmg);
						if(!(FF2flags[teleowner] & FF2FLAG_HUDDISABLED))
						{
							PrintHintText(teleowner, "TELEFRAG ASSIST!  Nice job setting it up!");
						}
					}

					if(!(FF2flags[attacker] & FF2FLAG_HUDDISABLED))
					{
						PrintHintText(attacker, "TELEFRAG! You are a pro!");
					}

					if(!(FF2flags[client] & FF2FLAG_HUDDISABLED))
					{
						PrintHintText(client, "TELEFRAG! Be careful around quantum tunneling devices!");
					}
					return Plugin_Changed;
				}

				int index;
				if(IsValidEntity(weapon) && weapon>MaxClients && attacker<=MaxClients)
				{
					char classname[64];
					GetEntityClassname(weapon, classname, sizeof(classname));
					if(!StrContains(classname, "eyeball_boss"))  //Dang spell Monoculuses
					{
						index=-1;
					}
					else
					{
						index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
					}
				}
				else
				{
					index=-1;
				}

				switch(index)
				{
					case 14, 201, 230, 402, 526, 664, 752, 792, 801, 851, 881, 890, 899, 908, 957, 966:  //Sniper Rifle, Strange Sniper Rifle, Sydney Sleeper, Bazaar Bargain, Machina, Festive Sniper Rifle, Hitman's Heatmaker, Botkiller Sniper Rifles
					{
						switch(index)
						{
							case 14, 201, 664, 792, 801, 851, 881, 890, 899, 908, 957, 966:  //Sniper Rifle, Strange Sniper Rifle, Festive Sniper Rifle, Botkiller Sniper Rifles
							{
								if(CheckRoundState()!=2)
								{
									float chargelevel=(IsValidEntity(weapon) && weapon>MaxClients ? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
									float time=(VSHA_GetGlowTimer(boss)>10 ? 1.0 : 2.0);
									time+=(VSHA_GetGlowTimer(boss)>10 ? (VSHA_GetGlowTimer(boss)>20 ? 1.0 : 2.0) : 4.0)*(chargelevel/100.0);
									//SetClientGlow(boss, time);
									VSHA_SetGlowTimer(boss, time);
									if(VSHA_GetGlowTimer(boss)>30.0)
									{
										//GlowTimer[boss]=30.0;
										VSHA_SetGlowTimer(boss,30.0);
									}
								}
							}
						}

						if(index==752 && CheckRoundState()!=2)  //Hitman's Heatmaker
						{
							float chargelevel=(IsValidEntity(weapon) && weapon>MaxClients ? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
							float add=10+(chargelevel/10);
							if(TF2_IsPlayerInCondition(attacker, view_as<TFCond>(46)))
							{
								add/=3;
							}
							float rage=GetEntPropFloat(attacker, Prop_Send, "m_flRageMeter");
							SetEntPropFloat(attacker, Prop_Send, "m_flRageMeter", (rage+add>100) ? 100.0 : rage+add);
						}

						if(!(damagetype & DMG_CRIT))
						{
							if(TF2_IsPlayerInCondition(attacker, TFCond_CritCola) || TF2_IsPlayerInCondition(attacker, TFCond_Buffed) || TF2_IsPlayerInCondition(attacker, TFCond_CritHype))
							{
								damage*=1.7;
							}
							else
							{
								if(index!=230 || BossCharge[boss][0]>90.0)  //Sydney Sleeper
								{
									damage*=2.9;
								}
								else
								{
									damage*=2.4;
								}
							}
							return Plugin_Changed;
						}
					}
					case 61, 1006:  //Ambassador, Festive Ambassador
					{
						if(damagecustom==TF_CUSTOM_HEADSHOT)
						{
							damage=85.0;  //Final damage 255
						}
					}
					case 132, 266, 482, 1082:  //Eyelander, HHHH, Nessie's Nine Iron, Festive Eyelander
					{
						IncrementHeadCount(attacker);
					}
					case 214:  //Powerjack
					{
						int health=GetClientHealth(attacker);
						int max=GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
						int newhealth=health+50;
						if(health<max+100)
						{
							if(newhealth>max+100)
							{
								newhealth=max+100;
							}
							SetEntProp(attacker, Prop_Data, "m_iHealth", newhealth);
							SetEntProp(attacker, Prop_Send, "m_iHealth", newhealth);
						}

						if(TF2_IsPlayerInCondition(attacker, TFCond_OnFire))
						{
							TF2_RemoveCondition(attacker, TFCond_OnFire);
						}
					}
					case 317:  //Candycane
					{
						SpawnSmallHealthPackAt(client, GetClientTeam(attacker));
					}
					case 355:  //Fan O' War
					{
						if(BossCharge[boss][0]>0.0)
						{
							BossCharge[boss][0]-=5.0;
							if(BossCharge[boss][0]<0.0)
							{
								BossCharge[boss][0]=0.0;
							}
						}
					}
					case 357:  //Half-Zatoichi
					{
						SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
						if(GetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy")<1)
						{
							SetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
						}

						int health=GetClientHealth(attacker);
						int max=GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
						int newhealth=health+50;
						if(health<max+100)
						{
							if(newhealth>max+100)
							{
								newhealth=max+100;
							}
							SetEntProp(attacker, Prop_Data, "m_iHealth", newhealth);
							SetEntProp(attacker, Prop_Send, "m_iHealth", newhealth);
						}
						if(TF2_IsPlayerInCondition(attacker, TFCond_OnFire))
						{
							TF2_RemoveCondition(attacker, TFCond_OnFire);
						}
					}
					case 416:  //Market Gardener (courtesy of Chdata)
					{
						if(FF2flags[attacker] & FF2FLAG_ROCKET_JUMPING)
						{
							damage=(Pow(float(VSHA_GetBossMaxHealth(boss)), 0.74074)+512.0-(Marketed[client]/128.0*float(VSHA_GetBossMaxHealth(boss))))/3.0;
							damagetype|=DMG_CRIT;

							if(Marketed[client]<5)
							{
								Marketed[client]++;
							}

							PrintHintText(attacker, "%t", "Market Gardener");  //You just market-gardened the boss!
							PrintHintText(client, "%t", "Market Gardened");  //You just got market-gardened!

							EmitSoundToClient(attacker, "player/doubledonk.wav", _, _, _, _, 0.6, _, _, position, _, false);
							EmitSoundToClient(client, "player/doubledonk.wav", _, _, _, _, 0.6, _, _, position, _, false);
							return Plugin_Changed;
						}
					}
					case 525, 595:  //Diamondback, Manmelter
					{
						if(GetEntProp(attacker, Prop_Send, "m_iRevengeCrits"))  //If a revenge crit was used, give a damage bonus
						{
							damage=85.0;  //255 final damage
						}
					}
					case 528:  //Short Circuit
					{
						if(circuitStun)
						{
							TF2_StunPlayer(client, circuitStun, 0.0, TF_STUNFLAGS_SMALLBONK|TF_STUNFLAG_NOSOUNDOREFFECT, attacker);
							EmitSoundToAll("weapons/barret_arm_zap.wav", client);
							EmitSoundToClient(client, "weapons/barret_arm_zap.wav");
						}
					}
					case 593:  //Third Degree
					{
						int healers[MAXPLAYERS];
						int healerCount;
						for(int healer; healer<=MaxClients; healer++)
						{
							if(IsValidClient(healer) && IsPlayerAlive(healer) && (GetHealingTarget(healer, true)==attacker))
							{
								healers[healerCount]=healer;
								healerCount++;
							}
						}

						for(int healer; healer<healerCount; healer++)
						{
							if(IsValidClient(healers[healer]) && IsPlayerAlive(healers[healer]))
							{
								int medigun=GetPlayerWeaponSlot(healers[healer], TFWeaponSlot_Secondary);
								if(IsValidEntity(medigun))
								{
									char classname[64];
									GetEdictClassname(medigun, classname, sizeof(classname));
									if(!strcmp(classname, "tf_weapon_medigun", false))
									{
										float uber=GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel")+(0.1/healerCount);
										float max=1.0;
										if(GetEntProp(medigun, Prop_Send, "m_bChargeRelease"))
										{
											max=1.5;
										}

										if(uber>max)
										{
											uber=max;
										}
										SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", uber);
									}
								}
							}
						}
					}
					case 594:  //Phlogistinator
					{
						if(!TF2_IsPlayerInCondition(attacker, TFCond_CritMmmph))
						{
							damage/=2.0;
						}
					}
					case 1099:  //Tide Turner
					{
						SetEntPropFloat(attacker, Prop_Send, "m_flChargeMeter", 100.0);
					}
					/*case 1104:  //Air Strike-moved to event_hurt for now since OTD doesn't display the actual damage :/
					{
						static Float:airStrikeDamage;
						airStrikeDamage+=damage;
						if(airStrikeDamage>=200.0)
						{
							SetEntProp(attacker, Prop_Send, "m_iDecapitations", GetEntProp(attacker, Prop_Send, "m_iDecapitations")+1);
							airStrikeDamage-=200.0;
						}
					}*/
				}

				if(bIsBackstab)
				{
					damage=VSHA_GetBossMaxHealth(boss)*(LastBossIndex()+1)*VSHA_GetMaxLives(boss)*(0.12-VSHA_GetBossStabs(boss)/90)/3;
					damagetype|=DMG_CRIT;
					damagecustom=0;

					EmitSoundToClient(client, "player/spy_shield_break.wav", _, _, _, _, 0.7, _, _, position, _, false);
					EmitSoundToClient(attacker, "player/spy_shield_break.wav", _, _, _, _, 0.7, _, _, position, _, false);
					EmitSoundToClient(client, "player/crit_received3.wav", _, _, _, _, 0.7, _, _, _, _, false);
					EmitSoundToClient(attacker, "player/crit_received3.wav", _, _, _, _, 0.7, _, _, _, _, false);
					SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+2.0);
					SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", GetGameTime()+2.0);
					SetEntPropFloat(attacker, Prop_Send, "m_flStealthNextChangeTime", GetGameTime()+2.0);

					int viewmodel=GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
					if(viewmodel>MaxClients && IsValidEntity(viewmodel) && TF2_GetPlayerClass(attacker)==TFClass_Spy)
					{
						int melee=GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Melee);
						int animation=15;
						switch(melee)
						{
							case 727:  //Black Rose
							{
								animation=41;
							}
							case 4, 194, 665, 794, 803, 883, 892, 901, 910:  //Knife, Strange Knife, Festive Knife, Botkiller Knifes
							{
								animation=10;
							}
							case 638:  //Sharp Dresser
							{
								animation=31;
							}
						}
						SetEntProp(viewmodel, Prop_Send, "m_nSequence", animation);
					}

					if(!(FF2flags[attacker] & FF2FLAG_HUDDISABLED))
					{
						PrintHintText(attacker, "%t", "Backstab");
					}

					if(!(FF2flags[client] & FF2FLAG_HUDDISABLED))
					{
						PrintHintText(client, "%t", "Backstabbed");
					}

					if(index==225 || index==574)  //Your Eternal Reward, Wanga Prick
					{
						CreateTimer(0.3, Timer_DisguiseBackstab, GetClientUserId(attacker));
					}
					else if(index==356)  //Conniver's Kunai
					{
						int health=GetClientHealth(attacker)+200;
						if(health>500)
						{
							health=500;
						}
						SetEntProp(attacker, Prop_Data, "m_iHealth", health);
						SetEntProp(attacker, Prop_Send, "m_iHealth", health);
					}
					else if(index==461)  //Big Earner
					{
						SetEntPropFloat(attacker, Prop_Send, "m_flCloakMeter", 100.0);  //Full cloak
					}

					if(GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Primary)==525)  //Diamondback
					{
						SetEntProp(attacker, Prop_Send, "m_iRevengeCrits", GetEntProp(attacker, Prop_Send, "m_iRevengeCrits")+2);
					}

					//char sound[PLATFORM_MAX_PATH];
					//if(RandomSound("sound_stabbed", sound, PLATFORM_MAX_PATH, boss))
					//{
						//EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, sound, _, _, _, _, _, _, Boss[boss], _, _, false);
						//EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, sound, _, _, _, _, _, _, Boss[boss], _, _, false);
					//}

					if(VSHA_GetBossStabs(boss)<3)
					{
						//Stabbed[boss]++;
						VSHA_SetBossStabs(client,(VSHA_GetBossStabs(boss)+1));
					}
					return Plugin_Changed;
				}
			}
			else
			{
				char classname[64];
				if(GetEdictClassname(attacker, classname, sizeof(classname)) && !strcmp(classname, "trigger_hurt", false))
				{
					Action action=Plugin_Continue;
					Call_StartForward(p_OnTriggerHurt);
					Call_PushCell(boss);
					Call_PushCell(attacker);
					float damage2=damage;
					Call_PushFloatRef(damage2);
					Call_Finish(action);
					if(action!=Plugin_Stop && action!=Plugin_Handled)
					{
						if(action==Plugin_Changed)
						{
							damage=damage2;
						}

						if(damage>1500.0)
						{
							damage=1500.0;
						}

						//if(!strcmp(currentmap, "arena_arakawa_b3", false) && damage>1000.0)
						//{
							//damage=490.0;
						//}
						//BossHealth[boss]-=RoundFloat(damage);
						int newBossHealth = VSHA_GetBossHealth(boss)-RoundFloat(damage);
						VSHA_SetBossHealth(boss,newBossHealth);
						//BossCharge[boss][0]+=damage*100.0/BossRageDamage[boss];
						float newBossRage = VSHA_GetBossRage(boss)+(damage*100.0/VSHA_GetDamage(boss));
						VSHA_SetBossRage(boss,newBossRage);
						if(VSHA_GetBossHealth(boss)<=0)  //Wat
						{
							damage*=5;
						}

						if(VSHA_GetBossRage(boss)>100.0)
						{
							//BossCharge[boss][0]=100.0;
							VSHA_SetBossRage(boss,100.0);
						}
						return Plugin_Changed;
					}
					else
					{
						return action;
					}
				}
			}

			if(BossCharge[boss][0]>100.0)
			{
				BossCharge[boss][0]=100.0;
			}
		}
		else
		{
			int index=(IsValidEntity(weapon) && weapon>MaxClients && attacker<=MaxClients ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : -1);
			if(index==307)  //Ullapool Caber
			{
				if(detonations[attacker]<allowedDetonations)
				{
					detonations[attacker]++;
					PrintHintText(attacker, "%t", "Detonations Left", allowedDetonations-detonations[attacker]);
					if(allowedDetonations-detonations[attacker])  //Don't reset their caber if they have 0 detonations left
					{
						SetEntProp(weapon, Prop_Send, "m_bBroken", 0);
						SetEntProp(weapon, Prop_Send, "m_iDetonated", 0);
					}
				}
			}

			if(IsValidClient(client, false) && TF2_GetPlayerClass(client)==TFClass_Soldier)  //TODO: LOOK AT THIS
			{
				if(damagetype & DMG_FALL)
				{
					int secondary=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
					if(secondary<=0 || !IsValidEntity(secondary))
					{
						damage/=10.0;
						return Plugin_Changed;
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action Timer_DisguiseBackstab(Handle timer, any userid)
{
	int client=GetClientOfUserId(userid);
	if(IsValidClient(client, false))
	{
		RandomlyDisguise(client);
	}
	return Plugin_Continue;
}
stock void RandomlyDisguise(int client)	//Original code was mecha's, but the original code is broken and this uses a better method now.
{
	if(IsValidClient(client) && IsPlayerAlive(client))
	{
		int disguiseTarget=-1;
		int team=GetClientTeam(client);

		Handle disguiseArray=CreateArray();
		for(int clientcheck; clientcheck<=MaxClients; clientcheck++)
		{
			if(IsValidClient(clientcheck) && GetClientTeam(clientcheck)==team && clientcheck!=client)
			{
				PushArrayCell(disguiseArray, clientcheck);
			}
		}

		if(GetArraySize(disguiseArray)<=0)
		{
			disguiseTarget=client;
		}
		else
		{
			disguiseTarget=GetArrayCell(disguiseArray, GetRandomInt(0, GetArraySize(disguiseArray)-1));
			if(!IsValidClient(disguiseTarget))
			{
				disguiseTarget=client;
			}
		}

		int class=GetRandomInt(0, 4);
		TFClassType classArray[]={TFClass_Scout, TFClass_Pyro, TFClass_Medic, TFClass_Engineer, TFClass_Sniper};
		CloseHandle(disguiseArray);

		if(TF2_GetPlayerClass(client)==TFClass_Spy)
		{
			TF2_DisguisePlayer(client, view_as<TFTeam>(team), classArray[class], disguiseTarget);
		}
		else
		{
			TF2_AddCondition(client, TFCond_Disguised, -1.0);
			SetEntProp(client, Prop_Send, "m_nDisguiseTeam", team);
			SetEntProp(client, Prop_Send, "m_nDisguiseClass", classArray[class]);
			SetEntProp(client, Prop_Send, "m_iDisguiseTargetIndex", disguiseTarget);
			SetEntProp(client, Prop_Send, "m_iDisguiseHealth", 200);
		}
	}
}

stock int LastBossIndex()
{
	for(int client=1; client<=MaxClients; client++)
	{
		if(!VSHA_IsBossPlayer(client))
		{
			return client;
		}
	}
	return 0;
}

/*
stock void FindBossArrayListIndex()
{
	int count = hArrayBossSubplugins.Length; //GetArraySize(hMyArray);
	for (int i = 0; i < count; i++)
	{
		StringMap MyStringMap = hArrayBossSubplugins.Get(i);
		if (GetBossSubPlugin(MyStringMap) == plugin) return MyStringMap;
	}
}*/
