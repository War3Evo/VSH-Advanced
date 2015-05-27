// vsha_CreateTimer_BossTimer.inc

// 0.2 Second Timer
public Action BossTimer(Handle timer)
{
	if (InternalPause) return Plugin_Stop;

	if ( !Enabled || CheckRoundState() == ROUNDSTATE_ROUND_END ) return Plugin_Stop;
	LoopActiveBosses(client)
	{
		if ( IsValidClient(client) && IsPlayerAlive(client) && bIsBoss[client] )
		{
			//commenting this out, as OnGetMaxHealth handles this every frame.
			//SetEntityHealth(client, iBossHealth[client]);
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
	VSHA_SetVar(EventClient,client);
	VSHA_Private_Forward("VSHA_OnBossTimer");

	return;
}
