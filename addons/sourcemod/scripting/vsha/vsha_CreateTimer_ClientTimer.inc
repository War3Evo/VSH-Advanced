// vsha_CreateTimer_ClientTimer.inc

public Action ClientTimer(Handle hTimer)
{
	if (CheckRoundState() > 1 || CheckRoundState() == -1) return Plugin_Stop;
	for (int i = 1; i <= MaxClients; i++)
        {
		if (IsValidClient(i) && !bIsBoss[i] && GetClientTeam(i) == OtherTeam) continue;
		char wepclassname[32];
		//int killstreaker = iDamage[i] / 500;
		//if (killstreaker >= 1) SetEntProp(i, Prop_Send, "m_iKillStreak", killstreaker);
		PlayerHUD(i);
		TFClassType class = TF2_GetPlayerClass(i);
		int weapon = GetEntPropEnt(i, Prop_Send, "m_hActiveWeapon");
		int index = GetItemIndex(weapon);
		if (TF2_IsPlayerInCondition(i, TFCond_Cloaked))
		{
			if (GetClientCloakIndex(i) == 59)
			{
				if (TF2_IsPlayerInCondition(i, TFCond_DeadRingered)) TF2_RemoveCondition(i, TFCond_DeadRingered);
			}
			else TF2_AddCondition(i, TFCond_DeadRingered, 0.3);
		}
		if ( iRedAlivePlayers == 1 && !TF2_IsPlayerInCondition(i, TFCond_Cloaked) )
		{
			TF2_AddCondition(i, TFCond_HalloweenCritCandy, 0.3);
			int primary = GetPlayerWeaponSlot(i, TFWeaponSlot_Primary);
			if (class == TFClass_Engineer && weapon == primary && StrEqual(wepclassname, "tf_weapon_sentry_revenge", false)) SetEntProp(i, Prop_Send, "m_iRevengeCrits", 3);

			TF2_AddCondition(i, TFCond_Buffed, 0.3);

			int boss = GetRandomBossIndex();
			Function FuncLastSurvivorLoop = GetFunctionByName(Storage[boss], "VSHA_OnLastSurvivorLoop");
			if (FuncLastSurvivorLoop != nullfunc)
			{
#if defined DEBUG
				DEBUGPRINT1("VSH Engine::VSHA_OnLastSurvivorLoop() **** Forward Called ****");
				DEBUGPRINT2("{lime}VSH Engine::VSHA_OnLastSurvivorLoop() **** Forward Called ****");
#endif
				Call_StartFunction(Storage[boss], FuncLastSurvivorLoop);
				Call_PushCell(i);
				Call_Finish();
			}
#if defined DEBUG
			else
			{
				DEBUGPRINT1("VSH Engine::VSHA_OnLastSurvivorLoop() **** Forward Invalid/Not Called ****");
				DEBUGPRINT2("{lime}VSH Engine::VSHA_OnLastSurvivorLoop() **** Forward Invalid/Not Called ****");
			}
#endif
			//if (bAllowSuperWeap && HaleHealth >= 7000) PickSuperWeapon(i, -1); later
			continue;
		}
		if ( iRedAlivePlayers == 2 && !TF2_IsPlayerInCondition(i, TFCond_Cloaked) ) TF2_AddCondition(i, TFCond_Buffed, 0.3);

		//==============================	C R I T S  P A R T S	   =============================================
		TFCond cond = TFCond_HalloweenCritCandy;
		if (TF2_IsPlayerInCondition(i, TFCond_CritCola) && (class == TFClass_Scout || class == TFClass_Heavy))
		{
			TF2_AddCondition(i, cond, 0.3);
			continue;
		}
		bool EnableCrits[2] = {false, false}; //0 - minicrits, 1 - full crits
		for (int e = 1; e <= MaxClients; e++)
		{
			if ( (0 < e && e <= MaxClients) && IsPlayerAlive(e) && GetHealingTarget(e) == i )
			{
				EnableCrits[0] = true;
				break;
			}
		}
		if (weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Melee))
		{
			//slightly longer check but makes sure that any weapon that can backstab will not crit (e.g. Saxxy)
			if (strcmp(wepclassname, "tf_weapon_knife", false) != 0 && index != 416) EnableCrits[1] = true;
		}
		switch (index)
		{
			case 305, 1079, 1081, 56, 16, 203, 58, 1083, 1105, 1100, 1005, 1092, 812, 833, 997, 39, 351, 740, 588, 595: //Critlist
			{
				int flindex = GetIndexOfWeaponSlot(i, TFWeaponSlot_Primary);
				// No crits if using phlog
				if (TF2_GetPlayerClass(i) == TFClass_Pyro && flindex == 594) EnableCrits[1] = false;
				else EnableCrits[1] = true;
			}
			case 22, 23, 160, 209, 294, 449, 773:
			{
				EnableCrits[1] = true;
				if (class == TFClass_Scout && cond == TFCond_HalloweenCritCandy) cond = TFCond_Buffed;
			}
			case 656:
			{
				EnableCrits[1] = true;
				cond = TFCond_Buffed;
			}
		}
		if (index == 16 && EnableCrits[1] && IsValidEntity(FindPlayerBack(i, { 642 }, 1))) EnableCrits[1] = false;
		switch (class)
		{
			case TFClass_Spy:
			{
				if (weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Primary))
				{
					if (!TF2_IsPlayerCritBuffed(i) && !TF2_IsPlayerInCondition(i, TFCond_Buffed) && !TF2_IsPlayerInCondition(i, TFCond_Cloaked) && !TF2_IsPlayerInCondition(i, TFCond_Disguised) && !GetEntProp(i, Prop_Send, "m_bFeignDeathReady"))
					{
						TF2_AddCondition(i, TFCond_CritCola, 0.3);
					}
				}
			}
			case TFClass_Engineer:
			{
				if (weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Primary) && StrEqual(wepclassname, "tf_weapon_sentry_revenge", false))
				{
					int sentry = FindSentry(i);
					if (IsValidEntity(sentry))
					{
						int TargettedBoss = GetEntPropEnt(sentry, Prop_Send, "m_hEnemy");
						if (bIsBoss[TargettedBoss])
						{
							SetEntProp(i, Prop_Send, "m_iRevengeCrits", 3);
							TF2_AddCondition(i, TFCond_Kritzkrieged, 0.3);
						}
					}
					else
					{
						if (GetEntProp(i, Prop_Send, "m_iRevengeCrits")) SetEntProp(i, Prop_Send, "m_iRevengeCrits", 0);
						else if (TF2_IsPlayerInCondition(i, TFCond_Kritzkrieged) && !TF2_IsPlayerInCondition(i, TFCond_Healing))
						{
							TF2_RemoveCondition(i, TFCond_Kritzkrieged);
						}
					}
				}
			}
			case TFClass_Medic:
			{
				if (weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary))
				{
					int healtarget = GetHealingTarget(i);
					if (IsValidClient(healtarget) && TF2_GetPlayerClass(healtarget) == TFClass_Scout)
					{
						TF2_AddCondition(i, TFCond_SpeedBuffAlly, 0.3);
					}
				}
			}
			case TFClass_DemoMan:
			{
				if (!IsValidEntity(GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary)))
				{
					EnableCrits[1] = true;
					/*if (!bDemoShieldCrits &&GetEntPropEnt(i, Prop_Send, "m_hActiveWeapon") != GetPlayerWeaponSlot(i, TFWeaponSlot_Melee)) cond = TFCond_Buffed;*/
				}
			}
		}
		if (EnableCrits[1])
		{
			TF2_AddCondition(i, cond, 0.3);
			if (EnableCrits[0] && cond != TFCond_Buffed) TF2_AddCondition(i, TFCond_Buffed, 0.3);
		}
	}
	return Plugin_Continue;
}
