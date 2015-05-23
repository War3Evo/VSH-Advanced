// vsha_PawnTimer_MusicPlay.inc

public void MusicPlay()
{
	if (CheckRoundState() != 1) return;
	char sound[PATHX];
	float time = -1.0;
	ClearTimer(MusicTimer);

	int client = GetRandomBossIndex();
	sound[0] = '\0';
	Function FuncMusicTimer = GetFunctionByName(Storage[client], "VSHA_OnMusic");
	if (FuncMusicTimer != nullfunc)
	{
#if defined DEBUG
		DEBUGPRINT1("VSH Engine::VSHA_OnMusic() **** Forward Called ****");
		DEBUGPRINT2("{lime}VSH Engine::VSHA_OnMusic() **** Forward Called ****");
		DEBUGPRINT3("VSH Engine::VSHA_OnMusic() **** Forward Called ****");
#endif
		Call_StartFunction(Storage[client], FuncMusicTimer);
		Call_PushStringEx(sound, sizeof(sound), 0, SM_PARAM_COPYBACK);
		Call_PushFloatRef(time);
		Call_Finish();
	}
#if defined DEBUG
	else
	{
		DEBUGPRINT1("VSH Engine::VSHA_OnMusic() **** Forward Invalid/Not Called ****");
		DEBUGPRINT2("{lime}VSH Engine::VSHA_OnMusic() **** Forward Invalid/Not Called ****");
		DEBUGPRINT3("VSH Engine::VSHA_OnMusic() **** Forward Invalid/Not Called ****");
	}
#endif
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
