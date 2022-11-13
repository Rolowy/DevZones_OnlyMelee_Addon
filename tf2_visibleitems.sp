#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
 
public Plugin myinfo =
{
	name = "VisibleItems",
	author = "Rolowy",
	description = "#",
	version = "1.0",
	url = "#"
};
 
public void OnPluginStart()
{
	
}
 
public void OnEntityCreated(int ent, const char[] classname)
{
	if(IsValidEntity(ent))
	{
	if(StrEqual(classname, "wearable_item") || StrEqual(classname, "tf_powerup_bottle"))
	{
		SetEntProp(ent, Prop_Send, "m_bValidatedAttachedEntity", 1);
	}
	}
	return;
}



