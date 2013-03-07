#define PENALTY_TYPE_WARN 0
#define PENALTY_TYPE_KICK 1
#define PENALTY_TYPE_BAN 2
#define PENALTY_TYPE_AJ 3
#define PENALTY_TYPE_BLOCK_OOC 4
#define PENALTY_TYPE_BLOCK_SPRINT 5
#define PENALTY_TYPE_BLOCK_FIGHT 6


stock GetPlayerSpawnType(playerid)
{
   new spawnType;
   sscanf(pInfo[playerid][baseSpawn], "p<,>d", spawnType);
   
   return spawnType;
}

stock GetPlayerSpeed(playerid)
{
        new Float:ST[ 4 ];
        GetPlayerVelocity(playerid, ST[ 0 ], ST[ 1 ], ST[ 2 ]);
        ST[3] = floatsqroot(floatpower(floatabs(ST[ 0 ]), 2.0) + floatpower(floatabs(ST[ 1 ]), 2.0) + floatpower(floatabs(ST[ 2 ]), 2.0)) * 169;
        return floatround(ST[ 3 ])/2;
}

stock GetPlayerSpawnLocation(playerid, &Float:x, &Float:y, &Float:z, &vw, &interior, &sType)
{ 
   // TODO: delete if cannot spawn
   sType = GetPlayerSpawnType(playerid);
   interior = 0;
   if( sType == 0 )
   {
	  basicSpawn:
	  // Basic spawn
	  x = BASEspawn[0];
	  y = BASEspawn[1];
	  z = BASEspawn[2];
	  vw = 0;
	  return 1;
   }
   
   if( sType == 1 )
   {
	  // House spawn
	  new doorsUid;
	  sscanf(pInfo[playerid][baseSpawn], "p<,>{d}d", doorsUid);
	  new doorsId = GetDoorsByUid(doorsUid);
	  
	  if( doorsId == -1 ) goto basicSpawn;
	  x = doors[doorsId][intSpawnX];
	  y = doors[doorsId][intSpawnY];
	  z = doors[doorsId][intSpawnZ];
	  
	  vw = doors[doorsId][doorUid];
	  return 1;
   }
   
   if( sType == 2 )
   {
      new doorsUid;
	  sscanf(pInfo[playerid][baseSpawn], "p<,>{d}d", doorsUid);
      vw = pInfo[playerid][uid];
	  interior = 9;
	  x = 2251.85;
      y = -1138.16;
      z = 1050.63;
	  pInfo[playerid][hotelOutdoor] = doorsUid;
   }
      
   return 0;
}

stock GetPlayerDynamicArea(playerid)
{
  if( pInfo[playerid][currentDynamicArea] == -1 ) return -1;
  if( !IsValidDynamicArea(pInfo[playerid][currentDynamicArea]) ) return -1;
  if( !IsPlayerInDynamicArea(playerid, pInfo[playerid][currentDynamicArea]) ) return -1;
  
  return pInfo[playerid][currentDynamicArea];
}

stock GetPlayerDynamicDoors(playerid)
{
  foreach (new area : Areas)
  {
    if( !IsValidDynamicArea(area) ) continue;
	if( areas[area][type] == AREA_TYPE_INNER_DOORS || areas[area][type] == AREA_TYPE_OUTER_DOORS )
	{
      if( IsPlayerInDynamicArea(playerid, area) ) return area;
	}  
  } 
  return -1;
}


public ResetSkills(playerid)
{
   SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 0);
   SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL_SILENCED, 0);
   SetPlayerSkillLevel(playerid, WEAPONSKILL_DESERT_EAGLE, 0);
   SetPlayerSkillLevel(playerid, WEAPONSKILL_SHOTGUN, 0);
   SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN, 0);
   SetPlayerSkillLevel(playerid, WEAPONSKILL_SPAS12_SHOTGUN, 0);
   SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI, 0);
   SetPlayerSkillLevel(playerid, WEAPONSKILL_MP5, 0);
   SetPlayerSkillLevel(playerid, WEAPONSKILL_AK47, 0);
   SetPlayerSkillLevel(playerid, WEAPONSKILL_M4, 0);
   SetPlayerSkillLevel(playerid, WEAPONSKILL_SNIPERRIFLE, 0);
   return 1;
}

stock SavePlayer(playerid)
{
  new Query[256];
  format( Query, sizeof(Query), "UPDATE `characters` SET `online`='0', `timeOnline`='%d', `cash`='%d', `weaponskill`='%d', `bw`='%d', `bwStatus`='%d', `health`='%f' WHERE `uid`='%d'", pInfo[playerid][timeOnline], pInfo[playerid][cash], pInfo[playerid][weaponskill], pInfo[playerid][bw], pInfo[playerid][bwStatus], pInfo[playerid][health], pInfo[playerid][uid]);
  mysql_function_query(mysqlHandle, Query, false, "", "");
  
  String->Format("Zapisywanie gracza o uid %d", pInfo[playerid][uid]);
  Crp->Notify("gracze", formatted);
}

stock BlockCharacter(playerid)
{      
        new string[256];
        format(string, sizeof(string), "UPDATE `characters` SET `p_block`='1' WHERE `uid`='%d'", pInfo[playerid][uid]);
        mysql_function_query(mysqlHandle, string, false, "", "");
        return 1;
}

forward HasPlayerPermission(playerid, permType[], permNode, param1);
public HasPlayerPermission(playerid, permType[], permNode, param1)
{
  if( !strcmp(permType, "group", true) )
  {
	switch(permNode)
	{
	  case GPREM_leader: return pGroups[playerid][param1][permLeader];
      case GPREM_info: return pGroups[playerid][param1][permInfo];
      case GPREM_online: return pGroups[playerid][param1][permOnline];
      case GPREM_storage: return pGroups[playerid][param1][permStorage];
      case GPREM_offers: return pGroups[playerid][param1][permOffers];
      case GPREM_invite: return pGroups[playerid][param1][permInvite];
      case GPREM_vehicles: return pGroups[playerid][param1][permVehicles];
      case GPREM_special: return pGroups[playerid][param1][permSpecial];
      // -- Urzad group permission -- //
      case GPREM_urzad_dokumenty: return pGroups[playerid][param1][permUrzadDokumenty];
      case GPREM_urzad_drzwi: return pGroups[playerid][param1][permUrzadDrzwi];
	}
  }
  return false;
}

forward AddNewPlayerDescription(playerid, opisText[]);
public AddNewPlayerDescription(playerid, opisText[])
{
   new rows, fields;
   cache_get_data( rows, fields, mysqlHandle);
   if( rows == 1 )
   {
      new Query[456], descUid[10];
      cache_get_field_content(0, "uid", descUid);
      format( Query, sizeof(Query), "UPDATE `characters_descriptions` SET `last_used`='%d' WHERE `uid`='%d'", gettime(), strval(descUid));
      mysql_function_query(mysqlHandle, Query, false, "", "");
   }
   else
   {
      new Query[456], opisEscaped[150];
      mysql_real_escape_string(opisText, opisEscaped);
      format( Query, sizeof(Query), "INSERT INTO `characters_descriptions` (uid, owner, text, last_used) VALUES (null, '%d', '%s', '%d')", pInfo[playerid][uid], opisEscaped, gettime());
      mysql_function_query(mysqlHandle, Query, false, "", "");
   }
   
   pInfo[playerid][playerDesc] = CreateDynamic3DTextLabel(opisText, 0xC2A2DAFF, 0.0, 0.0, -0.7, 10.0, playerid, INVALID_VEHICLE_ID, 1);
   SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Twój aktualny opis zosta³ ustawiony.");
}

forward SetSavedDescription(playerid, opisIndex);
public SetSavedDescription(playerid, opisIndex)
{
  new tmpText[100], opisEscaped[150];
  cache_get_field_content(opisIndex, "text", tmpText);
  
  mysql_real_escape_string(tmpText, opisEscaped);
  new Query[256];
  format( Query, sizeof(Query), "SELECT * FROM `characters_descriptions` WHERE `text`='%s' AND `owner`='%d' ", opisEscaped, pInfo[playerid][uid]);
  mysql_function_query(mysqlHandle, Query, true, "AddNewPlayerDescription", "ds", playerid, tmpText);
}

forward PlayerSpawnChange(playerid, spawnIndex);
public PlayerSpawnChange(playerid, spawnIndex)
{
  new spawnUid[10], spawnType[10];
  cache_get_field_content(spawnIndex, "uid", spawnUid);
  cache_get_field_content(spawnIndex, "type", spawnType);
  
  if( GetPlayerSpawnType(playerid) == 2 )
  {
    new hotelUid;
	sscanf( pInfo[playerid][baseSpawn], "p<,>{d}d", hotelUid );
	
	DeleteRenterFromDoors(GetDoorsByUid(hotelUid), playerid);
  }
  
  new Query[456];
  format( Query, sizeof(Query), "UPDATE `characters` SET `baseSpawn`='%d,%d' WHERE uid='%d'", strval(spawnType), strval(spawnUid), pInfo[playerid][uid]);
  mysql_function_query(mysqlHandle, Query, false, "", "");
  
  format( pInfo[playerid][baseSpawn], 158, "%d,%d", strval(spawnType), strval(spawnUid) );
  
  ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("Zmiana miejsca spawnu"), "Twój aktualny spawn zosta³ zmieniony!", "Zamknij", "");
}

stock GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, &Float:z, Float:distance, Float:angle)
{
  new Float:a;
  GetPlayerPos(playerid, x, y, z);
  GetPlayerFacingAngle(playerid, a);
  a += angle;
  x += (distance * floatsin(-a, degrees));
  y += (distance * floatcos(-a, degrees));
}

stock SetupPlayerLastActivity(playerid)
{
   pInfo[playerid][lastActivity] = gettime();
}

stock AddPlayerMoney(playerid, money)
{
  pInfo[playerid][cash] += money;
  GivePlayerMoney(playerid, (pInfo[playerid][cash] - GetPlayerMoney(playerid)) );
  
  new Query[200];
  format( Query, sizeof(Query), "UPDATE `characters` SET `cash`=%d WHERE `uid`=%d", pInfo[playerid][cash], pInfo[playerid][uid]);
  mysql_function_query(mysqlHandle, Query, false, "", "");  
}

stock AddBankMoney(bankNumber, amount)
{
  foreach (new p : Player)
  { 
    if( pInfo[p][logged] == 1 && pInfo[p][bank] == bankNumber )
	{
	  pInfo[p][bankcash] += amount;
	  break;
	}
  }   
  
  new Query[200];
  format( Query, sizeof(Query), "UPDATE `characters` SET `bankcash`= (bankcash + %d) WHERE `bank`=%d", amount, bankNumber );
  mysql_function_query(mysqlHandle, Query, false, "", "");  
}

stock BuildPlayerAdnotations(playerid, injure=0)
{
   new formattedAdnotation[256],
       formattedAFK[64],
	   formattedStatus[128],
	   formattedName[100];
   // -- AFK format -- //
   if( pInfo[playerid][isAFK] )
   {
     format(formattedAFK, 128, "(AFK od: %s)\n", FormatTime(gettime() - pInfo[playerid][lastActivity]));
   }
   // -- Status format -- //
   if( pInfo[playerid][bw] > 0 )
   {
      if( strlen(formattedStatus) > 0 ) format( formattedStatus, sizeof(formattedStatus), "%s, nieprzytomny", formattedStatus );
	  else format( formattedStatus, sizeof(formattedStatus), "nieprzytomny" );
   }   
   if( pInfo[playerid][bwStatus] > 0 )
   {
     if( strlen(formattedStatus) > 0 ) format( formattedStatus, sizeof(formattedStatus), "%s, os³abiony", formattedStatus );
	 else format( formattedStatus, sizeof(formattedStatus), "os³abiony" );
   }
   // -- Ending formatting -- //
   new nickColor[32];
   
   format(nickColor, sizeof(nickColor), ParseNickColor(playerid));
   
   if( !isnull(formattedStatus) ) format( formattedStatus, sizeof(formattedStatus), "(%s)", formattedStatus );
   
   if( OnlineTimeInHours(pInfo[playerid][timeOnline]) < 15 ) format(formattedName, sizeof(formattedName), "%s (%d, %dh)", pInfo[playerid][name], playerid, OnlineTimeInHours(pInfo[playerid][timeOnline]));
   else format(formattedName, sizeof(formattedName), "%s (%d)", pInfo[playerid][name], playerid);
   
   format(formattedAdnotation, 256, "%s%s%s\n{FFFFFF}%s", formattedAFK, nickColor, formattedName, formattedStatus);
   // -- Create/update player 3d text label -- //
   if( !IsValidDynamic3DTextLabel(pInfo[playerid][tdnicklabel]) )
   {
     pInfo[playerid][tdnicklabel] = CreateDynamic3DTextLabel(formattedAdnotation, 0xFFFFFF74, 0.0, 0.0, 0.2, 10.0, playerid);
   }
   else
   {
	 if( injure == 1 )
	 {
       UpdateDynamic3DTextLabelText(pInfo[playerid][tdnicklabel], 0xFF5959FF, formattedAdnotation);
       defer StopPlayerInjureEffect(playerid);
	 }
	 else
	 {
       UpdateDynamic3DTextLabelText(pInfo[playerid][tdnicklabel], WHITE, formattedAdnotation);
	 }
   }
}

stock ParseNickColor(playerid)
{
  new tmpColor[32];
    
  if( pInfo[playerid][currentDuty] != -1 && !pInfo[playerid][isAFK] && pInfo[playerid][logged] == 1 )
  {
    new grId = pGroups[playerid][pInfo[playerid][currentDuty]][groupIndx];
	if( groups[grId][type] != 2 || groups[grId][type] != 4 || groups[grId][type] != 7 || groups[grId][type] != 9 ) return _:tmpColor;
	new doorsId = -1;
	if( GetPlayerVirtualWorld(playerid) > 0 && pInfo[playerid][hotelOutdoor] == 0 )
	{
	  doorsId = GetDoorsByUid(GetPlayerVirtualWorld(playerid));
	}
	
	if( doorsId > -1 )
	{
	  if( doors[doorsId][type] == 0 && doors[doorsId][owner] == groups[grId][grid] )
	  {
		  format(tmpColor, sizeof(tmpColor), "{%06x}", groups[pInfo[playerid][currentDuty]][gColor]);
		  return _:tmpColor;
	  }
	}
	switch( groups[grId][type] )
	{		  
		  case 2:
		  {
		    new vID = GetPlayerVehicleID(playerid);
			if( vID > -1 )
			{
			  if( sVehInfo[vID][ownertype] == 1 && groups[GetGroupByUid(sVehInfo[vID][owner])][type] == 2 ) 
			  {
			    format(tmpColor, sizeof(tmpColor), "{%06x}", groups[pInfo[playerid][currentDuty]][gColor]);
			    return _:tmpColor;
			  }
			}
		  }
		  
		  case 4,7,9:
		  {
		    format(tmpColor, sizeof(tmpColor), "{%06x}", groups[pInfo[playerid][currentDuty]][gColor]);
			return _:tmpColor;
		  }
		
	}
  }
  
  return _:tmpColor;
}

stock TextDrawUpdateForPlayer(playerid, Text:textdraw = Text:INVALID_TEXT_DRAW,  PlayerText:ptext = PlayerText:INVALID_TEXT_DRAW)
{
   if( textdraw != Text:INVALID_TEXT_DRAW )
   {
     TextDrawHideForPlayer(playerid, textdraw);
     TextDrawShowForPlayer(playerid, textdraw);
   }
   else
   {
	 PlayerTextDrawHide(playerid, ptext);
	 PlayerTextDrawShow(playerid, ptext);
   }
   return true;
}

stock HidePlayerDialog(playerid)
{
    ShowPlayerDialog(playerid,-1,DIALOG_STYLE_MSGBOX,"Egal","Egal","Egal","Egal");
}

stock AddPlayerPenalty(playerId, giverId, types, whyshorty[], whyy[])
{
  new pname[MAX_PLAYER_NAME+1], giname[MAX_PLAYER_NAME+1], giverUid;

  GetPlayerName(playerId, pname, sizeof(pname));
  new wshorty[64], wyy[326];
  if( giverId == INVALID_PLAYER_ID ){ giname = "System"; giverUid = 0; } else { GetPlayerName(giverId, giname, sizeof(giname)); giverUid = pInfo[giverId][uid]; }

  format(wshorty, sizeof(wshorty), "%s", whyshorty);
  format(wyy, sizeof(wyy), "%s", whyy);

  // -- Kicking, banning, mysql inserting -- //
  new msg[128], Query[256];
  switch( types )
  {
	case PENALTY_TYPE_WARN:
	{
	  format(msg, sizeof(msg), "{804040}[%s] Zosta³eœ upomniany z powodu '%s', (%s)", giname, wshorty, wyy );
	  format( Query, sizeof(Query), "INSERT INTO `penalties` (`obtainer`, `giver`, `type`, `wshort`, `why`, `giventime`) VALUES ('%d', '%d', '%d', '%s', '%s', '%s')", pInfo[playerId][uid], giverUid, types, wshorty, wyy, GetDateTimeToMySQL());
	  SendClientMessage(playerId, WHITE, msg);
	}
	case PENALTY_TYPE_KICK:
	{
	  format(msg, sizeof(msg), "{804040}[%s] Zosta³eœ wyrzucony z powodu '%s', (%s)", giname, wshorty, wyy );
	  format( Query, sizeof(Query), "INSERT INTO `penalties` (`obtainer`, `giver`, `type`, `wshort`, `why`, `giventime`) VALUES ('%d', '%d', '%d', '%s', '%s', '%s')", pInfo[playerId][uid], giverUid, types, wshorty, wyy, GetDateTimeToMySQL());
	  SendClientMessage(playerId, WHITE, msg);
	  Kick(playerId);
	}
  }
  mysql_function_query(mysqlHandle, Query, false, "", "");
}

GetXYInfrontOfPlayer(playerid,&Float:x,&Float:y,Float:Distance)
{
        new Float:r;
        if(IsPlayerInAnyVehicle(playerid)==0)GetPlayerFacingAngle(playerid,r);
        else GetVehicleZAngle(GetPlayerVehicleID(playerid),r);
        x += (Distance * floatsin(-r, degrees));
        y += (Distance * floatcos(-r, degrees));
        return 1;
}

stock GetPlayerByUid(puid)
{
  foreach (new p : Player)
  {
	if( pInfo[p][logged] == 1 && pInfo[p][uid] == puid )
	{
	   return p;
	}
  }
}

forward PrepareOpisGui(playerid);
public PrepareOpisGui(playerid)
{
  new rows, fields, oldDesc[1050];
  cache_get_data( rows, fields, mysqlHandle);
  if( rows > 0 )
  {
	for(new i=0;i<rows;i++)
	{
	  new tmpText[100];
      cache_get_field_content(i, "text", tmpText);
      format( oldDesc, 1050, "%s\n %d. %s", oldDesc, i+1, tmpText );
    }
  }
  else
  {
	format( oldDesc, 1050, "Brak opisów" );
  }
  
  new opisGui[1200], currentDesc[100];
  GetDynamic3DTextLabelText(pInfo[playerid][playerDesc], currentDesc);
  if( strlen(currentDesc) > 0 )
  {
	format( opisGui, 1200, "  {9A9CCD}%s{FFFFFF}\nUsuñ opis\n------------------------------------------------------------     (10 ostatnich opisów)\n%s", currentDesc, oldDesc );
  }
  else
  {
    format( opisGui, 1200, "Ustaw opis\n------------------------------------------------------------     (10 ostatnich opisów)\n%s", oldDesc );
  }
  ShowPlayerDialog(playerid, 40, DIALOG_STYLE_LIST, BuildGuiCaption("Postac - Opis"), opisGui, "Wybierz", "Zamknij");
}