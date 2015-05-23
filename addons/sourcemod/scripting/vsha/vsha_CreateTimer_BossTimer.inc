// vsha_CreateTimer_BossTimer.inc

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
