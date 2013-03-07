stock UpdateWantedVehicle(upv_uid, vmodel[], color[], reg[], special[], driver[], lastseen[])
{
	new string[512], date[32];
	
	date = FormatDate();
	format(string, sizeof(string), "UPDATE `plerp_wantedvehicles` SET `model`='%s', `color`='%s', `registration`='%s', `special`='%s', \
													`driver_desc`='%s', `last_seen`='%s', `actualdate`='%s' WHERE `id`='%d'", vmodel, color, reg, special, driver, lastseen, date, upv_uid);
					
	mysql_function_query(mysqlHandle, string, false, "", "");
	return 1;
}

stock UpdateWantedPerson(uwp_uid, uwp_name[], surname[], nick[], adres[], vehicles[], height, skincolor[], eyescolor[], lastseen[])
{
	new string[512], date[32];
	
	date = FormatDate();
	format(string, sizeof(string), "UPDATE `plerp_wantedpersons` SET `name`='%s', `surname`='%s', `nick`='%s', `adres`='%s', `vehicles`='%s', \
													`height`='%d', `skincolor`='%s', `eyescolor`='%s', `lastseen`='%s', `actualdate`='%s' WHERE `id`='%d'", uwp_name, surname, nick, adres, 
													vehicles, height, skincolor, eyescolor, lastseen, date, uwp_uid);
							
	mysql_function_query(mysqlHandle, string, false, "", "");
	return 1;
}

stock UpdateTowedVehicle(utv_uid, uid2, vmodel[], color[], special[], towedfrom[], towedreason[], towprice)
{
	new string[512], date[32];
	
	date = FormatDate();
	format(string, sizeof(string), "UPDATE `plerp_towedvehicles` SET `uid`='%d', `model`='%s', `color`='%s', `special`='%d', `towedfrom`='%s', \
													`towedreason`='%s', `price`='%d', `actualdate`='%s' WHERE `id`='%d'", uid2, vmodel, color, special, towedfrom, towedreason, towprice, date, utv_uid);
					
	mysql_function_query(mysqlHandle, string, false, "", "");
	return 1;
}

stock UpdatePoliceFile(upf_uid, upf_name[], surname[], nick[], adres[], vehicles[], height, skincolor[], eyescolor[], arrestnum, arrestreason[])
{
	new string[512], date[32];
	
	date = FormatDate();
	format(string, sizeof(string), "UPDATE `plerp_policefiles` SET `name`='%s', `surname`='%s', `nick`='%s', `adres`='%s', `vehicles`='%s', \
													`height`='%d', `skincolor`='%s', `eyescolor`='%s', `arrestnum`='%d', `arrestreason`='%s', `actualdate`='%s' WHERE `id`='%d'", upf_name, surname, nick,
													adres, vehicles, height, skincolor, eyescolor, arrestnum, arrestreason, date, upf_uid);
													
	mysql_function_query(mysqlHandle, string, false, "", "");
	return 1;
}

stock TaserTime(playerid)
{
	TogglePlayerControllable(playerid, 1);
	return 1;
}

stock GetPlayerNameFunc(playerid)
{
	new plName[128];
	GetPlayerName(playerid, plName, sizeof(plName));
	
	strdel(plName, strfind(plName, "_"), strlen(plName));
	return plName;
}

stock GetPlayerSurname(playerid)
{
	new pSurname[128];
	GetPlayerName(playerid, pSurname, sizeof(pSurname));
	
	strdel(pSurname, 0, strfind(pSurname, "_")+1);
	return pSurname;
}

stock FormatDate()
{
	new day, month, year, tinystring[32];
	
	getdate(year, month, day);
	format(tinystring, sizeof(tinystring), "%d/%d/%d", day, month, year);
	
	return tinystring;
}

forward WantedVehicleQuery(playerid, sstring[], option, int);
public WantedVehicleQuery(playerid, sstring[], option, int)
{
	switch(option)
	{
		case 1:
		{
			new string[1024], rows, fields, new_uid[32], new_color[64], new_model[64], new_reg[64], new_madedate[32], uuid;
	
			cache_get_data(rows, fields, mysqlHandle);
	
			if(rows == 0) return ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Szukaj", "Brak wyników.", "OK", "");
				
			for(new i=0; i<rows; i++)
			{
				cache_get_field_content(i, "id", new_uid);
				cache_get_field_content(i, "color", new_color);
				cache_get_field_content(i, "model", new_model);
				cache_get_field_content(i, "registration", new_reg);
				cache_get_field_content(i, "madedate", new_madedate);
				uuid = strval(new_uid);
				format(string, sizeof(string), "%s\n%s %s %s %s (( UID: %d ))", string, new_madedate, new_model, new_color, new_reg, uuid);
			}
					
			ShowPlayerDialog(playerid, 83, DIALOG_STYLE_LIST, "Baza danych LSPD -> Szukaj", string, "Wybierz", "Anuluj");
			pInfo[playerid][t_dialogtmp2] = 1; // Poszukiwane pojazdy
			format(pInfo[playerid][t_stringtmp], 128, "%s", sstring);
		}
		case 2:
		{
			new string[128], bigstring[1024], rows, fields, suid[32], id;
			new vmodel[32], color[32], reg[32], special[64], driver[64], lastseen[32], madedate[32], actualdate[32];
			
			cache_get_data(rows, fields, mysqlHandle);
					
			for(new i=0; i<rows; i++)
			{
				if(id == int)
				{
					cache_get_field_content(i, "id", suid);
					cache_get_field_content(i, "model", vmodel);
					cache_get_field_content(i, "color", color);
					cache_get_field_content(i, "registration", reg);
					cache_get_field_content(i, "special", special);
					cache_get_field_content(i, "driver_desc", driver);
					cache_get_field_content(i, "last_seen", lastseen);
					cache_get_field_content(i, "madedate", madedate);
					cache_get_field_content(i, "actualdate", actualdate);
				}
				id++;
			}
				
			format(string, sizeof(string), "Baza danych LSPD -> %s", vmodel);
			format(bigstring, sizeof(bigstring), "Model: %s\nKolor: %s\nRejestracja: %s\nZnaki szczególne: %s\nOpis kierowcy: %s\nOstatnio widziany: %s\nData nadania: %s\nData aktualizacji: %s",
												vmodel, color, reg, special, driver, lastseen, madedate, actualdate);
												
			ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, string, bigstring, "OK", "");
		}
	}
	return 1;
}

forward WantedPersonQuery(playerid, sstring[], option, int);
public WantedPersonQuery(playerid, sstring[], option, int)
{
	switch(option)
	{
		case 1:
		{
			new rows, fields, string[1024], nname[32], surname[32], nick[32], id[16], uuid, madedate[32];
			
			cache_get_data(rows, fields, mysqlHandle);
				
			if(rows == 0) return ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Szukaj", "Brak wyników.", "OK", "");
			
			for(new i=0; i<rows; i++)
			{
				cache_get_field_content(i, "madedate", madedate);
				cache_get_field_content(i, "name", nname);
				cache_get_field_content(i, "surname", surname);
				cache_get_field_content(i, "nick", nick);
				cache_get_field_content(i, "id", id);
				uuid = strval(id);
				format(string, sizeof(string), "%s\n%s %s %s '%s' (( UID: %d ))", string, madedate, nname, surname, nick, uuid);
			}
				
			ShowPlayerDialog(playerid, 83, DIALOG_STYLE_LIST, "Baza danych LSPD -> Szukaj", string, "Wybierz", "Anuluj");
			pInfo[playerid][t_dialogtmp2] = 2; // Poszukiwane osoby
			format(pInfo[playerid][t_stringtmp], 128, "%s", sstring);
		}
		case 2:
		{
			new string[128], bigstring[1024], nname[32], surname[32], nick[32], adres[32], vehicles[64], sheight[16], height, skincolor[32], eyescolor[32], lastseen[64], madedate[32], actualdate[32];
			new rows, fields, id;
			
			cache_get_data(rows, fields, mysqlHandle);
			
			for(new i=0; i<rows; i++)
			{
				if(id == int)
				{
					cache_get_field_content(i, "name", nname);
					cache_get_field_content(i, "surname", surname);
					cache_get_field_content(i, "nick", nick);
					cache_get_field_content(i, "adres", adres);
					cache_get_field_content(i, "vehicles", vehicles);
					cache_get_field_content(i, "height", sheight);
					cache_get_field_content(i, "skincolor", skincolor);
					cache_get_field_content(i, "eyescolor", eyescolor);
					cache_get_field_content(i, "lastseen", lastseen);
					cache_get_field_content(i, "madedate", madedate);
					cache_get_field_content(i, "actualdate", actualdate);
					height = strval(sheight);
				}
				id++;
			}

			format(string, sizeof(string), "Baza danych LSPD -> '%s'", surname);
			format(bigstring, sizeof(bigstring), "Imiê: %s\nNazwisko: %s\nKsywa: %s\nAdres zamieszkania: %s\n\
												Pojazdy: %s\nWzrost: %dcm\nKolor skóry: %s\nKolor oczu: %s\nOstatnio widziany: %s \n\
												Data nadania: %s\nData aktualizacji: %s",
												nname, surname, nick, adres, vehicles, height,
												skincolor, eyescolor, lastseen, madedate, actualdate);
				
			ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, string, bigstring, "OK", "");
		}
	}
	return 1;
}

forward TowedVehicleQuery(playerid, sstring[], option, int);
public TowedVehicleQuery(playerid, sstring[], option, int)
{
	switch(option)
	{
		case 1:
		{
			new string[1024], rows, fields, madedate[32], vmodel[32], color[32], suid[16], uidd;
			
			cache_get_data(rows, fields, mysqlHandle);
			
			if(rows == 0) return ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Szukaj", "Brak wyników.", "OK", "");

			for(new i=0; i<rows; i++)
			{
				cache_get_field_content(i, "madedate", madedate);
				cache_get_field_content(i, "model", vmodel);
				cache_get_field_content(i, "color", color);
				cache_get_field_content(i, "id", suid);
				uidd = strval(suid);
				format(string, sizeof(string), "%s\n%s %s %s (( UID: %d ))", string, madedate, vmodel, color, uidd);	
			}
					
			ShowPlayerDialog(playerid, 83, DIALOG_STYLE_LIST, "Baza danych LSPD -> Szukaj", string, "Wybierz", "Anuluj");
			pInfo[playerid][t_dialogtmp2] = 3; // Odholowane pojazdy
			format(pInfo[playerid][t_stringtmp], 128, "%s", sstring);
		}
		case 2:
		{
			new string[128], bigstring[512], vuid, rows, fields, svuid[16], vmodel[32], color[32], special[64], towedfrom[64], towedreason[64], towprice, sprice[16];
			new madedate[32], actualdate[32], id;
			
			cache_get_data(rows, fields, mysqlHandle);
			
			for(new i=0; i<rows; i++)
			{
				if(id == int)
				{
					cache_get_field_content(i, "uid", svuid);
					cache_get_field_content(i, "model", vmodel);
					cache_get_field_content(i, "color", color);
					cache_get_field_content(i, "special", special);
					cache_get_field_content(i, "towedfrom", towedfrom);
					cache_get_field_content(i, "towedreason", towedreason);
					cache_get_field_content(i, "price", sprice);
					cache_get_field_content(i, "madedate", madedate);
					cache_get_field_content(i, "actualdate", actualdate);
					vuid = strval(svuid);
					towprice = strval(sprice);
				}
				id++;
			}
				
			format(string, sizeof(string), "Baza danych LSPD -> %s", vmodel);
			format(bigstring, sizeof(bigstring), "Numer seryjny (UID): %d\nMarka: %s\nKolor: %s\nZnaki szczególne: %s\n \
												Odholowany z: %s\nPowód odholowania: %s\nCena wykupu: $%d\nData nadania: %s\nData aktualizacji: %s",
												vuid, vmodel, color, special, towedfrom, towedreason, towprice, madedate, actualdate);
				
			ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, string, bigstring, "OK", "");
		}
	}
	return 1;
}

forward PoliceFileQuery(playerid, sstring[], option, int);
public PoliceFileQuery(playerid, sstring[], option, int)
{
	switch(option)
	{
		case 1:
		{
			new rows, fields, string[1024], madedate[32], nname[32], surname[32], nick[32], suid[16], uidd;
		
			cache_get_data(rows, fields, mysqlHandle);

			if(rows == 0) return ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Szukaj", "Brak wyników.", "OK", "");
	
			for(new i=0; i<rows; i++)
			{
				cache_get_field_content(i, "madedate", madedate);
				cache_get_field_content(i, "name", nname);
				cache_get_field_content(i, "surname", surname);
				cache_get_field_content(i, "nick", nick);
				cache_get_field_content(i, "id", suid);
				uidd = strval(suid);
				format(string, sizeof(string), "%s\n%s %s %s '%s' (( UID: %d ))", string, madedate, nname, surname, nick, uidd);
	
			}					
								
			ShowPlayerDialog(playerid, 83, DIALOG_STYLE_LIST, "Baza danych LSPD -> Szukaj", string, "Wybierz", "Anuluj");
			pInfo[playerid][t_dialogtmp2] = 4; // Kartoteki
			format(pInfo[playerid][t_stringtmp], 128, "%s", sstring);
		}
		case 2:
		{
			new string[128], bigstring[1024], nname[32], surname[32], nick[32], adres[32], vehicles[64], sheight[16], skincolor[32], eyescolor[32], sarrnum[16];
			new arrreason[64], madedate[32], actualdate[32], rows, fields, height, arrnum, id;
		
			cache_get_data(rows, fields, mysqlHandle);
			
			for(new i=0; i<rows; i++)
			{
				if(id == int)
				{
					cache_get_field_content(i, "name", nname);
					cache_get_field_content(i, "surname", surname);
					cache_get_field_content(i, "nick", nick);
					cache_get_field_content(i, "adres", adres);
					cache_get_field_content(i, "vehicles", vehicles);
					cache_get_field_content(i, "height", sheight);
					cache_get_field_content(i, "skincolor", skincolor);
					cache_get_field_content(i, "eyescolor", eyescolor);
					cache_get_field_content(i, "arrestnum", sarrnum);
					cache_get_field_content(i, "arrestreason", arrreason);
					cache_get_field_content(i, "madedate", madedate);
					cache_get_field_content(i, "actualdate", actualdate);
					height = strval(sheight);
					arrnum = strval(sarrnum);
				}
				id++;
			}
			
				
			format(string, sizeof(string), "Baza danych LSPD -> '%s'", nick);
			format(bigstring, sizeof(bigstring), "Imiê: %s\nNazwisko: %s\nKsywa: %s\nAdres zamieszkania: %s\nPojazdy: %s\n \
												Wzrost: %dcm\nKolor skóry: %s\nKolor oczu: %s\nAresztowania (Iloœæ): %d\nPowody aresztowañ: %s\nData utworzenia: %s\nData aktualizacji: %s",
												nname, surname, nick, adres,
												vehicles, height, skincolor, eyescolor,
												arrnum, arrreason, madedate, actualdate);
				
			ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, string, bigstring, "OK", "");
		}
	}
	return 1;
}

forward TicketQuery(playerid, sstring[], option, int);
public TicketQuery(playerid, sstring[], option, int)
{
	switch(option)
	{
		case 1:
		{
			new rows, fields, string[1024], date[32], nname[32], surname[32], suid[16], uidd;
			
			cache_get_data(rows, fields, mysqlHandle);
		
			if(rows == 0) return ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Szukaj", "Brak wyników.", "OK", "");

			for(new i=0; i<rows; i++)
			{
				cache_get_field_content(i, "date", date);
				cache_get_field_content(i, "name", nname);
				cache_get_field_content(i, "surname", surname);
				cache_get_field_content(i, "id", suid);
				uidd = strval(suid);
				format(string, sizeof(string), "%s\n%s %s %s (( UID: %d ))", string, date, nname, surname, uidd);
			}
												
			ShowPlayerDialog(playerid, 83, DIALOG_STYLE_LIST, "Baza danych LSPD -> Szukaj", string, "Wybierz", "Anuluj");
			pInfo[playerid][t_dialogtmp2] = 5; // Mandaty
			format(pInfo[playerid][t_stringtmp], 128, "%s", sstring);
		}
		case 2:
		{
			new rows, fields, string[128], bigstring[512], nname[32], surname[32], scost[16], spkt[16], reason[64], sstatus[16], status, cost, pkt, tinystring[32], id, date[32];
			
			cache_get_data(rows, fields, mysqlHandle);
			
			for(new i=0; i<rows; i++)
			{
				if(id == int)
				{
					cache_get_field_content(i, "name", nname);
					cache_get_field_content(i, "surname", surname);
					cache_get_field_content(i, "cost", scost);
					cache_get_field_content(i, "pkt", spkt);
					cache_get_field_content(i, "reason", reason);
					cache_get_field_content(i, "date", date);
					cache_get_field_content(i, "status", sstatus);
					status = strval(sstatus);
					cost = strval(scost);
					pkt = strval(spkt);
				}
				id++;
			}
					
			if(status == 0)
				format(tinystring, sizeof(tinystring), C_CZERWONY"Niezap³acony");
			else	
				format(tinystring, sizeof(tinystring), C_ZIELONY"Zap³acony");
						
			format(string, sizeof(string), "Baza danych LSPD -> %s", date);
			format(bigstring, sizeof(bigstring), "Imiê: %s\nNazwisko: %s\nKwota: %d\nPunkty karne: %d\nPowód: %s\nData: %s\nStatus: %s", nname, surname, cost, pkt, reason, date, tinystring);
					
			ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, string, bigstring, "OK", "");
		}
		case 3:
		{
			new rows, fields, sstatus[16], status;
			
			cache_get_data(rows, fields, mysqlHandle);
			
			if(rows == 0) return ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Zdejmij mandat", "Nie ma mandatu o takim numerze.", "OK", "");
			
			for(new i=0; i<rows; i++)
			{
				cache_get_field_content(i, "status", sstatus);
				status = strval(sstatus);
			}
			
			if(status == 1) return ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Zdejmij mandat", "Ten mandat nie jest ju¿ aktualny", "OK", "");
		}
	}
	return 1;
}

forward DeletePoliceRecord(playerid, uidd, int);
public DeletePoliceRecord(playerid, uidd, int)
{
	new string[128], rows, fields;
	
	cache_get_data(rows, fields, mysqlHandle);
	
	if(rows > 0)
	{
		switch(int)
		{
			case 1: format(string, sizeof(string), "DELETE FROM `plerp_wantedvehicles` WHERE `id`='%d'", uidd);
			case 2: format(string, sizeof(string), "DELETE FROM `plerp_wantedperson` WHERE `id`='%d'", uidd);
			case 3: format(string, sizeof(string), "DELETE FROM `plerp_towedvehicles` WHERE `id`='%d'", uidd);
			case 4: format(string, sizeof(string), "DELETE FROM `plerp_policefiles` WHERE `id`='%d'", uidd);
		}
		
		mysql_function_query(mysqlHandle, string, false, "", "");
		ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Usuñ", "Z powodzeniem usun¹³eœ wpis z bazy danych LSPD.", "OK", "");
	} else
	{
		ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Usuñ", "W bazie danych LSPD nie ma wpisu o takim numerze.", "OK", "");
	}
	return 1;
}

forward EditPoliceRecord(playerid, uidd, int);
public EditPoliceRecord(playerid, uidd, int)
{
	new rows, fields;
	
	cache_get_data(rows, fields, mysqlHandle);
	
	if(rows > 0)
	{
		switch(int)
		{
			case 1:
			{
				ShowPlayerDialog(playerid, 90, DIALOG_STYLE_INPUT, "Baza danych LSPD -> Edytuj wpis", "Wpisz dane w formacie: \
																	\nModel;Kolor;Rejestracja;Znaki szczególne;Opis kierowcy;Ostatnio widziany", "Akceptuj", "Anuluj");
				pInfo[playerid][t_dialogtmp2] = uidd;
			}
			case 2:
			{
				ShowPlayerDialog(playerid, 90, DIALOG_STYLE_INPUT, "Baza danych LSPD -> Edytuj wpis", "Wpisz dane w formacie: \
																	\nImiê;Nazwisko;Ksywa;Adres;Pojazdy;Wzrost;Kolor skóry;Kolor oczu;Ostatnio widziany", "Akceptuj", "Anuluj");				
				pInfo[playerid][t_dialogtmp2] = uidd;
			}
			case 3:
			{
				ShowPlayerDialog(playerid, 90, DIALOG_STYLE_INPUT, "Baza danych LSPD -> Edytuj wpis", "Wpisz dane w formacie: \
																	\nNumer seryjny(UID);Marka;Kolor;Znaki szczególne;Sk¹d odholowany;Powód odholowania;Cena wykupu", "Akceptuj", "Anuluj");												
				pInfo[playerid][t_dialogtmp2] = uidd;
			}
			case 4:
			{
				ShowPlayerDialog(playerid, 90, DIALOG_STYLE_INPUT, "Baza danych LSPD -> Edytuj wpis", "Dodaj wpis w formacie: \
																	\nImiê;Nazwisko;Ksywa;Adres;Pojazdy;Wzrost;Kolor skóry;Kolor oczu;Aresztowania(iloœæ);Powody aresztowañ", "Akceptuj", "Anuluj");
				pInfo[playerid][t_dialogtmp2] = uidd;
			}
		}
	} else
	{
		ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Edytuj wpis", "Wpis o danym numerze nie istnieje w bazie danych LSPD.", "OK", "");
	}
	return 1;
}

forward TireBlockadeQuery(playerid, inputtext[], option, int);
public TireBlockadeQuery(playerid, inputtext[], option, int)
{
	new rows, fields, string[512];
	
	cache_get_data(rows, fields, mysqlHandle);
	
	switch(option)
	{
		case 1:
		{
			if(rows > 0)
			{
				/// Zapytanie Mysql i zmiana w tablicy pojazdu
			
				format(string, sizeof(string), "DELETE FROM `plerp_tireblockades` WHERE `registration`='%s'", inputtext);
				mysql_function_query(mysqlHandle, string, false, "", "");
				
				format(string, sizeof(string), "Zdj¹³eœ blokadê z pojazdu o rejestracji %s", inputtext);
				SendClientMessage(playerid, COLOR_GREEN, string);
			} else
			{
				SendClientMessage(playerid, COLOR_GREY, "Pojazd o takiej rejestracji nie ma za³o¿onej blokady.");
			}	
		}
		case 2: 
		{
			new suid[16], reg[64], reason[64], uidd;
			
			if(rows > 0)
			{
			
				for(new i=0; i<rows; i++)
				{
					cache_get_field_content(i, "id", suid);
					cache_get_field_content(i, "registration", reg);
					cache_get_field_content(i, "reason", reason);
					uidd = strval(suid);
					format(string, sizeof(string), "%s\n%s (( UID: %d ))", string, reg, uidd);
				}
				
				ShowPlayerDialog(playerid, 83, DIALOG_STYLE_LIST, "Baza danych LSPD -> Szukaj", string, "Wybierz", "Anuluj");
				pInfo[playerid][t_dialogtmp2] = 6; // Bloady kó³
				format(pInfo[playerid][t_stringtmp], 128, "%s", inputtext);
			} else
			{
				ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Szukaj", "Brak wyników.", "OK", "");
			}
		}
		case 3:
		{
			new reg[64], scost[16], reason[64], cost, id, bigstring[512];
			
			for(new i=0; i<rows; i++)
			{
				if(id == int)
				{
					cache_get_field_content(i, "registration", reg);
					cache_get_field_content(i, "cost", scost);
					cache_get_field_content(i, "reason", reason);
					cost = strval(scost);
				}
				id++;
			}
			
			format(string, sizeof(string), "Baza danych LSPD -> %s", reg);
			format(bigstring, sizeof(bigstring), "Rejestracja: %s\nKwota zdjêcia blokady: $%d\nPowód za³o¿enia blokady: %s", reg, cost, reason);
					
			ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, string, bigstring, "OK", "");
		}			
	}
	return 1;			
}














			