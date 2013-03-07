stock GetDoorsByUid(doorsUID)
{
   foreach (new d : Doors)
   {
	  if( doors[d][doorUid] == doorsUID ) return d;
   }
   
   return -1;
}

stock ShowDoorsInfo(playerid, pickupid)
{
	// Hide
    PlayerTextDrawHide(playerid, DoorsInfo[0]);
	PlayerTextDrawHide(playerid, DoorsInfo[1]);
	PlayerTextDrawHide(playerid, DoorsInfo[2]);
	PlayerTextDrawHide(playerid, DoorsInfo[3]);
	
	// Show
	PlayerTextDrawShow(playerid, DoorsInfo[0]);
	PlayerTextDrawShow(playerid, DoorsInfo[1]);
	
	PlayerTextDrawSetString(playerid, DoorsInfo[2], doors[pickupid][name]);
	PlayerTextDrawShow(playerid, DoorsInfo[2]);
	
	if( doors[pickupid][payment] > 0 )
	{
	  new str[36];
	  format(str, 36, "~y~Wejscie: ~w~$%d", doors[pickupid][payment]);
	  PlayerTextDrawSetString(playerid, DoorsInfo[3], str);
	  PlayerTextDrawShow(playerid, DoorsInfo[3]);
	}
}

stock GetPlayerStandingInDoors(playerid)
{
   new tmpAr = GetPlayerDynamicDoors(playerid);
   if( tmpAr > -1  )
   {
     return areas[tmpAr][owner];
   }
   return -1;
}

stock OnPlayerVirtualWorldChange(playerid, areaId)
{
  
  PlayerTextDrawHide(playerid, afterDoorsInfo);
  // -- Setup radio -- //
  Audio_Stop(playerid, pInfo[playerid][radioHandle]);
  step2:
  // -- Change area -- //
  BuildPlayerAdnotations(playerid);
  if( areaId == -1 ) return 1;
  if( doors[areaId][type] != 1 )
  {
    new dOwnerIdx = GetGroupByUid(doors[areaId][owner]);
	PlayerTextDrawHide(playerid, afterDoorsInfo);
	
    if( groups[dOwnerIdx][type] == 8  )
	{
	  PlayerTextDrawSetString(playerid, afterDoorsInfo, "W hotelu mozesz korzystac z komendy /pokoj. Aby sie zameldowac wpisz /pokoj zamelduj.");
	  PlayerTextDrawShow(playerid, afterDoorsInfo);
	  defer HidePlayerTextDraw[5000](playerid, afterDoorsInfo);
	}
	
	if( groups[dOwnerIdx][type] == 5 )
	{
	  PlayerTextDrawSetString(playerid, afterDoorsInfo, "W sklepie mozesz kupic wiele przydatnych przedmiotow od telefonow, przez notesy az po akcesoria postaci i pojazdow. Aby skorzystac ze sklepu wpisz /kup.");
	  PlayerTextDrawShow(playerid, afterDoorsInfo);
	  defer HidePlayerTextDraw[10000](playerid, afterDoorsInfo);
	}
	
	if( groups[dOwnerIdx][type] == 10 && pInfo[playerid][bank] == 0 )
	{
	  PlayerTextDrawSetString(playerid, afterDoorsInfo, "Znajdujesz sis w banku i nie posiadasz zalozonego konta bankowego. Wystarczy, ze wpiszesz /bank a ukaze Ci sie informacja na temat korzystania z jego uslug.");
	  PlayerTextDrawShow(playerid, afterDoorsInfo);
	  defer HidePlayerTextDraw[10000](playerid, afterDoorsInfo);
	}
	
	if( groups[dOwnerIdx][type] == 11 )
	{
	  PlayerTextDrawSetString(playerid, afterDoorsInfo, "W sklepie z ciuchami mozesz kupic ubrania oraz dodatki postaci. Aby tego dokonac uzyj komendy /kup.");
	  PlayerTextDrawShow(playerid, afterDoorsInfo);
	  defer HidePlayerTextDraw[5000](playerid, afterDoorsInfo);
	}
  }
  
  return 1;
}

stock GetDoorsUsedObjects(doorsIdx)
{
   return Iter_Count(Objects_DOORS[doorsIdx]);
}

stock HasPermissionToEditDoors(playerid, areaId)
{	 // Group doors
     new isAdmin = IsPlayerInGroupType(playerid, 0); 
     if( isAdmin > -1 ) 
	 {
	   if( HasPlayerPermission(playerid, "group", GPREM_special, pGroups[playerid][isAdmin][groupIndx]) )  return true;
	 }

	 if( doors[areaId][type] == 0 || doors[areaId][type] == 2 )
	 {
		new doorsGroup = GetGroupByUid(doors[areaId][owner]);
		if( doorsGroup != -1 )
		{
		  new ownerUid = GetGroupLeader(doorsGroup);
		  if( ownerUid == pInfo[playerid][uid] )
		  {
             return true;
		  }
		}
	 }
	 else if( doors[areaId][type] == 3 )
	 {
	    new parentDoorsId = GetDoorsByUid(doors[areaId][owner]);
		return HasPermissionToEditDoors(playerid, parentDoorsId);
	 }
	 else
	 {
		if( doors[areaId][owner] == pInfo[playerid][uid] )
		{
           return true;
		}
	 }
	 return false;
}


stock GetClosestObjectWithType(playerid, modelID)
{
   new pretenderId, Float:pretenderDistance = 10.0;
   pretenderId = -1;
   new areaId = IsPlayerInAnyDynamicArea(playerid);
   if( GetPlayerVirtualWorld(playerid) > 0 )
   {
     foreach (new o : Objects_DOORS[GetDoorsByUid(GetPlayerVirtualWorld(playerid))])
     {
       if( objects[o][objectVW] == GetPlayerVirtualWorld(playerid) && objects[o][model] == modelID )
	   {
	     new Float:distance, Float:oX, Float:oY, Float:oZ;
	     GetDynamicObjectPos(o, oX, oY, oZ);
	     distance = GetPlayerDistanceFromPoint(playerid, oX, oY, oZ);
	     if( distance <= pretenderDistance && distance <= 10.0 )
	     {
	       pretenderDistance = distance;
		   pretenderId = o;
	     }
	   }
     }
   }
   else if( areaId )
   {
     foreach (new o : Objects_AREA[areaId])
     {
       if( objects[o][objectVW] == GetPlayerVirtualWorld(playerid) && objects[o][model] == modelID )
	   {
	     new Float:distance, Float:oX, Float:oY, Float:oZ;
	     GetDynamicObjectPos(o, oX, oY, oZ);
	     distance = GetPlayerDistanceFromPoint(playerid, oX, oY, oZ);
	     if( distance <= pretenderDistance && distance <= 10.0 )
	     {
	       pretenderDistance = distance;
		   pretenderId = o;
	     }
	   }
     }
   }
   else
   {
     foreach (new o : Objects_GLOBAL)
     {
       if( objects[o][objectVW] == GetPlayerVirtualWorld(playerid) && objects[o][model] == modelID )
	   {
	     new Float:distance, Float:oX, Float:oY, Float:oZ;
	     GetDynamicObjectPos(o, oX, oY, oZ);
	     distance = GetPlayerDistanceFromPoint(playerid, oX, oY, oZ);
	     if( distance <= pretenderDistance && distance <= 10.0 )
	     {
	       pretenderDistance = distance;
		   pretenderId = o;
	     }
	   }
     }
   }
   
   return pretenderId;
}

forward SetDoorsID(doorsId, area1, area2);
public SetDoorsID(doorsId, area1, area2)
{
      doors[doorsId][doorUid] = mysql_insert_id(mysqlHandle);
	  doors[doorsId][intSpawnVW] = doors[doorsId][doorUid];
	  areas[area1][uid] = doors[doorsId][doorUid];
	  areas[area2][uid] = doors[doorsId][doorUid];
      return 1;
}

forward SetObjectID(createdObject);
public SetObjectID(createdObject)
{
      objects[createdObject][objectUid] = mysql_insert_id(mysqlHandle);
	  if( objects[createdObject][owner_type] == OBJECT_OWNER_TYPE_DOORS ) Iter_Add(Objects_DOORS[GetDoorsByUid(objects[createdObject][owner])], createdObject);
	  if( objects[createdObject][owner_type] == OBJECT_OWNER_TYPE_GLOBAL ) Iter_Add(Objects_GLOBAL, createdObject);
      
      return 1;
}

stock UpdateObjectInfoTextDraw(playerid, objectid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
   PlayerTextDrawHide(playerid, objectInfoTd);
   new string[1000];
   format(string, sizeof(string), "~b~ID: ~w~%d ~b~MID: ~w~%d ~n~~b~X: ~w~%f ~n~~b~Y: ~w~%f ~n~~b~Z: ~w~%f ~n~~b~RX: ~w~%f ~n~~b~RY: ~w~%f ~n~~b~RZ: ~w~%f", objectid, objects[objectid][model], x, y, z, rx, ry, rz);
   PlayerTextDrawSetString(playerid, objectInfoTd, string);
   PlayerTextDrawShow(playerid, objectInfoTd);
}

stock Object_Remove(objId)
{
  DestroyDynamicObject(objId);
  new Query[456];
  format( Query, sizeof(Query), "DELETE FROM `objects` WHERE id='%d'", objects[objId][objectUid]);
  mysql_function_query(mysqlHandle, Query, false, "", "");
  
  if( objects[objId][owner_type] == OBJECT_OWNER_TYPE_DOORS ) Iter_Remove(Objects_DOORS[GetDoorsByUid(objects[objId][owner])], objId);
  if( objects[objId][owner_type] == OBJECT_OWNER_TYPE_GLOBAL ) Iter_Remove(Objects_GLOBAL, objId);
  
  if( objects[objId][model] == 2942 )
  {
    foreach (new area : Areas)
	{
	  if( areas[area][type] == AREA_TYPE_BANKOMAT && areas[area][owner] == objId )
	  {
	    DestroyDynamicArea(area);
		areas[area][type] = -1;
		areas[area][owner] = -1;
		DestroyDynamic3DTextLabel(areas[area][actionObjectLabel]);
	  }
	}
  }
  
}

stock Object_Create(owner_typeO, ownerO, omodel, ovw, Float:ox, Float:oy, Float:oz, Float:orotx, Float:oroty, Float:orotz)
{
       new Query[456];
       format( Query, sizeof(Query), "INSERT INTO `objects` (`id`, `owner_type`, `owner`, `model`, `vw`, `x`, `y`, `z`, `rotX`, `rotY`, `rotZ`) VALUES (null, '%d', '%d', '%d', '%d', '%f', '%f', '%f', '%f', '%f', '%f')", owner_typeO, ownerO, omodel, ovw, ox, oy, oz, orotx, oroty, orotz);
	   new createdObject = CreateDynamicObject(omodel, ox, oy, oz, orotx, oroty, orotz, ovw, 0, -1, OBJECTS_STREAM_DISTANCE);
       objects[createdObject][objectVW] = ovw;
	   objects[createdObject][owner_type] = owner_typeO;
	   objects[createdObject][owner] = ownerO;
	   objects[createdObject][model] = omodel;
	   mysql_function_query(mysqlHandle, Query, true, "SetObjectID", "d", createdObject);
	   
	   if( owner_typeO == OBJECT_OWNER_TYPE_DOORS ) Iter_Add(Objects_DOORS[GetDoorsByUid(ownerO)], createdObject);
       if( owner_typeO == OBJECT_OWNER_TYPE_GLOBAL ) Iter_Add(Objects_GLOBAL, createdObject);
	   
	   foreach (new p : Player)
	   {
	     Streamer_UpdateEx(p, ox, oy, oz, ovw);
	   }
	   
	   PrepareActionObject(createdObject);

	   return createdObject;
}


forward StoreToBuy(playerid);
public StoreToBuy(playerid)
{
	new rows, fields, string[64], dint[2], bigstring[512];
	cache_get_data(rows, fields, mysqlHandle);
	if(!rows) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "B³¹d", "Hurtownia jest pusta.", "Zamknij", "");
	for (new i; i<rows; i++)
	{
		cache_get_field_content(i, "uid", string);
		dint[0] = strval(string);			
		cache_get_field_content(i, "price", string);
		dint[1] = strval(string);
		cache_get_field_content(i, "name", string);
		format(string, sizeof(string), "\n%i\t%s CENA: %i", dint[0], string, dint[1]);
		strcat(bigstring, string);
	}
	if(strlen(bigstring) > sizeof(bigstring)) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "B³¹d", "Wyst¹pi³ b³¹d poinformuj nas o nim na forum, b¹dŸ w grze, pozwól innym korzystaæ z magazynu :) \nPewno senga doda³ za du¿o przedmiotów, nie informuj¹c mnie o tym :(", "Zamknij", "");
	ShowPlayerDialog(playerid, 141, DIALOG_STYLE_LIST, "Magazyn -> Lista przedmiotów", bigstring, "Wybierz", "Cofnij");
	return 1;
}


stock PrepareActionObject(obID, posChange=0)
{
  if( objects[obID][model] == 2942 )
  {
    new Float:obX, Float:obY, Float:obZ, bankomatId;
	GetDynamicObjectPos(obID, obX, obY, obZ);
	
	if( posChange )
    { 
      foreach (new area : Areas)
	  {
	    if( areas[area][type] == AREA_TYPE_BANKOMAT && areas[area][owner] == obID )
		{
		  DestroyDynamicArea(area);
		  DestroyDynamic3DTextLabel(areas[area][actionObjectLabel]);
		  areas[area][type] = -1;
		  areas[area][owner] = -1;
		  break;
		}
	  }
    }	
	
    bankomatId = CreateDynamicSphere(obX, obY, obZ, 3.0, objects[obID][objectVW]);
	areas[bankomatId][uid] = -1;
	areas[bankomatId][type] = AREA_TYPE_BANKOMAT;
	areas[bankomatId][owner] = obID;
	areas[bankomatId][actionObjectLabel] = CreateDynamic3DTextLabel("(( /bankomat ))", 0x33BDFFFF, obX, obY, obZ+0.4, 4.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, objects[obID][objectVW]);
	Iter_Add(Areas, bankomatId);
  }
}

stock DeleteRenterFromDoors(doorsId, renterid)
{
   Iter_Remove(Doors_Renters[doorsId], pInfo[renterid][uid]);
   
   new rstring[500];
   foreach (new renter : Doors_Renters[doorsId])
   {
     if( strlen(rstring) > 0 ) format(rstring, sizeof(rstring), "%s, %d", rstring, renter);
	 else format(rstring, sizeof(rstring), "%d", renter);
   }
   
   new Query[456];
   format( Query, sizeof(Query), "UPDATE `doors` SET `renters`='%s' WHERE uid='%d'", rstring, doors[doorsId][doorUid]);
   mysql_function_query(mysqlHandle, Query, false, "", "");
   
   format( Query, sizeof(Query), "UPDATE `characters` SET `baseSpawn`='0,10.0,10.0,10.0' WHERE uid='%d'", pInfo[renterid][uid]);
   mysql_function_query(mysqlHandle, Query, false, "", "");
   
   format(pInfo[renterid][baseSpawn], 158, "0,10.0,10.0,10.0");
}

stock AddRenterToDoors(doorsId, renterid)
{
   Iter_Add(Doors_Renters[doorsId], pInfo[renterid][uid]);
   
   new rstring[500];
   foreach (new renter : Doors_Renters[doorsId])
   {
     if( strlen(rstring) > 0 ) format(rstring, sizeof(rstring), "%s, %d", rstring, renter);
	 else format(rstring, sizeof(rstring), "%d", renter);
   }
   
   new Query[456];
   format( Query, sizeof(Query), "UPDATE `doors` SET `renters`='%s' WHERE uid='%d'", rstring, doors[doorsId][doorUid]);
   mysql_function_query(mysqlHandle, Query, false, "", "");
}
forward StoreToBuyS2(playerid, ilosc);
public StoreToBuyS2(playerid, ilosc)
{
	new rows, fields, string[64], dint[6], zapytanie[250];
	cache_get_data(rows, fields, mysqlHandle);
	if(!rows) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "B³¹d", "Wyst¹pi³ b³¹d", "Zamknij", "");
	cache_get_field_content(0, "price", string);
	dint[0] = strval(string);
	if(dint[0]*ilosc > groups[pInfo[playerid][t_dialogtmp2]][bank]) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "B³¹d", "Twoja grupa nie posiada wystarczaj¹cej gotówki.", "Zamknij", "");
	AddGroupMoney(pInfo[playerid][t_dialogtmp2], -dint[0]*ilosc);
	cache_get_field_content(0, "type", string);
	dint[1] = strval(string);//Typ przedmiotu	
	cache_get_field_content(0, "value1", string);
	dint[2] = strval(string);//Value 1	
	cache_get_field_content(0, "value2", string);
	dint[3] = strval(string);//Value 2
	cache_get_field_content(0, "modellook", string);
	dint[4] = strval(string);//moodellook
	cache_get_field_content(0, "name", string);
	format(zapytanie, sizeof(zapytanie), "INSERT INTO `plerp_items` SET `owner_id` = %i, `owner_type` = %i, `value1` = %i, `value2`= %i, `modellook` = %i, `name` = '%s', `count` = %i, `price` = %i, `type` = %i", pInfo[playerid][t_dialogtmp4], 9, dint[2], dint[3], dint[4], string, ilosc, pInfo[playerid][t_dialogtmp3], dint[1]);
	mysql_function_query(mysqlHandle, zapytanie, false, "", "");
	ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Magazyn", "Przedmioty zosta³e pomyœlnie dodane do magazynu.\nPoczekaj, a¿ firma transportowa przywiezie dany produkt do Twojej firmy, dopiero wtedy pojawi siê on magazynie Twojej grupy.", "Zamknij", "");
	return 1;
}