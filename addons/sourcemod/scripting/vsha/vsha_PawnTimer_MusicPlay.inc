// vsha_PawnTimer_MusicPlay.inc

public void MusicPlay()
{
	if (CheckRoundState() != 1) return;
	char sound[PATHX];
	float time = -1.0;
	ClearTimer(MusicTimer);

	sound[0] = '\0';

	StringMap SoundMap = new StringMap();
	SoundMap.SetString("Sound", sound);

	VSHA_SetVar(EventSound,SoundMap);
	VSHA_SetVar(EventTime,time);
	VSHA_Private_Forward("VSHA_OnMusic");

	SoundMap = VSHA_GetVar(EventSound);
	time = VSHA_GetVar(EventTime);

	SoundMap.GetString("Sound",STRING(sound));

	if ( sound[0] != '\0' )
	{
	//      Format(sound, sizeof(sound), "#%s", sound);
		EmitSoundToAll(sound, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, nullvec, nullvec, false, 0.0);
	}
	if ( time != -1.0 )
	{
		DataPack pack = new DataPack();
		pack.WriteString(sound);
		MusicTimer = CreateDataTimer(time, TimerMusicTheme, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
	return;
}
