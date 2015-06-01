// vsha_PawnTimer_MusicPlay.inc

public void MusicPlay()
{
	if (CheckRoundState() != ROUNDSTATE_START_ROUND_TIMER && CheckRoundState() != ROUNDSTATE_EVENT_ROUND_START)
	{
		//PrintToChatAll("vsha_PawnTimer_MusicPlay stopped MusicPlay");
		return;
	}
	char sound[PATHX];
	float time = -1.0;
	ClearTimer(MusicTimer);

	sound[0] = '\0';

	//StringMap SoundMap = new StringMap();
	//SoundMap.SetString("Sound", sound);

	//VSHA_SetVar(EventSound,SoundMap);
	//VSHA_SetVar(EventTime,time);
	//VSHA_Private_Forward("VSHA_OnMusic");

	VSHA_OnMusic(sound, time);

	//SoundMap = VSHA_GetVar(EventSound);
	//time = view_as<float>(VSHA_GetVar(EventTime));

	//PrintToChatAll("Music Time %.2f",time);

	//SoundMap.GetString("Sound",STRING(sound));

	//PrintToChatAll("VSHA_OnMusic %s",sound);

	if ( sound[0] != '\0' )
	{
	//      Format(sound, sizeof(sound), "#%s", sound);
		EmitSoundToAll(sound, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, nullvec, nullvec, false, 0.0);
		//PrintToServer("[VSHA] Music Theme '%s' played.",sound);
	}
	if ( time > 0.0 )
	{
		//PrintToChatAll("Started CreateDataTimer for MusicPlay");

		DataPack SndPack = new DataPack();
		SndPack.WriteString(sound);
		SndPack.WriteFloat(time);
		MusicTimer = CreateTimer(time, TimerMusicTheme, SndPack, TIMER_DATA_HNDL_CLOSE);
	}
	return;
}
