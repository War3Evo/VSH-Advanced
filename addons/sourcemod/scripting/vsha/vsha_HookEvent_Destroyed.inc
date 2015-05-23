// vsha_HookEvent_Destroyed.inc

public Action Destroyed(Event event, const char[] name, bool dontBroadcast)
{
	if (Enabled)
	{
		int attacker = GetClientOfUserId(event.GetInt("attacker"));
		if ( bIsBoss[attacker] ) //&& !GetRandomInt(0, 2) )
		{
			int building = event.GetInt("index");

			Function FuncBossKillToy = GetFunctionByName(Storage[attacker], "VSHA_OnBossKillBuilding");
			if (FuncBossKillToy != nullfunc)
			{
#if defined DEBUG
				DEBUGPRINT1("VSH Engine::VSHA_OnBossKillBuilding() **** Forward Called ****");
				DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossKillBuilding() **** Forward Called ****");
#endif
				Call_StartFunction(Storage[attacker], FuncBossKillToy);
				Call_PushCell(attacker);
				Call_PushCell(building);
				Call_Finish();
			}
#if defined DEBUG
			else
			{
				DEBUGPRINT1("VSH Engine::VSHA_OnBossKillBuilding() **** Forward Invalid/Not Called ****");
				DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossKillBuilding() **** Forward Invalid/Not Called ****");
			}
#endif
		}
	}
	return Plugin_Continue;
}
