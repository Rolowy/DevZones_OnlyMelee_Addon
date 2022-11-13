#include <sourcemod>
#include <tf2_stocks>
#include <tf2attributes>

public Plugin:myinfo =
{
	name = "Addons",
	author = "Rolowy",
	description = "#",
	version = "1.0",
	url = "#"
};


public void OnPluginStart()
{
	HookEvent("post_inventory_application", player_inv2);		
}


public void player_inv2(Handle event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	int Primary = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	int Secondary = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	//int Melee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	
	new String:auth[32];
	GetClientAuthId(client, AuthId_SteamID64, auth, sizeof(auth)); 
	
	switch(TF2_GetPlayerClass(client))
	{
		case TFClass_Heavy:
		{
		}
		case TFClass_DemoMan:
		{
		}
		case TFClass_Soldier:
		{
		}
		case TFClass_Scout:
		{
		}
		case TFClass_Pyro:
		{
		}
		case TFClass_Sniper:
		{
		}
		case TFClass_Spy:
		{
		}
		case TFClass_Medic:
		{
		}
		case TFClass_Engineer:
		{
			if(IsValidEntity(Primary))
			{
				TF2Attrib_SetByDefIndex(Primary, 80, 2.0);	
			}
		}	
	}
}
