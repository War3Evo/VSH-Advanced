// vsha_CommandListener_DoTaunt.inc

public Action DoTaunt(int client, const char[] command, int argc)
{
	//PrintToChatAll("Action DoTaunt(int client, const char[] command, int argc)");
	if ( !bEnabled || !bIsBoss[client] ) return Plugin_Continue;
	if (bNoTaunt[client]) return Plugin_Handled;
	//TF2_AddCondition(client, TFCond:42, 4.0); //use this in the forward
	if (flCharge[client] < flChargeLimit[client]) return Plugin_Continue;

	bNoTaunt[client] = true;

	VSHA_OnBossRage(client);

	CreateTimer(1.5, TimerNoTaunting, iBossUserID[client], TIMER_FLAG_NO_MAPCHANGE);
	flCharge[client] = 0.0;

	return Plugin_Handled;
}
public Action TimerNoTaunting(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client)) bNoTaunt[client] = false;
	return Plugin_Continue;
}


