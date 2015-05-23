// vsha_PawnTimer_MakeModelTimer.inc

public Action MakeModelTimer(Handle hTimer, any userid)
{
	int client = GetClientOfUserId(userid);
	if ( client <= 0 || CheckRoundState() == 2 || !bIsBoss[client] ) return Plugin_Stop;

	//Action result = Plugin_Continue;

	int result = VSHA_CreateEvent(ModelTimer, client);

	/*
	Function FuncModelTimer = GetFunctionByName(Storage[client], "VSHA_OnModelTimer");
	if (FuncModelTimer != nullfunc)
	{
		Call_StartFunction(Storage[client], FuncModelTimer);
		Call_PushCell(client);
		char model[PATH];
		Call_PushStringEx(model, sizeof(model), 0, SM_PARAM_COPYBACK);
		Call_Finish(result);

		SetVariantString(model);
		AcceptEntityInput(client, "SetCustomModel");
		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
		return result;
	}
	else LogError("**** VSH Engine Error: Cannot find 'VSHA_OnModelTimer' Function ****");
	*/
	return view_as<Action>result;
}
