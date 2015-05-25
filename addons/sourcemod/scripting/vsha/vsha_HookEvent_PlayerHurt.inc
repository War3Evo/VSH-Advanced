// vsha_HookEvent_PlayerHurt.inc

public Action PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	if ( !Enabled )
	{
#if defined DEBUG
		DEBUGPRINT1("VSH Engine::PlayerHurt() **** PlayerHurt Skipped ****");
		DEBUGPRINT2("{lime}VSH Engine::PlayerHurt() **** PlayerHurt Skipped ****");
#endif
		return Plugin_Continue;
	}
	int client = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int damage = event.GetInt("damageamount");

	if(ValidPlayer(client))
	{
		if (bIsBoss[client])
		{
			UpdateHealthBar();
			if (client == attacker) return Plugin_Continue;
			if (event.GetBool("minicrit") && event.GetBool("allseecrit")) event.SetBool("allseecrit", false);
			iBossHealth[client] -= damage;
			iDamage[attacker] += damage;

			int iHealers[MAXPLAYERS];
			int iHealerCount;
			int target;
			for (target = 1; target <= MaxClients; target++)
			{
				if ( IsValidClient(target) && IsPlayerAlive(target) && (GetHealingTarget(target) == attacker) )
				{
					iHealers[iHealerCount] = target;
					iHealerCount++;
				}
			}

			for (target = 0; target < iHealerCount; target++)
			{
				if (IsValidClient(iHealers[target]) && IsPlayerAlive(iHealers[target]))
				{
					if (damage < 10 || iUberedTarget[iHealers[target]] == attacker) iDamage[iHealers[target]] += damage;
					else iDamage[iHealers[target]] += damage/(iHealerCount+1);
				}
			}
			if (ValidPlayer(attacker) && TF2_GetPlayerClass(attacker) == TFClass_Soldier && GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Primary) == 1104)
			{
				iAirDamage[attacker] += damage;
				SetEntProp(attacker, Prop_Send, "m_iDecapitations", iAirDamage[attacker]/200);
			}
		}
		else iDamage[attacker] += damage; //increment boss' dmg
		iHits[client]++;
	}
	return Plugin_Continue;
}
