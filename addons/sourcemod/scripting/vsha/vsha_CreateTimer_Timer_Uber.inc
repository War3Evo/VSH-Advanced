// vsha_CreateTimer_Timer_Uber.inc

public Action Timer_Uber(Handle timer, any medigunid)
{
	int medigun = EntRefToEntIndex(medigunid);
	if (IsValidEntity(medigun) && CheckRoundState() == 1)
	{
		int medic = GetOwner(medigun);
		if (IsValidClient(medic) && IsPlayerAlive(medic) && GetEntPropEnt(medic, Prop_Send, "m_hActiveWeapon") == medigun)
		{
			int target = GetHealingTarget(medic);
			if ( GetMediCharge(medigun) > 0.05 )
			{
				/*TF2_AddCondition(medic, TFCond_HalloweenCritCandy, 0.5); what's the point in giving the ubering medic crits?*/
				if (IsValidClient(target) && IsPlayerAlive(target))
				{
					TF2_AddCondition(target, TFCond_HalloweenCritCandy, 0.5);
					iUberedTarget[medic] = target;

					int boss = GetFirstBossIndex();
					Function FuncHitUber = GetFunctionByName(Storage[boss], "VSHA_OnUberTimer");
					if (FuncHitUber != nullfunc)
					{
#if defined DEBUG
						DEBUGPRINT1("VSH Engine::VSHA_OnUberTimer() **** Forward Called ****");
						DEBUGPRINT2("{lime}VSH Engine::VSHA_OnUberTimer() **** Forward Called ****");
#endif
						Call_StartFunction(Storage[boss], FuncHitUber);
						Call_PushCell(medic);
						Call_PushCell(target);
						Call_Finish();
					}
#if defined DEBUG
					else
					{
						DEBUGPRINT1("VSH Engine::VSHA_OnUberTimer() **** Forward Invalid/Not Called ****");
						DEBUGPRINT2("{lime}VSH Engine::VSHA_OnUberTimer() **** Forward Invalid/Not Called ****");
					}
#endif
				}
				else iUberedTarget[medic] = -1;
			}
		}
		if ( GetMediCharge(medigun) <= 0.05 )
		{
			PawnTimer(ResetUberCharge, 3.0, EntIndexToEntRef(medigun)); //CreateTimer(3.0, ResetUberCharge, EntIndexToEntRef(medigun));
			return Plugin_Stop;
		}
	}
	else return Plugin_Stop;
	return Plugin_Continue;
}
