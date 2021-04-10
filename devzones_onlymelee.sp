#pragma semicolon 1
#include <sourcemod>
#include <devzones>
#include <tf2>
#include <tf2_stocks>
#include <tf2attributes>
#include <morecolors>

new bool:onlymelee[MAXPLAYERS+1];

public Plugin myinfo =
{
	name = "Addons for DevZones",
	author = "Rolowy",
	description = "Zone for only melee",
	version = "1.1",
	url = "https://github.com/Rolowy"
};


public OnPluginStart()
{
	HookEvent("player_spawn", PlayerSpawn);
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));	
	onlymelee[client] = false;
	TF2_RemoveCondition(client, TFCond_MeleeOnly);
}

public Action:SpawnTimer(Handle:timer, any:client)
{
	if (!IsClientInGame(client))
		return;
	onlymelee[client] = false;
}

public Zone_OnClientEntry(client, String:zone[])
{
	if(!ValidPlayer(client))
		return;

	if(StrContains(zone, "onlymelee", false) != 0) return;
	{
		TF2_SwitchtoSlot(client, TFWeaponSlot_Melee);
		TF2_AddCondition(client, TFCond_RestrictToMelee);
		onlymelee[client] = true;
	}
	
	
}

public Zone_OnClientLeave(client, String:zone[])
{
	if(!ValidPlayer(client))
		return;
	if(StrContains(zone, "onlymelee", false) != 0) return;
	{
		TF2_RemoveCondition(client, TFCond_RestrictToMelee);
		onlymelee[client] = false;
		TF2_SwitchtoSlot(client, TFWeaponSlot_Primary);
	}
}

stock bool:ValidPlayer(client)
{
	if(client > 0 && client<=MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client))
	{
		return true;
	}
	return false;
}



stock TF2_SwitchtoSlot(client, slot)
{
	if (slot >= 0 && slot <= 5 && IsClientInGame(client) && IsPlayerAlive(client))
	{
		decl String:classname[64];
		new wep = GetPlayerWeaponSlot(client, slot);
		if (wep > MaxClients && IsValidEdict(wep) && GetEdictClassname(wep, classname, sizeof(classname)))
		{
			FakeClientCommandEx(client, "use %s", classname);
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", wep);
		}
	}
}

