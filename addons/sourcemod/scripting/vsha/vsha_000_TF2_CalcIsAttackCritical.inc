// vsha_000_TF2_CalcIsAttackCritical.inc

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool &bresult)
{
	if(bEnabled && bIsBoss[client] && CheckRoundState()==1 && !TF2_IsPlayerCritBuffed(client) && !bBossCrits)
	{
		bresult=false;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
