#pragma semicolon 1
#include <sourcemod>
//#include <sdkhooks>
#include <morecolors>
#include <vsha>
#include <vsha_stocks>

public Plugin myinfo =
{
	name			= "Vagineer",
	author			= "J16FOX2",
	description		= "!pu raeg taht evom ottaG",
	version			= "1.0",
	url				= "http://tf2freakshow.wikia.com/wiki/Vagineer"
}

int iThisPlugin = -1; //DO NOT TOUCH THIS, THIS IS USED TO IDENTIFY THIS BOSS PLUGIN.

#define ThisConfigurationFile "configs/vsha/vagineer.cfg"

#define HALE_JUMPCHARGE			5
#define HALE_JUMPCHARGETIME		100

char VagiModel[PATHX];
char VagiModelPrefix[PATHX];

char VagineerLastA[PATHX];
char VagineerStart[PATHX];
char VagineerRageSound[PATHX];
char VagineerKSpree[PATHX];
char VagineerKSpree2[PATHX];
char VagineerHit[PATHX];

//===New Vagineer's responces===
char VagineerRoundStart[PATHX];
char VagineerJump[PATHX];			//	1-2
char VagineerRageSound2[PATHX];		//	1-2
char VagineerKSpreeNew[PATHX];		//	1-5
char VagineerFail[PATHX];			//	1-2

char VagineerTheme[PATHX];

//make defines, handles, variables heer lololol
int HaleCharge[PLYR];

int HaleChargeCoolDown[PLYR];

float UberRageCount[PLYR];

int defaulttakedamagetype[PLYR];

float WeighDownTimer = 0.0;
float RageDist = 800.0;

public void OnPluginStart()
{
	//AutoExecConfig(true, "VSHA-Boss-Vagineer");
#if defined DEBUG
	DEBUGPRINT1("VSH Engine::OnPluginStart() **** loaded VSHA Subplugin ****");
#endif
}
public void Load_VSHAHooks()
{
	if(!VSHAHookEx(VSHAHook_OnBossIntroTalk, OnBossIntroTalk))
	{
		LogError("Error loading VSHAHook_OnBossIntroTalk forwards for vagineer.");
	}
	if(!VSHAHookEx(VSHAHook_OnPlayerKilledByBoss, OnPlayerKilledByBoss))
	{
		LogError("Error loading VSHAHook_OnPlayerKilledByBoss forwards for vagineer.");
	}
	if(!VSHAHookEx(VSHAHook_OnKillingSpreeByBoss, OnKillingSpreeByBoss))
	{
		LogError("Error loading VSHAHook_OnKillingSpreeByBoss forwards for vagineer.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossKilled, OnBossKilled))
	{
		LogError("Error loading VSHAHook_OnBossKilled forwards for vagineer.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossWin, OnBossWin))
	{
		LogError("Error loading VSHAHook_OnBossWin forwards for vagineer.");
	}
	/*if(!VSHAHookEx(VSHAHook_OnBossKillBuilding, OnBossKillBuilding))
	{
		LogError("Error loading VSHAHook_OnBossKillBuilding forwards for vagineer.");
	}*/
	if(!VSHAHookEx(VSHAHook_OnBossAirblasted, OnBossAirblasted))
	{
		LogError("Error loading VSHAHook_OnBossAirblasted forwards for vagineer.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossChangeClass, OnChangeClass))
	{
		LogError("Error loading VSHAHook_OnBossChangeClass forwards for vagineer.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossSetHP, OnBossSetHP))
	{
		LogError("Error loading VSHAHook_OnBossSetHP forwards for vagineer.");
	}
	if(!VSHAHookEx(VSHAHook_OnLastSurvivor, OnLastSurvivor))
	{
		LogError("Error loading VSHAHook_OnLastSurvivor forwards for vagineer.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossTimer, OnBossTimer))
	{
		LogError("Error loading VSHAHook_OnBossTimer forwards for vagineer.");
	}
	if(!VSHAHookEx(VSHAHook_OnPrepBoss, OnPrepBoss))
	{
		LogError("Error loading VSHAHook_OnPrepBoss forwards for vagineer.");
	}
	if(!VSHAHookEx(VSHAHook_OnMusic, OnMusic))
	{
		LogError("Error loading VSHAHook_OnMusic forwards for vagineer.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossRage, OnBossRage))
	{
		LogError("Error loading VSHAHook_OnBossRage forwards for vagineer.");
	}
	if(!VSHAHookEx(VSHAHook_OnGameOver, OnGameOver))
	{
		LogError("Error loading VSHAHook_OnGameOver forwards for vagineer.");
	}
	if(!VSHAHookEx(VSHAHook_ShowBossHelpMenu, OnShowBossHelpMenu))
	{
		LogError("Error loading VSHAHook_ShowBossHelpMenu forwards for vagineer.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossStabbedPost, OnBossStabbedPost))
	{
		LogError("Error loading VSHAHook_OnBossStabbedPost forwards for vagineer.");
	}
}

public void UnLoad_VSHAHooks()
{
	if(!VSHAUnhookEx(VSHAHook_OnBossIntroTalk, OnBossIntroTalk))
	{
		LogError("Error unloading VSHAHook_OnBossIntroTalk forwards for vagineer.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnPlayerKilledByBoss, OnPlayerKilledByBoss))
	{
		LogError("Error unloading VSHAHook_OnPlayerKilledByBoss forwards for vagineer.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnKillingSpreeByBoss, OnKillingSpreeByBoss))
	{
		LogError("Error unloading VSHAHook_OnKillingSpreeByBoss forwards for vagineer.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnBossKilled, OnBossKilled))
	{
		LogError("Error unloading VSHAHook_OnBossKilled forwards for vagineer.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnBossWin, OnBossWin))
	{
		LogError("Error unloading VSHAHook_OnBossWin forwards for vagineer.");
	}
	/*if(!VSHAUnhookEx(VSHAHook_OnBossKillBuilding, OnBossKillBuilding))
	{
		LogError("Error unloading VSHAHook_OnBossKillBuilding forwards for vagineer.");
	}*/
	if(!VSHAUnhookEx(VSHAHook_OnBossAirblasted, OnBossAirblasted))
	{
		LogError("Error unloading VSHAHook_OnBossAirblasted forwards for vagineer.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnBossChangeClass, OnChangeClass))
	{
		LogError("Error unloading VSHAHook_OnBossChangeClass forwards for vagineer.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnBossSetHP, OnBossSetHP))
	{
		LogError("Error unloading VSHAHook_OnBossSetHP forwards for vagineer.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnLastSurvivor, OnLastSurvivor))
	{
		LogError("Error unloading VSHAHook_OnLastSurvivor forwards for vagineer.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnBossTimer, OnBossTimer))
	{
		LogError("Error unloading VSHAHook_OnBossTimer forwards for vagineer.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnPrepBoss, OnPrepBoss))
	{
		LogError("Error unloading VSHAHook_OnPrepBoss forwards for vagineer.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnMusic, OnMusic))
	{
		LogError("Error unloading VSHAHook_OnMusic forwards for vagineer.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnBossRage, OnBossRage))
	{
		LogError("Error unloading VSHAHook_OnBossRage forwards for vagineer.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnGameOver, OnGameOver))
	{
		LogError("Error unloading VSHAHook_OnGameOver forwards for vagineer.");
	}
	if(!VSHAUnhookEx(VSHAHook_ShowBossHelpMenu, OnShowBossHelpMenu))
	{
		LogError("Error unloading VSHAHook_ShowBossHelpMenu forwards for vagineer.");
	}
}

public void OnAllPluginsLoaded()
{
	iThisPlugin = VSHA_RegisterBoss("vagineer", "Vagineer");

	if(!VSHAHookEx(VSHAHook_OnBossSelected, OnBossSelected))
	{
		LogError("Error loading VSHAHook_OnBossSelected forwards for vagineer.");
	}
	if(!VSHAHookEx(VSHAHook_OnConfiguration_Load_Sounds, OnConfiguration_Load_Sounds))
	{
		LogError("Error loading VSHAHook_OnConfiguration_Load_Sounds forwards for vagineer.");
	}
	if(!VSHAHookEx(VSHAHook_OnConfiguration_Load_Materials, OnConfiguration_Load_Materials))
	{
		LogError("Error loading VSHAHook_OnConfiguration_Load_Materials forwards for vagineer.");
	}
	if(!VSHAHookEx(VSHAHook_OnConfiguration_Load_Models, OnConfiguration_Load_Models))
	{
		LogError("Error loading VSHAHook_OnConfiguration_Load_Models forwards for vagineer.");
	}

	// LoadConfiguration ALWAYS after VSHAHook
	VSHA_LoadConfiguration(ThisConfigurationFile);
}
//public void OnPluginEnd()
//{
	//if(ThisPluginHandle != null)
	//{
		//VSHA_UnRegisterBoss("saxtonhale");
	//}
//}
public void OnMapStart()
{
	PrecacheParticleSystem("ghost_appearation");
	PrecacheParticleSystem("yikes_fx");
}
public void OnMapEnd()
{
	WeighDownTimer = 0.0;
	RageDist = 800.0;

	LoopMaxPLYR(player)
	{
		HaleCharge[player] = 0;
	}
}


//public void OnClientDisconnect(int client)
//{
	//if(VSHA_GetBossHandle(iiBoss)!=ThisPluginHandle) return;

	//bool see[PLYR];
	//see[client] = true;
	//int tHale;
	//if (VSHA_GetPresetBossPlayer() > 0) tHale = VSHA_GetPresetBossPlayer();
	//else tHale = VSHA_FindNextBoss( see, sizeof(see) );
	//if (IsValidClient(tHale))
	//{
		//if (GetClientTeam(tHale) != 3)
		//{
			//ForceTeamChange(Hale[client], 3);
			//DP("vsha-saxtonhale 166 ForceTeamChange(i, 3)");
		//}
	//}
//}
public void OnChangeClass(int iBossArrayListIndex, Event event, int iiBoss)
{
	if (iThisPlugin != iBossArrayListIndex) return;

	if (TF2_GetPlayerClass(iiBoss) != TFClass_Engineer) TF2_SetPlayerClass(iiBoss, TFClass_Engineer, _, false);
	TF2_RemovePlayerDisguise(iiBoss);
}

public void OnPlayerKilledByBoss(int iBossArrayListIndex, int iiBoss, int attacker)
{
	if (iThisPlugin != iBossArrayListIndex) return;
	char playsound[PATHX];
	strcopy(playsound, PLATFORM_MAX_PATH, "");
	strcopy(playsound, PLATFORM_MAX_PATH, VagineerHit);
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(playsound, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public void OnKillingSpreeByBoss(int iBossArrayListIndex, int iiBoss, int attacker)
{
	if (iThisPlugin != iBossArrayListIndex) return;
	char playsound[PATHX];

	if (GetRandomInt(0, 4) == 1)
		strcopy(playsound, PLATFORM_MAX_PATH, VagineerKSpree);
	else if (GetRandomInt(0, 3) == 1)
		strcopy(playsound, PLATFORM_MAX_PATH, VagineerKSpree2);
	else
		Format(playsound, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, GetRandomInt(1, 5));

	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public void OnBossKilled(int iBossArrayListIndex, int iiBoss, int attacker) //victim is boss
{
	if (iThisPlugin != iBossArrayListIndex) return;
	char playsound[PATHX];

	Format(playsound, PLATFORM_MAX_PATH, "%s%i.wav", VagineerFail, GetRandomInt(1, 2));
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iiBoss, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public void OnBossWin(int iBossArrayListIndex, Event event, int iiBoss)
{
	if (iThisPlugin != iBossArrayListIndex) return;
	char playsound[PATHX];

	Format(playsound, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, GetRandomInt(1, 5));
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientValid(i)) continue;
		StopSound(i, SNDCHAN_AUTO, VagineerTheme);
	}
}
public void OnGameOver() // best play to reset all variables
{
	LoopMaxPLYR(players)
	{
		HaleCharge[players]=0;
		//InRage[players]=false;

		if(ValidPlayer(players))
		{
			StopSound(players, SNDCHAN_AUTO, VagineerTheme);
		}
	}
	// Dynamically unload private forwards
	//UnLoad_VSHAHooks();
}
/*public void OnBossKillBuilding(int iBossArrayListIndex, Event event, int iiBoss)
{
	if (iThisPlugin != iBossArrayListIndex) return;

	if ( !GetRandomInt(0, 4) )
	{
		char playsound[PATHX];
		strcopy(playsound, PLATFORM_MAX_PATH, HaleSappinMahSentry132);
		EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iiBoss, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iiBoss, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	}
}*/
public void OnBossAirblasted(int iBossArrayListIndex, Event event, int iiBoss)
{
	if (iThisPlugin != iBossArrayListIndex) return;
	//float rage = 0.04*RageDMG;
	//HaleRage += RoundToCeil(rage);
	//if (HaleRage > RageDMG) HaleRage = RageDMG;
	VSHA_SetBossRage(iiBoss, VSHA_GetBossRage(iiBoss)+4.0); //make this a convar/cvar!
}
public void OnBossSelected(int iBossArrayListIndex, int iiBoss)
{
	if(iBossArrayListIndex!=iThisPlugin)
	{
		// reset variables
		HaleCharge[iiBoss]=0;
		VSHA_SetBossRageLimit(iiBoss, 999999.0);
		//InRage[iiBoss]=false;
		return;
	}

	//CPrintToChatAll("%s, Vagineer Selected!",VSHA_COLOR);

	// Dynamically load private forwards
	VSHA_SetBossRageLimit(iiBoss, 100.0);
	Load_VSHAHooks();
}
public void OnBossIntroTalk()
{
	char playsound[PATHX];
	if (!GetRandomInt(0, 1))
		strcopy(playsound, PLATFORM_MAX_PATH, VagineerStart);
	else
		strcopy(playsound, PLATFORM_MAX_PATH, VagineerRoundStart);
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public Action OnBossSetHP(int iBossArrayListIndex, int BossEntity, int &BossMaxHealth)
{
	if (iThisPlugin != iBossArrayListIndex) return Plugin_Continue;
	BossMaxHealth = HealthCalc( 760.8, float( VSHA_GetPlayerCount() ), 1.0, 1.0341, 2046.0 );
	//VSHA_SetBossMaxHealth(Hale[BossEntity], BossMax);
	return Plugin_Changed;
}
public void OnLastSurvivor()
{
	char playsound[PATHX];
	strcopy(playsound, PLATFORM_MAX_PATH, VagineerLastA);
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public void OnBossTimer(int iBossArrayListIndex, int iiBoss, int &curHealth, int &curMaxHp, int buttons, Handle hHudSync, Handle hHudSync2)
{
	if (iThisPlugin != iBossArrayListIndex) return;

	char playsound[PATHX];
	float speed;
	//int curHealth = VSHA_GetBossHealth(iiBoss), curMaxHp = VSHA_GetBossMaxHealth(iiBoss);
	// temporary health fix
	if (curHealth < 0)
	{
		ForcePlayerSuicide(iiBoss);
		return;
	}
	if(GetClientHealth(iiBoss) != curHealth)
	{
		SetEntityHealth(iiBoss,curHealth);
	}
	if (curHealth <= curMaxHp) speed = 340.0 + 0.7 * (100.0-float(curHealth)*100.0/float(curMaxHp)); //convar/cvar for speed here!
	SetEntPropFloat(iiBoss, Prop_Send, "m_flMaxspeed", speed);

	//int buttons = GetClientButtons(iiBoss);
	if (HaleChargeCoolDown[iiBoss] <= GetTime())
	{
		if ( ((buttons & IN_DUCK) || (buttons & IN_ATTACK2)) && HaleCharge[iiBoss] >= 0 )
		{
			if (HaleCharge[iiBoss] + 5 < HALE_JUMPCHARGE) HaleCharge[iiBoss] += 5;
			else HaleCharge[iiBoss] = HALE_JUMPCHARGE;
			if (!(buttons & IN_SCORE))
			{
				SetHudTextParams(-1.0, 0.70, HudTextScreenHoldTime, 90, 255, 90, 200, 0, 0.0, 0.0, 0.0);
				ShowHudText(iiBoss, -1, "Jump Charge: %i%", HaleCharge[iiBoss]);
			}
		}
		// 5 * 60 = 300
		// 5 * .2 = 1 second, so 5 times number of seconds equals number for HaleCharge after superjump
		// 300 = 1 minute wait
		float ExtraBoost = float(HaleCharge[iiBoss]) * 2;
		if ( HaleCharge[iiBoss] > 1 && SuperJump(iiBoss, ExtraBoost, -15.0, HaleCharge[iiBoss], -150) ) //put convar/cvar for jump sensitivity here!
		{
			HaleChargeCoolDown[iiBoss] = GetTime()+3;
			Format(playsound, PLATFORM_MAX_PATH, "%s%i.wav", VagineerJump, GetRandomInt(1, 2));
			EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iiBoss, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		}
	}
	else
	{
		HaleCharge[iiBoss] = 0;
		if (!(buttons & IN_SCORE))
		{
			SetHudTextParams(-1.0, 0.75, HudTextScreenHoldTime, 90, 255, 90, 200, 0, 0.0, 0.0, 0.0);
			ShowHudText(iiBoss, -1, "Super Jump will be ready again in: %i", (-HaleCharge[iiBoss]/10));
		}
	}

	int iAlivePlayers;
	LoopAlivePlayers(alivePlayers)
	{
		++iAlivePlayers;
	}
	float AddToRage = 0.0;//VSHA_GetBossRage(iiBoss);

	if (iAlivePlayers > 12)
	{
		//PrintCenterTextAll("Saxton Hale's Current Health is: %i of %i", curHealth, curMaxHp);
		AddToRage += 0.5;
	}
	else if(iAlivePlayers > 1)
	{
		//AddToRage += (float((MaxClients + 1) - iAlivePlayers) * 0.001);
		AddToRage += float(iAlivePlayers) * 0.001;
	}
	int iGetOtherTeam = GetClientTeam(iiBoss) == 2 ? 3:2;
	if ( OnlyScoutsLeft(iGetOtherTeam ) )
	{
		AddToRage += 1.0;
		//VSHA_SetBossRage(iiBoss, VSHA_GetBossRage(iiBoss)+0.5);
	}
	if(AddToRage > 0)
	{
		VSHA_SetBossRage(iiBoss, (VSHA_GetBossRage(iiBoss)+AddToRage));
	}

	if ( !(GetEntityFlags(iiBoss) & FL_ONGROUND) ) WeighDownTimer += 0.2;
	else WeighDownTimer = 0.0;

	if ( (buttons & IN_DUCK) && Weighdown(iiBoss, WeighDownTimer, 60.0, 0.0) )
	{
		//CPrintToChat(client, "{olive}[VSHE]{default} You just used your weighdown!");
		//all this just to do a cprint? It's not like weighdown has a limit...
	}
}
public void OnPrepBoss(int iBossArrayListIndex, int iiBoss)
{
	if (iThisPlugin != iBossArrayListIndex) return;
	
	TF2_SetPlayerClass(iiBoss, TFClass_Engineer, _, false);
	HaleCharge[iiBoss] = 0;

	TF2_RemoveAllWeapons2(iiBoss);
	TF2_RemovePlayerDisguise(iiBoss);

	bool pri = IsValidEntity(GetPlayerWeaponSlot(iiBoss, TFWeaponSlot_Primary));
	bool sec = IsValidEntity(GetPlayerWeaponSlot(iiBoss, TFWeaponSlot_Secondary));
	bool mel = IsValidEntity(GetPlayerWeaponSlot(iiBoss, TFWeaponSlot_Melee));

	if (pri || sec || !mel)
	{
		TF2_RemoveAllWeapons2(iiBoss);
		char attribs[PATH];
		Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 3.0 ; 259 ; 1.0 ; 436 ; 1.0 ; 214 ; %d", GetRandomInt(999, 9999));
		int VagiWeapon = SpawnWeapon(iiBoss, "tf_weapon_wrench", 197, 100, 4, attribs);
		SetEntProp(VagiWeapon, Prop_Send, "m_iWorldModelIndex", -1);
		SetEntProp(VagiWeapon, Prop_Send, "m_nModelIndexOverrides", -1, _, 0);
		SetEntPropEnt(iiBoss, Prop_Send, "m_hActiveWeapon", VagiWeapon);
	}
}
public Action OnMusic(int iBossArrayListIndex, int iiBoss, char BossTheme[PATHX], float &ftime)
{
	if (iThisPlugin != iBossArrayListIndex) return Plugin_Continue;

	if (iiBoss<0)
	{
		return Plugin_Continue;
	}
	BossTheme = VagineerTheme;
	ftime = 199.0;
	
	return Plugin_Continue;
}
bool InRage[PATHX];
public void OnBossRage(int iBossArrayListIndex, int iiBoss)
{
	if (iThisPlugin != iBossArrayListIndex) return;
	if (InRage[iiBoss]) return;
	// Helps prevent multiple rages
	InRage[iiBoss] = true;
	char playsound[PATHX];
	float pos[3];
	GetEntPropVector(iiBoss, Prop_Send, "m_vecOrigin", pos);
	pos[2] += 20.0;
	TF2_AddCondition(iiBoss, view_as<TFCond>(42), 4.0);
	if (GetRandomInt(0, 2))
		strcopy(playsound, PLATFORM_MAX_PATH, VagineerRageSound);
	else
		Format(playsound, PLATFORM_MAX_PATH, "%s%i.wav", VagineerRageSound2, GetRandomInt(1, 2));
	EmitSoundToAll(playsound, iiBoss, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iiBoss, pos, NULL_VECTOR, true, 0.0);
	EmitSoundToAll(playsound, iiBoss, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iiBoss, pos, NULL_VECTOR, true, 0.0);

	TF2_AddCondition(iiBoss, TFCond_Ubercharged, 99.0);
	UberRageCount[iiBoss] = 0.0;

	CreateTimer(0.6, UseRage, iiBoss);
	CreateTimer(0.1, UseUberRage, iiBoss, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}
public void TF2_OnConditionAdded(int client, TFCond condition)
{
	if(VSHA_GetBossArrayListIndex(client)!=iThisPlugin) return;

	switch (condition)
	{
		case TFCond_Jarated:
		{
			VSHA_SetBossRage(client, VSHA_GetBossRage(client)-8.0);
			TF2_RemoveCondition(client, condition);
		}
		case TFCond_MarkedForDeath:
		{
			VSHA_SetBossRage(client, VSHA_GetBossRage(client)-5.0);
			TF2_RemoveCondition(client, condition);
		}
		case TFCond_Disguised: TF2_RemoveCondition(client, condition);
	}
	if (TF2_IsPlayerInCondition(client, view_as<TFCond>(42))
		&& TF2_IsPlayerInCondition(client, TFCond_Dazed)) TF2_RemoveCondition(client, TFCond_Dazed);
}
public void OnBossStabbedPost(int iBossArrayListIndex, int iiBoss)
{
	if (iThisPlugin != iBossArrayListIndex) return;

	/*char playsound[PATHX];
	Format(playsound, PLATFORM_MAX_PATH, "%s%i.wav", HaleStubbed132, GetRandomInt(1, 4));
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iiBoss, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iiBoss, NULL_VECTOR, NULL_VECTOR, false, 0.0);*/
}
public Action UseUberRage(Handle hTimer, int iiBoss)
{
	if (!IsValidClient(iiBoss))
		return Plugin_Stop;
	if (UberRageCount[iiBoss] == 1)
	{
		if (!GetEntProp(iiBoss, Prop_Send, "m_bIsReadyToHighFive") && !IsValidEntity(GetEntPropEnt(iiBoss, Prop_Send, "m_hHighFivePartner")))
		{
			TF2_RemoveCondition(iiBoss, TFCond_Taunting);

			VSHA_CallModelTimer(0.0, iiBoss);

			//MakeModelTimer(INVALID_HANDLE); // should reset Hale's animation
		}
//      TF2_StunPlayer(Hale, 0.0, _, TF_STUNFLAG_NOSOUNDOREFFECT);
	}
	else if (UberRageCount[iiBoss] >= 100)
	{
		if (defaulttakedamagetype[iiBoss] == 0) defaulttakedamagetype[iiBoss] = 2;
		SetEntProp(iiBoss, Prop_Data, "m_takedamage", defaulttakedamagetype[iiBoss]);
		defaulttakedamagetype[iiBoss] = 0;
		TF2_RemoveCondition(iiBoss, TFCond_Ubercharged);
		return Plugin_Stop;
	}
	else if (UberRageCount[iiBoss] >= 85 && !TF2_IsPlayerInCondition(iiBoss, TFCond_UberchargeFading))
	{
		TF2_AddCondition(iiBoss, TFCond_UberchargeFading, 3.0);
	}
	if (!defaulttakedamagetype[iiBoss])
	{
		defaulttakedamagetype[iiBoss] = GetEntProp(iiBoss, Prop_Data, "m_takedamage");
		if (defaulttakedamagetype[iiBoss] == 0) defaulttakedamagetype[iiBoss] = 2;
	}
	SetEntProp(iiBoss, Prop_Data, "m_takedamage", 0);
	UberRageCount[iiBoss] += 1.0;
	return Plugin_Continue;
}
public Action UseRage(Handle hTimer, int iiBoss)
{
	float pos[3], pos2[3];
	int i;
	float distance;
	if (!IsValidClient(iiBoss)) return Plugin_Continue;
	if (!GetEntProp(iiBoss, Prop_Send, "m_bIsReadyToHighFive") && !IsValidEntity(GetEntPropEnt(iiBoss, Prop_Send, "m_hHighFivePartner")))
	{
		TF2_RemoveCondition(iiBoss, TFCond_Taunting);
	}
	GetEntPropVector(iiBoss, Prop_Send, "m_vecOrigin", pos);
	LoopMaxClients(target)
	{
		if (IsValidClient(target) && IsPlayerAlive(target) && target != iiBoss)
		{
			GetEntPropVector(target, Prop_Send, "m_vecOrigin", pos2);
			distance = GetVectorDistance(pos, pos2);
			if (!TF2_IsPlayerInCondition(target, TFCond_Ubercharged) && distance < RageDist)
			{
				int flags = TF_STUNFLAGS_GHOSTSCARE;
				flags |= TF_STUNFLAG_NOSOUNDOREFFECT;
				CreateTimer(5.0, RemoveEnt, EntIndexToEntRef(AttachParticle(i, "yikes_fx", 75.0)));
				TF2_StunPlayer(target, 5.0, _, (TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT), iiBoss);
			}
		}
	}
	StunSentry(iiBoss, RageDist, 6.0, GetEntProp(i, Prop_Send, "m_iHealth"));
	i = -1;
	while ((i = FindEntityByClassname2(i, "obj_dispenser")) != -1)
	{
		GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
		distance = GetVectorDistance(pos, pos2);
		if (distance < RageDist)	//(!mode && (distance < RageDist)) || (mode && (distance < RageDist/2)))
		{
			SetVariantInt(1);
			AcceptEntityInput(i, "RemoveHealth");
		}
	}
	i = -1;
	while ((i = FindEntityByClassname2(i, "obj_teleporter")) != -1)
	{
		GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
		distance = GetVectorDistance(pos, pos2);
		if (distance < RageDist)	//(!mode && (distance < RageDist)) || (mode && (distance < RageDist/2)))
		{
			SetVariantInt(1);
			AcceptEntityInput(i, "RemoveHealth");
		}
	}
	InRage[iiBoss]=false;
	return Plugin_Continue;
}
public Action Timer_StopTickle(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (!IsValidClient(client) || !IsPlayerAlive(client)) return Plugin_Continue;
	if (!GetEntProp(client, Prop_Send, "m_bIsReadyToHighFive") && !IsValidEntity(GetEntPropEnt(client, Prop_Send, "m_hHighFivePartner"))) TF2_RemoveCondition(client, TFCond_Taunting);
	return Plugin_Continue;
}
// stocks
stock bool OnlyScoutsLeft(int iTeam)
{
	for (int client; client <= MaxClients; client++)
	{
		if (IsValidClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == iTeam)
		{
			if (TF2_GetPlayerClass(client) != TFClass_Scout) break;
			return true;
		}
	}
	return false;
}

// LOAD CONFIGURATION
public void OnConfiguration_Load_Sounds(char[] cFile, char[] skey, char[] value, bool &bPreCacheFile, bool &bAddFileToDownloadsTable)
{
	if(!StrEqual(cFile, ThisConfigurationFile)) return;
	
	// AutoLoad is not attached to any variable
	if(StrEqual(skey, "AutoLoad"))
	{
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "VagineerLastA"))
	{
		strcopy(STRING(VagineerLastA), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "VagineerStart"))
	{
		strcopy(STRING(VagineerStart), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "VagineerRageSound"))
	{
		strcopy(STRING(VagineerRageSound), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "VagineerKSpree"))
	{
		strcopy(STRING(VagineerKSpree), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "VagineerKSpree2"))
	{
		strcopy(STRING(VagineerKSpree2), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "VagineerHit"))
	{
		strcopy(STRING(VagineerHit), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "VagineerRoundStart"))
	{
		strcopy(STRING(VagineerRoundStart), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "VagineerJump"))
	{
		strcopy(STRING(VagineerJump), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "VagineerRageSound2"))
	{
		strcopy(STRING(VagineerRageSound2), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "VagineerKSpreeNew"))
	{
		strcopy(STRING(VagineerKSpreeNew), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "VagineerFail"))
	{
		strcopy(STRING(VagineerFail), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "VagineerTheme"))
	{
		strcopy(STRING(VagineerTheme), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}

	if(bPreCacheFile || bAddFileToDownloadsTable)
	{
		PrintToServer("Loading Sounds %s = %s",skey,value);
	}
}
public void OnConfiguration_Load_Materials(char[] cFile, char[] skey, char[] value, bool &bPrecacheGeneric, bool &bAddFileToDownloadsTable)
{
	if(!StrEqual(cFile, ThisConfigurationFile)) return;
	
	if(StrEqual(skey, "MaterialPrefix"))
	{
		char s[PATHX];
		char extensionsb[][] = { ".vtf", ".vmt" };

		for (int i = 0; i < sizeof(extensionsb); i++)
		{
			Format(s, PATHX, "%s%s", value, extensionsb[i]);
			if ( FileExists(s, true) )
			{
				AddFileToDownloadsTable(s);

				PrintToServer("Loading Materials %s",s);
			}
		}
	}
}
public void OnConfiguration_Load_Models(char[] cFile, char[] skey, char[] value, bool &bPreCacheModel, bool &bAddFileToDownloadsTable)
{
	if(!StrEqual(cFile, ThisConfigurationFile)) return;
	
	if(StrEqual(skey, "VagiModel"))
	{
		strcopy(STRING(VagiModel), value);
		bPreCacheModel = true;
		bAddFileToDownloadsTable = true;
		// For Model Manager:
		VSHA_SetPluginModel(iThisPlugin, VagiModel);
	}
	else if(StrEqual(skey, "VagiModelPrefix"))
	{
		char s[PATHX];
		char extensions[][] = { ".mdl", ".dx80.vtx", ".dx90.vtx", ".sw.vtx", ".vvd", ".phy" };

		for (int i = 0; i < sizeof(extensions); i++)
		{
			Format(s, PATHX, "%s%s", VagiModelPrefix, extensions[i]);
			if ( FileExists(s, true) )
			{
				AddFileToDownloadsTable(s);
				PrintToServer("Loading Model %s = %s",skey,value);
			}
		}
	}
	if(bPreCacheModel || bAddFileToDownloadsTable)
	{
		PrintToServer("Loading Model %s = %s",skey,value);
	}
}
// Just in case you want to have extra configurations for your sub plugin.
// This makes loading configurations easier for you.
// Keeping all your configurations for your sub plugin in one location!
/*
public void VSHA_OnConfiguration_Load_Misc(char[] cFile, char[] skey, char[] value)
{
}
*/

// Is triggered by VSHA engine when a boos needs a help menu
public void OnShowBossHelpMenu(int iBossArrayListIndex, int iiBoss)
{
	if (iThisPlugin != iBossArrayListIndex) return;

	if(ValidPlayer(iiBoss))
	{
		Handle panel = CreatePanel();
		char s[512];
		Format(s, 512, "Help menu needs work.");
		SetPanelTitle(panel, s);
		DrawPanelItem(panel, "Exit");
		SendPanelToClient(panel, iiBoss, HintPanelH, 12);
		CloseHandle(panel);
	}
}

public int HintPanelH(Handle menu, MenuAction action, int param1, int param2)
{
	if (!ValidPlayer(param1)) return;
	//if (action == MenuAction_Select || (action == MenuAction_Cancel && param2 == MenuCancel_Exit)) VSHFlags[param1] |= VSHFLAG_CLASSHELPED;
	return;
}

#if !defined _smlib_included
/* SMLIB
 * Precaches the given particle system.
 * It's best to call this OnMapStart().
 * Code based on Rochellecrab's, thanks.
 *
 * @param particleSystem    Name of the particle system to precache.
 * @return                  Returns the particle system index, INVALID_STRING_INDEX on error.
 */
stock int PrecacheParticleSystem(const char[] particleSystem)
{
	static int particleEffectNames = INVALID_STRING_TABLE;

	if (particleEffectNames == INVALID_STRING_TABLE) {
		if ((particleEffectNames = FindStringTable("ParticleEffectNames")) == INVALID_STRING_TABLE) {
			return INVALID_STRING_INDEX;
		}
	}

	int index = FindStringIndex2(particleEffectNames, particleSystem);
	if (index == INVALID_STRING_INDEX) {
		int numStrings = GetStringTableNumStrings(particleEffectNames);
		if (numStrings >= GetStringTableMaxStrings(particleEffectNames)) {
			return INVALID_STRING_INDEX;
		}

		AddToStringTable(particleEffectNames, particleSystem);
		index = numStrings;
	}

	return index;
}

/* SMLIB
 * Rewrite of FindStringIndex, because in my tests
 * FindStringIndex failed to work correctly.
 * Searches for the index of a given string in a string table.
 *
 * @param tableidx      A string table index.
 * @param str           String to find.
 * @return              String index if found, INVALID_STRING_INDEX otherwise.
 */
stock int FindStringIndex2(int tableidx, const char[] str)
{
	char buf[1024];

	int numStrings = GetStringTableNumStrings(tableidx);
	for (int i=0; i < numStrings; i++) {
		ReadStringTable(tableidx, i, buf, sizeof(buf));

		if (StrEqual(buf, str)) {
			return i;
		}
	}

	return INVALID_STRING_INDEX;
}
#endif

