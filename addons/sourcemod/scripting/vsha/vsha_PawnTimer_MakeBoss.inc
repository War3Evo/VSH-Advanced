// vsha_PawnTimer_MakeBoss.inc

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
