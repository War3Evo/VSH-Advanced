// vsha_CreateTimer_BossResponse.inc

public Action BossResponse(Handle timer, int data)
{
	//PrintToChatAll("Action BossResponse Timer");
	VSHA_OnBossIntroTalk();

	hBossResponse = null;
	//PrintToChatAll("hBossResponse = null;");
	return Plugin_Continue;
}
