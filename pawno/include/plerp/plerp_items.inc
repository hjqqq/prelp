#define USED_DIALOG_ITEM 24

#define OWNER_TYPE_PLAYER        1
#define OWNER_TYPE_GROUND        2
#define OWNER_TYPE_CAR           3
#define OWNER_TYPE_DOORS         4
#define OWNER_TYPE_WAREHOUSE     5
#define OWNER_TYPE_CAR_COMPONENT 6
#define OWNER_TYPE_ODDER_ITEM    7

#define ITEM_TYPE_PHONE   1
#define ITEM_TYPE_NOTEPAD 2
#define ITEM_TYPE_PAPER   3
#define ITEM_TYPE_ATTACH  4
#define ITEM_TYPE_CLOTHES 5
#define ITEM_TYPE_GUN     6
#define ITEM_TYPE_AMMO    7
#define ITEM_TYPE_FOOD    8
#define ITEM_TYPE_DRINKS  9
#define ITEM_TYPE_CORPSE  10
#define ITEM_TYPE_CIGG    11
#define ITEM_TYPE_DISC    12
#define ITEM_TYPE_MP3     13
#define ITEM_TYPE_ARMOR   14        
GetItemIDXByKOLGROUND(IDX, playerid)
{
    new liczba, idprzedmiotu = -1, virtualworld = GetPlayerVirtualWorld(playerid);

    foreach( new idee : Items_GROUND)
    {
               
        if(IsPlayerInRangeOfPoint(playerid, 5.00, Item[idee][pos_x], Item[idee][pos_y], Item[idee][pos_z]) &&  virtualworld == Item[idee][pos_vw])
        {
            liczba += 1;
        }
        if(liczba == IDX+1)
        {
            idprzedmiotu = idee;
            break;
        }
       
    }
    if(idprzedmiotu == -1) return 1;
	
    new zapytanie[128];
    Iter_Remove(Items_GROUND, idprzedmiotu);
    Iter_Add(Items_PLAYER[pInfo[playerid][uid]], idprzedmiotu);
    Item[idprzedmiotu][owner_type] = 1;
    Item[idprzedmiotu][owner_id] = pInfo[playerid][uid];
    DestroyDynamicObject(Item[idprzedmiotu][idobject]);
    format(zapytanie, sizeof(zapytanie), "UPDATE `plerp_items` SET `owner_id` = %i, `owner_type` = 1 WHERE `uid` = %i", pInfo[playerid][uid], Item[idprzedmiotu][uid]);
    mysql_function_query(mysqlHandle, zapytanie, false, "", "");
    format(zapytanie, sizeof(zapytanie), "Podnios³es przedmiot o uid %i", Item[idprzedmiotu][uid]);
    SendClientMessage(playerid, -1, zapytanie);
    return -1;
}

GetItemIDXByKOLCAR(IDX, playerid)
{
    new liczba, idprzedmiotu = -1;
    new vID = GetPlayerVehicleID(playerid);
    foreach( new idee : Items_GROUND_VEH[sVehInfo[vID][uid]])
    {
        liczba += 1;
        if(liczba == IDX+1)
        {
            idprzedmiotu = idee;
            break;
        }
       
    }
    if(idprzedmiotu == -1) return 1;
	
    new zapytanie[128];
    Iter_Remove(Items_GROUND_VEH[sVehInfo[vID][uid]], idprzedmiotu);
    Iter_Add(Items_PLAYER[pInfo[playerid][uid]], idprzedmiotu);
    Item[idprzedmiotu][owner_type] = 1;
    Item[idprzedmiotu][owner_id] = pInfo[playerid][uid];
    format(zapytanie, sizeof(zapytanie), "UPDATE `plerp_items` SET `owner_id` = %i, `owner_type` = 1 WHERE `uid` = %i", pInfo[playerid][uid], Item[idprzedmiotu][uid]);
    mysql_function_query(mysqlHandle, zapytanie, false, "", "");
    format(zapytanie, sizeof(zapytanie), "Podnios³es przedmiot o uid %i", Item[idprzedmiotu][uid]);
    SendClientMessage(playerid, -1, zapytanie);
    return -1;
}

GetItemIDXByKOL(playeruid, IDX)
{
	new liczba;
	foreach (new idee : Items_PLAYER[playeruid])
	{
		if(liczba == IDX)
		{
		return idee;
		}
		liczba++;
	}
	return -1;
}
ItemInfo(IDX, playerid)
{
	CancelSelectTextDraw(playerid);
	new string[30];
	format(string, sizeof(string), "ITEM INFO: UID %i",Item[IDX][uid]);
	SendClientMessage(playerid, -1, string);

}
ItemUse(IDX, playerid)
{
	CancelSelectTextDraw(playerid);
	new string[64];
	format(string, sizeof(string), "Uzy³eœ przedmiot u uid %i", Item[IDX][uid]);
	SendClientMessage(playerid, -1, string);
	switch(Item[IDX][type])
	{
		case ITEM_TYPE_PHONE: //Telefon
		{
		  if( pInfo[playerid][lastUsedPhone] == -1 && Item[IDX][used] == 0 )
		  {
		    pInfo[playerid][lastUsedPhone] = IDX;
			Item[IDX][used] = 1;
			new zapytanie[128];
			format(zapytanie, sizeof(zapytanie), "UPDATE `plerp_items` SET `value2`='1' WHERE `uid` = %i", Item[IDX][uid]);
	        mysql_function_query(mysqlHandle, zapytanie, false, "", "");
		  }
		  else if( pInfo[playerid][lastUsedPhone] == IDX && Item[IDX][used] == 1 && pCall[playerid][cState] == 0 )
		  {
            pInfo[playerid][lastUsedPhone] = -1;
			Item[IDX][used] = 0;
			new zapytanie[128];
			format(zapytanie, sizeof(zapytanie), "UPDATE `plerp_items` SET `value2`='0' WHERE `uid` = %i", Item[IDX][uid]);
	        mysql_function_query(mysqlHandle, zapytanie, false, "", "");
		  }
		  else if( pInfo[playerid][lastUsedPhone] != IDX )
		  {
		    SendClientMessage(playerid, -1, "{FF4137}[System] {FFFFFF}Masz ju¿ aktywny inny telefon.");
		  }
		}
		
		case ITEM_TYPE_NOTEPAD: //Notatnik
        {
            Item[IDX][value1] -= 1;
            if(!Item[IDX][value1])
            {
                ItemRemove(IDX);
            }
            else
            {
                new zapytanie[120];
                format(zapytanie, sizeof(zapytanie), "UPDATE `plerp_items` SET `value1` = %i WHERE `uid` = %i", Item[IDX][value1], Item[IDX][uid]);
                mysql_function_query(mysqlHandle, zapytanie, false, "", "");
            }
            ShowPlayerDialog(playerid, 45, DIALOG_STYLE_INPUT, "Tworzenie karteczki", "Poni¿ej podaj treœæ jak¹ ma zawieraæ karteczka", "Ok", "");
                       
        }
		
        case ITEM_TYPE_PAPER:  //Karteczka PIPECZKA HUAHAHAHH I TAK TEGO NIKT NIE CZYTA HUAHAHAH
        {
            new zapytanie[64];
            format(zapytanie, sizeof(zapytanie), "SELECT `content` FROM `plerp_karteczki` WHERE `uid` = %i", Item[IDX][value1]);
            mysql_function_query(mysqlHandle, zapytanie, true, "PokazKarteczke", "ii", playerid, IDX);
               
        }
		
		case ITEM_TYPE_ATTACH:
  	  	{
   	  	  if(!Item[IDX][used])//U¿ycie
   	  	  {
      	    if(!Item[IDX][value2])
       	    {
        	   Item[IDX][value2] = 1;
        	   new zapytanie[128];
        	   format(zapytanie, sizeof(zapytanie), "UPDATE `plerp_items` SET `value2`='1' WHERE `uid` = %i", Item[IDX][uid]);
        	   mysql_function_query(mysqlHandle, zapytanie, false, "", "");
        	   format(zapytanie, sizeof(zapytanie), "SELECT * FROM `plerp_atach` WHERE `uid` = %i", Item[IDX][value1]);
        	   mysql_function_query(mysqlHandle, zapytanie, true, "AttachItemFirstUse", "i", IDX);
       	    }
       	    pInfo[playerid][t_dialogtmp1] = IDX;
       	    ShowPlayerDialog(playerid, 46, DIALOG_STYLE_MSGBOX, "Obiekty przyczepialne - Opcje", "Wybierz opcje\t\t\t\t\t\t\t\t\t\t\t", "Za³ó¿", "Edytuj pozycje");
      	  }
      	  else
      	  {
       	     Item[IDX][used] = 0;
       	     RemovePlayerAttachedObject(playerid, Item[IDX][tmpvalue][0]);
          }
        }
		
		case ITEM_TYPE_CLOTHES:
		{
		  if(!Item[IDX][used])//U¿ycie
   	  	  {
		    if( pInfo[playerid][activeClothes] >= 0 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Aktualnie masz inne aktywne ubranie.");
			
			pInfo[playerid][activeClothes] = IDX;
			Item[IDX][used] = 1;
			new zapytanie[128];
        	format(zapytanie, sizeof(zapytanie), "UPDATE `plerp_items` SET `value2`='1' WHERE `uid` = %i", Item[IDX][uid]);
        	mysql_function_query(mysqlHandle, zapytanie, false, "", "");
			
			SetPlayerSkin(playerid, Item[IDX][value1]);
		  }
		  else
		  {
		    Item[IDX][used] = 0;
			pInfo[playerid][activeClothes] = -1;
			new zapytanie[128];
        	format(zapytanie, sizeof(zapytanie), "UPDATE `plerp_items` SET `value2`='0' WHERE `uid` = %i", Item[IDX][uid]);
        	mysql_function_query(mysqlHandle, zapytanie, false, "", "");
			
		    SetPlayerSkin(playerid, pInfo[playerid][skin]);
		  }
		}		
		case ITEM_TYPE_GUN:
		{
			if(!Item[IDX][used])// U¿ycie
			{
				if(!Item[IDX][value2]) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie mo¿esz u¿yæ broni w której nie ma amunicji");
				new wptslot = GetWeaponSlot(Item[IDX][value1]);
				if(pInfo[playerid][weaponUsed][wptslot] != -1) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Maksymalnie mo¿esz u¿ywaæ jednej broni na dany slot.");
				pInfo[playerid][weaponUsed][wptslot] = IDX;
				GivePlayerWeapon(playerid, Item[IDX][value1], Item[IDX][value2]);
				Item[IDX][used] = 1;
			}
			else//Przestanie u¿ywania
			{
				new wptslot = GetWeaponSlot(Item[IDX][value1]), null;
				pInfo[playerid][weaponUsed][wptslot] = -1;
				GetPlayerWeaponData(playerid, wptslot, null, Item[IDX][value2]);
				new zapytanie[128];
				RemovePlayerWeapon(playerid, Item[IDX][value1]);
        	    format(zapytanie, sizeof(zapytanie), "UPDATE `plerp_items` SET `value2`='%i' WHERE `uid` = %i", Item[IDX][value2], Item[IDX][uid]);
        	    mysql_function_query(mysqlHandle, zapytanie, false, "", "");
				Item[IDX][used] = 0;
			}
		}
		case ITEM_TYPE_AMMO:
		{
			new stringe[64], bigstring[256];
			foreach( new idee : Items_PLAYER[pInfo[playerid][uid]])
			{
				if(Item[IDX][value1] == Item[idee][value1] && Item[idee][used] == 0 && Item[idee][type] == ITEM_TYPE_GUN)
				{
					format(stringe, sizeof(stringe), "\n%i\t%s", Item[idee][uid], Item[idee][name]); 
					strcat(bigstring, stringe);
					printf("Przedmiot spe³nia warunek %i", Item[idee][value1]);
				}
			}
			if(!strlen(bigstring)) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "B³¹d", "W swoim ekwipunku nie posiadasz broni do której pasowa³a by ta amunicja.\nPamiêtaj ¿e przedmiot nie mo¿e byæ w u¿ytku.", "OK", "");
			pInfo[playerid][t_dialogtmp1] = IDX;
			ShowPlayerDialog(playerid, 48, DIALOG_STYLE_LIST, "Lista przedmiotów", bigstring, "W³ó¿", "WyjdŸ");
		}
		case ITEM_TYPE_FOOD:
		{
			pInfo[playerid][health] += float(Item[IDX][value1]);
			if(pInfo[playerid][health] > 100) 
			{
				pInfo[playerid][health] = 100;
			}
			SetPlayerHealth(playerid, pInfo[playerid][health]);
			ItemRemove(IDX);
		
		}
		case ITEM_TYPE_DRINKS:
		{
			ItemRemove(IDX);
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DRINK_BEER);
		}
		case ITEM_TYPE_CIGG:
		{
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_SMOKE_CIGGY);
			Item[IDX][value1] -= 1;
			if(!Item[IDX][value1])
            {
                ItemRemove(IDX);
            }
            else
            {
                new zapytanie[120];
                format(zapytanie, sizeof(zapytanie), "UPDATE `plerp_items` SET `value1` = %i WHERE `uid` = %i", Item[IDX][value1], Item[IDX][uid]);
                mysql_function_query(mysqlHandle, zapytanie, false, "", "");
            }
		}
		case ITEM_TYPE_CORPSE:
		{
			new stringg[256];
			
			format(stringg, sizeof(stringg), "SELECT * FROM `plerp_corpses` WHERE `id`='%d'", Item[IDX][value1]);
			mysql_function_query(mysqlHandle, stringg, true, "UseCorpse", "dd", Item[IDX][value1], playerid);
		}
		case ITEM_TYPE_DISC:
		{
			if(!Item[IDX][value1])
			{	
				pInfo[playerid][t_dialogtmp1] = IDX;
				ShowPlayerDialog(playerid, 60, DIALOG_STYLE_INPUT, "Tworzenie p³yty", "Poni¿ej podaj link do streama muzyki.\nPrzyk³adowy link: http://stream.task.gda.pl:8000/rg1.m3u", "OK", "Anuluj");
			}
			else
			{
				new stringe[64], bigstring[256];
				foreach( new idee : Items_PLAYER[pInfo[playerid][uid]])
				{
					if(Item[idee][type] == ITEM_TYPE_MP3 && Item[idee][used] == 0 && !Item[idee][value1])
					{
						format(stringe, sizeof(stringe), "\n%i\t%s", Item[idee][uid], Item[idee][name]); 
						strcat(bigstring, stringe);
					}
				}
				if(!strlen(bigstring)) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "B³ad", "Nie znaleziono discman'a do którego mo¿esz wsadziæ p³yte.", "OK", "");
				pInfo[playerid][t_dialogtmp1] = IDX;
				ShowPlayerDialog(playerid, 61, DIALOG_STYLE_LIST, "Wybierz odtwarzasz", bigstring, "Wybierz", "WyjdŸ");
			}
		
		}	
		case ITEM_TYPE_MP3:
		{
			if(!Item[IDX][used])//U¿ycie przedmiotu
			{
				if(!Item[IDX][value1]) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "B³¹d", "W discmanie nie ma ¿adnej p³yty", "OK", "");
				pInfo[playerid][t_dialogtmp1] = IDX;
				ShowPlayerDialog(playerid, 62, DIALOG_STYLE_MSGBOX, "U¿ycie discmana", "Discman Opcje.\nJeœli wybierzesz opcje wyciagnij, plyta zostanie z discmana wyci¹gniêta i trafi do Twojego ekwipunku.", "Wlacz", "Wyciagnij");
			}
			else
			{
				Audio_Stop(playerid, Item[IDX][tmpvalue][0]);
				Item[IDX][used] = 0;
			
			}
		}
		
		case ITEM_TYPE_ARMOR:
        {      
                        if(!Item[IDX][used]) // U¿yj
                        {
                               
                                pInfo[playerid][armor] = Item[IDX][value1];
                                pInfo[playerid][armor_status] = 1;
                                SetPlayerArmour(playerid, Item[IDX][value1]);
                                Item[IDX][used] = 1;
                        } else
                        {
                                new query[128];
                                format(query, sizeof(query), "UPDATE `plerp_items` SET `value1`='%d' WHERE `uid`='%d'", floatround(pInfo[playerid][armor]), Item[IDX][uid]);
                                mysql_function_query(mysqlHandle, query, false, "", "");
                                Item[IDX][value1] = floatround(pInfo[playerid][armor]);
                                pInfo[playerid][armor] = 0;
                                pInfo[playerid][armor_status] = 0;
                                SetPlayerArmour(playerid, 0.0);
                                Item[IDX][used] = 0;
                        }
        }
	}
    return 1;
}
stock ItemCreate(idowner, typeowner, typeea, value1ea, value2ea, modellookea, nazwaear[], countea = 0, priceea = 0)
{
        new zapytanie[250], przedid =  Iter_Free(Items);
        Item[przedid][owner_id] = idowner;
        Item[przedid][owner_type] = typeowner;
        Item[przedid][value1] = value1ea;
        Item[przedid][value2] = value2ea;
        Item[przedid][modellook] = modellookea;
		format(Item[przedid][name], 30, "%s", nazwaear);
		//Item[przedid][name] = nazwaear;
        Item[przedid][count] = countea;
        Item[przedid][price] = priceea;
        Item[przedid][type] = typeea;
        Iter_Add(Items, przedid);
        if(Item[przedid][owner_type] == 1) Iter_Add(Items_PLAYER[Item[przedid][owner_id]], przedid);
        if(Item[przedid][owner_type] == 2) Iter_Add(Items_GROUND, przedid);
        if(Item[przedid][owner_type] == 3) Iter_Add(Items_GROUND_VEH[Item[przedid][owner_id]], przedid);               
        if(Item[przedid][owner_type] == 4) Iter_Add(Items_GROUND_DOOR[Item[przedid][owner_id]], przedid);      
        if(Item[przedid][owner_type] == 5) Iter_Add(Items_STORE[Item[przedid][owner_id]], przedid);
        if(Item[przedid][owner_type] == 6) Iter_Add(Items_COMPONENT[Item[przedid][owner_id]], przedid);
        format(zapytanie, sizeof(zapytanie), "INSERT INTO `plerp_items` SET `owner_id` = %i, `owner_type` = %i, `value1` = %i, `value2`= %i, `modellook` = %i, `name` = '%s', `count` = %i, `price` = %i, `type` = %i",Item[przedid][owner_id], Item[przedid][owner_type], Item[przedid][value1], Item[przedid][value2], Item[przedid][modellook], Item[przedid][name], Item[przedid][count], Item[przedid][price], Item[przedid][type]);
	    mysql_function_query(mysqlHandle, zapytanie, true, "ItemCreateQuery", "i", przedid);
}
forward ItemCreateQuery(przedid);
public ItemCreateQuery(przedid)
{
        Item[przedid][uid] = mysql_insert_id(mysqlHandle);
		printf("Item Create Query zosta³o wykonane");
        return 1;
}
ItemRemove(IDX)
{
			Iter_Remove(Items, IDX);
			new zapytanie[128];
			format(zapytanie, sizeof(zapytanie), "DELETE FROM `plerp_items` WHERE `uid` = %i", Item[IDX][uid]);
			mysql_function_query(mysqlHandle, zapytanie, false, "", "");
			if(Item[IDX][owner_type] == 1)
			{
				Iter_Remove(Items_PLAYER[Item[IDX][owner_id]], IDX);
			
			}
			if(Item[IDX][owner_type] == 2)
			{
				Iter_Remove(Items_GROUND, IDX);
			
			}
			if(Item[IDX][owner_type] == 3)
			{
				Iter_Remove(Items_GROUND_VEH[Item[IDX][owner_id]], IDX);
			
			}			
			if(Item[IDX][owner_type] == 4)
			{
				Iter_Remove(Items_GROUND_DOOR[Item[IDX][owner_id]], IDX);
			
			}		
			if(Item[IDX][owner_type] == 5)
			{
				Iter_Remove(Items_STORE[Item[IDX][owner_id]], IDX);
			
			}		
			if(Item[IDX][owner_type] == 6)
			{
				Iter_Remove(Items_COMPONENT[Item[IDX][owner_id]], IDX);
			
			}

}
ItemPickup(IDX, playerid)
{
  #pragma unused IDX
  PrzedmiotyWPoblizu(playerid);
}
ItemOffer(IDX, playerid)
{
    if( Item[IDX][used] )
	{
	   SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie mo¿esz oferowaæ u¿ywanego przedmiotu.");
	   return;
	}
	pInfo[playerid][tmpOfferItem] = IDX;
	ShowPlayerDialog(playerid, 47, DIALOG_STYLE_INPUT, "Oferta - Przedmioty", "Aby oferowaæ przedmiot musisz podaæ kilka parametrów w nastêpuj¹cej formie:\t\t\t\t\t\n\t[id gracza] [cena]", "Oferuj", "Anuluj");
}
ItemDrop(IDX, playerid)
{
	CancelSelectTextDraw(playerid);
	if( Item[IDX][used] )
	{
	   SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie mo¿esz od³o¿yæ u¿ywanego przedmiotu.");
	   return 1;
	}
	new vID =  GetPlayerVehicleID(playerid);
	if( !IsPlayerInAnyVehicle(playerid) )
	{
	  new string[250], Float:pos[3];
	  GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	  format(string, sizeof(string), "ITEM DROP: UID %i",Item[IDX][uid]);
	  SendClientMessage(playerid, -1, string);
	  Iter_Add(Items_GROUND, IDX);
	  Iter_Remove(Items_PLAYER[pInfo[playerid][uid]], IDX);
	  Item[IDX][owner_type] = OWNER_TYPE_GROUND;
	  Item[IDX][owner_id] = 0;
	  Item[IDX][pos_x] = pos[0];
	  Item[IDX][pos_y] = pos[1];
	  Item[IDX][pos_z] = pos[2];
	  Item[IDX][pos_vw] = GetPlayerVirtualWorld(playerid);
	  Item[IDX][idobject] = CreateDynamicObject(Item[IDX][modellook], Item[IDX][pos_x], Item[IDX][pos_y], Item[IDX][pos_z]-1, 0, 0, 0, Item[IDX][pos_vw], -1, -1, 200.0);
	  format(string, sizeof(string), "UPDATE `plerp_items` SET `owner_id` = %d, `owner_type` = %d, `pos_x` = '%f', `pos_y` = '%f', `pos_z` = '%f', `pos_vw` = %i  WHERE `uid` = %i", Item[IDX][owner_id], Item[IDX][owner_type], Item[IDX][pos_x], Item[IDX][pos_y], Item[IDX][pos_z], Item[IDX][pos_vw], Item[IDX][uid]);
	  mysql_function_query(mysqlHandle, string, false, "", "");
	}
	else
	{
	  new string[250];
	  Iter_Add(Items_GROUND_VEH[sVehInfo[vID][uid]], IDX);
	  Iter_Remove(Items_PLAYER[pInfo[playerid][uid]], IDX);
	  Item[IDX][owner_type] = OWNER_TYPE_CAR;
	  Item[IDX][owner_id] = sVehInfo[vID][uid];
	  format(string, sizeof(string), "UPDATE `plerp_items` SET `owner_id` = %d, `owner_type` = %d WHERE `uid` = %i", Item[IDX][owner_id], Item[IDX][owner_type], Item[IDX][uid]);
	  mysql_function_query(mysqlHandle, string, false, "", "");
	}
	return 1;
		
}
stock HideItemList(playerid)
{
   PlayerTextDrawHide(playerid, itemsStaticTd[0]);
   PlayerTextDrawHide(playerid, itemsStaticTd[1]);
   PlayerTextDrawHide(playerid, itemsStaticTd[2]);
   PlayerTextDrawHide(playerid, itemsStaticTd[3]);
   PlayerTextDrawHide(playerid, itemsStaticTd[4]);
   for(new i=0;i<10;i++)
   {
     PlayerTextDrawHide(playerid, itemsTd[i]);
     PlayerTextDrawHide(playerid, itemsActionTd[i][0]);
     PlayerTextDrawHide(playerid, itemsActionTd[i][1]);
     PlayerTextDrawHide(playerid, itemsActionTd[i][2]);
     PlayerTextDrawHide(playerid, itemsActionTd[i][3]);
   }
}
PrzedmiotyWPoblizu(playerid, pageNum=1)
{
	new ownerToSet, page = pageNum;
	new liczba, liczba2 = 1,  spacing[30] = "          ", itemRow[80], vID, virtualworld = GetPlayerVirtualWorld(playerid);
	vID = GetPlayerVehicleID(playerid);
	if( !IsPlayerInAnyVehicle(playerid) ) 
	{
	  foreach (new idee : Items_GROUND)
	  {
	    if(IsPlayerInRangeOfPoint(playerid, 5.00, Item[idee][pos_x], Item[idee][pos_y], Item[idee][pos_z]) &&  virtualworld == Item[idee][pos_vw])
       {
		  if(liczba2 <= page*10 && liczba2 >10*(page-1))
		  {
		      PlayerTextDrawColor(playerid, itemsTd[liczba], -1);
			  if(Item[idee][uid] >= 10) format(spacing, 30, "         ");
			  else if(Item[idee][uid] >= 100) format(spacing, 30, "        ");
			  else if(Item[idee][uid] >= 1000) format(spacing, 30, "       ");
			  format(itemRow, sizeof(itemRow), " %d%s%s (%d:%d)", Item[idee][uid], spacing, Item[idee][name], Item[idee][value1], Item[idee][value2]);
			  PlayerTextDrawSetString(playerid, itemsTd[liczba], itemRow);
			  liczba++;
		  }
		
	      liczba2++;
	    }	
	  }
	  ownerToSet =  OWNER_TYPE_GROUND;
	}
	else
	{
	    if( !CanEditCar(playerid, vID) )
		{
		   if( pInfo[playerid][t_dialogtmp1] == 0 )  BuildPlayerItemsListAndDisplay(playerid, pInfo[playerid][itemsListPageNumber]);
	       return SendPlayerInformation(playerid, "Nie masz praw do podnoszenia przedmiotow w tym pojezdzie.");
		}
		
		foreach (new idee : Items_GROUND_VEH[sVehInfo[vID][uid]])
	    {
		    
		    if(liczba2 <= page*10 && liczba2 >10*(page-1))
		    {
			  PlayerTextDrawColor(playerid, itemsTd[liczba], -1);
			  if(Item[idee][uid] >= 10) format(spacing, 30, "         ");
			  else if(Item[idee][uid] >= 100) format(spacing, 30, "        ");
			  else if(Item[idee][uid] >= 1000) format(spacing, 30, "       ");
			  format(itemRow, sizeof(itemRow), " %d%s%s (%d:%d)", Item[idee][uid], spacing, Item[idee][name], Item[idee][value1], Item[idee][value2]);
			  PlayerTextDrawSetString(playerid, itemsTd[liczba], itemRow);
			  liczba++;
		    }
            liczba2++;
	    }
		
		ownerToSet =  OWNER_TYPE_CAR;
	}
	if(liczba2-1 == 0) 
	{
	  if( pInfo[playerid][t_dialogtmp1] == 0 ) BuildPlayerItemsListAndDisplay(playerid, pInfo[playerid][itemsListPageNumber]);
	  else 
	  {
	    HideItemList(playerid);
		CancelSelectTextDraw(playerid);
	  }	
	  if( ownerToSet == OWNER_TYPE_GROUND ) return SendPlayerInformation(playerid, "W poblizu nie ma zadnych przedmiotow.");
	  if( ownerToSet == OWNER_TYPE_CAR ) return SendPlayerInformation(playerid, "W tym pojezdzie nie ma zadnych przedmiotow.");
	}
	SelectTextDraw(playerid, 0xFFEC9FFF);
	pInfo[playerid][itemsPopupOpened] = ownerToSet;
	PlayerTextDrawSetString(playerid, itemsStaticTd[4], "Przedmioty_w_poblizu");
	PlayerTextDrawSetString(playerid, itemsStaticTd[3], "Ekwipunek");
    for(new i=0;i<liczba;i++)
	{
	  		PlayerTextDrawShow(playerid, itemsTd[i]);
			PlayerTextDrawSetString(playerid, itemsActionTd[i][1], "Podnies");
			PlayerTextDrawShow(playerid, itemsActionTd[i][1]);
	}
	PlayerTextDrawShow(playerid, itemsStaticTd[0]);
	if(liczba2 > (page*10)+1)
	{
		PlayerTextDrawShow(playerid, itemsStaticTd[1]);
	
	}
	if(page > 1)
	{
		PlayerTextDrawShow(playerid, itemsStaticTd[2]);	
	}
	PlayerTextDrawShow(playerid, itemsStaticTd[3]);
	PlayerTextDrawShow(playerid, itemsStaticTd[4]);
    return 1;
}
stock BuildPlayerItemsListAndDisplay(playerid, pageNum=1)
{
	pInfo[playerid][itemsPopupOpened] = OWNER_TYPE_PLAYER;
	new page = pageNum;
	new liczba, liczba2 = 1,  spacing[30] = "          ", itemRow[80];
	HideItemList(playerid);
	PlayerTextDrawSetString(playerid, itemsStaticTd[4], "Przedmioty_postaci");
	PlayerTextDrawSetString(playerid, itemsStaticTd[3], "Podnies");
	foreach (new idee : Items_PLAYER[pInfo[playerid][uid]])
	{
		if(liczba2 <= page*10 && liczba2 >10*(page-1))
		{
			if(Item[idee][used])
			{
		        PlayerTextDrawColor(playerid, itemsTd[liczba], 0xCFFD66FF);
			}
			else
			{
			    PlayerTextDrawColor(playerid, itemsTd[liczba], -1);
			}
			if(Item[idee][uid] >= 10) format(spacing, 30, "         ");
			else if(Item[idee][uid] >= 100) format(spacing, 30, "        ");
			else if(Item[idee][uid] >= 1000) format(spacing, 30, "       ");
			format(itemRow, sizeof(itemRow), " %d%s%s (%d:%d)", Item[idee][uid], spacing, Item[idee][name], Item[idee][value1], Item[idee][value2]);
			PlayerTextDrawSetString(playerid, itemsTd[liczba], itemRow);
			PlayerTextDrawShow(playerid, itemsTd[liczba]);
			PlayerTextDrawShow(playerid, itemsActionTd[liczba][0]);
			PlayerTextDrawTextSize(playerid, itemsActionTd[liczba][2], 9.000000, 23.000000);
			PlayerTextDrawSetString(playerid, itemsActionTd[liczba][1], "Odloz");
			PlayerTextDrawShow(playerid, itemsActionTd[liczba][1]);
			PlayerTextDrawShow(playerid, itemsActionTd[liczba][2]);
			PlayerTextDrawShow(playerid, itemsActionTd[liczba][3]);
			liczba++;
		}
		
		liczba2++;
	}
	if(liczba2-1 == 0) return SendClientMessage(playerid, -1, "Nie posiadasz ¿adnego przedmiotu");
	SelectTextDraw(playerid, 0xFFEC9FFF);
	PlayerTextDrawShow(playerid, itemsStaticTd[0]);
	if(liczba2 > (page*10)+1)
	{
		PlayerTextDrawShow(playerid, itemsStaticTd[1]);
	
	}
	if(page > 1)
	{
		PlayerTextDrawShow(playerid, itemsStaticTd[2]);
	
	}
	PlayerTextDrawShow(playerid, itemsStaticTd[3]);
	PlayerTextDrawShow(playerid, itemsStaticTd[4]);
	return 1;

}

stock HandleItemsList(playerid, PlayerText:clickedid)
{
	if( clickedid == itemsStaticTd[1] )
	{
	  	pInfo[playerid][itemsListPageNumber] += 1;
		if( pInfo[playerid][itemsPopupOpened] == OWNER_TYPE_PLAYER ) BuildPlayerItemsListAndDisplay(playerid, pInfo[playerid][itemsListPageNumber]);
		if( pInfo[playerid][itemsPopupOpened] == OWNER_TYPE_GROUND ) PrzedmiotyWPoblizu(playerid, pInfo[playerid][itemsListPageNumber]);
	}
	else if( clickedid == itemsStaticTd[2] )
	{
		pInfo[playerid][itemsListPageNumber] -= 1;
		if( pInfo[playerid][itemsPopupOpened] == OWNER_TYPE_PLAYER ) BuildPlayerItemsListAndDisplay(playerid, pInfo[playerid][itemsListPageNumber]);
		if( pInfo[playerid][itemsPopupOpened] == OWNER_TYPE_GROUND ) PrzedmiotyWPoblizu(playerid, pInfo[playerid][itemsListPageNumber]);
	}
	else if( clickedid == itemsStaticTd[3] )
	{
		if( pInfo[playerid][itemsPopupOpened] == OWNER_TYPE_PLAYER )
        {
		  pInfo[playerid][t_dialogtmp1] = 0;
          PrzedmiotyWPoblizu(playerid);
		}
		else if( pInfo[playerid][itemsPopupOpened] == OWNER_TYPE_GROUND )
        {
          BuildPlayerItemsListAndDisplay(playerid);
		}
	}

	if( clickedid == itemsActionTd[0][3] ) ItemUse(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10), playerid);// uzyj
	if( clickedid == itemsActionTd[1][3] ) ItemUse(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+1), playerid);// uzyj
	if( clickedid == itemsActionTd[2][3] ) ItemUse(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+2), playerid);// uzyj
	if( clickedid == itemsActionTd[3][3] ) ItemUse(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+3), playerid);// uzyj
	if( clickedid == itemsActionTd[4][3] ) ItemUse(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+4), playerid);// uzyj
	if( clickedid == itemsActionTd[5][3] ) ItemUse(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+5), playerid);// uzyj
	if( clickedid == itemsActionTd[6][3] ) ItemUse(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+6), playerid);// uzyj
	if( clickedid == itemsActionTd[7][3] ) ItemUse(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+7), playerid);// uzyj
	if( clickedid == itemsActionTd[8][3] ) ItemUse(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+8), playerid);// uzyj
	if( clickedid == itemsActionTd[9][3] ) ItemUse(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+9), playerid);// uzyj
	if( clickedid == itemsActionTd[0][2] ) ItemOffer(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10), playerid);// uzyj
	if( clickedid == itemsActionTd[1][2] ) ItemOffer(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+1), playerid);// uzyj
	if( clickedid == itemsActionTd[2][2] ) ItemOffer(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+2), playerid);// uzyj
	if( clickedid == itemsActionTd[3][2] ) ItemOffer(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+3), playerid);// uzyj
	if( clickedid == itemsActionTd[4][2] ) ItemOffer(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+4), playerid);// uzyj
	if( clickedid == itemsActionTd[5][2] ) ItemOffer(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+5), playerid);// uzyj
	if( clickedid == itemsActionTd[6][2] ) ItemOffer(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+6), playerid);// uzyj
	if( clickedid == itemsActionTd[7][2] ) ItemOffer(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+7), playerid);// uzyj
	if( clickedid == itemsActionTd[8][2] ) ItemOffer(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+8), playerid);// uzyj
	if( clickedid == itemsActionTd[9][2] ) ItemOffer(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+9), playerid);// uzyj
	if( clickedid == itemsActionTd[0][0] ) ItemInfo(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10), playerid);// uzyj
	if( clickedid == itemsActionTd[1][0] ) ItemInfo(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+1), playerid);// uzyj
	if( clickedid == itemsActionTd[2][0] ) ItemInfo(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+2), playerid);// uzyj
	if( clickedid == itemsActionTd[3][0] ) ItemInfo(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+3), playerid);// uzyj
	if( clickedid == itemsActionTd[4][0] ) ItemInfo(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+4), playerid);// uzyj
	if( clickedid == itemsActionTd[5][0] ) ItemInfo(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+5), playerid);// uzyj
	if( clickedid == itemsActionTd[6][0] ) ItemInfo(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+6), playerid);// uzyj
	if( clickedid == itemsActionTd[7][0] ) ItemInfo(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+7), playerid);// uzyj
	if( clickedid == itemsActionTd[8][0] ) ItemInfo(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+8), playerid);// uzyj
	if( clickedid == itemsActionTd[9][0] ) ItemInfo(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+9), playerid);// uzyj
	
	if( pInfo[playerid][itemsPopupOpened] == OWNER_TYPE_GROUND )
	{
        if( clickedid == itemsActionTd[0][1] ) ItemPickup(GetItemIDXByKOLGROUND((pInfo[playerid][itemsListPageNumber]-1)*10, playerid), playerid);// uzyj
		if( clickedid == itemsActionTd[1][1] ) ItemPickup(GetItemIDXByKOLGROUND((pInfo[playerid][itemsListPageNumber]-1)*10+1, playerid), playerid);// uzyj
		if( clickedid == itemsActionTd[2][1] ) ItemPickup(GetItemIDXByKOLGROUND((pInfo[playerid][itemsListPageNumber]-1)*10+2, playerid), playerid);// uzyj
		if( clickedid == itemsActionTd[3][1] ) ItemPickup(GetItemIDXByKOLGROUND((pInfo[playerid][itemsListPageNumber]-1)*10+3, playerid), playerid);// uzyj
		if( clickedid == itemsActionTd[4][1] ) ItemPickup(GetItemIDXByKOLGROUND((pInfo[playerid][itemsListPageNumber]-1)*10+4, playerid), playerid);// uzyj
		if( clickedid == itemsActionTd[5][1] ) ItemPickup(GetItemIDXByKOLGROUND((pInfo[playerid][itemsListPageNumber]-1)*10+5, playerid), playerid);// uzyj
		if( clickedid == itemsActionTd[6][1] ) ItemPickup(GetItemIDXByKOLGROUND((pInfo[playerid][itemsListPageNumber]-1)*10+6, playerid), playerid);// uzyj
		if( clickedid == itemsActionTd[7][1] ) ItemPickup(GetItemIDXByKOLGROUND((pInfo[playerid][itemsListPageNumber]-1)*10+7, playerid), playerid);// uzyj
		if( clickedid == itemsActionTd[8][1] ) ItemPickup(GetItemIDXByKOLGROUND((pInfo[playerid][itemsListPageNumber]-1)*10+8, playerid), playerid);// uzyj
		if( clickedid == itemsActionTd[9][1] ) ItemPickup(GetItemIDXByKOLGROUND((pInfo[playerid][itemsListPageNumber]-1)*10+9, playerid), playerid);// uzyj
	}
	else if( pInfo[playerid][itemsPopupOpened] == OWNER_TYPE_CAR )
	{
	    if( clickedid == itemsActionTd[0][1] ) ItemPickup(GetItemIDXByKOLCAR((pInfo[playerid][itemsListPageNumber]-1)*10, playerid), playerid);// uzyj
		if( clickedid == itemsActionTd[1][1] ) ItemPickup(GetItemIDXByKOLCAR((pInfo[playerid][itemsListPageNumber]-1)*10+1, playerid), playerid);// uzyj
		if( clickedid == itemsActionTd[2][1] ) ItemPickup(GetItemIDXByKOLCAR((pInfo[playerid][itemsListPageNumber]-1)*10+2, playerid), playerid);// uzyj
		if( clickedid == itemsActionTd[3][1] ) ItemPickup(GetItemIDXByKOLCAR((pInfo[playerid][itemsListPageNumber]-1)*10+3, playerid), playerid);// uzyj
		if( clickedid == itemsActionTd[4][1] ) ItemPickup(GetItemIDXByKOLCAR((pInfo[playerid][itemsListPageNumber]-1)*10+4, playerid), playerid);// uzyj
		if( clickedid == itemsActionTd[5][1] ) ItemPickup(GetItemIDXByKOLCAR((pInfo[playerid][itemsListPageNumber]-1)*10+5, playerid), playerid);// uzyj
		if( clickedid == itemsActionTd[6][1] ) ItemPickup(GetItemIDXByKOLCAR((pInfo[playerid][itemsListPageNumber]-1)*10+6, playerid), playerid);// uzyj
		if( clickedid == itemsActionTd[7][1] ) ItemPickup(GetItemIDXByKOLCAR((pInfo[playerid][itemsListPageNumber]-1)*10+7, playerid), playerid);// uzyj
		if( clickedid == itemsActionTd[8][1] ) ItemPickup(GetItemIDXByKOLCAR((pInfo[playerid][itemsListPageNumber]-1)*10+8, playerid), playerid);// uzyj
		if( clickedid == itemsActionTd[9][1] ) ItemPickup(GetItemIDXByKOLCAR((pInfo[playerid][itemsListPageNumber]-1)*10+9, playerid), playerid);// uzyj
	}
	else
	{
		if( clickedid == itemsActionTd[0][1] ) ItemDrop(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10), playerid);// uzyj
		if( clickedid == itemsActionTd[1][1] ) ItemDrop(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+1), playerid);// uzyj
		if( clickedid == itemsActionTd[2][1] ) ItemDrop(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+2), playerid);// uzyj
		if( clickedid == itemsActionTd[3][1] ) ItemDrop(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+3), playerid);// uzyj
		if( clickedid == itemsActionTd[4][1] ) ItemDrop(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+4), playerid);// uzyj
		if( clickedid == itemsActionTd[5][1] ) ItemDrop(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+5), playerid);// uzyj
		if( clickedid == itemsActionTd[6][1] ) ItemDrop(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+6), playerid);// uzyj
		if( clickedid == itemsActionTd[7][1] ) ItemDrop(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+7), playerid);// uzyj
		if( clickedid == itemsActionTd[8][1] ) ItemDrop(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+8), playerid);// uzyj
		if( clickedid == itemsActionTd[9][1] ) ItemDrop(GetItemIDXByKOL(pInfo[playerid][uid], (pInfo[playerid][itemsListPageNumber]-1)*10+9), playerid);// uzyj
	}
}

//Funkcje Bezpoœrednio do przedmiotów
forward CreateKarteczka(playerid, nazwaea[30]);
public CreateKarteczka(playerid, nazwaea[30])
{
		printf("w tym momencie powinna sie wykonaæ funkcja nazwa %s", nazwaea);
        ItemCreate(pInfo[playerid][uid], 1, 3, mysql_insert_id(mysqlHandle), 0, 2674, nazwaea);
}
forward PokazKarteczke(playerid, IDX);
public PokazKarteczke(playerid, IDX)
{
        new string[250];
        cache_get_field_content(0, "content", string);
        ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, Item[IDX][name], string, "OK", "");
 
}

forward AttachItemFirstUse(IDX);
public AttachItemFirstUse(IDX)
{
	new Float:dfloat[9], dinteger[2], zapytanie[700], string[30];
	cache_get_field_content(0, "pos_x", string);
	dfloat[0] = floatstr(string);	
	cache_get_field_content(0, "pos_y", string);
	dfloat[1] = floatstr(string);	
	cache_get_field_content(0, "pos_z", string);
	dfloat[2] = floatstr(string);	
	cache_get_field_content(0, "rot_x", string);
	dfloat[3] = floatstr(string);	
	cache_get_field_content(0, "rot_y", string);
	dfloat[4] = floatstr(string);	
	cache_get_field_content(0, "rot_z", string);
	dfloat[5] = floatstr(string);	
	cache_get_field_content(0, "scale_x", string);
	dfloat[6] = floatstr(string);	
	cache_get_field_content(0, "scale_y", string);
	dfloat[7] = floatstr(string);	
	cache_get_field_content(0, "scale_z", string);
	dfloat[8] = floatstr(string);
	cache_get_field_content(0, "modelid", string);
	dinteger[0] = strval(string);	
	cache_get_field_content(0, "bone", string);
	dinteger[1] = strval(string);
	format(zapytanie, sizeof(zapytanie), "INSERT INTO `plerp_atach` SET `pos_x` = %f, `pos_y` = %f, `pos_z` = %f, `rot_x` = %f, `rot_y` = %f, `rot_z` = %f, `scale_x` = %f, `scale_y` = %f, `scale_z` = %f, `modelid` = %i, `bone` = %i", dfloat[0], dfloat[1], dfloat[2], dfloat[3], dfloat[4], dfloat[5], dfloat[6], dfloat[7], dfloat[8], dinteger[0], dinteger[1]);
	mysql_function_query(mysqlHandle, zapytanie, true, "AttachItemFirstUseQuery", "i", IDX);
}
forward AttachItemFirstUseQuery(IDX);
public AttachItemFirstUseQuery(IDX)
{
	Item[IDX][value1] = mysql_insert_id(mysqlHandle);
	new zapytanie[128];
	format(zapytanie, sizeof(zapytanie), "UPDATE `plerp_items` SET `value1`='%i' WHERE `uid` = %i", Item[IDX][value1], Item[IDX][uid]);
	mysql_function_query(mysqlHandle, zapytanie, false, "", "");
}
forward AtachObjectToPlayer(playerid, IDX, slottouse);
public AtachObjectToPlayer(playerid, IDX, slottouse)
{
	new Float:dfloat[9], dinteger[2], string[30];
	cache_get_field_content(0, "pos_x", string);
	dfloat[0] = floatstr(string);	
	cache_get_field_content(0, "pos_y", string);
	dfloat[1] = floatstr(string);	
	cache_get_field_content(0, "pos_z", string);
	dfloat[2] = floatstr(string);	
	cache_get_field_content(0, "rot_x", string);
	dfloat[3] = floatstr(string);	
	cache_get_field_content(0, "rot_y", string);
	dfloat[4] = floatstr(string);	
	cache_get_field_content(0, "rot_z", string);
	dfloat[5] = floatstr(string);	
	cache_get_field_content(0, "scale_x", string);
	dfloat[6] = floatstr(string);	
	cache_get_field_content(0, "scale_y", string);
	dfloat[7] = floatstr(string);	
	cache_get_field_content(0, "scale_z", string);
	dfloat[8] = floatstr(string);
	cache_get_field_content(0, "modelid", string);
	dinteger[0] = strval(string);	
	cache_get_field_content(0, "bone", string);
	dinteger[1] = strval(string);
	if(slottouse == -1)
	{
		pInfo[playerid][EditorAttItem] = IDX;
		SetPlayerAttachedObject(playerid, 5, dinteger[0], dinteger[1], dfloat[0], dfloat[1], dfloat[2], dfloat[3], dfloat[4], dfloat[5], dfloat[6], dfloat[7], dfloat[8]);
		EditAttachedObject(playerid, 5);
	}
	else
	{
		Item[IDX][used] = 1;
		Item[IDX][tmpvalue][0] = slottouse;
		SetPlayerAttachedObject(playerid, slottouse, dinteger[0], dinteger[1], dfloat[0], dfloat[1], dfloat[2], dfloat[3], dfloat[4], dfloat[5], dfloat[6], dfloat[7], dfloat[8]);
	}

}

stock ShowItemsForPlayer(playerid)
{
   BuildPlayerItemsListAndDisplay(playerid, 1);
   pInfo[playerid][itemsListPageNumber] = 1;
}

stock ShowGroundItemsForPlayer(playerid)
{
   PrzedmiotyWPoblizu(playerid);
}

stock GetWeaponSlot(weaponid)
{
    switch (weaponid)
    {
        case  0,      1: return  0; // Unarmed
        case  2  ..   9: return  1; // Melee
        case 22  ..  24: return  2; // Pistol
        case 25  ..  27: return  3; // Shotgun
        case 28, 29, 32: return  4; // SMG
        case 30,     31: return  5; // Machinegun
        case 33,     34: return  6; // Rifle
        case 35  ..  38: return  7; // Heavy
        case 16, 18, 39: return  8; // Projectile
        case 42,     43: return  9; // Special
        case 14        : return 10; // Gifts
        case 44  ..  46: return 11; // Special
        case 40        : return 12; // Detonator
    }
    return 0;
}
forward UseCorpse(int, playerid);
public UseCorpse(int, playerid)
{
	new stringg[128], bigstring[256], killer[32], victim[32], reason, date[32], tempField[16], w_name[32];
	
	cache_get_field_content(0, "killer", killer);
	cache_get_field_content(0, "victim", victim);
	cache_get_field_content(0, "date", date);
	cache_get_field_content(0, "reason", tempField);
	reason = strval(tempField);
	GetWeaponName(reason, w_name, strlen(w_name));
	
	
	format(stringg, sizeof(stringg), "Zwloki -> UID: %d", int);
	format(bigstring, sizeof(bigstring), "Denat: %s\nNarzêdzie: %s\nData: %s\nZabójca: %s", victim, w_name, date, killer);
	ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, stringg, bigstring, "OK", "");
}
	
// -- Skill broni -- BARTEK -- //
stock CheckWeaponSkill(playerid)
{
	new Float:skill, skill2;
	skill = pInfo[playerid][weaponskill] * 1;
	skill2 = floatround(skill);
		
	SetPlayerDrunkLevel(playerid, skill2);
	pInfo[playerid][t_wdrunk] = 1;
	return 1;
}

stock AddWeaponSkill(playerid)
{
	new skill;
	
	skill = pInfo[playerid][weaponskill] - 10;
	pInfo[playerid][weaponskill] = skill;
	return 1;
}

// -- Skill broni -- BARTEK -- //


stock PrzedmiotyCommand(playerid, params[])
{
  new sub[32], param[128];
  if( sscanf(params, "s[32] ", sub) )
  {
  	ShowItemsForPlayer(playerid);
  	SendClientMessage(playerid, 0xFF0000AA, "{999A9C}PLERP.net: /(p)rzedmioty [podnies]   #Mo¿esz u¿yæ klawisza {B73E3E}[N]{999A9C} do wyœwietlenia listy przedmiotów");
  }
  else
  {
  	sscanf( params, "{s[32]}s[128]", param );
    if( !strcmp("podnies", sub, false) )
	{
	   pInfo[playerid][t_dialogtmp1] = 1;
       PrzedmiotyWPoblizu(playerid);
	}
  }
}
stock RemovePlayerWeapon(playerid, weaponid)
{
  new plyWeapons[12];
  new plyAmmo[12];
  for(new slot = 0; slot != 12; slot++)
  {
    new wep, ammoea;
    GetPlayerWeaponData(playerid, slot, wep, ammoea);
    if(wep != weaponid)
    {
      GetPlayerWeaponData(playerid, slot, plyWeapons[slot], plyAmmo[slot]);
    }
  }
  ResetPlayerWeapons(playerid);
  for(new slot = 0; slot != 12; slot++)
  {
    GivePlayerWeapon(playerid, plyWeapons[slot], plyAmmo[slot]);
  }
}




//Testy
////////////////////////////////////////////////////////////////
 
forward CreateCorpse(playerid);
public CreateCorpse(playerid)
{
        new string[128];
		new ueq = mysql_insert_id();
        ItemCreate(pInfo[playerid][uid], 1, 10, ueq, 0, 2060, "Zwloki", 0, 0);
        BlockCharacter(playerid);
        format(string, sizeof(string), "Postaæ %s zosta³a uœmiercona.", pInfo[playerid][name]);
        SendClientMessage(playerid, COLOR_RED, string);
		printf("tutaj powinien siê wykonaæ kick");
		defer Zwloki[500](playerid);
        return 1;
}
forward CDLink(playerid, CD, link[60]);
public CDLink(playerid, CD, link[60])
{
	Item[CD][value1] = mysql_insert_id(mysqlHandle);
	new zapytanie[120];
	ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "P³yta", "Strumieñ do p³yty zosta³ dodany pomyœlnie", "Ok", "");
	format(zapytanie, sizeof(zapytanie), "UPDATE `plerp_items` SET `value1`='%i' WHERE `uid` = %i", Item[CD][value1], Item[CD][uid]);
	mysql_function_query(mysqlHandle, zapytanie, false, "", "");
}
forward WlaczDiscman(playerid, IDX);
public WlaczDiscman(playerid, IDX)
{
	new content[60];
	cache_get_field_content(0, "content", content);
	Item[IDX][tmpvalue][0] = Audio_PlayStreamed(playerid, content);

}