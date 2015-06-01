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

	INTERNAL_VSHA_OnMessageTimer();

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
