// vsha_CreateDataTimer_TimerMusicTheme.inc

public Action TimerMusicTheme(Handle timer, DataPack pack)
{
	if (Enabled && CheckRoundState() == 1)
	{
		pack.Reset();
		char sound[PATHX]; pack.ReadString( sound, sizeof(sound) );

		if (sound[0] != '\0') EmitSoundToAll(sound, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, nullvec, nullvec, false, 0.0);
	}
	else
	{
		ClearTimer(MusicTimer);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
