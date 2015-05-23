// vsha_PawnTimer_MakeModelTimer.inc

public Action MakeModelTimer(Handle hTimer, any userid)
{
	int iClient = GetClientOfUserId(userid);
	if ( iClient <= 0 || CheckRoundState() == 2 || !bIsBoss[iClient] ) return Plugin_Stop;

	char model[PATH];
	StringMap ModelMap = new StringMap();
	ModelMap.SetString("Model", model);

	VSHA_SetVar(EventModel,ModelMap);
	VSHA_SetVar(EventModelTimer,iClient);
	Action result = VSHA_Private_Forward("VSHA_OnModelTimer");
	if(result != Plugin_Stop)
	{
		ModelMap.GetString("Model",STRING(model));
		SetVariantString(model);
		AcceptEntityInput(iClient, "SetCustomModel");
		SetEntProp(iClient, Prop_Send, "m_bUseClassAnimations", 1);
	}

	/*
	Function FuncModelTimer = GetFunctionByName(Storage[iClient], "VSHA_OnModelTimer");
	if (FuncModelTimer != nullfunc)
	{
		Call_StartFunction(Storage[iClient], FuncModelTimer);
		Call_PushCell(iClient);
		char model[PATH];
		Call_PushStringEx(model, sizeof(model), 0, SM_PARAM_COPYBACK);
		Call_Finish(result);

		SetVariantString(model);
		AcceptEntityInput(iClient, "SetCustomModel");
		SetEntProp(iClient, Prop_Send, "m_bUseClassAnimations", 1);
		return result;
	}
	else LogError("**** VSH Engine Error: Cannot find 'VSHA_OnModelTimer' Function ****");
	*/
	return Plugin_Continue;
}
