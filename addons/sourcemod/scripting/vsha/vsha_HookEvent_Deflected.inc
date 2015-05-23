// vsha_HookEvent_Deflected.inc

public Action Deflected(Event event, const char[] name, bool dontBroadcast)
{
	if ( !Enabled || event.GetInt("weaponid") ) return Plugin_Continue;
	int client = GetClientOfUserId(event.GetInt("ownerid"));
	if ( bIsBoss[client] )
	{
		int airblaster = GetClientOfUserId(event.GetInt("userid"));

		Function FuncBossAirBlst = GetFunctionByName(Storage[client], "VSHA_OnBossAirblasted");
		if (FuncBossAirBlst != nullfunc)
		{
#if defined DEBUG
			DEBUGPRINT1("VSH Engine::VSHA_OnBossAirblasted() **** Forward Called ****");
			DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossAirblasted() **** Forward Called ****");
#endif
			Call_StartFunction(Storage[client], FuncBossAirBlst);
			Call_PushCell(client);
			Call_PushCell(airblaster);
			Call_Finish();
		}
#if defined DEBUG
		else
		{
			DEBUGPRINT1("VSH Engine::VSHA_OnBossAirblasted() **** Forward Invalid/Not Called ****");
			DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossAirblasted() **** Forward Invalid/Not Called ****");
		}
#endif
	}
	return Plugin_Continue;
}
