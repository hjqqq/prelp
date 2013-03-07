timer ClearPlayerAnimation[500](playerid)
{
    ApplyAnimation(playerid, "CARRY", "putdwn105", 3.1, 0, 1, 1, 0, 1, 1);
}

timer HidePlayerTextDraw[500](playerid, PlayerText:pTdId)
{
    PlayerTextDrawHide(playerid, pTdId);
}

timer CarEngineStart[1000](vehicleid, playerid)
{
  new rand = 0;
  if( sVehInfo[vehicleid][health] < 500.0 )
  {
	 rand = PercentageChance(0.7);
	 if( sVehInfo[vehicleid][health] < 400.0 )
	 {
	   rand = PercentageChance(0.5);
	 }
	 if( sVehInfo[vehicleid][health] < 300.0 )
	 {
	   rand = PercentageChance(0.3);
	 }
  }

  if( rand == 0)
  {
    sVehInfo[vehicleid][engine] = true;
    PlayerTextDrawHide(playerid, carBarHud);
  }
  else
  {
    ShowPlayerDialog(playerid, 3, DIALOG_STYLE_MSGBOX, BuildGuiCaption("B³¹d - Pojazdy"), "Pojazd jest znacznie uszkodzony, dlatego mo¿e nie odpaliæ za pierwszym razem!", "Zamknij", "");
  }
  UpdateVehicle(vehicleid);
  TextDrawHideForPlayer(playerid, EngineStartTd);
}

timer UnfreezePlayer[1000](playerid)
{
    TogglePlayerControllable(playerid, 1);
}

timer ServerIntro[800](playerid)
{
    SetPlayerCameraPos(playerid, 2139.425781, -1038.801879, 70.655403);
    SetPlayerCameraLookAt(playerid, 2135.543701, -1041.656738, 69.321403);
}

timer DeleteDisconnectNotif[3000](Text3D:disconnectNotif)
{
    DestroyDynamic3DTextLabel(disconnectNotif);
}

timer ResetPlayerCall[1500](playerid)
{
  pCall[playerid][cState] = 0;
  pCall[playerid][cCaller] = 0;
  pCall[playerid][cReceiver] = 0;
  pCall[playerid][cTime] = 0;
  
  HideUpperPhoneBar(playerid);
  
  pInfo[playerid][t_911] = 0;
  
  SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
}

timer Zwloki[500](playerid)
{
    printf("Funkcja wyrzuc itemy zosta³a wykonana");
    new liczba, uidy[100];
    foreach(new idee : Items_PLAYER[pInfo[playerid][uid]])
    {
        uidy[liczba] = idee;
        liczba++;
    }
    for(new i; i<liczba; i++)
    {
        printf("Obecna liczba %i", i);
        if(Item[uidy[i]][used]) ItemUse(uidy[i], playerid);
        ItemDrop(uidy[i], playerid);
        }
    Kick(playerid);          
}

timer HideLSNBar[500]()
{
    TextDrawHideForAll(LSNTextdraw[0]);
    TextDrawHideForAll(LSNTextdraw[1]);
}

timer RepairVehicleScene[1000](vehicleid, data[], len)
{
  // data -- repairTime, secondsPassed, vehOwner, worker, workerPrice, damagePrice, percJump
  data[0] -= 1000;
  data[1] += 1;
  if( data[0] > 0 )
  {
	// -- Check if players are online -- //
	if( pInfo[data[7]][uid] != data[2] || pInfo[data[7]][logged] == 0 || pInfo[data[8]][uid] != data[3] || pInfo[data[8]][logged] == 0 || !IsPlayerConnected(data[7]) || !IsPlayerConnected(data[8]) )
	{
	  DestroyDynamic3DTextLabel(sVehInfo[vehicleid][carActionLabel]);
      sVehInfo[vehicleid][carActionInProgress] = false;
	}
	new Float:tempX,
		Float:tempY,
		Float:tempZ,
		formattedMsg[128];
	// -- Sprawdzanie dla w³aœciciela
	GetPlayerPos(data[7], tempX, tempY, tempZ);
	if( GetVehicleDistanceFromPoint(vehicleid, tempX, tempY, tempZ) > 15.0 && !data[9] )
	{
         format( formattedMsg, 128, "PLERP.net: Nie odchodŸ od pojazdu zbyt daleko inaczej naprawa zostanie anulowana!" );
         SendClientMessage(data[7], COLOR_RED, formattedMsg);
		 data[9] = 1;
	}
	if( GetVehicleDistanceFromPoint(vehicleid, tempX, tempY, tempZ) > 25.0 )
	{
         format( formattedMsg, 128, "PLERP.net: Naprawa pojazdu zosta³a anulowana, poniewa¿ odszed³eœ zbyt daleko!" );
         SendClientMessage(data[7], COLOR_RED, formattedMsg);
         format( formattedMsg, 128, "PLERP.net: Naprawa pojazdu zosta³a anulowana, poniewa¿ gracz odszed³ zbyt daleko od pojazdu!" );
         SendClientMessage(data[8], COLOR_RED, formattedMsg);
         
         DestroyDynamic3DTextLabel(sVehInfo[vehicleid][carActionLabel]);
         sVehInfo[vehicleid][carActionInProgress] = false;
	}
	// -- Sprawdzanie dla pracownika
	GetPlayerPos(data[8], tempX, tempY, tempZ);
	if( GetVehicleDistanceFromPoint(vehicleid, tempX, tempY, tempZ) > 15.0 && !data[10] )
	{
         format( formattedMsg, 128, "PLERP.net: Nie odchodŸ od pojazdu zbyt daleko inaczej naprawa zostanie anulowana!" );
         SendClientMessage(data[8], COLOR_RED, formattedMsg);
		 data[10] = 1;
	}
	if( GetVehicleDistanceFromPoint(vehicleid, tempX, tempY, tempZ) > 25.0 )
	{
         format( formattedMsg, 128, "PLERP.net: Naprawa pojazdu zosta³a anulowana, poniewa¿ odszed³eœ zbyt daleko!" );
         SendClientMessage(data[8], COLOR_RED, formattedMsg);
         format( formattedMsg, 128, "PLERP.net: Naprawa pojazdu zosta³a anulowana, poniewa¿ gracz odszed³ zbyt daleko od pojazdu!" );
         SendClientMessage(data[7], COLOR_RED, formattedMsg);

         DestroyDynamic3DTextLabel(sVehInfo[vehicleid][carActionLabel]);
         sVehInfo[vehicleid][carActionInProgress] = false;
	}
	new formattedLabel[64];
	format( formattedLabel, 64, "Naprawa pojazdu\n%.1f%", floatmul(data[1], floatdiv( 100, data[6])));
    UpdateDynamic3DTextLabelText(sVehInfo[vehicleid][carActionLabel], 0x509906FF, formattedLabel);
	defer RepairVehicleScene(vehicleid, data, len);
  }
  else
  {
	// -- check if player has money again
	if( pInfo[data[7]][cash] < data[4]+data[5] )
    {
       SendClientMessage(data[7], COLOR_GREY, "PLERP.net: Gracz, któremu naprawia³eœ pojazd nie mia³ wystarczaj¹cej iloœci pieniêdzy aby op³aciæ naprawê.");
	   SendClientMessage(data[7], COLOR_GREY, "PLERP.net: Nie masz wystarczaj¹cej iloœci pieniêdzy, aby op³aciæ naprawê pojazdu.");
	   DestroyDynamic3DTextLabel(sVehInfo[vehicleid][carActionLabel]);
       sVehInfo[vehicleid][carActionInProgress] = false;
    }
	AddPlayerMoney(data[7], -(data[4]+data[5]));
	AddPlayerMoney(data[8], data[4]);
	sVehInfo[vehicleid][health] = 1000.0;
	SetVehicleHealth(vehicleid, 1000.0);
	sVehInfo[vehicleid][destroyed] = 0;
	sVehInfo[vehicleid][vDamagePanels] = 0;
	sVehInfo[vehicleid][vDamageTires] = 0;
	sVehInfo[vehicleid][vDamageDoors] = 0;
	sVehInfo[vehicleid][vDamageLights] = 0;
	UpdateVehicle(vehicleid);
	SaveVehicle(vehicleid);
    DestroyDynamic3DTextLabel(sVehInfo[vehicleid][carActionLabel]);
    sVehInfo[vehicleid][carActionInProgress] = false;
    
	ShowPlayerDialog(data[7], 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("Oferty"), "Naprawa pojazdu zosta³a pomyœlnie zakoñczona.", "Zamknij", "");
	ShowPlayerDialog(data[8], 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("Oferty"), "Naprawa pojazdu zosta³a pomyœlnie zakoñczona.", "Zamknij", "");
  }
  
}

timer RefillVehicleScene[1000](vehicleid, data[], len)
{
  new formattedLabel[64];
  data[0] -= 1000;
  data[1] += 1;
  if( data[0] > 0 )
  {
	// -- Check if player is online -- //
	if( pInfo[data[5]][uid] != data[2] || pInfo[data[5]][logged] == 0 || !IsPlayerConnected(data[5]) ) 
	{
	  DestroyDynamic3DTextLabel(sVehInfo[vehicleid][carActionLabel]);
	  sVehInfo[vehicleid][carActionInProgress] = false;
	}

	format( formattedLabel, 64, "Tankowanie pojazdu\n%.0f%", floatmul(data[1], floatdiv( 100, data[4])));	
    UpdateDynamic3DTextLabelText(sVehInfo[vehicleid][carActionLabel], 0x509906FF, formattedLabel);
	defer RefillVehicleScene(vehicleid, data, len);
  }
  else
  {
	// -- check if player has money again
	if( pInfo[data[5]][cash] < floatround(data[3]*PALIWO_CENA, floatround_ceil) )
    {
	   SendClientMessage(data[5], COLOR_GREY, "PLERP.net: Nie masz wystarczaj¹cej iloœci pieniêdzy, aby op³aciæ tankowanie pojazdu.");
	   DestroyDynamic3DTextLabel(sVehInfo[vehicleid][carActionLabel]);
	   sVehInfo[vehicleid][carActionInProgress] = false;
    }
	
	AddPlayerMoney(data[5], -floatround(data[3]*PALIWO_CENA, floatround_ceil));
	new Float:fuelToSet = (GetVehicleCurrentFuel(vehicleid)+data[3]);
	if( floatcmp(fuelToSet, GetVehicleMaxFuel(vehicleid)) == 1 ) fuelToSet = GetVehicleMaxFuel(vehicleid);
    SetVehicleCurrentFuel(vehicleid, fuelToSet);
	if( IsPlayerInVehicle(data[5], vehicleid) ) UpdateVehicleFuelForPlayer(data[5]);
	SaveVehicle(vehicleid);
	
	ShowPlayerDialog(data[5], 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("Oferty"), "Tankowanie pojazdu zosta³o pomyœlnie zakoñczone.", "Zamknij", "");
    DestroyDynamic3DTextLabel(sVehInfo[vehicleid][carActionLabel]);
    sVehInfo[vehicleid][carActionInProgress] = false;
    ApplyAnimation(data[5], "CARRY", "putdwn105", 0.6, 0, 1, 1, 0, 1, 1);
	
  }
  
}

timer CheckAdminJail[1000](playerid)
{
        new ttime = gettime();
				
        if(ttime > pInfo[playerid][AJ_endtime])
        {
		        PlayerTextDrawHide(playerid, ajTime);
                stop pInfo[playerid][AJ_timer];
                SetPlayerVirtualWorld(playerid, 0);
                SendClientMessage(playerid, COLOR_GREEN, "Twoja kara dobieg³a koñca. Postaraj siê nie ³amaæ wiêcej zasad.");
                SpawnPlayer(playerid);
        }
		else
		{
		  new timeToEnd = pInfo[playerid][AJ_endtime] - ttime;
		  new bstring[50], TimeInMin = floatround((timeToEnd / 60), floatround_round);
		  format(bstring, sizeof(bstring), "do konca aj zostalo: ~r~%d ~w~min.", TimeInMin);
	
		  PlayerTextDrawHide(playerid, ajTime);
		  PlayerTextDrawSetString(playerid, ajTime, bstring);
		  PlayerTextDrawShow(playerid, ajTime);
		}
        return 1;
}
 
timer UpdateSpec[500](playerid, targetid)
{
        TextDrawDestroy(pInfo[playerid][spec_td_player]);
        TextDrawDestroy(pInfo[playerid][spec_td_id]);
        TextDrawDestroy(pInfo[playerid][spec_td_hp]);
        TextDrawDestroy(pInfo[playerid][spec_td_armor]);
        SpecTextdraw(playerid, targetid);
}
 
timer KickTimer[500](playerid)
{
        Kick(playerid);
}

timer HidePenaltyBar[500]()
{
        TextDrawDestroy(PenaltyTextDraw[0]);
        TextDrawDestroy(PenaltyTextDraw[1]);
        TextDrawDestroy(PenaltyTextDraw[2]);
        TextDrawDestroy(PenaltyTextDraw[3]);
}

timer Destroy3DText[2000](Text3D:id)
{
  DestroyDynamic3DTextLabel(id);
}

timer HideDoorsInfo[4000](playerid)
{
    PlayerTextDrawHide(playerid, DoorsInfo[0]);
	PlayerTextDrawHide(playerid, DoorsInfo[1]);
	PlayerTextDrawHide(playerid, DoorsInfo[2]);
	PlayerTextDrawHide(playerid, DoorsInfo[3]);
}

timer StopPlayerInjureEffect[1200](playerid)
{
  BuildPlayerAdnotations(playerid);
}

timer PlayerBW[1000](playerid)
{
	pInfo[playerid][bw] = pInfo[playerid][bw] - 1000;
	
	new bstring[50], TimeInMin = floatround((pInfo[playerid][bw] / 60000), floatround_round);
	format(bstring, sizeof(bstring), "do konca bw zostalo: ~g~%d ~w~min.", TimeInMin);
	
	PlayerTextDrawHide(playerid, bwTime);
	PlayerTextDrawSetString(playerid, bwTime, bstring);
	PlayerTextDrawShow(playerid, bwTime);
	
	if(pInfo[playerid][bw] == 0) 
	{
	    PlayerTextDrawHide(playerid, bwTime);
		stop pInfo[playerid][bw_timer];
		TogglePlayerControllable(playerid, 1);
		ClearAnimations(playerid);
		PlayerTextDrawHide(playerid, pInfo[playerid][td_bw]);
		SetCameraBehindPlayer(playerid);
		pInfo[playerid][bwStatus] +=1;
		pInfo[playerid][health] = 5.0;
		SetPlayerHealth(playerid, 5.0);
		BuildPlayerAdnotations(playerid);
		SendClientMessage(playerid, COLOR_GREEN, "Odzyska³eœ przytomnoœæ, lecz pamiêtaj ¿e wci¹¿ jesteœ os³abiony. Udaj siê do szpitala w celu odzyskania pe³nej sprawnoœci.");
	}
}

ptask UpdateTimeAndWeather[60000](playerid)
{
    gettime(hour, minute);
   	SetWorldTime(hour);
	
	if(IsPlayerConnected(playerid) && GetPlayerState(playerid) != PLAYER_STATE_NONE)
	{
      SetPlayerTime(playerid,hour,minute);
	}
}

task VehiclesUpdate[500]()
{
   foreach (new v : Vehicles)
   {
	 new Float:h;
	 GetVehicleHealth(v, h);
	 if( h > sVehInfo[v][health] )
	 {
	  // -- Player cheated and healed car, kick him and setup car health again -- //
	  String->Format("(vI:%d|oH:%f|nH:%f)", v, sVehInfo[v][health], h);
      SetVehicleHealth(v, sVehInfo[v][health]);
	  AddPlayerPenalty(GetVehicleDriver(v), INVALID_PLAYER_ID, PENALTY_TYPE_KICK, "Health cheat", formatted);
	 } else { sVehInfo[v][health] = h; }
	 
	 new tmpDMG[4];
	 GetVehicleDamageStatus(v, tmpDMG[0], tmpDMG[1], tmpDMG[2], tmpDMG[3]);
	 if( (sVehInfo[v][vDamagePanels] + sVehInfo[v][vDamageDoors] + sVehInfo[v][vDamageLights] + sVehInfo[v][vDamageTires]) < (tmpDMG[0]+tmpDMG[1]+tmpDMG[2]+tmpDMG[3]) )
	 {
	   SendClientMessage(GetVehicleDriver(v), -1, "cheat!!");
	 }
	 sVehInfo[v][vDamagePanels] = tmpDMG[0];
	 sVehInfo[v][vDamageDoors] = tmpDMG[1];
	 sVehInfo[v][vDamageLights] = tmpDMG[2];
	 sVehInfo[v][vDamageTires] = tmpDMG[3];

     if( sVehInfo[v][engine] == true )
	 {
	   // -- THE MILEAGE COUNTING -- //
	   new Float:currentPos[3], Float:distance;
	   // -- Get the current position -- //
       GetVehiclePos(v, currentPos[0], currentPos[1], currentPos[2]);
	   distance = 0.0;
       if( sVehInfo[v][oldPos][0] != 0 && sVehInfo[v][oldPos][1] != 0 && sVehInfo[v][oldPos][2] != 0 )
       {
		  distance = GetVehicleDistanceFromPoint(v, sVehInfo[v][oldPos][0], sVehInfo[v][oldPos][1], sVehInfo[v][oldPos][2]);
		  sVehInfo[v][mileage] += distance;
       }
	   // -- Save the actual position -- //
	   sVehInfo[v][oldPos][0] = currentPos[0];
	   sVehInfo[v][oldPos][1] = currentPos[1];
	   sVehInfo[v][oldPos][2] = currentPos[2];
	   // ------------------------ //

	   // -- THE FUEL USAGE -- //
       UpdateFuelConsume(v, distance);
	   // -------------------- //
	   
	   // -- CHANCE TO STOP ENGINE -- //
	   if( sVehInfo[v][health] <= 400.0 )
	   {
		 if( PercentageChance(0.01) == 1 )
		 {
           new driver = GetVehicleDriver(v);
           SetVehicleCurrentFuel(v, 0.0);
           sVehInfo[v][engine] = false;
	       PlayerTextDrawShow(driver, carBarHud);
           UpdateVehicle(v);
		 }
	   }
	   // --------------------- //
	 }



   }
   return 1;
}

ptask TimeOnlineAndAFK[1000](playerid)
{
  // -- Time Online Counting -- //
  if( pInfo[playerid][logged] == 1 )
  {
	if( pInfo[playerid][lastActivity] == 0 ) return;
	GivePlayerMoney(playerid, (pInfo[playerid][cash] - GetPlayerMoney(playerid)) );
	
	if( gettime() - pInfo[playerid][lastActivity] < 5 )
	{
	  // -- IF PLAYER ISN'T AFK THEN REMOVE THE ADNOTATION -- //
	  if( pInfo[playerid][isAFK] )
	  {
		 pInfo[playerid][isAFK] = false;
		 BuildPlayerAdnotations(playerid);
	  }
      pInfo[playerid][timeOnline] += 1;
    }
    else
    {
	   pInfo[playerid][isAFK] = true;
	   BuildPlayerAdnotations(playerid);
    }
  }
}

ptask PhoneCallsCleanup[1000](playerid)
{
  if( pCall[playerid][cState] > 0 )
  {
	switch(pCall[playerid][cState])
	{
	  case 1:
	  {
	    if( pCall[playerid][cReceiver] < 0 )
		{
		   if( pCall[playerid][cReceiver] == -911 && (gettime() - pCall[playerid][cStarted]) >= 5  )
		   {
		     // -- Setup Caller -- //
	         PlayerTextDrawHide(playerid, phoneBarUpper[0]);
             PlayerTextDrawSetString(playerid, phoneBarUpper[0], "     Czas trwania: 00:00");
             PlayerTextDrawShow(playerid, phoneBarUpper[0]);
             PlayerTextDrawHide(playerid, phoneBarUpper[1]);
		
             SendClientMessage(playerid, COLOR_GREEN, "E911: Centrum numerów alarmowych, proszê okreœliæ rodzaj s³u¿b jakie mamy powiadomiæ. LSPD czy Pogotowie?");
             pInfo[playerid][t_911] = 1;

             pCall[playerid][cState] = 2;
		   }
		}
	    else
		{
		  if( (gettime() - pCall[playerid][cStarted]) >= 15 && pCall[playerid][cCaller] == playerid )
		  {
		    // halt the call down - reason: receiver do not response
		  
            // -- Setup Caller -- //
	        PlayerTextDrawHide(playerid, phoneBarUpper[0]);
            PlayerTextDrawSetString(playerid, phoneBarUpper[0], "     Brak odpowiedzi");
            PlayerTextDrawShow(playerid, phoneBarUpper[0]);
            PlayerTextDrawHide(playerid, phoneBarUpper[2]);

            // -- Setup Receiver -- //
	        PlayerTextDrawHide(pCall[playerid][cReceiver], phoneBarUpper[0]);
            PlayerTextDrawSetString(pCall[playerid][cReceiver], phoneBarUpper[0], "     Polaczenie przerwane");
            PlayerTextDrawShow(pCall[playerid][cReceiver], phoneBarUpper[0]);
            PlayerTextDrawHide(pCall[playerid][cReceiver], phoneBarUpper[2]);
            PlayerTextDrawHide(pCall[playerid][cReceiver], phoneBarUpper[1]);
		  
		    pCall[playerid][cState] = 3;
		    pCall[pCall[playerid][cReceiver]][cState] = 3;
		  
		    defer ResetPlayerCall(playerid);
		    defer ResetPlayerCall(pCall[playerid][cReceiver]);
		  }
		}
	  }
	  
	  case 2:
	  {
		pCall[playerid][cTime] += 1;
        PlayerTextDrawHide(playerid, phoneBarUpper[0]);
        new tmpstr[64];
        format(tmpstr, 64, "     Czas trwania: %d:%d", pCall[playerid][cTime]/60, pCall[playerid][cTime]%60);
        PlayerTextDrawSetString(playerid, phoneBarUpper[0], tmpstr);
        PlayerTextDrawShow(playerid, phoneBarUpper[0]);
	  }
	  
	  case 4:
	  {
        defer ResetPlayerCall(playerid);
	  }
	}
  }
}

ptask GroupsDuty[1000](playerid)
{
  if( pInfo[playerid][currentDuty] != -1 && !pInfo[playerid][isAFK] && pInfo[playerid][logged] == 1 )
  {
    new grId = pGroups[playerid][pInfo[playerid][currentDuty]][groupIndx];
	new doorsId = -1;
	if( GetPlayerVirtualWorld(playerid) > 0 && pInfo[playerid][hotelOutdoor] == 0 )
	{
	  doorsId = GetDoorsByUid(GetPlayerVirtualWorld(playerid));
	}
	
	if( doorsId > -1 )
	{
	  if( doors[doorsId][type] == 0 && doors[doorsId][owner] == groups[grId][grid] )
	  {
		  return CountDuty(playerid, pInfo[playerid][currentDuty]);
	  }
	}
	switch( groups[grId][type] )
	{
	      case 0:
		  {
		    CountDuty(playerid, pInfo[playerid][currentDuty]);
		  }
		  
		  case 2:
		  {
		    new vID = GetPlayerVehicleID(playerid);
			if( vID > -1 )
			{
			  if( sVehInfo[vID][ownertype] == 1 && groups[GetGroupByUid(sVehInfo[vID][owner])][type] == 2 ) CountDuty(playerid, pInfo[playerid][currentDuty]);
			}
		  }
	}
  }
  
  return 1;
}

stock CountDuty(playerid, grSlot)
{
  pGroups[playerid][grSlot][dutyTime] += 1;
  new tmpstr[64];
  format(tmpstr, 64, "%dm %ds", pGroups[playerid][grSlot][dutyTime]/60, pGroups[playerid][grSlot][dutyTime]%60);
  
  return 1;
}

timer ResprayTimer[1000](playerid,vehicleid)
{
   if(GetPlayerWeapon(playerid) == 41 && GetClosestVehicle(playerid) == vehicleid && pInfo[playerid][firehold] == 1)
   {
      if(IsPlayerFacingVehicle(playerid,vehicleid))
	  {
         ChangeVehicleColor(GetClosestVehicle(playerid),random(127),random(127));
         GameTextForPlayer(playerid,"~g~Respray sucessfull",3000,4);
      }
   }
   return 1;
}

timer Paralizator[500](playerid)
{
        TogglePlayerControllable(playerid, 1);
        ClearAnimations(playerid);
}

timer Hide911[500](typee)
{
        foreach(Player, i)
        {
                if(IsPlayerInGroupType(i, typee))
                {
                        TextDrawHideForPlayer(i, td_911);
                }
        }
}
timer BusPrzenies[500](playerid)
{
	TogglePlayerControllable(playerid, 1);
	SetCameraBehindPlayer(playerid);
	SetPlayerVirtualWorld(playerid, 0);
}