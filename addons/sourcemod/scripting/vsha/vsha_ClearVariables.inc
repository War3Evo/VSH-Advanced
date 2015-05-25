// vsha_ClearVariables.inc

public void ClearVariablesRoundStart(int client)
{
	Storage[client] = null;
	iBoss[client] = -1;
	bIsBoss[client] = false;
	iDamage[client] = 0;
	iHits[client] = 0;
	bNoTaunt[client] = false;
	iModelRetrys[client] = 25;
}

public void ClearVariables()
{
	LoopMaxPLYR(player)
	{
		iModelRetrys[player] = 25;
		iPresetBoss[player]=0;
		Storage[player] = null;
		iBoss[player] = -1;
		iPresetBoss[player] = -1;
		bIsBoss[player] = false;
		iDifficulty[player] = 0;
		iDamage[player] = 0;
		iBossesKilled[player] = 0;
		iPlayerKilled[player][0] = 0;
		iPlayerKilled[player][1] = 1;
		iHits[player] = 0;
		bNoTaunt[player] = false;
		iLives[player] = 0;
		iUberedTarget[player] = 0;
		iAirDamage[player] = 0;
		iMarketed[player] = 0;
		iStabbed[player] = 0;
		flCharge[player] = 0.0;
		flKillStreak[player] = 0.0;
		flGlowTimer[player] = 0.0;
		bInJump[player] = false;
	}
	RetryCounter = 10;
}
