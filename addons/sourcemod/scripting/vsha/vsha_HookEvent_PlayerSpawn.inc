// vsha_HookEvent_PlayerSpawn.inc

public Action PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if (!Enabled) return Plugin_Continue;
	int client = GetClientOfUserId( event.GetInt("userid") );
	if ( client && IsClientInGame(client) && (CheckRoundState() > -1 && CheckRoundState() < 2) )
	{
		SetVariantString("");
		AcceptEntityInput(client, "SetCustomModel");
		if ( bIsBoss[client] ) PawnTimer(MakeBoss, 0.2, GetClientUserId(client)); //CreateTimer(0.1, MakeBoss, GetClientUserId(client));
		else
		{
			TF2_RemoveAllWeapons2(client);
			TF2_RegeneratePlayer(client);
			PawnTimer(EquipPlayers, 0.2, GetClientUserId(client)); //CreateTimer(0.1, EquipPlayers, GetClientUserId(client));
#if defined DEBUG
			DEBUGPRINT1("VSH Engine::PlayerSpawn() **** Non-Boss Player sent to Equip Timer! ****");
#endif
		}
	}
	if ( CheckRoundState() == 1 ) PawnTimer(CheckAlivePlayers, 0.2); //CreateTimer(0.5, CheckAlivePlayers);
	return Plugin_Continue;
}
