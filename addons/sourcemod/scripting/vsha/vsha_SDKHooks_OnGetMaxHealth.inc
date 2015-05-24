// vsha_SDKHooks_OnGetMaxHealth.inc

/**
* OnGetMaxHealth:
*
* Helps keep Hale from looking as if he has overheal.
*
*/
public Action OnGetMaxHealth(int client, int &maxhealth)
{
	if( CheckRoundState() != ROUNDSTATE_START_ROUND_TIMER)
	{
		return Plugin_Continue;
	}
	if (ValidPlayer(client,true) && bIsBoss[client])
	{
		int HP = GetEntProp(client, Prop_Data, "m_iHealth");
		if(HP>iBossMaxHealth[client])
		{
			SetEntProp(client, Prop_Data, "m_iHealth", iBossHealth[client]);
		}
		maxhealth=iBossMaxHealth[client];
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
