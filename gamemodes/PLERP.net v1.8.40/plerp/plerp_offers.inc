#define OFFER_TYPE_GROUP_INVITE   1
#define OFFER_TYPE_ITEM           2
#define OFFER_TYPE_VEHICLE_SELL   3
#define OFFER_TYPE_VEHICLE_REFILL 4
#define OFFER_TYPE_HEAL 		  5
#define OFFER_TYPE_VCARD          6
#define OFFER_TYPE_ADVERTISMENT   7
#define OFFER_TYPE_LIVE           8
#define OFFER_TYPE_PODAJ 		  9
#define OFFER_TYPE_REGISTRATION   10
#define OFFER_TYPE_LESSON         11
#define OFFER_TYPE_VEHICLE_REPAIR 12
#define OFFER_TYPE_VEHICLE_PAINT  13

stock HandleOfferResponse(playerid, response)
{
  if( !response ) goto offer_End;
  
  switch(pOffer[playerid][oType])
  {
	case OFFER_TYPE_GROUP_INVITE:
	{	  
	  new grId = pOffer[playerid][oParam1], blankPermission[100], Query[256];
	  format( blankPermission, sizeof(blankPermission), GetBlankGroupPermissions() );
	  
      // -- insert worker profile -- //
      format( Query, sizeof(Query), "INSERT INTO `worker_profile` (`id`, `uid`, `group`, `rank`, `permission`) VALUES (null, '%d', '%d', '%s', '%s')", pInfo[playerid][uid], groups[grId][grid], "", blankPermission);
	  mysql_function_query(mysqlHandle, Query, false, "", "");
	  
	  // -- update player stored groups -- //
	  new pGroupSlot = GetPlayerGroupFreeSlot(playerid);
	  
	  pGroups[playerid][pGroupSlot][groupIndx] = grId;
	  pGroups[playerid][pGroupSlot][groupUid] = groups[grId][grid];  
	  format(pGroups[playerid][pGroupSlot][rank], 64, "");
	  format(pGroups[playerid][pGroupSlot][permission], 64, blankPermission);
	  
	  ParsePlayerGroupPermission(playerid, pGroupSlot);  
	  Iter_Add(GroupWorkers[grId], playerid);
	}
	
	case OFFER_TYPE_ITEM:
	{	  
	  if( pInfo[playerid][cash] < pOffer[playerid][oParam1] )
      {
        new playerDeclineFormat[124];
	    format(playerDeclineFormat, 124, "Gracz ~r~%s~w~ nie ma pieniedzy na op³acenie Twojej oferty.", pInfo[playerid][tdnick]);
        if( pInfo[pOffer[playerid][oSender]][logged] == 1 ) SendPlayerInformation(pOffer[playerid][oSender], playerDeclineFormat);
		SendPlayerInformation(playerid, "Nie masz wystarczajacej ilosci pieniedzy, aby oplacic ta oferte.");
		goto offer_End;
      }
	  
	  if( Item[pOffer[playerid][oParam2]][owner_id] != pInfo[pOffer[playerid][oSender]][uid] )
	  {
	    new playerDeclineFormat[124];
        if( pInfo[pOffer[playerid][oSender]][logged] == 1 ) SendPlayerInformation(pOffer[playerid][oSender], "Nie posiadasz przedmiotu, ktory oferujesz.");
		format(playerDeclineFormat, 124, "Gracz ~r~%s~w~ nie posiada oferowanego przedmiotu.", pInfo[pOffer[playerid][oSender]][tdnick]);
		SendPlayerInformation(playerid, playerDeclineFormat);
		goto offer_End;
	  }
	  
	  Item[pOffer[playerid][oParam2]][owner_id] = pInfo[playerid][uid];
	  Iter_Remove(Items_PLAYER[pInfo[pOffer[playerid][oSender]][uid]], pOffer[playerid][oParam2]);
	  Iter_Add(Items_PLAYER[pInfo[playerid][uid]], pOffer[playerid][oParam2]);
	  
	  new string[200];
	  format(string, sizeof(string), "UPDATE `plerp_items` SET `owner_id` = %d, `owner_type` = %d WHERE `uid` = %i", Item[pOffer[playerid][oParam2]][owner_id], Item[pOffer[playerid][oParam2]][owner_type], Item[pOffer[playerid][oParam2]][uid]);
	  mysql_function_query(mysqlHandle, string, false, "", "");
	  
	  AddPlayerMoney(playerid, -pOffer[playerid][oParam1]);
	  AddPlayerMoney(pOffer[playerid][oSender], pOffer[playerid][oParam1]);
	}
	
	case OFFER_TYPE_VEHICLE_SELL:
	{
	  if( !response ) goto offer_End;
	  
	  if( pInfo[playerid][cash] < pOffer[playerid][oParam1] )
      {
        new playerDeclineFormat[124];
	    format(playerDeclineFormat, 124, "Gracz ~r~%s~w~ nie ma pieniedzy na op³acenie Twojej oferty.", pInfo[playerid][tdnick]);
        if( pInfo[pOffer[playerid][oSender]][logged] == 1 ) SendPlayerInformation(pOffer[playerid][oSender], playerDeclineFormat);
		SendPlayerInformation(playerid, "Nie masz wystarczajacej ilosci pieniedzy, aby oplacic ta oferte.");
		goto offer_End;
      }
	  
	  new vID = pOffer[playerid][oParam2];
	  
	  sVehInfo[vID][owner] = pInfo[playerid][uid];
	  sVehInfo[vID][engine] = false;  
	  UpdateVehicle(vID);
	  
	  new Query[200];
	  format( Query, sizeof(Query), "UPDATE `vehicles` SET `owner`=%d WHERE uid=%d", sVehInfo[vID][owner], sVehInfo[vID][uid] );
      mysql_function_query(mysqlHandle, Query, false, "", "");
	  
	  AddPlayerMoney(playerid, -pOffer[playerid][oParam1]);
	  AddPlayerMoney(pOffer[playerid][oSender], pOffer[playerid][oParam1]);
	}
	case OFFER_TYPE_HEAL:
	{
		if( !response ) goto offer_End;
		if( pInfo[playerid][cash] < pOffer[playerid][oParam1] )
		{
			new playerDeclineFormat[124];
			format(playerDeclineFormat, 124, "Gracz ~r~%s~w~ nie ma pieniedzy na op³acenie Twojej oferty.", pInfo[playerid][tdnick]);
			if( pInfo[pOffer[playerid][oSender]][logged] == 1 ) SendPlayerInformation(pOffer[playerid][oSender], playerDeclineFormat);
			SendPlayerInformation(playerid, "Nie masz wystarczajacej ilosci pieniedzy, aby oplacic ta oferte.");
			goto offer_End;
		}
		if(pInfo[pOffer[playerid][oSender]][currentDuty] == -1) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX,("Oferty -> B³¹d"), "Wyst¹pi³ b³¹d.", "Zamknij", "");
		if(groups[pGroups[pOffer[playerid][oSender]][pInfo[pOffer[playerid][oSender]][currentDuty]][groupIndx]][type] != 7) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX,("Oferty -> B³¹d"), "Wyst¹pi³ b³¹d.", "Zamknij", "");
		AddGroupMoney(pGroups[pOffer[playerid][oSender]][pInfo[pOffer[playerid][oSender]][currentDuty]][groupIndx], pOffer[playerid][oParam1]);
		AddPlayerMoney(playerid, -pOffer[playerid][oParam1]);
		pInfo[playerid][bwStatus] = 0;
		pInfo[playerid][health] = 100.00;
		SetPlayerHealth(playerid, pInfo[playerid][health]);
	}
	case OFFER_TYPE_PODAJ:
	{
		if( !response ) goto offer_End;
		if( pInfo[playerid][cash] < Item[pOffer[playerid][oParam1]][price])
		{
			new playerDeclineFormat[124];
			format(playerDeclineFormat, 124, "Gracz ~r~%s~w~ nie ma pieniedzy na op³acenie Twojej oferty.", pInfo[playerid][tdnick]);
			if( pInfo[pOffer[playerid][oSender]][logged] == 1 ) SendPlayerInformation(pOffer[playerid][oSender], playerDeclineFormat);
			SendPlayerInformation(playerid, "Nie masz wystarczajacej ilosci pieniedzy, aby oplacic ta oferte.");
			goto offer_End;
		}
		AddGroupMoney(pOffer[playerid][oParam3], Item[pOffer[playerid][oParam1]][price]);
		AddPlayerMoney(playerid, -Item[pOffer[playerid][oParam1]][price]);
		ItemCreate(pInfo[playerid][uid], 1, Item[pOffer[playerid][oParam1]][type], Item[pOffer[playerid][oParam1]][value1], Item[pOffer[playerid][oParam1]][value2], Item[pOffer[playerid][oParam1]][modellook], Item[pOffer[playerid][oParam1]][name]);
		Item[pOffer[playerid][oParam1]][count] -= 1;
		if(Item[pOffer[playerid][oParam1]][count] < 1) 
		{
			ItemRemove(pOffer[playerid][oParam1]);
		}
		else
		{
			new zapytanie[128];
			format(zapytanie, sizeof(zapytanie), "UPDATE `plerp_items` SET `count`='%i' WHERE `uid` = %i", Item[pOffer[playerid][oParam1]][count], Item[pOffer[playerid][oParam1]][uid]);
	        mysql_function_query(mysqlHandle, zapytanie, false, "", "");
		
		}
	}
	case OFFER_TYPE_VEHICLE_REFILL:
	{
	  new vID = pOffer[playerid][oParam2];
	  new iloscPaliwa = pOffer[playerid][oParam1];
	  new cenaPaliwa = floatround(iloscPaliwa / PALIWO_CENA, floatround_ceil);
	  	  
	  if( pInfo[playerid][cash] < cenaPaliwa )
      {
		SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie masz wystarczaj¹cej iloœci pieniêdzy, aby op³aciæ t¹ ofertê.");
		return HidePlayerOfferGUI(playerid);
      }
		
	  if( sVehInfo[vID][carActionInProgress] )
	  {
		SendClientMessage(playerid, WHITE, "PLERP.net: To auto jest ju¿ w akcji, poczekaj do jej ukoñczenia.");
		return HidePlayerOfferGUI(playerid);
	  }
		
	  sVehInfo[vID][carActionInProgress] = true;
	  sVehInfo[vID][carActionLabel] = CreateDynamic3DTextLabel("Tankowanie pojazdu\n0%", 0x509906FF, 0.0, 0.0, 1.0, 10.0, INVALID_PLAYER_ID, vID, 0, 0, -1, playerid);
	  new Float:vX, Float:vY, Float:vZ;
	  GetVehiclePos(vID, vX, vY, vZ);
	  Streamer_UpdateEx(playerid, vX, vY, vZ, 0, -1);
		
	  new array[6];
	  array[0] = 5000;
      array[1] = 0;
	  array[2] = pInfo[playerid][uid];
	  array[3] = iloscPaliwa;
	  array[4] = 5;
	  array[5] = playerid;
		
	  defer RefillVehicleScene(vID, array, sizeof(array));
	  ApplyAnimation(playerid, "BD_FIRE", "wash_up", 1.5, 1, 0, 0, 0, 5000, 1);
	}
	
	case OFFER_TYPE_VCARD:
	{
	  new phoneIndx[2];
	  phoneIndx[0] = pInfo[pOffer[playerid][oSender]][lastUsedPhone];
	  phoneIndx[1] = pInfo[playerid][lastUsedPhone];
	  
	  new Query[200];
	  format( Query, sizeof(Query), "INSERT INTO `phone_contacts` (`uid`, `phone`, `name`, `number`) VALUES (null, %d, '%s', %d), (null, %d, '%s', %d)", Item[phoneIndx[0]][uid], pInfo[playerid][name], Item[phoneIndx[1]][value1], Item[phoneIndx[1]][uid], pInfo[pOffer[playerid][oSender]][name], Item[phoneIndx[0]][value1] );
      mysql_function_query(mysqlHandle, Query, false, "", "");
	}
	
	case OFFER_TYPE_ADVERTISMENT:
    {
                new ttime = pOffer[playerid][oParam2];
                new kwota = pOffer[playerid][oParam1];
               
                if(pInfo[playerid][cash] < kwota)
                {
                        SendClientMessage(playerid, COLOR_GREY, "Plerp.net: Nie posiadasz wystarczaj¹co pieniêdzy.");
                        return HidePlayerOfferGUI(playerid);
                }
               
                ShowLSNBar(oSender, "~y~Reklama", pInfo[pOffer[playerid][oSender]][t_stringtmp], ttime);
               
                AddPlayerMoney(playerid, -kwota);
                AddGroupMoney(10, kwota);
    }
       
    case OFFER_TYPE_LIVE:
    {
                new string[128];
               
                pInfo[playerid][t_live] = 1;
                pInfo[playerid][t_live_pid] = oSender;
                pInfo[oSender][t_live_pid] = playerid;
                pInfo[oSender][t_live] = 1;
               
                format(string, sizeof(string), "LSN: Rozpocz¹³eœ wywiad na ¿ywo z %s.", pInfo[playerid][name]);
                SendClientMessage(oSender, COLOR_GREEN, string);
                format(string, sizeof(string), "LSN: Dziennikarz %s rozpocz¹³ z tob¹ wywiad na ¿ywo.", pInfo[oSender][name]);
                SendClientMessage(playerid, COLOR_GREEN, string);
    }
	
	case OFFER_TYPE_REGISTRATION:
    {
                new string[128], reg[32], intreg;
               
                new kwota = pOffer[playerid][oParam1];
                new vuid = pOffer[playerid][oParam2];
               
                if(pInfo[playerid][cash] < kwota)
                {
                        SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie posiadasz wystarczaj¹co du¿o pieniêdzy.");
                        return HidePlayerOfferGUI(playerid);
                }
               
                format(string, sizeof(string), "%d", vuid);
                if(strlen(string) < 4)
                {
                        if(strlen(string) == 1)
                        {
                                format(reg, sizeof(reg), "%d000", vuid);
                                intreg = strval(reg);
                        } else if(strlen(string) == 2)
                        {
                                format(reg, sizeof(reg), "%d00", vuid);
                                intreg = strval(reg);
                        } else if(strlen(string) == 3)
                        {
                                format(reg, sizeof(reg), "%d0", vuid);
                                intreg = strval(reg);
                        }
                } else
                {
                        intreg = vuid;
                }
 
                format(string, sizeof(string), "UPDATE `vehicles` SET `plates`='LS %d' WHERE `uid`='%d'", intreg, vuid);
                mysql_function_query(mysqlHandle, string, false, "", "");
               
                AddPlayerMoney(playerid, -kwota);
                AddGroupMoney(3, kwota);
               
                format(string, sizeof(string), "PLERP.net: Urzêdnik %s wyda³ Ci tablice rejestracyjne.", pInfo[pOffer[playerid][oSender]][name]);
                SendClientMessage(playerid, COLOR_GREEN, string);
                format(string, sizeof(string), "PLERP.net: Wyda³eœ tablice rejestracyjne graczowi %s.", pInfo[playerid][name]);
                SendClientMessage(pOffer[playerid][oSender], COLOR_GREEN, string);
        }
       
        case OFFER_TYPE_LESSON:
        {
                new string[128];
               
                new kwota = pOffer[playerid][oParam1];
               
                if(pInfo[playerid][cash] < kwota)
                {
                        SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie posiadasz wystarczaj¹co du¿o pieniêdzy.");
                        return HidePlayerOfferGUI(playerid);
                }
               
                pInfo[playerid][t_lesson] = 1;
                pInfo[playerid][t_teacher] = pOffer[playerid][oSender];
               
                format(string, sizeof(string), "PLERP.net: Rozpocz¹³eœ naukê jazdy z instruktorem %s.", pInfo[pOffer[playerid][oSender]][name]);
                SendClientMessage(playerid, COLOR_GREEN, string);
                format(string, sizeof(string), "PLERP.net: Rozpocz¹³eœ naukê jazdy z uczniem %s.", pInfo[playerid][name]);
                SendClientMessage(pOffer[playerid][oSender], COLOR_GREEN, string);
        }
	case OFFER_TYPE_VEHICLE_REPAIR:
	{
        if( pInfo[playerid][cash] < pOffer[playerid][oParam1] )
        {
           new playerDeclineFormat[124];
	       format(playerDeclineFormat, 124, "Gracz %s nie ma wystarczaj¹cej iloœci pieniêdzy aby op³aciæ Twoj¹ ofertê.", pInfo[playerid][tdnick]);
           if( pInfo[pOffer[playerid][oSender]][logged] == 1 ) ShowPlayerDialog(pOffer[playerid][oSender], 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("Oferty"), playerDeclineFormat, "Zamknij", "");
		   SendClientMessage(playerid, WHITE, "Nie masz wystarczaj¹cej iloœci pieniêdzy, aby op³aciæ t¹ ofertê.");
		   goto offer_End;
        }
		new vehID = pOffer[playerid][oParam2];
		sVehInfo[vehID][carActionInProgress] = true;
		sVehInfo[vehID][carActionLabel] = CreateDynamic3DTextLabel("Naprawa pojazdu\n0%", 0x509906FF, 0.0, 0.0, 1.0, 10.0, INVALID_PLAYER_ID, vehID, 1, GetVehicleVirtualWorld(vehID));
		new Float:vX, Float:vY, Float:vZ;
	    GetVehiclePos(vehID, vX, vY, vZ);
	    Streamer_UpdateEx(playerid, vX, vY, vZ, GetVehicleVirtualWorld(vehID), -1);
		
		new Float:missingHealth = 1000.0 - sVehInfo[vehID][health];
		
		new damagePrice = floatround((missingHealth * 0.8), floatround_round);
		
		new array[11];
		array[0] = floatround( (pOffer[playerid][oParam1] / 4) , floatround_round) * 1000;
		array[1] = 0;
		array[2] = pInfo[playerid][uid];
		array[3] = pInfo[pOffer[playerid][oSender]][uid];
	    array[4] = pOffer[playerid][oParam1] - damagePrice;
		array[5] = damagePrice;
		array[6] = floatround( (pOffer[playerid][oParam1] / 4) , floatround_round);
		array[7] = playerid;
		array[8] = pOffer[playerid][oSender];
		array[9] = 0;
		array[10] = 0;
		
        ShowPlayerDialog(pOffer[playerid][oSender], 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("Informacja - Oferty"), "Oferta naprawy zosta³a zaakceptowana. Zacznij odgrywaæ akcjê rp \ni nie odchodŸ za daleko od pojazdu. \nPostêp prac widnieje nad pojazdem.", "Zamknij", "");
		ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("Informacja - Oferty"), "Twój pojazd zostanie naprawiony. Nie w³¹czaj silnika\noraz nie odchodŸ za daleko bo oferta zostanie anulowana.\nPostêp prac widnieje nad autem.", "Zamknij", "");
		defer RepairVehicleScene(vehID, array, sizeof(array));
	}
	
  }
  offer_End:
  if( response == 0 && IsPlayerConnected(pOffer[playerid][oSender]) )
  {
    new playerDeclineFormat[124];
	format(playerDeclineFormat, 124, "Gracz ~r~%s ~w~odrzucil Twoja oferte.", pInfo[playerid][tdnick]);
	
	if( pInfo[pOffer[playerid][oSender]][logged] == 1 ) SendPlayerInformation(pOffer[playerid][oSender], playerDeclineFormat, 2500);
  }
  
  if( response == 1 && IsPlayerConnected(pOffer[playerid][oSender]) )
  {
    new playerAcceptFormat[124];
	format(playerAcceptFormat, 124, "Gracz ~r~%s ~w~zaakceptowal Twoja oferte.", pInfo[playerid][tdnick]);
	
	if( pInfo[pOffer[playerid][oSender]][logged] == 1 ) SendPlayerInformation(pOffer[playerid][oSender], playerAcceptFormat, 2500);
  }
  
  HidePlayerOfferGUI(playerid);
  return 1;
}

stock SendPlayerOffer(playerid, offertSender, offertType, offertParam1, offertParam2, offertParam3 = 0, offertParam4 = 0)
{
  if( pInfo[playerid][logged] == 0 ) return ShowPlayerDialog(offertSender, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("B³¹d - Oferty"), "Ten gracz nie jest zalogowany.", "Zamknij", ""); 
  if( pOffer[playerid][oType] > 0 ) return ShowPlayerDialog(offertSender, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("B³¹d - Oferty"), "Ten gracz aktualnie ma ju¿ coœ oferowane.", "Zamknij", "");  
  if( pInfo[playerid][isAFK] )      return ShowPlayerDialog(offertSender, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("B³¹d - Oferty"), "Ten gracz aktualnie jest AFK.", "Zamknij", ""); 
  if( offertParam1 < 0 ) return ShowPlayerDialog(offertSender, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("B³¹d - Oferty"), "Cena nie mo¿e byæ mniejsza od zera.", "Zamknij", "");
  //if( playerid == offertSender )    return ShowPlayerDialog(offertSender, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("B³¹d - Oferty"), "Nie mo¿esz oferowaæ sam sobie.", "Zamknij", "");
  
  switch(offertType)
  {
	case OFFER_TYPE_GROUP_INVITE:
	{
	  if( GetPlayerGroupFreeSlot(playerid) == -1 ) return ShowPlayerDialog(offertSender, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("B³¹d - Oferty"), "Ten gracz jest w maksymalnej liczbie grup na raz.", "Zamknij", "");
	   // -- param2 to grIdx
	  pOffer[playerid][oParam1] = offertParam1;
	  pOffer[playerid][oParam2] = offertParam2;	 
	}
	
	case OFFER_TYPE_ITEM:
	{
	  pOffer[playerid][oParam1] = offertParam1;
	  pOffer[playerid][oParam2] = offertParam2;
	}
	
	case OFFER_TYPE_VEHICLE_SELL:
	{
	  pOffer[playerid][oParam1] = offertParam1;
	  pOffer[playerid][oParam2] = offertParam2;
	}
	
	case OFFER_TYPE_VEHICLE_REFILL:
	{
	  pOffer[playerid][oParam1] = offertParam1;
	  pOffer[playerid][oParam2] = offertParam2;
	}
	
	case OFFER_TYPE_VCARD:
	{
	  pOffer[playerid][oParam1] = offertParam1;
	  pOffer[playerid][oParam2] = offertParam2;
	}
	
	case OFFER_TYPE_ADVERTISMENT:
    {
        pOffer[playerid][oParam1] = offertParam1;
        pOffer[playerid][oParam2] = offertParam2;
    }
       
    case OFFER_TYPE_LIVE:
    {
        pOffer[playerid][oParam1] = offertParam1;
        pOffer[playerid][oParam2] = offertParam2;
    }

    case OFFER_TYPE_HEAL:
	{
	  pOffer[playerid][oParam1] = offertParam1;
	  pOffer[playerid][oParam2] = offertParam2;
	}
	case OFFER_TYPE_PODAJ:
	{
	  pOffer[playerid][oParam1] = offertParam1;
	  pOffer[playerid][oParam2] = offertParam2;
	  pOffer[playerid][oParam3] = offertParam3;
	}

	case OFFER_TYPE_REGISTRATION:
    {
        pOffer[playerid][oParam1] = offertParam1;
        pOffer[playerid][oParam2] = offertParam2;
    }
       
    case OFFER_TYPE_LESSON:
    {
        pOffer[playerid][oParam1] = offertParam1;
        pOffer[playerid][oParam2] = offertParam2;
    }
	
	case OFFER_TYPE_VEHICLE_REPAIR:
	{
        pOffer[playerid][oParam2] = offertParam2;
		
		//new visualDamage = sVehInfo[offertParam2][vDamagePanels] + sVehInfo[offertParam2][vDamageDoors] + sVehInfo[offertParam2][vDamageLights] + sVehInfo[offertParam2][vDamageTires];
		new Float:missingHealth = 1000.0 - sVehInfo[offertParam2][health];
		
		new fullPrice = floatround((missingHealth * 0.8), floatround_round) + offertParam1;
		pOffer[playerid][oParam1] = fullPrice;
		
	}
	
	case OFFER_TYPE_VEHICLE_PAINT:
	{
	    pOffer[playerid][oParam2] = offertParam2;
		pOffer[playerid][oParam1] = offertParam1;
		pOffer[playerid][oParam3] = offertParam3;
		pOffer[playerid][oParam4] = offertParam4;
	}
  }
  
  pOffer[playerid][oSender] = offertSender;
  pOffer[playerid][oType] = offertType;
  
  ShowPlayerOfferGUI(playerid);
  if( offertSender != INVALID_PLAYER_ID ) SendPlayerInformation(offertSender, "Oferta zostala wyslana do gracza.");
  return 1;
}

stock GetLiteralOfferType(offerType)
{
   new string[100];
   
   switch(offerType)
   {
     case OFFER_TYPE_GROUP_INVITE, OFFER_TYPE_VCARD: 
	 { 
	   format(string, sizeof(string), "Zaproszenie");
	 }	
	 
	 case OFFER_TYPE_ITEM:
	 {
	   format(string, sizeof(string), "Przedmiot");
	 }
	 
	 case OFFER_TYPE_VEHICLE_REFILL, OFFER_TYPE_VEHICLE_SELL:
	 {
	   format(string, sizeof(string), "Pojazd");
	 }
	 
	 case OFFER_TYPE_ADVERTISMENT:
     {
         format(string, sizeof(string), "Reklama");
     }
         
     case OFFER_TYPE_LIVE:
     {
        format(string, sizeof(string), "Wywiad");
     }
	 
	 case OFFER_TYPE_REGISTRATION:
     {
        format(string, sizeof(string), "Rejestracja pojazdu");
     }
         
     case OFFER_TYPE_LESSON:
     {
        format(string, sizeof(string), "Nauka jazdy");
     }
	 
	 case OFFER_TYPE_VEHICLE_REPAIR:
	 {
	    format(string, sizeof(string), "Naprawa pojazdu");
	 }
	 
     default:
	 {
	   format(string, sizeof(string), "Inne");
	 }	 
   }
   
   
   return string;
}

stock ShowPlayerOfferGUI(playerid)
{
  new string1[200], literalOfferType[100];
  format( literalOfferType, sizeof(literalOfferType), GetLiteralOfferType(pOffer[playerid][oType]) );
  
  // -- Formatowanie nag³ówka oferty
  if( pOffer[playerid][oSender] == INVALID_PLAYER_ID ) format( string1, sizeof(string1), "Oferta od ~r~%s ~w~~>~ %s", "System", literalOfferType );
  else format( string1, sizeof(string1), "Oferta od ~r~%s ~w~~>~ %s", pInfo[pOffer[playerid][oSender]][name], literalOfferType );
  PlayerTextDrawSetString(playerid, offersTd[1], string1);
  
  // -- Formatowanie przedmiotu oferty
  if( pOffer[playerid][oType] == OFFER_TYPE_GROUP_INVITE ) format( string1, sizeof(string1), "~y~Przedmiot~n~~w~ Zaproszenie do %s (UID %d)", groups[pOffer[playerid][oParam2]][name], groups[pOffer[playerid][oParam2]][grid] );
  if( pOffer[playerid][oType] == OFFER_TYPE_ITEM ) format( string1, sizeof(string1), "~y~Przedmiot~n~~w~ %s (%d:%d)", Item[pOffer[playerid][oParam2]][name], Item[pOffer[playerid][oParam2]][value1], Item[pOffer[playerid][oParam2]][value2] );
  if( pOffer[playerid][oType] == OFFER_TYPE_VEHICLE_SELL ) format( string1, sizeof(string1), "~y~Przedmiot~n~~w~ Pojazd %s o uid %d (%d:%d, %.2fHP)", VehicleNames[sVehInfo[pOffer[playerid][oParam2]][model]-400], sVehInfo[pOffer[playerid][oParam2]][uid], sVehInfo[pOffer[playerid][oParam2]][col1], sVehInfo[pOffer[playerid][oParam2]][col2], sVehInfo[pOffer[playerid][oParam2]][health] );
  if( pOffer[playerid][oType] == OFFER_TYPE_VEHICLE_REFILL ) format( string1, sizeof(string1), "~y~Przedmiot~n~~w~ Tankowanie %dL do %s(%d)", floatround(pOffer[playerid][oParam1] / PALIWO_CENA, floatround_ceil), VehicleNames[sVehInfo[pOffer[playerid][oParam2]][model]-400], sVehInfo[pOffer[playerid][oParam2]][uid]);
  if( pOffer[playerid][oType] == OFFER_TYPE_VCARD ) format( string1, sizeof(string1), "~y~Przedmiot~n~~w~ Dodanie do kontaktów w telefonie");
  if( pOffer[playerid][oType] == OFFER_TYPE_ADVERTISMENT ) format( string1, sizeof(string1), "~y~Przedmiot~n~~w~ Reklama - Czas: %d sekund", pOffer[playerid][oParam2] / 1000);
  if( pOffer[playerid][oType] == OFFER_TYPE_LIVE ) format( string1, sizeof(string1), "~y~Przedmiot~n~~w~ Wywiad na ¿ywo");
  if( pOffer[playerid][oType] == OFFER_TYPE_PODAJ ) format( string1, sizeof(string1), "~y~Przedmiot~n~~w~ %s (%d:%d)", Item[pOffer[playerid][oParam1]][name], Item[pOffer[playerid][oParam1]][value1], Item[pOffer[playerid][oParam1]][value2] );
  if( pOffer[playerid][oType] == OFFER_TYPE_HEAL ) format( string1, sizeof(string1), "~y~Leczenie~n~~w~");
  if( pOffer[playerid][oType] == OFFER_TYPE_REGISTRATION ) format( string1, sizeof(string1), "~y~Przedmiot~n~~w~ Rejestracja pojazdu (%d)", pOffer[playerid][oParam2]);
  if( pOffer[playerid][oType] == OFFER_TYPE_LESSON ) format( string1, sizeof(string1), "~y~Przedmiot~n~~w~ Nauka jazdy");
  if( pOffer[playerid][oType] == OFFER_TYPE_VEHICLE_REPAIR ) format( string1, sizeof(string1), "~y~Przedmiot~n~~w~ Naprawa pojazdu");
  
  PlayerTextDrawSetString(playerid, offersTd[2], string1);
  
  // -- Formatowanie kosztu oferty
  if( pOffer[playerid][oType] == OFFER_TYPE_PODAJ )
  {
  format( string1, sizeof(string1), "~y~Cena~n~~w~ $%d", Item[pOffer[playerid][oParam1]][price]);
  }
  else
  {
	format( string1, sizeof(string1), "~y~Cena~n~~w~ $%d", pOffer[playerid][oParam1]);
  }
  PlayerTextDrawSetString(playerid, offersTd[3], string1);
  
  PlayerTextDrawShow(playerid, offersTd[0]);
  PlayerTextDrawShow(playerid, offersTd[1]);
  PlayerTextDrawShow(playerid, offersTd[2]);
  PlayerTextDrawShow(playerid, offersTd[3]);
  PlayerTextDrawShow(playerid, offersTd[4]);
  PlayerTextDrawShow(playerid, offersTd[5]);
}

stock HidePlayerOfferGUI(playerid)
{
  pOffer[playerid][oSender] = -1;
  pOffer[playerid][oType] = 0;
  pOffer[playerid][oParam1] = 0;
  pOffer[playerid][oParam2] = 0;
  PlayerTextDrawHide(playerid, offersTd[0]);
  PlayerTextDrawHide(playerid, offersTd[1]);
  PlayerTextDrawHide(playerid, offersTd[2]);
  PlayerTextDrawHide(playerid, offersTd[3]);
  PlayerTextDrawHide(playerid, offersTd[4]);
  PlayerTextDrawHide(playerid, offersTd[5]);
  
  return 1;
}