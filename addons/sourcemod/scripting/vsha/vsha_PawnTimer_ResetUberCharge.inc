// vsha_PawnTimer_ResetUberCharge.inc

public void ResetUberCharge(int medigunid)
{
	int medigun = EntRefToEntIndex(medigunid);
	if ( IsValidEntity(medigun) ) SetMediCharge(medigun, GetMediCharge(medigun)+MedigunReset.FloatValue); //GetConVarFloat(MedigunReset)); //40.0
}
