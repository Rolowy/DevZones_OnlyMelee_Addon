#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <morecolors>
#include <basecomm>

#include <tf2_stocks>
#include <advanced_motd>

new bool:_IsClientInGame[MAXPLAYERS + 1] = false;

new Handle:g_mapArray = INVALID_HANDLE;
new g_mapSerial = -1;

int iPort = -1;

bool:FirstSpawn[MAXPLAYERS+1] = false;

public Plugin myinfo = 
{
	name = "Menu",
	author = "Rolowy",
	description = "#",
	version = "1.0",
	url = "#",
};


public void OnPluginStart()
{
	iPort = GetConVarInt(FindConVar("hostport"));
	g_mapArray = CreateArray(32);
	
	RegConsoleCmd("sm_menu", Main_Menu);
	RegConsoleCmd("sm_hop", Hop_Menu);
	
	RegConsoleCmd("sm_profile", Main_Profile);
	//RegAdminCmd("sm_tele", Main_Tele, ADMFLAG_ROOT);
	
	//RegConsoleCmd("sm_google", Command_Google, "Opens Google in a large MOTD window");
	UpdatePlayers();
	
	//HookEvent("player_spawn", PlayerSpawn);
}



public Action Main_Tele(int client, int args)
{
	Menu menu = new Menu(Main_Tele_Handle, MENU_ACTIONS_ALL);
	menu.SetTitle("[Teleport Menu]\n ");
	menu.AddItem("1", "Premium Room");
	menu.AddItem("2", "Admin Room");
	menu.AddItem("3", "Wiezienie");
	menu.AddItem("4", "Mala Plaza");
	menu.AddItem("5", "Duza Plaza (Basen)");
	menu.AddItem("6", "Disco");
	menu.AddItem("7", "Sekretny Pokoj");
	
	menu.ExitButton = true;
	menu.ExitBackButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
}


public int Main_Tele_Handle(Menu menu, MenuAction action, int client, int item)
{
	switch(action)
	{
	case MenuAction_Select:
	{
		char choice[64];
		menu.GetItem(item, choice, sizeof(choice));
		
		if(StrEqual(choice, "1"))
		{
			new Float:flPos[3] = {5677.473144, 7401.979492, -2022.878784};
			TeleportEntity(client, flPos, NULL_VECTOR, NULL_VECTOR); 
		}
		else if(StrEqual(choice, "2"))
		{
			new Float:flPos[3] = {4380.502929, 7682.392089, -1991.968750};
			TeleportEntity(client, flPos, NULL_VECTOR, NULL_VECTOR); 
		}
		else if(StrEqual(choice, "3"))
		{
			new Float:flPos[3] = {1030.380371, 2353.684082, -2669.888671};
			TeleportEntity(client, flPos, NULL_VECTOR, NULL_VECTOR); 
		}
		else if(StrEqual(choice, "4"))
		{
			new Float:flPos[3] = {5403.760742, 4960.507812, -2969.968750};
			TeleportEntity(client, flPos, NULL_VECTOR, NULL_VECTOR); 
		}
		else if(StrEqual(choice, "5"))
		{
			new Float:flPos[3] = {3691.966064, 5688.350585, -3147.968750};
			TeleportEntity(client, flPos, NULL_VECTOR, NULL_VECTOR); 
		}
		else if(StrEqual(choice, "6"))
		{
			new Float:flPos[3] = {6276.339843, 5705.241699, -2952.968750};
			TeleportEntity(client, flPos, NULL_VECTOR, NULL_VECTOR); 
		}
		else if(StrEqual(choice, "7"))
		{
			new Float:flPos[3] = {3791.231689, 2352.088623, -2372.968750};
			TeleportEntity(client, flPos, NULL_VECTOR, NULL_VECTOR); 
		}
		
		
		Main_Tele(client, 0);
	}
	case MenuAction_End:
	{
		//param1 is MenuEnd reason, if canceled param2 is MenuCancel reason
		CloseHandle(menu);
	}
	}
}




public PlayerSpawn(Handle:event, const String:Name[], bool:Broadcast)
{
	decl client;
	client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(FirstSpawn[client] == false)
	{
		FirstSpawn[client] = true;
		AdvMOTD_ShowMOTDPanel(client, "Logo", "https://i.imgur.com/EaNGehl.jpg", MOTDPANEL_TYPE_URL, true, true, true, OnMOTDFailure);
		return;
	}
	return;
}



public UpdatePlayers()
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			_IsClientInGame[i] = true;
		}
	}
}


public OnClientPutInServer(client)
{
    _IsClientInGame[client] = true;	
}

public OnClientDisconnect_Post(client)
    _IsClientInGame[client] = false; 



public Action Main_Profile(int client, int args)
{
	if (args == 0)
	{
	Menu menu = new Menu(Main_Profile_Handle, MENU_ACTIONS_ALL);
	char URL[512]; 
	char steamID[64];
	
	
	menu.SetTitle("[Steam Profile]\n ");
	
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			if(i == client)
			{
			Format(URL, sizeof(URL), "%N (You)", i);
			}
			else
			{
			Format(URL, sizeof(URL), "%N", i);
			}
			
			GetClientAuthId(client, AuthId_SteamID64, steamID, sizeof(steamID)); 
			menu.AddItem(steamID, URL);
		}
	}
	
	menu.ExitButton = true;
	menu.ExitBackButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
	}
	else if (args == 1)
	{
		new String:arg1[128];
		GetCmdArg(1, arg1, 128);
		int target = FindTarget(0, arg1, true, false);


		if(_IsClientInGame[target] == false)
		{
			ReplyToCommand(client, "[SM] %t", "No matching client");
			return Plugin_Handled;
		}
		else
		{
			char steamID[64];
			GetClientAuthId(target, AuthId_SteamID64, steamID, sizeof(steamID)); 
			
			char URL[512];
			Format(URL, sizeof(URL), "https://steamcommunity.com/profiles/%s", steamID);
			AdvMOTD_ShowMOTDPanel(client, "SteamID Profile", URL, MOTDPANEL_TYPE_URL, true, true, true, OnMOTDFailure);	
		}
	}
	return Plugin_Handled;
}


public int Main_Profile_Handle(Menu menu, MenuAction action, int client, int item)
{
	switch(action)
	{
	case MenuAction_Select:
	{
		char choice[64];
		menu.GetItem(item, choice, sizeof(choice));

		char URL[512];
		Format(URL, sizeof(URL), "https://steamcommunity.com/profiles/%s", choice);
		AdvMOTD_ShowMOTDPanel(client, "SteamID Profile", URL, MOTDPANEL_TYPE_URL, true, true, true, OnMOTDFailure);
		
		Main_Profile(client, 0);
	}
	case MenuAction_End:
	{
		//param1 is MenuEnd reason, if canceled param2 is MenuCancel reason
		CloseHandle(menu);
	}
	}
}



public Action Hop_Menu(int client, int args)
{
	Server_List(client);
}



public Action Main_Menu(int client, int args)
{
	Menu menu = new Menu(MainHandle, MENU_ACTIONS_ALL);
	menu.SetTitle("[Main Menu]\n ");
	//menu.AddItem("1", "Rules\n ");
	menu.AddItem("B", "Main Rank\n ");
	
	
	
	menu.AddItem("00", "Web Rank\n ");
	
	menu.AddItem("2", "Server List");
	menu.AddItem("v", "Penalties");
	//menu.AddItem("x", "Map List");
	//menu.AddItem("3", "About Service");
	menu.AddItem("9", "Addons");
	menu.AddItem("4", "Command List");
	//menu.AddItem("5", "Projects\n ");
	menu.AddItem("6", "Contact");
	
	menu.ExitButton = true;
	menu.ExitBackButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
}


public int MainHandle(Menu menu, MenuAction action, int client, int item)
{
	switch(action)
	{
	case MenuAction_Select:
	{
		char choice[64];
		menu.GetItem(item, choice, sizeof(choice));
		
		if(StrEqual(choice, "1"))
		{
			Rules_Menu(client);
		}
		else if(StrEqual(choice, "2"))
		{
			Server_List(client);
		}
		else if(StrEqual(choice, "00"))
		{
			char URL[512];
			Format(URL, sizeof(URL), "http://167.86.127.8:4200/rank");
			AdvMOTD_ShowMOTDPanel(client, "Web Rank", URL, MOTDPANEL_TYPE_URL, true, true, true, OnMOTDFailure);	
		}
		
		else if(StrEqual(choice, "3"))
		{
			About_Service(client);
		}
		else if(StrEqual(choice, "4"))
		{
			Command_List(client);
		}
		else if(StrEqual(choice, "5"))
		{
			//Projects\n(client);
		}
		else if(StrEqual(choice, "9"))
		{
			Addons(client);
		}
		else if(StrEqual(choice, "6"))
		{
			char URL[512];
			Format(URL, sizeof(URL), "https://steamcommunity.com/id/Rolowy");
			AdvMOTD_ShowMOTDPanel(client, "SteamID Profile", URL, MOTDPANEL_TYPE_URL, true, true, true, OnMOTDFailure);
			Main_Menu(client, 0);
		}
		else if(StrEqual(choice, "x"))
		{
			MapList(client);
		}
		else if(StrEqual(choice, "v"))
		{
			Punishments(client);
		}
		else if(StrEqual(choice, "B"))
		{
			ClientCommand(client, "sm_rank");
		}	
	}
	case MenuAction_End:
	{
		//param1 is MenuEnd reason, if canceled param2 is MenuCancel reason
		CloseHandle(menu);
	}
	}
}


public Punishments(client)
{
	Menu menu = new Menu(BackToMainMenu_Handle);
	menu.SetTitle("[Penalties]\n ");
	
	if (BaseComm_IsClientGagged(client))
		menu.AddItem("x", "[GAG]: YES", ITEMDRAW_DISABLED);
	else
		menu.AddItem("x", "[GAG]: NO", ITEMDRAW_DISABLED);
	
	if (BaseComm_IsClientMuted(client))
		menu.AddItem("x", "[MUTE]: YES", ITEMDRAW_DISABLED);
	else
		menu.AddItem("x", "[MUTE]: NO", ITEMDRAW_DISABLED);
	
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}


public int BackToMainMenu_Handle(Menu menu, MenuAction action, int client, int item)
{
	switch(action)
	{
	case MenuAction_Select:
	{
		Main_Menu(client, 0);
	}
	case MenuAction_Cancel:
	{
		Main_Menu(client, 0);
	}
	case MenuAction_End:
	{
		//param1 is MenuEnd reason, if canceled param2 is MenuCancel reason
		CloseHandle(menu);
	}
	}
}



public MapList(client)
{
	Menu menu = new Menu(MapList_Handle, MENU_ACTIONS_ALL);
	
	new String:buf[64];
	ReadMapList(g_mapArray, g_mapSerial, "default");
	Format(buf, sizeof(buf), "[Current Rotation] (%d maps)\n ", GetArraySize(g_mapArray));
			
	menu.SetTitle(buf);
	
	if (g_mapArray != INVALID_HANDLE) {
		new mapct = GetArraySize(g_mapArray);
		new String:mapname[64];
		for (new i = 0; i < mapct; ++i) {
				GetArrayString(g_mapArray, i, mapname, sizeof(mapname));
				menu.AddItem(mapname, mapname, ITEMDRAW_DISABLED);
		}
	}

	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}


public int MapList_Handle(Menu menu, MenuAction action, int client, int item)
{
	switch(action)
	{
	case MenuAction_Select:
	{
		Main_Menu(client, 0);
	}
	case MenuAction_Cancel:
	{
		Main_Menu(client, 0);
	}
	case MenuAction_End:
	{
		//param1 is MenuEnd reason, if canceled param2 is MenuCancel reason
		CloseHandle(menu);
	}
	}
}

public Server_List(client)
{
	Menu menu = new Menu(Server_List_Handle);
	menu.SetTitle("[Server List]\n ");
	
	if (iPort == 27015)
	{
		menu.AddItem("1", "[#1] SERVER IDLE (You are here)", ITEMDRAW_DISABLED);
		menu.AddItem("2", "[#2] SERVER MIX");
	}
	else if (iPort == 27016)
	{
		menu.AddItem("1", "[#1] SERVER IDLE");
		menu.AddItem("2", "[#2] SERVER MIX (You are here)", ITEMDRAW_DISABLED);
	}
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}


public int Server_List_Handle(Menu menu, MenuAction action, int client, int item)
{
	switch(action)
	{
	case MenuAction_Select:
	{
		char choice[64];
		menu.GetItem(item, choice, sizeof(choice));
		
		if(StrEqual(choice, "1"))
		{
			ClientCommand(client, "redirect 167.86.127.8:27015");
			CPrintToChatAll("{gold}★ Servers {white}| Player %N has moved to idle server !", client);
		}
		else if(StrEqual(choice, "2"))
		{
			ClientCommand(client, "redirect 167.86.127.8:27016");
			CPrintToChatAll("{gold}★ Servers {white}| Player %N has moved to mix server !", client);
		}
		
	}
	case MenuAction_Cancel:
	{
		Main_Menu(client, 0);
	}
	case MenuAction_End:
	{
		//param1 is MenuEnd reason, if canceled param2 is MenuCancel reason
		CloseHandle(menu);
	}
	}
}




public About_Service(client)
{
	Menu menu = new Menu(About_Service_Handle, MENU_ACTIONS_ALL);
	menu.SetTitle("[About Service] (Our goals)\n ");
	menu.AddItem("1", "In the process of updating..", ITEMDRAW_DISABLED);
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}


public int About_Service_Handle(Menu menu, MenuAction action, int client, int item)
{
	switch(action)
	{
	case MenuAction_Select:
	{
		char choice[64];
		menu.GetItem(item, choice, sizeof(choice));
	}
	case MenuAction_Cancel:
	{
		Main_Menu(client, 0);
	}
	case MenuAction_End:
	{
		//param1 is MenuEnd reason, if canceled param2 is MenuCancel reason
		CloseHandle(menu);
	}
	}
}




public Addons(client)
{
	Menu menu = new Menu(MapList_Handle, MENU_ACTIONS_ALL);
	menu.SetTitle("[Addons List]\n ");
	
	menu.AddItem("x", "[Engineer] +200 metal", ITEMDRAW_DISABLED);
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public Command_List(client)
{
	Menu menu = new Menu(Command_List_Handle, MENU_ACTIONS_ALL);
	menu.SetTitle("[Command List]\n ");
	
	menu.AddItem("sm_menu", "Menu - !menu", ITEMDRAW_DISABLED);
	menu.AddItem("sm_webrank", "Web Rank - !webrank", ITEMDRAW_DISABLED);
	menu.AddItem("sm_steamid", "SteamID IO - !steamid", ITEMDRAW_DISABLED);
	
	menu.AddItem("sm_profile", "Profile - !profile", ITEMDRAW_DISABLED);
	menu.AddItem("sm_tp", "Third Person - !tp", ITEMDRAW_DISABLED);
	menu.AddItem("sm_fp", "First Person - !fp", ITEMDRAW_DISABLED);
	menu.AddItem("sm_gimme", "Gimme Skins - !gimme", ITEMDRAW_DISABLED);
	//menu.AddItem("sm_zombies", "Be a Zombies - !zombies", ITEMDRAW_DISABLED);
	//menu.AddItem("sm_fashion", "Fashion Menu - !fashion", ITEMDRAW_DISABLED);
	//menu.AddItem("sm_covid", "Covid Mask - !covid", ITEMDRAW_DISABLED);
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}


public int Command_List_Handle(Menu menu, MenuAction action, int client, int item)
{
	switch(action)
	{
	case MenuAction_Select:
	{
		char choice[64];
		menu.GetItem(item, choice, sizeof(choice));
		ClientCommand(client, choice);
		Command_List(client);
	}
	case MenuAction_Cancel:
	{
		Main_Menu(client, 0);
	}
	case MenuAction_End:
	{
		//param1 is MenuEnd reason, if canceled param2 is MenuCancel reason
		CloseHandle(menu);
	}
	}
}





public Rules_Menu(client)
{
	ClientCommand(client, "motd");
	Main_Menu(client, 0);
}


public Action Command_Google(int client, int args) {
    AdvMOTD_ShowMOTDPanel(client, "Google", "http://www.google.com", MOTDPANEL_TYPE_URL, true, true, true, OnMOTDFailure);
    return Plugin_Handled;
}

public void OnMOTDFailure(int client, MOTDFailureReason reason) {
    if(reason == MOTDFailure_Disabled) {
        PrintToChat(client, "[SM] You have HTML MOTDs disabled.");
    } else if(reason == MOTDFailure_Matchmaking) {
        PrintToChat(client, "[SM] You cannot view HTML MOTDs because you joined via Quickplay.");
    } else if(reason == MOTDFailure_QueryFailed) {
        PrintToChat(client, "[SM] Unable to verify that you can view HTML MOTDs.");
    } else {
        PrintToChat(client, "[SM] Unable to verify that you can view HTML MOTDs for an unknown reason.");
    }
} 