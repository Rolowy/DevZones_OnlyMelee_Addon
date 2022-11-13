#include <sourcemod>
#include <sdktools>

new Handle:g_hTimer;
new Handle:HudMessage;

new bool:_IsClientInGame[MAXPLAYERS + 1] = false;

public Plugin myinfo = 
{
	name = "Hud",
	author = "Rolowy",
	description = "#",
	version = "1.0",
	url = "#",
};


public OnPluginStart()
{
    HudMessage = CreateHudSynchronizer();
}

public OnClientPutInServer(client)
{
    _IsClientInGame[client] = true;	
}

public OnClientDisconnect_Post(client)
    _IsClientInGame[client] = false; 


public OnMapStart() 
{
    g_hTimer = CreateTimer(1.0, Timer_ShowInfo, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action:Timer_ShowInfo(Handle:timer) {


    for (new i = 1, iClients = GetClientCount(); i <= iClients; i++) 
	{
        if (_IsClientInGame[i]) 
		{
			int r = RollRandom();
			int g = RollRandom();
			int b = RollRandom();
			
			//int r = 131;
			//int g = 208;
			//int b = 201;
			
            SetHudTextParams(-1.0, 0.07, 2.0, r, g, b, 255, 2, 0.2, 0.1, 0.1);
            ShowSyncHudText(i, HudMessage, "PIEROGARNIA", GetClientHealth(i));
        }
    }

    return Plugin_Continue
}

public RollRandom()
{
	return GetRandomInt(1,255);
}

public ConVarChange_Interval(Handle:convar, const String:oldValue[], const String:newValue[]) 
{
    if (g_hTimer != INVALID_HANDLE) 
	{
        KillTimer(g_hTimer);
    }
    
    g_hTimer = CreateTimer(1.0, Timer_ShowInfo, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}