// vsha_PawnTimer_MakeBoss.inc

public void MakeBoss(int userid)
{
	int iClient = GetClientOfUserId(userid);
	if ( iClient <= 0 || !IsClientInGame(iClient) || !bIsBoss[iClient] ) return;

	if (GetClientTeam(iClient) != HaleTeam) ForceTeamChange(iClient, HaleTeam);
	if ( !IsPlayerAlive(iClient) )
	{
		if ( CheckRoundState() == 0 ) TF2_RespawnPlayer(iClient);
		else return;
	}
	int ent = -1, index = -1;
	while ((ent = FindEntityByClassname2(ent, "tf_wearable")) != -1)
	{
		if (GetOwner(ent) == iClient)
		{
			index = GetItemIndex(ent);
			switch (index)
			{
				case 167, 438, 463, 477, 1015, 1106, 1107, 1108, 1109, 1110, 1111, 1112, 1113, 1114, 1115, 1116, 1117, 1118, 1119, 1120: {}
				default: TF2_RemoveWearable(iClient, ent); //AcceptEntityInput(ent, "kill");
			}
		}
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "tf_powerup_bottle")) != -1)
	{
		if (GetOwner(ent) == iClient) TF2_RemoveWearable(iClient, ent); //AcceptEntityInput(ent,
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "tf_wearable_demoshield")) != -1)
	{
		if (GetOwner(ent) == iClient) TF2_RemoveWearable(iClient, ent);
	}
	TF2_RemoveAllWeapons2(iClient);
	TF2_RemovePlayerDisguise(iClient);

	SDKHook(iClient, SDKHook_GetMaxHealth, OnGetMaxHealth);

	VSHA_SetVar(EventOnPrepBoss,iClient);
	VSHA_Private_Forward("VSHA_OnPrepBoss");

	PawnTimer(CleanScreen, 0.2, iBossUserID[iClient]); //CreateTimer(0.0, CleanScreen, iBossUserID[iClient]);
	PawnTimer(MakeModelTimer, 0.2, iBossUserID[iClient]); //CreateTimer(0.2, MakeModelTimer, iBossUserID[iClient]);
	CreateTimer(10.0, MakeModelTimer, iBossUserID[iClient], TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	return;
}
