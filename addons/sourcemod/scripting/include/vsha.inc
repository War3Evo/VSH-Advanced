#if defined _vsha_included
	#endinput
#endif
#define _vsha_included

// To enable printing debug messages via DP();
#define debugon 1

#include <tf2_stocks>
// not sure why we need this, compiles without it
//#include <sdktools_gamerules>
#include <tf2items>

#pragma newdecls			required

#pragma semicolon			1

#define MaxEntities			2048
#define PLYR				MAXPLAYERS+1
#define PATH				64
#define PATHX				PLATFORM_MAX_PATH
#define nullfunc			INVALID_FUNCTION
#define nullvec				NULL_VECTOR

//#define DEBUG				0

#if defined DEBUG
	#define DEBUGPRINT0(%1)			PrintToServer(%1)
	#define DEBUGPRINT1(%1)			LogMessage(%1)
	#define DEBUGPRINT2(%1)			CPrintToChatAll(%1)
	#define DEBUGPRINT3(%1)			LogToFile("addons/sourcemod/logs/vsha-debugoutput.txt", %1)
#endif

#define STRING(%1) %1, sizeof(%1)

#define LoopMaxClients(%1) for(int %1=1;%1<=MaxClients;++%1)

#define LoopConnectedClients(%1) for(int %1=1;%1<=MaxClients;++%1)\
								if(IsClientConnected(%1))

#define LoopIngameClients(%1) for(int %1=1;%1<=MaxClients;++%1)\
								if(IsClientInGame(%1))

#define LoopInGameBots(%1) for(int %1=1;%1<=MaxClients;++%1)\
								if(IsClientInGame(%1) && IsFakeClient(%1))

#define LoopIngamePlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
								if(IsClientInGame(%1) && !IsFakeClient(%1))

#define LoopAuthorizedPlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
								if(IsClientConnected(%1) && IsClientAuthorized(%1))

#define LoopAlivePlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
								if(IsClientInGame(%1) && IsPlayerAlive(%1))

#define LoopTeamPlayers(%1,%2) for(int %2=1;%2<=MaxClients;++%2)\
								if(IsClientInGame(%2) && IsPlayerAlive(%2) && (GetClientTeam(%1)==GetClientTeam(%2)))

#define LoopDeadPlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
								if(IsClientInGame(%1) && !IsPlayerAlive(%1))

#define LoopActiveBosses(%1) for(int %1=1;%1<=MaxClients;++%1)\
								if(IsClientInGame(%1) && bIsBoss[%1])

#define Toggle(%1) %1=%1?false:true

// may use in future.. removed for now
/*
enum VSHA_EVENT
{
	ModelTimer,
	OnLastSurvivorLoop,
	OnBossSetHP,
	OnPlayerKilled,
	OnKillingSpree,
	OnBossKilled,
	OnBossAirblasted,
	OnBossKillBuilding
}*/

// VSHA Events
enum VSHA_Var
{
	hString,
	EventTime,
	EventOnPrepBoss,
	EventSound,
	EventModelTimer,
	EventModel,
	EventClient,
	EventAttacker,
	EventVictim,
	EventArg1, //generic vsha event arguments
	EventArg2,
	EventArg3,
	EventArg4,
	SmEvent, ///usual game events from sm hooked events
}

/**
 * Prints Message to server and all chat
 * For debugging prints
 */
stock void DP(const char[] szMessage, ...)
{
#if defined debugon
	char szBuffer[1000];

	VFormat(szBuffer, sizeof(szBuffer), szMessage, 2);
	PrintToServer("[DebugP %d] %s",RoundFloat(GetGameTime())%100, szBuffer);
	PrintToChatAll("[DebugP %d] %s",RoundFloat(GetGameTime())%100, szBuffer);
#endif
}

#if !defined _diablostocks_included
#if !defined _vanilla_constants_included
stock bool ValidPlayer(int client, bool check_alive = false,bool alivecheckbyhealth = false) {
	if(client>0 && client<=MaxClients && IsClientConnected(client) && IsClientInGame(client))
	{
		if(check_alive && !IsPlayerAlive(client))
		{
			return false;
		}
		if(alivecheckbyhealth&&GetClientHealth(client)<1) {
			return false;
		}
		return true;
	}
	return false;
}
#endif
#endif

/*methodmap CTFBoss < CTFPlayer
{
	public CTFBoss(int playerindex)
	{
		return view_as<CTFBoss>( new CTFPlayer( clientIndex ) );
	}
}*/

stock bool SuperJump(int client, float &charge, float JumpAngle, float subtractCharge)
{
	float ang[3]; GetClientEyeAngles(client, ang);
        if ( ang[0] <= JumpAngle) // JumpAngle = -45.0
	{
		float vel[3]; GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
		vel[2] = 750 + charge * 13.0;
		SetEntProp(client, Prop_Send, "m_bJumping", 1);
		vel[0] *= (1+Sine(charge * FLOAT_PI / 50));
		vel[1] *= (1+Sine(charge * FLOAT_PI / 50));
		TeleportEntity(client, nullvec, nullvec, vel);
		charge = subtractCharge;
		return true;
	}
	return false;
}
stock bool Weighdown(int client, float &weighdowntime, float AngleForWayDown, float SetWeighdown)
{
	if ( weighdowntime >= 1.0 && /*(GetClientButtons(bossplayer) & IN_DUCK)*/ (GetEntityGravity(client) != 6.0) )
	{
		float ang[3];
		GetClientEyeAngles(client, ang);
		if ( ang[0] >= AngleForWayDown ) //AngleForWayDown = 60.0
		{
			float fVelocity[3];
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
			fVelocity[2] = -1000.0;
			TeleportEntity(client, nullvec, nullvec, fVelocity);
			SetEntityGravity(client, 6.0);
			PawnTimer( GravityCat, 2.0, GetClientUserId(client) );
			//CreateTimer(2.0, TimerGravityCat, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			weighdowntime = SetWeighdown;
			return true;
		}
	}
	return false;
}
public void GravityCat(int userid)
{
	int client = GetClientOfUserId(userid);
	if (IsValidClient(client)) SetEntityGravity(client, 1.0);
}
stock void StunSentry(int client, float dist, float duration = 6.0, int Removehealth)
{
	float playerPos[3], sentryPos[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", playerPos);
	int sentry = -1;
	while ( (sentry = FindEntityByClassname2(sentry, "obj_sentrygun")) != -1 )
	{
		GetEntPropVector(sentry, Prop_Send, "m_vecOrigin", sentryPos);
		if ( GetVectorDistance(playerPos, sentryPos) <= dist )
		{
			SetEntProp(sentry, Prop_Send, "m_bDisabled", 1);
			PawnTimer( RemoveEnt, duration, EntIndexToEntRef(AttachParticle(sentry, "yikes_fx", 75.0)) );
			PawnTimer( EnableSentry, duration, EntIndexToEntRef(sentry) );
			//CreateTimer( duration, RemoveEnt, EntIndexToEntRef(AttachParticle(sentry, "yikes_fx", 75.0)) );
			//CreateTimer( duration, TimerEnableSentry, EntIndexToEntRef(sentry) );
		}
		if (Removehealth > 0.0)
		{
			SetVariantInt( Removehealth );
			AcceptEntityInput(sentry, "RemoveHealth");
		}
	}
}
public void EnableSentry(int sentryid)
{
	int i = EntRefToEntIndex(sentryid);
	if (CheckRoundState() == 1 && IsValidEdict(i) && i > MaxClients)
	{
		char s[64]; GetEdictClassname(i, s, sizeof(s));
		if (StrEqual(s, "obj_sentrygun")) GetEntProp(i, Prop_Send, "m_bDisabled", 0);
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Wrapper function for easily setting up timers; USE ONLY FOR FIRE-ONCE TIMERS
 *
 * @param func			Function pointer to callback desired function when time elapses
 * @param thinktime		time in seconds when timer function will be called
 * @param param1		1st param for the call back function
 * @param param2		2nd param for the call back function
 *
 * @noreturn
 */
stock void PawnTimer(Function func, float thinktime = 0.1, any param1 = -999, any param2 = -999)
{
	DataPack thinkpack = new DataPack();
	thinkpack.WriteFunction(func);
	thinkpack.WriteCell(param1);
	thinkpack.WriteCell(param2);

	CreateTimer(thinktime, DoTimer, thinkpack, TIMER_DATA_HNDL_CLOSE);
}

public Action DoTimer(Handle hTimer, DataPack hndl)
{
	hndl.Reset();
	Function pFunc = hndl.ReadFunction();
	Call_StartFunction( null, pFunc );

	any param1 = hndl.ReadCell();
	if ( param1 != -999 ) Call_PushCell(param1);

	any param2 = hndl.ReadCell();
	if ( param2 != -999 ) Call_PushCell(param2);

	Call_Finish();
	return Plugin_Continue;
}
stock bool IsVSHMap() //just use arena maps as vsh/ff2 maps
{
	char config[PATHX], currentmap[99];
	GetCurrentMap(currentmap, sizeof(currentmap));
	if ( FileExists("bNextMapToFF2") ) return true;
	else if ( FileExists("bNextMapToHale") ) return true;

	BuildPath(Path_SM, config, PATHX, "configs/freak_fortress_2/maps.cfg"); //Compatibility
	if (!FileExists(config))
	{
		BuildPath(Path_SM, config, PATHX, "configs/saxton_hale/saxton_hale_maps.cfg");
		if (!FileExists(config))
		{
			LogError("[VSH Engine] **** Unable to find VSH/FF2 Compatibility Map Configs, Disabling VSH Engine ****");
			return false;
		}
	}

	File file = OpenFile(config, "r");
	if (file == null)
	{
		LogError("[VSH Engine] **** Error Reading Maps from %s Config, Disabling VSH Engine ****", config);
		return false;
	}

	int tries;
	while ( file.ReadLine(config, sizeof(config)) && tries < 100 )
	{
		tries++;
		if (tries == 100)
		{
			LogError("[VSH Engine] **** Breaking Infinite Loop Looking For a Map ****");
			return false;
		}

		Format(config, strlen(config)-1, config);
		if ( !strncmp(config, "//", 2, false) ) continue;

		if ( StrContains(currentmap, config, false) != -1 || StrContains(config, "all", false) != -1 )
		{
			file.Close();
			return true;
		}
	}
	file.Close();
	return false;
	//if (FindEntityByClassname(-1, "tf_logic_arena") != -1) return true;
	//return false;
}
public void RemoveEnt(int entid)
{
	int ent = EntRefToEntIndex(entid);
	if (ent > 0 && IsValidEntity(ent)) AcceptEntityInput(ent, "Kill");
}
stock int AttachParticle(int ent, char[] particleType, float offset = 0.0, bool battach = true)
{
	int particle = CreateEntityByName("info_particle_system");
	char tName[128];
	float pos[3];
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	pos[2] += offset;
	TeleportEntity(particle, pos, nullvec, nullvec);
	Format(tName, sizeof(tName), "target%i", ent);
	DispatchKeyValue(ent, "targetname", tName);
	DispatchKeyValue(particle, "targetname", "tf2particle");
	DispatchKeyValue(particle, "parentname", tName);
	DispatchKeyValue(particle, "effect_name", particleType);
	DispatchSpawn(particle);
	SetVariantString(tName);
	if (battach)
	{
		AcceptEntityInput(particle, "SetParent", particle, particle, 0);
		SetEntPropEnt(particle, Prop_Send, "m_hOwnerEntity", ent);
	}
	ActivateEntity(particle);
	AcceptEntityInput(particle, "start");
	return particle;
}
stock void SetControlPoint(bool enable)
{
	int controlPoint = MaxClients+1;
	while ( (controlPoint = FindEntityByClassname2(controlPoint, "team_control_point")) != -1 )
	{
		if ( IsValidEdict(controlPoint) && IsValidEntity(controlPoint) )
		{
			AcceptEntityInput(controlPoint, (enable ? "ShowModel" : "HideModel"));
			SetVariantInt(enable ? 0 : 1);
			AcceptEntityInput(controlPoint, "SetLocked");
		}
	}
}
stock int CheckRoundState()
{
	switch ( GameRules_GetRoundState() )
	{
		case RoundState_Init, RoundState_Pregame: return -1;
		case RoundState_StartGame, RoundState_Preround: return 0;
		case RoundState_RoundRunning, RoundState_Stalemate: return 1;
		default: return 2;
	}
	return -1;
}
stock void ForceTeamWin(int team)
{
	int entity = FindEntityByClassname2(-1, "team_control_point_master");
	if (entity == -1)
	{
		entity = CreateEntityByName("team_control_point_master");
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "Enable");
	}
	SetVariantInt(team);
	AcceptEntityInput(entity, "SetWinner");
}
stock int FindEntityByClassname2(int startEnt, const char[] classname)
{
	/* If startEnt isn't valid shifting it back to the nearest valid one */
	while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
}
stock int GetItemIndex(int item)
{
	if (IsValidEdict(item) && IsValidEntity(item)) return GetEntProp(item, Prop_Send, "m_iItemDefinitionIndex");
	return -1;
}
stock int GetItemQuality(int item)
{
	if (IsValidEdict(item) && IsValidEntity(item)) return GetEntProp(item, Prop_Send, "m_iEntityQuality");
	return -1;
}
stock int GetIndexOfWeaponSlot(int client, int slot)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	return (IsValidEdict(weapon) && IsValidEntity(weapon)) ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : -1;
}
stock void TF2_RemoveWeaponSlot2(int client, int slot)
{
	int ew, weaponIndex;
	while ((weaponIndex = GetPlayerWeaponSlot(client, slot)) != -1)
	{
		ew = GetEntPropEnt(weaponIndex, Prop_Send, "m_hExtraWearable");
		if (IsValidEntity(ew)) TF2_RemoveWearable(client, ew);
		ew = GetEntPropEnt(weaponIndex, Prop_Send, "m_hExtraWearableViewModel");
		if (IsValidEntity(ew)) TF2_RemoveWearable(client, ew);
		RemovePlayerItem(client, weaponIndex);
		AcceptEntityInput(weaponIndex, "Kill");
	}
}
stock void TF2_RemoveAllWeapons2(int client)
{
	for (int i = 0; i <= 5; i++) { TF2_RemoveWeaponSlot2(client, i); }
}
stock void RemovePlayerBack(int client, int[] indices, int len)
{
	if (len <= 0) return;
	int edict = MaxClients+1;
	while ((edict = FindEntityByClassname2(edict, "tf_wearable")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearable"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i = 0; i < len; i++)
				{
					if (idx == indices[i]) TF2_RemoveWearable(client, edict);
				}
			}
		}
	}
	edict = MaxClients+1;
	while ((edict = FindEntityByClassname2(edict, "tf_powerup_bottle")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFPowerupBottle"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i = 0; i < len; i++)
				{
					if (idx == indices[i]) TF2_RemoveWearable(client, edict);
				}
			}
		}
	}
}
stock int FindPlayerBack(int client, int[] indices, int len)
{
	if (len <= 0) return -1;
	int edict = MaxClients+1;
	while ((edict = FindEntityByClassname2(edict, "tf_wearable")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearable"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i = 0; i < len; i++)
				{
					if (idx == indices[i]) return edict;
				}
			}
		}
	}
	edict = MaxClients+1;
	while ((edict = FindEntityByClassname2(edict, "tf_powerup_bottle")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFPowerupBottle"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i = 0; i < len; i++)
				{
					if (idx == indices[i]) return edict;
				}
			}
		}
	}
	return -1;
}
stock float GetMediCharge(int medigun)
{
	if (IsValidEdict(medigun) && IsValidEntity(medigun)) return GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
	return -1.0;
}
stock void SetMediCharge(int medigun, float val)
{
	if (IsValidEdict(medigun) && IsValidEntity(medigun)) SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", val);
}
stock Handle PrepareItemHandle(Handle hdlItem, char[] name = "", int index = -1, const char[] att = "", bool dontpreserve = false)
{
	Handle hWeapon = null;
	int addattribs = 0;

	char weaponAttribsArray[32][32];
	int attribCount = ExplodeString(att, " ; ", weaponAttribsArray, 32, 32);

	int flags = OVERRIDE_ATTRIBUTES;
	if (!dontpreserve) flags |= PRESERVE_ATTRIBUTES;
	if (hWeapon == null) hWeapon = TF2Items_CreateItem(flags);
	else TF2Items_SetFlags(hWeapon, flags);
	//  new Handle:hWeapon = TF2Items_CreateItem(flags);    //null;
	if (hdlItem != null)
	{
		addattribs = TF2Items_GetNumAttributes(hdlItem);
		if (addattribs > 0)
		{
			for (int i = 0; i < 2 * addattribs; i += 2)
			{
				bool dontAdd = false;
				int attribIndex = TF2Items_GetAttributeId(hdlItem, i);
				for (int z = 0; z < attribCount+i; z += 2)
				{
					if (StringToInt(weaponAttribsArray[z]) == attribIndex)
					{
						dontAdd = true;
						break;
					}
				}
				if (!dontAdd)
				{
					IntToString(attribIndex, weaponAttribsArray[i+attribCount], 32);
					FloatToString(TF2Items_GetAttributeValue(hdlItem, i), weaponAttribsArray[i+1+attribCount], 32);
				}
			}
			attribCount += 2 * addattribs;
		}
		delete hdlItem; //probably returns false but whatever
	}

	if (name[0] != '\0')
	{
		flags |= OVERRIDE_CLASSNAME;
		TF2Items_SetClassname(hWeapon, name);
	}
	if (index != -1)
	{
		flags |= OVERRIDE_ITEM_DEF;
		TF2Items_SetItemIndex(hWeapon, index);
	}
	if (attribCount > 1)
	{
		TF2Items_SetNumAttributes(hWeapon, (attribCount/2));
		int i2 = 0;
		for (int i = 0; i < attribCount && i < 32; i += 2)
		{
			TF2Items_SetAttribute(hWeapon, i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
			i2++;
		}
	}
	else TF2Items_SetNumAttributes(hWeapon, 0);
	TF2Items_SetFlags(hWeapon, flags);
	return hWeapon;
}
stock int SpawnWeapon(int client, char[] name, int index, int level, int qual, char[] att)
{
	Handle hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	TF2Items_SetClassname(hWeapon, name);
	TF2Items_SetItemIndex(hWeapon, index);
	TF2Items_SetLevel(hWeapon, level);
	TF2Items_SetQuality(hWeapon, qual);
	char atts[32][32];
	int count = ExplodeString(att, " ; ", atts, 32, 32);
	if (count > 0)
	{
		TF2Items_SetNumAttributes(hWeapon, count/2);
		int i2 = 0;
		for (int i = 0; i < count; i+= 2)
		{
			TF2Items_SetAttribute(hWeapon, i2, StringToInt(atts[i]), StringToFloat(atts[i+1]));
			i2++;
		}
	}
	else TF2Items_SetNumAttributes(hWeapon, 0);
	if (hWeapon == null) return -1;
	int entity = TF2Items_GiveNamedItem(client, hWeapon);
	hWeapon.Close();
	EquipPlayerWeapon(client, entity);
	return entity;
}
stock int GetClientCloakIndex(int client)
{
	if (!IsValidClient(client)) return -1;
	int wep = GetPlayerWeaponSlot(client, 4);
	if (!IsValidEntity(wep)) return -1;
	char classname[32];
	GetEntityClassname(wep, classname, sizeof(classname));
	if ( strncmp(classname, "tf_wea", 6, false) != 0 ) return -1;
	return GetEntProp(wep, Prop_Send, "m_iItemDefinitionIndex");
}
stock int GetHealingTarget(int client)
{
	int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if ( !IsValidEdict(medigun) || !IsValidEntity(medigun) ) return -1;
	char s[32]; GetEdictClassname(medigun, s, sizeof(s));
	if (!strcmp(s, "tf_weapon_medigun", false))
	{
		if (GetEntProp(medigun, Prop_Send, "m_bHealing")) return GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
	}
	return -1;
}
stock bool IsNearSpencer(int client)
{
	int medics = 0, healers = GetEntProp(client, Prop_Send, "m_nNumHealers");
	if (healers > 0)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && IsPlayerAlive(i) && GetHealingTarget(i) == client) medics++;
		}
	}
	return (healers > medics);
}

stock int FindSentry(int client)
{
	int i = -1;
	while ((i = FindEntityByClassname2(i, "obj_sentrygun")) != -1)
	{
		if (GetEntPropEnt(i, Prop_Send, "m_hBuilder") == client) return i;
	}
	return -1;
}
stock void IncrementHeadCount(int client)
{
	if (!TF2_IsPlayerInCondition(client, TFCond_DemoBuff)) TF2_AddCondition(client, TFCond_DemoBuff, -1.0);
	int decapitations = GetEntProp(client, Prop_Send, "m_iDecapitations");
	SetEntProp(client, Prop_Send, "m_iDecapitations", decapitations+1);
	int boosthealth = GetClientHealth(client);
	if (boosthealth < 300) boosthealth += 15;
	SetEntProp(client, Prop_Data, "m_iHealth", boosthealth);
	SetEntProp(client, Prop_Send, "m_iHealth", boosthealth);
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);   //recalc their speed
}
stock void SpawnSmallHealthPackAt(int client, int ownerteam = 0)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client)) return;
	int healthpack = CreateEntityByName("item_healthkit_small");
	float pos[3]; GetClientAbsOrigin(client, pos);
	pos[2] += 20.0;
	if (IsValidEntity(healthpack))
	{
		DispatchKeyValue(healthpack, "OnPlayerTouch", "!self,Kill,,0,-1");  //for safety, though it normally doesn't respawn
		DispatchSpawn(healthpack);
		SetEntProp(healthpack, Prop_Send, "m_iTeamNum", ownerteam, 4);
		SetEntityMoveType(healthpack, MOVETYPE_VPHYSICS);
		float vel[3];
		vel[0] = float(GetRandomInt(-10, 10)), vel[1] = float(GetRandomInt(-10, 10)), vel[2] = 50.0;
		TeleportEntity(healthpack, pos, nullvec, vel);
	}
}
stock void StopMusic(int client, char[] music)
{
	if ( IsValidClient(client) ) StopSound(client, SNDCHAN_AUTO, music);
}
stock bool IsValidClient(int client, bool replaycheck = true)
{
	if ( client <= 0 || client > MaxClients ) return false;
	if ( !IsClientInGame(client) ) return false;
	if ( GetEntProp(client, Prop_Send, "m_bIsCoaching") ) return false;
	if ( replaycheck ) if ( IsClientSourceTV(client) || IsClientReplay(client) ) return false;
	return true;
}
stock bool IsClientValid(int client)
{
	return ( client > 0 && client <= MaxClients && IsClientInGame(client) );
}
stock int FindTeleOwner(int client)
{
	int teleporter = GetEntPropEnt(client, Prop_Send, "m_hGroundEntity");
	char classname[32];
	if (IsValidEntity(teleporter) && GetEdictClassname(teleporter, classname, sizeof(classname)) && !strcmp(classname, "obj_teleporter", false))
	{
		int owner = GetEntPropEnt(teleporter, Prop_Send, "m_hBuilder");
		if (IsValidClient(owner, false)) return owner;
	}
	return -1;
}
stock int GetOwner(int ent)
{
	if ( IsValidEdict(ent) && IsValidEntity(ent) ) return GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	return -1;
}
stock void ClearTimer(Handle &Timer)
{
	if (Timer != null)
	{
		Timer.Close();
		Timer = null;
	}
}
stock void ForceTeamChange(int client, int iTeam)
{
	SetEntProp(client, Prop_Send, "m_lifeState", 2);
	ChangeClientTeam(client, iTeam);
	SetEntProp(client, Prop_Send, "m_lifeState", 0);
	TF2_RespawnPlayer(client);
}
stock int GetTeamPlayerCount(int team)
{
	int count = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && GetClientTeam(i) == team) count++;
	}
	return count;
}
stock int GetWeaponAmmo(int armament)
{
	int owner = GetEntPropEnt(armament, Prop_Send, "m_hOwnerEntity");
	if (owner <= 0) return 0;
	if (IsValidEntity(armament))
	{
		int iOffset = GetEntProp(armament, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		return GetEntData(owner, iAmmoTable+iOffset, 4);
	}
	return 0;
}
stock int GetWeaponClip(int armament)
{
	if (IsValidEntity(armament))
	{
		int AmmoClipTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		return GetEntData(armament, AmmoClipTable);
	}
	return 0;
}
stock void SetWeaponAmmo(int armament, int ammo)
{
	int owner = GetEntPropEnt(armament, Prop_Send, "m_hOwnerEntity");
	if (owner == -1) return;
	if (IsValidEntity(armament))
	{
		int iOffset = GetEntProp(armament, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(owner, iAmmoTable+iOffset, ammo, 4, true);
	}
	return;
}
stock void SetWeaponClip(int armament, int ammo)
{
	if (IsValidEntity(armament))
	{
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		SetEntData(armament, iAmmoTable, ammo, 4, true);
	}
	return;
}
stock int GetMaxAmmo(int client, int slot)
{
	if (!IsValidClient(client)) return 0;
	int armament = GetPlayerWeaponSlot(client, slot);
	if (IsValidEntity(armament))
	{
		switch (slot)
		{
			case TFWeaponSlot_Primary: return GetEntData(client, FindDataMapOffs(client, "m_iAmmo")+4);
			case TFWeaponSlot_Secondary: return GetEntData(client, FindDataMapOffs(client, "m_iAmmo")+8);
			case TFWeaponSlot_Melee: return GetEntData(client, FindDataMapOffs(client, "m_iAmmo")+12);
		}
	}
	return 0;
}
stock bool TF2_IsPlayerCritBuffed(int client)
{
    return (TF2_IsPlayerInCondition(client, TFCond_Kritzkrieged)
            || TF2_IsPlayerInCondition(client, TFCond_HalloweenCritCandy)
            || TF2_IsPlayerInCondition(client, view_as<TFCond>(34))
            || TF2_IsPlayerInCondition(client, view_as<TFCond>(35))
            || TF2_IsPlayerInCondition(client, TFCond_CritOnFirstBlood)
            || TF2_IsPlayerInCondition(client, TFCond_CritOnWin)
            || TF2_IsPlayerInCondition(client, TFCond_CritOnFlagCapture)
            || TF2_IsPlayerInCondition(client, TFCond_CritOnKill)
            || TF2_IsPlayerInCondition(client, TFCond_CritMmmph)
            );
}
stock void TeleportToSpawn(int iClient, int iTeam = 0)
{
	int iEnt = -1;
	float vPos[3], vAng[3];
	ArrayList hArray = new ArrayList(); //Handle hArray = CreateArray();
	while ((iEnt = FindEntityByClassname2(iEnt, "info_player_teamspawn")) != -1)
	{
		if (iTeam <= 1) hArray.Push(iEnt); //PushArrayCell(hArray, iEnt); // Not RED (2) nor BLu (3)
		else
		{
			int iSpawnTeam = GetEntProp(iEnt, Prop_Send, "m_iTeamNum");
			if (iSpawnTeam == iTeam) hArray.Push(iEnt);
		}
	}
	iEnt = hArray.Get(GetRandomInt(0, hArray.Length - 1)); //GetArrayCell(hArray, GetRandomInt(0, GetArraySize(hArray) - 1));
	hArray.Close();

	//Technically you'll never find a map without a spawn point. Not a good map at least.
	GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
	GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);
	TeleportEntity(iClient, vPos, vAng, nullvec);

	/*if (Special == VSHSpecial_HHH) //reserved for HHH subplugin boss
	{
		CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(AttachParticle(iEnt, "ghost_appearation", _, false)));
		EmitSoundToAll("misc/halloween/spell_teleport.wav", _, _, SNDLEVEL_GUNFIRE, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, vPos, nullvec, false, 0.0);
	}*/
}
stock int HealthCalc(float initial, float playing, float subtract, float exponent, float additional)
{
	return RoundFloat( Pow((((initial)+playing)*(playing-subtract)), exponent)+additional );
}
stock void SetClientGlow(int client, float time1, float clampfl = 0.0, float &glowtimer)
{
	if (IsValidClient(client))
	{
		glowtimer += time1;
		if (clampfl > 0.0) glowtimer = clampfl;
		if (glowtimer <= 0.0)
		{
			glowtimer = 0.0;
			SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0);
		}
		else SetEntProp(client, Prop_Send, "m_bGlowEnabled", 1);
	}
}
stock void SetClientOverlay(int client, char[] strOverlay)
{
	int iFlags = GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT);
	SetCommandFlags("r_screenoverlay", iFlags);
	ClientCommand(client, "r_screenoverlay \"%s\"", strOverlay);
}
stock void SetArenaCapEnableTime(float time)
{
	int ent = -1;
	char strTime[32];
	FloatToString(time, strTime, sizeof(strTime));
	if ((ent = FindEntityByClassname2(-1, "tf_logic_arena")) != -1) DispatchKeyValue(ent, "CapEnableDelay", strTime);
}
stock void ClampCharge(float &charge)
{
	if (charge > 100.0) charge = 100.0;
	else if (charge < 0.0) charge = 0.0;
}
stock void StringToLower(const char[] input, char[] output, int size)
{
	for (int i = 0; i < size; i++)
	{
		if (IsCharUpper(input[i])) output[i] = CharToLower(input[i]);
		else output[i] = input[i];
	}
}
stock bool GetTrieValueCaseInsensitive(StringMap trie, const char[] key, any &value)
{
	if (trie == null) return false;
	int length = strlen(key)+1;
	char[] trieKey = new char[length];
	StringToLower(key, trieKey, length);
	return trie.GetValue(trieKey, value); //GetTrieValue(trie, trieKey, value);
}
stock bool SetTrieValueCaseInsensitive(StringMap trie, const char[] key, any value)
{
	int length = strlen(key)+1;
	char[] trieKey = new char[length];
	StringToLower(key, trieKey, length);
	return trie.SetValue(trieKey, value); //SetTrieValue(trie, trieKey, value);
}
stock bool ValidateName(const char[] name)
{
	int length = strlen(name);
	for (int i = 0; i < length; i++)
	{
		int holder = name[i];
		// Invalid name, names may only contains numbers, underscores and normal letters
		if (!(IsCharAlpha(holder) || IsCharNumeric(holder) || holder == '_')) return false;
	} // A name is, of course, only valid if it's 1 or more chars long, though longer is recommended
	return (length > 0);
}
stock Handle GetBossSubPlugin(StringMap StrMapHndl)
{
	Handle plugin;
	//if (GetTrieValue(StrMapHndl, "Subplugin", plugin)) return plugin;
	if ( StrMapHndl.GetValue("Subplugin", plugin) ) return plugin;
	// Shouldn't actually get here, but we keep it just incase
	return null;
}
//=================================================================================================================================
//=================================================== [ N A T I V E ] =============================================================

native Handle VSHA_RegisterBoss(char[] BossName); //EVERY DAMN BOSS SUBPLUGIN REQUIRES THIS TO WORK; PREFERABLY USE IN ONPLUGINSTART OK?
native void VSHA_UnRegisterBoss(char[] BossName); //YOU SHOULD PUT THIS OnPluginEnd() !! So you can reload your boss plugin for development

native int VSHA_GetBossUserID(int client); //gets boss' userid
native void VSHA_SetBossUserID(int client, int userid);

native int VSHA_GetDifficulty(int client); /* this is to modify bosses based on what difficulty level the player wants his boss to be, doesn't do anything by itself but this API should help with it. */
native void VSHA_SetDifficulty(int client, int difficultylevel);

native int VSHA_GetLives(int client); /* gets the player's lives, you can get/set lives for both players and bosses */
native void VSHA_SetLives(int client, int lives);

native int VSHA_GetPresetBoss(int client); //this gets the preset boss special ID, similar to VSH Special or FF2 Get special
native void VSHA_SetPresetBoss(int client, int presetboss);

native int VSHA_GetBossHealth(int client);
native void VSHA_SetBossHealth(int client, int health);

native int VSHA_GetBossMaxHealth(int client);
native void VSHA_SetBossMaxHealth(int client, int maxhealth);

native int VSHA_GetBossPlayerKills(int client); //how many players a boss killed in the entire round
native void VSHA_SetBossPlayerKills(int client, int kills);

native int VSHA_GetBossKillstreak(int client); //how many people boss killed in a certain amount of time
native void VSHA_SetBossKillstreak(int client, int killspree);

native int VSHA_GetPlayerBossKills(int client); //how many times a player has killed a boss in entire map time
native void VSHA_SetPlayerBossKills(int client, int bosseskilled);

native int VSHA_GetDamage(int client); //this can also get the boss' damage.
native void VSHA_SetDamage(int client, int dmg);

native int VSHA_GetBossMarkets(int client); /* how many times a boss was market-gardened. THIS DOES NOT AUTO INCREMENT IN CORE PLUGIN. If you want your boss to take Market-Garden Backstab-like damage, you should use this. */
native void VSHA_SetBossMarkets(int client, int markets);

native int VSHA_GetBossStabs(int client); //how many times a boss was backstabbed
native void VSHA_SetBossStabs(int client, int stabs);

native int VSHA_GetHits(int client); //how many times a client was hit aka took dmg.
native void VSHA_SetHits(int client, int hits);

native int VSHA_GetMaxWepAmmo(int wepentity);
native void VSHA_SetMaxWepAmmo(int wepentity, int maxammo);

native int VSHA_GetMaxWepClip(int wepentity);
native void VSHA_SetMaxWepClip(int wepentity, int maxclip);

native int VSHA_GetPresetBossPlayer(); //Get when or which player will be forced as the next boss
native void VSHA_SetPresetBossPlayer(int client);

native int VSHA_GetAliveRedPlayers();
native int VSHA_GetAliveBluPlayers();

native float VSHA_GetBossRage(int client); /* gets the charge of the hardcoded, built-in rage charge. You can create multiple rage charges or make the default one charge up from different things than just taking damage. */
native void VSHA_SetBossRage(int client, float rage);

native float VSHA_GetGlowTimer(int client); //used to set glow timers on players, use in boss subplugins plz
native void VSHA_SetGlowTimer(int client, float glowtime);

native bool VSHA_IsBossPlayer(int client); //is client a boss?
native void VSHA_SetIsBossPlayer(int client, bool state);

native bool VSHA_IsPlayerInJump(int client); //did player rocket/sticky jump?

native bool VSHA_CanBossTaunt(int client); //is boss taunt cooldown over?

native int VSHA_FindNextBoss(bool[] clientarray, int arraysize); /* gets the next player in queue list */

native int VSHA_CountScoutsLeft(); /* counts how many scouts are left */

native int VSHA_GetPlayerCount();

// may use in future, removed for now
//native int VSHA_CreateEvent(VSHA_EVENT event, int client);

/* BEGIN GLOBAL VARS */
//retrieves specified values from the main VSHA plugin, see VSHA_Var enum in constants.inc, only those values are allowed
//this mostly used for accessing a variable without creating a special native just for it
//this returns any:, you should tag it if return value is not suppose to be normal integer.
// to get integer.. do this: view_as<int>(VSHA_GetVar(EventArg1)); or view_as<Handle>(VSHA_GetVar(EventArg1));
//most are temporary variables and this function should be called immidiately in the right functions
//examples VSHA_GetVar(EventArg1)   VSHA_GetVar(EventArg2)
//See VSHA_Var enum in constants to get a list
//Do not get/set vars arbitrarily unless you know what you are doing
native any VSHA_GetVar(VSHA_Var variabletoretrieve);
native void VSHA_SetVar(VSHA_Var variabletoretrieve, any value);
/* END GLOBAL VARS */

//=================================================================================================================================

//=================================================== [ F O R W A R D S ] =========================================================

// may add in the future?
//forward Action OnVSHAEvent(VSHA_EVENT event, int client);

forward void VSHA_AddToDownloads(); /* called during OnMapStart(); NOTICE: THIS IS A GLOBAL FORWARD */
/*
forward void VSHA_OnPlayerKilled(int attacker, int client); //when a boss kills a player

forward void VSHA_OnKillingSpree(int attacker, int client); //when boss has killed certain amount of players in a certain amount of time, conveniently gets the killed player who triggered this forward

forward void VSHA_OnBossKilled(int client, int attacker); //when a boss is killed, conveniently gets the player who killed the boss too, give the lucky sob a medal :3

forward void VSHA_OnBossWin(); // self explanatory lol

forward void VSHA_OnBossKillBuilding(int attacker, int building); // also self explanatory

forward void VSHA_OnBossAirblasted(int client, int airblaster); //when boss is airblasted, client is the airblasted boss

forward void VSHA_OnBossSelected(int client); //when a boss is selected, the client is the player that is assigned to be the boss

forward void VSHA_OnBossIntroTalk(); //play boss intro response sound clip in this forward

forward void VSHA_OnBossSetHP(int client); //self explanatory, when boss has their hp set and client is the individual boss

forward void VSHA_OnLastSurvivorLoop(int target); //target = lucky survivor

forward void VSHA_OnLastSurvivor(); //when CheckAlivePlayers counts only 1 player left, called once.

forward void VSHA_OnBossTimer(int client); //called every 0.2 seconds on each boss, health is set automatically though

forward void VSHA_OnPrepBoss(int client); //called during MakeBoss timer; in this forward, the boss is disarmed and stripped of all equipment. Equip them or whatever in this forward ok?

forward void VSHA_OnMusic(char BossTheme[256], float &time); //sets the boss theme music, no shitty earrape music ok?

forward Action VSHA_OnModelTimer(int client, char modelpath[64]); //YOU NEED THIS TIMER FOR EVERY BOSS + MINION OR ELSE PLUGIN WILL BITCH @ U

forward void VSHA_OnBossRage(int client); //when boss does taunt or medic call rage

//public void VSHA_OnBossConditionAdded(int client, TFCond condition); //when condition like jarate is added

forward void VSHA_OnUberTimer(int medic, int target); //called every 0.4 seconds

forward void VSHA_MessageTimer(); //called when a round begins.
*/
//=================================================================================================================================

public SharedPlugin __pl_vsha =
{
	name = "vsha",
	file = "vsha.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_vsha_SetNTVOptional()
{
	MarkNativeAsOptional("VSHA_RegisterBoss");
	MarkNativeAsOptional("VSHA_UnRegisterBoss");

	MarkNativeAsOptional("VSHA_GetBossUserID");
	MarkNativeAsOptional("VSHA_SetBossUserID");

	MarkNativeAsOptional("VSHA_GetDifficulty");
	MarkNativeAsOptional("VSHA_SetDifficulty");

	MarkNativeAsOptional("VSHA_GetLives");
	MarkNativeAsOptional("VSHA_SetLives");

	MarkNativeAsOptional("VSHA_GetPresetBoss");
	MarkNativeAsOptional("VSHA_SetPresetBoss");

	MarkNativeAsOptional("VSHA_GetBossHealth");
	MarkNativeAsOptional("VSHA_SetBossHealth");

	MarkNativeAsOptional("VSHA_GetBossMaxHealth");
	MarkNativeAsOptional("VSHA_SetBossMaxHealth");

	MarkNativeAsOptional("VSHA_GetBossPlayerKills");
	MarkNativeAsOptional("VSHA_SetBossPlayerKills");

	MarkNativeAsOptional("VSHA_GetBossKillstreak");
	MarkNativeAsOptional("VSHA_SetBossKillstreak");

	MarkNativeAsOptional("VSHA_GetPlayerBossKills");
	MarkNativeAsOptional("VSHA_SetPlayerBossKills");

	MarkNativeAsOptional("VSHA_GetDamage");
	MarkNativeAsOptional("VSHA_SetDamage");

	MarkNativeAsOptional("VSHA_GetBossMarkets");
	MarkNativeAsOptional("VSHA_SetBossMarkets");

	MarkNativeAsOptional("VSHA_GetBossStabs");
	MarkNativeAsOptional("VSHA_SetBossStabs");

	MarkNativeAsOptional("VSHA_GetHits");
	MarkNativeAsOptional("VSHA_SetHits");

	MarkNativeAsOptional("VSHA_GetMaxWepAmmo");
	MarkNativeAsOptional("VSHA_SetMaxWepAmmo");

	MarkNativeAsOptional("VSHA_GetMaxWepClip");
	MarkNativeAsOptional("VSHA_SetMaxWepClip");

	MarkNativeAsOptional("VSHA_GetPresetBossPlayer");
	MarkNativeAsOptional("VSHA_SetPresetBossPlayer");

	MarkNativeAsOptional("VSHA_GetAliveRedPlayers");
	MarkNativeAsOptional("VSHA_GetAliveBluPlayers");

	MarkNativeAsOptional("VSHA_GetBossRage");
	MarkNativeAsOptional("VSHA_SetBossRage");

	MarkNativeAsOptional("VSHA_GetGlowTimer");
	MarkNativeAsOptional("VSHA_SetGlowTimer");

	MarkNativeAsOptional("VSHA_IsBossPlayer");
	MarkNativeAsOptional("VSHA_SetIsBossPlayer");

	MarkNativeAsOptional("VSHA_IsPlayerInJump");
	MarkNativeAsOptional("VSHA_CanBossTaunt");

	MarkNativeAsOptional("VSHA_FindNextBoss");

	MarkNativeAsOptional("VSHA_CountScoutsLeft");
	MarkNativeAsOptional("VSHA_GetPlayerCount");
}
#endif
