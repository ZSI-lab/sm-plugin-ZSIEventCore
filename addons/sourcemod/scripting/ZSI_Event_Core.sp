#include <sourcemod>
#include <multicolors>

#define MAXLINES 1024

#pragma newdecls required

ConVar g_cvEventInfoFile;
ConVar g_cvEventInfoTime;
char g_sBufferFile[MAXLINES][1024];
char g_sBufferTime[MAXLINES][1024];

public Plugin myinfo = 
{
	name         = "ZSI Event Info",
	author       = "Dimas9410, ILLEGAL",
	description  = "Event Info ZSI",
	version      = "1.0",
	url          = "https://zsi-offliner.my.id/"
};

public void OnPluginStart() {
	RegConsoleCmd("sm_event", Command_Event);
	RegConsoleCmd("sm_events", Command_Event);
	RegConsoleCmd("sm_eventinfo", Command_Event);

	g_cvEventInfoFile = CreateConVar("sm_event_info_file", "no_eventschedule", "", FCVAR_NONE);
	g_cvEventInfoTime = CreateConVar("sm_event_time_file", "no_event_timeschedule", "", FCVAR_NONE);
	HookConVarChange(g_cvEventInfoFile, Cvar_FileChanged);
	HookConVarChange(g_cvEventInfoTime, Cvar_FileTimeChanged);
}

public void Cvar_FileChanged(ConVar convar, const char[] oldValue, const char[] newValue) {
	for (int i = 0; i <= (MAXLINES - 1); i++)
		g_sBufferFile[i][0] = '\0';

	char sFile[PLATFORM_MAX_PATH];
	char sLine[1024];
	char sFilename[1024];
	GetConVarString(g_cvEventInfoFile, sFilename, sizeof(sFilename))

	if (StrEqual(sFilename, "null"))
		return;

	BuildPath(Path_SM, sFile, sizeof(sFile), "configs/event_info/%s.cfg", sFilename);

	Handle hFile = OpenFile(sFile, "r");

	if(hFile != INVALID_HANDLE) {
		int iLine = 0;
		while (!IsEndOfFile(hFile)) {
			if (!ReadFileLine(hFile, sLine, sizeof(sLine)))
				break;

			TrimString(sLine);
			g_sBufferFile[iLine] = sLine;
			iLine++;
		}

		CloseHandle(hFile);
	}
	else {
		LogError("[SM] File not found! :D", sFilename);
	}
}

public void Cvar_FileTimeChanged(ConVar convar, const char[] oldValue, const char[] newValue) {

	char sFileTime[PLATFORM_MAX_PATH];
	char sLineTime[1024];
	char sFilenametime[1024];
	GetConVarString(g_cvEventInfoTime, sFilenametime, sizeof(sFilenametime))

	if (StrEqual(sFilenametime, "null"))
		return;

	BuildPath(Path_SM, sFileTime, sizeof(sFileTime), "configs/event_info/%s.cfg", sFilenametime);

	Handle hFile = OpenFile(sFileTime, "r");

	if(hFile != INVALID_HANDLE) {
		int iLine = 0;
		while (!IsEndOfFile(hFile)) {
			if (!ReadFileLine(hFile, sLineTime, sizeof(sLineTime)))
				break;

			TrimString(sLineTime);
			g_sBufferTime[iLine] = sLineTime;
			iLine++;
		}

		CloseHandle(hFile);

	}
	else {
		LogError("[SM] %s File not found!", sFileTime);
	}
}

int MenuHandler_NotifyPanel(Menu hMenu, MenuAction iAction, int iParam1, int iParam2) {
	switch (iAction) {
		case MenuAction_Select, MenuAction_Cancel:
			delete hMenu;
	}
}

public Action Command_Event(int client, int args) {
	char sFilename[1024];
	GetConVarString(g_cvEventInfoFile, sFilename, sizeof(sFilename));

	char sFiletime[1024];
	GetConVarString(g_cvEventInfoTime, sFiletime, sizeof(sFiletime));

	if (StrEqual(sFilename, "null"))
		return;

	Panel hNotifyPanel = new Panel(GetMenuStyleHandle(MenuStyle_Radio));

	for (int i = 0; i <= (MAXLINES - 1); i++)
	{
		if (StrEqual(g_sBufferFile[i], ""))
			break;

		if (StrEqual(g_sBufferFile[i], "/n"))
			hNotifyPanel.DrawItem("", ITEMDRAW_SPACER);

		else
			hNotifyPanel.DrawItem(g_sBufferFile[i], ITEMDRAW_RAWLINE);
	}

	hNotifyPanel.SetKeys(1023);
	hNotifyPanel.Send(client, MenuHandler_NotifyPanel, 0);
	delete hNotifyPanel;

	// chat
	// lgsg read .cfg, ga perlu /rcon

	BuildPath(Path_SM, sFiletime, sizeof(sFiletime), "configs/event_info/%s.cfg", sFiletime);

	Handle hFile = OpenFile(sFiletime, "r");
	if (hFile != INVALID_HANDLE) { //armadilo patch 15/5/2024
		while (!IsEndOfFile(hFile)) {
			char sTime[1024];
			if (ReadFileLine(hFile, sTime, sizeof(sTime))) {
				TrimString(sTime);

				CPrintToChat(client, "{blue}[{aqua}Event Info{blue}] {lightgreen}%s", sTime);
            }
        }

        CloseHandle(hFile);
	}	
 	else {
        LogError("[SM] %s File not found!", sFilename);
    }
}