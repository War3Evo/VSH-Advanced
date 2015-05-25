// vsha_PawnTimer_InitBoss.inc

public void InitBoss()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && bIsBoss[i])
		{
			bNoTaunt[i] = false;
			PawnTimer(MakeBoss, 0.2, iBossUserID[i]); //CreateTimer(0.2, MakeBoss, iBossUserID[i]);
		}
	}
#if defined DEBUG
	DEBUGPRINT1("VSH Engine::InitBoss() **** Player loop finished ****");
	DEBUGPRINT3("VSH Engine::InitBoss() **** Player loop finished ****");
#endif
}
