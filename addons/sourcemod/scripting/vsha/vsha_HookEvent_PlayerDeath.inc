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
	int client = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	PawnTimer(CheckAlivePlayers, 0.2); //CreateTimer(0.1, CheckAlivePlayers);
	SetClientOverlay(client, "");
	if (!bIsBoss[client])
	{
		CPrintToChat( client, "{olive}[VSH Engine]{default} Damage dealt: {red}%i{default}. Score for this round: {red}%i{default}", iDamage[client], RoundFloat(iDamage[client]/600.0) );
		if (bIsBoss[attacker])
		{
			if ( GetGameTime() <= flKillStreak[attacker] ) iPlayerKilled[attacker][1]++;
			else iPlayerKilled[attacker][1] = 0;

			Function FuncPlayerKilled = GetFunctionByName(Storage[attacker], "VSHA_OnPlayerKilled");
			if (FuncPlayerKilled != nullfunc) /*purpose of this forward is for kill specific mechanics*/
			{
#if defined DEBUG
				DEBUGPRINT1("VSH Engine::VSHA_OnPlayerKilled() **** Forward Called ****");
				DEBUGPRINT2("{lime}VSH Engine::VSHA_OnPlayerKilled() **** Forward Called ****");
#endif
				Call_StartFunction(Storage[attacker], FuncPlayerKilled);
				Call_PushCell(attacker);
				Call_PushCell(client);
				Call_Finish();
			}
#if defined DEBUG
			else
			{
				DEBUGPRINT1("VSH Engine::VSHA_OnPlayerKilled() **** Forward Invalid/Not Called ****");
				DEBUGPRINT2("{lime}VSH Engine::VSHA_OnPlayerKilled() **** Forward Invalid/Not Called ****");
			}
#endif

			if ( iPlayerKilled[attacker][1] >= GetRandomInt(2, 3) )
			{
				Function FuncKillSpree = GetFunctionByName(Storage[attacker], "VSHA_OnKillingSpree");
/*purpose of this forward is for killing spree specific mechanics like killing spree boss sound clips*/
				if (FuncKillSpree != nullfunc)
				{
#if defined DEBUG
					DEBUGPRINT1("VSH Engine::VSHA_OnKillingSpree() **** Forward Called ****");
					DEBUGPRINT2("{lime}VSH Engine::VSHA_OnKillingSpree() **** Forward Called ****");
#endif
					Call_StartFunction(Storage[attacker], FuncKillSpree);
					Call_PushCell(attacker);
					Call_PushCell(client);
					Call_Finish();
				}
#if defined DEBUG
				else
				{
					DEBUGPRINT1("VSH Engine::VSHA_OnKillingSpree() **** Forward Invalid/Not Called ****");
					DEBUGPRINT2("{lime}VSH Engine::VSHA_OnKillingSpree() **** Forward Invalid/Not Called ****");
				}
#endif
				iPlayerKilled[attacker][1] = 0;
			}
			else flKillStreak[attacker] = GetGameTime() + 5.0;
			iPlayerKilled[attacker][0]++;
		}
		if (TF2_GetPlayerClass(client) == TFClass_Engineer) //Destroys sentry gun when Engineer dies before it.
		{
			FakeClientCommand(client, "destroy 2");
			int KillSentry = FindSentry(client);
			if ( KillSentry != -1 )
			{
				SetVariantInt(GetEntPropEnt(KillSentry, Prop_Send, "m_iMaxHealth")+1);
				AcceptEntityInput(KillSentry, "RemoveHealth");

				Event engieevent = CreateEvent("object_removed", true);
				engieevent.SetInt("userid", GetClientUserId(client));
				engieevent.SetInt("index", KillSentry);
				engieevent.Fire();
				AcceptEntityInput(KillSentry, "Kill");
			}
		}
	}
	else if (bIsBoss[client] && !bIsBoss[attacker])
	{
		iBossesKilled[attacker]++;
		if ( iBossHealth[client] < 0 ) iBossHealth[client] = 0;

		Function FuncBossKilled = GetFunctionByName(Storage[client], "VSHA_OnBossKilled");
		if (FuncBossKilled != nullfunc)
		{
#if defined DEBUG
			DEBUGPRINT1("VSH Engine::VSHA_OnBossKilled() **** Forward Called ****");
			DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossKilled() **** Forward Called ****");
#endif
			Call_StartFunction(Storage[client], FuncBossKilled);
			Call_PushCell(client);
			Call_PushCell(attacker);
			Call_Finish();
		}
#if defined DEBUG
		else
		{
			DEBUGPRINT1("VSH Engine::VSHA_OnBossKilled() **** Forward Invalid/Not Called ****");
			DEBUGPRINT2("{lime}VSH Engine::VSHA_OnBossKilled() **** Forward Invalid/Not Called ****");
		}
#endif
		UpdateHealthBar();
		iStabbed[client] = 0;
		iMarketed[client] = 0;
		bIsBoss[client] = false;
	}
	return Plugin_Continue;
}
