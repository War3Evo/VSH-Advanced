// vsha_PawnTimer_CleanScreen.inc

public void CleanScreen(int userid)
{
	int client = GetClientOfUserId(userid);
	if ( client <= 0 || !bIsBoss[client] ) return;
	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT));
	ClientCommand(client, "r_screenoverlay \"\"");
	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & FCVAR_CHEAT);
	return;
}
