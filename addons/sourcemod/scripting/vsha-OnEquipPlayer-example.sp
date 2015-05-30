
#include <tf2attributes>
#include <vsha>
#include <vsha_stocks>

public Plugin myinfo = {
	name = "Versus Saxton Hale OnEquipPlayer Addon",
	author = "Diablo",
	description = "OnEquipPlayer External Example",
	version = "1.0",
	url = "https://github.com/War3Evo/VSH-Advanced"
};

Handle ThisPluginHandle;

ConVar EnableEurekaEffect;

public void OnAllPluginsLoaded()
{
	ThisPluginHandle = view_as<Handle>( VSHA_RegisterNonBossAddon() );

	EnableEurekaEffect = FindConVar("vsha_alloweureka");
}

public void OnPluginEnd()
{
	if(ThisPluginHandle != null)
	{
		VSHA_UnRegisterNonBossAddon();
	}
}

public Action VSHA_OnEquipPlayer_Pre()
{
	if(ThisPluginHandle == null) return Plugin_Continue;

	int iClient = VSHA_GetVar(EventClient);
	if(ValidPlayer(iClient))
	{
		int weapon = GetPlayerWeaponSlot(iClient, TFWeaponSlot_Primary);
		int index = -1;
		if (IsValidEdict(weapon) && IsValidEntity(weapon))
		{
			index = GetItemIndex(weapon);
			switch (index)
			{
				case 588:
				{
					TF2_RemoveWeaponSlot2(iClient, TFWeaponSlot_Primary);
					weapon = SpawnWeapon(iClient, "tf_weapon_shotgun_primary", 415, 10, 6, "265 ; 999.0 ; 179 ; 1.0 ; 178 ; 0.6 ; 2 ; 1.1 ; 3 ; 0.66");
				}
				case 237:
				{
					TF2_RemoveWeaponSlot2(iClient, TFWeaponSlot_Primary);
					weapon = SpawnWeapon(iClient, "tf_weapon_rocketlauncher", 18, 1, 0, "265 ; 999.0");
					SetWeaponAmmo(weapon, 20);
				}
				case 17, 204, 36, 412:
				{
					if (GetItemQuality(weapon) != 10)
					{
						TF2_RemoveWeaponSlot2(iClient, TFWeaponSlot_Primary);
						SpawnWeapon(iClient, "tf_weapon_syringegun_medic", 36, 1, 10, "17 ; 0.05 ; 144 ; 1");
					}
				}
			}
		}
		weapon = GetPlayerWeaponSlot(iClient, TFWeaponSlot_Secondary);
		if (IsValidEdict(weapon) && IsValidEntity(weapon))
		{
			index = GetItemIndex(weapon);
			switch (index)
			{
				case 57, 231:
				{
					TF2_RemoveWeaponSlot2(iClient, TFWeaponSlot_Secondary);
					weapon = SpawnWeapon(iClient, "tf_weapon_smg", 16, 1, 0, "");
				}
				case 265:
				{
					TF2_RemoveWeaponSlot2(iClient, TFWeaponSlot_Secondary);
					weapon = SpawnWeapon(iClient, "tf_weapon_pipebomblauncher", 20, 1, 0, "");
					SetWeaponAmmo(weapon, 24);
				}
				case 735, 736, 810, 831, 933, 1080, 1102: //NAILGUN FOR SAPPER, trust me it's more useful........
				{
					TF2_RemoveWeaponSlot2(iClient, TFWeaponSlot_Secondary);
					weapon = SpawnWeapon(iClient, "tf_weapon_handgun_scout_secondary", 23, 5, 10, "280 ; 5 ; 6 ; 0.7 ; 2 ; 0.66 ; 4 ; 4.167 ; 78 ; 8.333 ; 137 ; 6.0");
					SetWeaponAmmo(weapon, (GetMaxAmmo(iClient, 0)*200/GetMaxAmmo(iClient, 0))); // WTF up with this math?
				}
				case 39, 351, 1081:
				{
					TF2_RemoveWeaponSlot2(iClient, TFWeaponSlot_Secondary);
					weapon = SpawnWeapon(iClient, "tf_weapon_flaregun", index, 5, 10, "25 ; 0.5 ; 207 ; 1.33 ; 144 ; 1.0 ; 58 ; 3.2");
					SetWeaponAmmo(weapon, 16);
				}
			}
		}

		if (IsValidEntity(FindPlayerBack(iClient, { 57 , 231 }, 2)))
		{
			RemovePlayerBack(iClient, { 57 , 231 }, 2);
			weapon = SpawnWeapon(iClient, "tf_weapon_smg", 16, 1, 0, "");
		}

		weapon = GetPlayerWeaponSlot(iClient, TFWeaponSlot_Melee);
		if (IsValidEdict(weapon) && IsValidEntity(weapon))
		{
			index = GetItemIndex(weapon);
			switch (index)
			{
				case 331:
				{
					TF2_RemoveWeaponSlot2(iClient, TFWeaponSlot_Melee);
					weapon = SpawnWeapon(iClient, "tf_weapon_fists", 195, 1, 6, "");
				}
				// Requires Special Setup
				case 357: CreateTimer(1.0, Timer_RemoveHonorBound, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
				case 589:
				{
					if ( !EnableEurekaEffect.BoolValue ) //!GetConVarBool(EnableEurekaEffect))
					{
						TF2_RemoveWeaponSlot2(iClient, TFWeaponSlot_Melee);
						weapon = SpawnWeapon(iClient, "tf_weapon_wrench", 7, 1, 0, "");
					}
				}
			}
		}
		weapon = GetPlayerWeaponSlot(iClient, 4);
		if (IsValidEdict(weapon) && IsValidEntity(weapon) && GetItemIndex(weapon) == 60)
		{
			TF2_RemoveWeaponSlot2(iClient, 4);
			weapon = SpawnWeapon(iClient, "tf_weapon_invis", 30, 1, 0, "");
		}
		TFClassType equip = TF2_GetPlayerClass(iClient);
		switch (equip)
		{
			case TFClass_Medic:
			{
				weapon = GetPlayerWeaponSlot(iClient, TFWeaponSlot_Secondary);
				int mediquality = (IsValidEdict(weapon) && IsValidEntity(weapon) ? GetItemQuality(weapon) : -1);
				if (mediquality != 10)
				{
					TF2_RemoveWeaponSlot2(iClient, TFWeaponSlot_Secondary);
					weapon = SpawnWeapon(iClient, "tf_weapon_medigun", 998, 5, 10, "18 ; 0.0 ; 10 ; 1.25 ; 178 ; 0.75 ; 144 ; 2.0");
					//200 ; 1 for area of effect healing  ; 178 ; 0.75 Faster switch-to ; 14 ; 0.0 perm overheal
					SetMediCharge(weapon, 0.41);
				}
			}
			default: TF2Attrib_SetByDefIndex( iClient, 57, float(GetClientHealth(iClient)/50) ); //make by cvar
		}
	}
	return Plugin_Changed;
}


public Action Timer_RemoveHonorBound(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client) && IsPlayerAlive(client))
	{
		int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		int index = GetItemIndex(weapon);
		int active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		char classname[64]; GetEdictClassname(active, classname, sizeof(classname));
		if (index == 357 && active == weapon && strcmp(classname, "tf_weapon_katana", false) == 0)
		{
			SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
			if (GetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy") < 1) SetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
		}
	}
	return Plugin_Continue;
}
