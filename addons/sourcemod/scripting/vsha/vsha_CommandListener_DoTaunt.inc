// vsha_CommandListener_DoTaunt.inc

public Action DoTaunt(int client, const char[] command, int argc)
{
	if ( !Enabled || !bIsBoss[client] ) return Plugin_Continue;
	if (bNoTaunt[client]) return Plugin_Handled;
	//TF2_AddCondition(client, TFCond:42, 4.0); //use this in the forward
	if (flCharge[client] >= 100.0)
	{
		Function FuncBossRage = GetFunctionByName(Storage[client], "VSHA_OnBossRage");
		if (FuncBossRage != nullfunc)
		{
#if defined DEBUG
			DEBUGPRINT1("VSH Engine::VSHA_OnBossRage() **** Forward Called ****");
			DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossRage() **** Forward Called ****");
			DEBUGPRINT3("VSH Engine::VSHA_OnBossRage() **** Forward Called ****");
#endif
			Call_StartFunction(Storage[client], FuncBossRage);
			Call_PushCell(client);
			Call_Finish();
		}
#if defined DEBUG
		else
		{
			DEBUGPRINT1("VSH Engine::VSHA_OnBossRage() **** Forward Invalid/Not Called ****");
			DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossRage() **** Forward Invalid/Not Called ****");
			DEBUGPRINT3("VSH Engine::VSHA_OnBossRage() **** Forward Invalid/Not Called ****");
		}
#endif
		bNoTaunt[client] = true;
		CreateTimer(1.5, TimerNoTaunting, iBossUserID[client], TIMER_FLAG_NO_MAPCHANGE);
		flCharge[client] = 0.0;
	}
	return Plugin_Continue;
}
public Action TimerNoTaunting(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client)) bNoTaunt[client] = false;
	return Plugin_Continue;
}

