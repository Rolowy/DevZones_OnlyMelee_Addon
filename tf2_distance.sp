#include <sourcemod>
#include <morecolors>
#include <sdktools>
#include <sdktools_sound>

#define g_soundName1 "zeleczki/event/headshot1.wav"

#define MAX_FILE_LEN 80

public Plugin:myinfo = 
{
	name = "Distance",
	author = "Rolowy",
	description = "#",
	version = "1.0",
	url = "#"
};


public OnPluginStart()
{
    HookEvent("player_death", Event_Player_Death, EventHookMode_Pre);
}

public OnConfigsExecuted()
{
	char buffer[100];
	for(int x = 1; x<=7; x++)
	{
	Format(buffer, sizeof(buffer), "zeleczki/event/headshot%i.wav", x);
	PrecacheSound(buffer, true);
	Format(buffer, sizeof(buffer), "sound/%s", buffer);
	AddFileToDownloadsTable(buffer);
	}
}

public Event_Player_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(attacker != victim && attacker != 0 && victim != 0)
	{
		new Float:distance;
		distance = GetEntitiesDistance(victim, attacker);
		distance = (distance * 0.01905);
		CPrintToChat(victim, "\x07fe8a71%N \x07FFFFFFkilled you from a distance of \x07fed766%.2f \x07FFFFFFmeters.", attacker, distance);
		
		int customkill = GetEventInt(event,"customkill");
		
		if(customkill == 1)
		{
			char buffer[100];
			int los = GetRandomInt(1, 7);
			Format(buffer, sizeof(buffer), "zeleczki/event/headshot%i.wav", los)
			EmitSoundToClient(attacker, buffer);
		}
	}
}

stock Float:GetEntitiesDistance(ent1, ent2)
{
	new Float:orig1[3];
	GetEntPropVector(ent1, Prop_Send, "m_vecOrigin", orig1);
	
	new Float:orig2[3];
	GetEntPropVector(ent2, Prop_Send, "m_vecOrigin", orig2);

	return GetVectorDistance(orig1, orig2);
}