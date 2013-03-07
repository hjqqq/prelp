COMMAND:metryczki(playerid)
{
	//if(nie ma dostepu) return SendClientMessage(playerid, -,1 "Nie posiadasz dostÍpu do metryczek");
	if(!IsPlayerInGroupType(playerid, 7)) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Brak dostÍpu", "Nie posiadasz dostÍpu do bazy danych", "OK", "");
	ShowPlayerDialog(playerid, 50, DIALOG_STYLE_LIST, "Metryki Zdrowotne", "Wyszukaj metryczke\nDodaj metryczke", "Wybierz", "Wyjdü");
	return 1;

}
forward MetryczkiMysqlQuery(playerid);
public MetryczkiMysqlQuery(playerid)
{
	new string[64], dint[3], imie[30], nazwisko[30], dialogstring[256], rows, fields;
	cache_get_data(rows, fields, mysqlHandle);
	if(!rows) return ShowPlayerDialog(playerid, 51, DIALOG_STYLE_INPUT, "Metryki Zdrowotne -> B≥πd", "Nie znaleziono øadnej metryki o podanych wartoúciach.\nPoniøej podaj numer ubezpieczenia pacjenta bπdü jego nazwisko", "Wyszukaj", "Wyjdü");		
	for(new i=0; i<rows; i++)
	{
		cache_get_field_content(i, "uid", string);
		dint[0] = strval(string);
		cache_get_field_content(i, "owner", string);
		dint[1] = strval(string);		
		cache_get_field_content(i, "rok_urodzenia", string);
		dint[2] = strval(string);		
		cache_get_field_content(i, "imie", imie);	
		cache_get_field_content(i, "nazwisko", nazwisko);	
		format(string, sizeof(string), "\n%i\t%s %s(%i r.:UB %i)", dint[0], imie, nazwisko, dint[2], dint[0]);
		strcat(dialogstring, string);
	}
	if(strlen(dialogstring) > sizeof(dialogstring)) return 1;
	ShowPlayerDialog(playerid, 53, DIALOG_STYLE_LIST, "Metyki Zdrowotne -> Lista", dialogstring, "Wybierz", "Wyjdü");
	return 1;
}
forward MetryczkiMoreMysqlQuery(playerid);
public MetryczkiMoreMysqlQuery(playerid)
{
	new string[64], dint[4], imie[30], nazwisko[30], dialogstring[256], last[30], adden[30];
	cache_get_field_content(0, "owner", string);
	dint[0] = strval(string);		
	cache_get_field_content(0, "rok_urodzenia", string);
	dint[1] = strval(string);		
	cache_get_field_content(0, "wzrost", string);
	dint[2] = strval(string);		
	cache_get_field_content(0, "waga", string);
	dint[3] = strval(string);		
	cache_get_field_content(0, "imie", imie);	
	cache_get_field_content(0, "nazwisko", nazwisko);	
	cache_get_field_content(0, "last_update", last);	
	cache_get_field_content(0, "date", adden);	
	format(dialogstring, sizeof(dialogstring), "Lista WpisÛw\nDrukuj\nEdytuj\nImie:\t\t\t\t%s\nNazwisko:\t\t\t%s\nWaga:\t\t\t\t%i kg\nWzrost:\t\t\t\t%i cm\nRocznik:\t\t\t%i\nDodana:\t\t\t%s\nOstatnia zmiana:\t\t\t%s",\
	imie, nazwisko, dint[3], dint[2], dint[1], adden, last);
	format(string, sizeof(string), "Metryka Zdrowotna ->%s %s", imie, nazwisko);
	ShowPlayerDialog(playerid, 54, DIALOG_STYLE_LIST, string, dialogstring, "OK", "Wyjdü");
	format(pInfo[playerid][t_stringtmp], 64, "Imie: %s\nNazwisko: %s\nWaga: %i kg\nWzrost %i cm", imie, nazwisko, dint[3], dint[2]);
	return 1;
}
forward MetryczkiWpisyMysqlQuery(playerid);
public MetryczkiWpisyMysqlQuery(playerid)
{
	new date[30], uidee, dodany[30], dialogstring[500], string[60], rows, fields;
	cache_get_data(rows, fields, mysqlHandle);
	if(!rows) return ShowPlayerDialog(playerid, 56, DIALOG_STYLE_LIST, "Metryka Zdrowotna -> Wpisy", "Dodaj Wpis", "Wybierz", "Wyjdü");
	strcat(dialogstring, "Dodaj Wpis\n");
	for(new i=0; i<rows; i++)
	{
		cache_get_field_content(i, "uid", dodany);	
		uidee = strval(dodany);
		cache_get_field_content(i, "data", date);		
		cache_get_field_content(i, "dodany", dodany);	
		format(string, sizeof(string), "\n%i\tDodany przez %s %s", uidee, dodany, date);
		strcat(dialogstring, string);
	}
	ShowPlayerDialog(playerid, 56, DIALOG_STYLE_LIST, "Metryki Zdrowotne -> Wpisy", dialogstring, "Wybierz", "Wyjdü");
	return 1;
}
forward MetryczkiWpisMysqlQuery(playerid);
public MetryczkiWpisMysqlQuery(playerid)
{
	new date[30], adder[30], content[130], dialog[190], rows, fields;
	cache_get_data(rows, fields, mysqlHandle);
	if(!rows) return 1;
	cache_get_field_content(0, "data", date);	
	cache_get_field_content(0, "dodany", adder);	
	cache_get_field_content(0, "content", content);	
	format(dialog, sizeof(dialog), "Usun Wpis\nData dodania:\t%s\nDodany przez:\t%s\nTreúÊ wpisu\n%s", date, adder, content);
	ShowPlayerDialog(playerid, 57, DIALOG_STYLE_LIST, "Metryki Zdrowotne -> Wpis", dialog, "Wybierz", "Wyjdü");
	return 1;
}