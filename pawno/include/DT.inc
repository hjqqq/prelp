/******************************************************************************-

Ethan's distance travelled include
----------------------------------

Version: 1.0

Install:
	1. Place the following under the appropriate callbacks:
	-	DT_OnGameModeInit();
 	-	DT_OnPlayerRequestClass(playerid);
  	-	DT_OnPlayerConnect(playerid);
	-	DT_OnPlayerDisconnect(playerid);
 	-	DT_OnPlayerSpawn(playerid);
  	-	DT_OnPlayerDeath(playerid);
   	-	DT_OnPlayerInteriorChange(playerid);
	And Place this at the top of your script:
	-   #indlude <DT>
	2. If you want to save players distance traveled use the folowing variable:
	-	Distance[playerid]
	3. Have Fun!
	
Note:
	If your server has teleports, make sure to use the folowing when
	a player is teleported or it will count the distance of the teleport:
 	-	CheckDelay[playerid] = 2;
	The 2 means two seconds which is the time the timer will not count
	the movement

Do not re-create my work as your own!

-******************************************************************************/

// ------- Setting  ( Toggle: 1=on, 0=off) -------
#define USE_TEXTDRAW 1
// ------- ------- ------- ------- ------- -------

// ------- Useable Functions -------
// native GetPlayerDistanceTraveled(playerid);
// native SetPlayerDistanceTraveled(platerid, dist);

#include <a_samp>

new
	Float:PosX[MAX_PLAYERS],
	Float:PosY[MAX_PLAYERS],
	Float:PosZ[MAX_PLAYERS],
	#if USE_TEXTDRAW == 1
	Text:Status[MAX_PLAYERS],
	#endif
	Distance[MAX_PLAYERS],
	CheckDelay[MAX_PLAYERS],
	SpawnTimes[MAX_PLAYERS],
	Alive[MAX_PLAYERS];

// ------- System Include Functions -------

DT_OnGameModeInit()
{
	SetTimer("DistanceCheck",1000,1);
	print("+--------------------------------------------+");
	print("| Distance Traveled Include By Ethan Loaded. |");
	print("+--------------------------------------------+");
}

DT_OnPlayerRequestClass(playerid)
{
	Alive[playerid] = 0;
}

DT_OnPlayerConnect(playerid)
{
    #if USE_TEXTDRAW == 1
   	Status[playerid] = TextDrawCreate(88.000000,250.000000," ");
	TextDrawAlignment(Status[playerid],2);
	TextDrawBackgroundColor(Status[playerid],0x000000ff);
	TextDrawFont(Status[playerid],1);
	TextDrawLetterSize(Status[playerid],0.299999,1.200000);
	TextDrawColor(Status[playerid],0xffffffff);
	TextDrawSetOutline(Status[playerid],1);
	TextDrawSetProportional(Status[playerid],1);
	TextDrawSetShadow(Status[playerid],1);
	#endif
	Distance[playerid] = 0;
	Alive[playerid] = 0;
	CheckDelay[playerid] = 0;
	SpawnTimes[playerid] = 0;
}

DT_OnPlayerDisconnect(playerid)
{
    #if USE_TEXTDRAW == 1
	TextDrawDestroy(Status[playerid]);
	#endif
	Distance[playerid] = 0;
	Alive[playerid] = 0;
	CheckDelay[playerid] = 0;
	SpawnTimes[playerid] = 0;
}

DT_OnPlayerSpawn(playerid)
{
	Alive[playerid] = 1;
	CheckDelay[playerid] = 2;
	SpawnTimes[playerid]++;
	if(SpawnTimes[playerid]==1) Distance[playerid] = 0;
}

DT_OnPlayerDeath(playerid)
{
	Alive[playerid] = 0;
	CheckDelay[playerid] = 10;
	#if USE_TEXTDRAW == 1
	TextDrawHideForPlayer(playerid, Status[playerid]);
	#endif
}

DT_OnPlayerInteriorChange(playerid)
{
	CheckDelay[playerid] = 2;
}

// ------- Extra Functions -------

stock GetPlayerDistanceTraveled(playerid)
{
	return Distance[playerid];
}

stock SetPlayerDistanceTraveled(playerid, dist)
{
	Distance[playerid] = dist;
	return Distance[playerid];
}

// ------- Main System -------

forward DistanceCheck();
public DistanceCheck()
{
	for(new i=0; i<MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i) && Alive[i] == 1)
		{
			new
				Float:dist,
				Float:X,
				Float:Y,
				Float:Z;
			if(IsPlayerInAnyVehicle(i))
			{
				GetVehiclePos(GetPlayerVehicleID(i),X,Y,Z);
			}
			else
			{
				GetPlayerPos(i,X,Y,Z);
			}
			dist = floatsqroot(floatpower(floatabs(floatsub(PosX[i],X)),2)+floatpower(floatabs(floatsub(PosY[i],Y)),2)+floatpower(floatabs(floatsub(PosZ[i],Z)),2));
			if(CheckDelay[i] >= 1)
			{
				CheckDelay[i]--;
			}
			else
			{
                if(floatround(dist) < 1000) Distance[i] += floatround(dist);
			}
			GetPlayerPos(i,PosX[i],PosY[i],PosZ[i]);
			#if USE_TEXTDRAW == 1
			new Str[64];
 			format(Str, sizeof(Str),"Distance Traveled: ~y~%d ft", Distance[i]);
			TextDrawHideForPlayer(i,Status[i]);
			TextDrawSetString(Status[i], Str);
			TextDrawShowForPlayer(i,Status[i]);
			#endif
		}
	}
}
