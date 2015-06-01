#pragma semicolon 1
#include <sourcemod>
#include <sdkhooks>
#include <morecolors>
#include <vsha>
#include <vsha_stocks>

public Plugin myinfo =
{
	name 			= "Hatsunemiku",
	author 			= "Valve",
	description 		= "Hatsunemiku",
	version 		= "1.0",
	url 			= "http://en.wikipedia.org/wiki/Hatsune_Miku"
}

#define ThisConfigurationFile "configs/vsha/miku.cfg"

char MikuModel[PATHX];
char MikuModelPrefix[PATHX];

char timeleap[PATHX];

bool InRage[PATHX];

char MIKUTheme[PATHX];


stock int CreateVSHASParticle(const char[] effectName, const float fPos[3])
{
	int particle = CreateEntityByName("info_particle_system");
	if (IsValidEdict(particle))
	{
		TeleportEntity(particle, fPos, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(particle, "effect_name", effectName);
		DispatchSpawn(particle);

		ActivateEntity(particle);
		AcceptEntityInput(particle, "Start");

		return particle;
	}
	else
	{
		PrintToServer("Couldn't create info_particle_system!");
	}

	return -1;
}

stock void ModifyEntityAttach(const int entityIndex, const int otherEntityIndex, const char[] attachTo="")
{
	if (IsValidEdict(entityIndex))
	{
		SetVariantString("!activator");
		AcceptEntityInput(entityIndex, "SetParent", otherEntityIndex, entityIndex, 0);

		if (!StrEqual(attachTo, ""))
		{
			SetVariantString(attachTo);
			AcceptEntityInput(entityIndex, "SetParentAttachment", entityIndex, entityIndex, 0);
		}
	}
}

stock void ModifyEntityAddDeathTimer(const int entityIndex, const float vshalifetime)
{
	if (IsValidEdict(entityIndex))
	{
		char variantString[60];
		Format(variantString, sizeof(variantString), "OnUser1 !self:Kill::%f:-1", vshalifetime);

		SetVariantString(variantString);
		AcceptEntityInput(entityIndex, "AddOutput");
		AcceptEntityInput(entityIndex, "FireUser1");
	}
}

stock int AttachThrowAwayParticle(const int client, const char[] effectName, const float fPos[3], const char[] attachTo, const float vshalifetime)
{
	int particle = CreateVSHASParticle(effectName, fPos);
	ModifyEntityAttach(particle, client, attachTo);
	ModifyEntityAddDeathTimer(particle, vshalifetime);

	return particle;
}

#define HALE_JUMPCHARGETIME		4
#define HALE_JUMPCHARGE			(25 * HALE_JUMPCHARGETIME)

stock const char MikuWin[][] = {
	"saxton_hale/miku/miku_yay.mp3",
	"saxton_hale/miku/miku_yay2.mp3",
	"saxton_hale/miku/miku_yay3.mp3"
};
stock const char MikuJump[][] = {
	"saxton_hale/miku/miku_huh.mp3",
	"saxton_hale/miku/miku_huh2.mp3"
};
stock const char MikuRage[][] = {
	"saxton_hale/miku/miku_excuse_me.mp3",
	"saxton_hale/miku/miku_no.mp3"
};
stock const char MikuFail[][] = {
	"saxton_hale/miku/miku_go_away.mp3",
	"saxton_hale/miku/miku_see_you_next_time.mp3"
};
stock const char MikuKill[][] = {
	"saxton_hale/miku/miku_goodnight.mp3",
	"saxton_hale/miku/miku_goodnight2.mp3",
	"saxton_hale/miku/miku_goodbye.mp3"
};
stock const char MikuSpree[][] = {
	"saxton_hale/miku/miku_no_way.mp3",
	"saxton_hale/miku/miku_i_like_this.mp3"
};
stock const char MikuLast[][] = {
	"saxton_hale/miku/miku_awesome.mp3",
	"saxton_hale/miku/miku_come_here.mp3"
};
stock const char MikuPain[][] = {
	"saxton_hale/miku/miku_help1.mp3",
	"saxton_hale/miku/miku_help2.mp3",
	"saxton_hale/miku/miku_help3.mp3",
	"saxton_hale/miku/miku_stop_bothering_me.mp3",
	"saxton_hale/miku/miku_leave_me_alone.mp3",
	"saxton_hale/miku/miku_stop.mp3"
};
stock const char MikuStart[][] = {
	"saxton_hale/miku/miku_go.mp3",
	"saxton_hale/miku/miku_good_morning.mp3",
	"saxton_hale/miku/miku_cute.mp3"
};
stock const char MikuRandomVoice[][] = {
	"saxton_hale/miku/miku_what.mp3",
	"saxton_hale/miku/miku_what2.mp3",
	"saxton_hale/miku/miku_what3.mp3",
	"saxton_hale/miku/miku_what4.mp3",
	"saxton_hale/miku/miku_what_is_this.mp3"
};

public void VSHA_AddToDownloads()
{
	char s[PLATFORM_MAX_PATH];
	int i = 0;
	for (i = 0; i < sizeof(MikuWin); i++)
	{
		PrecacheSound(MikuWin[i], true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", MikuWin[i]);
		AddFileToDownloadsTable(s);
	}
	for (i = 0; i < sizeof(MikuJump); i++)
	{
		PrecacheSound(MikuJump[i], true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", MikuJump[i]);
		AddFileToDownloadsTable(s);
	}
	for (i = 0; i < sizeof(MikuRage); i++)
	{
		PrecacheSound(MikuRage[i], true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", MikuRage[i]);
		AddFileToDownloadsTable(s);
	}
	for (i = 0; i < sizeof(MikuFail); i++)
	{
		PrecacheSound(MikuFail[i], true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", MikuFail[i]);
		AddFileToDownloadsTable(s);
	}
	for (i = 0; i < sizeof(MikuKill); i++)
	{
		PrecacheSound(MikuKill[i], true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", MikuKill[i]);
		AddFileToDownloadsTable(s);
	}
	for (i = 0; i < sizeof(MikuSpree); i++)
	{
		PrecacheSound(MikuSpree[i], true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", MikuSpree[i]);
		AddFileToDownloadsTable(s);
	}
	for (i = 0; i < sizeof(MikuLast); i++)
	{
		PrecacheSound(MikuLast[i], true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", MikuLast[i]);
		AddFileToDownloadsTable(s);
	}
	for (i = 0; i < sizeof(MikuPain); i++)
	{
		PrecacheSound(MikuPain[i], true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", MikuPain[i]);
		AddFileToDownloadsTable(s);
	}
	for (i = 0; i < sizeof(MikuStart); i++)
	{
		PrecacheSound(MikuStart[i], true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", MikuStart[i]);
		AddFileToDownloadsTable(s);
	}
	for (i = 0; i < sizeof(MikuRandomVoice); i++)
	{
		PrecacheSound(MikuRandomVoice[i], true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", MikuRandomVoice[i]);
		AddFileToDownloadsTable(s);
	}
}

//Handle ThisPluginHandle = null; //DO NOT TOUCH THIS, THIS IS JUST USED AS HOLDING DATA.

//make defines, handles, variables heer lololol
int HaleCharge[PLYR];

int Hale[PLYR];

float WeighDownTimer = 0.0;
//float RageDist = 800.0;

char playsound[PATHX];

int JumpCoolDown[PLYR];

Handle JumpTimerHandle[PLYR];

int m_vecVelocity_0;

public void OnPluginStart()
{
	m_vecVelocity_0 = FindSendPropOffs("CBasePlayer","m_vecVelocity[0]");

	//RegConsoleCmd("+ability",VSHA_AbilityCommand);
	//RegConsoleCmd("-ability",VSHA_AbilityCommand);
}
/*
bool HaleAbilityPressed[PLYR];

public Action VSHA_AbilityCommand(int client, int args)
{
	if(client != Hale[client]) return Plugin_Continue;
	char command[32];
	GetCmdArg(0,command,sizeof(command));

	bool pressed=false;
	//PrintToChatAll("%s",command) ;

	if(StrContains(command,"+")>-1) pressed=true;
	HaleAbilityPressed[client]=pressed;

	return Plugin_Handled;
}*/

Handle hThisBoss;

public void OnAllPluginsLoaded()
{
	//ThisPluginHandle = view_as<Handle>( VSHA_RegisterBoss("miku","Hatsunemiku") );
	hThisBoss = view_as<Handle>( VSHA_RegisterBoss("miku","Hatsunemiku") );

	HookEvent("player_changeclass", ChangeClass);

	VSHA_LoadConfiguration(ThisConfigurationFile);
}

public void OnMapEnd()
{
	WeighDownTimer = 0.0;
	//RageDist = 800.0;

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
				//DP("vsha-saxtonhale 166 ForceTeamChange(i, 3)");
			}
		}
	}
}
public Action ChangeClass(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId( event.GetInt("userid") );
	if (client == Hale[client])
	{
		DP("MIKU ChangeClass");
		if (TF2_GetPlayerClass(client) != TFClass_Scout) TF2_SetPlayerClass(client, TFClass_Scout, _, false);
		TF2_RemovePlayerDisguise(client);
	}
	return Plugin_Continue;
}

public void VSHA_OnPlayerKilledByBoss(int iiBoss, int attacker)
{
	if(Hale[iiBoss] != iiBoss) return;

	if (!GetRandomInt(0, 2) && VSHA_GetAliveRedPlayers() != 1)
	{
		strcopy(playsound, PLATFORM_MAX_PATH, MikuKill[GetRandomInt(0, sizeof(MikuKill)-1)]);
	}
	if ( !StrEqual(playsound, "") ) EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);

	return;
}
public void VSHA_OnKillingSpreeByBoss(int iiBoss, int attacker)
{
	if(Hale[iiBoss] != iiBoss) return;

	strcopy(playsound, PLATFORM_MAX_PATH, MikuSpree[GetRandomInt(0, sizeof(MikuSpree)-1)]);

	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);

	return;
}
public void VSHA_OnBossKilled(int iiBoss, int attacker) //victim is boss
{
	if(Hale[iiBoss] != iiBoss) return;

	strcopy(playsound, PLATFORM_MAX_PATH, MikuFail[GetRandomInt(0, sizeof(MikuFail)-1)]);
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iiBoss, NULL_VECTOR, NULL_VECTOR, false, 0.0);

	SDKUnhook(iiBoss, SDKHook_OnTakeDamage, OnTakeDamage);
	Hale[iiBoss] = 0;
	return;
}
public void VSHA_OnBossWin(Event event, int iiBoss)
{
	if(Hale[iiBoss] != iiBoss) return;

	strcopy(playsound, PLATFORM_MAX_PATH, MikuWin[GetRandomInt(0, sizeof(MikuWin)-1)]);
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	for (int i = 1; i <= MaxClients; i++)
	{
		if ( !IsClientValid(i) ) continue;
		StopSound(i, SNDCHAN_AUTO, MIKUTheme);
	}

	SDKUnhook(Hale[iiBoss], SDKHook_OnTakeDamage, OnTakeDamage);
	Hale[iiBoss] = 0;
	return;
}
public void VSHA_OnMessageTimer()
{
	//SetHudTextParams(-1.0, 0.4, 10.0, 255, 255, 255, 255);
	char text[PATHX];
	int client;
	for (client = 1; client <= MaxClients; client++)
	{
		if ( !IsValidClient(client) ) continue;
		if ( client == Hale[client] )
		{
			Format( text, sizeof(text), "%N became Saxton Hale with %i HP", client, VSHA_GetBossMaxHealth(client) );
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
}
public void VSHA_OnBossAirblasted(Event event, int iiBoss)
{
	if (iiBoss != Hale[iiBoss]) return;
	//float rage = 0.04*RageDMG;
	//HaleRage += RoundToCeil(rage);
	//if (HaleRage > RageDMG) HaleRage = RageDMG;
	VSHA_SetBossRage(Hale[iiBoss], VSHA_GetBossRage(Hale[iiBoss])+4.0); //make this a convar/cvar!

	return;
}
public void VSHA_OnBossSelected(Handle hBoss, int iiBoss)
{
	if(hThisBoss != hBoss) return;
	DP("MIKU VSHA_OnBossSelected");
	if (VSHA_IsBossPlayer(iiBoss)) Hale[iiBoss] = iiBoss;
	if ( iiBoss != Hale[iiBoss] && VSHA_IsBossPlayer(iiBoss) )
	{
		VSHA_SetIsBossPlayer(Hale[iiBoss], false);
		Hale[iiBoss] = iiBoss;
		ForceTeamChange(iiBoss, 3);
		//DP("vsha-saxtonhale 526 ForceTeamChange(iiBoss, 3)");
	}
	SDKHook(iiBoss, SDKHook_OnTakeDamage, OnTakeDamage);
	return;
}
public void VSHA_OnBossIntroTalk(Handle hPluginHndl)
{
	if(hThisBoss != hPluginHndl) return;
	DP("MIKU VSHA_OnBossIntroTalk");
	strcopy(playsound, PLATFORM_MAX_PATH, MikuStart[GetRandomInt(0, sizeof(MikuStart)-1)]);
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	return;
}
public Action VSHA_OnBossSetHP(int BossEntity, int &BossMaxHealth)
{
	if (BossEntity != Hale[BossEntity]) return Plugin_Continue;
	DP("MIKU VSHA_OnBossSetHP");
	BossMaxHealth = HealthCalc( 760.8, view_as<float>( VSHA_GetPlayerCount() ), 1.0, 1.0341, 2046.0 );
	VSHA_SetBossMaxHealth(Hale[BossEntity], BossMaxHealth);

	return Plugin_Continue;
}
public void VSHA_OnLastSurvivor()
{
	DP("MIKU VSHA_OnLastSurvivor");
	strcopy(playsound, PLATFORM_MAX_PATH, MikuLast[GetRandomInt(0, sizeof(MikuLast)-1)]);

	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public void VSHA_OnBossTimer(int iClient, int &curHealth, int &curMaxHp)
{
	if (iClient != Hale[iClient]) return;
	//DP("MIKU iClient = %d Hale[iClient] = %d",iClient,Hale[iClient]);
	float speed;
	//int curHealth = VSHA_GetBossHealth(iClient), curMaxHp = VSHA_GetBossMaxHealth(iClient);
	// temporary health fix
	if (curHealth < 0 && IsPlayerAlive(iClient))
	{
		ForcePlayerSuicide(iClient);
		return;
	}
	if(GetClientHealth(iClient) != curHealth)
	{
		SetEntityHealth(iClient,curHealth);
	}
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
			ShowHudText(iClient, -1, "Mini-Super Jump will be ready again in: %i", (-HaleCharge[iClient]/10));
		}
	}
	else
	{
		// 5 * 60 = 300
		// 5 * .2 = 1 second, so 5 times number of seconds equals number for HaleCharge after superjump
		// 300 = 1 minute wait
		//float ExtraBoost = float(HaleCharge[iClient]) * 2;
		float ExtraBoost = float(HaleCharge[iClient]) / 10;
		if ( HaleCharge[iClient] > 1 && SuperJump(iClient, ExtraBoost, -15.0, HaleCharge[iClient], -150) ) //put convar/cvar for jump sensitivity here!
		{
			strcopy(playsound, PLATFORM_MAX_PATH, MikuJump[GetRandomInt(0, sizeof(MikuJump)-1)]);
			EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iClient, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		}
	}

	if (VSHA_GetAliveRedPlayers() == 1) PrintCenterTextAll("Saxton Hale's Current Health is: %i of %i", curHealth, curMaxHp);
	if ( OnlyScoutsLeft() ) VSHA_SetBossRage(iClient, VSHA_GetBossRage(iClient)+0.5);

	VSHA_SetBossRage(iClient, VSHA_GetBossRage(iClient)+1.0);

	if ( !(GetEntityFlags(iClient) & FL_ONGROUND) ) WeighDownTimer += 0.2;
	else WeighDownTimer = 0.0;

	if ( (buttons & IN_DUCK) && Weighdown(iClient, WeighDownTimer, 60.0, 0.0) )
	{
		//CPrintToChat(client, "{olive}[VSHE]{default} You just used your weighdown!");
		//all this just to do a cprint? It's not like weighdown has a limit...
	}
	return;
}
public void VSHA_OnPrepBoss(int iClient)
{
	if (iClient != Hale[iClient]) return;
	DP("MIKU VSHA_OnPrepBoss");
	TF2_SetPlayerClass(iClient, TFClass_Scout, _, false);
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
		Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 3.0 ; 259 ; 1.0 ; 252 ; 0.6 ; 214 ; %d", GetRandomInt(999, 9999));
		int SaxtonWeapon = SpawnWeapon(iClient, "tf_weapon_shovel", 5, 100, 4, attribs);
		SetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
	}
}
public Action VSHA_OnMusic(Handle hPluginHndl, char BossTheme[PATHX], float &time)
{
	if(hThisBoss != hPluginHndl) return Plugin_Continue;
	PrintToChatAll("MIKUTheme OnMusic %s",MIKUTheme);

	time = 210.0;
	BossTheme = MIKUTheme;

	//StringMap SoundMap = new StringMap();
	//SoundMap.SetString("Sound", MIKUTheme);
	//VSHA_SetVar(EventSound,SoundMap);
	//VSHA_SetVar(EventTime,time);

	return Plugin_Continue;
}
public Action VSHA_OnModelTimer(int iClient, char modelpath[PATHX])
{
	//DP("VSHA_OnModelTimer");
	if (iClient != Hale[iClient])
	{
		return Plugin_Continue;
	}
	DP("MIKU VSHA_OnModelTimer");
	modelpath = MikuModel;
	return Plugin_Changed;
}
public void VSHA_OnBossRage(int iClient)
{
	if (iClient != Hale[iClient]) return;
	float pos[3];
	GetEntPropVector(iClient, Prop_Send, "m_vecOrigin", pos);
	pos[2] += 20.0;
	TF2_AddCondition(iClient, view_as<TFCond>(42), 4.0);
	strcopy(playsound, PLATFORM_MAX_PATH, MikuRage[GetRandomInt(1, sizeof(MikuRage)-1)]);
	EmitSoundToAll(playsound, iClient, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iClient, pos, NULL_VECTOR, true, 0.0);
	EmitSoundToAll(playsound, iClient, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iClient, pos, NULL_VECTOR, true, 0.0);
	CreateTimer(0.6, UseRage, iClient);
	return;
}
public void TF2_OnConditionAdded(int client, TFCond condition)
{
	if (client != Hale[client]) return;
	switch (condition)
	{
		case TFCond_Jarated:
		{
#if defined DEBUG
			DEBUGPRINT1("VSH SaxtonHale::TF2_OnConditionAdded() **** Hale was Jarated ****");
			DEBUGPRINT2("{lime}VSH SaxtonHale::TF2_OnConditionAdded() **** Hale was Jarated ****");
#endif
			VSHA_SetBossRage(Hale[client], VSHA_GetBossRage(client)-8.0);
			TF2_RemoveCondition(Hale[client], condition);
		}
		case TFCond_MarkedForDeath:
		{
#if defined DEBUG
			DEBUGPRINT1("VSH SaxtonHale::TF2_OnConditionAdded() **** Hale was MarkedForDeath ****");
			DEBUGPRINT2("{lime}VSH SaxtonHale::TF2_OnConditionAdded() **** Hale was MarkedForDeath ****");
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
	//DP("attacker = %d, victim = %d, hale[victim] = %d",attacker,victim,Hale[victim]);
	//if((attacker <= 0) && (victim == Hale[victim])) return Plugin_Continue;

	// removed the = sign because we need to detect when hale takes damage from falls,
	// so we can remove that damage.

	if(TF2_IsPlayerInCondition(victim, TFCond_Ubercharged)) return Plugin_Continue;

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
			damage = (VSHA_GetBossHealth(Hale[victim]) > 100) ? 10.0 : 100.0; //please don't fuck with this.
			//damage = 0.0;
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
				DEBUGPRINT1("VSH SaxtonHale::VSHA_OnBossTeleFragd() **** Forward Responded ****");
				DEBUGPRINT2("{lime}VSH SaxtonHale::VSHA_OnBossTeleFragd() **** Forward Responded ****");
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
				case 593:       //Third Degree
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
				case 61, 1006:  //Ambassador does 2.5x damage on headshot
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
				DEBUGPRINT1("VSH SaxtonHale::VSHA_OnBossStabbed() **** Forward Responded ****");
				DEBUGPRINT2("{lime}VSH SaxtonHale::VSHA_OnBossStabbed() **** Forward Responded ****");
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

				strcopy(playsound, PLATFORM_MAX_PATH, MikuPain[GetRandomInt(0, sizeof(MikuPain)-1)]);
				EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim, NULL_VECTOR, NULL_VECTOR, false, 0.0);
				EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim, NULL_VECTOR, NULL_VECTOR, false, 0.0);

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
public Action UseRage(Handle hTimer, any client)
{
	//float pos[3], pos2[3];
	//int i;
	//float distance;
	if (!IsValidClient(client)) return Plugin_Continue;
	if (!GetEntProp(client, Prop_Send, "m_bIsReadyToHighFive") && !IsValidEntity(GetEntPropEnt(client, Prop_Send, "m_hHighFivePartner")))
	{
		TF2_RemoveCondition(client, TFCond_Taunting);
	}
	/*
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
	for (i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsPlayerAlive(i) && i != client)
		{
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			distance = GetVectorDistance(pos, pos2);
			if (!TF2_IsPlayerInCondition(i, TFCond_Ubercharged) && distance < RageDist)
			{
				int flags = TF_STUNFLAGS_GHOSTSCARE;
				flags |= TF_STUNFLAG_NOSOUNDOREFFECT;
				PawnTimer( RemoveEnt, 5.0, EntIndexToEntRef(AttachParticle(i, "yikes_fx", 75.0)) );
				if (CheckRoundState() != 0) TF2_StunPlayer(i, 5.0, _, flags, client);
			}
		}
	}*/
	CPrintToChat(client,"%s {red}RAGE! {yellow}You can now sprint with no cooldown!",VSHA_COLOR);

	InRage[client] = true;

	int flags = GetEntityFlags(client)|FL_NOTARGET;
	SetEntityFlags(client, flags);

	float origin[3];

	GetClientAbsOrigin(client,origin);
	AttachThrowAwayParticle(client, GetClientTeam(client)==2?"burningplayer_red":"burningplayer_blue", origin, "", 10.0);

	origin[2]+=40.0;
	AttachThrowAwayParticle(client, "unusual_spellbook_circle_purple", origin, "", 10.0);

	origin[2]+=40.0;
	AttachThrowAwayParticle(client, "unusual_spotlights", origin, "", 10.0);

	CreateTimer(10.0,EndRage,GetClientUserId(client));

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
public Action VSHA_OnConfiguration_Load_Sounds(const char[] cfile, char[] skey, char[] value, bool &bPreCacheFile, bool &bAddFileToDownloadsTable)
{
	if(!StrEqual(cfile, ThisConfigurationFile)) return Plugin_Continue;

	if(StrEqual(skey, "MIKUTheme"))
	{
		strcopy(STRING(MIKUTheme), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "timeleap"))
	{
		strcopy(STRING(timeleap), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}

	if(bPreCacheFile || bAddFileToDownloadsTable)
	{
		PrintToServer("Loading Sounds %s = '%s'",skey,value);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
public Action VSHA_OnConfiguration_Load_Materials(const char[] cfile, char[] skey, char[] value, bool &bPrecacheGeneric, bool &bAddFileToDownloadsTable)
{
	if(!StrEqual(cfile, ThisConfigurationFile)) return Plugin_Continue;

	if(StrEqual(skey, "MikuMaterialPrefix"))
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
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
public Action VSHA_OnConfiguration_Load_Models(const char[] cfile, char[] skey, char[] value, bool &bPreCacheModel, bool &bAddFileToDownloadsTable)
{
	if(!StrEqual(cfile, ThisConfigurationFile)) return Plugin_Continue;

	if(StrEqual(skey, "MikuModel"))
	{
		strcopy(STRING(MikuModel), value);
		bPreCacheModel = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "MikuModelPrefix"))
	{
		char s[PATHX];
		char extensions[][] = { ".mdl", ".dx80.vtx", ".dx90.vtx", ".sw.vtx", ".vvd", ".phy" };

		for (int i = 0; i < sizeof(extensions); i++)
		{
			Format(s, PATHX, "%s%s", MikuModelPrefix, extensions[i]);
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
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
// Just in case you want to have extra configurations for your sub plugin.
// This makes loading configurations easier for you.
// Keeping all your configurations for your sub plugin in one location!
/*
public Action VSHA_OnConfiguration_Load_Misc(const char[] cfile, char[] skey, char[] value)
{
}
*/

bool lastframewasground[MAXPLAYERS + 1];

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if(client != Hale[client]) return Plugin_Continue;

	if(!InRage[client] && (JumpCoolDown[client] > GetTime())) return Plugin_Continue;

	if (buttons & IN_JUMP)
	//if(HaleAbilityPressed[client])
	{
		bool lastwasgroundtemp=lastframewasground[client];
		lastframewasground[client]=view_as<bool>(GetEntityFlags(client) & FL_ONGROUND);
		//if(!Hexed(client)&&War3_SkillNotInCooldown(client,thisRaceID,SKILL_LEAP) &&  lastwasgroundtemp &&   !(GetEntityFlags(client) & FL_ONGROUND) )
		if(lastwasgroundtemp && !(GetEntityFlags(client) & FL_ONGROUND) )
		{
			/*
			if(InRage[client])
			{
				float origin[3];

				GetClientAbsOrigin(client,origin);
				origin[2]+=40.0;
				AttachThrowAwayParticle(client, "unusual_spellbook_circle_purple", origin, "", 2.0);
				AttachThrowAwayParticle(client, "unusual_spellbook_circle_purple", origin, "", 2.0);

				origin[2]+=40.0;
				AttachThrowAwayParticle(client, "unusual_spotlights", origin, "", 2.0);
			}*/

			float velocity[3];
			GetEntDataVector(client, m_vecVelocity_0, velocity); //gets all 3

			float oldz=velocity[2];
			velocity[2]=0.0; //zero z
			float len=GetVectorLength(velocity);
			if(len>3.0){
				ScaleVector(velocity,2000.0/len); //650.0
				velocity[2]=oldz;
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
			}

			strcopy(playsound, PLATFORM_MAX_PATH, timeleap);
			EmitSoundToAll(playsound, _, SNDCHAN_AUTO, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, NULL_VECTOR, NULL_VECTOR, false, 0.0);
			EmitSoundToAll(playsound, _, SNDCHAN_AUTO, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, NULL_VECTOR, NULL_VECTOR, false, 0.0);
			//War3_EmitSoundToAll(leapsnd,client);
			//War3_EmitSoundToAll(leapsnd,client);

			//War3_CooldownMGR(client,10.0,thisRaceID,SKILL_LEAP,_,_);
			if(!InRage[client])
			{
				JumpCoolDown[client] = GetTime() + 30;
				JumpTimerHandle[client] = CreateTimer(1.0, CoolDownCountDown, GetClientUserId(client));
			}
			else
			{
				ClearTimer(JumpTimerHandle[client]);
				JumpCoolDown[client] = 0;
			}
		}
	}
	return Plugin_Continue;
}

public Action CoolDownCountDown(Handle hTimer, any userid)
{
	int client = GetClientOfUserId(userid);
	if(ValidPlayer(client,true))
	{
		int nNumber = JumpCoolDown[client] - GetTime();
		if(nNumber > 10)
		{
			JumpTimerHandle[client] = CreateTimer(1.0, CoolDownCountDown, GetClientUserId(client));
		}
		else if(nNumber > 0)
		{
			PrintHintText(client, "Sprint ready in %d Seconds",nNumber);
			JumpTimerHandle[client] = CreateTimer(1.0, CoolDownCountDown, GetClientUserId(client));
		}
		else
		{
			JumpTimerHandle[client] = null;
			PrintHintText(client, "SPRINT IS READY!",nNumber);
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}


public Action EndRage(Handle thandle, int userid)
{
	int client = GetClientOfUserId(userid);

	if(ValidPlayer(client))
	{
		int flags = GetEntityFlags(client)&~FL_NOTARGET;
		SetEntityFlags(client, flags);

		CPrintToChat(client,"%s {yellow}You are no longer raged.",VSHA_COLOR);
	}

	InRage[client] = false;

	return Plugin_Continue;
}

// Is triggered by VSHA engine when a boos needs a help menu
public void VSHA_ShowBossHelpMenu(int iClient)
{
	if(Hale[iClient] != iClient) return;

	if(Hale[iClient] == iClient && ValidPlayer(iClient))
	{
		Handle panel = CreatePanel();
		char s[512];
		Format(s, 512, "You have 'Mini-Super Jump' not as high as other bosses.\nYou have a 'Sprint-Jump' ability that has a cooldown of 30 seconds.\nYou can trigger your 'Sprint-Jump' ability by normal jumping.\nWhen you RAGE, you have no cooldown of your 'Sprint-Jump' ability!");
		SetPanelTitle(panel, s);
		DrawPanelItem(panel, "Exit");
		SendPanelToClient(panel, iClient, HintPanelH, 12);
		CloseHandle(panel);
	}
	return;
}

public int HintPanelH(Handle menu, MenuAction action, int param1, int param2)
{
	if (!ValidPlayer(param1)) return;
	//if (action == MenuAction_Select || (action == MenuAction_Cancel && param2 == MenuCancel_Exit)) VSHFlags[param1] |= VSHFLAG_CLASSHELPED;
	return;
}

