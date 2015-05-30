// vsha_000_RegAdminCmd.inc

public void vsha_000_RegAdminCmd_OnPluginStart()
{
	RegAdminCmd("sm_forceboss", Command_forceboss, ADMFLAG_ROOT, "sm_forceboss");
	RegAdminCmd("sm_reloadboss", Command_ReloadBoss, ADMFLAG_ROOT, "sm_reloadboss");
}

public Action Command_ReloadBoss(int client, int args)
{
	Menu pickboss = new Menu(MenuHandler_ReloadBoss);
	pickboss.SetTitle("[VSH Engine] Which Boss to Reload?");
	int count = hArrayBossSubplugins.Length; //GetArraySize(hArrayBossSubplugins);
	for (int i = 0; i < count; i++)
	{
		//GetTrieString(GetArrayCell(hArrayBossSubplugins, i), "BossName", bossnameholder, sizeof(bossnameholder));
		char bossnameholder[32];
		GetTrieString(hArrayBossSubplugins.Get(i), "BossLongName", bossnameholder, sizeof(bossnameholder));
		pickboss.AddItem("pickclass", bossnameholder);
	}
	pickboss.Display(client, MENU_TIME_FOREVER);
}
public int MenuHandler_ReloadBoss(Menu menu, MenuAction action, int client, int selection)
{
	char blahblah[32];
	menu.GetItem(selection, blahblah, sizeof(blahblah));
	if (action == MenuAction_Select)
	{
		char bossnameholder[16];
		GetTrieString(hArrayBossSubplugins.Get(selection), "BossLongName", bossnameholder, sizeof(bossnameholder));
		ReplyToCommand(client, "[VSH Engine] Reloading %s!", bossnameholder);
		//iPresetBoss[client] = selection;

		GetTrieString(hArrayBossSubplugins.Get(selection), "BossShortName", bossnameholder, sizeof(bossnameholder));

		if(RemoveFromTrie(hTrieBossSubplugins, bossnameholder))
		{
			strcopy(STRING(ReloadBossShortName), bossnameholder);
			ReplyToCommand(client, "[VSH Engine] Successful RemoveFromTrie");
		}

		StringMap MyStringMap = hArrayBossSubplugins.Get(selection);

		Handle plugin;
		MyStringMap.GetValue("Subplugin", plugin);

		char hPlugin[PATHX];

		GetPluginFilename(plugin, STRING(hPlugin));

		LoopMaxPLYR(plyrBoss)
		{
			if(Storage[plyrBoss] == plugin)
			{
				Storage[plyrBoss] = null;
				ReloadPlayer[plyrBoss] = true;
			}
			else
			{
				ReloadPlayer[plyrBoss] = false;
			}
		}

		hArrayBossSubplugins.Erase(selection);

		ServerCommand("sm plugins reload %s",hPlugin);

		ReplyToCommand(client, "[VSH Engine] reloading done.");
	}
	else if (action == MenuAction_End) delete menu;
}

public Action Command_forceboss(int client, int args)
{
	if (Enabled && IsClientInGame(client))
	{
		Menu pickboss = new Menu(MenuHandler_ForceBoss);
		//Handle MainMenu = CreateMenu(MenuHandler_Perks);
		pickboss.SetTitle("[VSH Engine] Choose A Boss");
		int count = hArrayBossSubplugins.Length; //GetArraySize(hArrayBossSubplugins);
		for (int i = 0; i < count; i++)
		{
			//GetTrieString(GetArrayCell(hArrayBossSubplugins, i), "BossName", bossnameholder, sizeof(bossnameholder));
			char bossnameholder[32];
			GetTrieString(hArrayBossSubplugins.Get(i), "BossLongName", bossnameholder, sizeof(bossnameholder));
			pickboss.AddItem("pickclass", bossnameholder);
		}
		pickboss.Display(client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}
public int MenuHandler_ForceBoss(Menu menu, MenuAction action, int client, int selection)
{
	char blahblah[32];
	menu.GetItem(selection, blahblah, sizeof(blahblah));
	if (action == MenuAction_Select)
	{
		char bossnameholder[32];
		GetTrieString(hArrayBossSubplugins.Get(selection), "BossLongName", bossnameholder, sizeof(bossnameholder));
		ReplyToCommand(client, "[VSH Engine] You selected %s as your boss!", bossnameholder);
		iPresetBoss[client] = selection;

		SetClientQueuePoints(client, 99999);
	}
	else if (action == MenuAction_End) delete menu;
}
