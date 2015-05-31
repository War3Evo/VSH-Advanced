#pragma semicolon 1
#include <sourcemod>
#include <sdkhooks>
#include <morecolors>
#include <vsha>
#include <vsha_stocks>

public Plugin myinfo =
{
	name			= "Vagineer",
	author			= "Valve",
	description		= "!pu raeg taht evom ottaG",
	version			= "1.0",
	url				= "http://tf2freakshow.wikia.com/wiki/Vagineer"
}

#define HALE_JUMPCHARGETIME		4
#define HALE_JUMPCHARGE			(25 * HALE_JUMPCHARGETIME)

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

Handle ThisPluginHandle = null; //DO NOT TOUCH THIS, THIS IS JUST USED AS HOLDING DATA.

//make defines, handles, variables heer lololol
int HaleCharge[PLYR];

int Hale[PLYR];

float UberRageCount[PLYR];

int defaulttakedamagetype[PLYR];

float WeighDownTimer = 0.0;
float RageDist = 800.0;

char playsound[PATHX];

public void OnPluginStart()
{
	//ThisPluginHandle = view_as<Handle>( VSHA_RegisterBoss("vagineer") );
	//AutoExecConfig(true, "VSHA-Boss-Vagineer");
#if defined DEBUG
	DEBUGPRINT1("VSH Engine::OnPluginStart() **** loaded VSHA Subplugin ****");
#endif
}

public void OnAllPluginsLoaded()
{
	ThisPluginHandle = view_as<Handle>( VSHA_RegisterBoss("vagineer", "Vagineer") );
#if defined DEBUG
	if (ThisPluginHandle == null) DEBUGPRINT1("VSHA Vagineer::OnAllPluginsLoaded() **** ThisPluginHandle is NULL ****");
	else DEBUGPRINT1("VSHA Vagineer::OnAllPluginsLoaded() **** ThisPluginHandle is OK and Vagineer is Registered! ****");
#endif
	HookEvent("player_changeclass", ChangeClass);

	VSHA_LoadConfiguration("configs/vsha/vagineer.cfg");
}
public void OnPluginEnd()
{
	if(ThisPluginHandle != null)
	{
		//VSHA_UnRegisterBoss("vagineer");
	}
}
public void OnMapEnd()
{
	WeighDownTimer = 0.0;
	//gDist = 800.0;

	LoopMaxPLYR(player)
	{
		Hale[player] = 0;
		HaleCharge[player] = 0;
	}
}

public void OnClientDisconnect(int client)
{
	if (client == Hale[client])
	{
		Hale[client] = 0;
		bool see[PLYR];
		see[Hale[client]] = true;
		int tHale;
		if (VSHA_GetPresetBossPlayer() > 0) tHale = VSHA_GetPresetBossPlayer();
		else tHale = VSHA_FindNextBoss( see, sizeof(see) );
		if (IsValidClient(tHale))
		{
			if (GetClientTeam(tHale) != 3)
			{
				ForceTeamChange(Hale[client], 3);
				//DP("vsha-Vagineer 166 ForceTeamChange(i, 3)");
			}
		}
	}
}
public Action ChangeClass(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId( event.GetInt("userid") );
	if (client == Hale[client])
	{
		if (TF2_GetPlayerClass(client) != TFClass_Engineer) TF2_SetPlayerClass(client, TFClass_Engineer, _, false);
		TF2_RemovePlayerDisguise(client);
	}
	return Plugin_Continue;
}

// If You Prefer to use VSHA_AddToDownloads instead of loading a configuration file,
// That is your choice.
// This is here for your reference
/*
public void VSHA_AddToDownloads()
{
	char s[PATHX];
	char extensions[][] = { ".mdl", ".dx80.vtx", ".dx90.vtx", ".sw.vtx", ".vvd", ".phy" };
	char extensionsb[][] = { ".vtf", ".vmt" };
	//char extensionsc[][] = { ".wav", ".mp3" };
	int i;
	for (i = 0; i < sizeof(extensions); i++)
	{
		Format(s, PATHX, "%s%s", HaleModelPrefix, extensions[i]);
		if ( FileExists(s, true) ) AddFileToDownloadsTable(s);
	}
	PrecacheModel(HaleModel, true);

	for (i = 0; i < sizeof(extensionsb); i++)
	{
		Format(s, PATHX, "materials/models/player/saxton_hale/eye%s", extensionsb[i]);
		if ( FileExists(s, true) ) AddFileToDownloadsTable(s);
		Format(s, PATHX, "materials/models/player/saxton_hale/hale_head%s", extensionsb[i]);
		if ( FileExists(s, true) ) AddFileToDownloadsTable(s);
		Format(s, PATHX, "materials/models/player/saxton_hale/hale_body%s", extensionsb[i]);
		if ( FileExists(s, true) ) AddFileToDownloadsTable(s);
		Format(s, PATHX, "materials/models/player/saxton_hale/hale_misc%s", extensionsb[i]);
		if ( FileExists(s, true) ) AddFileToDownloadsTable(s);
		Format(s, PATHX, "materials/models/player/saxton_hale/sniper_red%s", extensionsb[i]);
		if ( FileExists(s, true) ) AddFileToDownloadsTable(s);
		Format(s, PATHX, "materials/models/player/saxton_hale/sniper_lens%s", extensionsb[i]);
		if ( FileExists(s, true) ) AddFileToDownloadsTable(s);
	}
	PrecacheSound(HaleComicArmsFallSound, true);
	Format(s, PATHX, "sound/%s", HaleComicArmsFallSound);
	AddFileToDownloadsTable(s);

	Format(s, PATHX, "sound/%s", HaleKSpree);
	PrecacheSound(HaleKSpree, true);
	AddFileToDownloadsTable(s);
	Format(s, PATHX, "sound/%s", HaleTheme1);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleTheme1, true);
	Format(s, PATHX, "sound/%s", HaleTheme2);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleTheme2, true);
	Format(s, PATHX, "sound/%s", HaleTheme3);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleTheme3, true);
	for (i = 1; i <= 4; i++)
	{
		Format(s, PATHX, "%s0%i.wav", HaleLastB, i);
		PrecacheSound(s, true);
	}
	PrecacheSound(HaleKillMedic, true);
	Format(s, PATHX, "sound/%s", HaleKillMedic);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillSniper1, true);
	Format(s, PATHX, "sound/%s", HaleKillSniper1);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillSniper2, true);
	Format(s, PATHX, "sound/%s", HaleKillSniper2);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillSpy1, true);
	Format(s, PATHX, "sound/%s", HaleKillSpy1);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillSpy2, true);
	Format(s, PATHX, "sound/%s", HaleKillSpy2);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillEngie1, true);
	Format(s, PATHX, "sound/%s", HaleKillEngie1);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillEngie2, true);
	Format(s, PATHX, "sound/%s", HaleKillEngie2);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillDemo132, true);
	Format(s, PATHX, "sound/%s", HaleKillDemo132);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillHeavy132, true);
	Format(s, PATHX, "sound/%s", HaleKillHeavy132);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillScout132, true);
	Format(s, PATHX, "sound/%s", HaleKillScout132);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillSpy132, true);
	Format(s, PATHX, "sound/%s", HaleKillSpy132);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillPyro132, true);
	Format(s, PATHX, "sound/%s", HaleKillPyro132);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleSappinMahSentry132, true);
	Format(s, PATHX, "sound/%s", HaleSappinMahSentry132);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillLast132, true);
	Format(s, PATHX, "sound/%s", HaleKillLast132);
	AddFileToDownloadsTable(s);
	PrecacheSound("vo/announcer_am_capincite01.wav", true);
	PrecacheSound("vo/announcer_am_capincite03.wav", true);
	PrecacheSound("vo/announcer_am_capenabled02.wav", true);
	for (i = 1; i <= 5; i++)
	{
		if (i <= 2)
		{
			Format(s, PATHX, "%s%i.wav", HaleJump, i);
			PrecacheSound(s, true);
			Format(s, PATHX, "sound/%s", s);
			AddFileToDownloadsTable(s);
			Format(s, PATHX, "%s%i.wav", HaleWin, i);
			PrecacheSound(s, true);
			Format(s, PATHX, "sound/%s", s);
			AddFileToDownloadsTable(s);
			Format(s, PATHX, "%s%i.wav", HaleJump132, i);
			PrecacheSound(s, true);
			Format(s, PATHX, "sound/%s", s);
			AddFileToDownloadsTable(s);
			Format(s, PATHX, "%s%i.wav", HaleKillEngie132, i);
			PrecacheSound(s, true);
			Format(s, PATHX, "sound/%s", s);
			AddFileToDownloadsTable(s);
			Format(s, PATHX, "%s%i.wav", HaleKillKSpree132, i);
			PrecacheSound(s, true);
			Format(s, PATHX, "sound/%s", s);
			AddFileToDownloadsTable(s);
		}
		if (i <= 3)
		{
			Format(s, PATHX, "%s%i.wav", HaleFail, i);
			PrecacheSound(s, true);
			Format(s, PATHX, "sound/%s", s);
			AddFileToDownloadsTable(s);
		}
		if (i <= 4)
		{
			Format(s, PATHX, "%s%i.wav", HaleRageSound, i);
			PrecacheSound(s, true);
			Format(s, PATHX, "sound/%s", s);
			AddFileToDownloadsTable(s);
			Format(s, PATHX, "%s%i.wav", HaleStubbed132, i);
			PrecacheSound(s, true);
			Format(s, PATHX, "sound/%s", s);
			AddFileToDownloadsTable(s);
		}
		Format(s, PATHX, "%s%i.wav", HaleRoundStart, i);
		PrecacheSound(s, true);
		Format(s, PATHX, "sound/%s", s);
		AddFileToDownloadsTable(s);
		Format(s, PATHX, "%s%i.wav", HaleKSpreeNew, i);
		PrecacheSound(s, true);
		Format(s, PATHX, "sound/%s", s);
		AddFileToDownloadsTable(s);
		Format(s, PATHX, "%s%i.wav", HaleLastMan, i);
		PrecacheSound(s, true);
		Format(s, PATHX, "sound/%s", s);
		AddFileToDownloadsTable(s);
		Format(s, PATHX, "%s%i.wav", HaleStart132, i);
		PrecacheSound(s, true);
		Format(s, PATHX, "sound/%s", s);
		AddFileToDownloadsTable(s);
	}
#if defined DEBUG
	DEBUGPRINT1("VSH Vagineer::VSHA_AddToDownloads() **** Forward Responded ****");
#endif
}*/

public Action VSHA_OnPlayerKilledByBoss()
{
	int iiBoss = VSHA_GetVar(EventBoss);
	int attacker = VSHA_GetVar(EventAttacker);

	if(Hale[iiBoss] != iiBoss) return Plugin_Continue;

	strcopy(playsound, PLATFORM_MAX_PATH, "");
	strcopy(playsound, PLATFORM_MAX_PATH, VagineerHit);
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(playsound, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
#if defined DEBUG
	DEBUGPRINT1("VSH Vagineer::VSHA_OnPlayerKilled() **** Forward Responded ****");
	DEBUGPRINT2("{lime}VSH Vagineer::VSHA_OnPlayerKilled() **** Forward Responded ****");
#endif
	return Plugin_Continue;
}
public Action VSHA_OnKillingSpreeByBoss()
{
	int iiBoss = VSHA_GetVar(EventBoss);
	int attacker = VSHA_GetVar(EventAttacker);

	if(Hale[iiBoss] != iiBoss) return Plugin_Continue;

	if (GetRandomInt(0, 4) == 1)
		strcopy(playsound, PLATFORM_MAX_PATH, VagineerKSpree);
	else if (GetRandomInt(0, 3) == 1)
		strcopy(playsound, PLATFORM_MAX_PATH, VagineerKSpree2);
	else
		Format(playsound, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, GetRandomInt(1, 5));

	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
#if defined DEBUG
	DEBUGPRINT1("VSH Vagineer::VSHA_OnKillingSpree() **** Forward Responded ****");
	DEBUGPRINT2("{lime}VSH Vagineer::VSHA_OnKillingSpree() **** Forward Responded ****");
#endif
	return Plugin_Continue;
}
public Action VSHA_OnBossKilled() //victim is boss
{
	int iiBoss = VSHA_GetVar(EventBoss);
	//int attacker = VSHA_GetVar(EventAttacker);

	if(Hale[iiBoss] != iiBoss) return Plugin_Continue;

	strcopy(playsound, PLATFORM_MAX_PATH, "");
	Format(playsound, PLATFORM_MAX_PATH, "%s%i.wav", VagineerFail, GetRandomInt(1, 2));
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iiBoss, NULL_VECTOR, NULL_VECTOR, false, 0.0);
#if defined DEBUG
	DEBUGPRINT1("VSH Vagineer::VSHA_OnBossKilled() **** Forward Responded ****");
	DEBUGPRINT2("{lime}VSH Vagineer::VSHA_OnBossKilled() **** Forward Responded ****");
#endif
	SDKUnhook(iiBoss, SDKHook_OnTakeDamage, OnTakeDamage);
	return Plugin_Continue;
}
public Action VSHA_OnBossWin()
{
	//VSHA_GetVar(SmEvent,event);
	int iiBoss = VSHA_GetVar(EventBoss);

	if(Hale[iiBoss] != iiBoss) return Plugin_Continue;

	strcopy(playsound, PLATFORM_MAX_PATH, "");
	Format(playsound, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, GetRandomInt(1, 5));
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
#if defined DEBUG
	DEBUGPRINT1("VSH Vagineer::VSHA_OnBossWin() **** Forward Responded ****");
	DEBUGPRINT2("{lime}VSH Vagineer::VSHA_OnBossWin() **** Forward Responded ****");
#endif
	SDKUnhook(Hale[iiBoss], SDKHook_OnTakeDamage, OnTakeDamage);
	return Plugin_Continue;
}
/*public Action VSHA_OnBossKillBuilding()
{
	//Event event = VSHA_GetVar(SmEvent);
	//int building = event.GetInt("index");
	int attacker = VSHA_GetVar(EventAttacker);

	if (attacker != Hale[attacker]) return Plugin_Continue;
	if ( !GetRandomInt(0, 4) )
	{
		strcopy(playsound, PLATFORM_MAX_PATH, "");
		strcopy(playsound, PLATFORM_MAX_PATH, HaleSappinMahSentry132);
		EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	}
#if defined DEBUG
	DEBUGPRINT1("VSH Vagineer::VSHA_OnBossKillBuilding() **** Forward Responded ****");
	DEBUGPRINT2("{lime}VSH Vagineer::VSHA_OnBossKillBuilding() **** Forward Responded ****");
#endif
	return Plugin_Continue;
}*/
public Action VSHA_MessageTimer()
{
	//SetHudTextParams(-1.0, 0.4, 10.0, 255, 255, 255, 255);
	char text[PATHX];
	int client;
	for (client = 1; client <= MaxClients; client++)
	{
		if ( !IsValidClient(client) ) continue;
		if ( client == Hale[client] )
		{
			Format( text, sizeof(text), "%N became Vagineer with %i HP", client, VSHA_GetBossMaxHealth(client) );
			break;
		}
	}
	for (client = 1; client <= MaxClients; client++)
	{
		if ( IsValidClient(client) )
		{
			SetHudTextParams(-1.0, 0.60, HudTextScreenHoldTime, 90, 255, 90, 200, 0, 0.0, 0.0, 0.0);
			ShowHudText(client, -1, text);
		}
	}
#if defined DEBUG
	DEBUGPRINT1("VSH Vagineer::VSHA_MessageTimer() **** Forward Responded ****");
	DEBUGPRINT2("{lime}VSH Vagineer::VSHA_MessageTimer() **** Forward Responded ****");
#endif
	return Plugin_Continue;
}
public Action VSHA_OnBossAirblasted()
{
	int iiBoss = VSHA_GetVar(EventBoss);
	//int airblaster = VSHA_GetVar(EventAttacker);

	if (iiBoss != Hale[iiBoss]) return Plugin_Continue;
	//float rage = 0.04*RageDMG;
	//HaleRage += RoundToCeil(rage);
	//if (HaleRage > RageDMG) HaleRage = RageDMG;
	VSHA_SetBossRage(Hale[iiBoss], VSHA_GetBossRage(Hale[iiBoss])+4.0); //make this a convar/cvar!
#if defined DEBUG
	DEBUGPRINT1("VSH Vagineer::VSHA_OnBossAirblasted() **** Forward Responded ****");
	DEBUGPRINT2("{lime}VSH Vagineer::VSHA_OnBossAirblasted() **** Forward Responded ****");
#endif
	return Plugin_Continue;
}
public Action VSHA_OnBossSelected()
{
	int iiBoss = VSHA_GetVar(EventClient);
	if (VSHA_IsBossPlayer(iiBoss)) Hale[iiBoss] = iiBoss;
	if ( iiBoss != Hale[iiBoss] && VSHA_IsBossPlayer(iiBoss) )
	{
		VSHA_SetIsBossPlayer(Hale[iiBoss], false);
		Hale[iiBoss] = 0;
		ForceTeamChange(iiBoss, 3);
		//DP("vsha-Vagineer 526 ForceTeamChange(iiBoss, 3)");
		return Plugin_Stop;
	}
	SDKHook(iiBoss, SDKHook_OnTakeDamage, OnTakeDamage);
#if defined DEBUG
	DEBUGPRINT1("VSH Vagineer::VSHA_OnBossSelected() **** Forward Responded ****");
	DEBUGPRINT2("{lime}VSH Vagineer::VSHA_OnBossSelected() **** Forward Responded ****");
#endif
	return Plugin_Continue;
}
public Action VSHA_OnBossIntroTalk()
{
	strcopy(playsound, PLATFORM_MAX_PATH, "");
	if (!GetRandomInt(0, 1))
		strcopy(playsound, PLATFORM_MAX_PATH, VagineerStart);
	else
		strcopy(playsound, PLATFORM_MAX_PATH, VagineerRoundStart);
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
#if defined DEBUG
	DEBUGPRINT1("VSH Vagineer::VSHA_OnBossIntroTalk() **** Forward Responded ****");
	DEBUGPRINT2("{lime}VSH Vagineer::VSHA_OnBossIntroTalk() **** Forward Responded ****");
#endif
	return Plugin_Continue;
}
public Action VSHA_OnBossSetHP()
{
	int iClient = VSHA_GetVar(EventClient);
	if (iClient != Hale[iClient]) return Plugin_Continue;
	int BossMax = HealthCalc( 760.8, view_as<float>( VSHA_GetPlayerCount() ), 1.0, 1.0341, 2046.0 );
	VSHA_SetBossMaxHealth(Hale[iClient], BossMax);
#if defined DEBUG
	DEBUGPRINT1("VSH Vagineer::VSHA_OnBossSetHP() **** Forward Responded ****");
	DEBUGPRINT2("{lime}VSH Vagineer::VSHA_OnBossSetHP() **** Forward Responded ****");
#endif
	return Plugin_Continue;
}
public Action VSHA_OnLastSurvivor()
{
	strcopy(playsound, PLATFORM_MAX_PATH, "");
	strcopy(playsound, PLATFORM_MAX_PATH, VagineerLastA);
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
#if defined DEBUG
	DEBUGPRINT1("VSH Vagineer::VSHA_OnLastSurvivor() **** Forward Responded ****");
	DEBUGPRINT2("{lime}VSH Vagineer::VSHA_OnLastSurvivor() **** Forward Responded ****");
#endif
	return Plugin_Continue;
}
public Action VSHA_OnBossTimer()
{
	int iClient = VSHA_GetVar(EventClient);
	if (iClient != Hale[iClient]) return Plugin_Continue;
	float speed;
	int curHealth = VSHA_GetBossHealth(iClient), curMaxHp = VSHA_GetBossMaxHealth(iClient);
	if (curHealth <= curMaxHp) speed = 340.0 + 0.7 * (100-curHealth*100/curMaxHp); //convar/cvar for speed here!
	SetEntPropFloat(iClient, Prop_Send, "m_flMaxspeed", speed);

	int buttons = GetClientButtons(iClient);
	if ( ((buttons & IN_DUCK) || (buttons & IN_ATTACK2)) && HaleCharge[iClient] >= 0 )
	{
		if (HaleCharge[iClient] + 5 < HALE_JUMPCHARGE) HaleCharge[iClient] += 5;
		else HaleCharge[iClient] = HALE_JUMPCHARGE;
		if (!(buttons & IN_SCORE))
		{
			SetHudTextParams(-1.0, 0.70, HudTextScreenHoldTime, 90, 255, 90, 200, 0, 0.0, 0.0, 0.0);
			ShowHudText(iClient, -1, "Jump Charge: %i%", HaleCharge[iClient]);
		}
	}
	else if (HaleCharge[iClient] < 0)
	{
		HaleCharge[iClient] += 5;
		if (!(buttons & IN_SCORE))
		{
			SetHudTextParams(-1.0, 0.75, HudTextScreenHoldTime, 90, 255, 90, 200, 0, 0.0, 0.0, 0.0);
			ShowHudText(iClient, -1, "Super Jump will be ready again in: %i", (-HaleCharge[iClient]/10));
		}
	}
	else
	{
		// 5 * 60 = 300
		// 5 * .2 = 1 second, so 5 times number of seconds equals number for HaleCharge after superjump
		// 300 = 1 minute wait
		float ExtraBoost = float(HaleCharge[iClient]) * 2;
		if ( HaleCharge[iClient] > 1 && SuperJump(iClient, ExtraBoost, -15.0, HaleCharge[iClient], -150) ) //put convar/cvar for jump sensitivity here!
		{
			strcopy(playsound, PLATFORM_MAX_PATH, "");
			Format(playsound, PLATFORM_MAX_PATH, "%s%i.wav", VagineerJump, GetRandomInt(1, 2));
			EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iClient, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		}
	}

	if (VSHA_GetAliveRedPlayers() == 1) PrintCenterTextAll("Vagineer's Current Health is: %i of %i", curHealth, curMaxHp);
	if ( OnlyScoutsLeft() ) VSHA_SetBossRage(iClient, VSHA_GetBossRage(iClient)+0.5);

	if ( !(GetEntityFlags(iClient) & FL_ONGROUND) ) WeighDownTimer += 0.2;
	else WeighDownTimer = 0.0;

	if ( (buttons & IN_DUCK) && Weighdown(iClient, WeighDownTimer, 60.0, 0.0) )
	{
		//CPrintToChat(client, "{olive}[VSHE]{default} You just used your weighdown!");
		//all this just to do a cprint? It's not like weighdown has a limit...
	}
#if defined DEBUG
	DEBUGPRINT1("VSH Vagineer::VSHA_OnBossTimer() **** Forward Responded ****");
	DEBUGPRINT2("{lime}VSH Vagineer::VSHA_OnBossTimer() **** Forward Responded ****");
#endif
	return Plugin_Continue;
}
public Action VSHA_OnPrepBoss()
{
	int iClient = VSHA_GetVar(EventOnPrepBoss);

	if (iClient != Hale[iClient]) return Plugin_Continue;
	TF2_SetPlayerClass(iClient, TFClass_Engineer, _, false);
	HaleCharge[iClient] = 0;

	TF2_RemoveAllWeapons2(iClient);
	TF2_RemovePlayerDisguise(iClient);

	bool pri = IsValidEntity(GetPlayerWeaponSlot(iClient, TFWeaponSlot_Primary));
	bool sec = IsValidEntity(GetPlayerWeaponSlot(iClient, TFWeaponSlot_Secondary));
	bool mel = IsValidEntity(GetPlayerWeaponSlot(iClient, TFWeaponSlot_Melee));

	if (pri || sec || !mel)
	{
		TF2_RemoveAllWeapons2(iClient);
		char attribs[PATH];
		Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 3.0 ; 259 ; 1.0 ; 436 ; 1.0 ; 214 ; %d", GetRandomInt(999, 9999));
		int VagiWeapon = SpawnWeapon(iClient, "tf_weapon_wrench", 197, 100, 4, attribs);
		SetEntProp(VagiWeapon, Prop_Send, "m_iWorldModelIndex", -1);
		SetEntProp(VagiWeapon, Prop_Send, "m_nModelIndexOverrides", -1, _, 0);
		SetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon", VagiWeapon);
	}
#if defined DEBUG
	DEBUGPRINT1("VSH Vagineer::VSHA_OnPrepBoss() **** Forward Responded ****");
	DEBUGPRINT2("{lime}VSH Vagineer::VSHA_OnPrepBoss() **** Forward Responded ****");
#endif
	return Plugin_Continue;
}
public Action VSHA_OnMusic()
{
	float time = 199.0;

	StringMap SoundMap = new StringMap();
	SoundMap.SetString("Sound", VagineerTheme);
	VSHA_SetVar(EventSound,SoundMap);
	VSHA_SetVar(EventTime,time);
#if defined DEBUG
	DEBUGPRINT1("VSH Vagineer::VSHA_OnMusic() **** Forward Responded ****");
	DEBUGPRINT2("{lime}VSH Vagineer::VSHA_OnMusic() **** Forward Responded ****");
#endif
	return Plugin_Continue;
}
/*
public Action OnVSHAEvent(VSHA_EVENT event, int client)
{
	switch(event)
	{
		case ModelTimer:
		{
			if (client != Hale)
			{
				SetVariantString("");
				AcceptEntityInput(client, "SetCustomModel");
				return Plugin_Stop;
			}

			SetVariantString(HaleModel);
			AcceptEntityInput(client, "SetCustomModel");
			SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
		}
	}
	return Plugin_Continue;
}*/

public Action VSHA_OnModelTimer()
{
	int iClient = VSHA_GetVar(EventModelTimer);

	char modelpath[PATHX];

	//DP("VSHA_OnModelTimer");
	if (iClient != Hale[iClient])
	{
		SetVariantString("");
		AcceptEntityInput(iClient, "SetCustomModel");
		return Plugin_Stop;
	}
	modelpath = VagiModel;

	StringMap ModelMap = new StringMap();
	ModelMap.SetString("Model", modelpath);
	VSHA_SetVar(EventModel, ModelMap);

	SetVariantString(modelpath);
	AcceptEntityInput(iClient, "SetCustomModel");
	SetEntProp(iClient, Prop_Send, "m_bUseClassAnimations", 1);

#if defined DEBUG
	//DEBUGPRINT1("VSH Vagineer::VSHA_OnModelTimer() **** Forward Responded ****");
	//DEBUGPRINT2("{lime}VSH Vagineer::VSHA_OnModelTimer() **** Forward Responded ****");
#endif
	return Plugin_Continue;
}

public Action VSHA_OnBossRage()
{
	int iClient = VSHA_GetVar(EventBoss);

	if (iClient != Hale[iClient]) return Plugin_Continue;
	float pos[3];
	GetEntPropVector(iClient, Prop_Send, "m_vecOrigin", pos);
	pos[2] += 20.0;
	TF2_AddCondition(iClient, view_as<TFCond>(42), 4.0);
	strcopy(playsound, PLATFORM_MAX_PATH, "");
	if (GetRandomInt(0, 2))
		strcopy(playsound, PLATFORM_MAX_PATH, VagineerRageSound);
	else
		Format(playsound, PLATFORM_MAX_PATH, "%s%i.wav", VagineerRageSound2, GetRandomInt(1, 2));
	EmitSoundToAll(playsound, iClient, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iClient, pos, NULL_VECTOR, true, 0.0);
	EmitSoundToAll(playsound, iClient, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iClient, pos, NULL_VECTOR, true, 0.0);

	TF2_AddCondition(iClient, TFCond_Ubercharged, 99.0);
	UberRageCount[iClient] = 0.0;

	CreateTimer(0.6, UseRage, GetClientUserId(iClient));
	CreateTimer(0.1, UseUberRage, GetClientUserId(iClient), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
#if defined DEBUG
	DEBUGPRINT1("VSH Vagineer::VSHA_OnBossRage() **** Forward Responded ****");
	DEBUGPRINT2("{lime}VSH Vagineer::VSHA_OnBossRage() **** Forward Responded ****");
#endif
	return Plugin_Continue;
}
public Action UseUberRage(Handle hTimer, int userid)
{
	int iClient = GetClientOfUserId(userid);

	if (!IsValidClient(Hale[iClient]))
		return Plugin_Stop;
	if (UberRageCount[iClient] == 1)
	{
		if (!GetEntProp(Hale[iClient], Prop_Send, "m_bIsReadyToHighFive") && !IsValidEntity(GetEntPropEnt(Hale[iClient], Prop_Send, "m_hHighFivePartner")))
		{
			TF2_RemoveCondition(Hale[iClient], TFCond_Taunting);

			VSHA_CallModelTimer(0.0,Hale[iClient]);

			//MakeModelTimer(INVALID_HANDLE); // should reset Hale's animation
		}
//      TF2_StunPlayer(Hale, 0.0, _, TF_STUNFLAG_NOSOUNDOREFFECT);
	}
	else if (UberRageCount[iClient] >= 100)
	{
		if (defaulttakedamagetype[iClient] == 0) defaulttakedamagetype[iClient] = 2;
		SetEntProp(Hale[iClient], Prop_Data, "m_takedamage", defaulttakedamagetype[iClient]);
		defaulttakedamagetype[iClient] = 0;
		TF2_RemoveCondition(Hale[iClient], TFCond_Ubercharged);
		return Plugin_Stop;
	}
	else if (UberRageCount[iClient] >= 85 && !TF2_IsPlayerInCondition(Hale[iClient], TFCond_UberchargeFading))
	{
		TF2_AddCondition(Hale[iClient], TFCond_UberchargeFading, 3.0);
	}
	if (!defaulttakedamagetype[iClient])
	{
		defaulttakedamagetype[iClient] = GetEntProp(Hale[iClient], Prop_Data, "m_takedamage");
		if (defaulttakedamagetype[iClient] == 0) defaulttakedamagetype[iClient] = 2;
	}
	SetEntProp(Hale[iClient], Prop_Data, "m_takedamage", 0);
	UberRageCount[iClient] += 1.0;
	return Plugin_Continue;
}
public void TF2_OnConditionAdded(int client, TFCond condition)
{
	if (client != Hale[client]) return;
	switch (condition)
	{
		case TFCond_Jarated:
		{
#if defined DEBUG
			DEBUGPRINT1("VSH Vagineer::TF2_OnConditionAdded() **** Hale was Jarated ****");
			DEBUGPRINT2("{lime}VSH Vagineer::TF2_OnConditionAdded() **** Hale was Jarated ****");
#endif
			VSHA_SetBossRage(Hale[client], VSHA_GetBossRage(client)-8.0);
			TF2_RemoveCondition(Hale[client], condition);
		}
		case TFCond_MarkedForDeath:
		{
#if defined DEBUG
			DEBUGPRINT1("VSH Vagineer::TF2_OnConditionAdded() **** Hale was MarkedForDeath ****");
			DEBUGPRINT2("{lime}VSH Vagineer::TF2_OnConditionAdded() **** Hale was MarkedForDeath ****");
#endif
			VSHA_SetBossRage(Hale[client], VSHA_GetBossRage(client)-5.0);
			TF2_RemoveCondition(Hale[client], condition);
		}
		case TFCond_Disguised: TF2_RemoveCondition(Hale[client], condition);
	}
	if (TF2_IsPlayerInCondition(Hale[client], view_as<TFCond>(42))
		&& TF2_IsPlayerInCondition(Hale[client], TFCond_Dazed)) TF2_RemoveCondition(Hale[client], TFCond_Dazed);
}
public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(!IsValidEdict(attacker)) return Plugin_Continue;

	if ( CheckRoundState() == 0 && (victim == Hale[victim] || (victim != attacker && attacker != Hale[attacker])) )
	{
		damage *= 0.0;
		return Plugin_Changed;
	}
	if ((damagetype & DMG_FALL) && victim == Hale[victim])
	{
		//DP("DMG_FALL victim = %d, hale[victim] = %d",victim,Hale[victim]);
		if(GetEntityFlags(victim) & FL_ONGROUND)
		{
			//DP("Hale Fall Damage");
			damage = (VSHA_GetBossHealth(victim) > 100) ? 10.0 : 100.0; //please don't fuck with this.
			return Plugin_Changed;
		}
	}

	switch (damagecustom)
	{
		case TF_CUSTOM_TAUNT_GRAND_SLAM, TF_CUSTOM_TAUNT_FENCING, TF_CUSTOM_TAUNT_GRENADE, TF_CUSTOM_TAUNT_BARBARIAN_SWING, TF_CUSTOM_TAUNT_ENGINEER_SMASH:
		{
			damage *= 10.0;
			return Plugin_Changed;
			//case TF_CUSTOM_TAUNT_HIGH_NOON:
		}
	}
	float AttackerPos[3];
	GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", AttackerPos); //Spot of attacker
	if (attacker == Hale[attacker])
	{
		if (TF2_IsPlayerInCondition(victim, TFCond_DefenseBuffed))
		{
			ScaleVector(damageForce, 9.0);
			damage *= 0.3;
			return Plugin_Changed;
		}
		if (TF2_IsPlayerInCondition(victim, TFCond_DefenseBuffMmmph))
		{
			damage *= 9;
			TF2_AddCondition(victim, TFCond_Bonked, 0.1);
			return Plugin_Changed;
		}
		if (TF2_IsPlayerInCondition(victim, TFCond_CritMmmph))
		{
			damage *= 0.25;
			return Plugin_Changed;
		}
		if (TF2_GetPlayerClass(victim) == TFClass_Spy)
		{
			if (GetEntProp(victim, Prop_Send, "m_bFeignDeathReady") && !TF2_IsPlayerInCondition(victim, TFCond_Cloaked))
			{
				if (damagetype & DMG_CRIT) damagetype &= ~DMG_CRIT;
				damage = 600.0; //make convar/cvar heer
				return Plugin_Changed;
			}
			if (TF2_IsPlayerInCondition(victim, TFCond_Cloaked) && TF2_IsPlayerInCondition(victim, TFCond_DeadRingered))
			{
				if (damagetype & DMG_CRIT) damagetype &= ~DMG_CRIT;
				damage = 850.0; //make convar/cvar heer!
				return Plugin_Changed;
			}
		}
		int ent = -1;
		while ((ent = FindEntityByClassname2(ent, "tf_wearable_demoshield")) != -1)
		{
			if (GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") == victim && !GetEntProp(ent, Prop_Send, "m_bDisguiseWearable") && weapon == GetPlayerWeaponSlot(attacker, 2))
			{
				//int HitsTaken = VSHA_GetHits(victim);
				//int HitsRequired = 0;
				/*int index = GetItemIndex(ent);
				switch (index)
				{
					case 131: HitsRequired = 2;
					case 406: HitsRequired = 1;
				}*/
				TF2_AddCondition(victim, TFCond_Bonked, 0.1);
				//if (HitsRequired <= HitsTaken)
				//{
				TF2_RemoveWearable(victim, ent);
				float Pos[3];
				GetEntPropVector(victim, Prop_Send, "m_vecOrigin", Pos);
				EmitSoundToClient(victim, "player/spy_shield_break.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 0.7, 100, _, Pos, NULL_VECTOR, false, 0.0);
				EmitSoundToClient(victim, "player/spy_shield_break.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 0.7, 100, _, Pos, NULL_VECTOR, false, 0.0);
				EmitSoundToClient(attacker, "player/spy_shield_break.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 0.7, 100, _, Pos, NULL_VECTOR, false, 0.0);
				EmitSoundToClient(attacker, "player/spy_shield_break.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 0.7, 100, _, Pos, NULL_VECTOR, false, 0.0);
				//}
				//return Plugin_Continue;
			}
		}
	}
	else if (Hale[victim] == victim && Hale[attacker] != attacker)
	{
		if (attacker <= MaxClients && attacker > 0)
		{
			int iFlags = GetEntityFlags(victim);
			if ( (iFlags & (FL_ONGROUND|FL_DUCKING)) == (FL_ONGROUND|FL_DUCKING) )
			{
				damage *= 0.2;
				return Plugin_Changed;
			}
			if (damagecustom == TF_CUSTOM_BOOTS_STOMP)
			{
				damage = 1024.0;
				return Plugin_Changed;
			}
			if ( damagecustom == TF_CUSTOM_TELEFRAG )
			{
				if (!IsPlayerAlive(attacker))
				{
					damage = 1.0;
					return Plugin_Changed;
				}
#if defined DEBUG
				DEBUGPRINT1("VSH Vagineer::VSHA_OnBossTeleFragd() **** Forward Responded ****");
				DEBUGPRINT2("{lime}VSH Vagineer::VSHA_OnBossTeleFragd() **** Forward Responded ****");
#endif
				damage = view_as<float>( VSHA_GetBossHealth(victim) ); //(HaleHealth > 9001 ? 15.0:float(GetEntProp(Hale, Prop_Send, "m_iHealth")) + 90.0);
				int teleowner = FindTeleOwner(attacker);
				if (IsValidClient(teleowner) && teleowner != attacker)
				{
					VSHA_SetDamage(teleowner, VSHA_GetDamage(teleowner)+9001);
					//Damage[teleowner] += 9001; //RoundFloat(9001.0 * 3 / 5);
					PrintCenterText(teleowner, "TELEFRAG ASSIST! Nice job setting up!");
				}
				PrintCenterText(attacker, "TELEFRAG! You are a Pro!");
				PrintCenterText(victim, "TELEFRAG! Be careful around quantum tunneling devices!");
				return Plugin_Changed;
			}
			int heavyhealth = GetClientHealth(attacker);
			char classname[32];
			if (IsValidEdict(weapon)) GetEdictClassname(weapon, classname, sizeof(classname));
			if ( !strcmp(classname, "tf_weapon_shotgun_hwg", false) && heavyhealth < 451 )
			{
				SetEntityHealth(attacker, heavyhealth+(RoundFloat(damage)/2));
			}

			int weapindex = GetItemIndex(weapon);
			switch (weapindex)
			{
				case 593:		//Third Degree
				{
					int healers[MAXPLAYERS];
					int healercount = 0;
					for (int i = 1; i <= MaxClients; i++)
					{
						if (IsValidClient(i) && IsPlayerAlive(i) && (GetHealingTarget(i) == attacker))
						{
							healers[healercount] = i;
							healercount++;
						}
					}
					for (int i = 0; i < healercount; i++)
					{
						if (IsValidClient(healers[i]) && IsPlayerAlive(healers[i]))
						{
							int medigun = GetPlayerWeaponSlot(healers[i], TFWeaponSlot_Secondary);
							if (IsValidEntity(medigun))
							{
								char cls[64];
								GetEdictClassname(medigun, cls, sizeof(cls));
								if (strcmp(cls, "tf_weapon_medigun", false) == 0)
								{
									float uber = GetMediCharge(medigun) + (0.1 / healercount);
									float max = 1.0;
									if (GetEntProp(medigun, Prop_Send, "m_bChargeRelease")) max = 1.5;
									if (uber > max) uber = max;
									SetMediCharge(medigun, uber);
								}
							}
						}
					}
				}
				case 14, 201, 230, 402, 526, 664, 752, 792, 801, 851, 881, 890, 899, 908, 957, 966, 1098:
				{
					switch (weapindex)
					{
						case 14, 201, 664, 792, 801, 851, 881, 890, 899, 908, 957, 966:
						{
							if (CheckRoundState() != 2)
							{
								float chargelevel = (IsValidEntity(weapon) && weapon > MaxClients ? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
								float curGlow = VSHA_GetGlowTimer(victim);
								float time = (curGlow > 10 ? 1.0 : 2.0);
								time += (curGlow > 10 ? (curGlow > 20 ? 1 : 2) : 4)*(chargelevel/100);
								VSHA_SetGlowTimer(victim, curGlow+time);
								if (curGlow+time > 30.0) VSHA_SetGlowTimer(victim, 30.0); //convar/cvar heer
								//SetEntProp(victim, Prop_Send, "m_bGlowEnabled", 1);
								//GlowTimer += RoundToCeil(time);
								//if (GlowTimer > 30.0) GlowTimer = 30.0;
							}
						}
					}
					if (weapindex == 752 && CheckRoundState() != 2)
					{
						float chargelevel = (IsValidEntity(weapon) && weapon > MaxClients ? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
						float add = 10 + (chargelevel / 10);
						if ( TF2_IsPlayerInCondition(attacker, view_as<TFCond>(46)) ) add /= 3.0;
						float rage = GetEntPropFloat(attacker, Prop_Send, "m_flRageMeter");
						SetEntPropFloat(attacker, Prop_Send, "m_flRageMeter", (rage + add > 100) ? 100.0 : rage + add);
					}
					if ( !(damagetype & DMG_CRIT) )
					{
						bool ministatus = (TF2_IsPlayerInCondition(attacker, TFCond_CritCola) || TF2_IsPlayerInCondition(attacker, TFCond_Buffed) || TF2_IsPlayerInCondition(attacker, TFCond_CritHype));

						damage *= (ministatus) ? 2.222222 : 3.0;
						if (weapindex == 230) VSHA_SetBossRage( victim, VSHA_GetBossRage(victim)-(damage/2.0/10.0) ); //make this a convar/cvar!
						//{
							//HaleRage -= RoundFloat(damage/2.0);
							//if (HaleRage < 0) HaleRage = 0;
						//}
						return Plugin_Changed;
					}
					else if (weapindex == 230) VSHA_SetBossRage( victim, VSHA_GetBossRage(victim)-(damage*3.0/2.0/10.0) );
					//{
						//HaleRage -= RoundFloat(damage*3.0/2.0);
						//if (HaleRage < 0) HaleRage = 0;
					//}
				}
				case 132, 266, 482, 1082: IncrementHeadCount(attacker);
				case 416: // Chdata's Market Gardener backstab
				{
					if (VSHA_IsPlayerInJump(attacker))
					{
						float curMaxHelth = view_as<float>(VSHA_GetBossMaxHealth(victim));
						int markethits = VSHA_GetBossMarkets(victim);
						damage = ( Pow(curMaxHelth, (0.74074)) + 512.0 - (markethits/128*curMaxHelth) )/3.0;
						//divide by 3 because this is basedamage and lolcrits (0.714286)) + 1024.0)
						damagetype |= DMG_CRIT;

						//if (Marketed < 5) Marketed++;
						if (markethits < 5) VSHA_SetBossMarkets(victim, markethits+1);

						PrintCenterText(attacker, "You market gardened him!");
						PrintCenterText(victim, "You were just market gardened!");

						float Pos[3];
						GetEntPropVector(victim, Prop_Send, "m_vecOrigin", Pos);
						EmitSoundToClient(victim, "player/doubledonk.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 0.6, 100, _, Pos, NULL_VECTOR, false, 0.0);
						EmitSoundToClient(attacker, "player/doubledonk.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 0.6, 100, _, Pos, NULL_VECTOR, false, 0.0);
						return Plugin_Changed;
					}
				}
				case 317: SpawnSmallHealthPackAt(victim, GetClientTeam(attacker));
				case 214:
				{
					int health = GetClientHealth(attacker);
					int max = GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
					int newhealth = health+25;
					if (health < max+50)
					{
						if (newhealth > max+50) newhealth = max+50;
						SetEntProp(attacker, Prop_Data, "m_iHealth", newhealth);
						SetEntProp(attacker, Prop_Send, "m_iHealth", newhealth);
					}
					if (TF2_IsPlayerInCondition(attacker, TFCond_OnFire)) TF2_RemoveCondition(attacker, TFCond_OnFire);
				}
				case 594: // Phlog
				{
					if (!TF2_IsPlayerInCondition(attacker, TFCond_CritMmmph))
					{
						damage /= 2.0;
						return Plugin_Changed;
					}
				}
				case 357:
				{
					SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
					if (GetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy") < 1)
					SetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
					int health = GetClientHealth(attacker);
					int max = GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
					int newhealth = health+35;
					if (health < max+25)
					{
						if (newhealth > max+25) newhealth = max+25;
						SetEntProp(attacker, Prop_Data, "m_iHealth", newhealth);
						SetEntProp(attacker, Prop_Send, "m_iHealth", newhealth);
					}
					if (TF2_IsPlayerInCondition(attacker, TFCond_OnFire)) TF2_RemoveCondition(attacker, TFCond_OnFire);
				}
				case 61, 1006:	//Ambassador does 2.5x damage on headshot
				{
					if (damagecustom == TF_CUSTOM_HEADSHOT)
					{
						damage = 100.0;
						return Plugin_Changed;
					}
				}
				case 525, 595:
				{
					int iCrits = GetEntProp(attacker, Prop_Send, "m_iRevengeCrits");
					if (iCrits > 0) //If a revenge crit was used, give a damage bonus
					{
						damage = 85.0;
						return Plugin_Changed;
					}
				}
				case 656:
				{
					CreateTimer(3.0, Timer_StopTickle, GetClientUserId(victim), TIMER_FLAG_NO_MAPCHANGE);
					if (TF2_IsPlayerInCondition(attacker, TFCond_Dazed)) TF2_RemoveCondition(attacker, TFCond_Dazed);
				}
			}
			if (damagecustom == TF_CUSTOM_BACKSTAB)
			{
				//damage = ( (Pow(float(iBossMaxHealth[victim])*0.0014, 2.0) + 899.0) - (float(iBossMaxHealth[victim])*(iStabbed[victim]/100)) )/3;
				float curMaxHelth = view_as<float>(VSHA_GetBossMaxHealth(victim));
				int stabamounts = VSHA_GetBossStabs(victim);
				float changedamage = ( (Pow(curMaxHelth*0.0014, 2.0) + 899.0) - (curMaxHelth*(stabamounts/100)) );

				damage = changedamage/3; // You can level "damage dealt" with backstabs

				damagetype |= DMG_CRIT;

				EmitSoundToClient(victim, "player/spy_shield_break.wav", _, _, SNDLEVEL_TRAFFIC, _, 0.7, 100, _, AttackerPos, _, false);
				EmitSoundToClient(attacker, "player/spy_shield_break.wav", _, _, SNDLEVEL_TRAFFIC, _, 0.7, 100, _, AttackerPos, _, false);
				EmitSoundToClient(victim, "player/crit_received3.wav", _, _, SNDLEVEL_TRAFFIC, _, 0.7, 100, _, _, _, false);
				EmitSoundToClient(attacker, "player/crit_received3.wav", _, _, SNDLEVEL_TRAFFIC, _, 0.7, 100, _, _, _, false);
				SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 2.0);
				SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", GetGameTime() + 2.0);
				SetEntPropFloat(attacker, Prop_Send, "m_flStealthNextChangeTime", GetGameTime() + 1.0);

				TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, 1.5);
				TF2_AddCondition(attacker, TFCond_Ubercharged, 2.0);

				int viewmodel = GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
				if (viewmodel > MaxClients && IsValidEntity(viewmodel) && TF2_GetPlayerClass(attacker) == TFClass_Spy)
				{
					int melee = GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Melee);
					int animation = 15;
					switch (melee)
					{
						case 727: animation = 41; //Black Rose
						case 4, 194, 665, 794, 803, 883, 892, 901, 910: animation = 10; //Knife, Strange Knife, Festive Knife, Botkiller Knifes
						case 638: animation = 31; //Sharp Dresser
					}
					SetEntProp(viewmodel, Prop_Send, "m_nSequence", animation);
				}
				PrintCenterText(attacker, "You Tickled The Boss!");
				PrintCenterText(victim, "You Were Just Tickled!");

#if defined DEBUG
				DEBUGPRINT1("VSH Vagineer::VSHA_OnBossStabbed() **** Forward Responded ****");
				DEBUGPRINT2("{lime}VSH Vagineer::VSHA_OnBossStabbed() **** Forward Responded ****");
#endif

				int pistol = GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Primary);
				if (pistol == 525) //Diamondback gives 3 crits on backstab
				{
					int iCrits = GetEntProp(attacker, Prop_Send, "m_iRevengeCrits");
					SetEntProp(attacker, Prop_Send, "m_iRevengeCrits", iCrits+2);
				}
				if (weapindex == 356)
				{
					int health = GetClientHealth(attacker) + 180;
					if (health > 195) health = 390;
					SetEntProp(attacker, Prop_Data, "m_iHealth", health);
					SetEntProp(attacker, Prop_Send, "m_iHealth", health);
				}
				if (weapindex == 461) SetEntPropFloat(attacker, Prop_Send, "m_flCloakMeter", 100.0); //Big Earner gives full cloak on backstab

				if (stabamounts < 4) VSHA_SetBossStabs(victim, VSHA_GetBossStabs(victim)+1);
				return Plugin_Changed;
			}
			if (TF2_GetPlayerClass(attacker) == TFClass_Scout)
			{
				if (weapindex == 45 || ((weapindex == 209 || weapindex == 294 || weapindex == 23 || weapindex == 160 || weapindex == 449) && (TF2_IsPlayerCritBuffed(victim) || TF2_IsPlayerInCondition(victim, TFCond_CritCola) || TF2_IsPlayerInCondition(victim, TFCond_Buffed) || TF2_IsPlayerInCondition(victim, TFCond_CritHype))))
				{
					ScaleVector(damageForce, 0.38);
					return Plugin_Changed;
				}
			}
		}
		else
		{
			char hurt[64];
			if (GetEdictClassname(attacker, hurt, sizeof(hurt)) && !strcmp(hurt, "trigger_hurt", false))
			{
				// Teleport the boss back to one of the spawns.
				// And during the first 30 seconds, he can only teleport to his own spawn.
				//TeleportToSpawn(victim, (bTenSecStart[1]) ? HaleTeam : 0);
				if (damage >= 500.0) TeleportToSpawn(victim, GetRandomInt(2, 3));

				float flMaxDmg = float(VSHA_GetBossMaxHealth(victim))*0.05;
				if (flMaxDmg > 500.0) flMaxDmg = 500.0;
				if (damage > flMaxDmg) damage = flMaxDmg;

				VSHA_SetBossRage( victim, (VSHA_GetBossRage(victim)+(damage/50.0)) );
				VSHA_SetBossHealth( victim, (VSHA_GetBossHealth(victim)-RoundFloat(damage)) );
				if (VSHA_GetBossHealth(victim) <= 0) damage *= 5;
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

public Action UseRage(Handle hTimer, int userid)
{
	int iClient = GetClientOfUserId(userid);
	float pos[3], pos2[3];
	int i;
	float distance;
	if (!IsValidClient(iClient)) return Plugin_Continue;
	if (!GetEntProp(iClient, Prop_Send, "m_bIsReadyToHighFive") && !IsValidEntity(GetEntPropEnt(iClient, Prop_Send, "m_hHighFivePartner")))
	{
		TF2_RemoveCondition(iClient, TFCond_Taunting);
	}
	GetEntPropVector(iClient, Prop_Send, "m_vecOrigin", pos);
	for (i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsPlayerAlive(i) && i != iClient)
		{
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			distance = GetVectorDistance(pos, pos2);
			if (!TF2_IsPlayerInCondition(i, TFCond_Ubercharged) && distance < RageDist)
			{
				int flags = TF_STUNFLAGS_GHOSTSCARE;
				flags |= TF_STUNFLAG_NOSOUNDOREFFECT;
				PawnTimer(RemoveEnt, 5.0, EntIndexToEntRef(AttachParticle(i, "yikes_fx", 75.0)));
				if (CheckRoundState() != 0) TF2_StunPlayer(i, 5.0, _, flags, iClient);
			}
		}
	}
	StunSentry(iClient, RageDist, 6.0, GetEntProp(i, Prop_Send, "m_iHealth"));
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
stock bool OnlyScoutsLeft()
{
	for (int client; client <= MaxClients; client++)
	{
		if (IsValidClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2)
		{
			if (TF2_GetPlayerClass(client) != TFClass_Scout) break;
			return true;
		}
	}
	return false;
}

// LOAD CONFIGURATION
public void VSHA_OnConfiguration_Load_Sounds(char[] skey, char[] value, bool &bPreCacheFile, bool &bAddFileToDownloadsTable)
{
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
public void VSHA_OnConfiguration_Load_Materials(char[] skey, char[] value, bool &bPrecacheGeneric, bool &bAddFileToDownloadsTable)
{
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
public void VSHA_OnConfiguration_Load_Models(char[] skey, char[] value, bool &bPreCacheModel, bool &bAddFileToDownloadsTable)
{
	if(StrEqual(skey, "VagiModel"))
	{
		strcopy(STRING(VagiModel), value);
		bPreCacheModel = true;
		bAddFileToDownloadsTable = true;
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
public void VSHA_OnConfiguration_Load_Misc(char[] skey, char[] value)
{
}
*/
