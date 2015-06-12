// vsha_000_TF2_CalcIsAttackCritical.inc

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool &bresult)
{
	//if(bEnabled && bIsBoss[client] && CheckRoundState()==ROUNDSTATE_START_ROUND_TIMER && !TF2_IsPlayerCritBuffed(client) && !bBossCrits)
	if(bEnabled && bIsBoss[client] && CheckRoundState()==ROUNDSTATE_START_ROUND_TIMER && !bBossCrits)
	{
		bresult=false;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
