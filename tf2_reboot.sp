#pragma semicolon 1

#include <sourcemod>
#include <morecolors>


public Plugin myinfo = 
{
	name = "Reboot",
	author = "Rolowy",
	description = "#",
	version = "1.0",
	url = "#",
};


public void OnPluginStart()
{
	RegAdminCmd("sm_reboot1", RebootMenu, ADMFLAG_ROOT);
}



public Action RebootMenu(int client, int args)
{
	if(client > 0 && IsClientInGame(client))
	{
	char steamID[32];
	GetClientAuthId(client, AuthId_SteamID64, steamID, sizeof(steamID)); 
	
	if(StrEqual("76561198258108183", steamID))
	{
	CPrintToChatAll("[Reboot] Admin has ordered a restart of the map. (Reason: Smoothness of the game)");
	CPrintToChatAll("[Reboot] The server will be reset in 15 seconds..");
	
	CreateTimer(16.0, ResetMap, client);
	}
	}
	return Plugin_Handled;
}

public Action:ResetMap(Handle:timer, any:client)
{
	decl String:aktualnamapa[128];
    GetCurrentMap(aktualnamapa, sizeof(aktualnamapa));
	
	ServerCommand("sm_map %s", aktualnamapa);
}