// vsha_CreateTimer_Timer_DrawGame.inc

public Action Timer_DrawGame(Handle timer)
{
	if (iLowestBossHP < CountDownHealthLimit.IntValue || CheckRoundState() != 1) return Plugin_Stop;

	int time = timeleft;
	timeleft--;
	char timeDisplay[6];
	if (time/60 > 9) IntToString(time/60, timeDisplay, sizeof(timeDisplay));
	else Format(timeDisplay, sizeof(timeDisplay), "0%i", time/60);

	if (time%60 > 9) Format(timeDisplay, sizeof(timeDisplay), "%s:%i", timeDisplay, time%60);
	else Format(timeDisplay, sizeof(timeDisplay), "%s:0%i", timeDisplay, time%60);

	SetHudTextParams(-1.0, 0.17, 1.1, 255, 255, 255, 200);
	for (int client = 1; client <= MaxClients; client++)
	{
		if ( IsClientValid(client) && !(GetClientButtons(client) & IN_SCORE) ) ShowSyncHudText(client, TimeLeftHUD, timeDisplay);
	}
	switch ( time )
	{
		case 300:	EmitSoundToAll("vo/announcer_ends_5min.mp3");
		case 120:	EmitSoundToAll("vo/announcer_ends_2min.mp3");
		case 60:	EmitSoundToAll("vo/announcer_ends_60sec.mp3");
		case 30:	EmitSoundToAll("vo/announcer_ends_30sec.mp3");
		case 10:	EmitSoundToAll("vo/announcer_ends_10sec.mp3");
		case 1, 2, 3, 4, 5:
		{
			char sound[PATHX];
			Format(sound, PATHX, "vo/announcer_ends_%isec.mp3", time);
			EmitSoundToAll(sound);
		}
		case 0:
		{
			for (int client = 1; client <= MaxClients; client++)
			{
				if ( IsClientInGame(client) && IsPlayerAlive(client) ) ForcePlayerSuicide(client);
			}
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}
