// vsha_HookEvent_PlayerDeath.inc

public Action PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if ( !Enabled || CheckRoundState() != 1 || (event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER) )
	{
#if defined DEBUG
		DEBUGPRINT1("VSH Engine::PlayerDeath() **** PlayerDeath Skipped ****");
		DEBUGPRINT2("{lime}VSH Engine::PlayerDeath() **** PlayerDeath Skipped ****");
#endif
		return Plugin_Continue;
	}
	int victim = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	CreateTimer(0.2, CheckAlivePlayers);
	SetClientOverlay(victim, "");
	if (!bIsBoss[victim])
	{
		CPrintToChat( victim, "{olive}[VSH Engine]{default} Damage dealt: {red}%i{default}. Score for this round: {red}%i{default}", iDamage[victim], RoundFloat(iDamage[victim]/600.0) );
		if (bIsBoss[attacker])
		{
			if ( GetGameTime() <= flKillStreak[attacker] ) iPlayerKilled[attacker][1]++;
			else iPlayerKilled[attacker][1] = 0;

			//VSHA_SetVar(EventBoss,victim);
			//VSHA_SetVar(EventAttacker,attacker);
			//VSHA_Private_Forward("VSHA_OnPlayerKilledByBoss");

			VSHA_OnPlayerKilledByBoss(victim,attacker);

			if ( iPlayerKilled[attacker][1] >= GetRandomInt(2, 3) )
			{
				//VSHA_SetVar(EventBoss,victim);
				//VSHA_SetVar(EventAttacker,attacker);
				//VSHA_Private_Forward("VSHA_OnKillingSpreeByBoss");

				VSHA_OnKillingSpreeByBoss(victim, attacker);

				iPlayerKilled[attacker][1] = 0;
			}
			else flKillStreak[attacker] = GetGameTime() + 5.0;
			iPlayerKilled[attacker][0]++;
		}
		if (TF2_GetPlayerClass(victim) == TFClass_Engineer) //Destroys sentry gun when Engineer dies before it.
		{
			FakeClientCommand(victim, "destroy 2");
			int KillSentry = FindSentry(victim);
			if ( KillSentry != -1 )
			{
				SetVariantInt(GetEntPropEnt(KillSentry, Prop_Send, "m_iMaxHealth")+1);
				AcceptEntityInput(KillSentry, "RemoveHealth");

				Event engieevent = CreateEvent("object_removed", true);
				engieevent.SetInt("userid", GetClientUserId(victim));
				engieevent.SetInt("index", KillSentry);
				engieevent.Fire();
				AcceptEntityInput(KillSentry, "Kill");
			}
		}
	}
	else if (bIsBoss[victim] && !bIsBoss[attacker])
	{
		iBossesKilled[attacker]++;
		if ( iBossHealth[victim] < 0 ) iBossHealth[victim] = 0;

		//VSHA_SetVar(EventBoss,victim);
		//VSHA_SetVar(EventAttacker,attacker);
		//VSHA_Private_Forward("VSHA_OnBossKilled");

		// Create the illusion the boss was killed!
		float vecAngles[3];
		float Origin[3], Direction[3];
		GetClientEyeAngles(victim,vecAngles);
		GetClientAbsOrigin(victim, Origin);

		VSHA_TE_SetupBloodSprite(Origin, vecAngles, {0, 0, 255, 255}, 28, BloodSpraymodelEntity, BloodDropmodelEntity);
		Direction[0] = GetRandomFloat(-100.0, 100.0);
		Direction[1] = GetRandomFloat(-100.0, 100.0);
		Direction[2] = 300.0;
		Gib(Origin, Direction, GIBmodel);
		TE_SendToAll(0.0);

		VSHA_OnBossKilled(victim, attacker);

		SDKUnhook(victim, SDKHook_GetMaxHealth, OnGetMaxHealth);

		UpdateHealthBar();
		iStabbed[victim] = 0;
		iMarketed[victim] = 0;
		bIsBoss[victim] = false;
	}
	return Plugin_Continue;
}
