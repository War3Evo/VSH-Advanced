// vsha_UpdateHealthBar.inc

public void UpdateHealthBar()
{
	//int dohealth = 0, domaxhealth = 0, bosscount = 0;
	int bosscount = 0;
	iTotalBossHP = 0;
	LoopAlivePlayers(target)
	{
		if ( !IsClientValid(target) || !bIsBoss[target] ) continue;

		//dohealth += iBossHealth[i]-iBossMaxHealth[i];
		//domaxhealth += iBossMaxHealth[i]; iTotalBossHP += iBossHealth[i];
		bosscount++;
	}
	if ( bosscount == 1 )
	{
		if(iHealthBar == -1)
		{
			FindHealthBar();
			if(iHealthBar == -1) return;
		}
		int BossIndex = GetFirstBossIndex();

		int percentage;
		if (BossIndex>0)
		{
			int maxHP = GetEntProp(BossIndex, Prop_Data, "m_iMaxHealth");
			int HP = GetEntProp(BossIndex, Prop_Data, "m_iHealth");

			if (HP <= 0)
			{
				percentage = 0;
			}
			else
			{
				float fHP = view_as<float>(HP);
				float fmaxHP = view_as<float>(maxHP);
				float fHEALTHBAR = view_as<float>(HEALTHBAR_MAX);

				percentage = RoundToCeil(FloatMul(FloatDiv(fHP,fmaxHP),fHEALTHBAR));

				if(percentage>HEALTHBAR_MAX)
				{
					percentage=HEALTHBAR_MAX;
				}
			}
		}
		else
		{
			percentage = 0;
		}
		SetEntProp(iHealthBar, Prop_Send, HEALTHBAR_PROPERTY, percentage);

		/*
		int percenthp = RoundFloat( float(dohealth) / float(domaxhealth) * 255.0 );
		if (percenthp > 255) percenthp = 255;
		else if (percenthp <= 0) percenthp = 1;
		SetEntProp(iHealthBar, Prop_Send, "m_iBossHealthPercentageByte", percenthp);*/
	}
	else if ( bosscount > 1 && iHealthBar != -1)
	{
		if (IsValidEntity(iHealthBar))
		{
			iHealthBar = -1;
			AcceptEntityInput(iHealthBar, "Kill");
		}
	}
}
