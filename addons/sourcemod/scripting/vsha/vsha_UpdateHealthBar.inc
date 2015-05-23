// vsha_UpdateHealthBar.inc

public void UpdateHealthBar()
{
	int dohealth = 0, domaxhealth = 0, bosscount = 0;
	iTotalBossHP = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if ( !IsClientValid(i) || !IsPlayerAlive(i) || !bIsBoss[i] ) continue;

		dohealth += iBossHealth[i]-iBossMaxHealth[i];
		domaxhealth += iBossMaxHealth[i]; iTotalBossHP += iBossHealth[i];
		bosscount++;
	}
	if ( bosscount > 0 )
	{
		int percenthp = RoundFloat( float(dohealth) / float(domaxhealth) * 255.0 );
		if (percenthp > 255) percenthp = 255;
		else if (percenthp <= 0) percenthp = 1;
		SetEntProp(iHealthBar, Prop_Send, "m_iBossHealthPercentageByte", percenthp);
	}
}
