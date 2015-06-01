// vsha_HookEvent_Destroyed.inc

public Action Destroyed(Event event, const char[] name, bool dontBroadcast)
{
	if (Enabled)
	{
		int attacker = GetClientOfUserId(event.GetInt("attacker"));
		if ( bIsBoss[attacker] ) //&& !GetRandomInt(0, 2) )
		{
			//int building = event.GetInt("index");

			INTERNAL_VSHA_OnBossKillBuilding(event, attacker);
		}
	}
	return Plugin_Continue;
}
