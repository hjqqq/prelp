stock FindGroupByUID(gUid)
{
  foreach (new g : Groups)
  {
	if( groups[g][grid] == gUid ) return g;
  }
  return 0;
}

stock GetPlayerGroupFreeSlot(playerid)
{
  for(new i=0;i<5;i++)
  {
	if( pGroups[playerid][i][groupUid] == 0 ) return i;
  }
  return -1;
}

stock IsPlayerInGroup(playerid, groupId)
{
  foreach (new worker : GroupWorkers[groupId])
  {
	if( worker == playerid ) return 1;
  }
  
  return 0;
}

stock IsPlayerInGroupType(playerid, groupType)
{
  for(new i=0;i<5;i++)
  {
    if(groups[pGroups[playerid][i][groupIndx]][type] == groupType) return i;
  }
  return -1;
}

stock GetBlankGroupPermissions()
{
   new str[100] = "0-1-1-0-0-0-0-0";
   return str;
}

stock ParsePlayerGroupPermission(playerid, grSlot)
{
          // -- permission parse -- //
		 new permToGroupLeader, permToGroupInfo, permToGroupOnline, permToGroupStorage, permToGroupOffers[20], permToGroupInvite[20], permToGroupVehicles[20], permToGroupSpecial[20];
	     sscanf(pGroups[playerid][grSlot][permission], "p<->dddds[20]s[20]s[20]s[20]", permToGroupLeader, permToGroupInfo, permToGroupOnline, permToGroupStorage, permToGroupOffers, permToGroupInvite, permToGroupVehicles, permToGroupSpecial);
	     
	     // -- basic permission parse -- //
		 pGroups[playerid][grSlot][permLeader] = !!permToGroupLeader; 
	     pGroups[playerid][grSlot][permInfo] = !!permToGroupInfo;
	     pGroups[playerid][grSlot][permOnline] = !!permToGroupOnline;
	     pGroups[playerid][grSlot][permStorage] = !!permToGroupStorage;
	     
	     // -- group offers permission parse -- //
         pGroups[playerid][grSlot][permOffers] = !!strval(permToGroupOffers);

	     // -- group invite permission parse -- //
         pGroups[playerid][grSlot][permInvite] = !!strval(permToGroupInvite);
	     
	     // -- group vehicles permission parse -- //
	     pGroups[playerid][grSlot][permVehicles] = !!strval(permToGroupVehicles);
	     
	     // -- group special permission parse -- //
	     pGroups[playerid][grSlot][permSpecial] = !!strval(permToGroupSpecial);
}

stock SetupPlayerDuty(playerid, grSlot)
{
  if( grSlot == -1 && pInfo[playerid][currentDuty] == -1  ) return;
  if( grSlot == -1 )
  {
	if( groups[pGroups[playerid][pInfo[playerid][currentDuty]][groupIndx]][type] == 0 )
	{
	  format( pInfo[playerid][tdnick], 100, "%s (%d)", pInfo[playerid][tempG0Name], playerid);
	  format( pInfo[playerid][name], MAX_PLAYER_NAME+1, pInfo[playerid][tempG0Name] );
	  
	  strreplace(pInfo[playerid][tempG0Name], ' ', '_');
	  SetPlayerName(playerid, pInfo[playerid][tempG0Name]);
	}
	
	new Query[400];
    format( Query, 400, "UPDATE `worker_profile` SET `duty_time`='%d' WHERE `uid`='%d' AND `group`='%d'", pGroups[playerid][pInfo[playerid][currentDuty]][dutyTime], pInfo[playerid][uid], pGroups[playerid][pInfo[playerid][currentDuty]][groupUid]);
	mysql_function_query(mysqlHandle, Query, false, "", "");
	pInfo[playerid][currentDuty] = -1;
	PlayerTextDrawHide(playerid, dutyBar[0]);
	PlayerTextDrawHide(playerid, dutyBar[1]);
  }
  else
  {
    pInfo[playerid][currentDuty] = grSlot;
    new tmpstr[64];
    format(tmpstr, 64, "%dm %ds", pGroups[playerid][pInfo[playerid][currentDuty]][dutyTime]/60, pGroups[playerid][pInfo[playerid][currentDuty]][dutyTime]%60);

    PlayerTextDrawHide(playerid, dutyBar[1]);
	PlayerTextDrawSetString(playerid, dutyBar[1], tmpstr);
	PlayerTextDrawShow(playerid, dutyBar[1]);
	PlayerTextDrawShow(playerid, dutyBar[0]);
	
	if( groups[pGroups[playerid][grSlot][groupIndx]][type] == 0 )
	{
	  format( pInfo[playerid][tempG0Name], MAX_PLAYER_NAME+1, pInfo[playerid][name] );
	  format( pInfo[playerid][tdnick], 100, "%s (%d)", pInfo[playerid][name], playerid);
	  format( pInfo[playerid][name], MAX_PLAYER_NAME+1, pInfo[playerid][gname] );
	  
	  SetPlayerName(playerid, pInfo[playerid][gname]);
	}

  }
  BuildPlayerAdnotations(playerid);
}

stock BuildGroupGUI(playerid, groupId)
{
  new groupSlot = GetGroupPlayerSlot(playerid, groupId);
  new string[78], string2[328], i;
  pInfo[playerid][lastGroupGuiId] = groupId;
  format(string, 78, "Grupy - {%06x}%s {bebebe}(uid: %d)        ", groups[groupId][gColor], groups[groupId][name], groups[groupId][grid]);
  if( HasPlayerPermission(playerid, "group", GPREM_info, groupSlot) == 1 ) { format(string2, 128, "%s\n", "Informacje"); format(lastGroupGuiOptions[playerid][i], 34, "info"); i++;}
  format(string2, 128, "%s\n%s", string2, "S³u¿ba"); format(lastGroupGuiOptions[playerid][i], 34, "duty"); i++;
  if( HasPlayerPermission(playerid, "group", GPREM_online, groupSlot) == 1 ) { format(string2, 128, "%s\n%s", string2, "Online"); format(lastGroupGuiOptions[playerid][i], 34, "online"); i++;}
  if( HasPlayerPermission(playerid, "group", GPREM_storage, groupSlot) == 1 ) { format(string2, 128, "%s\n%s", string2, "Magazyn"); format(lastGroupGuiOptions[playerid][i], 34, "storage"); i++;}
  if( HasPlayerPermission(playerid, "group", GPREM_offers, groupSlot) == 1 ) { format(string2, 128, "%s\n%s", string2, "Oferty"); format(lastGroupGuiOptions[playerid][i], 34, "offers"); i++;}
  if( HasPlayerPermission(playerid, "group", GPREM_invite, groupSlot) == 1 ) { format(string2, 128, "%s\n%s", string2, "Zaproœ/Wyrzuæ"); format(lastGroupGuiOptions[playerid][i], 34, "invite"); i++;}
  if( HasPlayerPermission(playerid, "group", GPREM_vehicles, groupSlot == 1) ) { format(string2, 128, "%s\n%s", string2, "Pojazdy"); format(lastGroupGuiOptions[playerid][i], 34, "vehicles"); i++;}
  format(string2, 128, "%s\n%s", string2, "Pomoc"); format(lastGroupGuiOptions[playerid][i], 34, "help"); i++;
  if( HasPlayerPermission(playerid, "group", GPREM_special, groupSlot) == 1 ) { format(string2, 128, "%s\n%s", string2, "---------------\nSpecjalne"); format(lastGroupGuiOptions[playerid][i], 34, "special"); i++;}
  ShowPlayerDialog(playerid, 9, DIALOG_STYLE_LIST, BuildGuiCaption(string), string2, "Wybierz", "Zamknij");
}

stock RebuildPlayerGroupsSlots(playerid)
{
  new bool:anyChanges;
  here:
  anyChanges = false;
  for(new i;i<5;i++)
  {
	if( i != 4 )
	{
      if( pGroups[playerid][i][groupUid] == 0 && pGroups[playerid][i+1][groupUid] != 0 )
      {
		anyChanges = true;
        pGroups[playerid][i][groupUid] = pGroups[playerid][i+1][groupUid];
        pGroups[playerid][i][groupIndx] = pGroups[playerid][i+1][groupIndx];
        format(pGroups[playerid][i][rank], 64, "%s", pGroups[playerid][i+1][rank]);
        format(pGroups[playerid][i][permission], 64, "%s", pGroups[playerid][i+1][permission]);
      }
    }
  }
  if( anyChanges ) goto here;
  
  return 1;
}

stock GetGroupPlayerSlot(playerid, groupIndex)
{
  for(new i=0; i<5; i++)
  {
	 if(pGroups[playerid][i][groupIndx] == groupIndex) return i;
  }
  return -1;
}

stock GetGroupByUid(grUid)
{
  foreach (new g : Groups)
  {
	if( groups[g][grid] == grUid ) return g;
  }
  return -1;
}

stock FindEmptyGroupSlot()
{
  new i;
  for(i = 0; i<sizeof(groups); i++)
  {
	if( groups[i][grid] == 0 ) break;
  }
  return i;
}

stock GetGroupLeader(grIndx)
{
  foreach (new w : GroupWorkers[grIndx])
  {
	if( HasPlayerPermission(w, "group", GPREM_leader, grIndx) ) return pInfo[w][uid];
  }
  
  return 0;
}

stock GroupsCommand(playerid, params[])
{
   #pragma unused params
   
   new groupCmdHelp[200];
   format(groupCmdHelp, sizeof(groupCmdHelp), "{999A9C}PLERP.net: /(g)rupy [slot 1-5] [info/sluzba/online/magazyn/wplac/oferty/zapros/wypros/(v/pojazdy)/pomoc]");
   if( pGroups[playerid][0][groupUid] == 0 )
   {
      ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("B³¹d - Grupy"), "Twoja postaæ nie jest cz³onkiem ¿adnej grupy!", "Zamknij", "");
      return 1;
   }
   
   if(isnull(params))
   {
     SendClientMessage(playerid, COLOR_GREY, groupCmdHelp);
	 // -- Main groups GUI window -- //
	 new formattedGroupsList[828];
     format(formattedGroupsList, 828, "** wybierz grupê, któr¹ chcesz zarz¹dzaæ aby wyœwietliæ listê dostêpnych opcji.\n pamiêtaj, ¿e mo¿esz u¿yc szybkiego wybierania poprzez {efe4b0}/g [slot] [akcja]\n----------------------\n");
     for(new i; i<5; i++)
     {
        if( pGroups[playerid][i][groupUid] > 0 )
        {
          new grIdx = pGroups[playerid][i][groupIndx];
          format(formattedGroupsList, 828, "%s\n {efe4b0}@%d{FFFFFF}                  {%06x}%s {bebebe}(uid: %d)          ", formattedGroupsList, i+1, groups[grIdx][gColor], groups[grIdx][name], groups[grIdx][grid]);
	    }
	    else break;
     }
     ShowPlayerDialog(playerid, 8, DIALOG_STYLE_LIST, BuildGuiCaption("Grupy"), formattedGroupsList, "Wybierz", "Zamknij");
   }
   else
   {
     new groupCmdParams[5][64];
     sscanf(params, "a<s[64]>[5]", groupCmdParams);

	 if( !IsNumeric(groupCmdParams[0]) ) return SendClientMessage(playerid, COLOR_GREY, groupCmdHelp);
	 new groupSlot = strval(groupCmdParams[0]);
	 if( groupSlot > 5 || groupSlot < 1 ) return 1;
	 if( GetPlayerGroupFreeSlot(playerid) != -1 )
	 {
	   if( groupSlot > GetPlayerGroupFreeSlot(playerid)+1 ) return 1;
	 }

	 if( isnull(groupCmdParams[1]) )
	 {
	    new grIdx = pGroups[playerid][groupSlot-1][groupIndx];
		BuildGroupGUI(playerid, grIdx);
	 }
	 else
	 {
	    new grIdx = pGroups[playerid][groupSlot-1][groupIndx];
		new grSlot = groupSlot-1;
		new string[78];
        format(string, 78, "Grupy - {%06x}@%d %s {bebebe}(uid: %d)          ", groups[grIdx][gColor], groupSlot, groups[grIdx][name], groups[grIdx][grid]);
		// todo: repair
	    if( !strcmp(groupCmdParams[1], "info", false) )
		{
		  if( HasPlayerPermission(playerid, "group", GPREM_info, grSlot) == 0 ) return 1;
		  BuildGroupInfoGui(playerid, grIdx, grSlot);
		}
		
		if( !strcmp(groupCmdParams[1], "sluzba", false) )
		{
		  if( pInfo[playerid][currentDuty] != -1 && pGroups[playerid][pInfo[playerid][currentDuty]][groupIndx] != grIdx)
		  {
			ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption(string), "Nie mo¿esz wejœæ na s³u¿bê w tej grupie, poniewa¿ aktualnie jeste¿ ju¿ na niej w innej grupie!", "Zamknij", "");
		  }
		  else if( pInfo[playerid][currentDuty] != -1 && pGroups[playerid][pInfo[playerid][currentDuty]][groupIndx] == grIdx )
		  {
			SetupPlayerDuty(playerid, -1);
		  }
		  else
		  {
			SetupPlayerDuty(playerid, grSlot);
		  }
		}
		
		if( !strcmp(groupCmdParams[1], "online", false) )
		{
		  if( HasPlayerPermission(playerid, "group", GPREM_online, grSlot) == 0 ) return 1;
		  new formattedOnlineList[2000], inc=0;
		  foreach (new worker : GroupWorkers[grIdx])
		  {
			inc += 1;
			new pgSlot = GetGroupPlayerSlot(worker, grIdx);
			format( formattedOnlineList, sizeof(formattedOnlineList), "%s%d.\t%s %s (ID: %d)\n", formattedOnlineList, inc, pGroups[worker][pgSlot][rank], pInfo[worker][name], worker );
		  }
		  format(string, 78, "Grupy - {%06x}@%d %s {bebebe}(uid: %d) - Gracze. Razem: %d", groups[grIdx][gColor], grSlot+1, groups[grIdx][name], groups[grIdx][grid], inc);
		  ShowPlayerDialog(playerid, 1, DIALOG_STYLE_LIST, BuildGuiCaption(string), formattedOnlineList, "Zamknij", "");
		}
		
		if( !strcmp(groupCmdParams[1], "magazyn", false) )
		{
		  if( HasPlayerPermission(playerid, "group", GPREM_storage, grSlot) == 0 ) return 1;
		  BuildGroupStorageGui(playerid, grIdx, grSlot);
		}
		
		if( !strcmp(groupCmdParams[1], "wplac", false) )
		{
		  if(isnull(groupCmdParams[2]) || !IsNumeric(groupCmdParams[2])) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /(g)rupy [slot 1-5] wplac [kwota]");
		  	  
		  if( pInfo[playerid][standingInDoors] >= 0 )
    	  {
      	    // -- Jest w budynku? -- //
      	    if( doors[pInfo[playerid][standingInDoors]][doorUid] == GetPlayerVirtualWorld(playerid) && doors[pInfo[playerid][standingInDoors]][type] == 0 && doors[pInfo[playerid][standingInDoors]][owner] == groups[grIdx][grid] ) 
	  	    {
			   new amount = strval(groupCmdParams[2]);
	    	   if( amount > pInfo[playerid][cash] ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie masz przy sobie wystarczaj¹cej iloœci pieniêdzy.");
			   
			   AddPlayerMoney(playerid, -amount);
			   AddGroupMoney(grIdx, amount);
	  	    }
    	  }
		  
		}
		
		if( !strcmp(groupCmdParams[1], "oferty", false) )
		{
		  if( HasPlayerPermission(playerid, "group", GPREM_offers, grSlot) == 0 ) return 1;
		  BuildGroupOffersHelp(playerid, grIdx, grSlot);
		}
		
		if( !strcmp(groupCmdParams[1], "zapros", false) || !strcmp(groupCmdParams[1], "wypros", false) )
		{
		  if( HasPlayerPermission(playerid, "group", GPREM_invite, grSlot) == 0 ) return 1;
		  ShowPlayerDialog(playerid, 25, DIALOG_STYLE_INPUT, BuildGuiCaption(string), "** Podaj id gracza, którego chcesz zaprosiæ lub wyrzuciæ z grupy.", "Gotowe", "Zamknij");
		}
				
		if( !strcmp(groupCmdParams[1], "pojazdy", false) || !strcmp(groupCmdParams[1], "v", false) )
		{
		  if( HasPlayerPermission(playerid, "group", GPREM_vehicles, grSlot) == 0 ) return 1;
		  if(isnull(groupCmdParams[2])) 
		  {
		   new str2[100];
		   format( str2, sizeof(str2), "PLERP.net: /(g)rupy [slot 1-5] v [lista]");
		   if( HasPlayerPermission(playerid, "group", GPREM_leader, grSlot) ) format( str2, sizeof(str2), "PLERP.net: /(g)rupy [slot 1-5] v [lista/respawn]");
		   
		   return SendClientMessage(playerid, COLOR_GREY, str2);
		  }
		  
		  if( !strcmp(groupCmdParams[2], "lista", false) ) BuildGroupVehiclesGui(playerid, grIdx, grSlot);
		  
		  if( !strcmp(groupCmdParams[2], "respawn", false) && HasPlayerPermission(playerid, "group", GPREM_leader, grSlot) ) 
		  {
		     RespawnGroupVehicles(grIdx); 
             SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Wszystkie pojazdy, w których nikt nie siedzia³ zosta³y zapisane i przywrócone na spawn.");
		  }
		  
		  
		} 
		
		if( !strcmp(groupCmdParams[1], "pomoc", false) )
		{
		  if( HasPlayerPermission(playerid, "group", GPREM_info, grSlot) == 0 ) return 1;
		}
	 }
   }
   
   return 1;
}

stock BuildGroupOffersHelp(playerid, grIdx, grSlot)
{
    new string[78];
    format(string, 78, "Grupy - {%06x}@%d %s {bebebe}(uid: %d)          ", groups[grIdx][gColor], grSlot+1, groups[grIdx][name], groups[grIdx][grid]);
	new formattedOffersHelp[650];
	if( groups[grIdx][type] == 2 ) // urzad miasta
	{
		new formatDokumenty[124], formatDrzwi[124];
		if( HasPlayerPermission(playerid, "group", GPREM_urzad_dokumenty, grSlot) ) format(formatDokumenty, 124, "\n    {FFFFFF}> {FF3737}(dok)umenty{FFFFFF} - prawo jazdy, dowód, dowód rejestracyjny pojazdu.");
		if( HasPlayerPermission(playerid, "group", GPREM_urzad_drzwi, grSlot) ) format(formatDrzwi, 124, "\n    {FFFFFF}> {FF3737}(drz)wi{FFFFFF} - tworzenie drzwi dla gracza.");
        format(formattedOffersHelp, 650, "{FFFFFF}Aby z³o¿yæ ofertê z zasobów grupy u¿yj komendy {FAC767}/(o)ferta{FFFFFF}.\n{FFFFFF}Dostêpne dla Ciebie rodzaje ofert:%s%s", formatDokumenty, formatDrzwi);
	}
	
	if( groups[grIdx][type] == 3 ) // warsztat samochodowy
	{
        new formatOferty[324];
		if( HasPlayerPermission(playerid, "group", GPREM_offers, grSlot) )
		{
			format(formatOferty, 324, "\n    {FFFFFF}> {FF3737}naprawa{FFFFFF} [id gracza] [koszt]\n    {FFFFFF}> {FF3737}malowanie{FFFFFF} [id gracza] [koszt] #Gracz sam wybiera kolory\n    {FFFFFF}> {FF3737}tankowanie{FFFFFF} [id gracza] [koszt] [ilosc]");
		}
		format(formattedOffersHelp, 650, "{FFFFFF}Aby z³o¿yæ ofertê z zasobów grupy u¿yj komendy {FAC767}/(o)ferta (g)rupa{FFFFFF}.\n{FFFFFF}Dostêpne dla Ciebie rodzaje ofert:%s%s", formatOferty);
	}
	ShowPlayerDialog(playerid, 33, DIALOG_STYLE_MSGBOX, BuildGuiCaption(string), formattedOffersHelp, "Zamknij", "");
}

stock BuildGroupStorageGui(playerid, grIdx, grSlot)
{
    new areaId, canShow = 0;
    if( pInfo[playerid][standingInDoors] >= 0 )
    {
      // -- Jest w budynku? -- //
      if( doors[pInfo[playerid][standingInDoors]][doorUid] == GetPlayerVirtualWorld(playerid) && doors[pInfo[playerid][standingInDoors]][type] == 0 && doors[pInfo[playerid][standingInDoors]][owner] == groups[grIdx][grid] ) 
	  {
	    canShow = 1;
	    areaId = pInfo[playerid][standingInDoors];
	  }
    }
    /*else
    {
      // -- Mo¿e jest w strefie? -- //
      new arid = IsPlayerInAnyDynamicArea(playerid);
	  if( arid >= 0 )
	  {
	    if( areas[arid][owner] == grIdx ) canShow = 1;
	  }
    }*/
    if( canShow )
	{
	  new string[78];
      format(string, 78, "Magazyn (%d) -> {%06x}@%d %s {bebebe}(uid: %d) ", doors[areaId][doorUid], groups[grIdx][gColor], grSlot+1, groups[grIdx][name], groups[grIdx][grid]);
	  
	  new liczba1, bigstring[300];
	  foreach (new item : Items_STORE[doors[areaId][doorUid]])
	  {
		liczba1++;
		format( bigstring, sizeof(bigstring), "%s\n%d.\t\t%s[%d:%d] (Iloœæ: %d)", bigstring, liczba1, Item[item][name], Item[item][value1], Item[item][value2], Item[item][price], Item[item][count]);
		    
	  }
		 
	  if( liczba1 > 0 )
	  {
		ShowPlayerDialog(playerid, 49, DIALOG_STYLE_LIST, string, bigstring, "Kup", "Anuluj");
	  }
	  else ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, string, "Magazyn tego budynku jest pusty. Aby zamówiæ towar u¿yj telefonu:\n\t/tel 777", "Zamknij", "");
    }
}

stock BuildGroupInfoGui(playerid, grIdx, grSlot)
{  
  new zapytanie[300];
  format(zapytanie, sizeof(zapytanie), "SELECT * FROM `worker_profile` WHERE `group` = '%d'", groups[grIdx][grid]);
  mysql_function_query(mysqlHandle, zapytanie, true, "GroupInfoGuiParse", "ddd", playerid, grIdx, grSlot);
}

forward GroupInfoGuiParse(playerid, grIdx, grSlot);
public GroupInfoGuiParse(playerid, grIdx, grSlot)
{
  new bigstring[400], bigstring2[200], string[80];
  format(string, sizeof(string), "Informacje -> {%06x}@%d %s {bebebe}(uid: %d) ", groups[grIdx][gColor], grSlot+1, groups[grIdx][name], groups[grIdx][grid]);
  
  new rows, fields;
  cache_get_data( rows, fields, mysqlHandle);
  
  new onlineWorkers = Iter_Count(GroupWorkers[grIdx]);
  
  new striny[80];
  format(striny, sizeof(striny), "%dm %ds", pGroups[playerid][grSlot][dutyTime] / 60, pGroups[playerid][grSlot][dutyTime] % 60);
  
  format( bigstring, sizeof(bigstring), "[{ABABAB} Informacje o grupie {FFFFFF}]\n   Nazwa\t\t{a9c4e4}%s\n   Typ:\t\t\t{a9c4e4}%d\n   Bank:\t\t\t{a9c4e4}$%d\n   Pracownicy:\t\t{a9c4e4}%d (w tym %d online)\n", groups[grIdx][name], groups[grIdx][type], groups[grIdx][bank], rows, onlineWorkers );
  format( bigstring2, sizeof(bigstring2), "[{ABABAB} Moje dane pracownika {FFFFFF}]\n   Imie i nazwisko\t{a9c4e4}%s\n   Ranga\t\t{a9c4e4}%s\n   Wyp³ata\t\t{a9c4e4}$%d\n   Czas na s³u¿bie\t{a9c4e4}%s (w ci¹gu ostatnich 24h)", pInfo[playerid][name], pGroups[playerid][grSlot][rank], pGroups[playerid][grSlot][payday], striny );
  strcat(bigstring, bigstring2);
  ShowPlayerDialog(playerid, 1, DIALOG_STYLE_LIST, string, bigstring, "Zamknij", "");
}

stock BuildGroupVehiclesGui(playerid, grIdx, grSlot)
{
  new bigstring[400], string[80], formattedPrimaryFuel[128], vehiclesCount;
  
  foreach (new v : GroupVehicles[grIdx])
  {
    vehiclesCount += 1;
	format(formattedPrimaryFuel, sizeof(formattedPrimaryFuel), "%s - %.0fl[%.0fl]", GetVehicleFuelType(v), GetVehicleCurrentFuel(v), GetVehicleMaxFuel(v));
	format(bigstring, sizeof(bigstring), "%s\n%d.\t%s (UID:%d)\t\t%s", bigstring, vehiclesCount, VehicleNames[sVehInfo[v][model]-400], sVehInfo[v][uid], formattedPrimaryFuel );
  }
  
  format(string, sizeof(string), "Pojazdy (wszystkich: %d) -> {%06x}@%d %s {bebebe}(uid: %d) ", vehiclesCount, groups[grIdx][gColor], grSlot+1, groups[grIdx][name], groups[grIdx][grid]);
  ShowPlayerDialog(playerid, 1, DIALOG_STYLE_LIST, string, bigstring, "Zamknij", "");
}

stock IsPlayerInDutyArea(playerid)
{
  if( pInfo[playerid][standingInDoors] == -1 ) goto skip;
  if( doors[pInfo[playerid][standingInDoors]][type] == 0 )
  {
     if( doors[pInfo[playerid][standingInDoors]][owner] != pGroups[playerid][pInfo[playerid][currentDuty]][groupUid] )
	 {
		skip:
        return false;
	 }
  }
  return true;
}

stock ShowLSNBar(playerid, prefix[], content[], ttime)
{      
        new string[258], query[250], s, h, minn, d, m, y, date[32];
       
        TextDrawHideForAll(LSNTextdraw[0]);
        TextDrawHideForAll(LSNTextdraw[1]);

        format(string, sizeof(string), "%s", str_replace("~", "[", content));
        format(string, sizeof(string), "%s", str_replace("[r]", "~r~", string));
        format(string, sizeof(string), "%s", str_replace("[y]", "~y~", string));
        format(string, sizeof(string), "%s", str_replace("[g]", "~g~", string));
        format(string, sizeof(string), "%s", str_replace("[b]", "~b~", string));
        format(string, sizeof(string), "%s", str_replace("[w]", "~w~", string));
        format(string, sizeof(string), "%s", str_replace("[p]", "~p~", string));
        format(string, sizeof(string), "%s", str_replace("[l]", "~l~", string));
        format(string, sizeof(string), "%s", str_replace("[h]", "~h~", string));
		
        printf("%s", content);
        format(string, sizeof(string), "%s ~>~ ~w~%s", prefix, content);
		TextDrawSetString(LSNTextdraw[1], string);
       
        TextDrawShowForAll(LSNTextdraw[0]);
        TextDrawShowForAll(LSNTextdraw[1]);
       
        gettime(h, minn, s);
        getdate(y, m, d);
        format(date, sizeof(date), "%d:%d:%d %d/%d/%d", h, minn, s, d, m, y);
        format(query, sizeof(query), "INSERT INTO `plerp_lsn` SET `sender`='%d', `content`='%s', `date`='%s'",
                                                                        pInfo[playerid][uid], string, date);
        mysql_function_query(mysqlHandle, query, false, "", "");
       
        defer HideLSNBar[ttime]();
        return 1;
}

stock AddGroupMoney(grIndx, amount)
{
   groups[grIndx][bank] += amount;
   
   new Query[456];
   format( Query, sizeof(Query), "UPDATE `groups` SET `bank`='%d' WHERE `uid`='%d'", groups[grIndx][bank], groups[grIndx][grid]);
   mysql_function_query(mysqlHandle, Query, false, "", "");
}