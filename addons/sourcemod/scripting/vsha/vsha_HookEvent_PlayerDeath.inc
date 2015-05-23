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
	PawnTimer(CheckAlivePlayers, 0.2); //CreateTimer(0.1, CheckAlivePlayers);
	SetClientOverlay(victim, "");
	if (!bIsBoss[victim])
	{
		CPrintToChat( victim, "{olive}[VSH Engine]{default} Damage dealt: {red}%i{default}. Score for this round: {red}%i{default}", iDamage[victim], RoundFloat(iDamage[victim]/600.0) );
		if (bIsBoss[attacker])
		{
			if ( GetGameTime() <= flKillStreak[attacker] ) iPlayerKilled[attacker][1]++;
			else iPlayerKilled[attacker][1] = 0;

			VSHA_SetVar(SmEvent,event);
			VSHA_SetVar(EventAttacker,attacker);
			VSHA_CreateEvent(OnPlayerKilled, victim);

			if ( iPlayerKilled[attacker][1] >= GetRandomInt(2, 3) )
			{
				VSHA_SetVar(SmEvent,event);
				VSHA_SetVar(EventAttacker,attacker);
				VSHA_CreateEvent(OnKillingSpree, victim);

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

		VSHA_SetVar(SmEvent,event);
		VSHA_SetVar(EventAttacker,attacker);
		VSHA_CreateEvent(OnBossKilled, victim);

		UpdateHealthBar();
		iStabbed[victim] = 0;
		iMarketed[victim] = 0;
		bIsBoss[victim] = false;
	}
	return Plugin_Continue;
}
