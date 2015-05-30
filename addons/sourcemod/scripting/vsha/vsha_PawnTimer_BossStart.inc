// vsha_PawnTimer_BossStart.inc

public void BossStart()
{
	iPlaying = 0;
	LoopIngameClients(iClient) //loop iClients first for health calculation
	{
		if ( IsClientValid(iClient) && IsPlayerAlive(iClient) && !bIsBoss[iClient])
		{
			iPlaying++;
			SetEntityMoveType(iClient, MOVETYPE_WALK); // >_>
			PawnTimer(EquipPlayers, 0.2, GetClientUserId(iClient)); //SUIT UP!
			//CreateTimer(0.1, TimerEquipPlayers, GetClientUserId(iClient));
		}
	}
#if defined DEBUG
	DEBUGPRINT1("VSH Engine::BossStart() **** non-Boss Player loop finished ****");
	DEBUGPRINT2("{lime}VSH Engine::BossStart() **** non-Boss Player loop finished ****");
	DEBUGPRINT3("VSH Engine::BossStart() **** non-Boss Player loop finished ****");
#endif
	LoopActiveBosses(iClient)
	{
		// LoopActiveBosses takes care of this:
		//if ( !IsClientValid(iClient) || !bIsBoss[iClient] ) continue;

		if ( !IsPlayerAlive(iClient) ) TF2_RespawnPlayer(iClient);
		SetEntityMoveType(iClient, MOVETYPE_WALK);

		VSHA_SetVar(EventBoss,iClient);
		VSHA_SetVar(EventHitPoints,2500);
		VSHA_Private_Forward("VSHA_OnBossSetHP");
		int MaxBossHP = VSHA_GetVar(EventHitPoints);

		if(MaxBossHP <= 0)
		{
			MaxBossHP = 2500;
		}

		//GetTrieString(GetArrayCell(hArrayBossSubplugins, iBoss[iClient]), "BossName", charBossName, sizeof(charBossName));
		//if (iBossMaxHealth[iClient] <= 0) iBossMaxHealth[iClient] = HealthCalc(760.8, float(iPlaying), 1.0, 1.0341, 2046.0);

		if (iBossMaxHealth[iClient] < MaxBossHP) iBossMaxHealth[iClient] = MaxBossHP; //fallback incase accident
		iBossHealth[iClient] = iBossMaxHealth[iClient];

		int maxhp = GetEntProp(iClient, Prop_Data, "m_iMaxHealth");

		if (IsValidEntity(iClient)) TF2Attrib_RemoveAll(iClient);
		SetEntityHealth( iClient, GetEntProp(iClient, Prop_Data, "m_iMaxHealth") );

		TF2Attrib_SetByDefIndex( iClient, 26, float(iBossMaxHealth[iClient]-maxhp) );
		SetEntityHealth( iClient, iBossHealth[iClient] );
	}
#if defined DEBUG
	DEBUGPRINT1("VSH Engine::TimerBossStart() **** Boss Player loop finished ****");
	DEBUGPRINT2("{lime}VSH Engine::TimerBossStart() **** Boss Player loop finished ****");
	DEBUGPRINT3("VSH Engine::TimerBossStart() **** Boss Player loop finished ****");
#endif
	PawnTimer(CheckAlivePlayers, 0.2); //CreateTimer(0.2, CheckAlivePlayers);
	CreateTimer(0.2, HaleTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.2, BossTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

#if defined DEBUG
	DEBUGPRINT1("VSH Engine::TimerBossStart() **** Boss & Client Loop Timers created ****");
	DEBUGPRINT2("{lime}VSH Engine::TimerBossStart() **** Boss & Client Loop Timers created ****");
#endif
	if ( !PointType && iPlaying > AliveToEnable.IntValue ) SetControlPoint(false); //GetConVarInt(AliveToEnable)
	if ( CheckRoundState() == 0 ) PawnTimer(MusicPlay, 2.0); //CreateTimer(2.0, MusicPlay, _, TIMER_FLAG_NO_MAPCHANGE);
}
