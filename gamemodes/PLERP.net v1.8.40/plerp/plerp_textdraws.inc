InitTextdrawsOnGameModeInit()
{
 	NoAudioClient = TextDrawCreate(499.000000, 8.000000, "Brak klienta audio");
 	TextDrawBackgroundColor(NoAudioClient, -16776961);
 	TextDrawFont(NoAudioClient, 2);
 	TextDrawLetterSize(NoAudioClient, 0.240000, 1.500000);
 	TextDrawColor(NoAudioClient, -1);
 	TextDrawSetOutline(NoAudioClient, 1);
 	TextDrawSetProportional(NoAudioClient, 1);

 	EngineStartTd = TextDrawCreate(325.000000, 328.000000, "trwa odpalanie silnika...");
 	TextDrawAlignment(EngineStartTd, 2);
 	TextDrawBackgroundColor(EngineStartTd, 255);
 	TextDrawFont(EngineStartTd, 2);
 	TextDrawLetterSize(EngineStartTd, 0.479999, 1.799998);
 	TextDrawColor(EngineStartTd, -1);
 	TextDrawSetOutline(EngineStartTd, 0);
 	TextDrawSetProportional(EngineStartTd, 1);
 	TextDrawSetShadow(EngineStartTd, 1);
	
	td_911 = TextDrawCreate(602.000000, 112.000000, "Nowe zgloszenie");
    TextDrawAlignment(td_911, 3);
    TextDrawBackgroundColor(td_911, 255);
    TextDrawFont(td_911, 1);
    TextDrawLetterSize(td_911, 0.340000, 1.100000);
    TextDrawColor(td_911, -65281);
    TextDrawSetOutline(td_911, 1);
    TextDrawSetProportional(td_911, 1);
    TextDrawTextSize(td_911, 714.000000, 112.00000);
    TextDrawSetSelectable(td_911, 1);
	
	LSNTextdraw[1] = TextDrawCreate(1.000000, 437.000000, "DO DOMU");
    TextDrawBackgroundColor(LSNTextdraw[1], 255);
    TextDrawFont(LSNTextdraw[1], 1);
    TextDrawLetterSize(LSNTextdraw[1], 0.159999, 0.899999);
    TextDrawColor(LSNTextdraw[1], -1);
    TextDrawSetOutline(LSNTextdraw[1], 1);
    TextDrawSetProportional(LSNTextdraw[1], 1);
	
	LSNTextdraw[0] = TextDrawCreate(-90.000000, 437.000000, "~n~");
    TextDrawBackgroundColor(LSNTextdraw[0], 255);
    TextDrawFont(LSNTextdraw[0], 1);
    TextDrawLetterSize(LSNTextdraw[0], 2.999999, 1.700000);
    TextDrawColor(LSNTextdraw[0], -1);
    TextDrawSetOutline(LSNTextdraw[0], 0);
    TextDrawSetProportional(LSNTextdraw[0], 1);
    TextDrawSetShadow(LSNTextdraw[0], 1);
    TextDrawUseBox(LSNTextdraw[0], 1);
    TextDrawBoxColor(LSNTextdraw[0], 86);
    TextDrawTextSize(LSNTextdraw[0], 761.000000, 0.000000);
}

InitTextdrawsOnPlayerConnect(playerid)
{
    NoCars = CreatePlayerTextDraw(playerid, 189.000000, 270.000000, "Nie posiadasz pojazdow");
 	PlayerTextDrawBackgroundColor(playerid, NoCars, 255);
 	PlayerTextDrawFont(playerid, NoCars, 2);
 	PlayerTextDrawLetterSize(playerid, NoCars, 0.490000, 1.900000);
 	PlayerTextDrawColor(playerid, NoCars, 0xFFEDD2FF);
 	PlayerTextDrawSetOutline(playerid, NoCars, 0);
 	PlayerTextDrawSetProportional(playerid, NoCars, 1);
 	PlayerTextDrawSetShadow(playerid, NoCars, 1);
	
	carSpawnTd = CreatePlayerTextDraw(playerid, 195.000000, 270.000000, "");
 	PlayerTextDrawBackgroundColor(playerid, carSpawnTd, 255);
 	PlayerTextDrawFont(playerid, carSpawnTd, 2);
 	PlayerTextDrawLetterSize(playerid, carSpawnTd, 0.490000, 1.900000);
 	PlayerTextDrawColor(playerid, carSpawnTd, 0xFFEDD2FF);
 	PlayerTextDrawSetOutline(playerid, carSpawnTd, 0);
 	PlayerTextDrawSetProportional(playerid, carSpawnTd, 1);
 	PlayerTextDrawSetShadow(playerid, carSpawnTd, 1);

 	carLockStateChangeTd = CreatePlayerTextDraw(playerid, 325.000000, 328.000000, "Pojazd otwarty");
 	PlayerTextDrawAlignment(playerid, carLockStateChangeTd, 2);
 	PlayerTextDrawBackgroundColor(playerid, carLockStateChangeTd, 255);
 	PlayerTextDrawFont(playerid, carLockStateChangeTd, 2);
 	PlayerTextDrawLetterSize(playerid, carLockStateChangeTd, 0.479999, 1.799998);
 	PlayerTextDrawColor(playerid, carLockStateChangeTd, -1);
 	PlayerTextDrawSetOutline(playerid, carLockStateChangeTd, 0);
 	PlayerTextDrawSetProportional(playerid, carLockStateChangeTd, 1);
 	PlayerTextDrawSetShadow(playerid, carLockStateChangeTd, 1);

	carTdSpeedo[0] = CreatePlayerTextDraw(playerid, 517.000000, 358.000000, "~n~~n~");
	PlayerTextDrawBackgroundColor(playerid, carTdSpeedo[0], 255);
	PlayerTextDrawFont(playerid, carTdSpeedo[0], 0);
	PlayerTextDrawLetterSize(playerid, carTdSpeedo[0], 0.800000, 2.500000);
	PlayerTextDrawColor(playerid, carTdSpeedo[0], -1);
	PlayerTextDrawSetOutline(playerid, carTdSpeedo[0], 0);
	PlayerTextDrawSetProportional(playerid, carTdSpeedo[0], 1);
	PlayerTextDrawSetShadow(playerid, carTdSpeedo[0], 1);
	PlayerTextDrawUseBox(playerid, carTdSpeedo[0], 1);
	PlayerTextDrawBoxColor(playerid, carTdSpeedo[0], 50);
	PlayerTextDrawTextSize(playerid, carTdSpeedo[0], 568.000000, 22.000000);

	carTdSpeedo[1] = CreatePlayerTextDraw(playerid, 522.000000, 389.000000, "km/h");
	PlayerTextDrawBackgroundColor(playerid, carTdSpeedo[1], 255);
	PlayerTextDrawFont(playerid, carTdSpeedo[1], 1);
	PlayerTextDrawLetterSize(playerid, carTdSpeedo[1], 0.500000, 1.000000);
	PlayerTextDrawColor(playerid, carTdSpeedo[1], -1);
	PlayerTextDrawSetOutline(playerid, carTdSpeedo[1], 0);
	PlayerTextDrawSetProportional(playerid, carTdSpeedo[1], 1);
	PlayerTextDrawSetShadow(playerid, carTdSpeedo[1], 1);

	carTdSpeedo[2] = CreatePlayerTextDraw(playerid, 542.000000, 358.000000, "0");
	PlayerTextDrawAlignment(playerid, carTdSpeedo[2], 2);
	PlayerTextDrawBackgroundColor(playerid, carTdSpeedo[2], 255);
	PlayerTextDrawFont(playerid, carTdSpeedo[2], 3);
	PlayerTextDrawLetterSize(playerid, carTdSpeedo[2], 0.800000, 3.3000000);
	PlayerTextDrawColor(playerid, carTdSpeedo[2], -1);
	PlayerTextDrawSetOutline(playerid, carTdSpeedo[2], 0);
	PlayerTextDrawSetProportional(playerid, carTdSpeedo[2], 1);
	PlayerTextDrawSetShadow(playerid, carTdSpeedo[2], 1);

	carBarHud = CreatePlayerTextDraw(playerid, 332.000000, 87.000000, "Uzyj ~y~LCTRL~w~ aby odpalic silnik lub ~y~LALT~w~ aby wlaczyc swiatla.");
	PlayerTextDrawBackgroundColor(playerid, carBarHud, 255);
	PlayerTextDrawFont(playerid, carBarHud, 1);
	PlayerTextDrawLetterSize(playerid, carBarHud, 0.249999, 0.799998);
	PlayerTextDrawColor(playerid, carBarHud, -1);
	PlayerTextDrawSetOutline(playerid, carBarHud, 0);
	PlayerTextDrawSetProportional(playerid, carBarHud, 1);
	PlayerTextDrawSetShadow(playerid, carBarHud, 1);
	PlayerTextDrawUseBox(playerid, carBarHud, 1);
	PlayerTextDrawBoxColor(playerid, carBarHud, 120);
	PlayerTextDrawTextSize(playerid, carBarHud, 454.000000, 0.000000);

    carFuel[0] = CreatePlayerTextDraw(playerid, 572.000000, 358.000000, "~n~");
    PlayerTextDrawBackgroundColor(playerid, carFuel[0], 255);
    PlayerTextDrawFont(playerid, carFuel[0], 1);
    PlayerTextDrawLetterSize(playerid, carFuel[0], 1.440000, 5.000000);
    PlayerTextDrawColor(playerid, carFuel[0], -1);
    PlayerTextDrawSetOutline(playerid, carFuel[0], 0);
    PlayerTextDrawSetProportional(playerid, carFuel[0], 1);
    PlayerTextDrawSetShadow(playerid, carFuel[0], 1);
    PlayerTextDrawUseBox(playerid, carFuel[0], 1);
    PlayerTextDrawBoxColor(playerid, carFuel[0], 50);
    PlayerTextDrawTextSize(playerid, carFuel[0], 592.000000, 0.000000);

    carFuel[1] = CreatePlayerTextDraw(playerid, 594.000000, 359.000000, "~n~");
    PlayerTextDrawBackgroundColor(playerid, carFuel[1], 255);
    PlayerTextDrawFont(playerid, carFuel[1], 1);
    PlayerTextDrawLetterSize(playerid, carFuel[1], 0.500000, 4.799997);
    PlayerTextDrawColor(playerid, carFuel[1], -1);
    PlayerTextDrawSetOutline(playerid, carFuel[1], 0);
    PlayerTextDrawSetProportional(playerid, carFuel[1], 1);
    PlayerTextDrawSetShadow(playerid, carFuel[1], 1);
    PlayerTextDrawUseBox(playerid, carFuel[1], 1);
    PlayerTextDrawBoxColor(playerid, carFuel[1], -8388531);
    PlayerTextDrawTextSize(playerid, carFuel[1], 570.000000, 7.000000);

    carFuel[2] = CreatePlayerTextDraw(playerid, 594.000000, 405.000000, "~n~");
    PlayerTextDrawBackgroundColor(playerid, carFuel[2], 255);
    PlayerTextDrawFont(playerid, carFuel[2], 1);
    PlayerTextDrawLetterSize(playerid, carFuel[2], 0.500000, -1.199992);
    PlayerTextDrawColor(playerid, carFuel[2], -1);
    PlayerTextDrawSetOutline(playerid, carFuel[2], 0);
    PlayerTextDrawSetProportional(playerid, carFuel[2], 1);
    PlayerTextDrawSetShadow(playerid, carFuel[2], 1);
    PlayerTextDrawUseBox(playerid, carFuel[2], 1);
    PlayerTextDrawBoxColor(playerid, carFuel[2], -8388427);
    PlayerTextDrawTextSize(playerid, carFuel[2], 570.000000, -20.000000);

    carFuel[3] = CreatePlayerTextDraw(playerid, 582.000000, 382.000000, "4.43l");
    PlayerTextDrawAlignment(playerid, carFuel[3], 2);
    PlayerTextDrawBackgroundColor(playerid, carFuel[3], -16776961);
    PlayerTextDrawFont(playerid, carFuel[3], 1);
    PlayerTextDrawLetterSize(playerid, carFuel[3], 0.185000, 0.659999);
    PlayerTextDrawColor(playerid, carFuel[3], -1);
    PlayerTextDrawSetOutline(playerid, carFuel[3], 0);
    PlayerTextDrawSetProportional(playerid, carFuel[3], 1);
    PlayerTextDrawSetShadow(playerid, carFuel[3], 0);

    carFuel[4] = CreatePlayerTextDraw(playerid, 582.500000, 388.000000, "45%");
    PlayerTextDrawAlignment(playerid, carFuel[4], 2);
    PlayerTextDrawBackgroundColor(playerid, carFuel[4], 255);
    PlayerTextDrawFont(playerid, carFuel[4], 1);
    PlayerTextDrawLetterSize(playerid, carFuel[4], 0.170000, 0.449999);
    PlayerTextDrawColor(playerid, carFuel[4], -1);
    PlayerTextDrawSetOutline(playerid, carFuel[4], 0);
    PlayerTextDrawSetProportional(playerid, carFuel[4], 1);
    PlayerTextDrawSetShadow(playerid, carFuel[4], 0);

 	itemsStaticTd[0] = CreatePlayerTextDraw(playerid, 160.000000, 128.000000, "ID              NAZWA                                                              OPCJE");
 	PlayerTextDrawBackgroundColor(playerid, itemsStaticTd[0], 255);
 	PlayerTextDrawFont(playerid, itemsStaticTd[0], 2);
 	PlayerTextDrawLetterSize(playerid, itemsStaticTd[0], 0.200000, 0.999998);
 	PlayerTextDrawColor(playerid, itemsStaticTd[0], -340237057);
 	PlayerTextDrawSetOutline(playerid, itemsStaticTd[0], 1);
 	PlayerTextDrawSetProportional(playerid, itemsStaticTd[0], 1);

 	itemsStaticTd[1] = CreatePlayerTextDraw(playerid, 486.000000, 268.500000, "Nastepna");
 	PlayerTextDrawAlignment(playerid, itemsStaticTd[1], 2);
 	PlayerTextDrawBackgroundColor(playerid, itemsStaticTd[1], 255);
 	PlayerTextDrawFont(playerid, itemsStaticTd[1], 1);
 	PlayerTextDrawLetterSize(playerid, itemsStaticTd[1], 0.189998, 0.599999);
 	PlayerTextDrawColor(playerid, itemsStaticTd[1], -1);
 	PlayerTextDrawSetOutline(playerid, itemsStaticTd[1], 1);
 	PlayerTextDrawSetProportional(playerid, itemsStaticTd[1], 1);
 	PlayerTextDrawUseBox(playerid, itemsStaticTd[1], 1);
 	PlayerTextDrawBoxColor(playerid, itemsStaticTd[1], 100);
 	PlayerTextDrawTextSize(playerid, itemsStaticTd[1], 9.000000, 32.000000);
 	PlayerTextDrawSetSelectable(playerid, itemsStaticTd[1], true);

 	itemsStaticTd[2] = CreatePlayerTextDraw(playerid, 445.000000, 268.500000, "Poprzednia");
 	PlayerTextDrawAlignment(playerid, itemsStaticTd[2], 2);
 	PlayerTextDrawBackgroundColor(playerid, itemsStaticTd[2], 255);
 	PlayerTextDrawFont(playerid, itemsStaticTd[2], 1);
 	PlayerTextDrawLetterSize(playerid, itemsStaticTd[2], 0.189998, 0.599999);
 	PlayerTextDrawColor(playerid, itemsStaticTd[2], -1);
 	PlayerTextDrawSetOutline(playerid, itemsStaticTd[2], 1);
 	PlayerTextDrawSetProportional(playerid, itemsStaticTd[2], 1);
 	PlayerTextDrawUseBox(playerid, itemsStaticTd[2], 1);
 	PlayerTextDrawBoxColor(playerid, itemsStaticTd[2], 100);
 	PlayerTextDrawTextSize(playerid, itemsStaticTd[2], 9.000000, 37.000000);
 	PlayerTextDrawSetSelectable(playerid, itemsStaticTd[2], true);
 	
 	itemsStaticTd[3] = CreatePlayerTextDraw(playerid, 182.000000, 268.500000, "Podnies");
 	PlayerTextDrawAlignment(playerid, itemsStaticTd[3], 2);
 	PlayerTextDrawBackgroundColor(playerid, itemsStaticTd[3], 255);
 	PlayerTextDrawFont(playerid, itemsStaticTd[3], 1);
 	PlayerTextDrawLetterSize(playerid, itemsStaticTd[3], 0.189998, 0.599999);
 	PlayerTextDrawColor(playerid, itemsStaticTd[3], -1);
 	PlayerTextDrawSetOutline(playerid, itemsStaticTd[3], 1);
 	PlayerTextDrawSetProportional(playerid, itemsStaticTd[3], 1);
 	PlayerTextDrawTextSize(playerid, itemsStaticTd[3], 9.000000, 30.000000);
 	PlayerTextDrawSetSelectable(playerid, itemsStaticTd[3], true);

 	itemsStaticTd[4] = CreatePlayerTextDraw(playerid, 250.000000, 268.500000, "Przedmioty");
 	PlayerTextDrawAlignment(playerid, itemsStaticTd[4], 2);
 	PlayerTextDrawBackgroundColor(playerid, itemsStaticTd[4], 255);
 	PlayerTextDrawFont(playerid, itemsStaticTd[4], 1);
 	PlayerTextDrawLetterSize(playerid, itemsStaticTd[4], 0.189998, 0.599999);
 	PlayerTextDrawColor(playerid, itemsStaticTd[4], -1);
 	PlayerTextDrawSetOutline(playerid, itemsStaticTd[4], 1);
 	PlayerTextDrawSetProportional(playerid, itemsStaticTd[4], 1);
 	PlayerTextDrawUseBox(playerid, itemsStaticTd[4], 1);
 	PlayerTextDrawBoxColor(playerid, itemsStaticTd[4], 100);
 	PlayerTextDrawTextSize(playerid, itemsStaticTd[4], 442.000000, -80.000000);

 	
 	DoorsInfo[0] = CreatePlayerTextDraw(playerid, 510.000000, 340.000000, "~n~");
 	PlayerTextDrawAlignment(playerid, DoorsInfo[0], 2);
 	PlayerTextDrawBackgroundColor(playerid, DoorsInfo[0], 255);
 	PlayerTextDrawFont(playerid, DoorsInfo[0], 1);
 	PlayerTextDrawLetterSize(playerid, DoorsInfo[0], 0.500000, 6.600000);
 	PlayerTextDrawColor(playerid, DoorsInfo[0], -1);
 	PlayerTextDrawSetOutline(playerid, DoorsInfo[0], 0);
 	PlayerTextDrawSetProportional(playerid, DoorsInfo[0], 1);
 	PlayerTextDrawSetShadow(playerid, DoorsInfo[0], 1);
 	PlayerTextDrawUseBox(playerid, DoorsInfo[0], 1);
 	PlayerTextDrawBoxColor(playerid, DoorsInfo[0], 85);
 	PlayerTextDrawTextSize(playerid, DoorsInfo[0], 0.000000, 178.000000);

 	DoorsInfo[1] = CreatePlayerTextDraw(playerid, 510.000000, 383.000000, "~p~Aby wejsc do budynku wcisnij~n~~w~~k~~SNEAK_ABOUT~ + ~k~~PED_SPRINT~");
 	PlayerTextDrawAlignment(playerid, DoorsInfo[1], 2);
 	PlayerTextDrawBackgroundColor(playerid, DoorsInfo[1], 255);
 	PlayerTextDrawFont(playerid, DoorsInfo[1], 2);
 	PlayerTextDrawLetterSize(playerid, DoorsInfo[1], 0.199999, 0.799998);
 	PlayerTextDrawColor(playerid, DoorsInfo[1], -1);
 	PlayerTextDrawSetOutline(playerid, DoorsInfo[1], 0);
 	PlayerTextDrawSetProportional(playerid, DoorsInfo[1], 1);
 	PlayerTextDrawSetShadow(playerid, DoorsInfo[1], 1);

 	DoorsInfo[2] = CreatePlayerTextDraw(playerid, 509.000000, 346.000000, "Los Santos Police Departament");
 	PlayerTextDrawAlignment(playerid, DoorsInfo[2], 2);
 	PlayerTextDrawBackgroundColor(playerid, DoorsInfo[2], 255);
 	PlayerTextDrawFont(playerid, DoorsInfo[2], 1);
 	PlayerTextDrawLetterSize(playerid, DoorsInfo[2], 0.219999, 1.100000);
 	PlayerTextDrawColor(playerid, DoorsInfo[2], -1);
 	PlayerTextDrawSetOutline(playerid, DoorsInfo[2], 0);
 	PlayerTextDrawSetProportional(playerid, DoorsInfo[2], 1);
 	PlayerTextDrawSetShadow(playerid, DoorsInfo[2], 1);

 	DoorsInfo[3] = CreatePlayerTextDraw(playerid, 509.000000, 360.000000, "~y~Wejscie: ~w~$10");
 	PlayerTextDrawBackgroundColor(playerid, DoorsInfo[3], 255);
	PlayerTextDrawAlignment(playerid, DoorsInfo[3], 2);
 	PlayerTextDrawFont(playerid, DoorsInfo[3], 1);
 	PlayerTextDrawLetterSize(playerid, DoorsInfo[3], 0.219999, 1.100000);
 	PlayerTextDrawColor(playerid, DoorsInfo[3], -1);
 	PlayerTextDrawSetOutline(playerid, DoorsInfo[3], 0);
 	PlayerTextDrawSetProportional(playerid, DoorsInfo[3], 1);
 	PlayerTextDrawSetShadow(playerid, DoorsInfo[3], 1);
 	
 	doorsLocked[0] = CreatePlayerTextDraw(playerid, 327.000000, 342.000000, " DRZWI ~r~ZAMKNIETE");
 	PlayerTextDrawAlignment(playerid, doorsLocked[0], 2);
 	PlayerTextDrawBackgroundColor(playerid, doorsLocked[0], 255);
 	PlayerTextDrawFont(playerid, doorsLocked[0], 1);
 	PlayerTextDrawLetterSize(playerid, doorsLocked[0], 0.399999, 1.399999);
 	PlayerTextDrawColor(playerid, doorsLocked[0], -572662273);
 	PlayerTextDrawSetOutline(playerid, doorsLocked[0], 0);
 	PlayerTextDrawSetProportional(playerid, doorsLocked[0], 1);
 	PlayerTextDrawSetShadow(playerid, doorsLocked[0], 1);
 	PlayerTextDrawUseBox(playerid, doorsLocked[0], 1);
 	PlayerTextDrawBoxColor(playerid, doorsLocked[0], 84);
 	PlayerTextDrawTextSize(playerid, doorsLocked[0], 366.000000, 88.000000);
 	
 	dutyBar[0] = CreatePlayerTextDraw(playerid, 513.000000, 107.000000, "~y~Sluzba");
 	PlayerTextDrawAlignment(playerid, dutyBar[0], 2);
 	PlayerTextDrawBackgroundColor(playerid, dutyBar[0], 255);
 	PlayerTextDrawFont(playerid, dutyBar[0], 1);
 	PlayerTextDrawLetterSize(playerid, dutyBar[0], 0.260000, 0.799999);
 	PlayerTextDrawColor(playerid, dutyBar[0], -65281);
 	PlayerTextDrawSetOutline(playerid, dutyBar[0], 0);
 	PlayerTextDrawSetProportional(playerid, dutyBar[0], 1);
 	PlayerTextDrawSetShadow(playerid, dutyBar[0], 1);

 	dutyBar[1] = CreatePlayerTextDraw(playerid, 513.000000, 100.000000, "14m 15s");
 	PlayerTextDrawAlignment(playerid, dutyBar[1], 2);
 	PlayerTextDrawBackgroundColor(playerid, dutyBar[1], 255);
 	PlayerTextDrawFont(playerid, dutyBar[1], 1);
 	PlayerTextDrawLetterSize(playerid, dutyBar[1], 0.179999, 0.799998);
 	PlayerTextDrawColor(playerid, dutyBar[1], -1);
 	PlayerTextDrawSetOutline(playerid, dutyBar[1], 0);
 	PlayerTextDrawSetProportional(playerid, dutyBar[1], 1);
 	PlayerTextDrawSetShadow(playerid, dutyBar[1], 1);
	
	objectInfoTd = CreatePlayerTextDraw(playerid, 520.000000, 251.000000, "~b~X: ~w~782.82812 ~n~~b~Y: ~w~1728.29812 ~n~~b~Z: ~w~17.28112 ~n~~b~RX: ~w~782.82812 ~n~~b~RY: ~w~1728.29812 ~b~RZ: ~w~17.28112");
	PlayerTextDrawBackgroundColor(playerid, objectInfoTd, 255);
	PlayerTextDrawFont(playerid, objectInfoTd, 1);
	PlayerTextDrawLetterSize(playerid, objectInfoTd, 0.320000, 0.899999);
	PlayerTextDrawColor(playerid, objectInfoTd, -1);
	PlayerTextDrawSetOutline(playerid, objectInfoTd, 1);
	PlayerTextDrawSetProportional(playerid, objectInfoTd, 1);
	PlayerTextDrawUseBox(playerid, objectInfoTd, 1);
	PlayerTextDrawBoxColor(playerid, objectInfoTd, 84);
	PlayerTextDrawTextSize(playerid, objectInfoTd, 635.000000, 0.000000);
	
	informationTd = CreatePlayerTextDraw(playerid, 433.000000, 272.000000, "~r~Vincent Dabrasco ~w~zaakceptowal Twoja oferte");
	PlayerTextDrawBackgroundColor(playerid, informationTd, 255);
	PlayerTextDrawFont(playerid, informationTd, 1);
	PlayerTextDrawLetterSize(playerid, informationTd, 0.200000, 0.699999);
	PlayerTextDrawColor(playerid, informationTd, -1);
	PlayerTextDrawSetOutline(playerid, informationTd, 0);
	PlayerTextDrawSetProportional(playerid, informationTd, 1);
	PlayerTextDrawSetShadow(playerid, informationTd, 1);
	PlayerTextDrawUseBox(playerid, informationTd, 1);
	PlayerTextDrawBoxColor(playerid, informationTd, 69);
	PlayerTextDrawTextSize(playerid, informationTd, 542.000000, 0.000000);
	
	afterDoorsInfo = CreatePlayerTextDraw(playerid, 410.000000, 260.000000, "W hotelu mozesz korzystac z komendy /pokoj. Aby sie zameldowac wpisz /pokoj zamelduj.");
	PlayerTextDrawBackgroundColor(playerid, afterDoorsInfo, 255);
	PlayerTextDrawFont(playerid, afterDoorsInfo, 1);
	PlayerTextDrawLetterSize(playerid, afterDoorsInfo, 0.250000, 0.899999);
	PlayerTextDrawColor(playerid, afterDoorsInfo, -1);
	PlayerTextDrawSetOutline(playerid, afterDoorsInfo, 0);
	PlayerTextDrawSetProportional(playerid, afterDoorsInfo, 1);
	PlayerTextDrawSetShadow(playerid, afterDoorsInfo, 1);
	PlayerTextDrawUseBox(playerid, afterDoorsInfo, 1);
	PlayerTextDrawBoxColor(playerid, afterDoorsInfo, 117);
	PlayerTextDrawTextSize(playerid, afterDoorsInfo, 570.000000, 60.000000);
	
	bwTime = CreatePlayerTextDraw(playerid, 440.000000, 320.000000, "do konca bw zostalo: ~g~9 ~w~min.");
	PlayerTextDrawAlignment(playerid, bwTime, 2);
	PlayerTextDrawBackgroundColor(playerid, bwTime, 255);
	PlayerTextDrawFont(playerid, bwTime, 3);
	PlayerTextDrawLetterSize(playerid, bwTime, 0.610000, 2.400000);
	PlayerTextDrawColor(playerid, bwTime, -1);
	PlayerTextDrawSetOutline(playerid, bwTime, 1);
	PlayerTextDrawSetProportional(playerid, bwTime, 1);

	ajTime = CreatePlayerTextDraw(playerid, 440.000000, 290.000000, "do konca aj zostalo ~r~9 ~w~min.");
	PlayerTextDrawAlignment(playerid, ajTime, 2);
	PlayerTextDrawBackgroundColor(playerid, ajTime, 255);
	PlayerTextDrawFont(playerid, ajTime, 3);
	PlayerTextDrawLetterSize(playerid, ajTime, 0.610000, 2.400000);
	PlayerTextDrawColor(playerid, ajTime, -1);
	PlayerTextDrawSetOutline(playerid, ajTime, 1);
	PlayerTextDrawSetProportional(playerid, ajTime, 1);

}

stock GenerateItemsListRows(playerid)
{
  new Float:baseHeight = 140.000000;
  new Float:lineHeight = 13.000000;
  new Float:rowHeight;
  for(new i=0;i<ITEMS_PER_PAGE;i++)
  {
	rowHeight = floatadd(baseHeight, floatmul(lineHeight, float(i)));
    itemsTd[i] = CreatePlayerTextDraw(playerid, 160.000000, rowHeight, " 1          Deagle (19, 24)");
    PlayerTextDrawBackgroundColor(playerid, itemsTd[i], 255);
    PlayerTextDrawFont(playerid, itemsTd[i], 1);
    PlayerTextDrawLetterSize(playerid, itemsTd[i], 0.179998, 0.899999);
    PlayerTextDrawColor(playerid, itemsTd[i], -1);
    PlayerTextDrawSetOutline(playerid, itemsTd[i], 1);
    PlayerTextDrawSetProportional(playerid, itemsTd[i], 1);
    PlayerTextDrawUseBox(playerid, itemsTd[i], 1);
    PlayerTextDrawBoxColor(playerid, itemsTd[i], 100);
    PlayerTextDrawTextSize(playerid, itemsTd[i], 502.000000, -189.000000);
    
    itemsActionTd[i][0] = CreatePlayerTextDraw(playerid, 395.000000, floatadd(rowHeight,1.5), "Informacje");
    PlayerTextDrawAlignment(playerid, itemsActionTd[i][0], 2);
    PlayerTextDrawBackgroundColor(playerid, itemsActionTd[i][0], 255);
    PlayerTextDrawFont(playerid, itemsActionTd[i][0], 1);
    PlayerTextDrawLetterSize(playerid, itemsActionTd[i][0], 0.189999, 0.599999);
    PlayerTextDrawColor(playerid, itemsActionTd[i][0], -1);
    PlayerTextDrawSetOutline(playerid, itemsActionTd[i][0], 1);
    PlayerTextDrawSetProportional(playerid, itemsActionTd[i][0], 1);
    PlayerTextDrawUseBox(playerid, itemsActionTd[i][0], 1);
    PlayerTextDrawBoxColor(playerid, itemsActionTd[i][0], 100);
    PlayerTextDrawTextSize(playerid, itemsActionTd[i][0], 9.000000, 39.000000);
    PlayerTextDrawSetSelectable(playerid, itemsActionTd[i][0], true);

    itemsActionTd[i][1] = CreatePlayerTextDraw(playerid, 488.000000, floatadd(rowHeight,1.5), "Odloz");
    PlayerTextDrawAlignment(playerid, itemsActionTd[i][1], 2);
    PlayerTextDrawBackgroundColor(playerid, itemsActionTd[i][1], 255);
    PlayerTextDrawFont(playerid, itemsActionTd[i][1], 1);
    PlayerTextDrawLetterSize(playerid, itemsActionTd[i][1], 0.189999, 0.599999);
    PlayerTextDrawColor(playerid, itemsActionTd[i][1], -1);
    PlayerTextDrawSetOutline(playerid, itemsActionTd[i][1], 1);
    PlayerTextDrawSetProportional(playerid, itemsActionTd[i][1], 1);
    PlayerTextDrawUseBox(playerid, itemsActionTd[i][1], 1);
    PlayerTextDrawBoxColor(playerid, itemsActionTd[i][1], 100);
    PlayerTextDrawTextSize(playerid, itemsActionTd[i][1], 9.000000, 23.000000);
    PlayerTextDrawSetSelectable(playerid, itemsActionTd[i][1], true);

    itemsActionTd[i][2] = CreatePlayerTextDraw(playerid, 433.000000, floatadd(rowHeight,1.5), "Oferuj");
    PlayerTextDrawAlignment(playerid, itemsActionTd[i][2], 2);
    PlayerTextDrawBackgroundColor(playerid, itemsActionTd[i][2], 255);
    PlayerTextDrawFont(playerid, itemsActionTd[i][2], 1);
    PlayerTextDrawLetterSize(playerid, itemsActionTd[i][2], 0.189999, 0.599999);
    PlayerTextDrawColor(playerid, itemsActionTd[i][2], -1);
    PlayerTextDrawSetOutline(playerid, itemsActionTd[i][2], 1);
    PlayerTextDrawSetProportional(playerid, itemsActionTd[i][2], 1);
    PlayerTextDrawUseBox(playerid, itemsActionTd[i][2], 1);
    PlayerTextDrawBoxColor(playerid, itemsActionTd[i][2], 100);
    PlayerTextDrawTextSize(playerid, itemsActionTd[i][2], 9.000000, 26.000000);
    PlayerTextDrawSetSelectable(playerid, itemsActionTd[i][2], true);

    itemsActionTd[i][3] = CreatePlayerTextDraw(playerid, 461.000000, floatadd(rowHeight,1.5), "Uzyj");
    PlayerTextDrawAlignment(playerid, itemsActionTd[i][3], 2);
    PlayerTextDrawBackgroundColor(playerid, itemsActionTd[i][3], 255);
    PlayerTextDrawFont(playerid, itemsActionTd[i][3], 1);
    PlayerTextDrawLetterSize(playerid, itemsActionTd[i][3], 0.189999, 0.599999);
    PlayerTextDrawColor(playerid, itemsActionTd[i][3], -1);
    PlayerTextDrawSetOutline(playerid, itemsActionTd[i][3], 1);
    PlayerTextDrawSetProportional(playerid, itemsActionTd[i][3], 1);
    PlayerTextDrawUseBox(playerid, itemsActionTd[i][3], 1);
    PlayerTextDrawBoxColor(playerid, itemsActionTd[i][3], 100);
    PlayerTextDrawTextSize(playerid, itemsActionTd[i][3], 9.000000, 19.000000);
    PlayerTextDrawSetSelectable(playerid, itemsActionTd[i][3], true);
  }
}

stock GenerateOffersTextDraws(playerid)
{
  offersTd[0] = CreatePlayerTextDraw(playerid, 235.000000, 269.000000, "~n~");
  PlayerTextDrawBackgroundColor(playerid, offersTd[0], 255);
  PlayerTextDrawFont(playerid, offersTd[0], 1);
  PlayerTextDrawLetterSize(playerid, offersTd[0], 0.500000, 6.500001);
  PlayerTextDrawColor(playerid, offersTd[0], -1);
  PlayerTextDrawSetOutline(playerid, offersTd[0], 0);
  PlayerTextDrawSetProportional(playerid, offersTd[0], 1);
  PlayerTextDrawSetShadow(playerid, offersTd[0], 1);
  PlayerTextDrawUseBox(playerid, offersTd[0], 1);
  PlayerTextDrawBoxColor(playerid, offersTd[0], 69);
  PlayerTextDrawTextSize(playerid, offersTd[0], 420.000000, 90.000000);

  offersTd[1] = CreatePlayerTextDraw(playerid, 237.000000, 270.000000, "Oferta od ~r~Vincent Dabrasco ~w~~>~ Zaproszenie");
  PlayerTextDrawBackgroundColor(playerid, offersTd[1], 255);
  PlayerTextDrawFont(playerid, offersTd[1], 2);
  PlayerTextDrawLetterSize(playerid, offersTd[1], 0.139999, 0.799999);
  PlayerTextDrawColor(playerid, offersTd[1], -1);
  PlayerTextDrawSetOutline(playerid, offersTd[1], 1);
  PlayerTextDrawSetProportional(playerid, offersTd[1], 1);

  offersTd[2] = CreatePlayerTextDraw(playerid, 240.000000, 282.000000, "~y~Przedmiot~n~~w~ Zaproszenie do Administracja (UID 1)");
  PlayerTextDrawBackgroundColor(playerid, offersTd[2], 255);
  PlayerTextDrawFont(playerid, offersTd[2], 1);
  PlayerTextDrawLetterSize(playerid, offersTd[2], 0.190000, 0.699999);
  PlayerTextDrawColor(playerid, offersTd[2], -1);
  PlayerTextDrawSetOutline(playerid, offersTd[2], 1);
  PlayerTextDrawSetProportional(playerid, offersTd[2], 1);

  offersTd[3] = CreatePlayerTextDraw(playerid, 240.000000, 297.000000, "~y~Cena~n~~w~ $100");
  PlayerTextDrawBackgroundColor(playerid, offersTd[3], 255);
  PlayerTextDrawFont(playerid, offersTd[3], 1);
  PlayerTextDrawLetterSize(playerid, offersTd[3], 0.190000, 0.699999);
  PlayerTextDrawColor(playerid, offersTd[3], -1);
  PlayerTextDrawSetOutline(playerid, offersTd[3], 1);
  PlayerTextDrawSetProportional(playerid, offersTd[3], 1);

  offersTd[4] = CreatePlayerTextDraw(playerid, 362.000000, 318.000000, "Akceptuj");
  PlayerTextDrawAlignment(playerid, offersTd[4], 1);
  PlayerTextDrawBackgroundColor(playerid, offersTd[4], 255);
  PlayerTextDrawFont(playerid, offersTd[4], 2);
  PlayerTextDrawLetterSize(playerid, offersTd[4], 0.120000, 0.599999);
  PlayerTextDrawColor(playerid, offersTd[4], -1);
  PlayerTextDrawSetOutline(playerid, offersTd[4], 1);
  PlayerTextDrawSetProportional(playerid, offersTd[4], 1);
  PlayerTextDrawUseBox(playerid, offersTd[4], 1);
  PlayerTextDrawBoxColor(playerid, offersTd[4], 69);
  PlayerTextDrawTextSize(playerid, offersTd[4], 362.0 + 25.0, 8.0);
  PlayerTextDrawSetSelectable(playerid, offersTd[4], 1);

  offersTd[5] = CreatePlayerTextDraw(playerid, 397.000000, 318.000000, "Odrzuc");
  PlayerTextDrawAlignment(playerid, offersTd[5], 1);
  PlayerTextDrawBackgroundColor(playerid, offersTd[5], 255);
  PlayerTextDrawFont(playerid, offersTd[5], 2);
  PlayerTextDrawLetterSize(playerid, offersTd[5], 0.120000, 0.599999);
  PlayerTextDrawColor(playerid, offersTd[5], -1);
  PlayerTextDrawSetOutline(playerid, offersTd[5], 1);
  PlayerTextDrawSetProportional(playerid, offersTd[5], 1);
  PlayerTextDrawUseBox(playerid, offersTd[5], 1);
  PlayerTextDrawBoxColor(playerid, offersTd[5], 69);
  PlayerTextDrawTextSize(playerid, offersTd[5], 397.0 + 19.0, 8.0);
  PlayerTextDrawSetSelectable(playerid, offersTd[5], 1);
}

stock GeneratePhoneTextDraws(playerid)
{
  phoneBarUpper[0] = CreatePlayerTextDraw(playerid, 518.000000, 138.000000, "     Polaczenie przychodzace");
  PlayerTextDrawBackgroundColor(playerid, phoneBarUpper[0], 255);
  PlayerTextDrawFont(playerid, phoneBarUpper[0], 1);
  PlayerTextDrawLetterSize(playerid, phoneBarUpper[0], 0.230000, 0.699998);
  PlayerTextDrawColor(playerid, phoneBarUpper[0], -1);
  PlayerTextDrawSetOutline(playerid, phoneBarUpper[0], 1);
  PlayerTextDrawSetProportional(playerid, phoneBarUpper[0], 1);
  PlayerTextDrawUseBox(playerid, phoneBarUpper[0], 1);
  PlayerTextDrawBoxColor(playerid, phoneBarUpper[0], 84);
  PlayerTextDrawTextSize(playerid, phoneBarUpper[0], 651.000000, 10.000000);

  phoneBarUpper[1] = CreatePlayerTextDraw(playerid, 517.000000, 136.500000, "LD_BEAT:circle");
  PlayerTextDrawBackgroundColor(playerid, phoneBarUpper[1], 255);
  PlayerTextDrawFont(playerid, phoneBarUpper[1], 4);
  PlayerTextDrawLetterSize(playerid, phoneBarUpper[1], 0.500000, 1.000000);
  PlayerTextDrawColor(playerid, phoneBarUpper[1], 12517631);
  PlayerTextDrawSetOutline(playerid, phoneBarUpper[1], 0);
  PlayerTextDrawSetProportional(playerid, phoneBarUpper[1], 1);
  PlayerTextDrawSetShadow(playerid, phoneBarUpper[1], 1);
  PlayerTextDrawUseBox(playerid, phoneBarUpper[1], 1);
  PlayerTextDrawBoxColor(playerid, phoneBarUpper[1], 255);
  PlayerTextDrawTextSize(playerid, phoneBarUpper[1], 8.000000, 9.000000);
  PlayerTextDrawSetSelectable(playerid, phoneBarUpper[1], 1);

  phoneBarUpper[2] = CreatePlayerTextDraw(playerid, 526.000000, 136.500000, "LD_BEAT:circle");
  PlayerTextDrawBackgroundColor(playerid, phoneBarUpper[2], 255);
  PlayerTextDrawFont(playerid, phoneBarUpper[2], 4);
  PlayerTextDrawLetterSize(playerid, phoneBarUpper[2], 0.500000, 1.000000);
  PlayerTextDrawColor(playerid, phoneBarUpper[2], -16776961);
  PlayerTextDrawSetOutline(playerid, phoneBarUpper[2], 0);
  PlayerTextDrawSetProportional(playerid, phoneBarUpper[2], 1);
  PlayerTextDrawSetShadow(playerid, phoneBarUpper[2], 1);
  PlayerTextDrawUseBox(playerid, phoneBarUpper[2], 1);
  PlayerTextDrawBoxColor(playerid, phoneBarUpper[2], 255);
  PlayerTextDrawTextSize(playerid, phoneBarUpper[2], 8.000000, 9.000000);
  PlayerTextDrawSetSelectable(playerid, phoneBarUpper[2], 1);

  phoneBarUpper[3] = CreatePlayerTextDraw(playerid, 553.000000, 147.500000, "M.Wallace");
  PlayerTextDrawAlignment(playerid, phoneBarUpper[3], 2);
  PlayerTextDrawBackgroundColor(playerid, phoneBarUpper[3], 255);
  PlayerTextDrawFont(playerid, phoneBarUpper[3], 1);
  PlayerTextDrawLetterSize(playerid, phoneBarUpper[3], 0.170000, 0.599999);
  PlayerTextDrawColor(playerid, phoneBarUpper[3], -1);
  PlayerTextDrawSetOutline(playerid, phoneBarUpper[3], 1);
  PlayerTextDrawSetProportional(playerid, phoneBarUpper[3], 1);
  
  phoneBarUpper[4] = CreatePlayerTextDraw(playerid, 524.000000, 161.000000, "  Masz nowa wiadomosc");
  PlayerTextDrawBackgroundColor(playerid, phoneBarUpper[4], 255);
  PlayerTextDrawFont(playerid, phoneBarUpper[4], 1);
  PlayerTextDrawLetterSize(playerid, phoneBarUpper[4], 0.230000, 0.699998);
  PlayerTextDrawColor(playerid, phoneBarUpper[4], -1);
  PlayerTextDrawSetOutline(playerid, phoneBarUpper[4], 1);
  PlayerTextDrawSetProportional(playerid, phoneBarUpper[4], 1);
  PlayerTextDrawUseBox(playerid, phoneBarUpper[4], 1);
  PlayerTextDrawBoxColor(playerid, phoneBarUpper[4], 84);
  PlayerTextDrawTextSize(playerid, phoneBarUpper[4], 651.000000, 10.000000);
  PlayerTextDrawSetSelectable(playerid, phoneBarUpper[4], 1);
}

stock SpecTextdraw(playerid, targetid)
{
        new string[128];
       
        format(string, sizeof(string), "Gracz: %s", pInfo[targetid][name]);
        pInfo[playerid][spec_td_player] = TextDrawCreate(523.000000, 311.000000, string);
        TextDrawBackgroundColor(pInfo[playerid][spec_td_player], 255);
        TextDrawFont(pInfo[playerid][spec_td_player], 1);
        TextDrawLetterSize(pInfo[playerid][spec_td_player], 0.270000, 1.500000);
        TextDrawColor(pInfo[playerid][spec_td_player], -1);
        TextDrawSetOutline(pInfo[playerid][spec_td_player], 1);
        TextDrawSetProportional(pInfo[playerid][spec_td_player], 1);
 
        format(string, sizeof(string), "ID: %d", targetid);
        pInfo[playerid][spec_td_id] = TextDrawCreate(523.000000, 325.000000, string);
        TextDrawBackgroundColor(pInfo[playerid][spec_td_id], 255);
        TextDrawFont(pInfo[playerid][spec_td_id], 1);
        TextDrawLetterSize(pInfo[playerid][spec_td_id], 0.350000, 1.000000);
        TextDrawColor(pInfo[playerid][spec_td_id], -1);
        TextDrawSetOutline(pInfo[playerid][spec_td_id], 1);
        TextDrawSetProportional(pInfo[playerid][spec_td_id], 1);
 
        format(string, sizeof(string), "HP: %.1f", pInfo[playerid][health]);
        pInfo[playerid][spec_td_hp] = TextDrawCreate(523.000000, 335.000000, string);
        TextDrawBackgroundColor(pInfo[playerid][spec_td_hp], 255);
        TextDrawFont(pInfo[playerid][spec_td_hp], 1);
        TextDrawLetterSize(pInfo[playerid][spec_td_hp], 0.340000, 1.000000);
        TextDrawColor(pInfo[playerid][spec_td_hp], -1);
        TextDrawSetOutline(pInfo[playerid][spec_td_hp], 1);
        TextDrawSetProportional(pInfo[playerid][spec_td_hp], 1);
 
        format(string, sizeof(string), "Pancerz: %.1f", pInfo[playerid][armor]);
        pInfo[playerid][spec_td_armor] = TextDrawCreate(524.000000, 345.000000, string);
        TextDrawBackgroundColor(pInfo[playerid][spec_td_armor], 255);
        TextDrawFont(pInfo[playerid][spec_td_armor], 1);
        TextDrawLetterSize(pInfo[playerid][spec_td_armor], 0.320000, 1.000000);
        TextDrawColor(pInfo[playerid][spec_td_armor], -1);
        TextDrawSetOutline(pInfo[playerid][spec_td_armor], 1);
        TextDrawSetProportional(pInfo[playerid][spec_td_armor], 1);
       
        TextDrawShowForPlayer(playerid, pInfo[playerid][spec_td_player]);
        TextDrawShowForPlayer(playerid, pInfo[playerid][spec_td_id]);
        TextDrawShowForPlayer(playerid, pInfo[playerid][spec_td_hp]);
        TextDrawShowForPlayer(playerid, pInfo[playerid][spec_td_armor]);
}

stock PenaltyTextdraw(playerid, targetid, reason[], header[])
{
        new string[128];
       
        PenaltyTextDraw[0] = TextDrawCreate(9.000000, 255.000000, header);
        TextDrawBackgroundColor(PenaltyTextDraw[0], 255);
        TextDrawFont(PenaltyTextDraw[0], 1);
        TextDrawLetterSize(PenaltyTextDraw[0], 0.220000, 1.000000);
        TextDrawColor(PenaltyTextDraw[0], -1659824897);
        TextDrawSetOutline(PenaltyTextDraw[0], 1);
        TextDrawSetProportional(PenaltyTextDraw[0], 1);
 
        format(string, sizeof(string), "%s", BeautyString(reason, 1, 1));
        PenaltyTextDraw[1] = TextDrawCreate(9.000000, 284.000000, string);
        TextDrawBackgroundColor(PenaltyTextDraw[1], 255);
        TextDrawFont(PenaltyTextDraw[1], 1);
        TextDrawLetterSize(PenaltyTextDraw[1], 0.220000, 1.000000);
        TextDrawColor(PenaltyTextDraw[1], -1280219137);
        TextDrawSetOutline(PenaltyTextDraw[1], 1);
        TextDrawSetProportional(PenaltyTextDraw[1], 1);
 
        format(string, sizeof(string), "Gracz:     %s", pInfo[targetid][name]);
        PenaltyTextDraw[2] = TextDrawCreate(9.000000, 264.000000, string);
        TextDrawBackgroundColor(PenaltyTextDraw[2], 255);
        TextDrawFont(PenaltyTextDraw[2], 1);
        TextDrawLetterSize(PenaltyTextDraw[2], 0.220000, 1.000000);
        TextDrawColor(PenaltyTextDraw[2], -1128481537);
        TextDrawSetOutline(PenaltyTextDraw[2], 1);
        TextDrawSetProportional(PenaltyTextDraw[2], 1);
 
        format(string, sizeof(string), "Nadajacy:  %s", pInfo[playerid][name]);
        PenaltyTextDraw[3] = TextDrawCreate(9.000000, 274.000000, string);
        TextDrawBackgroundColor(PenaltyTextDraw[3], 255);
        TextDrawFont(PenaltyTextDraw[3], 1);
        TextDrawLetterSize(PenaltyTextDraw[3], 0.220000, 1.000000);
        TextDrawColor(PenaltyTextDraw[3], -1128481537);
        TextDrawSetOutline(PenaltyTextDraw[3], 1);
        TextDrawSetProportional(PenaltyTextDraw[3], 1);
       
        foreach(Player, i)
        {
                TextDrawShowForPlayer(i, PenaltyTextDraw[0]);
                TextDrawShowForPlayer(i, PenaltyTextDraw[1]);
                TextDrawShowForPlayer(i, PenaltyTextDraw[2]);
                TextDrawShowForPlayer(i, PenaltyTextDraw[3]);
        }
        defer HidePenaltyBar[5000]();
}