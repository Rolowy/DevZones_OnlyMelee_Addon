#include <sourcemod>

public Plugin:myinfo =
{
	name = "Reload",
	author = "Rolowy",
	description = "#",
	version = "1.0",
	url = "#"
};

public void OnPluginStart(){
	RegAdminCmd("sm_reload",	Menu_Reload, ADMFLAG_ROOT);
	RegAdminCmd("sm_load",	Menu_Load, ADMFLAG_ROOT);
	RegAdminCmd("sm_unload",	Menu_Unload, ADMFLAG_ROOT);	
}

public Action Menu_Reload(int client, int args)
{
	if (args >= 1)
	{
		char buffer[512];
		GetCmdArgString(buffer, sizeof(buffer));
		
		if(client == 0)
			ServerCommand("sm_rcon sm plugins reload %s", buffer);
		else
		ClientCommand(client, "sm_rcon sm plugins reload %s", buffer);
	}
	else
	{
		ReplyToCommand(client, "[SM] sm_reload <plugins>");
	}
	return Plugin_Handled;
}

public Action Menu_Load(int client, int args)
{
	if (args >= 1)
	{
		char buffer[512];
		GetCmdArgString(buffer, sizeof(buffer));
		if(client == 0)
			ServerCommand("sm_rcon sm plugins load %s", buffer);
		else
			ClientCommand(client, "sm_rcon sm plugins load %s", buffer);
	}
	else
	{
		ReplyToCommand(client, "[SM] sm_load <plugins>");
	}
	return Plugin_Handled;
}
public Action Menu_Unload(int client, int args)
{
	if (args >= 1)
	{
		char buffer[512];
		GetCmdArgString(buffer, sizeof(buffer));
		
		if(client == 0)
			ServerCommand("sm_rcon sm plugins unload %s", buffer);
		else
		ClientCommand(client, "sm_rcon sm plugins unload %s", buffer);
	}
	else
	{
		ReplyToCommand(client, "[SM] sm_unload <plugins>");
	}
	return Plugin_Handled;
}
