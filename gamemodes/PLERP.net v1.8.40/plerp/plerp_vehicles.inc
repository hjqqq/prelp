// -- Vehicles names -- //
new VehicleNames[212][] = {
   "Landstalker",  "Bravura",  "Buffalo", "Linerunner", "Perennial", "Sentinel",
   "Dumper",  "Firetruck" ,  "Trashmaster" ,  "Stretch",  "Manana",  "Infernus",
   "Voodoo", "Pony",  "Mule", "Cheetah", "Ambulance",  "Leviathan",  "Moonbeam",
   "Esperanto", "Taxi",  "Washington",  "Bobcat",  "Mr Whoopee", "BF Injection",
   "Hunter", "Premier",  "Enforcer",  "Securicar", "Banshee", "Predator", "Bus",
   "Rhino",  "Barracks",  "Hotknife",  "Trailer",  "Previon", "Coach", "Cabbie",
   "Stallion", "Rumpo", "RC Bandit",  "Romero", "Packer", "Monster",  "Admiral",
   "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer",  "Turismo", "Speeder",
   "Reefer", "Tropic", "Flatbed","Yankee", "Caddy", "Solair","Berkley's RC Van",
   "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron","RC Raider","Glendale",
   "Oceanic", "Sanchez", "Sparrow",  "Patriot", "Quad",  "Coastguard", "Dinghy",
   "Hermes", "Sabre", "Rustler", "ZR-350", "Walton",  "Regina",  "Comet", "BMX",
   "Burrito", "Camper", "Marquis", "Baggage", "Dozer","Maverick","News Chopper",
   "Rancher", "FBI Rancher", "Virgo", "Greenwood","Jetmax","Hotring","Sandking",
   "Blista Compact", "Police Maverick", "Boxville", "Benson","Mesa","RC Goblin",
   "Hotring Racer", "Hotring Racer", "Bloodring Banger", "Rancher",  "Super GT",
   "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropdust", "Stunt",
   "Tanker", "RoadTrain", "Nebula", "Majestic", "Buccaneer", "Shamal",  "Hydra",
   "FCR-900","NRG-500","HPV1000","Cement Truck","Tow Truck","Fortune","Cadrona",
   "FBI Truck", "Willard", "Forklift","Tractor","Combine","Feltzer","Remington",
   "Slamvan", "Blade", "Freight", "Streak","Vortex","Vincent","Bullet","Clover",
   "Sadler",  "Firetruck", "Hustler", "Intruder", "Primo", "Cargobob",  "Tampa",
   "Sunrise", "Merit",  "Utility Truck",  "Nevada", "Yosemite", "Windsor",  "Monster",
   "Monster","Uranus","Jester","Sultan","Stratum","Elegy","Raindance","RCTiger",
   "Flash","Tahoma","Savanna", "Bandito", "Freight", "Trailer", "Kart", "Mower",
   "Dune", "Sweeper", "Broadway", "Tornado", "AT-400",  "DFT-30", "Huntley",
   "Stafford", "BF-400", "Newsvan","Tug","Trailer","Emperor","Wayfarer","Euros",
   "Hotdog", "Club", "Trailer", "Trailer","Andromada","Dodo","RC Cam", "Launch",
   "Police Car (LSPD)", "Police Car (SFPD)","Police Car (LVPD)","Police Ranger",
   "Picador",   "S.W.A.T. Van",  "Alpha",   "Phoenix",   "Glendale",   "Sadler",
   "Luggage Trailer","Luggage Trailer","Stair Trailer", "Boxville", "Farm Plow",
   "Utility Trailer"
};

new Float: VehicleBaseFuelUsage[212] = {
   4.0,  1.8,  3.4, 9.0, 2.0, 1.8,
   12.0,  9.0 ,  8.0 ,  2.5,  1.4,  3.8,
   2.6, 2.8,  3.5, 3.6, 3.2,  10.0,  2.8,
   1.8, 1.8,  2.0,  1.8,  2.5, 2.4,
   15.0, 1.8,  5.0,  4.5, 3.4, 5.0, 7.0,
   20.0,  5.5,  3.4,  0.0,  1.4, 7.0, 1.8,
   1.6, 2.4, 0.0,  1.8, 7.0, 6.5,  1.6,
   5.0, 9.0, 0.3, 0.0, 0.0, 3.6, 6.0,
   6.5, 6.5, 6.5, 4.5, 0.6, 1.6, 2.6,
   5.5, 1.2, 0.4, 1.2, 0.0, 0.0, 1.6,
   1.6, 1.3, 5.5, 4.0, 0.8,  5.5, 4.5,
   1.8, 2.4, 6.7, 2.8, 1.6,  1.6,  2.2, 0.0,
   2.8, 2.8, 4.6, 1.0, 6.0, 6.0, 6.0,
   5.5, 5.5, 1.8, 1.6, 6.0, 5.0, 7.0,
   1.6, 6.5, 2.8, 2.8, 1.6, 0.0,
   5.0, 5.0, 3.0, 3.0, 3.6,
   1.8, 3.5, 0.0, 0.0, 6.8, 5.8, 5.5,
   9.0, 8.5, 1.8, 1.8, 2.4, 15.0, 30.0,
   1.4, 1.8, 1.4, 10.0, 3.5, 1.6, 1.4,
   3.5, 1.6, 0.8, 0.8, 4.5, 1.6, 1.8,
   2.4, 1.6, 0.0, 0.0, 1.4, 1.6, 4.0, 2.2,
   1.8, 7.5, 1.8, 1.6, 1.6, 14.0, 2.2,
   1.8, 1.8, 2.8, 20.0, 2.2, 1.4, 7.0,
   7.0, 1.8, 2.4, 2.4, 2.4, 2.4, 11.0, 0.0,
   2.4, 1.8, 1.8, 1.2, 0.0, 0.0, 0.2, 0.8,
   7.0, 0.8, 1.8, 1.8, 18.0, 7.5, 4.2,
   1.8, 1.4, 2.2, 0.4, 0.0, 1.8, 1.4, 2.4,
   2.8, 2.0, 0.0, 0.0, 40.0, 9.0, 0.0, 8.0,
   2.2, 2.2, 2.2, 4.4,
   1.8, 6.0, 1.8, 2.2, 1.6, 1.6,
   0.0, 0.0, 0.0, 4.6, 0.0,
   0.0
};

// --------------------- //
// -- FUEL MANAGEMENT -- //
// --------------------- //
stock Float: GetVehicleCurrentFuel(vehicleid)
{
   new fuelD[128], 
	   Float: b;
	   
   format(fuelD, sizeof(fuelD), "%s", sVehInfo[vehicleid][activeFuel]);
   format(fuelD, sizeof(fuelD), "%s", str_replace("{", "", str_replace("}", "", fuelD)));
   sscanf(fuelD, "p<,>{s[64]}f{f}", b);

   return b;
}

stock Float: GetVehicleMaxFuel(vehicleid)
{
   new fuelD[128],
       Float: c;
	   
   format(fuelD, sizeof(fuelD), "%s", sVehInfo[vehicleid][activeFuel]);
   format(fuelD, sizeof(fuelD), "%s", str_replace("{", "", str_replace("}", "", fuelD)));
   sscanf(fuelD, "p<,>{s[64]}{f}f", c);

   return c;
}

stock GetVehicleFuelType(vehicleid)
{
   new fuelD[128],
       a[64];
	   
   format(fuelD, sizeof(fuelD), "%s", sVehInfo[vehicleid][activeFuel]);
   format(fuelD, sizeof(fuelD), "%s", str_replace("{", "", str_replace("}", "", fuelD)));
   sscanf(fuelD, "p<,>s[64]{f}{f}", a);

   return a;
}

stock SetVehicleCurrentFuel(vehicleid, Float:value)
{
   format(sVehInfo[vehicleid][activeFuel], 64, "{%s,%f,%f}", GetVehicleFuelType(vehicleid), value, GetVehicleMaxFuel(vehicleid));
}

stock UpdateVehicleFuelForPlayer(playerid)
{
  new vehicleid = GetPlayerVehicleID(playerid);

  new Float: fuel = GetVehicleCurrentFuel(vehicleid);
  new Float: maxfuel = GetVehicleMaxFuel(vehicleid);
  new Float: fuelperc = floatdiv(fuel,maxfuel);
	  
  PlayerTextDrawLetterSize(playerid, carFuel[2], 0.500000, floatadd(-0.2999, floatmul(FUEL_TD_HEIGHT,fuelperc)));
  TextDrawUpdateForPlayer(playerid, Text:INVALID_TEXT_DRAW, carFuel[2]);
  
  new fuelString[2][64];
  format(fuelString[1], 64, "%.0f%", floatmul(fuelperc,100.0));
  format(fuelString[0], 64, "%.2fl", fuel);

  PlayerTextDrawSetString(playerid, carFuel[4], fuelString[1]);
  TextDrawUpdateForPlayer(playerid, Text:INVALID_TEXT_DRAW, carFuel[4]);

  PlayerTextDrawSetString(playerid, carFuel[3], fuelString[0]);
  TextDrawUpdateForPlayer(playerid, Text:INVALID_TEXT_DRAW, carFuel[3]);

}

stock UpdateFuelConsume(vehicleid, Float:distance)
{
  new Float: BaseFuelConsumePerOneM,
      Float:currentFuel,
	  Float:usedFuel,
	  fuelType[64];

  BaseFuelConsumePerOneM = floatdiv(VehicleBaseFuelUsage[GetVehicleModel(vehicleid)-400], 1000.0);

  currentFuel = GetVehicleCurrentFuel(vehicleid);
  fuelType = GetVehicleFuelType(vehicleid);
  if( distance > 0 )
  {
	distance = floatmul(distance, 0.7);
    usedFuel = floatmul(distance, BaseFuelConsumePerOneM);
  }
  else {
	usedFuel = floatmul(CAR_PASSIVE_USAGE_MULTIPLY, BaseFuelConsumePerOneM);
  }
  // -- Fixing proper usage -- //
  usedFuel = floatmul(usedFuel, 0.25);
  // -- Fuel type effect -- //
  new Float:fuelTypeMultiplier;
  if( !strcmp(fuelType, "Benzyna") ){ fuelTypeMultiplier = FUEL_BENZYNA_USAGE; }
  if( !strcmp(fuelType, "Gaz") )    { fuelTypeMultiplier = FUEL_GAZ_USAGE;     }
  if( !strcmp(fuelType, "Diesel") ) { fuelTypeMultiplier = FUEL_DIESEL_USAGE;  }

  usedFuel = floatmul(usedFuel, fuelTypeMultiplier);
  // -- Car mileage effect -- //
  new Float:mileagePointer;
  mileagePointer = floatmul(floatdiv(sVehInfo[vehicleid][mileage], 1000000.0), 0.4);
  usedFuel = floatadd(usedFuel, floatmul(usedFuel, mileagePointer));
  // ------------------------ //
  if( floatsub(currentFuel, usedFuel) <= 0.0 )
  {
	new driver = GetVehicleDriver(vehicleid);
    SetVehicleCurrentFuel(vehicleid, 0.0);
	sVehInfo[vehicleid][engine] = false;
	PlayerTextDrawShow(driver, carBarHud);
    UpdateVehicle(vehicleid);
    ShowPlayerDialog(driver, 3, DIALOG_STYLE_MSGBOX, BuildGuiCaption("B³¹d - Pojazdy"), "Brak paliwa w pojeŸdzie! Pomyœl o zakupieniu kanistra lub zadzwoñ do warsztatu samochodowego.", "Zamknij", "");
	return;
  }
  SetVehicleCurrentFuel(vehicleid, floatsub(currentFuel, usedFuel));
}
// ---------------------- //

stock SaveVehicle(vehicleid)
{
  String->Format("Zapisywanie pojazdu o uid %d", sVehInfo[vehicleid][uid]);
  Crp->Notify("pojazdy", formatted);
  GetVehicleHealth(vehicleid, sVehInfo[vehicleid][health]);
  GetVehicleDamageStatus(vehicleid, sVehInfo[vehicleid][vDamagePanels], sVehInfo[vehicleid][vDamageDoors], sVehInfo[vehicleid][vDamageLights], sVehInfo[vehicleid][vDamageTires]);
  if( sVehInfo[vehicleid][destroyed] == 1 ) sVehInfo[vehicleid][health] = 0.0;

  new Query[456], Query2[256], formattedFuel[150], formattedVisualDamage[80];
  format(formattedFuel, sizeof(formattedFuel), "%s", sVehInfo[vehicleid][activeFuel]);
  format(formattedVisualDamage, 80, "%d:%d:%d:%d", sVehInfo[vehicleid][vDamagePanels], sVehInfo[vehicleid][vDamageDoors], sVehInfo[vehicleid][vDamageLights], sVehInfo[vehicleid][vDamageTires]);

  format( Query, sizeof(Query), "UPDATE `vehicles` SET `col1`='%d', `col2`='%d', `mileage`='%f', `health`='%f', `x`='%f', `y`='%f', `z`='%f',", sVehInfo[vehicleid][col1], sVehInfo[vehicleid][col2], sVehInfo[vehicleid][mileage], sVehInfo[vehicleid][health], sVehInfo[vehicleid][pX], sVehInfo[vehicleid][pY], sVehInfo[vehicleid][pZ]);
  format( Query2, sizeof(Query2), " `a`='%f', `fuel`='%s', `visual_damage`='%s', `radioStation`='%s' WHERE `uid`='%d'", sVehInfo[vehicleid][pA], formattedFuel, formattedVisualDamage, sVehInfo[vehicleid][radioStation], sVehInfo[vehicleid][uid]);
  strcat( Query, Query2 );

  mysql_function_query(mysqlHandle, Query, false, "", "");
}

public GetSpawnedVehicleIdByUid(vehuid)
{
   foreach (new v : Vehicles)
   {
	 if( sVehInfo[v][uid] == vehuid )
	 {
		return v;
	 }
   }
   return 0;
}

public IsVehicleEmpty(vehicleid)
{
   foreach (new p : Player)
   {
      if( IsPlayerInVehicle(p, vehicleid) )
      {
	     return false;
      }
   }
   return true;
}

stock GetVehicleDriver(vehicleid)
{
   foreach (new p : Player)
   {
      if( IsPlayerInVehicle(p, vehicleid) && GetPlayerVehicleSeat(p) == 0 )
      {
	     return p;
      }
   }
   return INVALID_PLAYER_ID;
}

stock GetVehicleSpeed(playerid)
{
   new Float:x,Float:y,Float:z,vehicleid, Float:kmph;
   vehicleid = GetPlayerVehicleID(playerid);
   GetVehicleVelocity(vehicleid,x,y,z);
   kmph = floatsqroot((x*x)+(y*y)+(z*z))*198;
   return floatround(kmph);
}

stock GetVehicleIdByUid(vUid)
{
   foreach (new veh : Vehicles)
   {
	  if( sVehInfo[veh][uid] == vUid ) return veh;
   }
   return -1;
}

stock FindClosestVehicle(playerid)
{
    new
        Float:x, Float:y, Float:z,
        closest = -1,
		Float:lastDistance = MAX_CAR_LOCK_DIST,
		Float:currentDistance;

    foreach (new v : Vehicles)
    {
        GetVehiclePos(v, x, y, z);
		currentDistance = GetPlayerDistanceFromPoint(playerid, x, y, z);
        if(sVehInfo[v][owner] == pInfo[playerid][uid] && currentDistance <= MAX_CAR_LOCK_DIST && currentDistance <= lastDistance)
        {
		   lastDistance = currentDistance;
		   closest = v;
        }
    }
    if(closest != -1) return closest;

    return INVALID_VEHICLE_ID;
}

stock UpdateVehicle(vehicleid, update_radio=false)
{
  if( update_radio )
  {
	foreach (new p : Player)
	{
	   if( IsPlayerInVehicle(p, vehicleid) )
	   {
		 if( sVehInfo[vehicleid][radioState] )
		 {
           Audio_Stop(p, pInfo[p][carAudio]);
           pInfo[p][carAudio] = Audio_PlayStreamed(p, sVehInfo[vehicleid][radioStation]);
		 }
		 else
		 {
           Audio_Stop(p, pInfo[p][carAudio]);
		 }
	   }
	}
  }
  SetVehicleParamsEx(vehicleid, sVehInfo[vehicleid][engine], sVehInfo[vehicleid][lights], sVehInfo[vehicleid][alarm], 0, sVehInfo[vehicleid][bonnet], sVehInfo[vehicleid][boot], sVehInfo[vehicleid][objective]);
  UpdateVehicleDamageStatus(vehicleid, sVehInfo[vehicleid][vDamagePanels], sVehInfo[vehicleid][vDamageDoors], sVehInfo[vehicleid][vDamageLights], sVehInfo[vehicleid][vDamageTires]);
}

public VehiclePark(playerid)
{
   new rows, fields;
   cache_get_data( rows, fields, mysqlHandle);

   if( rows > 0 )
   {
	 ShowPlayerDialog(playerid, 3, DIALOG_STYLE_MSGBOX, BuildGuiCaption("B³¹d - Pojazdy"), "W tym miejscu zaparkowany jest ju¿ inny pojazd!", "Zamknij", "");
	 return 0;
   }

   new vehid;
   vehid = GetPlayerVehicleID(playerid);
   GetVehiclePos(vehid, sVehInfo[vehid][pX], sVehInfo[vehid][pY], sVehInfo[vehid][pZ]);
   GetVehicleZAngle(vehid, sVehInfo[vehid][pA]);

   ShowPlayerDialog(playerid, 3, DIALOG_STYLE_MSGBOX, BuildGuiCaption("Informacja - Pojazdy"), "Pojazd zosta³ zaparkowany pomyœlnie, zaleca siê jego respawn w celu unikniêcia straty dokonanych zmian!", "Zamknij", "");

   return 1;
}

public VehiclesListQuery(playerid)
{
   new rows, fields;
   cache_get_data( rows, fields, mysqlHandle);
   if( rows > 0 )
   {
	  new vmodel[32],vuid[32],spcapt[64],vlist[326];
	  for (new i = 0; i != rows; ++i)
      {
		 spcapt = "";
         cache_get_field_content(i, "model", vmodel);
         cache_get_field_content(i, "uid", vuid);
         if( GetSpawnedVehicleIdByUid(strval(vuid)) > 0 )
         {
		   format(spcapt, sizeof(spcapt), "%s", "{008000}");
         }
		 format(vlist, sizeof(vlist), "%s%s%d.\t%s (UID:%d)\n", vlist, spcapt, i+1, VehicleNames[strval(vmodel)-400], strval(vuid));
      }
	  ShowPlayerDialog(playerid, 2, DIALOG_STYLE_LIST, BuildGuiCaption("Twoje pojazdy"), vlist, "(un)spawn", "Zamknij");
   }
   else
   {
      PlayerTextDrawShow(playerid, NoCars);
      defer HidePlayerTextDraw[1500](playerid, NoCars);
   }
   return 1;
}

stock encode_lights(light1, light2, light3, light4) {
    return light1 | (light2 << 1) | (light3 << 2) | (light4 << 3);
}
public VehicleSpawnQuery(playerid, listpos)
{
   new rows, fields, vuid[32], vmodel[32], vowner[32], vcol1[32], vcol2[32], Float:vmileage, vmileaget[32], vhealth[32], vposx[32], vposy[32], vposz[32], vposa[32], vfuel[150], vVisualDmg[80], vComponents[200], vComponentsList[14], vehicd, vRadio[2], vRadioStation[120], vPlates[8];
   cache_get_data(rows, fields, mysqlHandle);
   cache_get_field_content(listpos, "uid", vuid);
   cache_get_field_content(listpos, "model", vmodel);
   cache_get_field_content(listpos, "owner", vowner);
   cache_get_field_content(listpos, "col1", vcol1);
   cache_get_field_content(listpos, "col2", vcol2);
   cache_get_field_content(listpos, "mileage", vmileaget); vmileage = floatstr(vmileaget);
   cache_get_field_content(listpos, "plates", vPlates);
   cache_get_field_content(listpos, "health", vhealth);
   cache_get_field_content(listpos, "x", vposx);
   cache_get_field_content(listpos, "y", vposy);
   cache_get_field_content(listpos, "z", vposz);
   cache_get_field_content(listpos, "a", vposa);
   cache_get_field_content(listpos, "fuel", vfuel);
   cache_get_field_content(listpos, "visual_damage", vVisualDmg);
   cache_get_field_content(listpos, "components", vComponents);
   cache_get_field_content(listpos, "radio", vRadio);
   cache_get_field_content(listpos, "radioStation", vRadioStation);
   vehicd = GetSpawnedVehicleIdByUid(strval(vuid));
   if( vehicd > 0 )
   {
	 if( sVehInfo[vehicd][carActionInProgress] )
	 {
      ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("B³¹d - Pojazdy"), "Nie mo¿esz odspawnowaæ swojego pojazdu, poniewa¿ aktualnie jest w akcji.", "Zamknij", "");
	  return 1;
	 }
	 if( !IsVehicleEmpty(vehicd) ){ ShowPlayerDialog(playerid, 3, DIALOG_STYLE_MSGBOX, BuildGuiCaption("B³¹d - Pojazdy"), "Nie mo¿esz odspawnowaæ swojego pojazdu, poniewa¿ ktoœ siê w nim znajduje", "Zamknij", ""); return 1; }
     if( sVehInfo[vehicd][health] <= 250 && sVehInfo[vehicd][health] > 0 ){ ShowPlayerDialog(playerid, 3, DIALOG_STYLE_MSGBOX, BuildGuiCaption("B³¹d - Pojazdy"), "Nie mo¿esz odspawnowaæ swojego pojazdu, poniewa¿ zaraz wybuchnie", "Zamknij", ""); return 1; }
	 SaveVehicle(vehicd);
	 DestroyVehicle(vehicd);
	 Iter_Remove(Vehicles, vehicd);

	 sVehInfo[vehicd][uid] = 0;
	 PlayerTextDrawSetString(playerid, carSpawnTd, "Pojazd odspawnowany");
	 PlayerTextDrawShow(playerid, carSpawnTd);
	 defer HidePlayerTextDraw[CAR_SPAWN_TD_TIMEOUT*1000](playerid, carSpawnTd);
   }
   else
   {
    vehicd = CreateVehicle(strval(vmodel), floatstr(vposx), floatstr(vposy), floatstr(vposz), floatstr(vposa), strval(vcol1), strval(vcol2), 0);
    Iter_Add(Vehicles, vehicd);
    sVehInfo[vehicd][uid] = strval(vuid);
    sVehInfo[vehicd][model] = strval(vmodel);
    sVehInfo[vehicd][owner] = strval(vowner);
	sVehInfo[vehicd][ownertype] = 0;
    sVehInfo[vehicd][col1] = strval(vcol1);
    sVehInfo[vehicd][col2] = strval(vcol2);
    sVehInfo[vehicd][locked] = true;
    sVehInfo[vehicd][engine] = false;
    sVehInfo[vehicd][lights] = false;
    sVehInfo[vehicd][alarm] = false;
    sVehInfo[vehicd][objective] = false;
	sVehInfo[vehicd][radio] = !!strval(vRadio);
	format(sVehInfo[vehicd][radioStation], 128, vRadioStation);
	format(sVehInfo[vehicd][plates], 8, vPlates);
    sVehInfo[vehicd][mileage] = vmileage;
    sVehInfo[vehicd][health] = floatstr(vhealth);
    sVehInfo[vehicd][destroyed] = 0;
    sVehInfo[vehicd][pX] = floatstr(vposx);
    sVehInfo[vehicd][pY] = floatstr(vposy);
    sVehInfo[vehicd][pZ] = floatstr(vposz);
    sVehInfo[vehicd][pA] = floatstr(vposa);
    sscanf(vfuel, "s[64]", sVehInfo[vehicd][activeFuel]);
    if( floatcmp(sVehInfo[vehicd][health], 0.0) == 0 ){
	 sVehInfo[vehicd][health] = 251.0;
	 sVehInfo[vehicd][destroyed] = 1;
	}
	sscanf(vVisualDmg, "p<:>dddd", sVehInfo[vehicd][vDamagePanels], sVehInfo[vehicd][vDamageDoors], sVehInfo[vehicd][vDamageLights], sVehInfo[vehicd][vDamageTires]);
	sscanf(vComponents, "p<:>a<i>[14]", vComponentsList);
	for(new i=0;i<14;i++)
	{
	 AddVehicleComponent(vehicd, vComponentsList[i]);
	}
	SetVehicleNumberPlate(vehicd, sVehInfo[vehicd][plates]);
	SetVehicleHealth(vehicd, sVehInfo[vehicd][health]);
    UpdateVehicle(vehicd);

    PlayerTextDrawSetString(playerid, carSpawnTd, "Pojazd zespawnowany");
	PlayerTextDrawShow(playerid, carSpawnTd);
	defer HidePlayerTextDraw[CAR_SPAWN_TD_TIMEOUT*1000](playerid, carSpawnTd);

   }

   return 1;
}

stock GetClosestVehicle(playerid)
{
  new pretenderID, Float:pretenderDistance = 5.0;
  pretenderID = -1;
  foreach (new v : Vehicles)
  {
    new Float: vX, Float: vY, Float: vZ, Float:distance;
	GetVehiclePos(v, vX, vY, vZ);
	distance = GetPlayerDistanceFromPoint(playerid, vX, vY, vZ);
    if( GetPlayerVirtualWorld(playerid) == GetVehicleVirtualWorld(v) && distance <= 5.0 &&  distance <= pretenderDistance )
	{
	  pretenderID = v;
	  pretenderDistance = distance;
	}
  }
  
  return pretenderID;
}

stock CarsCommand(playerid, params[])
{
   new sub[32], param[128];
   if( sscanf(params, "s[32] ", sub) )
   {
	  new vehid;
	  vehid = GetPlayerVehicleID(playerid);
	  if( IsPlayerInAnyVehicle(playerid) && CanUseCar(playerid, vehid) )
	  {
		 new formattedVehData[580], formattedPrimaryFuel[128], formattedMisc[250], formattedRadio[220];
		 format(formattedPrimaryFuel, 128, "%s - %.0fl[%.0fl]", GetVehicleFuelType(vehid), GetVehicleCurrentFuel(vehid), GetVehicleMaxFuel(vehid));
		 String->Format("Pojazdy - %s [VID:%d][UID:%d]", VehicleNames[GetVehicleModel(vehid)-400], vehid, sVehInfo[vehid][uid]);

		 format(formattedMisc, sizeof(formattedMisc), "   Œwiat³a\t%s\n   Maska\t%s\n   Baga¿nik\t%s", (sVehInfo[vehid][lights]==false) ? ("[ {ED5E50}Wy³¹czone{FFFFFF} ]") : ("[ {8EB133}W³¹czone{FFFFFF} ]"), (sVehInfo[vehid][bonnet]==false) ? ("[ {ED5E50}Zamkniêta{FFFFFF} ]") : ("[ {8EB133}Otwarta{FFFFFF} ]"),(sVehInfo[vehid][boot]==false) ? ("[ {ED5E50}Zamkniêty{FFFFFF} ]") : ("[ {8EB133}Otwarty{FFFFFF} ]"));
		 if( sVehInfo[vehid][radio] )
		 {
		   format( formattedRadio, sizeof(formattedRadio), "   Radio\t\t%s\n   Radio stacja\t%s", (sVehInfo[vehid][radioState]==false) ? ("[ {ED5E50}Wy³¹czone{FFFFFF} ]") : ("[ {8EB133}W³¹czone{FFFFFF} ]"), sVehInfo[vehid][radioStation] );
		 }
		 else
		 {
		   format( formattedRadio, sizeof(formattedRadio), "   Radio\t\t[ {ED5E50}Brak{FFFFFF} ]" );
		 }

		 format(formattedVehData, sizeof(formattedVehData), "[{ABABAB} Podstawowe informacje {FFFFFF}]\n   Przebieg\t{a9c4e4}%dm\n   Zniszczenia\t{a9c4e4}%.2f\n   Silnik\t\t{a9c4e4}%.0fcm3\n   Paliwo\t{a9c4e4}%s\n[{ABABAB} Dodatki {FFFFFF}]\n%s\n%s", floatround(sVehInfo[vehid][mileage]), sVehInfo[vehid][health], floatmul(VehicleBaseFuelUsage[GetVehicleModel(vehid)-400], 1000), formattedPrimaryFuel, formattedMisc, formattedRadio);
         ShowPlayerDialog(playerid, 4, DIALOG_STYLE_LIST, BuildGuiCaption(formatted),formattedVehData,"Wybierz","Anuluj");
      }
      else
      {
        SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /v [lista/zaparkuj/(z)amknij/namierz/przepisz]");
      }
   }
   else
   {
	 sscanf( params, "{s[32]}s[128]", param );
     if( !strcmp("zaparkuj", sub, false) )
	 {
	   new Float:posX, Float:posY, Float:posZ, vid;
	   new Float:aMinX,Float:aMinY,Float:aMinZ,
            Float:aMaxX,Float:aMaxY,Float:aMaxZ;
	   vid = GetPlayerVehicleID(playerid);
	   if( !CanEditCar(playerid, vid) ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie posiadasz odpowiednich uprawnieñ do zarz¹dzania tym pojazdem.");
	   GetVehiclePos(vid, posX, posY, posZ);
	   aMinX = Min(floatsub(posX, CAR_PARK_RADIUS), floatadd(posX, CAR_PARK_RADIUS));
	   aMaxX = Max(floatsub(posX, CAR_PARK_RADIUS), floatadd(posX, CAR_PARK_RADIUS));
	   aMinY = Min(floatsub(posY, CAR_PARK_RADIUS), floatadd(posY, CAR_PARK_RADIUS));
	   aMaxY = Max(floatsub(posY, CAR_PARK_RADIUS), floatadd(posY, CAR_PARK_RADIUS));
	   aMinZ = Min(floatsub(posZ, CAR_PARK_RADIUS), floatadd(posZ, CAR_PARK_RADIUS));
	   aMaxZ = Max(floatsub(posZ, CAR_PARK_RADIUS), floatadd(posZ, CAR_PARK_RADIUS));
	   Query("SELECT * FROM vehicles WHERE x >= %f AND x <= %f AND y >= %f AND y <= %f AND z >= %f AND z <= %f", true, "VehiclePark" , aMinX, aMaxX, aMinY, aMaxY, aMinZ, aMaxZ);

	 }
	 
	 if( !strcmp("przepisz", sub, false) )
	 {
	   if( !IsPlayerInAnyVehicle(playerid) ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Aby przepisaæ pojazd pod grupê musisz siê w nim znajdowaæ.");
	   new vID = GetPlayerVehicleID(playerid);
	   if( isnull(param) || !IsNumeric(param) ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /v przepisz [uid grupy]");
	   if( !CanEditCar(playerid, vID) || sVehInfo[vID][ownertype] == 1 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie mo¿esz przepisaæ pod grupê tego pojazdu.");
	   
	   new grIdx = GetGroupByUid(strval(param));
	   if( grIdx == -1 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Grupa o podanym uid nie istnieje.");
	   
	   pInfo[playerid][t_dialogtmp1] = grIdx;
	   new string2[300];
	   format(string2, sizeof(string2), "{f90012}Ta akcja wymaga potwierdzenia, poniewa¿ nie mo¿esz cofn¹æ jej sam.\n\
	                                     {a9c4e4}Czy napewno chcesz przepisaæ pojazd {ffffff}%s {a9c4e4}o uid {ffffff}%d {a9c4e4}na grupê {%06x}%s{a9c4e4}?\n\n\
										 {ffffff}Aby potwierdziæ swój wybór, wpisz w pole poni¿ej 'potwierdzam'.", VehicleNames[sVehInfo[vID][model]-400], sVehInfo[vID][uid], groups[grIdx][gColor], groups[grIdx][name]);
	   ShowPlayerDialog(playerid, 74, DIALOG_STYLE_INPUT, BuildGuiCaption("PotwierdŸ akcjê -> Przepisanie pojazdu"), string2, "Dalej","Anuluj");
	   
	 }
	 
	 if( !strcmp("namierz", sub, false ) )
	 {
	   if(isnull(param)) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /v namierz [id pojazdu/wylacz]");
	   
	   if( IsNumeric(param) )
	   {
	     if( IsValidDynamicCP(carNamierz[playerid][0]) ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Masz ju¿ w³¹czone namierzanie innego pojazdu. Aby je wy³¹czyæ u¿yj /v namierz wylacz");
	     new vID = GetVehicleIdByUid( strval(param) );
		 
		 if( vID == -1 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Pojazd o podanym uid nie jest zespawnowany.");
	     if( !CanUseCar(playerid, vID) ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie masz prawa do namierzania tego pojazdu.");
		 
		 new Float: vX, Float:vY, Float:vZ, vVW;
		 GetVehiclePos(vID, vX, vY, vZ);
		 vVW = GetVehicleVirtualWorld(vID);
		 
		 if( GetPlayerVirtualWorld(playerid) != vVW ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Pojazd, który próbujesz namierzyæ znajduje siê w innym wirtualnym œwiecie.");
		 
		 carNamierz[playerid][0] = CreateDynamicCP(vX, vY, vZ, 5.0, vVW, -1, playerid);
		 carNamierz[playerid][1] = CreateDynamicMapIcon(vX, vY, vZ, 0, 0xFF4137FF, vVW, -1, playerid);
	   }
	   else
	   {
	     if( IsValidDynamicCP(carNamierz[playerid][0]) )
		 {
		   DestroyDynamicCP(carNamierz[playerid][0]);
		   DestroyDynamicMapIcon(carNamierz[playerid][1]);
		   
		   SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Namierzanie pojazdu zosta³o wy³¹czone.");
		 }
	   }
	   
	   
	 }
	 
	 if( !strcmp("lista", sub, false) )
	 {
       Query("SELECT * FROM vehicles WHERE owner=%d AND owner_type=0", true, "VehiclesListQuery" , pInfo[playerid][uid]);
     }
	 
	 if( !strcmp("z", sub, false) || !strcmp("zamknij", sub, false) )
	 {
	  new Float: x, Float:y, Float:z;
	  GetPlayerPos(playerid, x, y, z);
	  new Pretendent, Float:PretendentDistance, Float:Distance;
	  PretendentDistance = 6.0;
      Pretendent = -1;
	  foreach (new vid : Vehicles)
	  {
         Distance = GetVehicleDistanceFromPoint(vid, x, y, z);

         if( Distance <= 5.0 && Distance <= PretendentDistance )
         {
			Pretendent = vid;
			PretendentDistance = Distance;
         }
	  }
	  if( Pretendent > -1 )
	  {
	    if( !CanUseCar(playerid, Pretendent) ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie posiadasz kluczy do tego pojazdu.");
		if( sVehInfo[Pretendent][locked] == true )
		{
		   sVehInfo[Pretendent][locked] = false;
		   PlayerTextDrawSetString(playerid, carLockStateChangeTd, "Pojazd otwarty");
		   PlayerTextDrawColor(playerid, carLockStateChangeTd, 0x7CCB43FF);
		   PlayerTextDrawShow(playerid, carLockStateChangeTd);
		   defer HidePlayerTextDraw[1200](playerid, carLockStateChangeTd);
		   ApplyAnimation(playerid, "BD_FIRE", "wash_up", 4.1, 0, 1, 1, 1, 1, 1);
		   defer ClearPlayerAnimation[1000](playerid);
		   PlayerPlaySound( playerid, 1056, sVehInfo[Pretendent][pX], sVehInfo[Pretendent][pY], sVehInfo[Pretendent][pZ] );
        }
		else
		{
		   sVehInfo[Pretendent][locked] = true;
		   PlayerTextDrawSetString(playerid, carLockStateChangeTd, "Pojazd zamkniety");
		   PlayerTextDrawColor(playerid, carLockStateChangeTd, 0xB91E1EFF);
		   PlayerTextDrawShow(playerid, carLockStateChangeTd);
           defer HidePlayerTextDraw[1200](playerid, carLockStateChangeTd);
		   ApplyAnimation(playerid, "BD_FIRE", "wash_up", 4.1, 0, 1, 1, 1, 1, 1);
		   defer ClearPlayerAnimation[1000](playerid);
		   PlayerPlaySound( playerid, 1056, sVehInfo[Pretendent][pX], sVehInfo[Pretendent][pY], sVehInfo[Pretendent][pZ] );
	    }
	  }

	 }
   }
   
   return 0;
}

stock CanUseCar(playerid, vehicleid)
{
  if( sVehInfo[vehicleid][ownertype] == 0 )
  {
    // -- Pojazd prywatny
	// TODO: klucze
	if( sVehInfo[vehicleid][owner] == pInfo[playerid][uid] ) return 1;
  }
  else
  {
    // -- Jazdy
    if(pInfo[playerid][t_lesson] == 1 && IsPlayerInVehicle(pInfo[playerid][t_teacher], vehicleid) && sVehInfo[vehicleid][ownertype] == 1 && groups[GetGroupByUid(sVehInfo[vehicleid][owner])][type] == 2 ) return 1;
    // -- Pojazd grupowy
	new grIdx = GetGroupByUid(sVehInfo[vehicleid][owner]);
	new grSlot = GetGroupPlayerSlot(playerid, grIdx);
	if( IsPlayerInGroup(playerid, grIdx) )
	{
	  if( HasPlayerPermission(playerid, "group", GPREM_vehicles, grSlot) ) return 1;
	}
  }
  
  return 0;
}

stock CanEditCar(playerid, vehicleid)
{
  if( sVehInfo[vehicleid][ownertype] == 0 )
  {
    // -- Pojazd prywatny
	if( sVehInfo[vehicleid][owner] == pInfo[playerid][uid] ) return 1;
  }
  else
  {
    // -- Pojazd grupowy
	new grIdx = GetGroupByUid(sVehInfo[vehicleid][owner]);
	new grSlot = GetGroupPlayerSlot(playerid, grIdx);
	printf( "D1 - grIdx = %d, grSlot = %d, %d, %d", grIdx, grSlot, IsPlayerInGroup(playerid, grIdx), HasPlayerPermission(playerid, "group", GPREM_leader, grSlot));
	if( IsPlayerInGroup(playerid, grIdx) )
	{
	  if( HasPlayerPermission(playerid, "group", GPREM_leader, grSlot) ) return 1;
	}
  }
  
  return 0;
}

stock GetNumberOfPlayersInVehicle(vehicleid)
{
  new pcount = 0;
  foreach (new p: Player)
  {
    if( IsPlayerInVehicle(p, vehicleid) ) pcount++;
  }
  
  return pcount;
}

stock RespawnGroupVehicles(grIndx)
{
  new countVehs;
  foreach (new v : GroupVehicles[grIndx])
  {
     if( !IsVehicleEmpty(v) ) continue;
	 countVehs++;
	 // -- unspawn and save -- //
     SaveVehicle(v);
	 DestroyVehicle(v);
	 Iter_Remove(Vehicles, v);
	 Iter_Remove(GroupVehicles[GetGroupByUid(sVehInfo[v][owner])], v);
	 // -- spawn again -- //
	 
	 new vehicd = CreateVehicle(sVehInfo[v][model], sVehInfo[v][pX], sVehInfo[v][pY], sVehInfo[v][pZ], sVehInfo[v][pA], sVehInfo[v][col1], sVehInfo[v][col2], 0);
	 Iter_Add(GroupVehicles[GetGroupByUid(sVehInfo[v][owner])], vehicd);
	 Iter_Add(Vehicles, vehicd);
	 
	 sVehInfo[vehicd][locked] = true;
     sVehInfo[vehicd][engine] = false;
     sVehInfo[vehicd][lights] = false;
     sVehInfo[vehicd][alarm] = false;
     sVehInfo[vehicd][objective] = false;
	 sVehInfo[vehicd][radioState] = false;
	 UpdateVehicle(vehicd);
  }
}

forward SetVehicleID(vehicleId);
public SetVehicleID(vehicleId)
{
      sVehInfo[vehicleId][uid] = mysql_insert_id(mysqlHandle);
      return 1;
}