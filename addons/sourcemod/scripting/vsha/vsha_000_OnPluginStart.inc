// vsha_000_OnPluginStart.inc

public void OnPluginStart()
{
	hArrayBossSubplugins = new ArrayList();	//CreateArray();
	hTrieBossSubplugins = new StringMap();	//CreateTrie();

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

	RegConsoleCmd("sm_vsha_special", CommandMakeNextSpecial);

	RegAdminCmd("sm_forceboss", Command_forceboss, ADMFLAG_ROOT, "sm_forceboss");

	RegConsoleCmd("sm_setboss", PickBossMenu);
	RegConsoleCmd("sm_haleboss", PickBossMenu);
	RegConsoleCmd("sm_vshaboss", PickBossMenu);
	RegConsoleCmd("sm_vsheboss", PickBossMenu);

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

