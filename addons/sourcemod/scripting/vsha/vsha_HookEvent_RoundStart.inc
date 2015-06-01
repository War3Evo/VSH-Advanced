// vsha_HookEvent_RoundStart.inc

public void ForceRoundStartCheckTimer()
{
	RoundStartFunction();
}

public Action RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	return RoundStartFunction();
}

public Action RoundStartFunction()
{
	//DP("RoundStart");
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
	// We do this on round end, why need it on round start?
	// commenting this out to try and defeat a bug
	//ClearTimer(MusicTimer);
	CheckArena();
	int i;
	iPlaying = 0;
	for (i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsOnBlueOrRedTeam(i))
		{
			ClearVariablesRoundStart(i);
			//ForceTeamChange(i, OtherTeam);
			//iDamage[i] = 0;
			//bIsBoss[i] = false;
			iPlaying++;
		}
	}
#if defined DEBUG
	DEBUGPRINT1("VSH Engine::RoundStart() **** Player Loop finished! ****");
#endif
	if (GetClientCount() <= 1 || iPlaying < 2)
	{
		if(RetryCounter>0)
		{
			int entityTimer = FindEntityByClassname(-1, "team_round_timer");
			if (entityTimer > -1)
			{
				SetVariantInt(5);
				AcceptEntityInput(entityTimer, "AddTime");
				RetryCounter=10;
			}
			else
			{
				RetryCounter--;
			}
			PawnTimer(ForceRoundStartCheckTimer, 4.8);
			CPrintToChatAll("{olive}[VSH Engine]{default} Waiting for more players...");
		}
		else
		{
			CPrintToChatAll("{olive}[VSH Engine]{default} Need more players to begin!");
			Enabled = false;
			SetControlPoint(true);
		}
		return Plugin_Continue;
	}
	RetryCounter = 10;
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

	INTERNAL_VSHA_OnBossSelected(Storage[boss], boss);

	if ( GetTeamPlayerCount(HaleTeam) <= 0 || GetTeamPlayerCount(OtherTeam) <= 0 )
	{
		for (i = 1; i <= MaxClients; i++)
		{
			if ( IsValidClient(i) && IsOnBlueOrRedTeam(i) )
			{
				if (bIsBoss[i])
				{
					//DP("HookEvent_RoundStart 123 ForceTeamChange(i, HaleTeam)");
					ForceTeamChange(i, HaleTeam);
				}
				else
				{
					//DP("HookEvent_RoundStart 123 ForceTeamChange(i, OtherTeam)");
					ForceTeamChange(i, OtherTeam);
				}
			}
		}
	}

	bTenSecStart[0] = true;
	bTenSecStart[1] = true;

	PawnTimer(tTenSecStart, 29.1, 0);
	PawnTimer(tTenSecStart, 60.1, 1);

	PawnTimer(BossStart, 9.1); //CreateTimer(9.1, TimerBossStart);
	PawnTimer(InitBoss, 0.2); //CreateTimer(0.1, TimerInitBoss);
	CreateTimer(3.5, TimerBossResponse); //CreateTimer(3.5, TimerBossResponse);
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
