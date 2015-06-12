// vsha_CreateTimer_tTenSecStart.inc

public Action tTenSecStart(Handle timer, int ofs)
{
	//PrintToChatAll("tTenSecStart Timer");
	bTenSecStart[ofs] = false;
	HandletTenSecStartTimer = null;
}

public Action tTenSecStart2(Handle timer, int ofs)
{
	//PrintToChatAll("tTenSecStart2 Timer");
	bTenSecStart[ofs] = false;
	HandletTenSecStartTimer2 = null;
}
