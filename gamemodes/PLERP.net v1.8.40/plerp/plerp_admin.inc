// -- /astrefa -- //
new Float:aStrefaPos1[MAX_PLAYERS][3];
new Float:aStrefaPos2[MAX_PLAYERS][3];
new aStrefaIcon1[MAX_PLAYERS];
new aStrefaIcon2[MAX_PLAYERS];

// -- ADMIN PANEL -- BARTEK -- //
stock KickEx(playerid, targetid, reason[])
{
        new string[512], ttime;
        ttime = gettime();
        format(string, sizeof(string), "INSERT INTO `penalties` SET `obtainer`='%d', `giver`='%d', `type`='%d', `why`='%s', `giventime`='%d'",
                                                                        pInfo[targetid][uid], pInfo[playerid][uid], PENALTY_TYPE_KICK, reason, ttime);
        mysql_function_query(mysqlHandle, string, false, "", "");
        format(string, sizeof(string), "PLERP.net: Zosta³eœ wyrzucony z serwera przez %s. Powód: %s.", pInfo[playerid][name], reason);
        SendClientMessage(targetid, COLOR_RED, string);
        defer KickTimer[500](targetid);
        return 1;
}
 
stock BanPlayer(playerid, targetid, reason[], endtime)
{
        new string[512], ttime;
        ttime = gettime();
        format(string, sizeof(string), "INSERT INTO `penalties` SET `obtainer`='%d', `giver`='%d', `type`='%d', `why`='%s', `giventime`='%d', `endtime`='%d'",
                                                                        pInfo[targetid][uid], pInfo[playerid][uid], PENALTY_TYPE_BAN, reason, ttime, endtime);
        mysql_function_query(mysqlHandle, string, false, "", "");
        format(string, sizeof(string), "PLERP.net: Zosta³eœ zbanowany przez %s. Powód: %s.", pInfo[playerid][name], reason);
        SendClientMessage(targetid, COLOR_RED, string);
        defer KickTimer[500](targetid);
        return 1;
}
 
stock WarnPlayer(playerid, targetid, reason[])
{
        new string[512], ttime, endtime;
        ttime = gettime();
        endtime = gettime() + 7*24*(60*60);
        format(string, sizeof(string), "INSERT INTO `penalties` SET `obtainer`='%d', `giver`='%d', `type`='%d', `why`='%s', `giventime`='%d', `endtime`='%d'",
                                                                        pInfo[targetid][uid], pInfo[playerid][uid], PENALTY_TYPE_WARN, reason, ttime, endtime);
        mysql_function_query(mysqlHandle, string, false, "", "");
        format(string, sizeof(string), "PLERP.net: Otrzyma³eœ warna od %s. Powód: %s.", pInfo[playerid][name], reason);
        SendClientMessage(targetid, COLOR_RED, string);
        return 1;
}
 
stock BlockOOC(playerid, targetid, reason[], endtime)
{
        new string[512], ttime;
        ttime = gettime();
        format(string, sizeof(string), "INSERT INTO `penalties` SET `obtainer`='%d', `giver`='%d', `type`='%d', `why`='%s', `giventime`='%d', `endtime`='%d'",
                                                                        pInfo[targetid][uid], pInfo[playerid][uid], PENALTY_TYPE_BLOCK_OOC, reason, ttime, endtime);
        mysql_function_query(mysqlHandle, string, false, "", "");
        format(string, sizeof(string), "PLERP.net: Admin %s zablokowa³ Ci mo¿liwoœæ pisania na czacie OOC. Powód: %s.", pInfo[playerid][name], reason);
        SendClientMessage(targetid, COLOR_RED, string);
}
 
stock BlockSprint(playerid, targetid, reason[], endtime)
{
        new string[512], ttime;
        ttime = gettime();
        format(string, sizeof(string), "INSERT INTO `penalties` SET `obtainer`='%d', `giver`='%d', `type`='%d', `why`='%s', `giventime`='%d', `endtime`='%d'",
                                                                        pInfo[targetid][uid], pInfo[playerid][uid], PENALTY_TYPE_BLOCK_SPRINT, reason, ttime, endtime);
        mysql_function_query(mysqlHandle, string, false, "", "");
        format(string, sizeof(string), "PLERP.net: Admin %s zablokowa³ Ci mo¿liwoœc biegania. Powód: %s.", pInfo[playerid][name], reason);
        SendClientMessage(targetid, COLOR_RED, string);
}
 
stock BlockFight(playerid, targetid, reason[], endtime)
{
        new string[512], ttime;
        ttime = gettime();
        format(string, sizeof(string), "INSERT INTO `penalties` SET `obtainer`='%d', `giver`='%d', `type`='%d', `why`='%s', `giventime`='%d', `endtime`='%d'",
                                                                        pInfo[targetid][uid], pInfo[playerid][uid], PENALTY_TYPE_BLOCK_FIGHT, reason, ttime, endtime);
        mysql_function_query(mysqlHandle, string, false, "", "");
        format(string, sizeof(string), "PLERP.net: Admin %s zablokowa³ Ci mo¿liwoœæ bicia. Powód: %s.", pInfo[playerid][name], reason);
        SendClientMessage(targetid, COLOR_RED, string);
}
 
stock AdminJail(playerid, targetid, reason[], endtime)
{
        new string[512], ttime;
        ttime = gettime();
        format(string, sizeof(string), "INSERT INTO `penalties` SET `obtainer`='%d', `giver`='%d', `type`='%d', `why`='%s', `giventime`='%d', `endtime`='%d'",
                                                                        pInfo[targetid][uid], pInfo[playerid][uid], PENALTY_TYPE_AJ, reason, ttime, endtime);
        mysql_function_query(mysqlHandle, string, false, "", "");
        SetPlayerVirtualWorld(targetid, pInfo[targetid][uid]);
        SetPlayerPos(targetid, 1770.73, -2411.71, 13.55);
        pInfo[playerid][AJ_endtime] = endtime;
        pInfo[playerid][AJ_timer] = repeat CheckAdminJail(playerid);
        format(string, sizeof(string), "PLERP.net: Admin %s wrzuci³ Ciê do Admin Jaila. Powód: %s.", pInfo[playerid][name], reason);
        SendClientMessage(targetid, COLOR_RED, string);
}
 
/// Komendy
 
COMMAND:ban(playerid, params[])
{      
        new targetid, string[64], gIDD;
       
        gIDD = GetGroupByUid(1);       
        if(!HasPlayerPermission(playerid, "group", GPREM_special, gIDD)) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie posiadasz uprawnieñ.");
 
        if(sscanf(params, "d", targetid))
        {
                SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Wpisz /ban [ID gracza]");
        } else
        {
                if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Ten gracz nie jest online.");
                format(string, sizeof(string), "Ban -> %s", pInfo[targetid][name]);
                pInfo[playerid][t_dialogtmp2] = targetid;
                pInfo[playerid][t_dialogtmp1] = 1;
                ShowPlayerDialog(playerid, 98, DIALOG_STYLE_LIST, string, "24h\n48h\nTydzieñ\nDwa tygodnie\nMiesi¹c\nCztery miesi¹ce\nNa zawsze", "Wybierz", "Anuluj");
        }
        return 1;
}
 
COMMAND:kick(playerid, params[])
{      
        new targetid, string[64], gIDD;
       
        gIDD = GetGroupByUid(1);       
        if(!HasPlayerPermission(playerid, "group", GPREM_special, gIDD)) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie posiadasz uprawnieñ.");
 
        if(sscanf(params, "d", targetid))
        {
                SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Wpisz /kick [ID gracza]");
        } else
        {
                if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Ten gracz nie jest online.");
                format(string, sizeof(string), "Kick -> %s", pInfo[targetid][name]);
                pInfo[playerid][t_dialogtmp2] = targetid;
                ShowPlayerDialog(playerid, 100, DIALOG_STYLE_INPUT, string, "Wpisz powód wyrzucenia gracza z serwera.", "Wyrzuæ", "Anuluj");
        }
        return 1;
}
 
COMMAND:warn(playerid, params[])
{
        new targetid, string[64], gIDD;
       
        gIDD = GetGroupByUid(1);       
        if(!HasPlayerPermission(playerid, "group", GPREM_special, gIDD)) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie posiadasz uprawnieñ.");
 
        if(sscanf(params, "d", targetid))
        {
                SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Wpisz /warn [ID gracza]");
        } else
        {
                if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Ten gracz nie jest online.");
                format(string, sizeof(string), "Warn -> %s", pInfo[playerid][name]);
                pInfo[playerid][t_dialogtmp2] = targetid;
                ShowPlayerDialog(playerid, 101, DIALOG_STYLE_INPUT, string, "Wpisz powód nadania warna graczowi.", "Akceptuj", "Anuluj");
        }
        return 1;
}
 
COMMAND:spec(playerid, params[])
{
        new targetid, string[128], gIDD;
       
        gIDD = GetGroupByUid(1);       
        if(!HasPlayerPermission(playerid, "group", GPREM_special, gIDD)) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie posiadasz uprawnieñ.");
 
        if(sscanf(params, "d", targetid))
        {
                if(!strcmp(params, "stop", true) && pInfo[playerid][t_spec] == 1)
                {
                        TogglePlayerSpectating(playerid, 0);
                        stop pInfo[playerid][spec_timer];
                        TextDrawDestroy(pInfo[playerid][spec_td_player]);
                        TextDrawDestroy(pInfo[playerid][spec_td_id]);
                        TextDrawDestroy(pInfo[playerid][spec_td_hp]);
                        TextDrawDestroy(pInfo[playerid][spec_td_armor]);
                        return 1;
                }
                SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Wpisz /spec [ID gracza]");
        } else
        {
                if(playerid == targetid) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie mo¿esz podgl¹daæ samego siebie.");
                if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Ten gracz nie jest online.");
                TogglePlayerSpectating(playerid, 1);
                PlayerSpectatePlayer(playerid, targetid);
                pInfo[playerid][spec_timer] = repeat UpdateSpec(playerid, targetid);
                pInfo[playerid][t_spec] = 1;
                format(string, sizeof(string), "PLERP.net: Podgl¹dasz gracza %s.", pInfo[targetid][name]);
                SendClientMessage(playerid, COLOR_GREEN, string);
        }
        return 1;
}
 
COMMAND:aj(playerid, params[])
{
        new targetid, gIDD;
       
        gIDD = GetGroupByUid(1);
        if(!HasPlayerPermission(playerid, "group", GPREM_special, gIDD)) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie posiadasz uprawnieñ.");
 
        if(sscanf(params, "d", targetid))
        {
                SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Wpisz /aj [ID gracza]");
        } else
        {
                if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Ten gracz nie jest online");
                pInfo[playerid][t_dialogtmp2] = targetid;
                pInfo[playerid][t_dialogtmp1] = 2;
                ShowPlayerDialog(playerid, 98, DIALOG_STYLE_LIST, "Admin Jail", "30min\n1h\n2h\n6h\n24h", "Wybierz", "Anuluj");
        }
        return 1;
}
 
COMMAND:slap(playerid, params[])
{
        new targetid, string[128], gIDD;
       
        gIDD = GetGroupByUid(1);       
        if(!HasPlayerPermission(playerid, "group", GPREM_special, gIDD)) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie posiadasz uprawnieñ.");
 
        if(sscanf(params, "d", targetid))
        {
                SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Wpisz /slap [ID gracza]");
        } else
        {
                if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Ten gracz nie jest online.");
                new Float: Pos[3];
                GetPlayerPos(targetid, Pos[0], Pos[1], Pos[2]);
                SetPlayerPos(targetid, Pos[0], Pos[1], Pos[2] + 5.0);
                format(string, sizeof(string), "PLERP.net: Zeslapowa³eœ gracza %s o 5 jednostek do góry.", pInfo[targetid][name]);
                SendClientMessage(playerid, COLOR_GREEN, string);
                format(string, sizeof(string), "PLERP.net: Zosta³es zeslapowany przez admina %s o 5 jednostek do góry.", pInfo[playerid][name]);
                SendClientMessage(targetid, COLOR_RED, string);
        }
        return 1;
}
 
COMMAND:tp(playerid, params[])
{
        new targetid, targetid2, string[128], gIDD;
       
        gIDD = GetGroupByUid(1);       
        if(!HasPlayerPermission(playerid, "group", GPREM_special, gIDD)) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie posiadasz uprawnieñ.");
 
        if(sscanf(params, "d", targetid))
        {
                SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Wpisz /tp [ID 1 gracza] [ID 2 gracza]");
        } else
        {
                if(!IsPlayerConnected(targetid) || !IsPlayerConnected(targetid2)) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Jeden z graczy nie jest online.");
                if(targetid == targetid2) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie mo¿esz teleportowaæ gracza samego do siebie.");
                new Float: Pos[3];
                GetPlayerPos(targetid2, Pos[0], Pos[1], Pos[2]);
                SetPlayerPos(targetid, Pos[0], Pos[1] + 2.0, Pos[2]);
                OnPlayerVirtualWorldChange(targetid, GetDoorsByUid(GetPlayerVirtualWorld(targetid)));
                format(string, sizeof(string), "PLERP.net: Zosta³eœ teleportowany do gracza %s przez admina %s.", pInfo[targetid2][name], pInfo[playerid][name]);
                SendClientMessage(targetid, COLOR_GREEN, string);
                format(string, sizeof(string), "PLERP.net: Gracz %s zosta³ do Ciebie przeteleportowany przez admina %s.", pInfo[targetid][name], pInfo[playerid][name]);
                SendClientMessage(targetid2, COLOR_GREEN, string);
                format(string, sizeof(string), "PLERP.net: Teleportowa³eœ gracza %s do gracza %s.", pInfo[targetid][name], pInfo[targetid2][name]);
                SendClientMessage(playerid, COLOR_GREEN, string);
        }
        return 1;
}
               
COMMAND:zycie(playerid, params[])
{
        new targetid, value, string[128], gIDD;
       
        gIDD = GetGroupByUid(1);       
        if(!HasPlayerPermission(playerid, "group", GPREM_special, gIDD)) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie posiadasz uprawnieñ.");
 
        if(sscanf(params, "dd", targetid, value))
        {
                SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Wpisz /zycie [ID gracza] [Wartosc]");
        } else
        {
                if(value < 0 || value > 100) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: B³êdna wartoœæ. [0-100]");
               
                pInfo[playerid][health] = value;
                SetPlayerHealth(targetid, value);
                format(string, sizeof(string), "PLERP.net: Admin %s nada³ Ci %d jednostek ¿ycia.", pInfo[playerid][name], value);
                SendClientMessage(targetid, COLOR_GREEN, string);
                format(string, sizeof(string), "PLERP.net: Nada³eœ %d jednostek ¿ycia graczowi %s.", value, pInfo[targetid][name]);
                SendClientMessage(playerid, COLOR_GREEN, string);
        }
        return 1;
}
 
COMMAND:armor(playerid, params[])
{
        new targetid, value, string[128], gIDD;
       
        gIDD = GetGroupByUid(1);
        if(!HasPlayerPermission(playerid, "group", GPREM_special, gIDD)) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie posiadasz uprawnieñ.");
       
        if(sscanf(params, "dd", targetid, value))
        {
                SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Wpisz /armor [ID gracza] [Wartosc]");
        } else
        {
                if(value < 0 || value > 100) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: B³êdna wartoœæ. [0-100]");
               
                pInfo[playerid][armor] = value;
                SetPlayerArmour(playerid, value);
                format(string, sizeof(string), "PLERP.net: Admin %s nada³ Ci %d jednostek pancerza.", pInfo[playerid][name], value);
                SendClientMessage(targetid, COLOR_GREEN, string);
                format(string, sizeof(string), "PLERP.net: Nada³es %d jednostek pancerza graczowi %s.", value, pInfo[targetid][name]);
                SendClientMessage(playerid, COLOR_GREEN, string);
        }
        return 1;
}
               
COMMAND:acp(playerid, params[])
{
        #pragma unused params
        new gIDD;
        gIDD = GetGroupByUid(1);       
        if(!HasPlayerPermission(playerid, "group", GPREM_special, gIDD)) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie posiadasz uprawnieñ.");
 
        ShowPlayerDialog(playerid, 102, DIALOG_STYLE_LIST, "Admin Control Panel", "Podstawowe komendy\nBlokady\nDodatki", "Wybierz", "Anuluj");
        return 1;
}

COMMAND:astrefa(playerid, params[])
{
   #pragma unused params
   new grSlot = IsPlayerInGroupType(playerid, 0);
   if( grSlot >= 0 && HasPlayerPermission(playerid, "group", GPREM_special, pGroups[playerid][grSlot][groupIndx]) )
   {
     new cmdAlias[64];
	 if( !sscanf(params, "s[64]", cmdAlias) )
	 {
	   if( !strcmp(cmdAlias, "addpoint1",  false) )
	   {
	     GetPlayerPos(playerid, aStrefaPos1[playerid][0], aStrefaPos1[playerid][1], aStrefaPos1[playerid][2]);
		 if( IsValidDynamicMapIcon(aStrefaIcon1[playerid]) ) DestroyDynamicMapIcon(aStrefaIcon1[playerid]);
		 aStrefaIcon1[playerid] = CreateDynamicMapIcon(aStrefaPos1[playerid][0], aStrefaPos1[playerid][1], aStrefaPos1[playerid][2], 0, 0xFF4137FF, GetPlayerVirtualWorld(playerid), -1, playerid);
		 SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Pozycja pierwsza strefy zosta³a zapisana i oznaczona na mapie.");
	   }
	   
	   if( !strcmp(cmdAlias, "addpoint2",  false) )
	   {
	     GetPlayerPos(playerid, aStrefaPos2[playerid][0], aStrefaPos2[playerid][1], aStrefaPos2[playerid][2]);
		 if( IsValidDynamicMapIcon(aStrefaIcon2[playerid]) ) DestroyDynamicMapIcon(aStrefaIcon2[playerid]);
		 aStrefaIcon2[playerid] = CreateDynamicMapIcon(aStrefaPos2[playerid][0], aStrefaPos2[playerid][1], aStrefaPos2[playerid][2], 0, 0xFF4137FF, GetPlayerVirtualWorld(playerid), -1, playerid);
		 SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Pozycja druga strefy zosta³a zapisana i oznaczona na mapie.");
	   }
	   
	   if( !strcmp(cmdAlias, "resetpoint",  false) )
	   {
	     aStrefaPos1[playerid][0] = 0;
		 aStrefaPos1[playerid][1] = 0;
		 aStrefaPos1[playerid][2] = 0;
		 aStrefaPos2[playerid][0] = 0;
		 aStrefaPos2[playerid][1] = 0;
		 aStrefaPos2[playerid][2] = 0;
		 if( IsValidDynamicMapIcon(aStrefaIcon1[playerid]) ) DestroyDynamicMapIcon(aStrefaIcon1[playerid]);
		 if( IsValidDynamicMapIcon(aStrefaIcon2[playerid]) ) DestroyDynamicMapIcon(aStrefaIcon2[playerid]);
	   }
	   
	   if( !strcmp(cmdAlias, "build",  false) )
	   {
	     if( IsValidDynamicMapIcon(aStrefaIcon1[playerid]) && IsValidDynamicMapIcon(aStrefaIcon2[playerid]) )
		 {
		   ShowPlayerDialog(playerid, 70, DIALOG_STYLE_INPUT, BuildGuiCaption("Tworzenie strefy"), "Aby stworzyæ strefê musisz podaæ kolejno dane:\n   {FFFFFF}[UID GRUPY],[DODATKOWY_TYP]", "Stwórz", "Zamknij");
		 }
		 else
		 {
		   SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Aby stworzyæ strefê musisz wyznaczyæ jej dwa punkty tworz¹ce przek¹tn¹.");
		 }
	   }
	 }
	 else SendClientMessage(playerid, WHITE, "{999A9C}PLERP.net: /astrefa [addpoint1/addpoint2/resetpoint/build] ");
   }
   else return 1;
   
   return 1;
}

COMMAND:adelbus(playerid, params[])
{
    new grSlot = IsPlayerInGroupType(playerid, 0);
	if( grSlot == -1 || !HasPlayerPermission(playerid, "group", GPREM_special, pGroups[playerid][grSlot][groupIndx])) return 1;
	
	new string[60], IDX = -1, liczba;
	
	foreach (new idee : Bus)
	{
		liczba++;
		if(liczba == strval(params))
		{
			IDX = idee;
			break;
		}
	}
	if(IDX == -1) return SendClientMessage(playerid, -1, "Niepoprawny przystanek");
	if(!Bus[IDX][uid]) return SendClientMessage(playerid, -1, "Niepoprawny przystanek");
	format(string, sizeof(string), "DELETE FROM `plerp_buss` WHERE `uid` = %i", Bus[IDX][uid]);
	mysql_function_query(mysqlHandle, string, false, "", "");
	Iter_Remove(Bus, IDX);
	Bus[IDX][pos_x] = 0.00;
	Bus[IDX][pos_y] = 0.00;
	Bus[IDX][pos_z] = 0.00;
	Bus[IDX][pos_rz] = 0.00;
	Bus[IDX][name] = 0;
	Bus[IDX][uid] = 0;
	DestroyDynamicObject(Bus[IDX][idobject]);
	DestroyDynamic3DTextLabel(Bus[IDX][label]);
	liczba = 0;
	foreach (new i : Bus)
	{
		liczba++;
		format(string, sizeof(string), "Przystanek \n%s \nnr. %i", Bus[i][name], liczba);
		UpdateDynamic3DTextLabelText(Bus[i][label], COLOR_GREY, string);
	}
	SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Pomyœlnie wyjeba³eœ przystanek");
	return 1;
}
COMMAND:abalon(playerid, params[])
{
  new grSlot = IsPlayerInGroupType(playerid, 0);
  if( grSlot >= 0 && HasPlayerPermission(playerid, "group", GPREM_special, pGroups[playerid][grSlot][groupIndx]) )
  {
    if( IsValidDynamicArea(balonik[1]) )
	{
	   DestroyDynamicArea(balonik[1]);
	   SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Balon usuniêty.");
	}
	else
	{
	   if( isnull(params) || !IsNumeric(params) ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /abalon [id obiektu]");
	   if( strval(params) < 0 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /abalon [id obiektu]");
	   if( !IsValidDynamicObject(strval(params)) || objects[strval(params)][model] != 19335 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /abalon [id obiektu]");
	   balonik[0] = strval(params);
	   new Float:bX, Float:bY, Float:bZ;
	   GetDynamicObjectPos(balonik[0], bX, bY, bZ);
	   balonik[1] = CreateDynamicCircle(bX, bY, 5.0, GetPlayerVirtualWorld(playerid));
	   AttachDynamicAreaToObject(balonik[1], balonik[0]);
	}
  }
  
  return 1;
}

COMMAND:unbw(playerid, params[])
{
        new targetid, string[128], gIDD;
        gIDD = GetGroupByUid(1);
        if(!HasPlayerPermission(playerid, "group", GPREM_special, gIDD)) return 1;
       
        if(sscanf(params, "d", targetid))
        {
                SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Wpisz /unbw [ID gracza]");
        } 
		else
        {
                if(pInfo[targetid][bw] == 0) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Ten gracz nie posiada BW.");
               
                pInfo[targetid][bw] = 0;
                stop pInfo[targetid][bw_timer];
                PlayerTextDrawDestroy(targetid, pInfo[targetid][td_bw]);
                PlayerTextDrawDestroy(targetid, bwTime);
                TogglePlayerControllable(targetid, 1);
				pInfo[targetid][health] = 5.0;
                SetPlayerHealth(targetid, 5.0);
                SetCameraBehindPlayer(targetid);
                ClearAnimations(targetid);
                BuildPlayerAdnotations(playerid);
				
                format(string, sizeof(string), "PLERP.net: Zdj¹³eœ BW graczowi %s.", pInfo[targetid][name]);
                SendClientMessage(playerid, COLOR_GREEN, string);
                format(string, sizeof(string), "PLERP.net: Admin %s zdj¹³ Ci BW.", pInfo[playerid][name]);
                SendClientMessage(targetid, COLOR_GREEN, string);
        }
        return 1;
}
 
COMMAND:unaj(playerid, params[])
{
        new targetid, string[128], gIDD;
        gIDD = GetGroupByUid(1);
        if(!HasPlayerPermission(playerid, "group", GPREM_special, gIDD)) return 1;
       
        if(sscanf(params, "d", targetid))
        {
                SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Wpisz /unaj [ID gracza]");
        } else
        {
                if(pInfo[targetid][AJ_endtime] == 0) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Ten gracz nie jest w Admin Jail'u.");
               
                pInfo[targetid][AJ_endtime] = 0;
                stop pInfo[targetid][AJ_timer];
                SetPlayerVirtualWorld(targetid, 0);
                PlayerTextDrawDestroy(targetid, ajTime);
                SpawnPlayer(targetid);
               
                format(string, sizeof(string), "PLERP.net: Admin %s wypuœci³ Ciê z Admin Jail'a.", pInfo[playerid][name]);
                SendClientMessage(targetid, COLOR_GREEN, string);
                format(string, sizeof(string), "PLERP.net: Wypuœci³eœ %s z Admin Jail'a.", pInfo[targetid][name]);
                SendClientMessage(playerid, COLOR_GREEN, string);
        }
        return 1;
}

COMMAND:abus(playerid, params[10])
{		

			new grSlot = IsPlayerInGroupType(playerid, 0);
			if( grSlot == -1 || !HasPlayerPermission(playerid, "group", GPREM_special, pGroups[playerid][grSlot][groupIndx])) return 1;
			
			new string[150], Float:pos[4], i = Iter_Free(Bus);
			if(sscanf(params, "p<;>s[150]f", string, pos[3])) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /abus [nazwa];[rot_z]");
			SendClientMessage(playerid, -1, "test");
			GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
			format(Bus[i][name], 30, "%s", string);
			Bus[i][pos_x] = pos[0];			
			Bus[i][pos_y] = pos[1];			
			Bus[i][pos_z] = pos[2];
			Bus[i][pos_rz] = pos[3];
			Iter_Add(Bus, i);
			Bus[i][label] = CreateDynamic3DTextLabel(string, 0xD94100FF, Bus[i][pos_x], Bus[i][pos_y], Bus[i][pos_z], 10);
			Bus[i][idobject] = CreateDynamicObject(1257, Bus[i][pos_x], Bus[i][pos_y], Bus[i][pos_z], 0, 0, Bus[i][pos_rz]);
			new liczba;
			foreach (new ii : Bus)
			{
				liczba++;
				format(string, sizeof(string), "Przystanek \n%s \nnr. %i", Bus[ii][name], liczba);
				UpdateDynamic3DTextLabelText(Bus[ii][label], 0xD94100FF, string);
			}
			SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Pomyœlnie stworzy³eœ przystanek.");
			format(string, sizeof(string), "INSERT INTO `plerp_buss` SET `pos_x` = %f, `pos_y` = %f, `pos_z` = %f, `rot_z` = %f, `name` = '%s'", pos[0], pos[1], pos[2], pos[3], Bus[i][name]);
			mysql_function_query(mysqlHandle, string, true, "ReturnBusUID", "i", i);
			return 1;

}
forward ReturnBusUID(IDX);
public ReturnBusUID(IDX)
{
	Bus[IDX][uid] = mysql_insert_id();
}