// vsha_PawnTimer_BossStart.inc

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
