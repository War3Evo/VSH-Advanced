// vsha_CreateTimer_BossResponse.inc

public Action BossResponse(Handle timer, int data)
{
	VSHA_OnBossIntroTalk();

	return Plugin_Continue;
}
