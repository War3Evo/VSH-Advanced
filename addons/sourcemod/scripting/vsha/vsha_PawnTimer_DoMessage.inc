// vsha_PawnTimer_DoMessage.inc

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
