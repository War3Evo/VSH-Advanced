// vsha_Engine_CacheDownloads.inc

public void CacheDownloads()
{
	Call_StartForward(AddToDownloads);
#if defined DEBUG
	DEBUGPRINT1("VSH Engine::CacheDownloads() **** AddToDownloads Forward Called ****");
	DEBUGPRINT3("VSH Engine::CacheDownloads() **** AddToDownloads Forward Called ****");
#endif
	Call_Finish();
	AddFileToDownloadsTable("sound/saxton_hale/9000.wav");
	PrecacheSound("saxton_hale/9000.wav", true);
	PrecacheSound("vo/announcer_am_capincite01.wav", true);
	PrecacheSound("vo/announcer_am_capincite03.wav", true);
	PrecacheSound("vo/announcer_am_capenabled01.wav", true);
	PrecacheSound("vo/announcer_am_capenabled02.wav", true);
	PrecacheSound("vo/announcer_am_capenabled03.wav", true);
	PrecacheSound("vo/announcer_am_capenabled04.wav", true);
	PrecacheSound("weapons/barret_arm_zap.wav", true);
	PrecacheSound("vo/announcer_ends_2min.wav", true);
	PrecacheSound("player/doubledonk.wav", true);
}
