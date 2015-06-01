// vsha_000_OnPluginStart.inc

public void OnPluginStart()
{
	hArrayBossSubplugins = new ArrayList();	//CreateArray();
	hArrayNonBossSubplugins = new ArrayList();	//CreateArray();
	hTrieBossSubplugins = new StringMap();	//CreateTrie();

	// VSHAHook
	p_OnBossIntroTalk = CreateGlobalForward("VSHA_OnBossIntroTalk",ET_Ignore);
	p_AddToDownloads = CreateGlobalForward("VSHA_AddToDownloads",ET_Ignore);

	p_OnPlayerKilledByBoss = CreateGlobalForward("VSHA_OnPlayerKilledByBoss",ET_Ignore, Param_Cell, Param_Cell);
	p_OnKillingSpreeByBoss = CreateGlobalForward("VSHA_OnKillingSpreeByBoss",ET_Ignore, Param_Cell, Param_Cell);
	p_OnBossKilled = CreateGlobalForward("VSHA_OnBossKilled",ET_Ignore, Param_Cell, Param_Cell);

	p_OnBossWin = CreateGlobalForward("VSHA_OnBossWin",ET_Ignore, Param_Cell, Param_Cell);
	p_OnBossKillBuilding = CreateGlobalForward("VSHA_OnBossKillBuilding",ET_Ignore, Param_Cell, Param_Cell);

	p_OnMessageTimer = CreateGlobalForward("VSHA_OnMessageTimer",ET_Ignore);

	p_OnBossAirblasted = CreateGlobalForward("VSHA_OnBossAirblasted",ET_Ignore, Param_Cell, Param_Cell);

	p_OnBossSelected = CreateGlobalForward("VSHA_OnBossSelected",ET_Ignore, Param_Cell);

	p_OnBossSetHP = CreateGlobalForward("VSHA_OnBossSetHP",ET_Hook, Param_Cell, Param_CellByRef);

	p_OnLastSurvivor = CreateGlobalForward("VSHA_OnLastSurvivor",ET_Ignore);

	p_OnBossTimer = CreateGlobalForward("VSHA_OnBossTimer",ET_Ignore, Param_Cell, Param_CellByRef, Param_CellByRef);

	p_OnPrepBoss = CreateGlobalForward("VSHA_OnPrepBoss",ET_Ignore, Param_Cell);

	p_OnMusic = CreateGlobalForward("VSHA_OnMusic",ET_Hook, Param_String, Param_FloatByRef);

	p_OnModelTimer = CreateGlobalForward("VSHA_OnModelTimer",ET_Hook, Param_Cell, Param_String);

	p_OnBossRage = CreateGlobalForward("VSHA_OnBossRage",ET_Ignore, Param_Cell);

	p_OnConfiguration_Load_Sounds = CreateGlobalForward("VSHA_OnConfiguration_Load_Sounds",ET_Ignore, Param_String, Param_String, Param_CellByRef, Param_CellByRef);
	p_OnConfiguration_Load_Materials = CreateGlobalForward("VSHA_OnConfiguration_Load_Materials",ET_Ignore, Param_String, Param_String, Param_CellByRef, Param_CellByRef);
	p_OnConfiguration_Load_Models = CreateGlobalForward("VSHA_OnConfiguration_Load_Models",ET_Ignore, Param_String, Param_String, Param_CellByRef, Param_CellByRef);

	p_OnConfiguration_Load_Misc =  CreateGlobalForward("VSHA_OnConfiguration_Load_Misc",ET_Ignore, Param_String, Param_String);

	p_OnEquipPlayer_Pre = CreateGlobalForward("VSHA_OnEquipPlayer_Pre",ET_Hook, Param_Cell);

	p_ShowPlayerHelpMenu = CreateGlobalForward("VSHA_ShowPlayerHelpMenu",ET_Ignore, Param_Cell);

	p_OnEquipPlayer_Post = CreateGlobalForward("VSHA_OnEquipPlayer_Post",ET_Ignore, Param_Cell);

	p_ShowBossHelpMenu = CreateGlobalForward("VSHA_ShowBossHelpMenu",ET_Ignore, Param_Cell);

	p_OnUberTimer = CreateGlobalForward("VSHA_OnUberTimer",ET_Ignore, Param_Cell, Param_Cell);

	p_OnLastSurvivorLoop =  CreateGlobalForward("VSHA_OnLastSurvivorLoop",ET_Ignore, Param_Cell);

	LogMessage("==== Versus Saxton Hale Engine Initializing - v%s ====", PLUGIN_VERSION);
	bEnabled = CreateConVar("vsha_enabled", "1", "Enable the VSH Engine", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	FirstRound = CreateConVar("vsha_firstround", "1", "Enable first round for VSH Engine", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	MedigunReset = CreateConVar("vsha_medigunreset", "0.40", "default ubercharge for when mediguns reset", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	AliveToEnable = CreateConVar("vsha_alivetoenable", "3", "how many players left to enable cap", FCVAR_PLUGIN, true, 0.0, true, 16.0);
	CountDownPlayerLimit = CreateConVar("vsha_countdownplayerlimit", "3", "how many players must be left to start the final countdown timer", FCVAR_PLUGIN, true, 0.0, true, 16.0);
	CountDownHealthLimit = CreateConVar("vsha_countdownbosshealth", "5000", "how low boss health must be to start the final countdown timer", FCVAR_PLUGIN, true, 0.0, true, 999999.0);
	LastPlayersTimerCountDown = CreateConVar("vsha_finalcountdowntimer", "120", "how long the final countdown timer is", FCVAR_PLUGIN, true, 0.0, true, 99999.0);
	EnableEurekaEffect = CreateConVar("vsha_alloweureka", "1", "(dis)allows the eureka wrench from being used", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	PointDelay = CreateConVar("vsha_capturepointdelay", "10", "time in seconds the cap is delayed from enabling", FCVAR_PLUGIN, true, 0.0, true, 999.0);
	QueueIncrement = CreateConVar("vsha_queueincrement", "10", "by how much queue increments", FCVAR_PLUGIN, true, 1.0, true, 999.0);
	//FallDmgSoldier = CreateConVar("vsha_soldierfalldamage", "20.0", "divides fall damage by this number", FCVAR_PLUGIN, true, 0.0, true, 999.0);
	//DifficultyAmount = CreateConVar("vsha_difficultyamount", "3", "how many difficulty settings you want available for bosses to choose", FCVAR_PLUGIN, true, 0.0, true, 999.0);

	AddCommandListener(DoTaunt, "taunt");
	AddCommandListener(DoTaunt, "+taunt");
	AddCommandListener(CallMedVoiceMenu, "voicemenu");
	AddCommandListener(DoSuicide, "explode");
	AddCommandListener(DoSuicide, "kill");
	AddCommandListener(DoSuicide2, "jointeam");
	AddCommandListener(clDestroy, "destroy");

	HookEvent("teamplay_round_start", RoundStart);
	HookEvent("teamplay_round_win", RoundEnd);
	HookEvent("player_spawn", PlayerSpawn);
	//HookEvent("post_inventory_application", PlayerSpawn);
	HookEvent("player_chargedeployed", UberDeployed);
	HookEvent("rocket_jump", JumpHook);
	HookEvent("rocket_jump_landed", JumpHook);
	HookEvent("sticky_jump", JumpHook);
	HookEvent("sticky_jump_landed", JumpHook);
	HookEvent("player_death", JumpHook);
	HookEvent("player_death", PlayerDeath, EventHookMode_Pre);
	HookEvent("player_hurt", PlayerHurt, EventHookMode_Pre);
	HookEvent("object_destroyed", Destroyed, EventHookMode_Pre);
	HookEvent("object_deflected", Deflected, EventHookMode_Pre);
	//HookEvent("player_changeclass", ChangeClass);

	vsha_000_RegConsoleCmd_OnPluginStart();
	vsha_000_RegAdminCmd_OnPluginStart();

	hBossHUD = CreateHudSynchronizer();
	hPlayerHUD = CreateHudSynchronizer();
	TimeLeftHUD = CreateHudSynchronizer();
	MiscHUD = CreateHudSynchronizer();

	PointCookie = RegClientCookie("vsha_queuepoints", "Amount of VSH Engine Queue points, the player has", CookieAccess_Protected);
	//LoadSubPlugins();
	//AutoExecConfig(true, "VSH-Engine");

	for (int i = 1; i <= MaxClients; i++)
	{
		if ( !IsValidClient(i) ) continue;
		OnClientPutInServer(i);
	}
}

