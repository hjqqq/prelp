stock HandleCallAction(playerid, action)
{
  if( pCall[playerid][cState] == 1 )
  {
	if( pCall[playerid][cCaller] == playerid )
	{
      // -- Setup Caller -- //
	  PlayerTextDrawHide(playerid, phoneBarUpper[0]);
      PlayerTextDrawSetString(playerid, phoneBarUpper[0], "     Zakonczono rozmowe");
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
      // -- Call reset -- //
      defer ResetPlayerCall(playerid);
      defer ResetPlayerCall(pCall[playerid][cReceiver]);
	}
	else
	{
      new secondTalker = GetSecondTalker(playerid);
	  if( action == 1 )
	  {
        // -- Setup Caller -- //
	    PlayerTextDrawHide(playerid, phoneBarUpper[0]);
        PlayerTextDrawSetString(playerid, phoneBarUpper[0], "     Czas trwania: 00:00");
        PlayerTextDrawShow(playerid, phoneBarUpper[0]);
        PlayerTextDrawHide(playerid, phoneBarUpper[1]);

        // -- Setup Receiver -- //
	    PlayerTextDrawHide(secondTalker, phoneBarUpper[0]);
        PlayerTextDrawSetString(secondTalker, phoneBarUpper[0], "     Czas trwania: 00:00");
        PlayerTextDrawShow(secondTalker, phoneBarUpper[0]);
        PlayerTextDrawHide(secondTalker, phoneBarUpper[1]);
		
        pCall[playerid][cState] = 2;
        pCall[secondTalker][cState] = 2;
		return;
	  }
	  // -- Setup Caller -- //
	  PlayerTextDrawHide(secondTalker, phoneBarUpper[0]);
      PlayerTextDrawSetString(secondTalker, phoneBarUpper[0], "     Numer zajêty");
      PlayerTextDrawShow(secondTalker, phoneBarUpper[0]);
      PlayerTextDrawHide(secondTalker, phoneBarUpper[2]);

      // -- Setup Receiver -- //
	  PlayerTextDrawHide(playerid, phoneBarUpper[0]);
      PlayerTextDrawSetString(playerid, phoneBarUpper[0], "     Zakonczono rozmowe");
      PlayerTextDrawShow(playerid, phoneBarUpper[0]);
      PlayerTextDrawHide(playerid, phoneBarUpper[2]);
      PlayerTextDrawHide(playerid, phoneBarUpper[1]);

      pCall[playerid][cState] = 3;
      pCall[secondTalker][cState] = 3;
      // -- Call reset -- //
      defer ResetPlayerCall(playerid);
      defer ResetPlayerCall(secondTalker);
	}
  }
  else if( pCall[playerid][cState] == 2 )
  {
    if( pCall[playerid][cReceiver] < 0 )
	{
	  // -- Setup Caller -- //
	  PlayerTextDrawHide(playerid, phoneBarUpper[0]);
      PlayerTextDrawSetString(playerid, phoneBarUpper[0], "     Zakonczono rozmowe");
      PlayerTextDrawShow(playerid, phoneBarUpper[0]);
      PlayerTextDrawHide(playerid, phoneBarUpper[2]);
	  
	  pCall[playerid][cState] = 3;
	  defer ResetPlayerCall(playerid);
	  return;
	}
    new secondTalker = GetSecondTalker(playerid);
	// -- Setup Caller -- //
	PlayerTextDrawHide(playerid, phoneBarUpper[0]);
    PlayerTextDrawSetString(playerid, phoneBarUpper[0], "     Zakonczono rozmowe");
    PlayerTextDrawShow(playerid, phoneBarUpper[0]);
    PlayerTextDrawHide(playerid, phoneBarUpper[2]);

    // -- Setup Receiver -- //
	PlayerTextDrawHide(secondTalker, phoneBarUpper[0]);
    PlayerTextDrawSetString(secondTalker, phoneBarUpper[0], "     Zakonczono rozmowe");
    PlayerTextDrawShow(secondTalker, phoneBarUpper[0]);
    PlayerTextDrawHide(secondTalker, phoneBarUpper[2]);
    PlayerTextDrawHide(secondTalker, phoneBarUpper[1]);

    pCall[playerid][cState] = 3;
    pCall[secondTalker][cState] = 3;
    // -- Call reset -- //
    defer ResetPlayerCall(playerid);
    defer ResetPlayerCall(secondTalker);
  }
}

stock AddCallToDatabase(pCaller, pReceiver, pWhen, pTime)
{
    new Query[200];
	format( Query, sizeof(Query), "INSERT INTO `phone_calls` SET `from`=%d, `to`=%d, `when`=%d, `time`=%d", pCaller, pReceiver, pWhen, pTime );
    mysql_function_query(mysqlHandle, Query, false, "", "");
}

stock HideUpperPhoneBar(playerid)
{
  PlayerTextDrawHide(playerid, phoneBarUpper[0]);
  PlayerTextDrawHide(playerid, phoneBarUpper[1]);
  PlayerTextDrawHide(playerid, phoneBarUpper[2]);
  PlayerTextDrawHide(playerid, phoneBarUpper[3]);
}

stock GetSecondTalker(playerid)
{
  if( pCall[playerid][cCaller] == playerid ) return pCall[playerid][cReceiver];
  return pCall[playerid][cCaller];
}

public PhoneContactsListQuery(playerid)
{
   new GUIcaption[64], contactsHeader[80], clist[360];
   new phoneIDX = pInfo[playerid][lastUsedPhone];
   format(GUIcaption, 64, "%s(%d) - Kontakty", Item[phoneIDX][name], Item[phoneIDX][value1]);
   new rows, fields;
   cache_get_data( rows, fields, mysqlHandle);
   format(contactsHeader, 80, "Wyœlij vCard\nIloœæ kontaktów: %d\n-------------", rows);
   if( rows > 0 )
   {
	  new cname[40],cnumber[10],crows[280];
	  for (new i = 0; i != rows; ++i)
      {
         cache_get_field_content(i, "name", cname);
         cache_get_field_content(i, "number", cnumber);
         
		 format(crows, sizeof(crows), "%s%s (%d)\n", crows, cname, strval(cnumber));
      }
      format( clist, 326, "%s\n%s", contactsHeader, crows );
	  ShowPlayerDialog(playerid, 31, DIALOG_STYLE_LIST, BuildGuiCaption(GUIcaption), clist, "Wybierz", "Zamknij");
   }
   else
   {
	  format( clist, 326, "%s\nBrak kontaktów", contactsHeader );
      ShowPlayerDialog(playerid, 31, DIALOG_STYLE_LIST, BuildGuiCaption(GUIcaption), clist, "Wybierz", "Zamknij");
   }
   return 1;
}
forward PhoneContactEditQuery(playerid, listitem);
public PhoneContactEditQuery(playerid, listitem)
{
  new rows, fields;
  cache_get_data( rows, fields, mysqlHandle);
  if( rows == 1 )
  {
    new cUid, cNumber, cName[64];
	cache_get_field_content(0, "uid", cName); cUid = strval(cName);
	cache_get_field_content(0, "number", cName); cNumber = strval(cName);
	cache_get_field_content(0, "name", cName);
	
	pInfo[playerid][t_dialogtmp1] = listitem;
	pInfo[playerid][t_dialogtmp2] = cUid;
	pInfo[playerid][t_dialogtmp3] = cNumber;
	
	new stringy[150];
	format(stringy, sizeof(stringy), "%s (%d)\n-------------------\nZadzwoñ\nWyœlij wiadomoœæ\nZmieñ nazwê\nUsuñ", cName, cNumber);
	
	ShowPlayerDialog(playerid, 112, DIALOG_STYLE_LIST, BuildGuiCaption("Telefon » Edycja kontaktu"), stringy, "Wybierz", "Zamknij");
  }
}

public PhoneCallsListQuery(playerid)
{
   new GUIcaption[64], clist[360];
   format(GUIcaption, 64, "Telefon » Spis po³¹czeñ");
   
   new rows, fields;
   cache_get_data( rows, fields, mysqlHandle);
   if( rows > 0 )
   {
	  /*new cname[40],cnumber[10],crows[280];
	  // -- TODO: Phone calls list format -- //
	  for (new i = 0; i != rows; ++i)
      {
         cache_get_field_content(i, "name", cname);
         cache_get_field_content(i, "from", cFrom);
		 cache_get_field_content(i, "to", cTo);
		 cache_get_field_content(i, "when", cWhen);
		 cache_get_field_content(i, "time", cTime);

		 format(crows, sizeof(crows), "%s%s [%d]\n", crows, cname, strval(cnumber));
      }
      format( clist, 326, "%s", crows );
	  ShowPlayerDialog(playerid, 32, DIALOG_STYLE_LIST, BuildGuiCaption(GUIcaption), clist, "Zamknij", "");*/
   }
   else
   {
	  format( clist, 326, "Brak po³¹czeñ" );
      ShowPlayerDialog(playerid, 32, DIALOG_STYLE_LIST, BuildGuiCaption(GUIcaption), clist, "Zamknij", "");
   }
   return 1;
}

forward PhoneMessagesListQuery(playerid);
public PhoneMessagesListQuery(playerid)
{
   new GUIcaption[64], clist[360];
   format(GUIcaption, 64, "Telefon » Przegl¹danie wiadomoœci");
   new phoneIDX = pInfo[playerid][lastUsedPhone];
   
   new rows, fields;
   cache_get_data( rows, fields, mysqlHandle);
   if( rows > 0 )
   {
      PlayerTextDrawHide(playerid, phoneBarUpper[4]);
	  new tempstr[100], cFrom, cTo, cWhen, cValue[200], cReaden, crows[300];
	  
	  for (new i = 0; i != rows; ++i)
      {
         cache_get_field_content(i, "from", tempstr); cFrom = strval(tempstr);
		 cache_get_field_content(i, "to", tempstr); cTo = strval(tempstr);
		 cache_get_field_content(i, "when", tempstr); cWhen = strval(tempstr);
		 cache_get_field_content(i, "readen", tempstr); cReaden = strval(tempstr);
		 cache_get_field_content(i, "value", cValue);
		 
		 format(tempstr, sizeof(tempstr), "");
		 if( !cReaden ) format(tempstr, sizeof(tempstr), "{FDDD2B}");
		 strmid(cValue, cValue, 0, 20);
		 format(cValue, sizeof(cValue), "%s...", cValue);
		 if( cFrom == Item[phoneIDX][value1] ) 
		 {
		   format(crows, sizeof(crows), "%s %s« %d [%s]  %s\n", crows, tempstr, cTo, FormatDataForShow(cWhen), cValue);
		 }  
		 else 
		 {
		   format(crows, sizeof(crows), "%s %s« %d [%s]  %s\n", crows, tempstr, cFrom, FormatDataForShow(cWhen), cValue);
		 }
      }
	  pInfo[playerid][t_dialogtmp3] = 1;
      format( clist, 326, "%s", crows );
	  ShowPlayerDialog(playerid, 117, DIALOG_STYLE_LIST, BuildGuiCaption(GUIcaption), clist, "Wybierz", "Zamknij");
   }
   else
   {
      pInfo[playerid][t_dialogtmp3] = 0;
	  format( clist, 326, "Brak wiadomoœci" );
      ShowPlayerDialog(playerid, 117, DIALOG_STYLE_LIST, BuildGuiCaption(GUIcaption), clist, "Zamknij", "");
   }
   return 1;
}

forward PhoneMessageDetailsQuery(playerid);
public PhoneMessageDetailsQuery(playerid)
{
   new GUIcaption[64];
   new phoneIDX = pInfo[playerid][lastUsedPhone];
   
   new rows, fields;
   cache_get_data( rows, fields, mysqlHandle);
   if( rows > 0 )
   {
	  new tempstr[100], cUid, cFrom, cTo, cWhen, cValue[200], cReaden, crow[300];
	  cache_get_field_content(0, "id", tempstr); cUid = strval(tempstr);
      cache_get_field_content(0, "from", tempstr); cFrom = strval(tempstr);
	  cache_get_field_content(0, "to", tempstr); cTo = strval(tempstr);
	  cache_get_field_content(0, "when", tempstr); cWhen = strval(tempstr);
	  cache_get_field_content(0, "readen", tempstr); cReaden = strval(tempstr);
	  cache_get_field_content(0, "value", cValue);
	  
	  new Query[200];
	  format( Query, sizeof(Query), "UPDATE phone_messages SET `readen`=1 WHERE `id`=%d", cUid );
      mysql_function_query(mysqlHandle, Query, false, "", "");
	  
	  format(tempstr, sizeof(tempstr), "");
	  if( !cReaden ) format(tempstr, sizeof(tempstr), "{FDDD2B}");
	  
	  if( cFrom == Item[phoneIDX][value1] ) 
	  {
	       format(GUIcaption, 64, "Telefon » Wiadomoœæ do %d", cTo);
		   format(crow, sizeof(crow), "                                                                        %s\nTreœæ wiadomoœci: \n%s", FormatDataForShow(cWhen), cValue);
	  }  
	  else 
	  {
	       format(GUIcaption, 64, "Telefon » Wiadomoœæ od %d", cFrom);
	 	   format(crow, sizeof(crow), "                                                                        %s\nTreœæ wiadomoœci: \n%s", FormatDataForShow(cWhen), cValue);
	  }
	  ShowPlayerDialog(playerid, 118, DIALOG_STYLE_MSGBOX, BuildGuiCaption(GUIcaption), crow, "Zamknij", "");
   }
   return 1;
}

stock SendPhoneMessage(playerid, phoneTo, phoneMessage[])
{
  SendPlayerInformation(playerid, "Wiadomosc zostala wyslana.");
  
  new Query[200];
  format( Query, sizeof(Query), "INSERT INTO `phone_messages` SET `from`=%d, `to`=%d, `date`=%d, `value`='%s'", Item[pInfo[playerid][lastUsedPhone]][value1], phoneTo, gettime(), phoneMessage );
  mysql_function_query(mysqlHandle, Query, false, "", "");
  
  new sendingTo = -1;
  foreach (new p : Player)
  {
	if( Item[pInfo[p][lastUsedPhone]][value1] == phoneTo && pInfo[p][logged] == 1 )
	{
		sendingTo = p;
	}
  }
  
  if( sendingTo > -1 )
  {
    PlayerTextDrawShow(playerid, phoneBarUpper[4]);
  }
}

stock OpenPhoneGUI(playerid, itemid)
{
  new GUIcaption[64];
  format(GUIcaption, 64, "%s » Menu", Item[itemid][name]);
  ShowPlayerDialog(playerid, 26, DIALOG_STYLE_LIST, BuildGuiCaption(GUIcaption), "Telefon\nWiadomoœci\nUstawienia", "Wybierz", "Zamknij");
  
  return 1;
}