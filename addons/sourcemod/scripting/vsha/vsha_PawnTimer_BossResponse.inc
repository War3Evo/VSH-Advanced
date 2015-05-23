// vsha_PawnTimer_BossResponse.inc

public void BossResponse()
{
	int client = GetRandomBossIndex();
	Function FuncBossTalk = GetFunctionByName(Storage[client], "VSHA_OnBossIntroTalk");
	if (FuncBossTalk != nullfunc)
	{
#if defined DEBUG
		DEBUGPRINT1("VSH Engine::VSHA_OnBossIntroTalk() **** Forward Called ****");
		DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossIntroTalk() **** Forward Called ****");
		DEBUGPRINT3("VSH Engine::VSHA_OnBossIntroTalk() **** Forward Called ****");
#endif
		Call_StartFunction(Storage[client], FuncBossTalk);
		Call_Finish();
	}
#if defined DEBUG
	else
	{
		DEBUGPRINT1("VSH Engine::VSHA_OnBossIntroTalk() **** Forward Invalid/Not Called ****");
		DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossIntroTalk() **** Forward Invalid/Not Called ****");
		DEBUGPRINT3("VSH Engine::VSHA_OnBossIntroTalk() **** Forward Invalid/Not Called ****");
	}
	DEBUGPRINT1("VSH Engine::BossResponse() **** Boss Response called ****");
	DEBUGPRINT3("VSH Engine::BossResponse() **** Boss Response called ****");
#endif
	return;
}
