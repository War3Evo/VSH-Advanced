#undef REQUIRE_EXTENSIONS
#tryinclude <steamtools>
#define REQUIRE_EXTENSIONS

#include <sourcemod>
#include <clientprefs>
#include <tf2attributes>
#include <morecolors>
#include <sdkhooks>
#include <vsha>

ArrayList hArrayBossSubplugins = null;	// List <Subplugin>
StringMap hTrieBossSubplugins = null;	// Map <Boss Name, Subplugin Handle>

enum VSHAError
{
	Error_None,				// All-Clear :>
	Error_InvalidName,			// Invalid name for Boss
	Error_AlreadyExists,			// Boss Already Exists....
	Error_SubpluginAlreadyRegistered,	// The plugin registering a boss already has a boss registered
}

// V A R I A B L E S =========================================================================

//Handles
Handle Storage[PLYR];

//ints
int iBossUserID[PLYR],		//USERID NUM OVER CLIENT INT
	iBoss[PLYR],		//THIS IS NOT THE USER, IT'S THE SPECIAL BOSS IDs
	iDifficulty[PLYR],
	iPresetBoss[PLYR],
	iBossHealth[PLYR],
	iBossMaxHealth[PLYR],
	iPlayerKilled[PLYR][2],	//0 - kill count, 1 - killing spree
	iBossesKilled[PLYR],
	iDamage[PLYR],
	iAirDamage[PLYR],
	iMarketed[PLYR],
	iStabbed[PLYR],
	iUberedTarget[PLYR],
	iLives[PLYR],		//lives can work for BOTH Bosses & for players, get creative!
	iHits[PLYR],		//How many times a player has been hit lol
	AmmoTable[2049],
	ClipTable[2049],
	HaleTeam = 3,
	OtherTeam = 2,
	iNextBossPlayer,
	iTotalBossHP,
	iHealthBar = -1,
	iRedAlivePlayers,
	iBluAlivePlayers,
	iPlaying = 0,
	TeamRoundCounter,
	RoundCount,
	timeleft;

//floats
float flCharge[PLYR], //SINGLE MEDIC-TAUNT/RAGE CHARGE, MAKE YOUR OWN CHARGE VARS IN YOUR OWN BOSS SUBPLUGINS
	flKillStreak[PLYR],
	flGlowTimer[PLYR],
	flHPTime;

//bools
bool Enabled,
	bIsBoss[PLYR], //EITHER IS BOSS OR NOT
	bInJump[PLYR],
	bNoTaunt[PLYR],
	bTenSecStart[2],
	PointType,
	PointReady,
	steamtools;

//================================================================================================

int tf_arena_use_queue, mp_teams_unbalance_limit, tf_arena_first_blood, mp_forcecamera;
float tf_scout_hype_pep_max;

public Plugin myinfo = {
	name = "Versus Saxton Hale Engine",
	author = "Diablo, Nergal, Chdata, Cookies, with special props to Powerlord + Flamin' Sarge",
	description = "Es Sexy-time beyechez",
	version = PLUGIN_VERSION,
	url = "https://github.com/War3Evo/VSH-Advanced"
};

//cvar Handles
ConVar bEnabled = null;
ConVar FirstRound = null;
ConVar MedigunReset = null;
ConVar AliveToEnable = null;
ConVar CountDownPlayerLimit = null;
ConVar CountDownHealthLimit = null;
ConVar LastPlayersTimerCountDown = null;
ConVar EnableEurekaEffect = null;
ConVar PointDelay = null;
ConVar QueueIncrement = null;
//ConVar FallDmgSoldier = null;
//ConVar DifficultyAmount = null;

//non-cvar Handles
Handle hBossHUD;
Handle hPlayerHUD;
Handle TimeLeftHUD = null;
Handle MiscHUD = null; //for various other HUD additions
//Handle CustomHUD = null;
Handle hdoorchecktimer = null;
Handle PointCookie = null;
Handle MusicTimer = null;
Handle DrawGameTimer = null;

//Forward Handles
Handle AddToDownloads;

public void OnPluginStart()
{
	hArrayBossSubplugins = new ArrayList();	//CreateArray();
	hTrieBossSubplugins = new StringMap();	//CreateTrie();

	LogMessage("==== Versus Saxton Hale Engine Initializing - v%s ====", PLUGIN_VERSION);
	bEnabled = CreateConVar("vshe_enabled", "1", "Enable the VSH Engine", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	FirstRound = CreateConVar("vshe_firstround", "1", "Enable first round for VSH Engine", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	MedigunReset = CreateConVar("vshe_medigunreset", "0.40", "default ubercharge for when mediguns reset", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	AliveToEnable = CreateConVar("vshe_alivetoenable", "3", "how many players left to enable cap", FCVAR_PLUGIN, true, 0.0, true, 16.0);
	CountDownPlayerLimit = CreateConVar("vshe_countdownplayerlimit", "3", "how many players must be left to start the final countdown timer", FCVAR_PLUGIN, true, 0.0, true, 16.0);
	CountDownHealthLimit = CreateConVar("vshe_countdownbosshealth", "5000", "how low boss health must be to start the final countdown timer", FCVAR_PLUGIN, true, 0.0, true, 999999.0);
	LastPlayersTimerCountDown = CreateConVar("vshe_finalcountdowntimer", "120", "how long the final countdown timer is", FCVAR_PLUGIN, true, 0.0, true, 99999.0);
	EnableEurekaEffect = CreateConVar("vshe_alloweureka", "1", "(dis)allows the eureka wrench from being used", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	PointDelay = CreateConVar("vshe_capturepointdelay", "10", "time in seconds the cap is delayed from enabling", FCVAR_PLUGIN, true, 0.0, true, 999.0);
	QueueIncrement = CreateConVar("vshe_queueincrement", "10", "by how much queue increments", FCVAR_PLUGIN, true, 1.0, true, 999.0);
	//FallDmgSoldier = CreateConVar("vshe_soldierfalldamage", "20.0", "divides fall damage by this number", FCVAR_PLUGIN, true, 0.0, true, 999.0);
	//DifficultyAmount = CreateConVar("vshe_difficultyamount", "3", "how many difficulty settings you want available for bosses to choose", FCVAR_PLUGIN, true, 0.0, true, 999.0);

	AddCommandListener(DoTaunt, "taunt");
	AddCommandListener(DoTaunt, "+taunt");
	AddCommandListener(CallMedVoiceMenu, "voicemenu");
	AddCommandListener(DoSuicide, "explode");
	AddCommandListener(DoSuicide, "kill");
	AddCommandListener(DoSuicide2, "jointeam");
	AddCommandListener(KillOwnShit, "destroy");

	HookEvent("teamplay_round_start", RoundStart);
	HookEvent("teamplay_round_win", RoundEnd);
	HookEvent("player_spawn", PlayerSpawn);
	//HookEvent("post_inventory_application", PlayerSpawn);
	HookEvent("player_chargedeployed", UberDeployed);
	HookEvent("rocket_jump", OnHookedEvent);
	HookEvent("rocket_jump_landed", OnHookedEvent);
	HookEvent("sticky_jump", OnHookedEvent);
	HookEvent("sticky_jump_landed", OnHookedEvent);
	HookEvent("player_death", OnHookedEvent);
	HookEvent("player_death", PlayerDeath, EventHookMode_Pre);
	HookEvent("player_hurt", PlayerHurt, EventHookMode_Pre);
	HookEvent("object_destroyed", Destroyed, EventHookMode_Pre);
	HookEvent("object_deflected", Deflected, EventHookMode_Pre);
	//HookEvent("player_changeclass", ChangeClass);

	RegConsoleCmd("sm_vsha_special", CommandMakeNextSpecial);

	RegConsoleCmd("sm_setboss", PickBossMenu);
	RegConsoleCmd("sm_haleboss", PickBossMenu);
	RegConsoleCmd("sm_vshaboss", PickBossMenu);
	RegConsoleCmd("sm_vsheboss", PickBossMenu);

	hBossHUD = CreateHudSynchronizer();
	hPlayerHUD = CreateHudSynchronizer();
	TimeLeftHUD = CreateHudSynchronizer();
	MiscHUD = CreateHudSynchronizer();

	PointCookie = RegClientCookie("vshe_queuepoints", "Amount of VSH Engine Queue points, the player has", CookieAccess_Protected);
	//LoadSubPlugins();
	AutoExecConfig(true, "VSH-Engine");

	for (int i = 1; i <= MaxClients; i++)
	{
		if ( !IsValidClient(i) ) continue;
		OnClientPutInServer(i);
	}
}

public void OnClientPutInServer(int client)
{
	//SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_PreThink, OnPreThink);
	Storage[client] = null;
	iBoss[client] = -1;
	iPresetBoss[client] = -1;
	bIsBoss[client] = false;
	iDifficulty[client] = 0;
	iDamage[client] = 0;
	iBossesKilled[client] = 0;
	iPlayerKilled[client][0] = 0;
	iPlayerKilled[client][1] = 1;
	iHits[client] = 0;
	bNoTaunt[client] = false;
}
public void OnClientDisconnect(int client)
{
	//SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKUnhook(client, SDKHook_PreThink, OnPreThink);
	iBoss[client] = -1;
	iPresetBoss[client] = -1;
	iDifficulty[client] = 0;
	iDamage[client] = 0;
	iBossesKilled[client] = 0;
	iPlayerKilled[client][0] = 0;
	iPlayerKilled[client][1] = 1;
	iHits[client] = 0;
	bNoTaunt[client] = false;
	if (IsValidEntity(client)) TF2Attrib_RemoveAll(client);
	if (Enabled)
	{
		if (bIsBoss[client])
		{
			switch ( CheckRoundState() )
			{
				case 2: SetClientQueuePoints(client, 0);
				case 1: ForceTeamWin(OtherTeam);
				case 0:
				{
					int tBoss;
					if (iNextBossPlayer > 0)
					{
						tBoss = iNextBossPlayer;
						iNextBossPlayer = -1;
					}
					else tBoss = FindNextBoss(bIsBoss);
					bIsBoss[tBoss] = true;
					iBossUserID[tBoss] = GetClientUserId(tBoss);
					Storage[tBoss] = Storage[client];
					if (GetClientTeam(tBoss) != HaleTeam) ForceTeamChange(tBoss, HaleTeam);
					PawnTimer(MakeBoss, 0.2, iBossUserID[tBoss]); //CreateTimer(0.1, MakeBoss, iBossUserID[tBoss]);
					CPrintToChat(tBoss, "{olive}[VSH Engine]{default} Surprise! You're on NOW!");
				}
			}
			bIsBoss[client] = false;
			CPrintToChatAll("{olive}[VSH Engine]{default} Boss just disconnected!");
			Storage[client] = null;
		}
		else
		{
			if ( IsClientInGame(client) )
			{
				if ( IsPlayerAlive(client) ) PawnTimer(CheckAlivePlayers, 0.2); //CreateTimer(0.1, CheckAlivePlayers);
				if ( client == FindNextBoss(bIsBoss) ) CreateTimer(1.0, Timer_SkipHalePanel, _, TIMER_FLAG_NO_MAPCHANGE);
			}
			if ( client == iNextBossPlayer ) iNextBossPlayer = -1;
		}
	}
}
public void OnMapStart()
{
	if ( IsVSHMap() )
	{
		Enabled = true;
		tf_arena_use_queue = GetConVarInt( FindConVar("tf_arena_use_queue") );
		mp_teams_unbalance_limit = GetConVarInt( FindConVar("mp_teams_unbalance_limit") );
		tf_arena_first_blood = GetConVarInt( FindConVar("tf_arena_first_blood") );
		mp_forcecamera = GetConVarInt( FindConVar("mp_forcecamera") );
		tf_scout_hype_pep_max = GetConVarFloat( FindConVar("tf_scout_hype_pep_max") );
		CacheDownloads();
		FindHealthBar();
#if defined _steamtools_included
		if (steamtools)
		{
			char gameDesc[64];
			Format(gameDesc, sizeof(gameDesc), "VS Saxton Hale Advanced v%s", PLUGIN_VERSION);
			Steam_SetGameDescription(gameDesc);
		}
#endif
		SetConVarInt(FindConVar("tf_arena_use_queue"), 0);
		SetConVarInt(FindConVar("mp_teams_unbalance_limit"), FirstRound.BoolValue ? 0 : 1); //GetConVarBool(FirstRound)
		SetConVarInt(FindConVar("tf_arena_first_blood"), 0);
		SetConVarInt(FindConVar("mp_forcecamera"), 0);
		SetConVarFloat(FindConVar("tf_scout_hype_pep_max"), 100.0);
#if defined DEBUG
		DEBUGPRINT1("VSH Engine::OnMapStart() **** Map is VSH map & VSHA is enabled! ****");
#endif
	}
	else
	{
		Enabled = false; //enforcing strict arena only
#if defined DEBUG
		DEBUGPRINT1("VSH Engine::OnMapStart() **** Plugin Disabled Cuz current map is not VSH/FF2 compatible ****");
		DEBUGPRINT2("{lime}VSH Engine::OnMapStart() **** Plugin Disabled Cuz current map is not VSH/FF2 compatible ****");
		DEBUGPRINT3("VSH Engine::OnMapStart() **** Plugin Disabled Cuz current map is not VSH/FF2 compatible ****");
#endif
	}
}
public void OnMapEnd()
{
	if ( Enabled )
	{
		SetConVarInt(FindConVar("tf_arena_use_queue"), tf_arena_use_queue);
		SetConVarInt(FindConVar("mp_teams_unbalance_limit"), mp_teams_unbalance_limit);
		SetConVarInt(FindConVar("tf_arena_first_blood"), tf_arena_first_blood);
		SetConVarInt(FindConVar("mp_forcecamera"), mp_forcecamera);
		SetConVarFloat(FindConVar("tf_scout_hype_pep_max"), tf_scout_hype_pep_max);
#if defined _steamtools_included
		if (steamtools) Steam_SetGameDescription("Team Fortress");
#endif
	}
}
public void OnLibraryAdded(const char[] name) //:D
{
#if defined _steamtools_included
	if (strcmp(name, "SteamTools", false) == 0) steamtools = true;
#endif
}
public void OnLibraryRemoved(const char[] name)
{
#if defined _steamtools_included
	if (strcmp(name, "SteamTools", false) == 0) steamtools = false;
#endif
}
public void CacheDownloads()
{
	Call_StartForward(AddToDownloads);
#if defined DEBUG
	DEBUGPRINT1("VSH Engine::CacheDownloads() **** AddToDownloads Forward Called ****");
	DEBUGPRINT3("VSH Engine::CacheDownloads() **** AddToDownloads Forward Called ****");
#endif
	Call_Finish();
	AddFileToDownloadsTable("sound/saxton_hale/9000.wav");
	PrecacheSound("saxton_hale/9000.wav", true);
	PrecacheSound("vo/announcer_am_capincite01.wav", true);
	PrecacheSound("vo/announcer_am_capincite03.wav", true);
	PrecacheSound("vo/announcer_am_capenabled01.wav", true);
	PrecacheSound("vo/announcer_am_capenabled02.wav", true);
	PrecacheSound("vo/announcer_am_capenabled03.wav", true);
	PrecacheSound("vo/announcer_am_capenabled04.wav", true);
	PrecacheSound("weapons/barret_arm_zap.wav", true);
	PrecacheSound("vo/announcer_ends_2min.wav", true);
	PrecacheSound("player/doubledonk.wav", true);
}
public Action KillOwnShit(int client, const char[] command, int argc)
{
	if (!Enabled || bIsBoss[client]) return Plugin_Continue;
	if (client && TF2_GetPlayerClass(client) == TFClass_Engineer && TF2_IsPlayerInCondition(client, TFCond_Taunting) && GetIndexOfWeaponSlot(client, TFWeaponSlot_Melee) == 589) return Plugin_Handled;
	return Plugin_Continue;
}
public Action RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	bool MakeEnabled = false;
	if (!bEnabled.BoolValue)
	{
#if defined _steamtools_included
		if (steamtools) Steam_SetGameDescription("Team Fortress");
#endif

#if defined DEBUG
		DEBUGPRINT1("VSH Engine::RoundStart() **** VSHA not Enabled ****");
#endif
		MakeEnabled = false;
		return Plugin_Continue;
	}
	else MakeEnabled = true;
	Enabled = MakeEnabled;
	if ( !Enabled )
	{
#if defined DEBUG
		DEBUGPRINT1("VSH Engine::RoundStart() **** Plugin is NOT Enabled! ****");
		DEBUGPRINT2("{lime}VSH Engine::RoundStart() **** Plugin is NOT Enabled! ****");
		DEBUGPRINT3("VSH Engine::RoundStart() **** Plugin is NOT Enabled! ****");
#endif
		return Plugin_Continue;
	}
	ClearTimer(MusicTimer);
	CheckArena();
	int i;
	iPlaying = 0;
	for (i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && GetClientTeam(i) > view_as<int>(TFTeam_Spectator))
		{
			//ForceTeamChange(i, OtherTeam);
			iDamage[i] = 0;
			bIsBoss[i] = false;
			iPlaying++;
		}
	}
#if defined DEBUG
	DEBUGPRINT1("VSH Engine::RoundStart() **** Player Loop finished! ****");
#endif
	if (GetClientCount() <= 1 || iPlaying < 2)
	{
		CPrintToChatAll("{olive}[VSH Engine]{default} Need more players to begin");
		Enabled = false;
		SetControlPoint(true);
		return Plugin_Continue;
	}
	if (hArrayBossSubplugins.Length < 1) //if (GetArraySize(hArrayBossSubplugins) < 1)
	{
		LogMessage("VSH Engine::RoundStart() **** No Boss Subplugins Loaded ****");
		Enabled = false;
		return Plugin_Continue;
	}

	SetConVarInt(FindConVar("mp_teams_unbalance_limit"), 0);

	int boss = -1;
	if ( IsClientValid(iNextBossPlayer) ) boss = iNextBossPlayer;
	else boss = FindNextBoss(bIsBoss);

	if (boss <= 0)
	{
		CPrintToChatAll("{olive}[VSH Engine]{default} Need more players to begin");
		Enabled = false;
		return Plugin_Continue;
	}

	iBossUserID[boss] = GetClientUserId(boss);
	bIsBoss[boss] = true;
	Storage[boss] = PickBossSpecial(iPresetBoss[boss]);
#if defined DEBUG
	DEBUGPRINT3("VSH Engine::PickBossSpecial() **** Boss subplugin has been chosen and player is set ****");
#endif

	Function FuncBossSelected = GetFunctionByName(Storage[boss], "VSHA_OnBossSelected");
	if (FuncBossSelected != nullfunc)
	{
#if defined DEBUG
		DEBUGPRINT1("VSH Engine::VSHA_RoundStart() **** Forward Called ****");
		DEBUGPRINT2("{lime}VSH Engine::VSHA_RoundStart() **** Forward Called ****");
		DEBUGPRINT3("VSH Engine::VSHA_RoundStart() **** Forward Called ****");
#endif
		Call_StartFunction(Storage[boss], FuncBossSelected);
		Call_PushCell(boss);
		Call_Finish();
	}
#if defined DEBUG
	else
	{
		DEBUGPRINT1("VSH Engine::VSHA_OnBossSelected() **** Forward Invalid/Not Called ****");
		DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossSelected() **** Forward Invalid/Not Called ****");
		DEBUGPRINT3("VSH Engine::VSHA_OnBossSelected() **** Forward Invalid/Not Called ****");
	}
#endif
#if defined DEBUG
	DEBUGPRINT1("VSH Engine::RoundStart() **** Found Player to be boss! ****");
#endif

	if ( GetTeamPlayerCount(HaleTeam) <= 0 || GetTeamPlayerCount(OtherTeam) <= 0 )
	{
		for (i = 1; i <= MaxClients; i++)
		{
			if ( IsValidClient(i) && GetClientTeam(i) > view_as<int>(TFTeam_Spectator) )
			{
				if (bIsBoss[i]) ForceTeamChange(i, HaleTeam);
				else ForceTeamChange(i, OtherTeam);
			}
		}
	}

	bTenSecStart[0] = true; bTenSecStart[1] = true;

	PawnTimer(tTenSecStart, 29.1, 0);
	PawnTimer(tTenSecStart, 60.1, 1);

	PawnTimer(BossStart, 9.1); //CreateTimer(9.1, TimerBossStart);
	PawnTimer(InitBoss, 0.2); //CreateTimer(0.1, TimerInitBoss);
	PawnTimer(BossResponse, 3.5); //CreateTimer(3.5, TimerBossResponse);
	PawnTimer(DoMessage, 9.6); //CreateTimer(9.6, MessageTimer);
	PointReady = false;

	for ( int entity = MaxClients+1; entity < MaxEntities; entity++ )
	{
		if ( !IsValidEdict(entity) ) continue;
		char classname[64]; GetEdictClassname(entity, classname, sizeof(classname));

		if ( !strcmp(classname, "func_regenerate") || !strcmp(classname, "func_respawnroomvisualizer") ) AcceptEntityInput(entity, "Disable");

		if ( !strcmp(classname, "obj_dispenser") )
		{
			SetVariantInt(OtherTeam);
			AcceptEntityInput(entity, "SetTeam");
			AcceptEntityInput(entity, "skin");
			SetEntProp(entity, Prop_Send, "m_nSkin", OtherTeam-2);
		}
		if ( !strcmp(classname, "mapobj_cart_dispenser") )
		{
			SetVariantInt(OtherTeam);
			AcceptEntityInput(entity, "SetTeam");
			AcceptEntityInput(entity, "skin");
		}
	}
	SearchForItemPacks();
	return Plugin_Continue;
}

public Action RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (!Enabled)
	{
#if defined DEBUG
		DEBUGPRINT1("VSH Engine::RoundEnd() **** RoundEnd - Plugin is Disabled ****");
		DEBUGPRINT2("{lime}VSH Engine::RoundEnd() **** RoundEnd - Plugin is Disabled ****");
#endif
		return Plugin_Continue;
	}
	TeamRoundCounter++;
	RoundCount++;
	int i;
	bool playedwinsound = false;
	for (i = 1; i <= MaxClients; i++)
	{
		if ( !IsValidClient(i) ) continue;
		if ( bIsBoss[i] )
		{
			if (event.GetInt("team") == HaleTeam && !playedwinsound)
			{
				Function FuncBossWon = GetFunctionByName(Storage[i], "VSHA_OnBossWin");
				if (FuncBossWon != nullfunc)
				{
#if defined DEBUG
					DEBUGPRINT1("VSH Engine::VSHA_OnBossWin() **** Forward Called ****");
					DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossWin() **** Forward Called ****");
#endif
					Call_StartFunction(Storage[i], FuncBossWon);
					Call_Finish();
				} //stop music here, put win sound
#if defined DEBUG
				else
				{
					DEBUGPRINT1("VSH Engine::VSHA_OnBossWin() **** Forward Invalid/Not Called ****");
					DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossWin() **** Forward Invalid/Not Called ****");
				}
#endif
				playedwinsound = true;
			}
			SetEntProp(i, Prop_Send, "m_bGlowEnabled", 0);
			flGlowTimer[i] = 0.0;
			if ( IsPlayerAlive(i) ) CPrintToChatAll("{olive}[VSH Engine]{default} %N had %i of %i", i, iBossHealth[i], iBossMaxHealth[i]);
			else
			{
				if (GetClientTeam(i) != HaleTeam) ForceTeamChange(i, HaleTeam);
			}
			bIsBoss[i] = false;
		}
		else // reset client shit heer
		{
		}
	}
	ClearTimer(MusicTimer);

	int top[3];
	iDamage[0] = 0;
	for (i = 1; i <= MaxClients; i++)
	{
		if ( iDamage[i] <= 0 ) continue;
		if ( iDamage[i] >= iDamage[top[0]] )
		{
			top[2] = top[1];
			top[1] = top[0];
			top[0] = i;
		}
		else if ( iDamage[i] >= iDamage[top[1]] )
		{
			top[2] = top[1];
			top[1] = i;
		}
		else if ( iDamage[i] >= iDamage[top[2]] )
		{
			top[2] = i;
		}
	}
	if ( iDamage[top[0]] > 9000 ) PawnTimer( TimerNineThousand, 1.0, TIMER_FLAG_NO_MAPCHANGE );
	//CreateTimer(1.0, TimerNineThousand, _, TIMER_FLAG_NO_MAPCHANGE);

	char first[32];
	if ( IsValidClient(top[0]) && (GetClientTeam(top[0]) == OtherTeam) ) GetClientName(top[0], first, 32);
	else
	{
		Format(first, sizeof(first), "---");
		top[0] = 0;
	}

	char second[32];
	if ( IsValidClient(top[1]) && (GetClientTeam(top[1]) == OtherTeam) ) GetClientName(top[1], second, 32);
	else
	{
		Format(second, sizeof(second), "---");
		top[1] = 0;
	}

	char third[32];
	if ( IsValidClient(top[2]) && (GetClientTeam(top[2]) == OtherTeam) ) GetClientName(top[2], third, 32);
	else
	{
		Format(third, sizeof(third), "---");
		top[2] = 0;
	}

        SetHudTextParams(-1.0, 0.3, 10.0, 255, 255, 255, 255);
        PrintCenterTextAll(""); //Should clear center text
	for (i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !(GetClientButtons(i) & IN_SCORE))
		{
			ShowHudText(i, -1, "Most Damage Dealt By:\n1)%i - %s\n2)%i - %s\n3)%i - %s\n\nDamage Dealt: %i\nScore for this round: %i", iDamage[top[0]], first, iDamage[top[1]], second, iDamage[top[2]], third, iDamage[i], RoundFloat(iDamage[i]/600.0));
		}
        }
	PawnTimer( CalcScores, 3.0, TIMER_FLAG_NO_MAPCHANGE );
	//CreateTimer(3.0, TimerCalcScores, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Continue;
}

public Action PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if (!Enabled) return Plugin_Continue;
	int client = GetClientOfUserId( event.GetInt("userid") );
	if ( client && IsClientInGame(client) && (CheckRoundState() > -1 && CheckRoundState() < 2) )
	{
		SetVariantString("");
		AcceptEntityInput(client, "SetCustomModel");
		if ( bIsBoss[client] ) PawnTimer(MakeBoss, 0.2, GetClientUserId(client)); //CreateTimer(0.1, MakeBoss, GetClientUserId(client));
		else
		{
			TF2_RemoveAllWeapons2(client);
			TF2_RegeneratePlayer(client);
			PawnTimer(EquipPlayers, 0.2, GetClientUserId(client)); //CreateTimer(0.1, EquipPlayers, GetClientUserId(client));
#if defined DEBUG
			DEBUGPRINT1("VSH Engine::PlayerSpawn() **** Non-Boss Player sent to Equip Timer! ****");
#endif
		}
	}
	if ( CheckRoundState() == 1 ) PawnTimer(CheckAlivePlayers, 0.2); //CreateTimer(0.5, CheckAlivePlayers);
	return Plugin_Continue;
}
public Action UberDeployed(Event event, const char[] name, bool dontBroadcast)
{
	if (!Enabled) return Plugin_Continue;
	int client = GetClientOfUserId( event.GetInt("userid") );
	//int target = GetClientOfUserId(event.GetInt("targetid"));
	if (IsPlayerAlive(client) )
	{
		int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
		if (GetItemQuality(medigun) == 10)
		{
			TF2_AddCondition(client, TFCond_HalloweenCritCandy, 0.5, client);
			int target = GetHealingTarget(client);
			if (IsValidClient(target) && IsPlayerAlive(target))
			{
				TF2_AddCondition(target, TFCond_HalloweenCritCandy, 0.5, client);
				iUberedTarget[client] = target;
			}
			else iUberedTarget[client] = -1;
			SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", 1.50);
			CreateTimer(0.4, Timer_Uber, EntIndexToEntRef(medigun), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	return Plugin_Continue;
}

public Action OnHookedEvent(Event event, const char[] name, bool dontBroadcast)
{
	SetRJFlag( GetClientOfUserId(event.GetInt("userid")), StrEqual(name, "rocket_jump", false) );
	return Plugin_Continue;
}
public Action PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if ( !Enabled || CheckRoundState() != 1 || (event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER) )
	{
#if defined DEBUG
		DEBUGPRINT1("VSH Engine::PlayerDeath() **** PlayerDeath Skipped ****");
		DEBUGPRINT2("{lime}VSH Engine::PlayerDeath() **** PlayerDeath Skipped ****");
#endif
		return Plugin_Continue;
	}
	int client = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	PawnTimer(CheckAlivePlayers, 0.2); //CreateTimer(0.1, CheckAlivePlayers);
	SetClientOverlay(client, "");
	if (!bIsBoss[client])
	{
		CPrintToChat( client, "{olive}[VSH Engine]{default} Damage dealt: {red}%i{default}. Score for this round: {red}%i{default}", iDamage[client], RoundFloat(iDamage[client]/600.0) );
		if (bIsBoss[attacker])
		{
			if ( GetGameTime() <= flKillStreak[attacker] ) iPlayerKilled[attacker][1]++;
			else iPlayerKilled[attacker][1] = 0;

			Function FuncPlayerKilled = GetFunctionByName(Storage[attacker], "VSHA_OnPlayerKilled");
			if (FuncPlayerKilled != nullfunc) /*purpose of this forward is for kill specific mechanics*/
			{
#if defined DEBUG
				DEBUGPRINT1("VSH Engine::VSHA_OnPlayerKilled() **** Forward Called ****");
				DEBUGPRINT2("{lime}VSH Engine::VSHA_OnPlayerKilled() **** Forward Called ****");
#endif
				Call_StartFunction(Storage[attacker], FuncPlayerKilled);
				Call_PushCell(attacker);
				Call_PushCell(client);
				Call_Finish();
			}
#if defined DEBUG
			else
			{
				DEBUGPRINT1("VSH Engine::VSHA_OnPlayerKilled() **** Forward Invalid/Not Called ****");
				DEBUGPRINT2("{lime}VSH Engine::VSHA_OnPlayerKilled() **** Forward Invalid/Not Called ****");
			}
#endif

			if ( iPlayerKilled[attacker][1] >= GetRandomInt(2, 3) )
			{
				Function FuncKillSpree = GetFunctionByName(Storage[attacker], "VSHA_OnKillingSpree");
/*purpose of this forward is for killing spree specific mechanics like killing spree boss sound clips*/
				if (FuncKillSpree != nullfunc)
				{
#if defined DEBUG
					DEBUGPRINT1("VSH Engine::VSHA_OnKillingSpree() **** Forward Called ****");
					DEBUGPRINT2("{lime}VSH Engine::VSHA_OnKillingSpree() **** Forward Called ****");
#endif
					Call_StartFunction(Storage[attacker], FuncKillSpree);
					Call_PushCell(attacker);
					Call_PushCell(client);
					Call_Finish();
				}
#if defined DEBUG
				else
				{
					DEBUGPRINT1("VSH Engine::VSHA_OnKillingSpree() **** Forward Invalid/Not Called ****");
					DEBUGPRINT2("{lime}VSH Engine::VSHA_OnKillingSpree() **** Forward Invalid/Not Called ****");
				}
#endif
				iPlayerKilled[attacker][1] = 0;
			}
			else flKillStreak[attacker] = GetGameTime() + 5.0;
			iPlayerKilled[attacker][0]++;
		}
		if (TF2_GetPlayerClass(client) == TFClass_Engineer) //Destroys sentry gun when Engineer dies before it.
		{
			FakeClientCommand(client, "destroy 2");
			int KillSentry = FindSentry(client);
			if ( KillSentry != -1 )
			{
				SetVariantInt(GetEntPropEnt(KillSentry, Prop_Send, "m_iMaxHealth")+1);
				AcceptEntityInput(KillSentry, "RemoveHealth");

				Event engieevent = CreateEvent("object_removed", true);
				engieevent.SetInt("userid", GetClientUserId(client));
				engieevent.SetInt("index", KillSentry);
				engieevent.Fire();
				AcceptEntityInput(KillSentry, "Kill");
			}
		}
	}
	else if (bIsBoss[client] && !bIsBoss[attacker])
	{
		iBossesKilled[attacker]++;
		if ( iBossHealth[client] < 0 ) iBossHealth[client] = 0;

		Function FuncBossKilled = GetFunctionByName(Storage[client], "VSHA_OnBossKilled");
		if (FuncBossKilled != nullfunc)
		{
#if defined DEBUG
			DEBUGPRINT1("VSH Engine::VSHA_OnBossKilled() **** Forward Called ****");
			DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossKilled() **** Forward Called ****");
#endif
			Call_StartFunction(Storage[client], FuncBossKilled);
			Call_PushCell(client);
			Call_PushCell(attacker);
			Call_Finish();
		}
#if defined DEBUG
		else
		{
			DEBUGPRINT1("VSH Engine::VSHA_OnBossKilled() **** Forward Invalid/Not Called ****");
			DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossKilled() **** Forward Invalid/Not Called ****");
		}
#endif
		UpdateHealthBar();
		iStabbed[client] = 0;
		iMarketed[client] = 0;
		bIsBoss[client] = false;
	}
	return Plugin_Continue;
}

public Action PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	if ( !Enabled )
	{
#if defined DEBUG
		DEBUGPRINT1("VSH Engine::PlayerHurt() **** PlayerHurt Skipped ****");
		DEBUGPRINT2("{lime}VSH Engine::PlayerHurt() **** PlayerHurt Skipped ****");
#endif
		return Plugin_Continue;
	}
	int client = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int damage = event.GetInt("damageamount");

	if (bIsBoss[client])
	{
		if (client == attacker) return Plugin_Continue;
		if (event.GetBool("minicrit") && event.GetBool("allseecrit")) event.SetBool("allseecrit", false);
		iBossHealth[client] -= damage;
		iDamage[attacker] += damage;

		int iHealers[MAXPLAYERS];
		int iHealerCount;
		int target;
		for (target = 1; target <= MaxClients; target++)
		{
			if ( IsValidClient(target) && IsPlayerAlive(target) && (GetHealingTarget(target) == attacker) )
			{
				iHealers[iHealerCount] = target;
				iHealerCount++;
			}
		}

		for (target = 0; target < iHealerCount; target++)
		{
			if (IsValidClient(iHealers[target]) && IsPlayerAlive(iHealers[target]))
			{
				if (damage < 10 || iUberedTarget[iHealers[target]] == attacker) iDamage[iHealers[target]] += damage;
				else iDamage[iHealers[target]] += damage/(iHealerCount+1);
			}
		}
		if (TF2_GetPlayerClass(attacker) == TFClass_Soldier && GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Primary) == 1104)
		{
			iAirDamage[attacker] += damage;
			SetEntProp(attacker, Prop_Send, "m_iDecapitations", iAirDamage[attacker]/200);
		}
	}
	else iDamage[attacker] += damage; //increment boss' dmg
	iHits[client]++;
	return Plugin_Continue;
}
public Action Destroyed(Event event, const char[] name, bool dontBroadcast)
{
	if (Enabled)
	{
		int attacker = GetClientOfUserId(event.GetInt("attacker"));
		if ( bIsBoss[attacker] ) //&& !GetRandomInt(0, 2) )
		{
			int building = event.GetInt("index");

			Function FuncBossKillToy = GetFunctionByName(Storage[attacker], "VSHA_OnBossKillBuilding");
			if (FuncBossKillToy != nullfunc)
			{
#if defined DEBUG
				DEBUGPRINT1("VSH Engine::VSHA_OnBossKillBuilding() **** Forward Called ****");
				DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossKillBuilding() **** Forward Called ****");
#endif
				Call_StartFunction(Storage[attacker], FuncBossKillToy);
				Call_PushCell(attacker);
				Call_PushCell(building);
				Call_Finish();
			}
#if defined DEBUG
			else
			{
				DEBUGPRINT1("VSH Engine::VSHA_OnBossKillBuilding() **** Forward Invalid/Not Called ****");
				DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossKillBuilding() **** Forward Invalid/Not Called ****");
			}
#endif
		}
	}
	return Plugin_Continue;
}
public Action Deflected(Event event, const char[] name, bool dontBroadcast)
{
	if ( !Enabled || event.GetInt("weaponid") ) return Plugin_Continue;
	int client = GetClientOfUserId(event.GetInt("ownerid"));
	if ( bIsBoss[client] )
	{
		int airblaster = GetClientOfUserId(event.GetInt("userid"));

		Function FuncBossAirBlst = GetFunctionByName(Storage[client], "VSHA_OnBossAirblasted");
		if (FuncBossAirBlst != nullfunc)
		{
#if defined DEBUG
			DEBUGPRINT1("VSH Engine::VSHA_OnBossAirblasted() **** Forward Called ****");
			DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossAirblasted() **** Forward Called ****");
#endif
			Call_StartFunction(Storage[client], FuncBossAirBlst);
			Call_PushCell(client);
			Call_PushCell(airblaster);
			Call_Finish();
		}
#if defined DEBUG
		else
		{
			DEBUGPRINT1("VSH Engine::VSHA_OnBossAirblasted() **** Forward Invalid/Not Called ****");
			DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossAirblasted() **** Forward Invalid/Not Called ****");
		}
#endif
	}
	return Plugin_Continue;
}
public void CheckArena()
{
	if (PointType) SetArenaCapEnableTime(view_as<float>(45+PointDelay.IntValue*(iPlaying-1)));
	else
	{
		SetArenaCapEnableTime(0.0);
		SetControlPoint(false);
	}
}
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
public void FindHealthBar()
{
	iHealthBar = FindEntityByClassname2(-1, "monster_resource");
	if (iHealthBar == -1)
	{
		iHealthBar = CreateEntityByName("monster_resource");
		if (iHealthBar != -1) DispatchSpawn(iHealthBar);
	}
}
public void tTenSecStart(int ofs)
{
	bTenSecStart[ofs] = false;
}
public void ResetUberCharge(int medigunid)
{
	int medigun = EntRefToEntIndex(medigunid);
	if ( IsValidEntity(medigun) ) SetMediCharge(medigun, GetMediCharge(medigun)+MedigunReset.FloatValue); //GetConVarFloat(MedigunReset)); //40.0
}
public void TimerNineThousand()
{
	EmitSoundToAll("saxton_hale/9000.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, nullvec, false, 0.0);
}
public int GetClientQueuePoints(int client)
{
	if (!IsValidClient(client)) return -1;
	if (!AreClientCookiesCached(client)) return -1;
	char strPoints[32]; GetClientCookie(client, PointCookie, strPoints, sizeof(strPoints));
	return StringToInt(strPoints);
}
public void SetClientQueuePoints(int client, int points)
{
	if (!IsValidClient(client)) return;
	if (IsFakeClient(client)) return;
	if (!AreClientCookiesCached(client)) return;
	char strPoints[32]; IntToString(points, strPoints, sizeof(strPoints));
	SetClientCookie(client, PointCookie, strPoints);
}
public Action Timer_CheckDoors(Handle hTimer)
{
	if ( (!Enabled && CheckRoundState() != -1) || (Enabled && CheckRoundState() != 1) )
	{
		//ClearTimer(hdoorchecktimer);
		return Plugin_Stop;
	}
	int ent = -1;
	while ( (ent = FindEntityByClassname2(ent, "func_door")) != -1 )
	{
		AcceptEntityInput(ent, "Open");
		AcceptEntityInput(ent, "Unlock");
	}
	return Plugin_Continue;
}
public Action CommandMakeNextSpecial(int client, int args)
{
	char arg[32], name[64];
	if (args < 1)
	{
		ReplyToCommand(client, "[VSH Engine] Usage: vsha_special <boss name>");
		return Plugin_Handled;
	}
	GetCmdArgString(arg, sizeof(arg));

	int count = hArrayBossSubplugins.Length; //GetArraySize(hArrayBossSubplugins);
	for (int i = 0; i < count; i++)
	{
		//GetTrieString(GetArrayCell(hArrayBossSubplugins, i), "BossName", name, sizeof(name));
		GetTrieString(hArrayBossSubplugins.Get(i), "BossName", name, sizeof(name));
		if (StrContains(arg, name, false) != -1)
		{
			iPresetBoss[FindNextBoss(bIsBoss)] = i;
			break;
		}
	}
	ReplyToCommand(client, "[VSH Engine] Set the next Special to %s", name);
	return Plugin_Handled;
}
public Action PickBossMenu(int client, int args)
{
	if (Enabled && IsClientInGame(client))
	{
		Menu pickboss = new Menu(MenuHandler_PickBoss);
		//Handle MainMenu = CreateMenu(MenuHandler_Perks);
		pickboss.SetTitle("[VSH Engine] Choose A Boss");
		int count = hArrayBossSubplugins.Length; //GetArraySize(hArrayBossSubplugins);
		for (int i = 0; i < count; i++)
		{
			//GetTrieString(GetArrayCell(hArrayBossSubplugins, i), "BossName", bossnameholder, sizeof(bossnameholder));
			char bossnameholder[32];
			GetTrieString(hArrayBossSubplugins.Get(i), "BossName", bossnameholder, sizeof(bossnameholder));
			pickboss.AddItem("pickclass", bossnameholder);
		}
		pickboss.Display(client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}
public int MenuHandler_PickBoss(Menu menu, MenuAction action, int client, int selection)
{
	char blahblah[32];
	menu.GetItem(selection, blahblah, sizeof(blahblah));
	if (action == MenuAction_Select)
        {
		char bossnameholder[32];
		GetTrieString(hArrayBossSubplugins.Get(selection), "BossName", bossnameholder, sizeof(bossnameholder));
		ReplyToCommand(client, "[VSH Engine] You selected %s as your boss!", bossnameholder);
		iPresetBoss[client] = selection;
        }
	else if (action == MenuAction_End) delete menu;
}
public Action Timer_DrawGame(Handle timer)
{
	if (iTotalBossHP < CountDownHealthLimit.IntValue || CheckRoundState() != 1) return Plugin_Stop;

	int time = timeleft;
	timeleft--;
	char timeDisplay[6];
	if (time/60 > 9) IntToString(time/60, timeDisplay, sizeof(timeDisplay));
	else Format(timeDisplay, sizeof(timeDisplay), "0%i", time/60);

	if (time%60 > 9) Format(timeDisplay, sizeof(timeDisplay), "%s:%i", timeDisplay, time%60);
	else Format(timeDisplay, sizeof(timeDisplay), "%s:0%i", timeDisplay, time%60);

	SetHudTextParams(-1.0, 0.17, 1.1, 255, 255, 255, 200);
	for (int client = 1; client <= MaxClients; client++)
	{
		if ( IsClientValid(client) && !(GetClientButtons(client) & IN_SCORE) ) ShowSyncHudText(client, TimeLeftHUD, timeDisplay);
	}
	switch ( time )
	{
		case 300:	EmitSoundToAll("vo/announcer_ends_5min.mp3");
		case 120:	EmitSoundToAll("vo/announcer_ends_2min.mp3");
		case 60:	EmitSoundToAll("vo/announcer_ends_60sec.mp3");
		case 30:	EmitSoundToAll("vo/announcer_ends_30sec.mp3");
		case 10:	EmitSoundToAll("vo/announcer_ends_10sec.mp3");
		case 1, 2, 3, 4, 5:
		{
			char sound[PATHX];
			Format(sound, PATHX, "vo/announcer_ends_%isec.mp3", time);
			EmitSoundToAll(sound);
		}
		case 0:
		{
			for (int client = 1; client <= MaxClients; client++)
			{
				if ( IsClientInGame(client) && IsPlayerAlive(client) ) ForcePlayerSuicide(client);
			}
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}
public void MusicPlay()
{
	if (CheckRoundState() != 1) return;
	char sound[PATHX];
	float time = -1.0;
	ClearTimer(MusicTimer);

	int client = GetRandomBossIndex();
	sound[0] = '\0';
	Function FuncMusicTimer = GetFunctionByName(Storage[client], "VSHA_OnMusic");
	if (FuncMusicTimer != nullfunc)
	{
#if defined DEBUG
		DEBUGPRINT1("VSH Engine::VSHA_OnMusic() **** Forward Called ****");
		DEBUGPRINT2("{lime}VSH Engine::VSHA_OnMusic() **** Forward Called ****");
		DEBUGPRINT3("VSH Engine::VSHA_OnMusic() **** Forward Called ****");
#endif
		Call_StartFunction(Storage[client], FuncMusicTimer);
		Call_PushStringEx(sound, sizeof(sound), 0, SM_PARAM_COPYBACK);
		Call_PushFloatRef(time);
		Call_Finish();
	}
#if defined DEBUG
	else
	{
		DEBUGPRINT1("VSH Engine::VSHA_OnMusic() **** Forward Invalid/Not Called ****");
		DEBUGPRINT2("{lime}VSH Engine::VSHA_OnMusic() **** Forward Invalid/Not Called ****");
		DEBUGPRINT3("VSH Engine::VSHA_OnMusic() **** Forward Invalid/Not Called ****");
	}
#endif
	if ( sound[0] != '\0' )
	{
	//      Format(sound, sizeof(sound), "#%s", sound);
		EmitSoundToAll(sound, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, nullvec, nullvec, false, 0.0);
	}
	if ( time != -1.0 )
	{
		DataPack pack = new DataPack();
		pack.WriteString(sound);
		MusicTimer = CreateDataTimer(time, TimerMusicTheme, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
	return;
}
public Action TimerMusicTheme(Handle timer, DataPack pack)
{
	if (Enabled && CheckRoundState() == 1)
	{
		pack.Reset();
		char sound[PATHX]; pack.ReadString( sound, sizeof(sound) );

		if (sound[0] != '\0') EmitSoundToAll(sound, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, nullvec, nullvec, false, 0.0);
	}
	else
	{
		ClearTimer(MusicTimer);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
public void CleanScreen(int userid)
{
	int client = GetClientOfUserId(userid);
	if ( client <= 0 || !bIsBoss[client] ) return;
	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT));
	ClientCommand(client, "r_screenoverlay \"\"");
	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & FCVAR_CHEAT);
	return;
}
public Action Timer_SkipHalePanel(Handle hTimer)
{
	int i, j, client;
	do
	{
		client = FindNextBoss(bIsBoss);
		if (IsValidClient(client) && !bIsBoss[client])
		{
			if (!IsFakeClient(client))
			{
				CPrintToChat(client, "{olive}[VSH Engine]{default} You are going to be Hale soon! Type {olive}/halenext{default} to check/reset your queue points.");
				if (i == 0) SkipHalePanelNotify(client);
			}
			i++;
		}
		j++;
	}
	while (i < 3 && j < PLYR);
	return Plugin_Continue;
}
public void SkipHalePanelNotify(int client)
{
	if (!Enabled || !IsValidClient(client) || IsVoteInProgress()) return;
	Handle panel = CreatePanel();
	char s[PATH];
	SetPanelTitle(panel, "[VSH Engine] You're the next Boss!");
	Format(s, sizeof(s), "You are going to be Hale soon! Type {olive}/halenext{default} to check/reset your queue points.\nAlternatively, use !resetq.");
	CRemoveTags(s, sizeof(s));
	ReplaceString(s, sizeof(s), "{olive}", "");
	ReplaceString(s, sizeof(s), "{default}", "");
	DrawPanelItem(panel, s);
	SendPanelToClient(panel, client, SkipHalePanelH, 30);
	CloseHandle(panel);
	return;
}
//(Handle:panel, client, MenuHandler:handler, time)
public int SkipHalePanelH(Menu menu, MenuAction action, int client, int selection)
{
	//for later
	//if ( IsValidAdmin(client, "b") ) Command_SetBoss( client, -1 );
	//else Command_SetSkill(client, -1);
	return;
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
public Action CommandQueuePoints(int client, int args)
{
	if ( !Enabled ) return Plugin_Continue;
	if (args != 2)
	{
		ReplyToCommand(client, "[VSH Engine] Usage: vsha_addpoints <target> <points>");
		return Plugin_Handled;
	}
	char s2[80];
	char targetname[PLATFORM_MAX_PATH];
	GetCmdArg(1, targetname, sizeof(targetname));
	GetCmdArg(2, s2, sizeof(s2));
	int points = StringToInt(s2);
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	if ( (target_count = ProcessTargetString(
			targetname,
			client,
			target_list,
			MAXPLAYERS,
			0,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0 )
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for (int i = 0; i < target_count; i++)
	{
		SetClientQueuePoints(target_list[i], GetClientQueuePoints(target_list[i])+points);
		LogAction(client, target_list[i], "\"%L\" added %d VSHA queue points to \"%L\"", client, points, target_list[i]);
	}
	ReplyToCommand(client, "[VSH Engine] Added %d queue points to %s", points, target_name);
	return Plugin_Handled;
}
public Action CommandBossSelect(int client, int args)
{
	if (!Enabled) return Plugin_Continue;
	if (args < 1)
	{
		ReplyToCommand(client, "[VSH] Usage: hale_select <target> [\"hidden\"]");
		return Plugin_Handled;
	}
	char s2[32];
	char targetname[32];
	GetCmdArg(1, targetname, sizeof(targetname));
	GetCmdArg(2, s2, sizeof(s2));
	if ( strcmp(targetname, "@me", false) == 0 && IsValidClient(client) ) iNextBossPlayer = client;
	else
	{
		int target = FindTarget(client, targetname);
		if (IsValidClient(target)) iNextBossPlayer = target;
	}
	return Plugin_Handled;
}
public int OnEntityCreated(int entity, const char[] classname)
{
	if ( StrContains(classname, "tf_weapon_") != -1 ) CreateTimer( 0.4, OnWeaponSpawned, EntIndexToEntRef(entity) );
}
public Action OnWeaponSpawned(Handle timer, any ref)
{
	int wep = EntRefToEntIndex(ref);
	if ( IsValidEntity(wep) && IsValidEdict(wep) )
	{
		int client = GetOwner(wep);
		if (!IsValidClient(client)) return Plugin_Continue;
		AmmoTable[wep] = GetWeaponAmmo(wep);
		ClipTable[wep] = GetWeaponClip(wep);
	}
	return Plugin_Continue;
}
public void OnConfigsExecuted()
{
	Enabled = bEnabled.BoolValue;
}
public void CalcScores()
{
	int j, damage;
	for (int i = 1; i <= MaxClients; i++)
	{
		if ( IsValidClient(i) && GetClientTeam(i) > view_as<int>(TFTeam_Spectator) )
		{
			damage = iDamage[i];

			Event aevent = CreateEvent("player_escort_score", true);
			aevent.SetInt("player", i);

			for (j = 0; damage-600 > 0; damage -= 600, j++) {}
			aevent.SetInt("points", j);
			aevent.Fire();

			if ( bIsBoss[i] ) SetClientQueuePoints(i, 0);
			else
			{
				CPrintToChat(i, "{olive}[VSH Engine]{default} You get %i+ queue points.", QueueIncrement.IntValue); //GetConVarInt(QueueIncrement));
				SetClientQueuePoints( i, (GetClientQueuePoints(i)+QueueIncrement.IntValue) );
			}
		}
	}
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

public Action ClientTimer(Handle hTimer)
{
	if (CheckRoundState() > 1 || CheckRoundState() == -1) return Plugin_Stop;
	for (int i = 1; i <= MaxClients; i++)
        {
		if (IsValidClient(i) && !bIsBoss[i] && GetClientTeam(i) == OtherTeam) continue;
		char wepclassname[32];
		//int killstreaker = iDamage[i] / 500;
		//if (killstreaker >= 1) SetEntProp(i, Prop_Send, "m_iKillStreak", killstreaker);
		PlayerHUD(i);
		TFClassType class = TF2_GetPlayerClass(i);
		int weapon = GetEntPropEnt(i, Prop_Send, "m_hActiveWeapon");
		int index = GetItemIndex(weapon);
		if (TF2_IsPlayerInCondition(i, TFCond_Cloaked))
		{
			if (GetClientCloakIndex(i) == 59)
			{
				if (TF2_IsPlayerInCondition(i, TFCond_DeadRingered)) TF2_RemoveCondition(i, TFCond_DeadRingered);
			}
			else TF2_AddCondition(i, TFCond_DeadRingered, 0.3);
		}
		if ( iRedAlivePlayers == 1 && !TF2_IsPlayerInCondition(i, TFCond_Cloaked) )
		{
			TF2_AddCondition(i, TFCond_HalloweenCritCandy, 0.3);
			int primary = GetPlayerWeaponSlot(i, TFWeaponSlot_Primary);
			if (class == TFClass_Engineer && weapon == primary && StrEqual(wepclassname, "tf_weapon_sentry_revenge", false)) SetEntProp(i, Prop_Send, "m_iRevengeCrits", 3);

			TF2_AddCondition(i, TFCond_Buffed, 0.3);

			int boss = GetRandomBossIndex();
			Function FuncLastSurvivorLoop = GetFunctionByName(Storage[boss], "VSHA_OnLastSurvivorLoop");
			if (FuncLastSurvivorLoop != nullfunc)
			{
#if defined DEBUG
				DEBUGPRINT1("VSH Engine::VSHA_OnLastSurvivorLoop() **** Forward Called ****");
				DEBUGPRINT2("{lime}VSH Engine::VSHA_OnLastSurvivorLoop() **** Forward Called ****");
#endif
				Call_StartFunction(Storage[boss], FuncLastSurvivorLoop);
				Call_PushCell(i);
				Call_Finish();
			}
#if defined DEBUG
			else
			{
				DEBUGPRINT1("VSH Engine::VSHA_OnLastSurvivorLoop() **** Forward Invalid/Not Called ****");
				DEBUGPRINT2("{lime}VSH Engine::VSHA_OnLastSurvivorLoop() **** Forward Invalid/Not Called ****");
			}
#endif
			//if (bAllowSuperWeap && HaleHealth >= 7000) PickSuperWeapon(i, -1); later
			continue;
		}
		if ( iRedAlivePlayers == 2 && !TF2_IsPlayerInCondition(i, TFCond_Cloaked) ) TF2_AddCondition(i, TFCond_Buffed, 0.3);

		//==============================	C R I T S  P A R T S	   =============================================
		TFCond cond = TFCond_HalloweenCritCandy;
		if (TF2_IsPlayerInCondition(i, TFCond_CritCola) && (class == TFClass_Scout || class == TFClass_Heavy))
		{
			TF2_AddCondition(i, cond, 0.3);
			continue;
		}
		bool EnableCrits[2] = {false, false}; //0 - minicrits, 1 - full crits
		for (int e = 1; e <= MaxClients; e++)
		{
			if ( (0 < e && e <= MaxClients) && IsPlayerAlive(e) && GetHealingTarget(e) == i )
			{
				EnableCrits[0] = true;
				break;
			}
		}
		if (weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Melee))
		{
			//slightly longer check but makes sure that any weapon that can backstab will not crit (e.g. Saxxy)
			if (strcmp(wepclassname, "tf_weapon_knife", false) != 0 && index != 416) EnableCrits[1] = true;
		}
		switch (index)
		{
			case 305, 1079, 1081, 56, 16, 203, 58, 1083, 1105, 1100, 1005, 1092, 812, 833, 997, 39, 351, 740, 588, 595: //Critlist
			{
				int flindex = GetIndexOfWeaponSlot(i, TFWeaponSlot_Primary);
				// No crits if using phlog
				if (TF2_GetPlayerClass(i) == TFClass_Pyro && flindex == 594) EnableCrits[1] = false;
				else EnableCrits[1] = true;
			}
			case 22, 23, 160, 209, 294, 449, 773:
			{
				EnableCrits[1] = true;
				if (class == TFClass_Scout && cond == TFCond_HalloweenCritCandy) cond = TFCond_Buffed;
			}
			case 656:
			{
				EnableCrits[1] = true;
				cond = TFCond_Buffed;
			}
		}
		if (index == 16 && EnableCrits[1] && IsValidEntity(FindPlayerBack(i, { 642 }, 1))) EnableCrits[1] = false;
		switch (class)
		{
			case TFClass_Spy:
			{
				if (weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Primary))
				{
					if (!TF2_IsPlayerCritBuffed(i) && !TF2_IsPlayerInCondition(i, TFCond_Buffed) && !TF2_IsPlayerInCondition(i, TFCond_Cloaked) && !TF2_IsPlayerInCondition(i, TFCond_Disguised) && !GetEntProp(i, Prop_Send, "m_bFeignDeathReady"))
					{
						TF2_AddCondition(i, TFCond_CritCola, 0.3);
					}
				}
			}
			case TFClass_Engineer:
			{
				if (weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Primary) && StrEqual(wepclassname, "tf_weapon_sentry_revenge", false))
				{
					int sentry = FindSentry(i);
					if (IsValidEntity(sentry))
					{
						int TargettedBoss = GetEntPropEnt(sentry, Prop_Send, "m_hEnemy");
						if (bIsBoss[TargettedBoss])
						{
							SetEntProp(i, Prop_Send, "m_iRevengeCrits", 3);
							TF2_AddCondition(i, TFCond_Kritzkrieged, 0.3);
						}
					}
					else
					{
						if (GetEntProp(i, Prop_Send, "m_iRevengeCrits")) SetEntProp(i, Prop_Send, "m_iRevengeCrits", 0);
						else if (TF2_IsPlayerInCondition(i, TFCond_Kritzkrieged) && !TF2_IsPlayerInCondition(i, TFCond_Healing))
						{
							TF2_RemoveCondition(i, TFCond_Kritzkrieged);
						}
					}
				}
			}
			case TFClass_Medic:
			{
				if (weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary))
				{
					int healtarget = GetHealingTarget(i);
					if (IsValidClient(healtarget) && TF2_GetPlayerClass(healtarget) == TFClass_Scout)
					{
						TF2_AddCondition(i, TFCond_SpeedBuffAlly, 0.3);
					}
				}
			}
			case TFClass_DemoMan:
			{
				if (!IsValidEntity(GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary)))
				{
					EnableCrits[1] = true;
					/*if (!bDemoShieldCrits &&GetEntPropEnt(i, Prop_Send, "m_hActiveWeapon") != GetPlayerWeaponSlot(i, TFWeaponSlot_Melee)) cond = TFCond_Buffed;*/
				}
			}
		}
		if (EnableCrits[1])
		{
			TF2_AddCondition(i, cond, 0.3);
			if (EnableCrits[0] && cond != TFCond_Buffed) TF2_AddCondition(i, TFCond_Buffed, 0.3);
		}
	}
	return Plugin_Continue;
}
public Action Timer_Uber(Handle timer, any medigunid)
{
	int medigun = EntRefToEntIndex(medigunid);
	if (IsValidEntity(medigun) && CheckRoundState() == 1)
	{
		int medic = GetOwner(medigun);
		if (IsValidClient(medic) && IsPlayerAlive(medic) && GetEntPropEnt(medic, Prop_Send, "m_hActiveWeapon") == medigun)
		{
			int target = GetHealingTarget(medic);
			if ( GetMediCharge(medigun) > 0.05 )
			{
				/*TF2_AddCondition(medic, TFCond_HalloweenCritCandy, 0.5); what's the point in giving the ubering medic crits?*/
				if (IsValidClient(target) && IsPlayerAlive(target))
				{
					TF2_AddCondition(target, TFCond_HalloweenCritCandy, 0.5);
					iUberedTarget[medic] = target;

					int boss = GetRandomBossIndex();
					Function FuncHitUber = GetFunctionByName(Storage[boss], "VSHA_OnUberTimer");
					if (FuncHitUber != nullfunc)
					{
#if defined DEBUG
						DEBUGPRINT1("VSH Engine::VSHA_OnUberTimer() **** Forward Called ****");
						DEBUGPRINT2("{lime}VSH Engine::VSHA_OnUberTimer() **** Forward Called ****");
#endif
						Call_StartFunction(Storage[boss], FuncHitUber);
						Call_PushCell(medic);
						Call_PushCell(target);
						Call_Finish();
					}
#if defined DEBUG
					else
					{
						DEBUGPRINT1("VSH Engine::VSHA_OnUberTimer() **** Forward Invalid/Not Called ****");
						DEBUGPRINT2("{lime}VSH Engine::VSHA_OnUberTimer() **** Forward Invalid/Not Called ****");
					}
#endif
				}
				else iUberedTarget[medic] = -1;
			}
		}
		if ( GetMediCharge(medigun) <= 0.05 )
		{
			PawnTimer(ResetUberCharge, 3.0, EntIndexToEntRef(medigun)); //CreateTimer(3.0, ResetUberCharge, EntIndexToEntRef(medigun));
			return Plugin_Stop;
		}
	}
	else return Plugin_Stop;
	return Plugin_Continue;
}
public void CheckAlivePlayers()
{
	if ( CheckRoundState() == 2 ) return;
	iRedAlivePlayers = 0, iBluAlivePlayers = 0;
	for (int client = 1; client <= MaxClients; client++)
	{
		if ( IsClientInGame(client) && IsPlayerAlive(client) )
		{
			if (GetClientTeam(client) == OtherTeam) iRedAlivePlayers++;
			else if (GetClientTeam(client) == HaleTeam) iBluAlivePlayers++;
		}
	}
#if defined DEBUG
	DEBUGPRINT1("VSH Engine::CheckAlivePlayers() **** Players Looped ****");
#endif
	if (iRedAlivePlayers <= 0) ForceTeamWin(HaleTeam);
	else if (iRedAlivePlayers == 1 && iBluAlivePlayers)
	{
		int boss = GetRandomBossIndex();
		Function FuncLastSurvivor = GetFunctionByName(Storage[boss], "VSHA_OnLastSurvivor");
		if (FuncLastSurvivor != nullfunc)
		{
#if defined DEBUG
			DEBUGPRINT1("VSH Engine::VSHA_OnLastSurvivor() **** Forward Called ****");
			DEBUGPRINT2("{lime}VSH Engine::VSHA_OnLastSurvivor() **** Forward Called ****");
#endif
			Call_StartFunction(Storage[boss], FuncLastSurvivor);
			Call_Finish();
		}
#if defined DEBUG
		else
		{
			DEBUGPRINT1("VSH Engine::VSHA_OnLastSurvivor() **** Forward Invalid/Not Called ****");
			DEBUGPRINT2("{lime}VSH Engine::VSHA_OnLastSurvivor() **** Forward Invalid/Not Called ****");
		}
#endif
		/*char message[PATH];
		for (int boss = 1; bIsBoss[boss]; boss++)
		{
			if (IsValidClient(boss)) Format(message, sizeof(message), "%s\n%N's Health is %i of %i", message, boss, iBossHealth[boss], iBossMaxHealth[boss]);
		}
		for (int target = 1; target <= MaxClients; target++)
		{
			if (IsValidClient(target)) PrintCenterText(target, message);
		}
		decl String:sound[PLATFORM_MAX_PATH];
		if(RandomSound("sound_lastman", sound, PLATFORM_MAX_PATH))
		{
			EmitSoundToAll(sound);
			EmitSoundToAll(sound);
		}*/
	}
	else if ( !PointType && (iRedAlivePlayers <= AliveToEnable.IntValue) && !PointReady ) //GetConVarInt(AliveToEnable)
	{
		if (iRedAlivePlayers == AliveToEnable.IntValue) //GetConVarInt(AliveToEnable))
		{
			char sound[PATH];
			if (GetRandomInt(0, 1))
			{
				Format(sound, sizeof(sound), "vo/announcer_am_capenabled0%i.wav", GetRandomInt(1, 4));
				EmitSoundToAll(sound);
			}
			else
			{
				int i = GetRandomInt(1, 4);
				if ( !(i % 2) ) i--;
				Format(sound, sizeof(sound), "vo/announcer_am_capincite0%i.wav", i);
				EmitSoundToAll(sound);
			}
		}
		SetControlPoint(true);
		PointReady = true; //:>
#if defined DEBUG
		DEBUGPRINT1("VSH Engine::CheckAlivePlayers() **** Control Point Control Enabled ****");
#endif
	}
	if ( iRedAlivePlayers <= CountDownPlayerLimit.IntValue &&
		iTotalBossHP > CountDownHealthLimit.IntValue &&
		LastPlayersTimerCountDown.IntValue > 1 && !DrawGameTimer )
	{
		if (FindEntityByClassname2(-1, "team_control_point") != -1)
		{
			timeleft = LastPlayersTimerCountDown.IntValue; //GetConVarInt(LastPlayersTimerCountDown);
			DrawGameTimer = CreateTimer(1.0, Timer_DrawGame, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
#if defined DEBUG
			DEBUGPRINT1("VSH Engine::CheckAlivePlayers() **** Final Countdown Created ****");
#endif
		}
	}
	return;
}
public Action TF2Items_OnGiveNamedItem(int client, char[] classname, int iItemDefinitionIndex, Handle &hItem)
{
	if (!Enabled || bIsBoss[client]) return Plugin_Continue;
	switch ( iItemDefinitionIndex )
	{
		case 40: //backburner
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "165 ; 1.0");
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 349: //sun on a stick
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "208 ; 1");
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 648: //wrap assassin
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "279 ; 2.0");
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 224: //Letranger
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "166 ; 15 ; 1 ; 0.8", true);
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 225, 574: //YER
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "155 ; 1 ; 160 ; 1", true);
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 232, 401: // Bushwacka + Shahanshah
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "236 ; 1");
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 226: // The Battalion's Backup
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "252 ; 0.25 ; 125 -20"); //125 ; -10
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 305, 1079: // Medic Xbow
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "17 ; 0.12 ; 2 ; 1.45 ; 6 ; 1.5"); // ; 266 ; 1.0");
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 56, 1005, 1092: // Huntsman
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "2 ; 1.5 ; 76 ; 2.0");
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 38, 457: // Axetinguisher
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "", true);
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 43, 239, 1084, 1100: //gru
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "107 ; 1.65 ; 1 ; 0.5 ; 128 ; 1 ; 191 ; -7", true);
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 415: //reserve shooter
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "179 ; 1 ; 265 ; 999.0 ; 178 ; 0.6 ; 2 ; 1.1 ; 3 ; 0.66", true);
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
	}
	if (TF2_GetPlayerClass(client) == TFClass_Soldier)
	{
		Handle hItemOverride = null;
		if ( !strncmp(classname, "tf_weapon_rocketlauncher", 24, false) )
		{
			switch (iItemDefinitionIndex)
			{
				case 127: hItemOverride = PrepareItemHandle(hItem, _, _, "265 ; 999.0 ; 179 ; 1.0");
				default: hItemOverride = PrepareItemHandle(hItem, _, _, "265 ; 999.0");
			}
		}
		if (hItemOverride != null)
		{
			hItem = hItemOverride;
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}
public void EquipPlayers(int clientid)
{
	int client = GetClientOfUserId(clientid);
	if ( client <= 0 || !IsPlayerAlive(client) || CheckRoundState() == 2) return;

	if (IsValidEntity(client)) TF2Attrib_RemoveAll(client);
	if (GetClientTeam(client) != OtherTeam)
	{
		ForceTeamChange(client, OtherTeam);
		TF2_RegeneratePlayer(client); // Added fix by Chdata to correct team colors
	}
	int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	int index = -1;
	if (IsValidEdict(weapon) && IsValidEntity(weapon))
	{
		index = GetItemIndex(weapon);
		switch (index)
		{
			case 588:
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Primary);
				weapon = SpawnWeapon(client, "tf_weapon_shotgun_primary", 415, 10, 6, "265 ; 999.0 ; 179 ; 1.0 ; 178 ; 0.6 ; 2 ; 1.1 ; 3 ; 0.66");
			}
			case 237:
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Primary);
				weapon = SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 1, 0, "265 ; 999.0");
				SetWeaponAmmo(weapon, 20);
			}
			case 17, 204, 36, 412:
			{
				if (GetItemQuality(weapon) != 10)
				{
					TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Primary);
					SpawnWeapon(client, "tf_weapon_syringegun_medic", 36, 1, 10, "17 ; 0.05 ; 144 ; 1");
				}
			}
		}
	}
	weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if (IsValidEdict(weapon) && IsValidEntity(weapon))
	{
		index = GetItemIndex(weapon);
		switch (index)
		{
			case 57, 231:
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Secondary);
				weapon = SpawnWeapon(client, "tf_weapon_smg", 16, 1, 0, "");
			}
			case 265:
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Secondary);
				weapon = SpawnWeapon(client, "tf_weapon_pipebomblauncher", 20, 1, 0, "");
				SetWeaponAmmo(weapon, 24);
			}
			case 735, 736, 810, 831, 933, 1080, 1102: //NAILGUN FOR SAPPER, trust me it's more useful........
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Secondary);
				weapon = SpawnWeapon(client, "tf_weapon_handgun_scout_secondary", 23, 5, 10, "280 ; 5 ; 6 ; 0.7 ; 2 ; 0.66 ; 4 ; 4.167 ; 78 ; 8.333 ; 137 ; 6.0");
				SetWeaponAmmo(weapon, (GetMaxAmmo(client, 0)*200/GetMaxAmmo(client, 0)));
			}
			case 39, 351, 1081:
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Secondary);
				weapon = SpawnWeapon(client, "tf_weapon_flaregun", index, 5, 10, "25 ; 0.5 ; 207 ; 1.33 ; 144 ; 1.0 ; 58 ; 3.2");
				SetWeaponAmmo(weapon, 16);
			}
		}
	}
	if (IsValidEntity(FindPlayerBack(client, { 57 , 231 }, 2)))
	{
		RemovePlayerBack(client, { 57 , 231 }, 2);
		weapon = SpawnWeapon(client, "tf_weapon_smg", 16, 1, 0, "");
	}
	weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if (IsValidEdict(weapon) && IsValidEntity(weapon))
	{
		index = GetItemIndex(weapon);
		switch (index)
		{
			case 331:
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Melee);
				weapon = SpawnWeapon(client, "tf_weapon_fists", 195, 1, 6, "");
			}
			case 357: CreateTimer(1.0, Timer_RemoveHonorBound, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			case 589:
			{
				if ( !EnableEurekaEffect.BoolValue ) //!GetConVarBool(EnableEurekaEffect))
				{
					TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Melee);
					weapon = SpawnWeapon(client, "tf_weapon_wrench", 7, 1, 0, "");
				}
			}
		}
	}
	weapon = GetPlayerWeaponSlot(client, 4);
	if (IsValidEdict(weapon) && IsValidEntity(weapon) && GetItemIndex(weapon) == 60)
	{
		TF2_RemoveWeaponSlot2(client, 4);
		weapon = SpawnWeapon(client, "tf_weapon_invis", 30, 1, 0, "");
	}
	TFClassType equip = TF2_GetPlayerClass(client);
	switch (equip)
	{
		case TFClass_Medic:
		{
			weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
			int mediquality = (IsValidEdict(weapon) && IsValidEntity(weapon) ? GetItemQuality(weapon) : -1);
			if (mediquality != 10)
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Secondary);
				weapon = SpawnWeapon(client, "tf_weapon_medigun", 998, 5, 10, "18 ; 0.0 ; 10 ; 1.25 ; 178 ; 0.75 ; 144 ; 2.0");
//200 ; 1 for area of effect healing  ; 178 ; 0.75 Faster switch-to ; 14 ; 0.0 perm overheal
				SetMediCharge(weapon, 0.41);
			}
		}
		default: TF2Attrib_SetByDefIndex( client, 57, float(GetClientHealth(client)/50) ); //make by cvar
	}
	return;
}
public Action Timer_RemoveHonorBound(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client) && IsPlayerAlive(client))
	{
		int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		int index = GetItemIndex(weapon);
		int active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		char classname[64]; GetEdictClassname(active, classname, sizeof(classname));
		if (index == 357 && active == weapon && strcmp(classname, "tf_weapon_katana", false) == 0)
		{
			SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
			if (GetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy") < 1) SetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
		}
	}
	return Plugin_Continue;
}
public void OnPreThink(int client)
{
	if (Enabled)
	{
		if (IsNearSpencer(client) && TF2_IsPlayerInCondition(client, TFCond_Cloaked))
		{
			float cloak = GetEntPropFloat(client, Prop_Send, "m_flCloakMeter")-0.5; //PUT CVAR HEER
			if (cloak < 0.0) cloak = 0.0;
			SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", cloak);
		}
	}
}
public void PlayerHUD(int client)
{
	if (GetClientButtons(client) & IN_SCORE) return;
	TFClassType tfclass = TF2_GetPlayerClass(client);
	if (!IsClientObserver(client) && IsPlayerAlive(client))
	{
		switch (tfclass)
		{
			case TFClass_Spy:
			{
				if (GetClientCloakIndex(client) == 59)
				{
					int drstatus = TF2_IsPlayerInCondition(client, TFCond_Cloaked) ? 2 : GetEntProp(client, Prop_Send, "m_bFeignDeathReady") ? 1 : 0;
					char s[32];
					switch (drstatus)
					{
						case 1:
						{
							SetHudTextParams(-1.0, 0.83, 0.35, 90, 255, 90, 255, 0, 0.0, 0.0, 0.0);
							Format(s, sizeof(s), "Status: Feign-Death Ready");
						}
						case 2:
						{
							SetHudTextParams(-1.0, 0.83, 0.35, 255, 64, 64, 255, 0, 0.0, 0.0, 0.0);
							Format(s, sizeof(s), "Status: Dead-Ringered");
						}
						default:
						{
							SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.0, 0.0, 0.0);
							Format(s, sizeof(s), "Status: Inactive");
						}
					}
					ShowSyncHudText(client, MiscHUD, "%s", s);
				}
	    		}
			case TFClass_Medic:
			{
				int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
				if (GetItemQuality(medigun) == 10)
				{
					SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.2, 0.0, 0.1);
					int charge = RoundToFloor(GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel")*100);
					ShowSyncHudText(client, MiscHUD, "ÃœberCharge: %i%", charge);
				}
			}
			case TFClass_Soldier:
			{
				if (GetIndexOfWeaponSlot(client, TFWeaponSlot_Primary) == 1104)
				{
					SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.2, 0.0, 0.1);
					ShowSyncHudText(client, MiscHUD, "Air-Strike Damage: %i", iAirDamage[client]);
				}
			}
		}
		SetHudTextParams(-1.0, 0.88, 1.0, 90, 255, 90, 200, 0, 0.0, 0.0, 0.0);
		ShowSyncHudText(client, hPlayerHUD, "[Damage]: {%i}", iDamage[client]);
	}
	else if ( IsClientObserver(client) || !IsPlayerAlive(client) )
	{
		SetHudTextParams(-1.0, 0.88, 1.0, 90, 255, 90, 200, 0, 0.0, 0.0, 0.0);
		int spec = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
		if (IsValidClient(spec)) ShowSyncHudText(client, hPlayerHUD, "[Damage]: {%i} | [%N's Damage]: {%i}", iDamage[client], spec, iDamage[spec]);
		else ShowSyncHudText(client, hPlayerHUD, "[Damage]: {%i}", iDamage[client]);
	}
}
public bool GetRJFlag(int client)
{
	return (IsValidClient(client, false) && IsPlayerAlive(client) ? bInJump[client] : false);
}
public void SetRJFlag(int client, bool bState)
{
	if (IsValidClient(client, false)) bInJump[client] = bState;
}
public bool OnlyScoutsLeft()
{
	for (int client; client <= MaxClients; client++)
	{
		if (IsValidClient(client) && IsPlayerAlive(client) && !bIsBoss[client])
		{
			if (TF2_GetPlayerClass(client) != TFClass_Scout) break;
			return true;
		}
	}
	return false;
}
public int CountScoutsLeft()
{
	int scunts = 0;
	for (int client; client <= MaxClients; client++)
	{
		if (IsValidClient(client) && IsPlayerAlive(client) && !bIsBoss[client])
		{
			if (TF2_GetPlayerClass(client) != TFClass_Scout) continue;
			scunts++;
		}
	}
	return scunts;
}
public Action BossTimer(Handle timer)
{
	if ( !Enabled || CheckRoundState() == 2 ) return Plugin_Stop;
	for ( int client = 1; client <= MaxClients; client++ )
	{
		if ( IsValidClient(client) && IsPlayerAlive(client) && bIsBoss[client] )
		{
			SetEntityHealth(client, iBossHealth[client]);
			ZeroPointTwoSecondThink(client);
			BossHUD(client);
			SetClientGlow(client, -0.2, _, flGlowTimer[client]);
		}
	}
	flHPTime -= 0.2;
	if ( flHPTime < 0.0 ) flHPTime = 0.0;
	UpdateHealthBar();
	return Plugin_Continue;
}
public void ZeroPointTwoSecondThink(int client)
{
	Function FuncBossTimer = GetFunctionByName(Storage[client], "VSHA_OnBossTimer");
	if (FuncBossTimer != nullfunc)
	{
#if defined DEBUG
		DEBUGPRINT1("VSH Engine::VSHA_OnBossTimer() **** Forward Called ****");
		DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossTimer() **** Forward Called ****");
		DEBUGPRINT3("VSH Engine::VSHA_OnBossTimer() **** Forward Called ****");
#endif
		Call_StartFunction(Storage[client], FuncBossTimer);
		Call_PushCell(client);
		Call_Finish();
	}
#if defined DEBUG
	else
	{
		DEBUGPRINT1("VSH Engine::VSHA_OnBossTimer() **** Forward Invalid/Not Called ****");
		DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossTimer() **** Forward Invalid/Not Called ****");
		DEBUGPRINT3("VSH Engine::VSHA_OnBossTimer() **** Forward Invalid/Not Called ****");
	}
#endif
	return;
}

public void BossStart()
{
	iPlaying = 0;
	int client;
	for (client = 1; client <= MaxClients; client++) //loop clients first for health calculation
	{
		if ( !IsClientValid(client) || !IsPlayerAlive(client) || !bIsBoss[client]) continue;

		iPlaying++;
		SetEntityMoveType(client, MOVETYPE_WALK); // >_>
		PawnTimer(EquipPlayers, 0.2, GetClientUserId(client)); //SUIT UP!
		//CreateTimer(0.1, TimerEquipPlayers, GetClientUserId(client));
	}
#if defined DEBUG
	DEBUGPRINT1("VSH Engine::BossStart() **** non-Boss Player loop finished ****");
	DEBUGPRINT2("{lime}VSH Engine::BossStart() **** non-Boss Player loop finished ****");
	DEBUGPRINT3("VSH Engine::BossStart() **** non-Boss Player loop finished ****");
#endif
	for (client = 1; client <= MaxClients; client++)
	{
		if ( !IsClientValid(client) || !bIsBoss[client] ) continue;

		if ( !IsPlayerAlive(client) ) TF2_RespawnPlayer(client);
		SetEntityMoveType(client, MOVETYPE_WALK);

		Function FuncSetBossHP = GetFunctionByName(Storage[client], "VSHA_OnBossSetHP");
		if (FuncSetBossHP != nullfunc)
		{
#if defined DEBUG
			DEBUGPRINT1("VSH Engine::VSHA_OnBossSetHP() **** Forward Called ****");
			DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossSetHP() **** Forward Called ****");
			DEBUGPRINT3("VSH Engine::VSHA_OnBossSetHP() **** Forward Called ****");
#endif
			Call_StartFunction(Storage[client], FuncSetBossHP);
			Call_PushCell(client);
			Call_Finish();
		}
#if defined DEBUG
		else
		{
			DEBUGPRINT1("VSH Engine::VSHA_OnBossSetHP() **** Forward Invalid/Not Called ****");
			DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossSetHP() **** Forward Invalid/Not Called ****");
			DEBUGPRINT3("VSH Engine::VSHA_OnBossSetHP() **** Forward Invalid/Not Called ****");
		}
#endif
		//GetTrieString(GetArrayCell(hArrayBossSubplugins, iBoss[client]), "BossName", charBossName, sizeof(charBossName));
		//if (iBossMaxHealth[client] <= 0) iBossMaxHealth[client] = HealthCalc(760.8, float(iPlaying), 1.0, 1.0341, 2046.0);

		if (iBossMaxHealth[client] < 2500) iBossMaxHealth[client] = 2500; //fallback incase accident
		iBossHealth[client] = iBossMaxHealth[client];

		int maxhp = GetEntProp(client, Prop_Data, "m_iMaxHealth");

		if (IsValidEntity(client)) TF2Attrib_RemoveAll(client);
		SetEntityHealth( client, GetEntProp(client, Prop_Data, "m_iMaxHealth") );

		TF2Attrib_SetByDefIndex( client, 26, float(iBossMaxHealth[client]-maxhp) );
		SetEntityHealth( client, iBossHealth[client] );
	}
#if defined DEBUG
	DEBUGPRINT1("VSH Engine::TimerBossStart() **** Boss Player loop finished ****");
	DEBUGPRINT2("{lime}VSH Engine::TimerBossStart() **** Boss Player loop finished ****");
	DEBUGPRINT3("VSH Engine::TimerBossStart() **** Boss Player loop finished ****");
#endif
	PawnTimer(CheckAlivePlayers, 0.2); //CreateTimer(0.2, CheckAlivePlayers);
	CreateTimer(0.2, ClientTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.2, BossTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

#if defined DEBUG
	DEBUGPRINT1("VSH Engine::TimerBossStart() **** Boss & Client Loop Timers created ****");
	DEBUGPRINT2("{lime}VSH Engine::TimerBossStart() **** Boss & Client Loop Timers created ****");
#endif
	if ( !PointType && iPlaying > AliveToEnable.IntValue ) SetControlPoint(false); //GetConVarInt(AliveToEnable)
	if ( CheckRoundState() == 0 ) PawnTimer(MusicPlay, 2.0); //CreateTimer(2.0, MusicPlay, _, TIMER_FLAG_NO_MAPCHANGE);
}

public void InitBoss()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !bIsBoss[i]) continue;

		bNoTaunt[i] = false;
		PawnTimer(MakeBoss, 0.2, iBossUserID[i]); //CreateTimer(0.2, MakeBoss, iBossUserID[i]);
	}
#if defined DEBUG
	DEBUGPRINT1("VSH Engine::InitBoss() **** Player loop finished ****");
	DEBUGPRINT3("VSH Engine::InitBoss() **** Player loop finished ****");
#endif
}

public Action CallMedVoiceMenu(int iClient, const char[] sCommand, int iArgc)
{
	if (iArgc < 2) return Plugin_Handled;
	char sCmd1[8]; GetCmdArg(1, sCmd1, sizeof(sCmd1));
	char sCmd2[8]; GetCmdArg(2, sCmd2, sizeof(sCmd2));
	//Capture call for medic commands (represented by "voicemenu 0 0")
	if (sCmd1[0] == '0' && sCmd2[0] == '0' && IsPlayerAlive(iClient) && bIsBoss[iClient])
	{
		DoTaunt(iClient, "", 0);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action DoTaunt(int client, const char[] command, int argc)
{
	if ( !Enabled || !bIsBoss[client] ) return Plugin_Continue;
	if (bNoTaunt[client]) return Plugin_Handled;
	//TF2_AddCondition(client, TFCond:42, 4.0); //use this in the forward
	if (flCharge[client] >= 100.0)
	{
		Function FuncBossRage = GetFunctionByName(Storage[client], "VSHA_OnBossRage");
		if (FuncBossRage != nullfunc)
		{
#if defined DEBUG
			DEBUGPRINT1("VSH Engine::VSHA_OnBossRage() **** Forward Called ****");
			DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossRage() **** Forward Called ****");
			DEBUGPRINT3("VSH Engine::VSHA_OnBossRage() **** Forward Called ****");
#endif
			Call_StartFunction(Storage[client], FuncBossRage);
			Call_PushCell(client);
			Call_Finish();
		}
#if defined DEBUG
		else
		{
			DEBUGPRINT1("VSH Engine::VSHA_OnBossRage() **** Forward Invalid/Not Called ****");
			DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossRage() **** Forward Invalid/Not Called ****");
			DEBUGPRINT3("VSH Engine::VSHA_OnBossRage() **** Forward Invalid/Not Called ****");
		}
#endif
		bNoTaunt[client] = true;
		CreateTimer(1.5, TimerNoTaunting, iBossUserID[client], TIMER_FLAG_NO_MAPCHANGE);
		flCharge[client] = 0.0;
	}
	return Plugin_Continue;
}
public Action TimerNoTaunting(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client)) bNoTaunt[client] = false;
	return Plugin_Continue;
}
public void BossHUD(int client)
{
	SetHudTextParams(-1.0, 0.88, 1.0, 90, 255, 90, 200);
	if ( !(GetClientButtons(client) & IN_SCORE) )
	{
		if (IsPlayerAlive(client) )
		{
			ClampCharge(flCharge[client]); //automatically clamp the rage charge so it never goes over in subplugins :>
			if (flCharge[client] == 100.0) ShowSyncHudText(client, hBossHUD, "[Health]: {%i/%i} | [Charge]: FULL", iBossHealth[client], iBossMaxHealth[client]);
			else ShowSyncHudText(client, hBossHUD, "[Health]: {%i/%i} | [Charge]: %i%", iBossHealth[client], iBossMaxHealth[client], RoundFloat(flCharge[client]));
		}
		else
		{
			int spec = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
			if (IsValidClient(spec) && bIsBoss[spec]) ShowSyncHudText(client, hBossHUD, "[Health]: {%i/%i} | [Charge]: %i", iBossHealth[spec], iBossMaxHealth[spec], RoundFloat(flCharge[spec]));
		}
	}
	return;
}
public Action DoSuicide(int client, const char[] command, int argc)
{
	if ( Enabled && (CheckRoundState() == 0 || CheckRoundState() == 1) )
	{
		if (bIsBoss[client] && bTenSecStart[0])
		{
			CPrintToChat(client, "Do not suicide as a Boss, asshole!. Use !resetq instead.");
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}
public Action DoSuicide2(int client, const char[] command, int argc)
{
	if (Enabled && bIsBoss[client] && bTenSecStart[0])
	{
		CPrintToChat(client, "You Can't Change Teams This Early!!");
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
public int GetRandomBossIndex() //purpose is for the Storage client Handle
{
	int i = 0;
	for ( i = 1; i <= MaxClients; i++ )
	{
		if ( IsClientValid(i) && bIsBoss[i] ) return i;
	}
	return -1;
}
public Action MakeModelTimer(Handle hTimer, any userid)
{
	int client = GetClientOfUserId(userid);
	if ( client <= 0 || CheckRoundState() == 2 || !bIsBoss[client] ) return Plugin_Stop;

	Action result = Plugin_Continue;
	Function FuncModelTimer = GetFunctionByName(Storage[client], "VSHA_OnModelTimer");
	if (FuncModelTimer != nullfunc)
	{
		Call_StartFunction(Storage[client], FuncModelTimer);
		Call_PushCell(client);
		char model[PATH];
		Call_PushStringEx(model, sizeof(model), 0, SM_PARAM_COPYBACK);
		Call_Finish(result);

		SetVariantString(model);
		AcceptEntityInput(client, "SetCustomModel");
		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
		return result;
	}
	else LogError("**** VSH Engine Error: Cannot find 'VSHA_OnModelTimer' Function ****");
	return Plugin_Continue;
}
public void UpdateHealthBar()
{
	int dohealth = 0, domaxhealth = 0, bosscount = 0;
	iTotalBossHP = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if ( !IsClientValid(i) || !IsPlayerAlive(i) || !bIsBoss[i] ) continue;

		dohealth += iBossHealth[i]-iBossMaxHealth[i];
		domaxhealth += iBossMaxHealth[i]; iTotalBossHP += iBossHealth[i];
		bosscount++;
	}
	if ( bosscount > 0 )
	{
		int percenthp = RoundFloat( float(dohealth) / float(domaxhealth) * 255.0 );
		if (percenthp > 255) percenthp = 255;
		else if (percenthp <= 0) percenthp = 1;
		SetEntProp(iHealthBar, Prop_Send, "m_iBossHealthPercentageByte", percenthp);
	}
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
public void MakeBoss(int userid)
{
	int client = GetClientOfUserId(userid);
	if ( client <= 0 || !IsClientInGame(client) || !bIsBoss[client] ) return;

	if (GetClientTeam(client) != HaleTeam) ForceTeamChange(client, HaleTeam);
	if ( !IsPlayerAlive(client) )
	{
		if ( CheckRoundState() == 0 ) TF2_RespawnPlayer(client);
		else return;
	}
	int ent = -1, index = -1;
	while ((ent = FindEntityByClassname2(ent, "tf_wearable")) != -1)
	{
		if (GetOwner(ent) == client)
		{
			index = GetItemIndex(ent);
			switch (index)
			{
				case 167, 438, 463, 477, 1015, 1106, 1107, 1108, 1109, 1110, 1111, 1112, 1113, 1114, 1115, 1116, 1117, 1118, 1119, 1120: {}
				default: TF2_RemoveWearable(client, ent); //AcceptEntityInput(ent, "kill");
			}
		}
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "tf_powerup_bottle")) != -1)
	{
		if (GetOwner(ent) == client) TF2_RemoveWearable(client, ent); //AcceptEntityInput(ent,
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "tf_wearable_demoshield")) != -1)
	{
		if (GetOwner(ent) == client) TF2_RemoveWearable(client, ent);
	}
	TF2_RemoveAllWeapons2(client);
	TF2_RemovePlayerDisguise(client);

	Function FuncPrepBossTimer = GetFunctionByName(Storage[client], "VSHA_OnPrepBoss");
	if (FuncPrepBossTimer != nullfunc)
	{
#if defined DEBUG
		DEBUGPRINT1("VSH Engine::VSHA_OnPrepBoss() **** Forward Called ****");
		DEBUGPRINT2("{lime}VSH Engine::VSHA_OnPrepBoss() **** Forward Called ****");
		DEBUGPRINT3("VSH Engine::VSHA_OnPrepBoss() **** Forward Called ****");
#endif
		Call_StartFunction(Storage[client], FuncPrepBossTimer);
		Call_PushCell(client);
		Call_Finish();
	}
#if defined DEBUG
	else
	{
		DEBUGPRINT1("VSH Engine::VSHA_OnPrepBoss() **** Forward Invalid/Not Called ****");
		DEBUGPRINT2("{lime}VSH Engine::VSHA_OnPrepBoss() **** Forward Invalid/Not Called ****");
		DEBUGPRINT3("VSH Engine::VSHA_OnPrepBoss() **** Forward Invalid/Not Called ****");
	}
	DEBUGPRINT1("VSH Engine::MakeBoss() **** Boss Prepared! ****");
#endif
	PawnTimer(CleanScreen, 0.2, iBossUserID[client]); //CreateTimer(0.0, CleanScreen, iBossUserID[client]);
	PawnTimer(MakeModelTimer, 0.2, iBossUserID[client]); //CreateTimer(0.2, MakeModelTimer, iBossUserID[client]);
	CreateTimer(10.0, MakeModelTimer, iBossUserID[client], TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	return;
}
public void BossResponse()
{
	int client = GetRandomBossIndex();
	Function FuncBossTalk = GetFunctionByName(Storage[client], "VSHA_OnBossIntroTalk");
	if (FuncBossTalk != nullfunc)
	{
#if defined DEBUG
		DEBUGPRINT1("VSH Engine::VSHA_OnBossIntroTalk() **** Forward Called ****");
		DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossIntroTalk() **** Forward Called ****");
		DEBUGPRINT3("VSH Engine::VSHA_OnBossIntroTalk() **** Forward Called ****");
#endif
		Call_StartFunction(Storage[client], FuncBossTalk);
		Call_Finish();
	}
#if defined DEBUG
	else
	{
		DEBUGPRINT1("VSH Engine::VSHA_OnBossIntroTalk() **** Forward Invalid/Not Called ****");
		DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossIntroTalk() **** Forward Invalid/Not Called ****");
		DEBUGPRINT3("VSH Engine::VSHA_OnBossIntroTalk() **** Forward Invalid/Not Called ****");
	}
	DEBUGPRINT1("VSH Engine::BossResponse() **** Boss Response called ****");
	DEBUGPRINT3("VSH Engine::BossResponse() **** Boss Response called ****");
#endif
	return;
}
public void DoMessage()
{
	if (CheckRoundState() != 0) return;

	int entity = -1;
	while ( (entity = FindEntityByClassname2(entity, "func_door")) != -1 )
	{
		AcceptEntityInput(entity, "Open");
		AcceptEntityInput(entity, "Unlock");
	}
	if ( hdoorchecktimer == null )
	{
		hdoorchecktimer = CreateTimer(5.0, Timer_CheckDoors, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}

	int client = GetRandomBossIndex();
	Function FuncMessageTimer = GetFunctionByName(Storage[client], "VSHA_MessageTimer");
	if (FuncMessageTimer != nullfunc)
	{
#if defined DEBUG
		DEBUGPRINT1("VSH Engine::VSHA_DoMessage() **** Forward Called ****");
		DEBUGPRINT2("{lime}VSH Engine::VSHA_DoMessage() **** Forward Called ****");
		DEBUGPRINT3("VSH Engine::VSHA_DoMessage() **** Forward Called ****");
#endif
		Call_StartFunction(Storage[client], FuncMessageTimer);
		Call_Finish();
	}
#if defined DEBUG
	else
	{
		DEBUGPRINT1("VSH Engine::VSHA_DoMessage() **** Forward Invalid/Not Called ****");
		DEBUGPRINT2("{lime}VSH Engine::VSHA_DoMessage() **** Forward Invalid/Not Called ****");
		DEBUGPRINT3("VSH Engine::VSHA_DoMessage() **** Forward Invalid/Not Called ****");
	}
#endif
	/*SetHudTextParams(-1.0, 0.4, 10.0, 255, 255, 255, 255);
	char text[PATHX];
	for (int client = 1; bIsBoss[client]; client++)
	{
		if ( !IsValidClient(client) ) continue;
		Format(text, sizeof(text), "%s\n%N became %s with %i HP", text, client, charBossName, iBossMaxHealth[client]);
	}
	for (int client = 1; client <= MaxClients; client++)
	{
		if ( IsValidClient(client) ) ShowHudText(client, -1, text);
	}*/
	return;
}
//===================================================================================================================================

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////// N A T I V E S  &  F O R W A R D S //////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// F O R W A R D S ==============================================================================================
	AddToDownloads = CreateGlobalForward("VSHA_AddToDownloads", ET_Ignore);
	//===========================================================================================================================

	// N A T I V E S ============================================================================================================
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

	//===========================================================================================================================

	RegPluginLibrary("vsha");
#if defined _steamtools_included
	MarkNativeAsOptional("Steam_SetGameDescription");
#endif
	return APLRes_Success;
}

public int Native_RegisterBossSubplugin(Handle plugin, int numParams)
{
	char BossSubPluginName[32]; GetNativeString(1, BossSubPluginName, sizeof(BossSubPluginName));
	VSHAError erroar;
	Handle BossHandle = RegisterBoss( plugin, BossSubPluginName, erroar ); //ALL PROPS TO COOKIES.NET AKA COOKIES.IO
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
