#pragma semicolon 1
#pragma tabsize 0

#include <sourcemod>
#include <scp>
#include <clientprefs>
#include <adminmenu>
#include <tf2>
#include <tf2_stocks>
#include <morecolors>
#include <advanced_motd>

new bool:_IsClientInGame[MAXPLAYERS+1];

new Handle:db = INVALID_HANDLE;
char steamid[MAXPLAYERS+1][128];

enum struct Player {
   int Kills;
   int Deaths;
   int Assists;
   int Exp;
   int FakeDeaths;
   int HeadShot;
   int BackStab;
   int Deflect;
   bool Adverts;
   bool StalyGracz;
   int Ranga;
}

int RanksPoints[][] = {0, 100, 200, 500, 1000};
char Ranks[][] = {"Gość", "Grajek", "Odwiedzający", "Przyjaciel Serwera", "Stały Gracz"};
char RanksColor[][] = {"fed766", "Grajek", "Odwiedzający", "Przyjaciel Serwera", "63ace5"};

bool:Spectate[MAXPLAYERS+1];


Player g_Player[MAXPLAYERS + 1];


#define SQL_CREATETABLE	"CREATE TABLE IF NOT EXISTS `players` (steamid VARCHAR(20) NOT NULL PRIMARY KEY, nickname TEXT, kills INT, deaths INT, assists INT, exp INT, fakedeaths INT, headshot INT, backstab INT, deflect INT);"
char UpdateUser[] = "UPDATE players SET kills='%i',deaths='%i',assists='%i',exp='%i',fakedeaths='%i',headshot='%i',backstab='%i',deflect='%i' WHERE steamid='%s';";


public Plugin:myinfo = 
{
	name = "Rank",
	author = "Rolowy",
	description = "#",
	version = "1.2",
	url = "#"
};



public OnClientPutInServer(client)
{
    _IsClientInGame[client] = true;	
	Spectate[client] = true;
	g_Player[client].Adverts = true;
	
	
	char buffer[5000];
	GetClientAuthId(client, AuthId_SteamID64, steamid[client], sizeof(steamid));
	
	if(!StrEqual(steamid[client], "STEAM_ID_STOP_IGNORING_RETVALS"))
	{
		PrintToServer("[Rank] %N: Rozpoczęto wyszukiwanie zmiennych", client);
		Format(buffer, sizeof(buffer), "SELECT kills, deaths, assists, exp, fakedeaths, headshot, backstab, deflect FROM players WHERE steamid='%s'", steamid[client]);
		PrintToServer(buffer);

		int userid = GetClientUserId(client);
		SQL_TQuery(db, SQLQuery_Exit, buffer, userid);
	}
	else
	{
		
		PrintToServer("[Rank] %N zalogował się jako STEAM_ID_STOP_IGNORING_RETVALS", client);
	}
}

public OnClientDisconnect(client)
{
	SavePlayersClient(client);
    _IsClientInGame[client] = false; 
}


ConnectDB()
{
	PrintToServer("[Rank] Loading..");    
    PrintToServer("[Rank] Checking databases.cfg..");
    
    decl String:error[256];
    error[0] = '\0';
	
	if(SQL_CheckConfig("ranking")) 
    {
        db = SQL_Connect("ranking", true, error, sizeof(error));
    } 
    
    PrintToServer("[Ranks] Conecting to database..");
    
    if(db==INVALID_HANDLE) 
    {
        LogError("[Ranks] Could not connect to default database: %s", error);
        return;
    }
    
    PrintToServer("[Ranks] Connection successful.");
	
	PrintToServer("[Rank] Creating tables (if not exists)..");
    
    SQL_TQuery(db, SQLErrorCallback, SQL_CREATETABLE);
	
	syncDatabase_exec();
    
	PrintToServer("[Rank] Loaded.");
}

public SQLErrorCallback(Handle:owner, Handle:hndl, const String:error[], any:data) {
    if(!StrEqual("", error)) 
    {
        LogError("Query failed: %s", error);
    }
    return false;
}

public syncDatabase_exec()
{
    for(new i=1; i<= MaxClients; i++)
    {
        if(_IsClientInGame[i])
        {   
            OnClientPutInServer(i);
        }
    }
}

public SQLQuery_Exit(Handle:owner, Handle:hndl, const String:error[], any:data)
{
    new client;
   
    if((client = GetClientOfUserId(data))==0) 
    {
        return;
    }
	
	PrintToServer("%N", client);
	
	if(hndl==INVALID_HANDLE) 
    {
        LogError("[Rank] Query failed: %s", error);
    }
	else
	{
		if (!SQL_GetRowCount(hndl))
		{
			char buffer[5000];
			Format(buffer, sizeof(buffer), "INSERT INTO players (steamid, nickname, kills, deaths, assists, exp, fakedeaths, headshot, backstab, deflect) VALUES (\"%s\", \"%N\", 0, 0, 0, 0, 0, 0, 0, 0)", steamid[client], client);
			SQL_TQuery(db, SQLErrorCallback, buffer);
			PrintToServer("[Rank] Dodano nowego gracza o nazwie %N [%s]", client, steamid[client]);
		}
		else
		{
			SQL_FetchRow(hndl);
			g_Player[client].Kills = SQL_FetchInt(hndl, 0);
			g_Player[client].Deaths = SQL_FetchInt(hndl, 1);
			g_Player[client].Assists = SQL_FetchInt(hndl, 2);
			g_Player[client].Exp = SQL_FetchInt(hndl, 3);
			g_Player[client].FakeDeaths = SQL_FetchInt(hndl, 4);
			g_Player[client].HeadShot = SQL_FetchInt(hndl, 5);
			g_Player[client].BackStab = SQL_FetchInt(hndl, 6);
			g_Player[client].Deflect = SQL_FetchInt(hndl, 7);
			
			PrintToServer("%N: %d %d %d %d %d %d %d %d", client, g_Player[client].Kills,g_Player[client].Deaths,g_Player[client].Assists,g_Player[client].Exp,g_Player[client].FakeDeaths,g_Player[client].HeadShot,g_Player[client].BackStab,g_Player[client].Deflect);
			PrintToServer("[Rank] Załadowano dane z bazy danych na gracza %N", client);
		}
	}
    return;
}




public OnPluginStart() {
	UpdatePlayers();
	ConnectDB();
	
	
	HookEvent("player_death", Event_Player_Death, EventHookMode_Pre);
	RegConsoleCmd("sm_rank", Rank);
	RegConsoleCmd("sm_webrank", WebRank);
	//RegConsoleCmd("sm_testrank", TestRank);
	HookEvent("player_team", Event_playerTeam, EventHookMode_Post);
	
	
	
	CreateTimer(0.1, MyTimer, _, TIMER_REPEAT);	
}


public Action Event_playerTeam(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	int team = GetClientTeam(client);

	if (team == 1)
		Spectate[client] = true;
	else
		Spectate[client] = false;
	
	return Plugin_Continue;
}




public Action MyTimer(Handle timer)
{
	DrawList();
}

public UpdatePlayers()
{
	for(new i=1; i<= MaxClients; i++)
    { 
		if(IsValidClient(i))
		{
			Spectate[i] = false;
			_IsClientInGame[i] = true;
		}
    }
}

public Action TestRank(int client, int args)
{
	char buffer[5000];
	GetClientAuthId(client, AuthId_SteamID64, steamid[client], sizeof(steamid));
	
	
    Format(buffer, sizeof(buffer), "SELECT kills, deaths, assists, exp, fakedeaths, headshot, backstab, deflect FROM players WHERE steamid='%s'", steamid[client]);
	PrintToServer(buffer);
    SQL_TQuery(db, SQLQuery_Exit, buffer, client);
}


public Action WebRank(int client, int args)
{
	char URL[512];
	Format(URL, sizeof(URL), "http://167.86.127.8:4200/rank");
	AdvMOTD_ShowMOTDPanel(client, "Web Rank", URL, MOTDPANEL_TYPE_URL, true, true, true, OnMOTDFailure);
}
public Action Rank(int client, int args)
{
	char buffer[5000];
	Format(buffer, sizeof(buffer), "[Main Ranks] \n \nPoints: %d\n ", g_Player[client].Exp); 
	
	
	Menu menu = new Menu(Rank_Exit);
	menu.SetTitle(buffer);
	
	menu.AddItem("1", "My Statistics");
	menu.AddItem("1", "Badges", ITEMDRAW_DISABLED);
	menu.AddItem("1", "Quests\n ", ITEMDRAW_DISABLED);
	
	menu.AddItem("rank", "Rank List\n ");
	if(g_Player[client].Adverts == true)
		menu.AddItem("ad", "Adverts - [√]");
	else
		menu.AddItem("ad", "Adverts - [ ]");
	
	//menu.AddItem("x", "[Gracz] - [♜]", ITEMDRAW_DISABLED);
	//menu.AddItem("x", "[Stały Gracz] - [ ] (1000 points)", ITEMDRAW_DISABLED);
	
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
}


public int Rank_Exit(Menu menu, MenuAction action, int client, int item)
{
	switch(action)
	{
	case MenuAction_Select:
	{
		char info[32];
		menu.GetItem(item, info, sizeof(info));
		if(StrEqual(info, "1"))
		{
			OpenStatistic(client, 0);
		}
		else if(StrEqual(info, "ad"))
		{
			if(g_Player[client].Adverts == true)
				g_Player[client].Adverts = false;
			else
				g_Player[client].Adverts = true;
			
			Rank(client, 0);
		}
		else if(StrEqual(info, "rank"))
		{
			RankList(client, 0);
		}
		else
		{
			CloseHandle(menu);
		}
	}
	case MenuAction_Cancel:
	{
		ClientCommand(client, "sm_menu");
	}
	case MenuAction_End:
	{
		CloseHandle(menu);
	}
	}
}


public Action RankList(int client, int args)
{
	char buffer[100];
	Format(buffer, sizeof(buffer), "[Rank List]\n "); 
	
	
	Menu menu = new Menu(RankList_Exit);
	menu.SetTitle(buffer);
	
	for(new x = 0; x<sizeof(Ranks); x++)
	{
	if(x == g_Player[client].Ranga)
	{
		Format(buffer, sizeof(buffer), "%s - [√]", Ranks[x]);
		menu.AddItem("x", buffer);
	}
	else
	{
		char value[32];
		IntToString(x, value, sizeof(value));
		
		//if(g_Player[client].Exp < RanksPoints[x])
		//{
		//	Format(buffer, sizeof(buffer), "%s - [ ]", Ranks[x]);
		//	menu.AddItem(value, buffer);
		//}
		//else
		//{
			Format(buffer, sizeof(buffer), "%s - [ ]", Ranks[x]);
			menu.AddItem(value, buffer, ITEMDRAW_DISABLED);
		//}
	}
	}
	
	

	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}



public int RankList_Exit(Menu menu, MenuAction action, int client, int item)
{
	switch(action)
	{
	case MenuAction_Select:
	{
		
	}
	case MenuAction_Cancel:
	{
		Rank(client, 0);
	}
	case MenuAction_End:
	{
		CloseHandle(menu);
	}
	}
}





public SavePlayersClient(int client)
{
	char buffer[5000];
	Format(buffer, sizeof(buffer), UpdateUser, g_Player[client].Kills, g_Player[client].Deaths, g_Player[client].Assists, g_Player[client].Exp, g_Player[client].FakeDeaths, g_Player[client].HeadShot, g_Player[client].BackStab, g_Player[client].Deflect, steamid[client]);
	//PrintToConsole(client, buffer);
	if(SQL_FastQuery(db, buffer))
	{
		PrintToServer("[Rank- Save] - %N - [%s] Zapisano dane gracza poprawnie", client, steamid[client]);
	}
	else
	{
		LogError("[Rank - Save] Error: %s", buffer);
	}
}



public SavePlayers()
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(_IsClientInGame[i] == true)
		{
			SavePlayersClient(i);
		}
	}
}


public Action OpenStatistic(int client, int args)

{
	char buffer[64];
	Format(buffer, sizeof(buffer), "[Statistics]\n "); 
	
	Menu menu = new Menu(BackToRank);
	menu.SetTitle(buffer);
	
	Format(buffer, sizeof(buffer), "[Points]: %d\n ", g_Player[client].Exp); 
	menu.AddItem("0", buffer, ITEMDRAW_DISABLED);
	
	Format(buffer, sizeof(buffer), "[Kills]: %d", g_Player[client].Kills); 
	menu.AddItem("0", buffer, ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "[Deaths]: %d", g_Player[client].Deaths); 
	menu.AddItem("0", buffer, ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "[Assists]: %d", g_Player[client].Assists); 
	menu.AddItem("0", buffer, ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "[Fake Deaths]: %d", g_Player[client].FakeDeaths); 
	menu.AddItem("0", buffer, ITEMDRAW_DISABLED);
	
	Format(buffer, sizeof(buffer), "[HeadShot]: %d", g_Player[client].HeadShot); 
	menu.AddItem("0", buffer, ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "[Deflect]: %d", g_Player[client].Deflect); 
	menu.AddItem("0", buffer, ITEMDRAW_DISABLED);
	Format(buffer, sizeof(buffer), "[Backstab]: %d", g_Player[client].BackStab); 
	menu.AddItem("0", buffer, ITEMDRAW_DISABLED);
	
	
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}


public int BackToRank(Menu menu, MenuAction action, int client, int item)
{
	switch(action)
	{
	case MenuAction_Select:
	{
		Rank(client, 0);
	}
	case MenuAction_Cancel:
	{
		Rank(client, 0);
	}
	case MenuAction_End:
	{
		CloseHandle(menu);
	}
	}
}


public OnPluginEnd()
{
	SavePlayers();
}


public CheckRanks(int client) {
	if(g_Player[client].Exp == 100)
	{
		CPrintToChat(client, "\x07fe8a71[Rank]\x07fed766 Gratulację, udało Ci się wbić nową rangę ! :)");
	}
}

public Event_Player_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    new assister = GetClientOfUserId(GetEventInt(event, "assister"));
    new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	
	
	if(attacker != victim && attacker != 0 && victim != 0)
	{
		new bool:victimFeigned = bool:(GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER);
		if (victimFeigned == false) {
			
			g_Player[attacker].Kills++;
			
			
			CheckRanks(attacker);
			
			if(assister != 0)
			{
				g_Player[assister].Assists++;
			}
			
			g_Player[victim].Deaths++;
			
			new customKill = GetEventInt(event, "customkill");
			
			if (customKill == TF_CUSTOM_HEADSHOT || customKill == TF_CUSTOM_HEADSHOT_DECAPITATION)
			{
				g_Player[attacker].HeadShot++;
			}
			else if (customKill == TF_CUSTOM_BACKSTAB)
			{
				g_Player[attacker].BackStab++;
			}
			else {
			new String:weapon[9];
			GetEventString(event, "weapon", weapon, 9);
			bool deflection = StrEqual(weapon, "deflect_");
			
			if (deflection == true) {
				g_Player[attacker].Deflect++;
			}
		}
			g_Player[attacker].Exp++;
		}
		else
		{
			g_Player[attacker].FakeDeaths++;
		}
	}
}



bool IsValidClient(int client, bool allowBots=true) {
	return ( 1<=client<=MaxClients && IsClientInGame(client) ) && ( allowBots || !IsFakeClient(client) );
}




public Action:OnChatMessage(&author, Handle:recipients, String:name[], String:message[]) {
	if(IsValidClient(author))
	{
		char sTime[32];
		FormatTime(sTime, sizeof(sTime), "%H:%M", GetTime()); 
		
		
		//if(CheckCommandAccess(author, "", ADMFLAG_GENERIC, false) == false)
		Format(name, MAX_NAME_LENGTH, "%s \x07%s[%s] \x03%s", sTime, RanksColor[g_Player[author].Ranga], Ranks[g_Player[author].Ranga], name);
		
		return Plugin_Changed;
	}
	return Plugin_Continue;
}



public DrawList()
{
	new String:player_list[2048];
	for(new client=1; client<= MaxClients; client++)
    {
		//if(Spectate[client])
		if(IsValidClient(client))
		{
			int frags = GetClientFrags(client);
			int deaths = GetClientDeaths(client);
			
			if (frags > 0 && deaths > 0)
			{
				new Float:KDRate = float(g_Player[client].Kills/g_Player[client].Deaths);
				Format(player_list, 512, "♚ [Rank Panel] ♚\n \nRank: [%s]\nExp: [%d]\n \nFrags/Deaths: [%i/%i]\nRatio: %2.f\n \nQuest: Not selected", Ranks[g_Player[client].Ranga], g_Player[client].Exp, frags, deaths, KDRate);
				Client_PrintKeyHintText(client, "%s", player_list);
				
			}
			else
			{
				Format(player_list, 512, "♚ [Rank Panel] ♚\n \nRank: [%s]\nExp: [%d]\n \nFrags/Deaths: [0/0]\nRatio: 0.0\n \nQuest: Not selected", Ranks[g_Player[client].Ranga], g_Player[client].Exp);
				Client_PrintKeyHintText(client, "%s", player_list);
			}
			
		}
	}
}

stock bool:Client_PrintKeyHintText(client, const String:format[], any:...)
{
	new Handle:userMessage = StartMessageOne("KeyHintText", client);
	
	if (userMessage == INVALID_HANDLE) {
		return false;
	}

	decl String:buffer[1000];

	SetGlobalTransTarget(client);
	VFormat(buffer, sizeof(buffer), format, 3);

	BfWriteByte(userMessage, 1); 
	BfWriteString(userMessage, buffer); 

	EndMessage();
	
	return true;
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