// vsha_CreateTimer_CleanScreen.inc

public Action CleanScreen(Handle timer, int userid)
{
	//PrintToChatAll("Action CleanScreen Timer");
	int client = GetClientOfUserId(userid);
	if ( client <= 0 || !bIsBoss[client] ) return Plugin_Continue;
	//PrintToChatAll("( client > 0 || bIsBoss[client] ) Action CleanScreen Timer");
	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT));
	ClientCommand(client, "r_screenoverlay \"\"");
	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & FCVAR_CHEAT);
	return Plugin_Continue;
}
