#include <a_samp>
#include <a_mysql>
#include <sscanf2>
#include <streamer>
#include <string>
#include <strlib>
#include <audio>
#include <md5>
#include <foreach>
#include <YSI\y_master>
#include <YSI\y_timers>
#include <zcmd>
#include <timestamptodate>


//gAMEmODES iNCLUDE
// -- GUI Dialog definitions -- //
#define DIALOG_STYLE_MSGBOX             0
#define DIALOG_STYLE_INPUT               1
#define DIALOG_STYLE_LIST                 2
#define DIALOG_STYLE_PASSWORD              3
#define LAST_DIALOG_ID 2

// GUI
#define C_ZIELONY "{00A600}"
#define C_CZERWONY "{FF0000}"

// Normal
#define COLOR_GREY 0xAFAFAFAA
#define COLOR_GREEN 0x33AA33FF
#define COLOR_RED 0xAA3333AA
#define COLOR_BLUE2 0x0000A0FF

// -- Colors -- //
#define BLUE 0x8080FFFF
#define WHITE 0xFFFFFFFF
#define RED 0x800000FF

// -- Penalty types -- //
#define PENALTY_TYPE_WARN 0
#define PENALTY_TYPE_KICK 1
#define PENALTY_SHOW_TIMEOUT 6

// -- Server indeed definitions -- //
#define GUI_CAPTION "[PLERP.net]"
#define Crp->Notify(%0,%1)                       printf("  [PLERP.net][%s] %s", (%0), (%1))

#define String->Format(%0,%1)                      \
		 new formatted[320];                               \
		 format(formatted, sizeof(formatted), (%0), %1)

#define Query(%0,%1,%2,%3)                 \
 new Query[256];                          \
 format( Query, sizeof(Query), (%0), %3); \
 mysql_function_query(mysqlHandle, Query, (%1), (%2), "d", playerid)

#if !defined isnull
    #define isnull(%1) \
                ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#endif

#define toupper(%0) \
    (((%0) >= 'a' && (%0) <= 'z') ? ((%0) & ~0x20) : (%0))

#define tolower(%0) \
    (((%0) >= 'A' && (%0) <= 'Z') ? ((%0) | 0x20) : (%0))

// -- MySql settings -- //
#define SQL_HOST "127.0.0.1"
#define SQL_USER "root"
#define SQL_PASS "zxcv"
#define SQL_DB "crp"

// -- Some settings -- //
#define MAX_LOGIN_ATTEMPTS 3
#define CAR_SPAWN_TD_TIMEOUT 2
#define MAX_CAR_LOCK_DIST 5.0
#define CAR_LOCK_STATE_TD_TIMEOUT 2
#define INJURE_EFFECT_TIMEOUT 1.5
#define CAR_REPAIR_BUFF_DURATION 5
#define CAR_PARK_RADIUS 2.0
#define CAR_PASSIVE_USAGE_MULTIPLY 2
#define FUEL_TD_HEIGHT -5.15
#define CAR_BASE_ENGINE_START_TIMEOUT 2.0

// -- STREAMING DISTANCE -- //
#define OBJECTS_STREAM_DISTANCE 50.0
#define OBJECTS_TEXT_STREAM_DISTANCE 20.0
#define ITEMS_LABEL_DRAWDISTANCE 6.0
#define PICKUPS_STREAM_DISTANCE 100.0

// -- SOME COLORS -- //
#define ITEMS_ON_GROUND_COLOR 0xFFFFFFD8


// -- FUEL TYPES USAGE -- //
#define FUEL_BENZYNA_USAGE 0.6
#define FUEL_GAZ_USAGE 0.9
#define FUEL_DIESEL_USAGE 0.7

#define PALIWO_CENA 2

// -- CHAT RANGE -- //
#define ME_CHAT_RANGE 5.0
#define MAX_CHAT_STRING 144

// -- ITEMS LIST -- //
#define ITEMS_PER_PAGE 10
#define MAX_ITEMS 1000
#define MAX_DOOR 1000
#define MAX_VEH 100
#define MAX_GROUPS 500
#define MAX_GROUP_REPORTS 500
#define MAX_ITEMS_PLAYER 100
#define MAX_PLAYER_ITEMS 100
#define MAX_ON_GROUND_ITEMS 2000

// -- ADMIN LEVELS -- //
#define ADMIN_LEVEL_MIN 4
#define GAMEMASTER_LEVEL_MIN 1

// -- ITEM TYPES -- //
#define CAR_KEYS_NORMAL 55
#define DOOR_KEYS 57
#define PHONE 58
#define DOKUMENT_DOWOD 59
#define CLOTHES 60

// -- objects owner types -- //
#define OBJECT_OWNER_TYPE_DOORS 0
#define OBJECT_OWNER_TYPE_AREA 1
#define OBJECT_OWNER_TYPE_GLOBAL 2

#define AREA_TYPE_GROUP       0
#define AREA_TYPE_OUTER_DOORS 1
#define AREA_TYPE_INNER_DOORS 2
#define AREA_TYPE_BANKOMAT    3

// -- Group perm types -- //
#define GPREM_leader 0
#define GPREM_info 1
#define GPREM_online 2
#define GPREM_storage 3
#define GPREM_offers 4
#define GPREM_invite 5
#define GPREM_vehicles 6
#define GPREM_special 7
#define GPREM_urzad_dokumenty 8
#define GPREM_urzad_drzwi 9

new names_of_month[12][15] = {"Stycze�","Luty","Marzec","Kwiecie�","Maj","Czerwiec","Lipiec","Sierpie�","Wrzesie�","Pa�dziernik","Listopad","Grudzie�"};

new Float:BASEspawn[3];

new globaln[MAX_PLAYERS][100];

// -- Textdraw's -- //
new Text:NoAudioClient;
new Text:EngineStartTd;
new Text:td_911;
new Text:PenaltyTextDraw[4];
new Text:LSNTextdraw[2];

// -- Pre-defined variables -- //
new mysqlHandle;
new pName[MAX_PLAYERS][MAX_PLAYER_NAME];
new pSalt[MAX_PLAYERS][20];
new bool:pHasIntro[MAX_PLAYERS];
new pLoginAttempt[MAX_PLAYERS] = 0;
new lastGroupGuiOptions[MAX_PLAYERS][10][34];

new Dostawa[MAX_PLAYERS][6];
new carNamierz[MAX_PLAYERS][2];

// -- Iterators -- //
//busy
#define MAX_BUS 100
enum BUSENUM {
    name[30],
    Float:pos_x,
    Float:pos_y,
    Float:pos_z,
    Float:pos_rz,
    uid,
    idobject,
    Text3D:label,
};
new Bus[MAX_BUS][BUSENUM];


#define BUS_CENA 0.25
//
new Iterator:Vehicles<MAX_VEH>;
new Iterator:Items_INITEM[MAX_ITEMS]<100>;
new Iterator:Groups<MAX_GROUPS>;
new Iterator:GroupVehicles[MAX_GROUPS]<100>;
new Iterator:GroupWorkers[MAX_GROUPS]<200>;
new Iterator:Doors<MAX_DOOR>;
new Iterator:Doors_Renters[MAX_DOOR]<200>;
new Iterator:Objects_GLOBAL<1000>;
new Iterator:Objects_DOORS[MAX_GROUPS]<300>;
new Iterator:Objects_AREA[500]<300>;
new Iterator:Bus<MAX_BUS>;
new Iterator:Areas<500>;

new Iterator:Animations<500>;
new Iterator:Items_PLAYER[1000]<MAX_ITEMS_PLAYER>;
new Iterator:Items_GROUND<100>;
new Iterator:Items_GROUND_VEH[MAX_VEH]<100>;
new Iterator:Items_GROUND_DOOR[MAX_DOOR]<100>;
new Iterator:Items_COMPONENT[MAX_VEH]<100>;
new Iterator:Items_STORE[MAX_DOOR]<100>;
//dodane teraz
//koniec
new Iterator:Items<MAX_ITEMS>;
new Iterator:GroupReports[MAX_GROUPS]<MAX_GROUP_REPORTS>;

// -- Time and Weather -- //
new hour, minute;

// -- Static Items Textdraw's -- //
new PlayerText:itemsStaticTd[5];
new PlayerText:itemsActionTd[10][4];
new PlayerText:carLockStateChangeTd;
new PlayerText:carSpawnTd;
new PlayerText:carTdSpeedo[3];
new PlayerText:carBarHud;
new PlayerText:carFuel[5];
new PlayerText:itemsTd[10];
new PlayerText:offersTd[6];
new PlayerText:doorsLocked[2];
new PlayerText:phoneBarUpper[5];
new PlayerText:dutyBar[2];
new PlayerText:DoorsInfo[4];
new PlayerText:NoCars;
new PlayerText:objectInfoTd;
new PlayerText:informationTd;
new PlayerText:afterDoorsInfo;
new PlayerText:ajTime;
new PlayerText:bwTime;

// -- groups enum -- //
enum e_groups{
	grid,
	name[64],
	type,
	bank,
	gColor
}
new groups[500][e_groups];

enum e_report {
        caller[128],
        place[128],
        attackers[128],
        victims[128],
        details[256],
        type[128],
        r_date[32],
		r_time
}
new GroupReport[MAX_GROUP_REPORTS][e_report];

enum e_areas{
    uid,
    owner,
    owner_type,
	type,
	Text3D:actionObjectLabel
}
new areas[100][e_areas];

// -- doors enum -- //
enum e_doors{
	doorUid,
	name[128],
	type,
	pickupType,
	pickupStyle,
	payment,
	owner,
	Float:doorX,
	Float:doorY,
	Float:doorZ,
	doorVW,
	doorInt,
	Float:intSpawnX,
	Float:intSpawnY,
	Float:intSpawnZ,
	intSpawnVW,
	intSpawnInt,
	maxObjects,
	bool:locked,
	bool:automaticLock,
	bool:carCrosing
}
new doors[1000][e_doors];

// -- objects enum -- //
enum e_objects{
	objectUid,
	owner_type,
	owner,
	objectVW,
	objectInt,
	model
}
new objects[10000][e_objects];

// -- Animations enum -- //
enum e_animations{
   animAlias[20],
   animLib[10],
   animName[64],
   Float:delta,
   loop,
   lockx,
   locky,
   freeze,
   time,
   forcesync
}
new animations[500][e_animations];

// -- User groups -- //
enum e_PlayerInfo_groups{
   groupIndx,
   groupUid,
   rank[64],
   permission[238],
   dutyTime,
   payday,
   bool:permLeader,
   bool:permInfo,
   bool:permOnline,
   bool:permStorage,
   bool:permOffers,
   bool:permInvite,
   bool:permVehicles,
   bool:permSpecial,
   // urzad miasta
   bool:permUrzadDokumenty,
   bool:permUrzadDrzwi
}
new pGroups[MAX_PLAYERS][5][e_PlayerInfo_groups];

// -- User holding enum -- //
enum e_PlayerInfo{
    uid,
    gid,
    cash,
	bank,
	bankcash,
    gname[64],
	name[MAX_PLAYER_NAME+1],
	tempG0Name[MAX_PLAYER_NAME+1],
	adminLevel,
	age,
	sex,
	lastLogin,
	Float:health,
	Float:last_x,
	Float:last_y,
	Float:last_z,
	timeOnline,
	lastActivity,
	bool:isAFK,
	logged,
	pswd[64],
	skin,
	tdnick[100],
	Text3D:tdnicklabel,
	carAudio,
	groupsPopupOpened,
	itemsPopupOpened,
	baseSpawn[158],
	itemsListPageNumber,
	itemInHand,
	tempItemsNear[30],
	lastGroupGuiId,
	standingInDoors,
	lastUsedItem,
	itemInteracted,
	radioHandle,
	lastUsedPhone,
	activeClothes,
	currentDuty,
	firehold,
	Text3D:playerDesc,
	/// LSPD - Bartek
	t_dialogtmp1,
	t_dialogtmp2,
	t_dialogtmp3,
	t_dialogtmp4,
	t_stringtmp[128],
	t_cuffed,
	////
	EditorAttItem,
	tmpOfferItem,
	bw,
	Timer:bw_timer,
	PlayerText:td_bw,
	weaponskill,
	t_wdrunk,
	weaponUsed[13],
	editedObject,
	bwStatus,
	t_911,
    // 911
    t_911_police,
    t_911_ambulance,
	t_killerid,
	t_reason,
    tmp1[128],
    tmp2[128],
    tmp3[256],
    tmp4[128],
    tmp5[128],
	hotelOutdoor,
	currentDynamicArea,
	OOC_block,
    RUN_block,
    FIGHT_block,
    t_spec,
    Float: armor,
	armor_status,
    /// Spec Text
    Text: spec_td_player,
    Text: spec_td_hp,
    Text: spec_td_armor,
    Text: spec_td_id,
    Timer: spec_timer,
    AJ_endtime,
    Timer: AJ_timer,
	/// LSN
    t_live,
    t_live_pid,
	//clothshop
	clothes_gui,
	clothes_page,
	/// Jazdy
    t_lesson,
    t_teacher
};
new pInfo[MAX_PLAYERS][e_PlayerInfo];

// -- User Active Offer -- //
enum e_pOffer{
   oSender,
   oType,
   oParam1,
   oParam2,
   oParam3,
   oParam4
}
new pOffer[MAX_PLAYERS][e_pOffer];

// -- User Active Call -- //
enum e_pCall{
   cCaller,
   cReceiver,
   cState,
   cTime,
   cStarted
}
new pCall[MAX_PLAYERS][e_pCall];

enum ENUM_ITEMS
{
	name[60],
	uid,
	owner_id,
	owner_type,
	type,
	value1,
	value2,
	tmpvalue[10],
	price,
	count,
	used,
	Float:pos_x,
	Float:pos_y,
	Float:pos_z,
	pos_vw,
	modellook,
	idobject
};
new Item[MAX_ITEMS][ENUM_ITEMS];

// - Spawned cars holding enum -- //
enum spawned_CarsInfo{
	uid,
	owner,
	ownertype,
	model,
	col1,
	col2,
	bool:locked,
	bool:engine,
	bool:lights,
	bool:boot,
	bool:bonnet,
	bool:alarm,
	bool:objective,
	bool:radio,
	bool:radioState,
	plates[8],
	radioStation[128],
	vDamagePanels,
	vDamageDoors,
	vDamageLights,
	vDamageTires,
	destroyed,
	Float:oldPos[3],
	Float:mileage,
	Float:health,
	Float:pX,
	Float:pY,
	Float:pZ,
	Float:pA,
	bool:carActionInProgress,
	Text3D:carActionLabel,
	activeFuel[64] // {Benzyna,50.421,80.0}
};
new sVehInfo[1000][spawned_CarsInfo];

#include <plerp\plerp_misc>
#include <plerp\plerp_items>
#include <plerp\plerp_lspd>
#include <plerp\plerp_textdraws>
#include <plerp\plerp_vehicles>
#include <plerp\plerp_timers>
#include <plerp\plerp_groups>
#include <plerp\plerp_offers>
#include <plerp\plerp_phones>
#include <plerp\plerp_doors>
#include <plerp\plerp_player>
#include <plerp\plerp_asgh>
#include <plerp\plerp_buildings>
#include <plerp\plerp_admin>
#include <plerp\plerp_clothshop>

// -- Forwards below -- //
forward ConnectMySQL();
forward DisconnectMySQL();
forward LoginQuery(playerid);
forward BeforeLoginQuery(playerid);
forward ResetSkills(playerid);
forward GetSpawnedVehicleIdByUid(vehuid);
forward VehiclesListQuery(playerid);
forward VehicleSpawnQuery(playerid, listpos);
forward IsVehicleEmpty(vehicleid);
forward VehiclePark(playerid);
forward CarEngineStart(vehicleid, playerid);
forward ItemsListQuery(playerid);
forward OnPlayerChangeWeapon(playerid, oldwep, newwep);
forward PlayerItemsLoadQuery(playerid);
forward PlayerGroupsLoadQuery(playerid);
forward OnPlayerWeaponRunOutOfAmmo(playerid, slotid, itemid);
forward ItemsLoadQuery();
forward DoorsLoadQuery();
forward GroupsLoadQuery();
forward GroupVehiclesLoadQuery();
forward ObjectsLoadQuery();
forward PhoneContactsListQuery(playerid);
forward PhoneCallsListQuery(playerid);
forward AnimationsLoadQuery();
forward AreasLoadQuery();
main() {}

public OnGameModeInit()
{
	Iter_Init(Items_PLAYER);
	Iter_Init(Items_GROUND_VEH);
	Iter_Init(Items_GROUND_DOOR);
	Iter_Init(Items_STORE);
	Iter_Init(Items_COMPONENT);
	Iter_Init(Items_INITEM);
	Iter_Init(GroupWorkers);
	Iter_Init(GroupVehicles);
	Iter_Init(GroupReports);
	Iter_Init(Objects_DOORS);
	Iter_Init(Objects_AREA);
	Iter_Init(Items_INITEM);
	Iter_Init(Doors_Renters);
	
	ShowPlayerMarkers(0);
    ShowNameTags(0);
    DisableInteriorEnterExits();
    EnableStuntBonusForAll(0);
    ManualVehicleEngineAndLights();
	
	printf("\n\n\n\n________________________________________________________\n");
	Crp->Notify("core", "Uruchamianie modu��w...");
	
    ConnectMySQL();     
    LoadItems();
    LoadGroups();
	LoadGroupVehicles();
    LoadDoors();
    LoadObjects();
    LoadAnimations();
	LoadAreas();
    LoadBus();
	
	BASEspawn[0] = 1486.837402;
	BASEspawn[1] = -1617.784057;
	BASEspawn[2] = 14.039297;

	SetGameModeText("PLERP.net v1.8");

	InitTextdrawsOnGameModeInit();
	
	printf("\n__________________________________________________________\n\n\n\n");
	
	
	return 1;
}

stock LoadGroups()
{
  new Query[256];
  format( Query, sizeof(Query), "SELECT * FROM groups");
  mysql_function_query(mysqlHandle, Query, true, "GroupsLoadQuery", "");
}

public GroupsLoadQuery()
{
  new rows, fields;
  cache_get_data( rows, fields, mysqlHandle);
   // -- Notification -- //
  String->Format("Wczytano %d grup", rows);
  Crp->Notify("grupy", formatted);
  if( rows > 0 )
  {
    for (new i; i<rows; i++)
    {
      new tempGrId[10], tempGrType[10], tempColor[32], tempBank[15];
      cache_get_field_content(i, "uid", tempGrId);
      cache_get_field_content(i, "type", tempGrType);
      cache_get_field_content(i, "colors", tempColor);
      cache_get_field_content(i, "name", groups[i][name]);
	  cache_get_field_content(i, "bank", tempBank);
      groups[i][gColor] = strval(tempColor);
      groups[i][grid] = strval(tempGrId);
      groups[i][type] = strval(tempGrType);
	  groups[i][bank] = strval(tempBank);
      Iter_Add(Groups, i);
	  
	  // -- Load group vehicles -- //
	  
	}
  }
}

stock LoadGroupVehicles()
{
  new Query[256];
  format( Query, sizeof(Query), "SELECT * FROM vehicles WHERE owner_type=1");
  mysql_function_query(mysqlHandle, Query, true, "GroupVehiclesLoadQuery", "");
}

public GroupVehiclesLoadQuery()
{
  new rows, fields;
  cache_get_data( rows, fields, mysqlHandle);
   // -- Notification -- //
  String->Format("Wczytano %d pojazd�w grup.", rows);
  Crp->Notify("pojazdy", formatted);
  if( rows > 0 )
  {
    for (new i; i<rows; i++)
    {
      new vuid[32], vmodel[32], vowner[32], vownertype[32], vcol1[32], vcol2[32], Float:vmileage, vmileaget[32], vhealth[32], vposx[32], vposy[32], vposz[32], vposa[32], vfuel[150], vVisualDmg[80], vComponents[200], vComponentsList[14], vehicd, vRadio[2], vRadioStation[120], vPlates[8];
      cache_get_field_content(i, "uid", vuid);
      cache_get_field_content(i, "model", vmodel);
      cache_get_field_content(i, "owner", vowner);
	  cache_get_field_content(i, "owner_type", vownertype);
      cache_get_field_content(i, "col1", vcol1);
      cache_get_field_content(i, "col2", vcol2);
      cache_get_field_content(i, "mileage", vmileaget); vmileage = floatstr(vmileaget);
      cache_get_field_content(i, "plates", vPlates);
      cache_get_field_content(i, "health", vhealth);
      cache_get_field_content(i, "x", vposx);
      cache_get_field_content(i, "y", vposy);
      cache_get_field_content(i, "z", vposz);
      cache_get_field_content(i, "a", vposa);
      cache_get_field_content(i, "fuel", vfuel);
      cache_get_field_content(i, "visual_damage", vVisualDmg);
      cache_get_field_content(i, "components", vComponents);
      cache_get_field_content(i, "radio", vRadio);
      cache_get_field_content(i, "radioStation", vRadioStation);
	  
	  vehicd = CreateVehicle(strval(vmodel), floatstr(vposx), floatstr(vposy), floatstr(vposz), floatstr(vposa), strval(vcol1), strval(vcol2), 0);
	  Iter_Add(GroupVehicles[GetGroupByUid(strval(vowner))], vehicd);
	  Iter_Add(Vehicles, vehicd);
      sVehInfo[vehicd][uid] = strval(vuid);
      sVehInfo[vehicd][model] = strval(vmodel);
      sVehInfo[vehicd][owner] = strval(vowner);
	  sVehInfo[vehicd][ownertype] = 1;
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
	  for(new j=0;j<14;j++)
	  {
	   AddVehicleComponent(vehicd, vComponentsList[j]);
	  }
	  SetVehicleNumberPlate(vehicd, sVehInfo[vehicd][plates]);
	  SetVehicleHealth(vehicd, sVehInfo[vehicd][health]);
      UpdateVehicle(vehicd);
	  
	}
  }
}

stock LoadAreas()
{
    new Query[256];
	format(Query, sizeof(Query), "SELECT * FROM areas");
	mysql_function_query(mysqlHandle, Query, true, "AreasLoadQuery", "");
}

public AreasLoadQuery()
{
  new rows, fields, stringz[64];
  cache_get_data(rows, fields, mysqlHandle);
   // -- Notification -- //
  String->Format("Wczytano %d stref", rows);
  Crp->Notify("strefy", formatted);
  if( rows > 0 )
  {
	 for (new i; i<rows; i++)
	 {
		new tempUid, tempOwner, tempType, Float:tempMinX, Float:tempMaxX, Float:tempMinY, Float:tempMaxY, tempVW;
		cache_get_field_content(i, "uid", stringz); tempUid = strval(stringz);
		cache_get_field_content(i, "owner", stringz); tempOwner = strval(stringz);
		cache_get_field_content(i, "type", stringz); tempType = strval(stringz);
		cache_get_field_content(i, "vw", stringz); tempVW = strval(stringz);
		cache_get_field_content(i, "minx", stringz); tempMinX = floatstr(stringz);
		cache_get_field_content(i, "maxx", stringz); tempMaxX = floatstr(stringz);
		cache_get_field_content(i, "miny", stringz); tempMinY = floatstr(stringz);
		cache_get_field_content(i, "maxy", stringz); tempMaxY = floatstr(stringz);
		
		new area = CreateDynamicRectangle(tempMinX, tempMinY, tempMaxX, tempMaxY, tempVW);
		areas[area][owner] = GetGroupByUid(tempOwner);
		areas[area][type] = tempType;
		areas[area][uid] = tempUid;
		
		Iter_Add(Areas, area);
	 }
  }
}

stock LoadItems()
{
	new Query[256];
	format(Query, sizeof(Query), "SELECT * FROM plerp_items");
	mysql_function_query(mysqlHandle, Query, true, "ItemsLoadQuery", "");
}

public ItemsLoadQuery()
{
	new rows, fields, string[64];
	cache_get_data(rows, fields, mysqlHandle);
	 // -- Notification -- //
    String->Format("Wczytano %d przedmiot�w", rows);
    Crp->Notify("przedmioty", formatted);
	if( rows > 0 )
	{
		for (new i; i<rows; i++)
		{
			cache_get_field_content(i, "type", string);
			if(strval(string) == 8 || strval(string) == 9) continue;
			Item[i][type] = strval(string);
			cache_get_field_content(i, "owner_id", string);
			Item[i][owner_id] = strval(string);
			cache_get_field_content(i, "owner_type", string);
			Item[i][owner_type] = strval(string);
			cache_get_field_content(i, "value1", string);
			Item[i][value1] = strval(string);
			cache_get_field_content(i, "value2", string);
			Item[i][value2] = strval(string);
			cache_get_field_content(i, "name", Item[i][name]);
			cache_get_field_content(i, "count", string);
			Item[i][count] = strval(string);
			cache_get_field_content(i, "price", string);
			Item[i][price] = strval(string);
			cache_get_field_content(i, "uid", string);
			Item[i][uid] = strval(string);
			cache_get_field_content(i, "pos_x", string);
			Item[i][pos_x] = floatstr(string);
			cache_get_field_content(i, "pos_y", string);
			Item[i][pos_y] = floatstr(string);
			cache_get_field_content(i, "pos_z", string);
			Item[i][pos_z] = floatstr(string);		
			//Dodane teraz
			cache_get_field_content(i, "pos_vw", string);
			Item[i][pos_vw] = strval(string);	
			//Koniec
			cache_get_field_content(i, "modellook", string);
			Item[i][modellook] = strval(string);
			Iter_Add(Items, i);
			printf("Iter %i zosta� dodany", i);
			if(Item[i][owner_type] == OWNER_TYPE_PLAYER)
			{
				Iter_Add(Items_PLAYER[Item[i][owner_id]], i);
				printf("Item o uid %i", Item[i][uid]);
			
			}
			if(Item[i][owner_type] == OWNER_TYPE_GROUND)
			{
				Iter_Add(Items_GROUND, i);
				printf("przedmiot o uid  %i le�y na ziemi", Item[i][uid]);
			    Item[i][idobject] = CreateDynamicObject(Item[i][modellook], Item[i][pos_x], Item[i][pos_y], Item[i][pos_z]-1, 0, 0, 0, Item[i][pos_vw], -1, -1, 200.0);
			}
			if(Item[i][owner_type] == OWNER_TYPE_CAR)
			{
				Iter_Add(Items_GROUND_VEH[Item[i][owner_id]], i);
			
			}			
			if(Item[i][owner_type] == OWNER_TYPE_DOORS)
			{
				Iter_Add(Items_GROUND_DOOR[Item[i][owner_id]], i);
			
			}		
			if(Item[i][owner_type] == OWNER_TYPE_WAREHOUSE)
			{
				Iter_Add(Items_STORE[Item[i][owner_id]], i);
			
			}		
			if(Item[i][owner_type] == OWNER_TYPE_CAR_COMPONENT)
			{
				Iter_Add(Items_COMPONENT[Item[i][owner_id]], i);
			
			}
			
			if(Item[i][type] == ITEM_TYPE_PHONE) Item[i][used] = Item[i][value2];
			if(Item[i][type] == ITEM_TYPE_CLOTHES) Item[i][used] = Item[i][value2];
		}
    }
    printf("Ostatni iter %i", Iter_Last(Items));
}

stock LoadDoors()
{
   new Query[256];
   format( Query, sizeof(Query), "SELECT * FROM doors");
   mysql_function_query(mysqlHandle, Query, true, "DoorsLoadQuery", "");
}

public DoorsLoadQuery()
{
   new rows, fields;
   cache_get_data( rows, fields, mysqlHandle);
    // -- Notification -- //
   String->Format("Wczytano %d drzwi", rows);
   Crp->Notify("drzwi", formatted);
   if( rows > 0 )
   {
      new doorsId, doorsAreaId, doorsSpawnAreaId;
	  for (new i; i<rows; i++)
      {
		 new tempDoorsUid[5], tempDoorsPickupStyle[5], tempDoorsPickupType[5], tempDoorsX[15], tempDoorsY[15], tempDoorsZ[15], tempDoorsVW[5], tempDoorsInt[5], tempDoorsPayment[10], tempDoorsOwner[5], tempDoorsType[5], tempDoorsName[300];
		 new tempIntSpawnX[15], tempIntSpawnY[15], tempIntSpawnZ[15], tempIntSpawnInt[10];
		 new tempObjectsMax[4], tempDoorsClosing[2], tempCarCrosing[2];
		 new tempRenters[400];
         cache_get_field_content(i, "uid", tempDoorsUid);
         cache_get_field_content(i, "type", tempDoorsType);
         cache_get_field_content(i, "pickupType", tempDoorsPickupType);
		 cache_get_field_content(i, "pickupStyle", tempDoorsPickupStyle);
         cache_get_field_content(i, "doorsName", tempDoorsName);
         cache_get_field_content(i, "doorsPayment", tempDoorsPayment);
         cache_get_field_content(i, "doorsClosing", tempDoorsClosing);
         cache_get_field_content(i, "doorsCarCrosing", tempCarCrosing);
         cache_get_field_content(i, "owner", tempDoorsOwner);
		 cache_get_field_content(i, "renters", tempRenters);
		 cache_get_field_content(i, "x", tempDoorsX);
         cache_get_field_content(i, "y", tempDoorsY);
         cache_get_field_content(i, "z", tempDoorsZ);
         cache_get_field_content(i, "vw", tempDoorsVW);
		 cache_get_field_content(i, "int", tempDoorsInt);
         cache_get_field_content(i, "objectsMax", tempObjectsMax);
         cache_get_field_content(i, "spawnX", tempIntSpawnX);
         cache_get_field_content(i, "spawnY", tempIntSpawnY);
         cache_get_field_content(i, "spawnZ", tempIntSpawnZ);
		 cache_get_field_content(i, "spawnInt", tempIntSpawnInt);
         
         doorsId = CreateDynamicPickup(strval(tempDoorsPickupStyle), strval(tempDoorsPickupType), floatstr(tempDoorsX), floatstr(tempDoorsY), floatstr(tempDoorsZ), strval(tempDoorsVW), -1, -1, PICKUPS_STREAM_DISTANCE);

         doors[doorsId][doorUid] = strval(tempDoorsUid);
		 doors[doorsId][type] = strval(tempDoorsType);
		 doors[doorsId][pickupType] = strval(tempDoorsPickupType);
		 doors[doorsId][pickupStyle] = strval(tempDoorsPickupStyle);
         doors[doorsId][payment] = strval(tempDoorsPayment);
         doors[doorsId][owner] = strval(tempDoorsOwner);
         doors[doorsId][doorX] = floatstr(tempDoorsX);
         doors[doorsId][doorY] = floatstr(tempDoorsY);
         doors[doorsId][doorZ] = floatstr(tempDoorsZ);
		 doors[doorsId][doorVW] = strval(tempDoorsVW);
		 doors[doorsId][doorInt] = strval(tempDoorsInt);
         doors[doorsId][intSpawnX] = floatstr(tempIntSpawnX);
         doors[doorsId][intSpawnY] = floatstr(tempIntSpawnY);
         doors[doorsId][intSpawnZ] = floatstr(tempIntSpawnZ);
		 doors[doorsId][intSpawnVW] = strval(tempDoorsUid);
		 doors[doorsId][intSpawnInt] = strval(tempIntSpawnInt);
         doors[doorsId][maxObjects] = strval(tempObjectsMax);
         doors[doorsId][automaticLock] = !!strval(tempDoorsClosing);
         doors[doorsId][carCrosing] = !!strval(tempCarCrosing);
         format(doors[doorsId][name], 128, "%s", tempDoorsName);
         if( doors[doorsId][automaticLock] ) doors[doorsId][locked] = true;
		 Iter_Add(Doors, doorsId);
		 
		 doorsAreaId = CreateDynamicSphere(doors[doorsId][doorX], doors[doorsId][doorY], doors[doorsId][doorZ], 3.0, doors[doorsId][doorVW], doors[doorsId][doorInt]);
		 areas[doorsAreaId][uid] = -1;
		 areas[doorsAreaId][type] = AREA_TYPE_OUTER_DOORS;
		 areas[doorsAreaId][owner] = doorsId;
		 
		 Iter_Add(Areas, doorsAreaId);
		 
		 doorsSpawnAreaId = CreateDynamicSphere(doors[doorsId][intSpawnX], doors[doorsId][intSpawnY], doors[doorsId][intSpawnZ], 3.0, doors[doorsId][intSpawnVW], doors[doorsId][intSpawnInt]);
		 areas[doorsSpawnAreaId][uid] = -1;
		 areas[doorsSpawnAreaId][type] = AREA_TYPE_INNER_DOORS;
		 areas[doorsSpawnAreaId][owner] = doorsId;
		 
		 Iter_Add(Areas, doorsSpawnAreaId);
		 
		 new renters[200];
		 sscanf(tempRenters, "p<,>a<d>[200]", renters);
		 for( new k=0; k<200; k++ )
		 {
		   if( renters[k] > 0 )
		   {
		      Iter_Add(Doors_Renters[doorsId], renters[k]);
		   }
		 }
      }

   }
}

stock LoadObjects()
{
   new Query[256];
   format( Query, sizeof(Query), "SELECT * FROM objects");
   mysql_function_query(mysqlHandle, Query, true, "ObjectsLoadQuery", "");
}

public ObjectsLoadQuery()
{
   new rows, fields;
   cache_get_data( rows, fields, mysqlHandle);
    // -- Notification -- //
   String->Format("Wczytano %d obiekt�w", rows);
   Crp->Notify("obiekty", formatted);
   if( rows > 0 )
   {
      new objectId;
	  for (new i; i<rows; i++)
      {
		 new tempObjectUid[5], tempObjectOwnerType[5], tempObjectOwner[5], tempObjectVW[5], tempObjectX[15], tempObjectY[15], tempObjectZ[15], tempObjectRotX[15], tempObjectRotY[15], tempObjectRotZ[15], tempObjectModel[10], tempObjectInt[5];
         cache_get_field_content(i, "owner_type", tempObjectOwnerType);
		 cache_get_field_content(i, "owner", tempObjectOwner);
		 cache_get_field_content(i, "vw", tempObjectVW);
		 cache_get_field_content(i, "int", tempObjectInt);
		 cache_get_field_content(i, "x", tempObjectX);
         cache_get_field_content(i, "y", tempObjectY);
         cache_get_field_content(i, "z", tempObjectZ);
         cache_get_field_content(i, "model", tempObjectModel);
         cache_get_field_content(i, "rotX", tempObjectRotX);
         cache_get_field_content(i, "rotY", tempObjectRotY);
         cache_get_field_content(i, "rotZ", tempObjectRotZ);
         cache_get_field_content(i, "id", tempObjectUid);
         
         objectId = CreateDynamicObject(strval(tempObjectModel), floatstr(tempObjectX), floatstr(tempObjectY), floatstr(tempObjectZ), floatstr(tempObjectRotX), floatstr(tempObjectRotY), floatstr(tempObjectRotZ), strval(tempObjectVW), -1, -1, OBJECTS_STREAM_DISTANCE);
         objects[objectId][objectUid] = strval(tempObjectUid);
		 objects[objectId][owner_type] = strval(tempObjectOwnerType);
		 objects[objectId][owner] = strval(tempObjectOwner);
         objects[objectId][objectVW] = strval(tempObjectVW);
		 objects[objectId][objectInt] = strval(tempObjectInt);
		 objects[objectId][model] = strval(tempObjectModel);
		 
		 if( strval(tempObjectOwnerType) == OBJECT_OWNER_TYPE_DOORS )
		 {
		    new dIdx = GetDoorsByUid(strval(tempObjectOwner));
		    Iter_Add(Objects_DOORS[dIdx], objectId);
		 }
		 
		 if( strval(tempObjectOwnerType) == OBJECT_OWNER_TYPE_AREA )
		 {
		    //new dIdx = GetDoorsByUid(strval(tempObjectOwner));
		    //Iter_Add(Objects_DOORS[dIdx], objectId);
		 }
		 
		 if( strval(tempObjectOwnerType) == OBJECT_OWNER_TYPE_GLOBAL )
		 {
		    Iter_Add(Objects_GLOBAL, objectId);
		 }
		 
		 // -- Action objects np. bankomat
		 PrepareActionObject(objectId);
      }

   }
}

stock LoadAnimations()
{
   new Query[256];
   format( Query, sizeof(Query), "SELECT * FROM animations");
   mysql_function_query(mysqlHandle, Query, true, "AnimationsLoadQuery", "");
}

public AnimationsLoadQuery()
{
   new rows, fields;
   cache_get_data( rows, fields, mysqlHandle);
    // -- Notification -- //
   String->Format("Wczytano %d animacji", rows);
   Crp->Notify("animacje", formatted);
   if( rows > 0 )
   {
	  for (new i; i<rows; i++)
      {
		 new tempAnimId[5], tempAnimAlias[20], tempAnimLib[10], tempAnimName[64], tempDelta[15], tempLoop[15], tempLockX[15], tempLockY[15], tempTime[10], tempFreeze[10], tempForceSync[10];
         cache_get_field_content(i, "id", tempAnimId);
		 cache_get_field_content(i, "name", tempAnimAlias);
		 cache_get_field_content(i, "animlib", tempAnimLib);
         cache_get_field_content(i, "animname", tempAnimName);
         cache_get_field_content(i, "Delta", tempDelta);
         cache_get_field_content(i, "loop", tempLoop);
         cache_get_field_content(i, "lockx", tempLockX);
         cache_get_field_content(i, "locky", tempLockY);
         cache_get_field_content(i, "freeze", tempFreeze);
         cache_get_field_content(i, "time", tempTime);
         cache_get_field_content(i, "forcesync", tempForceSync);

		 new animId = strval(tempAnimId);
         animations[animId][animAlias] = tempAnimAlias;
         animations[animId][animLib] = tempAnimLib;
         animations[animId][animName] = tempAnimName;
         animations[animId][delta] = floatstr(tempDelta);
         animations[animId][loop] = strval(tempLoop);
         animations[animId][lockx] = strval(tempLockX);
         animations[animId][locky] = strval(tempLockY);
         animations[animId][freeze] = strval(tempFreeze);
         animations[animId][time] = strval(tempTime);
         animations[animId][forcesync] = strval(tempForceSync);
         
		 Iter_Add(Animations, animId);
      }

   }
}

public OnGameModeExit()
{
	Crp->Notify("pojazdy", "Zapisywanie wszystkich pojazd�w...");
	
	foreach (new v : Vehicles)
	{
	  SaveVehicle(v);
	}

    Crp->Notify("przedmioty", "Zapisywanie przedmiot�w na ziemi...");
	
    Crp->Notify("j�dro", "Zamykanie modu��w...");
	return 1;
}

public OnPlayerConnect(playerid)
{
    RemoveAllBuildingsForPlayer(playerid);
    
	gettime(hour, minute);
	SetPlayerTime(playerid,hour,minute);
	
	DestroyDynamic3DTextLabel(pInfo[playerid][tdnicklabel]);
	ResetPlayerWeapons(playerid);
	SetPlayerColor(playerid, WHITE);
	SetPlayerTeam(playerid, 1);
		
    // -- Reseting all data -- //
    for(new z; e_PlayerInfo:z<e_PlayerInfo; z++)
    {
      pInfo[playerid][e_PlayerInfo:z] = '\0';
    }
     
	for(new f=0; f<13;f++)
	{
	  pInfo[playerid][weaponUsed][f] = -1;
	}
	
	InitTextdrawsOnPlayerConnect(playerid);
	GenerateOffersTextDraws(playerid);
	GeneratePhoneTextDraws(playerid);
	GenerateItemsListRows(playerid);


	pInfo[playerid][logged] = 0;
	
	GetPlayerName(playerid, pName[playerid], sizeof(pName) );
	strreplace(pName[playerid], '_', ' ');
	Query("SELECT * FROM characters,mbb_users WHERE characters.gid=mbb_users.uid AND characters.nick='%s'", true, "BeforeLoginQuery" , pName[playerid]);
	TogglePlayerSpectating(playerid, 1);
	PlayerSpectatePlayer(playerid, INVALID_PLAYER_ID);
    defer ServerIntro[500](playerid);
}

public BeforeLoginQuery(playerid)
{
	new rows, fields;
	cache_get_data(rows, fields, mysqlHandle);
	if( rows == 1 ) 
	{
	   new string[500], tmpInt;
	   #pragma unused tmpInt
	   cache_get_field_content(0, "username", globaln[playerid]);
	   cache_get_field_content(0, "salt", pSalt[playerid]);
	   format( string, sizeof(string), "Witaj %s, pod��czy�e� si� do serwera PLERP.net.\n\
	                                    Dzi� jest %s, %d dzie� w roku.\n\n\
										Aby rozpocz�� gr� postaci� {DCD6BC}%s {a9c4e4}zaloguj si� podaj�c has�o\n\
										w polu poni�ej. Mo�esz tak�e skorzysta� z dodatkowych opcji.", globaln[playerid], FormatDataForShow(gettime(), 1), getdate(tmpInt, tmpInt, tmpInt), pName[playerid] );
       ShowPlayerDialog(playerid, 0, DIALOG_STYLE_PASSWORD, BuildGuiCaption("PLERP.net � {AFCC70}Logowanie"), string, "Zaloguj", "Opcje");
	   ChatClean(playerid);
	} 
	else 
	{
	   new string[160];
	   format( string, sizeof(string), "Posta� {DCD6BC}%s {a9c4e4}nie istnieje w naszej bazie danych.\n\
	                                    Zmien swoj� posta� lub wejd� na www.plerp.net, aby si� zarejestrowa�.", pName[playerid] );
       ShowPlayerDialog(playerid, 73, DIALOG_STYLE_MSGBOX, BuildGuiCaption("PLERP.net � {AFCC70}Nie posiadasz konta"), string, "Zmie� posta�", "Wyjd�" );
	}
	return 1;
}

public LoginQuery(playerid)
{
	new rows, fields, msg[144];
	cache_get_data(rows, fields, mysqlHandle);
	if( rows == 1 ) {
	   new tempField[300], qsX[30], qsY[30], qsZ[30], qsVW[30], qsTime[30], block, Float: phealth;
	   // -- Setup pInfo -- //
	   cache_get_field_content(0, "uid", tempField);  pInfo[playerid][uid] = strval(tempField);
	   cache_get_field_content(0, "gid", tempField);  pInfo[playerid][gid] = strval(tempField);
	   cache_get_field_content(0, "age", tempField);  pInfo[playerid][age] = strval(tempField);
	   cache_get_field_content(0, "sex", tempField);  pInfo[playerid][sex] = strval(tempField);
	   cache_get_field_content(0, "bwstatus", tempField); pInfo[playerid][bwStatus] = strval(tempField);
	   cache_get_field_content(0, "cash", tempField); pInfo[playerid][cash] = strval(tempField);
	   cache_get_field_content(0, "bank", tempField); pInfo[playerid][bank] = strval(tempField);
	   cache_get_field_content(0, "bankcash", tempField); pInfo[playerid][bankcash] = strval(tempField);
	   cache_get_field_content(0, "timeOnline", tempField); pInfo[playerid][timeOnline] = strval(tempField);
	   cache_get_field_content(0, "lastLogin", tempField); pInfo[playerid][lastLogin] = strval(tempField);
	   cache_get_field_content(0, "username", pInfo[playerid][gname]);
	   cache_get_field_content(0, "nick", pInfo[playerid][name]);
	   cache_get_field_content(0, "password", pInfo[playerid][pswd]);
	   cache_get_field_content(0, "skin", tempField); pInfo[playerid][skin] = strval(tempField);
	   cache_get_field_content(0, "baseSpawn", pInfo[playerid][baseSpawn]);
	   cache_get_field_content(0, "qsX", qsX);
	   cache_get_field_content(0, "qsY", qsY);
	   cache_get_field_content(0, "qsZ", qsZ); 
	   cache_get_field_content(0, "qsVW", qsVW); 
	   cache_get_field_content(0, "qsTime", qsTime);
	   cache_get_field_content(0, "weaponskill", tempField); pInfo[playerid][weaponskill] = strval(tempField);
	   cache_get_field_content(0, "bw", tempField); pInfo[playerid][bw] = strval(tempField);
	   cache_get_field_content(0, "p_block", tempField); block = strval(tempField);
	   cache_get_field_content(0, "health", tempField); phealth = floatstr(tempField);
	   //Dodane teraz
	   for(new i; i < 13; i++ )
	   {
		  pInfo[playerid][weaponUsed][i] = -1;
	   }
	   
	   pInfo[playerid][lastActivity] = 0;
	   pInfo[playerid][logged] = 1;
	   pInfo[playerid][standingInDoors] = -1;
	   pInfo[playerid][currentDuty] = -1;
	   pInfo[playerid][lastUsedPhone] = -1;
	   pInfo[playerid][EditorAttItem] = -1;
	   pInfo[playerid][activeClothes] = -1;
	   pInfo[playerid][editedObject] = -1;
	   pInfo[playerid][clothes_gui] = 0;
	   
	   // -- clothshop -- //
       gHeaderTextDrawId[playerid] = PlayerText:INVALID_TEXT_DRAW;
       gBackgroundTextDrawId[playerid] = PlayerText:INVALID_TEXT_DRAW;
       gCurrentPageTextDrawId[playerid] = PlayerText:INVALID_TEXT_DRAW;
       gNextButtonTextDrawId[playerid] = PlayerText:INVALID_TEXT_DRAW;
       gPrevButtonTextDrawId[playerid] = PlayerText:INVALID_TEXT_DRAW;
    
       for(new x=0; x < SELECTION_ITEMS; x++) {
          gSelectionItems[playerid][x] = PlayerText:INVALID_TEXT_DRAW;
	   }
	
	   gItemAt[playerid] = 0;
	   
	   // -- Blokada postaci -- //
	   if(block == 1)
	   {
			SendClientMessage(playerid, COLOR_RED, "Ta posta� jest u�miercona.");
			Kick(playerid);
			return 1;
	   }
	   
	   new stringg[250], ttime = gettime();
       // -- Banicje -- //
       format(stringg, sizeof(stringg), "SELECT * FROM `penalties` WHERE `type`='2' AND `obtainer`=%d AND `endtime`>='%d'", pInfo[playerid][uid], ttime);
       mysql_function_query(mysqlHandle, stringg, true, "CheckBanQuery", "d", playerid);
       // -- Warny -- //
       format(stringg, sizeof(stringg), "SELECT * FROM `penalties` WHERE `type`='0' AND `obtainer`=%d AND `endtime`>='%d'", pInfo[playerid][uid], ttime);
       mysql_function_query(mysqlHandle, stringg, true, "CheckWarnQuery", "d", playerid);
       // -- Blokady -- //
       format(stringg, sizeof(stringg), "SELECT * FROM `penalties` WHERE (`type`='4' OR `type`='5' OR `type`='6') AND `obtainer`=%d AND `endtime`>='%d'", pInfo[playerid][uid], ttime);
       mysql_function_query(mysqlHandle, stringg, true, "CheckBlockadesQuery", "d", playerid);
       // -- Admin Jail -- //
       format(stringg, sizeof(stringg), "SELECT * FROM `penalties` WHERE `type`='3' AND `obtainer`=%d AND `endtime`>='%d'", pInfo[playerid][uid], ttime);
       mysql_function_query(mysqlHandle, stringg, true, "CheckAdminJailQuery", "d", playerid);
	   
	   // -- �ycie postaci -- //
	   pInfo[playerid][health] = phealth;
	   SetPlayerHealth(playerid, phealth);
	   
	   // -- check for used items like phone -- //
	   foreach (new i : Items_PLAYER[pInfo[playerid][uid]])
	   {
	     if( Item[i][type] == ITEM_TYPE_PHONE && Item[i][used] == 1 ) pInfo[playerid][lastUsedPhone] = i;
		 if( Item[i][type] == ITEM_TYPE_CLOTHES && Item[i][used] == 1 ) 
		 {
		    pInfo[playerid][activeClothes] = i;
		 }
 	   }
	   
	   // -- welcome message -- //
	   format(msg, sizeof(msg), "{B2C5D3}PLERP.net 1.8: Witaj, %s! Zalogowa�e� si� jako {FFFFFF}%s {B2C5D3}(ID: %d, UID: %d, GID: %d).", pInfo[playerid][gname], pInfo[playerid][name], playerid, pInfo[playerid][uid], pInfo[playerid][gid]);
       SendClientMessage(playerid, WHITE, msg);
	 
       // -- Loading player groups -- //
       new QueryG[256];
       format( QueryG, sizeof(QueryG), "SELECT * FROM worker_profile WHERE uid=%d", pInfo[playerid][uid]);
       mysql_function_query(mysqlHandle, QueryG, true, "PlayerGroupsLoadQuery", "d", playerid);
       // -- Set player online -- //
       new updateQuery[256];
       format( updateQuery, sizeof(updateQuery), "UPDATE `characters` SET `online`='1', `lastLogin`='%d' WHERE `uid`='%d'", gettime(), pInfo[playerid][uid]);
       mysql_function_query(mysqlHandle, updateQuery, false, "", "");
       
	   if( pInfo[playerid][bwStatus] == 1 )
	   {
	     SendClientMessage(playerid, COLOR_RED, "Jeszcze niedawno utraci�e� przytomno�c i jeste� os�abiony, lepiej udaj si� do szpitala.");
	   }
	   
	   // -- First, check for the /qs time
       if( strval(qsTime) > 0 && gettime() - strval(qsTime) < 60*10)
       {
	     if( floatstr(qsX) == 0.0 && floatstr(qsY) == 0 && floatstr(qsZ) == 0 )
		 {
		    SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Twoja zapisana pozycja uleg�a zniszczeniu, zostaniesz przeniesiony na spawn.");
			new QsQuery[256];
            format( QsQuery, 256, "UPDATE `characters` SET `qsX`='%f', `qsY`='%f', `qsZ`='%f', `qsVW`='%d', `qsTime`='%d' WHERE `uid`='%d'", 0.0, 0.0, 0.0, 0, 0, pInfo[playerid][uid]);
            mysql_function_query(mysqlHandle, QsQuery, false, "", "");
		    	
			goto wrongPos;
		 }
		 if(pInfo[playerid][bw] > 0) 
	     {
	       SetSpawnInfo(playerid, NO_TEAM, pInfo[playerid][skin], floatstr(qsX), floatstr(qsY), floatstr(qsZ), 0,0,0,0,0,0,0);
		   goto skipQsCheck;
	     }
         SetSpawnInfo(playerid, NO_TEAM, pInfo[playerid][skin], floatstr(qsX), floatstr(qsY), floatstr(qsZ), 0,0,0,0,0,0,0);
         SetPlayerVirtualWorld(playerid, strval(qsVW));
         
         new QsQuery[256];
         format( QsQuery, 256, "UPDATE `characters` SET `qsX`='%f', `qsY`='%f', `qsZ`='%f', `qsVW`='%d', `qsTime`='%d' WHERE `uid`='%d'", 0.0, 0.0, 0.0, 0, 0, pInfo[playerid][uid]);
         mysql_function_query(mysqlHandle, QsQuery, false, "", "");
         
         new formattedMsg[128], timeFromLogout;
         timeFromLogout = gettime() - strval(qsTime);
         format( formattedMsg, 128, "PLERP.net: Twoja poprzednia pozycja zosta�a przywr�cona, czas od wylogowania: %dm %ds", timeFromLogout/60, timeFromLogout%60 );
         SendClientMessage(playerid, COLOR_GREY, formattedMsg);
       }
       else
       {
	     wrongPos:
         new Float:spawnX, Float:spawnY, Float:spawnZ, spawnVW, spawnInt, spawnType;
         GetPlayerSpawnLocation(playerid, spawnX, spawnY, spawnZ, spawnVW, spawnInt, spawnType);
         SetSpawnInfo(playerid,NO_TEAM,pInfo[playerid][skin], spawnX, spawnY, spawnZ, 0,0,0,0,0,0,0);
         SetPlayerVirtualWorld(playerid, spawnVW);
		 
		 if( spawnType == 2 ) 
		 {
		    SetPlayerInterior(playerid, spawnInt);
			SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Aby wyj�c z pokoju hotelowego u�yj /pokoj wyjdz");
		 }
       }
	   
	   skipQsCheck:
	   
       TogglePlayerSpectating(playerid, 0);
       
       ResetSkills(playerid);
	   SetCameraBehindPlayer(playerid);
	   GivePlayerMoney(playerid, pInfo[playerid][cash]);
	   
	   // -- 3d nick label -- //
	   format(pInfo[playerid][tdnick], 100, "%s (%d)", pInfo[playerid][name], playerid );
	   BuildPlayerAdnotations(playerid);
	   
    } 
	else 
	{
	   new string[550], string2[220], tmpInt;
   	   pLoginAttempt[playerid]++;
	   if( pLoginAttempt[playerid] >= MAX_LOGIN_ATTEMPTS )
	   {
		  format( string, sizeof(string), "PLERP.net: Wpisa�e� b��dne has�o %d razy - zostaniesz wyrzucony z serwera!", MAX_LOGIN_ATTEMPTS); 
		  SendClientMessage(playerid, COLOR_GREY, string); 
		  Kick(playerid);
	   }
	   format( string, sizeof(string), "Witaj %s, pod��czy�e� si� do serwera PLERP.net.\n\
	                                         Dzi� jest %s, %d dzie� w roku.\n\n",globaln[playerid], FormatDataForShow(gettime(), 1), getdate(tmpInt, tmpInt, tmpInt));
	   format( string2, sizeof(string2), "Aby rozpocz�� gr� postaci� {DCD6BC}%s {a9c4e4}zaloguj si� podaj�c has�o\n\
										  w polu poni�ej. Mo�esz tak�e skorzysta� z dodatkowych opcji.\n\n\
										         \t{9f000b}Wpisane has�o jest b��dne - pozosta�o %d pr�b.", pName[playerid], (MAX_LOGIN_ATTEMPTS-pLoginAttempt[playerid]) );
	   strcat(string, string2);
	   ShowPlayerDialog(playerid, 0, DIALOG_STYLE_PASSWORD, BuildGuiCaption("PLERP.net � {AFCC70}Logowanie"), string, "Zaloguj", "Opcje");

	}



    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if( pInfo[playerid][logged] == 0 ) return 1;
		
	if( pCall[playerid][cState] > 0 )
	{
      defer ResetPlayerCall(playerid);
      defer ResetPlayerCall(GetSecondTalker(playerid));
    }
    
	foreach (new idee : Items_PLAYER[pInfo[playerid][uid]])
    {
       if(Item[idee][used] && Item[idee][type] != ITEM_TYPE_PHONE && Item[idee][type] != ITEM_TYPE_CLOTHES )
       {
          ItemUse(idee, playerid);
       }
    }
	
	if(pInfo[playerid][t_live] == 1)
                pInfo[pInfo[playerid][t_live_pid]][t_live] = 0;
	
	if(pInfo[playerid][bw] > 0)
		stop pInfo[playerid][bw_timer];
		
	new vID = GetPlayerVehicleID(playerid);
	if( vID > -1 )
	{
	  sVehInfo[vID][locked] = true;
	}
	
	new Float:currX, Float:currY, Float:currZ;
    GetPlayerPos(playerid, currX, currY, currZ);
	if(pInfo[playerid][bw] > 0)
    {
        stop pInfo[playerid][bw_timer];
        new Query[456];
        format( Query, sizeof(Query), "UPDATE `characters` SET `qsX`='%f', `qsY`='%f', `qsZ`='%f', `qsVW`='%d', `qsTime`='%d' WHERE `uid`='%d'", currX, currY, currZ, GetPlayerVirtualWorld(playerid), gettime(), pInfo[playerid][uid]);
        mysql_function_query(mysqlHandle, Query, false, "", "");
    }
    new formattedReason[84];
    if( reason == 0 ) format( formattedReason, 84, "(( %s ))\n(( timeout ))", pInfo[playerid][name] );
    if( reason == 1 ) format( formattedReason, 84, "(( %s ))\n(( /q ))", pInfo[playerid][name] );
    if( reason == 2 ) goto skip;
	
    new Text3D:disconnectNotif = CreateDynamic3DTextLabel(formattedReason, 0xA4A4A4FF, currX, currY, currZ-0.3, ITEMS_LABEL_DRAWDISTANCE, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), INVALID_PLAYER_ID, OBJECTS_STREAM_DISTANCE);
    defer DeleteDisconnectNotif[3000](disconnectNotif);
	
	skip:
    SetupPlayerDuty(playerid, -1);
	DestroyDynamic3DTextLabel(pInfo[playerid][tdnicklabel]);
	
	for( new i=0; i<GetPlayerGroupFreeSlot(playerid); i++ )
	{
	  Iter_Remove(GroupWorkers[pGroups[playerid][i][groupIndx]], playerid);
	}
	
	SavePlayer(playerid);
	pInfo[playerid][logged] = 0;
	return 1;
}

public Audio_OnClientConnect(playerid)
{
   TextDrawHideForPlayer(playerid, NoAudioClient);
}

public OnPlayerSpawn(playerid)
{
	gettime(hour, minute);
	SetPlayerTime(playerid,hour,minute);
	
	if( pInfo[playerid][activeClothes] != -1 ) SetPlayerSkin(playerid, Item[pInfo[playerid][activeClothes]][value1]);
	
	// -- Anim Libs Preload -- //
	PreloadAnimLib(playerid,"BOMBER");
   	PreloadAnimLib(playerid,"RAPPING");
    PreloadAnimLib(playerid,"SHOP");
   	PreloadAnimLib(playerid,"BEACH");
   	PreloadAnimLib(playerid,"SMOKING");
    PreloadAnimLib(playerid,"FOOD");
    PreloadAnimLib(playerid,"ON_LOOKERS");
    PreloadAnimLib(playerid,"DEALER");
	PreloadAnimLib(playerid,"CRACK");
	PreloadAnimLib(playerid,"CARRY");
	PreloadAnimLib(playerid,"COP_AMBIENT");
	PreloadAnimLib(playerid,"PARK");
	PreloadAnimLib(playerid,"INT_HOUSE");
	PreloadAnimLib(playerid,"FOOD");
	PreloadAnimLib(playerid,"PED");
	PreloadAnimLib(playerid,"SWEET");
		
	PreloadAnimLib(playerid,"AIRPORT");
	PreloadAnimLib(playerid,"Attractors");
	PreloadAnimLib(playerid,"BAR");
	PreloadAnimLib(playerid,"BASEBALL");
	PreloadAnimLib(playerid,"BD_FIRE");
	PreloadAnimLib(playerid,"benchpress");
	PreloadAnimLib(playerid,"BF_injection");
	PreloadAnimLib(playerid,"BLOWJOBZ");
	PreloadAnimLib(playerid,"BOX");
	PreloadAnimLib(playerid,"BSKTBALL");
	PreloadAnimLib(playerid,"BUDDY");
	PreloadAnimLib(playerid,"CAMERA");
	PreloadAnimLib(playerid,"CARRY");
	
    if( pInfo[playerid][logged] == 1 && pInfo[playerid][bw] > 0 )
	{
	   BuildPlayerAdnotations(playerid);
	   ApplyAnimation(playerid, "SWEET", "Sweet_injuredloop", 4.1, 1, 0, 0, 1, 0, 1); 
	   TogglePlayerControllable(playerid, 0);	   
	   pInfo[playerid][td_bw] = CreatePlayerTextDraw(playerid, 0.0, 0.0, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~ \
																		  ~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~ \
																		  ~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~ \
																		  ~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~ \
																		  ~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~");
	   PlayerTextDrawUseBox(playerid, pInfo[playerid][td_bw], 1);
	   PlayerTextDrawBoxColor(playerid, pInfo[playerid][td_bw], 0xFF000050);
	   PlayerTextDrawTextSize(playerid, pInfo[playerid][td_bw], 640, 400);
	   PlayerTextDrawShow(playerid, pInfo[playerid][td_bw]);
	   pInfo[playerid][bw_timer] = repeat PlayerBW(playerid);
	   pInfo[playerid][health] = 9999999999.0;
	   SetPlayerHealth(playerid, 9999999999.0);
	   
	   new Float:currX, Float:currY, Float:currZ;
	   GetPlayerPos(playerid, currX, currY, currZ);
	   SetPlayerCameraPos(playerid, currX, currY, currZ+4.0);
	   SetPlayerCameraLookAt(playerid, currX, currY, currZ);
	   
	   SendClientMessage(playerid, COLOR_RED, "Zosta�e� powa�nie ranny i straci�e� przytomno��. Poczekaj na przybycie karetki, lub odzyskanie przytomno�ci.");
	}
	else if( pInfo[playerid][logged] == 1 && pInfo[playerid][bw] == 0 )
	{		
	    TogglePlayerControllable(playerid, 0);
	    defer UnfreezePlayer[3000](playerid);
	    // -- Audio plugin -- //
	    if( !Audio_IsClientConnected(playerid) ) TextDrawShowForPlayer(playerid, NoAudioClient);
        BuildPlayerAdnotations(playerid);
        if( GetPlayerSpawnType(playerid) == 1 ) OnPlayerVirtualWorldChange(playerid, GetDoorsByUid(GetPlayerVirtualWorld(playerid)));
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    new Float:posX, Float:posY, Float:posZ;
	GetPlayerPos(playerid, posX, posY, posZ);
	SetPlayerHealth(playerid, 1.0);
	
	new Query[300];
	format( Query, sizeof(Query), "UPDATE `characters` SET `qsX`='%f', `qsY`='%f', `qsZ`='%f', `qsVW`='%d', `qsTime`='%d' WHERE `uid`='%d'", posX, posY, posZ, GetPlayerVirtualWorld(playerid), gettime(), pInfo[playerid][uid]);
    mysql_function_query(mysqlHandle, Query, false, "", "");
	if( IsPlayerInAnyVehicle(playerid) )
	{
	   PlayerTextDrawHide(playerid, carTdSpeedo[0]);
	   PlayerTextDrawHide(playerid, carTdSpeedo[1]);
	   PlayerTextDrawHide(playerid, carTdSpeedo[2]);
	   PlayerTextDrawHide(playerid, carFuel[0]);
	   PlayerTextDrawHide(playerid, carFuel[1]);
	   PlayerTextDrawHide(playerid, carFuel[2]);
	   PlayerTextDrawHide(playerid, carFuel[3]);
	   PlayerTextDrawHide(playerid, carFuel[4]);
	}
	
    SetSpawnInfo(playerid, NO_TEAM, pInfo[playerid][skin], posX, posY, posZ,0,0,0,0,0,0,0);
	if(killerid == INVALID_PLAYER_ID)
	{
		pInfo[playerid][bw] = 1200000;
	}	
	else
	{
		pInfo[playerid][bw] = 600000;
	}
	pInfo[playerid][health] = 5;
	SpawnPlayer(playerid);
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	if( sVehInfo[vehicleid][health] > 250.0 ) return 1;
	
	sVehInfo[vehicleid][health] = 0.0;
	sVehInfo[vehicleid][destroyed] = 1;
	

    GetVehiclePos(vehicleid, sVehInfo[vehicleid][pX], sVehInfo[vehicleid][pY], sVehInfo[vehicleid][pZ]);
    GetVehicleZAngle(vehicleid, sVehInfo[vehicleid][pA]);

	SaveVehicle(vehicleid);
	DestroyVehicle(vehicleid);
	Iter_Remove(Vehicles, vehicleid);
	
	new Query[256];
	format( Query, sizeof(Query), "SELECT * FROM vehicles WHERE uid=%d", sVehInfo[vehicleid][uid]);
	sVehInfo[vehicleid][uid] = 0;
    mysql_function_query(mysqlHandle, Query, true, "VehicleSpawnQuery", "dd",  6666, 0);
	return 1;
}

//-----------------------------------------------
public OnPlayerText(playerid, text[])
{
	if(pInfo[playerid][bw] > 0)
    {
        SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie mo�esz m�wi� gdy jeste� nieprzytomny.");
        return 0;
    }
	
	if( !strcmp(":)", text, true) ) { NewProx(playerid, "me", "u�miecha si�"); return 0; }
	if( !strcmp(":(", text, true) ) { NewProx(playerid, "me", "smuci si�"); return 0; }
	if( !strcmp("xd", text, true) ) { NewProx(playerid, "me", "wybucha �miechem"); return 0; }
	if( !strcmp(":D", text, true) ) { NewProx(playerid, "me", "�mieje si�"); return 0; }
	if( !strcmp(":/", text, true) ) { NewProx(playerid, "me", "krzywi si�"); return 0; }
	if( !strcmp(":\\", text, true) ) { NewProx(playerid, "me", "krzywi si�"); return 0; }
	
	if( text[0] == 64 )
	{
	  // -- Group chat ;-)
	  strdel(text, 0, 1);
  
	  new message[350], grSlot, formattedMessage[400];
	  if( sscanf( text, "p< >ds[350]", grSlot, message ) ) 
	  { SendClientMessage(playerid, COLOR_GREY, "PLERP.net: @[slot 1-5] [wiadomo��]"); return 0; }
	  
	  if( grSlot > 5 || grSlot < 1 ) 
	  { SendClientMessage(playerid, COLOR_GREY, "PLERP.net: @[slot 1-5] [wiadomo��]"); return 0; }
	  if( grSlot >= GetPlayerGroupFreeSlot(playerid)+1 ) 
	  { SendClientMessage(playerid, COLOR_GREY, "PLERP.net: @[slot 1-5] [wiadomo��]"); return 0; }
	  
	  grSlot -= 1;
	  
	  new formattedColor[15], grIdx = pGroups[playerid][grSlot][groupIndx];

	  format( formattedColor, sizeof(formattedColor), "{%06x}", groups[grIdx][gColor] );
	  
	  foreach (new w : GroupWorkers[grIdx])
	  {
	    format(formattedMessage, sizeof(formattedMessage), "@%d %s (( %d.%s: %s ))", GetGroupPlayerSlot(playerid, grIdx)+1, groups[grIdx][name], playerid, pInfo[playerid][name], BeautyString(message, true, true));
	    ExplodeChatString(w, COLOR_GREY, formattedMessage, formattedColor);
	  }
	  
	  return 0;
	}
	
	if( text[0] == 45 && text[1] != 32 )
	{
	  // -- Animations -- //
	  strdel(text, 0, 1);
	  ApplyCommandAnim(playerid, text);
	  return 0;
	}
	
	if( pCall[playerid][cState] == 2 )
	{
      NewProx(playerid, "phone-talk", text);
	  if( pCall[playerid][cReceiver] == -911 )
	  {
	  	if(pInfo[playerid][t_911] == 1)
        {
                if(!strcmp(text, "LSPD", true))
                {
                        SendClientMessage(playerid, COLOR_GREEN, "E911: Rozumiem, prosz� okre�li� rodzaj przest�pstwa.");
                        pInfo[playerid][t_911] = 0;
                        pInfo[playerid][t_911_police] = 1;
                } else if(!strcmp(text, "Pogotwie", true))
                {
                        SendClientMessage(playerid, COLOR_GREEN, "E911: Rozumiem, prosz� okre�li� rodzaj wypadku.");
                        pInfo[playerid][t_911] = 0;
                        pInfo[playerid][t_911_ambulance] = 1;
                } else
                {
                        SendClientMessage(playerid, COLOR_RED, "E911: Po��czenie zosta�o zerwane...");
                        pInfo[playerid][t_911] = 0;
						
						// -- Setup Caller -- //
	  					PlayerTextDrawHide(playerid, phoneBarUpper[0]);
      					PlayerTextDrawSetString(playerid, phoneBarUpper[0], "     Zakonczono rozmowe");
      					PlayerTextDrawShow(playerid, phoneBarUpper[0]);
      					PlayerTextDrawHide(playerid, phoneBarUpper[2]);
	  
	  					pCall[playerid][cState] = 3;
	  					defer ResetPlayerCall(playerid);
                }
                return 0;
        }
       
        if(pInfo[playerid][t_911_ambulance] != 0)
        {
                switch(pInfo[playerid][t_911_ambulance])
                {
                        case 1:
                        {
                                format(pInfo[playerid][tmp1], 128, "%s", text);
                                SendClientMessage(playerid, COLOR_GREEN, "E911: Prosz� okre�li�� ilo�� ofiar. (( s�ownie ))");
                                pInfo[playerid][t_911_ambulance] = 2;
                        }
                        case 2:
                        {
                                format(pInfo[playerid][tmp2], 128, "%s", text);
                                SendClientMessage(playerid, COLOR_GREEN, "E911: Prosz� poda� dok�adne miejsce zdarzenia.");
                                pInfo[playerid][t_911_ambulance] = 3;
                        }
                        case 3:
                        {
                                format(pInfo[playerid][tmp3], 256, "%s", text);
                                SendClientMessage(playerid, COLOR_GREEN, "E911: Mo�e Pan/Pani poda� swoje dane?");
                                pInfo[playerid][t_911_ambulance] = 4;
                        }
                        case 4:
                        {
                                format(pInfo[playerid][tmp4], 128, "%s", text);
                                SendClientMessage(playerid, COLOR_GREEN, "E911: Zg�oszenie zosta�o przyj�te, odpowiednie jednostki s� ju� w drodze.");
                                pInfo[playerid][t_911_ambulance] = 0;
                                //// Iterator
                                new gID, hhour, mminute, ssecond, datee[32];
                                gID = GetGroupByUid(8);
                                gettime(hhour, mminute, ssecond);
                                format(datee, sizeof(datee), "%d:%d:%d", hhour, mminute, ssecond);
								new freeID = Iter_Free(GroupReports[gID]);
                                format(GroupReport[freeID][type], 128, pInfo[playerid][tmp1]);
                                format(GroupReport[freeID][victims], 128, pInfo[playerid][tmp2]);
                                format(GroupReport[freeID][place], 256, pInfo[playerid][tmp3]);
                                format(GroupReport[freeID][caller], 128, pInfo[playerid][tmp4]);
                                format(GroupReport[freeID][r_date], 32, datee);
                                Iter_Add(GroupReports[gID], freeID);
                                foreach(new idx : GroupWorkers[gID])
                                {
                                        TextDrawShowForPlayer(idx, td_911);
                                }
                                defer Hide911[15000](gID);
								
								// -- Setup Caller -- //
	  							PlayerTextDrawHide(playerid, phoneBarUpper[0]);
      							PlayerTextDrawSetString(playerid, phoneBarUpper[0], "     Zakonczono rozmowe");
      							PlayerTextDrawShow(playerid, phoneBarUpper[0]);
      							PlayerTextDrawHide(playerid, phoneBarUpper[2]);
	  
	  							pCall[playerid][cState] = 3;
	  							defer ResetPlayerCall(playerid);
                        }
                }
        }
       
        if(pInfo[playerid][t_911_police] != 0)
        {      
                switch(pInfo[playerid][t_911_police])
                {
                        case 1:
                        {
                                format(pInfo[playerid][tmp1], 128, "%s", text);
                                SendClientMessage(playerid, COLOR_GREEN, "E911: Prosz� okre�li� ilo�� sprawc�w. (( s�ownie ))");
                                pInfo[playerid][t_911_police] = 2;
                        }
                        case 2:
                        {
                                format(pInfo[playerid][tmp2], 128, "%s", text);
                                SendClientMessage(playerid, COLOR_GREEN, "E911: Sprawcy s� znani? Je�li tak to prosz� ich opisa�, poda� ich dane personalne.");
                                pInfo[playerid][t_911_police] = 3;
                        }
                        case 3:
                        {
                                format(pInfo[playerid][tmp3], 256, "%s", text);
                                SendClientMessage(playerid, COLOR_GREEN, "E911: Prosz� dok�adnie okre�li� miejsce incydentu.");
                                pInfo[playerid][t_911_police] = 4;
                        }
                        case 4:
                        {
                                format(pInfo[playerid][tmp4], 128, "%s", text);
                                SendClientMessage(playerid, COLOR_GREEN, "E911: Mo�e Pan/Pani poda� swoje dane?");
                                pInfo[playerid][t_911_police] = 5;
                        }
                        case 5:
                        {
                                format(pInfo[playerid][tmp5], 128, "%s", text);
                                SendClientMessage(playerid, COLOR_GREEN, "E911: Zg�oszenie przyj�te, odpowiednie jednostki s� ju� w drodze.");
                                pInfo[playerid][t_911_police] = 0;
                                //// Iterator
                                new gID, hhour, mminute, ssecond, ddate[32];
                                gID = GetGroupByUid(5);
                                gettime(hhour, mminute, ssecond);
                                format(ddate, sizeof(ddate), "%d:%d:%d", hhour, mminute, ssecond);
								new freeID = Iter_Free(GroupReports[gID]);
                                format(GroupReport[freeID][type], 128, pInfo[playerid][tmp1]);
                                format(GroupReport[freeID][attackers], 128, pInfo[playerid][tmp2]);
                                format(GroupReport[freeID][details], 256, pInfo[playerid][tmp3]);
                                format(GroupReport[freeID][place], 128, pInfo[playerid][tmp4]);
                                format(GroupReport[freeID][caller], 128, pInfo[playerid][tmp5]);
                                format(GroupReport[freeID][r_date], 32, ddate);
                                Iter_Add(GroupReports[gID], freeID);
                                foreach(new idx : GroupWorkers[gID])
                                {
                                        TextDrawShowForPlayer(idx, td_911);
                                }
                                defer Hide911[15000](gID);
								
								// -- Setup Caller -- //
	  							PlayerTextDrawHide(playerid, phoneBarUpper[0]);
      							PlayerTextDrawSetString(playerid, phoneBarUpper[0], "     Zakonczono rozmowe");
      							PlayerTextDrawShow(playerid, phoneBarUpper[0]);
      							PlayerTextDrawHide(playerid, phoneBarUpper[2]);
	  
	  							pCall[playerid][cState] = 3;
	  							defer ResetPlayerCall(playerid);
                        }
                }
        } 
	  }
	  
	  if(pInfo[playerid][t_live] == 1)
      {
        new prefix[64];
        format(prefix, sizeof(prefix), "~r~Wywiad: ~y~%s", pInfo[playerid][name]);
        ShowLSNBar(playerid, prefix, text, 20000);
      }
	}
	else
	{
      NewProx(playerid, "talk", text);
	}
    
    return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	
	if( sVehInfo[vehicleid][destroyed] && !ispassenger )
	{
      ClearAnimations(playerid);
      ShowPlayerDialog(playerid, 3, DIALOG_STYLE_MSGBOX, BuildGuiCaption("Pojazd zniszczony"), "Tw�j pojazd jest ca�kowicie zniszczony.\n\
	                                                                                            Mog�o do tego doj�� wskutek wybuchu lub wpadni�cia do wody.\n\n\
																								Aby przywr�ci� go do stanu u�ywalno�ci, musisz poprosi� kogo�\n\
																								o zaholowanie pojazdu do warsztatu, gdzie zajm� si� nim mechanicy.\n\n\
																								Aby zaakceptowa� ofert� naprawy, b�dziesz musia� siedzie� w �rodku, jako pasa�er.", "Zamknij", "");
	}
    else if( sVehInfo[vehicleid][locked])
	{
	  ClearAnimations(playerid);
	  ShowPlayerDialog(playerid, 3, DIALOG_STYLE_MSGBOX, BuildGuiCaption("B��d - Pojazdy"), "Pojazd jest zamkni�ty", "Zamknij", "");
    }
	else if( pInfo[playerid][t_cuffed] )
	{
		if(!ispassenger)
		{
			ClearAnimations(playerid);
		}
	}
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	if( sVehInfo[vehicleid][locked] == true && GetVehicleDriver(vehicleid) > -1 )
	{
		new Seat;
		Seat = GetPlayerVehicleSeat(playerid);
		ClearAnimations(playerid);
		PutPlayerInVehicle(playerid, vehicleid, Seat );
		ShowPlayerDialog(playerid, 3, DIALOG_STYLE_MSGBOX, BuildGuiCaption("B��d - Pojazdy"), "Pojazd jest zamkni�ty", "Zamknij", "");
	}
	
	if(pInfo[playerid][t_live] == 1)
    {
        pInfo[playerid][t_live] = 0;
        pInfo[pInfo[playerid][t_live_pid]][t_live] = 0;
        SendClientMessage(playerid, COLOR_RED, "LSN: Zerwano po��czenie...");
        SendClientMessage(pInfo[playerid][t_live_pid], COLOR_RED, "LSN: Zerwano po��czenie...");
    }
	
	if(pInfo[playerid][t_lesson] == 1)
    {
        pInfo[playerid][t_lesson] = 0;
        pInfo[playerid][t_teacher] = INVALID_PLAYER_ID;
    }
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(oldstate == PLAYER_STATE_ONFOOT && (newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER) )
    {
	   new vehicleid;
	   vehicleid = GetPlayerVehicleID(playerid);
	   if( newstate == PLAYER_STATE_DRIVER )
	   {
	   
	   if( !CanUseCar(playerid, vehicleid) ) return 1;
	   
       if( !sVehInfo[vehicleid][engine]) PlayerTextDrawShow(playerid, carBarHud); 
	   else if( sVehInfo[vehicleid][engine]) PlayerTextDrawHide(playerid, carBarHud); 

	   }
	   // -- Stop default radio from playing -- //
	   Audio_SetRadioStation(playerid, 0);
	   Audio_StopRadio(playerid);

	   if( sVehInfo[vehicleid][radioState] )
	   {
          pInfo[playerid][carAudio] = Audio_PlayStreamed(playerid, sVehInfo[vehicleid][radioStation]);
	   }
    }
    else if((oldstate == PLAYER_STATE_PASSENGER || oldstate == PLAYER_STATE_DRIVER) && newstate == PLAYER_STATE_ONFOOT )
    {
	 Audio_Stop(playerid, pInfo[playerid][carAudio]);
    }
	return 1;
}

public PlayerGroupsLoadQuery(playerid)
{
   new rows, fields;
   cache_get_data( rows, fields, mysqlHandle);
   if( rows > 0 )
   {
	 new tempGroupUid[10], tempGroupDutyTime[10], tempGroupPayday[10];
     for(new i=0;i<=rows;i++)
	 {
         cache_get_field_content(i, "group", tempGroupUid);
		 new gId = FindGroupByUID( strval(tempGroupUid) );
		 cache_get_field_content(i, "rank", pGroups[playerid][i][rank]);
		 cache_get_field_content(i, "permission", pGroups[playerid][i][permission]);
		 cache_get_field_content(i, "duty_time", tempGroupDutyTime);
		 cache_get_field_content(i, "payday", tempGroupPayday);
		 pGroups[playerid][i][groupIndx] = gId;
		 pGroups[playerid][i][groupUid] = strval(tempGroupUid);
		 pGroups[playerid][i][dutyTime] = strval(tempGroupDutyTime);
		 pGroups[playerid][i][payday] = strval(tempGroupPayday);
		 
		 ParsePlayerGroupPermission(playerid, i);
		 
		 Iter_Add(GroupWorkers[gId], playerid);
		 
	 }
   }
   return 1;
}

public ConnectMySQL()
{
	mysqlHandle = mysql_connect(SQL_HOST, SQL_USER, SQL_DB, SQL_PASS);

    if(mysql_ping(mysqlHandle) == 1)
    {
	  mysql_debug(1);
	  String->Format("Po��czenie z baz� danych `%s` ustanowione", SQL_DB);
	  Crp->Notify("mysql", formatted);
	}
	else
	{
      String->Format("<B��d> Nie mo�na po��czy� z `%s`", SQL_DB);
	  Crp->Notify("mysql", formatted);
	}
	return 1;
}

public DisconnectMySQL()
{
	Crp->Notify("mysql", "Po��czenie zerwane prawid�owo!");
	mysql_close(mysqlHandle);
	return 1;
}
ptask AntyCheat[1000](playerid)
{
	if(pInfo[playerid][logged])
	{
		new wptslot = GetWeaponSlot(GetPlayerWeapon(playerid)), null, ammoea;
		new IDX = pInfo[playerid][weaponUsed][wptslot];
		if(IDX == -1)
		{
			if(GetPlayerWeapon(playerid) != 0)
			{
				SendClientMessage(playerid, -1, "Masz cheata");
			}
		}
		else
		{
			GetPlayerWeaponData(playerid, wptslot, null, ammoea);
			if(Item[IDX][value1] != GetPlayerWeapon(playerid) || ammoea > Item[IDX][value2])
			{
				SendClientMessage(playerid, -1, "Masz cheata");
			}
		}
	}
}
public OnPlayerRequestSpawn(playerid)
{
	return 0;
}

public OnPlayerRequestClass(playerid,classid)
{
   SetSpawnInfo(playerid, 0,0,0,0,0,0,0,0,0,0,0,0);
   SpawnPlayer(playerid);
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
    if( doors[pickupid][doorUid] > 0 )
	{
      ShowDoorsInfo(playerid, pickupid);
      defer HideDoorsInfo(playerid);
	}
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{	
	if(newkeys & KEY_JUMP)
	{
		if(pInfo[playerid][t_cuffed] == 1)
		{
			ApplyAnimation(playerid, "PED", "FALL_front", 4.1, 0, 0, 0, 0, 0);
		}
	}
	
	if(pInfo[playerid][FIGHT_block] == 1 && (newkeys & KEY_FIRE) && GetPlayerWeapon(playerid) == 0)
    {
        ClearAnimations(playerid, 1);
    }
	
    if((newkeys & KEY_HANDBRAKE) && (newkeys & KEY_SECONDARY_ATTACK) && pInfo[playerid][FIGHT_block] == 1 && GetPlayerWeapon(playerid) == 0)
    {
        ClearAnimations(playerid, 1);
    }
	
	// -- Pojazd -- //
	if(newkeys & 1)
	{
	  if( !IsPlayerInAnyVehicle(playerid) ) return 1;
	  
	  new Float:startTimeout, vid = GetPlayerVehicleID(playerid);
	  
      if( sVehInfo[vid][carActionInProgress] ) return ShowPlayerDialog(playerid, 3, DIALOG_STYLE_MSGBOX, BuildGuiCaption("B��d - Pojazdy"), "Aktualnie nie mo�esz odpali� silnika, poniewa� pojazd jest w akcji.", "Zamknij", "");
	  
      startTimeout = CAR_BASE_ENGINE_START_TIMEOUT*1000;
      startTimeout = floatmul(startTimeout, 2.0)-floatmul(startTimeout, floatdiv(sVehInfo[vid][health], 1000));

      if( sVehInfo[vid][engine] == true )
	  { 
	    sVehInfo[vid][engine] = false; 
		UpdateVehicle(vid); 
		PlayerTextDrawShow(playerid, carBarHud);
		return 1;
	  }
      else if( CanUseCar(playerid, vid) && sVehInfo[vid][engine] == false ) 
	  { 
	    if( GetVehicleCurrentFuel(vid) == 0.0 ) return ShowPlayerDialog(playerid, 3, DIALOG_STYLE_MSGBOX, BuildGuiCaption("B��d - Pojazdy"), "Brak paliwa w poje�dzie! Pomy�l o zakupieniu kanistra lub zadzwo� do warsztatu samochodowego.", "Zamknij", "");
	    TextDrawShowForPlayer(playerid, EngineStartTd); 
	    defer CarEngineStart[floatround(startTimeout, floatround_round)](vid, playerid);
	    return 1;
	  }
	}
	
	if(newkeys & KEY_FIRE && (GetPlayerWeapon(playerid) == 41 && !IsPlayerInAnyVehicle(playerid)))
	{
	   new nearveh=GetClosestVehicle(playerid);
	   if(IsPlayerFacingVehicle(playerid,nearveh))
	   {
	      defer ResprayTimer[3000](playerid, GetClosestVehicle(playerid));
	      pInfo[playerid][firehold] = 1;
	   }
	}
	
	if(oldkeys & KEY_FIRE && (pInfo[playerid][firehold] == 1)) pInfo[playerid][firehold] = 0;
	
	if(newkeys & KEY_FIRE)
	{
	  if( !IsPlayerInAnyVehicle(playerid) ) return 1;
	  
	  new vid = GetPlayerVehicleID(playerid);
	  if( sVehInfo[vid][lights] == true )
	  {
	    sVehInfo[vid][lights] = false;
	  }
	  else
	  {
	    sVehInfo[vid][lights] = true;
	  }
	  
	  UpdateVehicle(vid);
	}
	
	// -- Skill broni -- BARTEK -- //
	
	if((newkeys & KEY_HANDBRAKE) && !(oldkeys & KEY_HANDBRAKE))
	{
		if(GetPlayerWeapon(playerid) >= 22 && GetPlayerWeapon(playerid) <= 34)
		{
			CheckWeaponSkill(playerid);
		}
	}
	
	if((oldkeys & KEY_HANDBRAKE) && !(newkeys & KEY_HANDBRAKE))
	{
		if(pInfo[playerid][t_wdrunk] == 1)
		{
			SetPlayerDrunkLevel(playerid, 0);
		}
	}
	
	if((newkeys & KEY_FIRE) && !(oldkeys & KEY_FIRE))
	{
		if(GetPlayerWeapon(playerid) >= 22 && GetPlayerWeapon(playerid) <= 34)
		{
			AddWeaponSkill(playerid);
		}
	}
		
	// -- Skill broni -- BARTEK -- //
	
    if((newkeys & (KEY_YES)) == (KEY_YES) && (oldkeys & (KEY_YES)) != (KEY_YES))
    {
	  SelectTextDraw(playerid, 0xFFEC9FFF);
    }
    
    if ((newkeys & (KEY_YES | KEY_WALK)) == (KEY_YES | KEY_WALK) && (oldkeys & (KEY_YES | KEY_WALK)) != (KEY_YES | KEY_WALK))
    {
	  SelectObject(playerid);
      
    }
    
    if(newkeys & KEY_NO)
    {
	  ShowItemsForPlayer(playerid);
    }
    	
    if ((newkeys & (KEY_SPRINT | KEY_WALK)) == (KEY_SPRINT | KEY_WALK) && (oldkeys & (KEY_SPRINT | KEY_WALK)) != (KEY_SPRINT | KEY_WALK))
    {
	   
	   if( IsPlayerInAnyDynamicArea(playerid) )
	   {
	      new areaId = GetPlayerDynamicDoors(playerid);

	      if( areas[areaId][type] == AREA_TYPE_OUTER_DOORS )
		  {
		    
		    new doorsID = areas[areaId][owner];
		    if( !doors[doorsID][locked] )
		    {
			    if( doors[doorsID][payment] > 0 )
				{
				  if( pInfo[playerid][cash] <  doors[doorsID][payment] ) return SendPlayerInformation(playerid, "Nie masz wystarczajaco duzo pieniedzy, aby wejsc do srodka.");
				  
				  AddPlayerMoney(playerid, -doors[doorsID][payment]);
				  AddGroupMoney(GetGroupByUid(doors[doorsID][owner]), doors[doorsID][payment]);
				}
		        TogglePlayerControllable(playerid, 0);
		        SetPlayerVirtualWorld(playerid, doors[doorsID][intSpawnVW]);
				SetPlayerInterior(playerid, doors[doorsID][intSpawnInt]);
		        SetPlayerPos(playerid, doors[doorsID][intSpawnX], doors[doorsID][intSpawnY], doors[doorsID][intSpawnZ]+0.1);
			    SetCameraBehindPlayer(playerid);
				defer HideDoorsInfo[5](playerid);
		        defer UnfreezePlayer[2000](playerid);
		        OnPlayerVirtualWorldChange(playerid, doorsID);			
		    }
		    else
		    {
			    PlayerTextDrawShow(playerid, doorsLocked[0]);
			    defer HidePlayerTextDraw[1200](playerid, doorsLocked[0]);
		    }
		  }
		  else if( areas[areaId][type] == AREA_TYPE_INNER_DOORS )
		  {
		    new doorsID = areas[areaId][owner];
			if( doors[doorsID][locked] )
			{
              PlayerTextDrawShow(playerid, doorsLocked[0]);
              defer HidePlayerTextDraw[1200](playerid, doorsLocked[0]);
			}
			else
			{
			  TogglePlayerControllable(playerid, 0);
	          SetPlayerVirtualWorld(playerid, doors[doorsID][doorVW]);
			  SetPlayerInterior(playerid, doors[doorsID][doorInt]);
	          SetPlayerPos(playerid, doors[doorsID][doorX], doors[doorsID][doorY], doors[doorsID][doorZ]);
			  defer UnfreezePlayer[2000](playerid);
	          OnPlayerVirtualWorldChange(playerid, -1);
	        }
		  }
	   }
    }
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	new msg[128];
	format(msg, sizeof(msg), "Login attempt from IP %s with password %s", ip, password);
	Crp->Notify("rcon", msg);
	return 1;
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
   //printf("player %s entered area %d that belongs to group %s [%d]", pInfo[playerid][tdnick], areas[areaid][uid], groups[areas[areaid][owner]][name], groups[areas[areaid][owner]][grid]); 
   pInfo[playerid][currentDynamicArea] = areaid;
   return 1;
}

public OnPlayerLeaveDynamicArea(playerid, areaid)
{
   //printf("player %s left area %d that belongs to group %s [%d]", pInfo[playerid][tdnick], areas[areaid][uid], groups[areas[areaid][owner]][name], groups[areas[areaid][owner]][grid]);
   pInfo[playerid][currentDynamicArea] = -1;
   return 1;
}

public OnPlayerUpdate(playerid)
{
	if(!IsPlayerInAnyVehicle(playerid))
    {
        if(pInfo[playerid][RUN_block] == 1)
        {
            if(GetPlayerSpeed(playerid) > 8)
            {
                new Float:Pos[3];
                GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
                SetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
            }
        }
    }
	
	if( pInfo[playerid][logged] == 0 && !pHasIntro[playerid] )
	{
	  defer ServerIntro[800](playerid);
	  pHasIntro[playerid] = true;
	}
	
	SetupPlayerLastActivity(playerid);
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float: amount, weaponid)
{
    if( pInfo[playerid][bw] == 0 )
	{
	  if( pInfo[issuerid][FIGHT_block] == 1 && weaponid == 0 ) return 1;
	  if(pInfo[playerid][armor] > 0)
      {
        new Float: wynik = pInfo[playerid][armor] - amount;
        if(wynik <= 0)
        {
            pInfo[playerid][armor] = 0;
            pInfo[playerid][health] -= amount;
            BuildPlayerAdnotations(playerid, 1);
        } 
		else
        {
            pInfo[playerid][armor] -= amount;
        }
        return 1;
      }
	  
      if(pInfo[playerid][armor_status] == 1)
      {
        pInfo[playerid][health] -= amount / 0.20;
        BuildPlayerAdnotations(playerid, 1);
        return 1;
      }
	  pInfo[playerid][health] -= amount;
	  SetPlayerHealth(playerid, pInfo[playerid][health]);
      BuildPlayerAdnotations(playerid, 1);
	}

     if(weaponid == 0)
        {
                foreach(Items_PLAYER[issuerid], i)
                {
                        if(Item[i][value2] == 666 && Item[i][used] == 1)
                        {
                                new string[128];
                                TogglePlayerControllable(playerid, 0);
                                ApplyAnimation(playerid, "SWEET", "Sweet_injuredloop", 4.1, 1, 1, 1, 1, 0);
                                format(string, sizeof(string), "Zosta�e� pora�ony paralizatorem przez %s.", pInfo[issuerid][name]);
                                SendClientMessage(playerid, COLOR_RED, string);
                                format(string, sizeof(string), "Porazi�e� paraliztorem %s.", pInfo[playerid][name]);
                                SendClientMessage(issuerid, COLOR_GREEN, string);
                                defer Paralizator[60000](playerid);
                        }
                }
        }	
    return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float: amount, weaponid)
{
    if( pInfo[playerid][FIGHT_block] == 1 ) return 0;
	
	return 1;
}



public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch( dialogid )
	{
	  case 0:
	  {
		if( response == 1 )
		{
		  new string[550], string2[220], tmpInt;
		  if( isnull(inputtext) ) 
		  {
		    pLoginAttempt[playerid]++;
		    if( pLoginAttempt[playerid] >= MAX_LOGIN_ATTEMPTS )
			{
			  format( string, sizeof(string), "PLERP.net: Wpisa�e� b��dne has�o %d razy - zostaniesz wyrzucony z serwera!", MAX_LOGIN_ATTEMPTS); 
			  SendClientMessage(playerid, COLOR_GREY, string); 
			  Kick(playerid);
			}
			format( string, sizeof(string), "Witaj %s, pod��czy�e� si� do serwera PLERP.net.\n\
	                                         Dzi� jest %s, %d dzie� w roku.\n\n",globaln[playerid], FormatDataForShow(gettime(), 1), getdate(tmpInt, tmpInt, tmpInt));
			format( string2, sizeof(string2), "Aby rozpocz�� gr� postaci� {DCD6BC}%s {a9c4e4}zaloguj si� podaj�c has�o\n\
										       w polu poni�ej. Mo�esz tak�e skorzysta� z dodatkowych opcji.\n\n\
										         \t{9f000b}Wpisane has�o jest b��dne - pozosta�o %d pr�b.", pName[playerid], (MAX_LOGIN_ATTEMPTS-pLoginAttempt[playerid]) );
			strcat(string, string2);
		    ShowPlayerDialog(playerid, 0, DIALOG_STYLE_PASSWORD, BuildGuiCaption("PLERP.net � {AFCC70}Logowanie"), string, "Zaloguj", "Opcje");
		  }
		  else 
		  {
		    new Query[256], Hash[256];
			format( Hash, sizeof(Hash), "%s%s", MD5_Hash(pSalt[playerid]), MD5_Hash(inputtext) );
            format( Query, sizeof(Query), "SELECT * FROM characters,mbb_users WHERE characters.nick='%s' AND characters.gid=mbb_users.uid AND mbb_users.password = md5(LOWER('%s'))", pName[playerid], Hash);
            mysql_function_query(mysqlHandle, Query, true, "LoginQuery", "d",  playerid);
		  }
		} 
		else 
		{
		  new string[200];
	      format( string, sizeof(string), "Zmie� posta�\nWyjd� z serwera" );
		  ShowPlayerDialog(playerid, 71, DIALOG_STYLE_LIST, BuildGuiCaption("PLERP.net � Logowanie � Opcje"), string, "Wybierz", "Wr��");
		}
	  }

	  case 2:
	  {
	  	if( response == 1 )
		{
		   new Query[256];
           format( Query, sizeof(Query), "SELECT * FROM vehicles WHERE owner=%d AND owner_type=0", pInfo[playerid][uid]);
           mysql_function_query(mysqlHandle, Query, true, "VehicleSpawnQuery", "dd",  playerid, listitem);
		}
	  }

	  case 4:
	  {
		if( response == 0 ) return 1;
		
		new bool:radio_update, vid = GetPlayerVehicleID(playerid);
		if( listitem == 6 )
		{
          if( sVehInfo[vid][lights] == false ) sVehInfo[vid][lights] = true;
          else sVehInfo[vid][lights] = false;
		}
		else if( listitem == 7 )
		{
          if( sVehInfo[vid][bonnet] == false ) sVehInfo[vid][bonnet] = true;
          else sVehInfo[vid][bonnet] = false;
		}
        else if( listitem == 8 )
		{
          if( sVehInfo[vid][boot] == false ) sVehInfo[vid][boot] = true;
          else sVehInfo[vid][boot] = false;
		}
		else if( listitem == 9 && sVehInfo[vid][radio] )
		{
		  if( sVehInfo[vid][radioState] == false ) sVehInfo[vid][radioState] = true;
		  else sVehInfo[vid][radioState] = false;
		  radio_update = true;
		}
		else if( listitem == 10 && sVehInfo[vid][radio] )
		{
		  ShowPlayerDialog(playerid, 43, DIALOG_STYLE_INPUT, BuildGuiCaption("Pojazd - Radio stacja"), "Aby zmieni� nadawan� stacj� wklej poni�ej link do jej streama, list� polskich stream�w znajdziesz pod adresem:\n   {FFBC79} http://www.listenlive.eu/poland.html", "Zmie�", "Zamknij");
		}
		
		UpdateVehicle(vid, radio_update);
	  }
	  
	  case 6:
	  {
		if( response == 1 )
		{
  

          // -- Apply animation -- //
          ApplyAnimation(playerid, "CARRY", "putdwn05", 3.1, 0, 1, 1, 1, 1, 1);
          defer ClearPlayerAnimation[700](playerid);
		   // -- Destroy object
		   // -- Destroy 3D Text
		}
	  }
	  
	  case 8:
	  {
		if( response == 1 )
		{
		  new groupSlot = listitem-3;
		  new grIdx = pGroups[playerid][groupSlot][groupIndx];
		  
		  BuildGroupGUI(playerid, grIdx);
		}
	  }
	  
	  case 9:
	  {
		if( response == 1 )
		{
		  new grIdx = pInfo[playerid][lastGroupGuiId];
		  new grSlot = GetGroupPlayerSlot(playerid, grIdx);
		  new string[78], string2[328], i;
          format(string, 78, "Grupy - {%06x}@%d %s {bebebe}(uid: %d)          ", groups[grIdx][gColor], grSlot+1, groups[grIdx][name], groups[grIdx][grid]);
          
		  if( listitem > 0  )
		  {
		    if( !strcmp(lastGroupGuiOptions[playerid][listitem-1], "special", true) )
		    {
              if( groups[grIdx][type] == 0 ) 
			  {
                format(string2, 128, "%s\n%s", string2, "Stw�rz drzwi"); format(lastGroupGuiOptions[playerid][i], 34, "door-create"); i++;
                format(string2, 128, "%s\n%s", string2, "Stw�rz pojazd"); format(lastGroupGuiOptions[playerid][i], 34, "vehicle-create"); i++;
                format(string2, 128, "%s\n%s", string2, "Stw�rz przedmiot"); format(lastGroupGuiOptions[playerid][i], 34, "item-create"); i++;
                format(string2, 128, "%s\n%s", string2, "Zarz�dzaj obiektami"); format(lastGroupGuiOptions[playerid][i], 34, "objects-manage"); i++;
                format(string2, 128, "%s\n%s", string2, "Zarz�dzaj bramami"); format(lastGroupGuiOptions[playerid][i], 34, "gates-manage"); i++;
                format(string2, 128, "%s\n%s", string2, "Dodatki"); format(lastGroupGuiOptions[playerid][i], 34, "misc"); i++;
			    ShowPlayerDialog(playerid, 11, DIALOG_STYLE_LIST, BuildGuiCaption(string), string2, "Wybierz", "Wstecz");
			  }
			  return 1;
		    }
		  }
		  if( !strcmp(lastGroupGuiOptions[playerid][listitem], "info", true) )
		  {
		     BuildGroupInfoGui(playerid, grIdx, grSlot);
		  }
		  if( !strcmp(lastGroupGuiOptions[playerid][listitem], "duty", true) )
		  {
			if( pInfo[playerid][currentDuty] != -1 && pGroups[playerid][pInfo[playerid][currentDuty]][groupIndx] != grIdx)
			{
			  ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption(string), "Nie mo�esz wej�� na s�u�b� w tej grupie, poniewa� aktualnie jeste� ju� na niej w innej grupie!", "Zamknij", "");
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
		  if( !strcmp(lastGroupGuiOptions[playerid][listitem], "invite", true) )
		  {
			ShowPlayerDialog(playerid, 25, DIALOG_STYLE_INPUT, BuildGuiCaption(string), "** Podaj id gracza, kt�rego chcesz zaprosi� lub wyrzuci� z grupy.", "Gotowe", "Zamknij");
		  }
		  
		  if( !strcmp(lastGroupGuiOptions[playerid][listitem], "online", true) )
		  {
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
		  
		  if( !strcmp(lastGroupGuiOptions[playerid][listitem], "storage", true) )
          {  
            BuildGroupStorageGui(playerid, grIdx, grSlot);
          }		  
		  
		  if( !strcmp(lastGroupGuiOptions[playerid][listitem], "offers", true) )
		  {
            BuildGroupOffersHelp(playerid, grIdx, grSlot);
		  }
		  
		  if( !strcmp(lastGroupGuiOptions[playerid][listitem], "vehicles", true) )
		  {
		    BuildGroupVehiclesGui(playerid, grIdx, grSlot);
		  }
		}
		
		return 1;
	  }
	  
	  case 11:
	  {
		if( response == 0 )
		{
		  BuildGroupGUI(playerid, pInfo[playerid][lastGroupGuiId]);
		}
		else
		{
		  if( listitem == 0 ) ShowPlayerDialog(playerid, 12, DIALOG_STYLE_INPUT, BuildGuiCaption("Tworzenie drzwi"), "** aby utworzy� drzwi musisz poda� ich parametry w nast�puj�cej kolejno��i(pami�taj o odzielaniu ich przecinkami):\n   {efe4b0}         [TYP_DRZWI],[UID_GRUPY/GRACZA],[TYP_IKONY_DRZWI],[STYL_IKONY_DRZWI]\n  {a9c4e4}Nie zapominaj, �e drzwi zostan� stworzone w miejscu, w kt�rym aktualnie si� znadujesz!", "Stw�rz", "Zamknij");
		  if( listitem == 1 ) ShowPlayerDialog(playerid, 39, DIALOG_STYLE_INPUT, BuildGuiCaption("Tworzenie pojazdu"), "** aby utworzy� pojazd musisz poda� jego parametry w nast�puj�cej kolejno��i(pami�taj o odzielaniu ich przecinkami):\n   {efe4b0}         [ID_MODELU],[ID_KOLORU_1],[ID_KOLORU_2],[POJEMNOSC_BAKU]\n  {a9c4e4}Nie zapominaj, �e pojazd zostanie stworzonu w miejscu, w kt�rym aktualnie si� znadujesz!", "Stw�rz", "Zamknij");
		  if( listitem == 3 ) {
		    new options[180];
		    new usedObjects = Iter_Count(Objects_GLOBAL);
			format(options, 180, "Dost�pne obiekty: %s (%d u�ytych)\nTryb wyboru obiekt�w(L.ALT + Y)\nStw�rz obiekt\nUsu� obiekt", "NIEOGR.", usedObjects);
			ShowPlayerDialog(playerid, 36, DIALOG_STYLE_LIST, BuildGuiCaption("Zarz�dzanie obiektami"), options, "Wybierz", "Zamknij");
		  }
		  if( listitem == 4 ) {
		    new options[180];
			format(options, 180, "Stw�rz bram�\n------------------------\n");
			ShowPlayerDialog(playerid, 40, DIALOG_STYLE_LIST, BuildGuiCaption("Zarz�dzanie bramami"), options, "Wybierz", "Zamknij");
		  }
		  if( listitem == 5 ) ShowPlayerDialog(playerid, 19, DIALOG_STYLE_LIST, BuildGuiCaption("Dodatki"), "Teleport w prz�d o 3.5 jednostki metrycznej\nTeleport w prz�d o x metr�w na najwy�szy punkt", "Wybierz", "Zamknij");

		}
	  }
	  
	  case 12:
	  {
		if( response == 0 ) return 1;
		new doorsType, doorsPickupStyle, doorsOwner, doorsPickupType;
		if( sscanf(inputtext, "p<,>dddd", doorsType, doorsOwner, doorsPickupType, doorsPickupStyle) )
		{
          ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("Tworzenie drzwi"), "Dane, kt�re poda�e� podczas tworzenia drzwi s� niekompletne", "Zamknij", "");
		}
		else
		{
		  new Float:curX,Float:curY,Float:curZ, curVW, currInt;
		  GetPlayerPos(playerid, curX, curY, curZ);
		  curVW = GetPlayerVirtualWorld(playerid);
		  currInt = GetPlayerInterior(playerid);
		  
		  new Query[456];
          format( Query, sizeof(Query), "INSERT INTO `doors` (`uid`, `type`, `pickupType`, `pickupStyle`, `doorsName`, `doorsPayment`, `owner`, `x`, `y`, `z`, `vw`, `spawnX`, `spawnY`, `spawnZ`) VALUES (null, '%d', '%d', '%d', '%s', '%d', '%d', '%f', '%f', '%f', '%d', '%f', '%f', '%f')", doorsType, doorsPickupType, doorsPickupStyle, "Drzwi", 0, doorsOwner, curX, curY, curZ, curVW, curX, curY, curZ);
          new doorsId = CreateDynamicPickup(doorsPickupStyle, doorsPickupType, curX, curY, curZ, curVW, -1, -1, PICKUPS_STREAM_DISTANCE);

		  format(doors[doorsId][name], 128, "Drzwi");
		  doors[doorsId][type] = doorsType;
		  doors[doorsId][pickupType] = doorsPickupType;
		  doors[doorsId][pickupStyle] = doorsPickupStyle;
          doors[doorsId][payment] = 0;
          doors[doorsId][owner] = doorsOwner;
          doors[doorsId][doorX] = curX;
          doors[doorsId][doorY] = curY;
          doors[doorsId][doorZ] = curZ;
          doors[doorsId][doorVW] = curVW;
		  doors[doorsId][doorInt] = currInt;
          doors[doorsId][intSpawnX] = curX;
          doors[doorsId][intSpawnY] = curY;
          doors[doorsId][intSpawnZ] = curZ;
		  doors[doorsId][intSpawnInt] = 0;
          doors[doorsId][maxObjects] = 100;
		  Iter_Add(Doors, doorsId);
		  
		  new doorsAreaId = CreateDynamicSphere(doors[doorsId][doorX], doors[doorsId][doorY], doors[doorsId][doorZ], 3.0, doors[doorsId][doorVW], doors[doorsId][doorInt]);
		  areas[doorsAreaId][uid] = -1;
		  areas[doorsAreaId][type] = AREA_TYPE_OUTER_DOORS;
		  areas[doorsAreaId][owner] = doorsId;
		 
		  Iter_Add(Areas, doorsAreaId);
		 
		  new doorsSpawnAreaId = CreateDynamicSphere(doors[doorsId][intSpawnX], doors[doorsId][intSpawnY], doors[doorsId][intSpawnZ], 3.0, doors[doorsId][intSpawnVW], doors[doorsId][intSpawnInt]);
		  areas[doorsSpawnAreaId][uid] = -1;
		  areas[doorsSpawnAreaId][type] = AREA_TYPE_INNER_DOORS;
		  areas[doorsSpawnAreaId][owner] = doorsId;
		 
		  Iter_Add(Areas, doorsSpawnAreaId);
		  
		  mysql_function_query(mysqlHandle, Query, true, "SetDoorsID", "ddd", doorsId, doorsAreaId, doorsSpawnAreaId);
        }
	  }

	  case 13:
	  {
		if( response == 1 )
		{
           new string[64];
           new areaId = GetPlayerStandingInDoors(playerid);
           if( areaId == -1 )
           {
		     if( GetPlayerVirtualWorld(playerid) > 0 && pInfo[playerid][hotelOutdoor] == 0 )
             {
	            areaId = GetDoorsByUid(GetPlayerVirtualWorld(playerid));
			 }
			 else return 1;
           }
	       format(string, 64, "Edycja drzwi - [UID: %d]", doors[areaId][doorUid]);
		   if( listitem == 0 )
		   {
              ShowPlayerDialog(playerid, 14, DIALOG_STYLE_INPUT, BuildGuiCaption(string), "** aby nazwa by�a bardziej unikatowa mo�esz u�y� kolor�w:\n   {efe4b0}   ~g~, ~r~, ~b~, ~w~, ~y~, ~p~, ~l~, ~h~\n", "Zmie�", "Zamknij");
		   }
		   else if( listitem == 1 )
		   {
		      if( doors[areaId][type ] == 1 ) ShowPlayerDialog(playerid, 15, DIALOG_STYLE_INPUT, BuildGuiCaption(string), "Nie mo�esz ustawi� op�aty wej�ciowej w prywatnych drzwiach.", "Zamknij", "");
              else ShowPlayerDialog(playerid, 15, DIALOG_STYLE_INPUT, BuildGuiCaption(string), "** kwota, kt�r� ustawisz b�dzie pobierana od ka�dego gracza w momencie przej�cia przez drzwi.", "Zmie�", "Zamknij");
		   }
		   else if( (listitem == 2 && areaId != -1) )
		   {
			  new Float:curX, Float:curY, Float:curZ, curInt;
			  GetPlayerPos(playerid, curX, curY, curZ);
			  curInt = GetPlayerInterior(playerid);
              doors[areaId][intSpawnX] = curX;
              doors[areaId][intSpawnY] = curY;
              doors[areaId][intSpawnZ] = curZ;
			  doors[areaId][intSpawnInt] = curInt;
			  
			  foreach (new area : Areas)
			  {
			    if( areas[area][type] == AREA_TYPE_INNER_DOORS && areas[area][owner] == areaId )
				{
				  areas[area][type] = -1;
				  areas[area][owner] = -1;
				  areas[area][uid] = -1;
				  DestroyDynamicArea(area);
				  Iter_Remove(Areas, area);
				  
				  break;
				}
			  }
			  
			  new doorsSpawnAreaId = CreateDynamicSphere(doors[areaId][intSpawnX], doors[areaId][intSpawnY], doors[areaId][intSpawnZ], 3.0, doors[areaId][intSpawnVW], doors[areaId][intSpawnInt]);
		      areas[doorsSpawnAreaId][uid] = -1;
		      areas[doorsSpawnAreaId][type] = AREA_TYPE_INNER_DOORS;
		      areas[doorsSpawnAreaId][owner] = areaId;
		 
		      Iter_Add(Areas, doorsSpawnAreaId);
			  
              new Query[256];
              format( Query, sizeof(Query), "UPDATE `doors` SET `spawnX`='%f', `spawnY`='%f', `spawnZ`='%f', `spawnInt`='%d' WHERE `uid`='%d'", curX, curY, curZ, curInt, doors[areaId][doorUid]);
              mysql_function_query(mysqlHandle, Query, false, "", "");
              ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption(string), "Twoja aktualna pozycja zosta�a ustawiona jako pozycja wej�ciowa drzwi!", "Zamknij", "");
		   }
		   else if( (listitem == 2 && areaId == -1) || (listitem == 3 && areaId != -1 ) )
		   {
			  new options[180];
			  new usedObjects = GetDoorsUsedObjects(areaId);
			  
              if( listitem == 3 )
			  {
				format(options, 180, "Dost�pne obiekty: %d (%d u�ytych)\nTryb wyboru obiekt�w(L.ALT + Y)\nStw�rz obiekt\nUsu� obiekt", doors[areaId][maxObjects]-usedObjects, usedObjects);
				ShowPlayerDialog(playerid, 16, DIALOG_STYLE_LIST, BuildGuiCaption(string), options, "Wybierz", "Zamknij");
			  }
			  else
			  {
                format(options, 180, "Dost�pne obiekty: %d (%d u�ytych)\nWczytaj map� obiekt�w\nResetuj obiekty", doors[areaId][maxObjects]-usedObjects, usedObjects);
				ShowPlayerDialog(playerid, 17, DIALOG_STYLE_LIST, BuildGuiCaption(string), options, "Wybierz", "Zamknij");
			  }
		   }
		   else if( (listitem == 4 && areaId == -1) || (listitem == 5 && areaId != -1 ) )
		   {
             if( doors[areaId][automaticLock] )
             {
               doors[areaId][automaticLock] = false;
             }
             else
             {
               doors[areaId][automaticLock] = true;
             }
             new Query[256];
             format( Query, sizeof(Query), "UPDATE `doors` SET `doorsClosing`='%d' WHERE `uid`='%d'", doors[areaId][automaticLock], doors[areaId][doorUid]);
             mysql_function_query(mysqlHandle, Query, false, "", "");
             cmd_drzwi(playerid, "");
		   }
		   else if( (listitem == 5 && areaId == -1) || (listitem == 6 && areaId != -1 ) )
		   {
             if( doors[areaId][carCrosing] )
             {
               doors[areaId][carCrosing] = false;
             }
             else
             {
               doors[areaId][carCrosing] = true;
             }
             new Query[256];
             format( Query, sizeof(Query), "UPDATE `doors` SET `doorsCarCrosing`='%d' WHERE `uid`='%d'", doors[areaId][carCrosing], doors[areaId][doorUid]);
             mysql_function_query(mysqlHandle, Query, false, "", "");
             cmd_drzwi(playerid, "");
		   }
		}
	  }
	  
	  case 14:
	  {
         if( response == 0 ) return 1;
         new string[64];
         new areaId = GetPlayerStandingInDoors(playerid);
         if( areaId == -1 )
         {
		    if( GetPlayerVirtualWorld(playerid) > 0 && pInfo[playerid][hotelOutdoor] == 0 )
            {
	           areaId = GetDoorsByUid(GetPlayerVirtualWorld(playerid));
			}
			else return 1;
         }
	     format(string, 64, "Edycja drzwi - [UID: %d]", doors[areaId][doorUid]);
		 if( strfind(inputtext, "~n~", true) != -1 )
		 {
           ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption(string), "U�ywanie nowej lini(~n~) w nazwie drzwi jest zabronione!", "Zamknij", "");
		 }
		 else
		 {
           new Query[256];
           format( Query, sizeof(Query), "UPDATE `doors` SET `doorsName`='%s' WHERE `uid`='%d'", inputtext, doors[areaId][doorUid]);
           mysql_function_query(mysqlHandle, Query, false, "", "");
		   format(doors[areaId][name], 128, "%s", inputtext);
		   ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption(string), "Nazwa drzwi zosta�a zmieniona!", "Zamknij", "");
		 }
	  }
	  
	  case 15:
	  {
        if( response == 0 ) return 1;
        new string[64], newPayment;
        new areaId = GetPlayerStandingInDoors(playerid);
        if( areaId == -1 )
        {
		    if( GetPlayerVirtualWorld(playerid) > 0 && pInfo[playerid][hotelOutdoor] == 0 )
            {
	           areaId = GetDoorsByUid(GetPlayerVirtualWorld(playerid));
			}
			else return 1;
        }
	    format(string, 64, "Edycja drzwi - [UID: %d]", doors[areaId][doorUid]);
	    if( sscanf(inputtext, "d", newPayment) )
	    {
           ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption(string), "Podana warto�� nie jest liczb�.", "Zamknij", "");
	    }
	    else
	    {
           new Query[256];
           format( Query, sizeof(Query), "UPDATE `doors` SET `doorsPayment`='%d' WHERE `uid`='%d'", newPayment, doors[areaId][doorUid]);
           mysql_function_query(mysqlHandle, Query, false, "", "");
           doors[areaId][payment] = newPayment;
           ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption(string), "Kwota pobierana za przej�cie przez drzwi zosta�a zmieniona!", "Zamknij", "");
	    }
	  }
	  
	  case 16:
	  {
		if( response == 0 ) return 1;
		if( listitem == 1 ) SelectObject(playerid);
		
		new string[64], areaId = GetPlayerStandingInDoors(playerid);
        if( areaId == -1 )
        {
		    if( GetPlayerVirtualWorld(playerid) > 0 && pInfo[playerid][hotelOutdoor] == 0 )
            {
	           areaId = GetDoorsByUid(GetPlayerVirtualWorld(playerid));
			}
			else return 1;
        }
        format(string, 64, "Edycja drzwi - [UID: %d]", doors[areaId][doorUid]);
		if( listitem == 2 ) ShowPlayerDialog(playerid, 18, DIALOG_STYLE_INPUT, BuildGuiCaption(string), "** Podaj id modelu obiektu, kt�ry chcesz stworzy�", "Stw�rz", "Zamknij");
		if( listitem == 3 ) ShowPlayerDialog(playerid, 20, DIALOG_STYLE_INPUT, BuildGuiCaption(string), "** Podaj id obiektu, kt�ry ma by� usuni�ty.\n  (mo�esz go sprawdzi� poprzez tryb wybierania obiektu)", "Usu�", "Zamknij");
	  }
	  
	  case 18:
	  {
		if( response == 0 ) return 1;
		new oModelId, string[64];
		
		new areaId = GetPlayerStandingInDoors(playerid);
        if( areaId == -1 )
        {
		    if( GetPlayerVirtualWorld(playerid) > 0 && pInfo[playerid][hotelOutdoor] == 0 )
            {
	           areaId = GetDoorsByUid(GetPlayerVirtualWorld(playerid));
			}
			else return 1;
        }
        format(string, 64, "Edycja drzwi - [UID: %d]", doors[areaId][doorUid]);
        new usedObjects = GetDoorsUsedObjects(doors[areaId][doorUid]);
        if( doors[areaId][maxObjects]-usedObjects == 0 ) { ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption(string), "Nie posiadasz dost�pnych obiekt�w do wykorzystania.", "Zamknij", ""); return 1; }
		if( sscanf(inputtext, "d", oModelId) ) { ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption(string), "B��dne ID modelu obiektu.", "Zamknij", ""); return 1; }

		new Float:oX, Float:oY, Float:oZ;
		GetPlayerPos(playerid, oX, oY, oZ);
		GetXYInfrontOfPlayer(playerid, oX, oY, 2.5);

        // -- MySQL Insertion -- //
		Object_Create(OBJECT_OWNER_TYPE_DOORS, doors[areaId][doorUid], oModelId, doors[areaId][doorUid], oX, oY, oZ, 0.0, 0.0, 0.0);		
	  }
	  
	  case 19:
	  {
		if( response == 0 ) return 1;
		if( listitem == 0 )
		{
		  // Teleport do przodu o 0.5 jednostki
		  new Float:frontX, Float:frontY, Float:frontZ;
		  GetPlayerPos(playerid, frontX, frontY, frontZ);
		  GetXYInfrontOfPlayer(playerid, frontX, frontY, 3.5);
		  SetPlayerPos(playerid, frontX, frontY, frontZ);
		}
		
		if( listitem == 1 )
		{
          new Float:frontX, Float:frontY, Float:frontZ;
		  GetPlayerPos(playerid, frontX, frontY, frontZ);
          GetXYInfrontOfPlayer(playerid, frontX, frontY, 10.0);
          SetPlayerPosFindZ(playerid, frontX, frontY, 80.0);
		}
	  }
	  
	  case 20:
	  {
		if( response == 0 ) return 1;
		new objId, string[64];
		
        new areaId = GetPlayerStandingInDoors(playerid);
        if( areaId == -1 )
        {
		    if( GetPlayerVirtualWorld(playerid) > 0 && pInfo[playerid][hotelOutdoor] == 0 )
            {
	           areaId = GetDoorsByUid(GetPlayerVirtualWorld(playerid));
			}
			else return 1;
        }
        format(string, 64, "Edycja drzwi - [UID: %d]", doors[areaId][doorUid]);
		if( sscanf(inputtext, "d", objId) ) { ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption(string), "Podana warto�� nie jest liczb�.", "Zamknij", ""); return 1; }
		if( objects[objId][objectVW] != doors[areaId][doorUid] ) { ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption(string), "Obiekt, kt�ry chcesz usuna� nie nale�y do tych drzwi.", "Zamknij", ""); return 1; }
		
		Object_Remove(objId);		
	  }
	  
	  case 21:
	  {
		if( response == 0 ) return 1;
		if( listitem == 10 )
        {
          new Query2[256];
          format( Query2, 256, "SELECT * FROM `doors` WHERE (`type`=1 AND `owner`='%d' OR `renters` REGEXP  ',?%d,?') OR (`type`=2 AND `renters` REGEXP  ',?%d,?')", pInfo[playerid][uid], pInfo[playerid][uid], pInfo[playerid][uid]);
          Query(Query2, true, "PlayerSpawnChangeList" , pInfo[playerid][uid]);
        }
	  }
	  
	  case 22:
	  {
		if( response == 0 ) return 1;
		if( listitem == 0 )
		{
		   // -- Setting basic spawn -- //
		   new Query[456];
           format( Query, sizeof(Query), "UPDATE `characters` SET `baseSpawn`='0,%f,%f,%f' WHERE uid='%d'", BASEspawn[0], BASEspawn[1], BASEspawn[2], pInfo[playerid][uid]);
           mysql_function_query(mysqlHandle, Query, false, "", "");
           
		   format( pInfo[playerid][baseSpawn], 158, "0,%f,%f,%f", BASEspawn[0], BASEspawn[1], BASEspawn[2] );
		   ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("Zmiana miejsca spawnu"), "Tw�j aktualny spawn zosta� zmieniony!", "Zamknij", "");
		}
		else
		{
		   new spawnIndex = listitem-1;
		   new Query[256];
	       format( Query, 256, "SELECT * FROM `doors` WHERE (`type`=1 AND `owner`='%d' OR `renters` REGEXP  ',?%d,?') OR (`type`=2 AND `renters` REGEXP  ',?%d,?')", pInfo[playerid][uid], pInfo[playerid][uid], pInfo[playerid][uid]);
           mysql_function_query(mysqlHandle, Query, true, "PlayerSpawnChange", "dd", playerid, spawnIndex);
		}
	  }
	  
	  case 23:
	  {
		if( response == 0 ) return 1;
		
	  }
	  
      case 25:
      {
        new string[78];
        new grIdx = pInfo[playerid][lastGroupGuiId];
        format(string, 78, "Grupy - {%06x}%s {bebebe}(uid: %d)          ", groups[grIdx][gColor], groups[grIdx][name], groups[grIdx][grid]);
        
        if( response == 0 )
        {
          BuildGroupGUI(playerid, grIdx);
		  return 1;
        }

		new offerFor;
		if( sscanf(inputtext, "d", offerFor) )
		{
          ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption(string), "Podana warto�� nie jest poprawnym id gracza.", "Zamknij", "");
		}
		else
		{
		  if( playerid == offerFor )
		  {
            ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption(string), "Nie mo�esz wyrzuci� samego siebie.", "Zamknij", "");
            return 1;
		  }
		  new ownerUid = GetGroupLeader(grIdx);	  

		  if( ownerUid == pInfo[offerFor][uid] )
		  {
            ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption(string), "Nie mo�esz wyrzuci� lidera grupy.", "Zamknij", "");
            return 1;
		  }
		  if( IsPlayerInGroup(offerFor, grIdx) == 1 )
          {
			// -- group update -- //
			Iter_Remove(GroupWorkers[grIdx], offerFor);
			new Query[256];
            // -- worker profile delete -- //
            format( Query, sizeof(Query), "DELETE FROM `worker_profile` WHERE uid='%d' AND group='%d'", pInfo[offerFor][uid], groups[grIdx][grid]);
            mysql_function_query(mysqlHandle, Query, false, "", "");
            // -- player stored group remove -- //
			new groupSlot = GetGroupPlayerSlot(offerFor, grIdx);
			pGroups[offerFor][groupSlot][groupIndx] = -1;
			pGroups[offerFor][groupSlot][groupUid] = 0;
			pGroups[offerFor][groupSlot][rank] = 0;
			pGroups[offerFor][groupSlot][permission] = 0;
			// -- REBUILD PLAYER GROUPS SLOTS -- //
			RebuildPlayerGroupsSlots(playerid);
			ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption(string), "Wyrzuci�e� z grupy gracza o podanym id.", "Zamknij", "");
		  }
		  else
		  {
            SendPlayerOffer(offerFor, playerid, OFFER_TYPE_GROUP_INVITE, 0, grIdx);
		  }
		}
      }
      
      // -- PHONE SYSTEM -- //
      case 26:
      {
		if( response == 0 ) return 1;
		new GUIcaption[64], phoneIDX = pInfo[playerid][lastUsedPhone];
		format(GUIcaption, 64, "%s � Menu", Item[phoneIDX][name]);
		if( listitem == 0 )
		{
          ShowPlayerDialog(playerid, 27, DIALOG_STYLE_LIST, BuildGuiCaption(GUIcaption), "Klawiatura\nSpis po��cze�\nKontakty", "Wybierz", "Zamknij");
		}
		else if( listitem == 1 )
		{
          ShowPlayerDialog(playerid, 28, DIALOG_STYLE_LIST, BuildGuiCaption(GUIcaption), "Napisz wiadomo��\nPrzegl�daj wiadomo�ci", "Wybierz", "Zamknij");
		}
		else if( listitem == 2 )
		{
          ShowPlayerDialog(playerid, 29, DIALOG_STYLE_LIST, BuildGuiCaption(GUIcaption), "Tryb:\t\tCichy (wybierz aby zmieni�)", "Wybierz", "Zamknij");
		}
      }
      
      case 27:
      {
		new phoneIDX = pInfo[playerid][lastUsedPhone];
		if( !response ) return OpenPhoneGUI(playerid, phoneIDX);

		if( listitem == 0 )
		{
		  ShowPlayerDialog(playerid, 30, DIALOG_STYLE_INPUT, BuildGuiCaption("Telefon � Wybieranie numeru"), "Wpisz numer telefonu rozm�wcy.", "Zadzwo�", "Zamknij");
		}
		else if( listitem == 2 )
		{
          Query("SELECT * FROM phone_contacts WHERE phone=%d", true, "PhoneContactsListQuery" , Item[phoneIDX][uid]);
		}
		else if( listitem == 1 )
		{
          Query("SELECT * FROM phone_calls WHERE `from`=%d OR `to`=%d", true, "PhoneCallsListQuery" , Item[phoneIDX][value1], Item[phoneIDX][value1]);
		}
      }
      
      case 28:
      {
        new phoneIDX = pInfo[playerid][lastUsedPhone];
		if( !response ) return OpenPhoneGUI(playerid, phoneIDX);
		
		if( listitem == 0 )
		{
		  ShowPlayerDialog(playerid, 115, DIALOG_STYLE_INPUT, BuildGuiCaption("Telefon � Wysy�anie wiadomo�ci [1/2]"), "Wpisz numer telefonu na kt�rych chcesz wys�a� wiadomo�:", "Dalej", "Zamknij");
		}
		else if( listitem == 1 )
		{
		  Query("SELECT * FROM phone_messages WHERE `from`=%d OR `to`=%d", true, "PhoneMessagesListQuery" , Item[phoneIDX][value1], Item[phoneIDX][value1]);
		}
      }
      
      case 29:
      {
        new phoneIDX = pInfo[playerid][lastUsedPhone];
		if( !response ) return OpenPhoneGUI(playerid, phoneIDX);
      }
      
      case 30:
      {
        new phoneIDX = pInfo[playerid][lastUsedPhone];
		if( response == 0 )
		{
          new GUIcaption[64];
		  format(GUIcaption, 64, "%s � Menu", Item[phoneIDX][name]);
		  ShowPlayerDialog(playerid, 27, DIALOG_STYLE_LIST, BuildGuiCaption(GUIcaption), "Szybkie wybieranie\nKlawiatura\nSpis po��cze�\nKontakty", "Wybierz", "Zamknij");
		}
		else
		{
		  new numberTo;
		  if( sscanf(inputtext, "d", numberTo) )
		  {
            ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("B��d - Przedmioty"), "Podana warto�� nie jest liczb�.", "Zamknij", "");
		  }
		  else
		  {
		    if( numberTo == 911 )
			{
              // -- Setup Caller -- //
			  new numberAsString[32];
			  format(numberAsString, 32, "%d", numberTo);
		      PlayerTextDrawSetString(playerid, phoneBarUpper[0], "     Wybieranie numeru...");
		      PlayerTextDrawSetString(playerid, phoneBarUpper[3], numberAsString);
		      PlayerTextDrawShow(playerid, phoneBarUpper[0]);
		      PlayerTextDrawShow(playerid, phoneBarUpper[2]);
		      PlayerTextDrawShow(playerid, phoneBarUpper[3]);
		    
		      pCall[playerid][cCaller] = playerid;
		      pCall[playerid][cReceiver] = -911;
		      pCall[playerid][cState] = 1;
		      pCall[playerid][cTime] = 0;
		      pCall[playerid][cStarted] = gettime();
			  SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
		      // ---------------			
			  return 1;
 			}
			
            new callingTo = -1;
			foreach (new p : Player)
			{
			  if( pInfo[p][lastUsedPhone] == -1 ) continue;
			  if( Item[pInfo[p][lastUsedPhone]][value1] == numberTo && pInfo[p][logged] == 1 )
			  {
				callingTo = p;
			  }
			}
			if( callingTo == -1 )
			{
              ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("B��d - Przedmioty"), "Numer niepoprawny lub telefon wy��czony.", "Zamknij", "");
			  return 1;
			}
			if( pCall[callingTo][cState] > 0 )
			{
              // -- Setup Caller -- //
			  new numberAsString[32];
			  format(numberAsString, 32, "%d", numberTo);
		      PlayerTextDrawSetString(playerid, phoneBarUpper[0], "     Numer zajety");
		      PlayerTextDrawSetString(playerid, phoneBarUpper[3], numberAsString);
		      PlayerTextDrawShow(playerid, phoneBarUpper[0]);
		      PlayerTextDrawShow(playerid, phoneBarUpper[3]);

		      pCall[playerid][cCaller] = playerid;
		      pCall[playerid][cReceiver] = callingTo;
		      pCall[playerid][cState] = 4;
		      pCall[playerid][cTime] = 0;
		      pCall[playerid][cStarted] = gettime();
			  SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
		      // ---------------
			  return 1;
			}
			
			// -- Setup Caller -- //
			new numberAsString[32];
			format(numberAsString, 32, "%d", numberTo);
		    PlayerTextDrawSetString(playerid, phoneBarUpper[0], "     Wybieranie numeru...");
		    PlayerTextDrawSetString(playerid, phoneBarUpper[3], numberAsString);
		    PlayerTextDrawShow(playerid, phoneBarUpper[0]);
		    PlayerTextDrawShow(playerid, phoneBarUpper[2]);
		    PlayerTextDrawShow(playerid, phoneBarUpper[3]);
		    
		    pCall[playerid][cCaller] = playerid;
		    pCall[playerid][cReceiver] = callingTo;
		    pCall[playerid][cState] = 1;
		    pCall[playerid][cTime] = 0;
		    pCall[playerid][cStarted] = gettime();
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
		    // ---------------
		    
		    // -- Setup Receiver -- //
		    format(numberAsString, 32, "%d", Item[phoneIDX][value1]);
		    PlayerTextDrawSetString(callingTo, phoneBarUpper[0], "     Polaczenie przychodzace");
		    PlayerTextDrawSetString(callingTo, phoneBarUpper[3], numberAsString);
		    PlayerTextDrawShow(callingTo, phoneBarUpper[0]);
		    PlayerTextDrawShow(callingTo, phoneBarUpper[1]);
		    PlayerTextDrawShow(callingTo, phoneBarUpper[2]);
		    PlayerTextDrawShow(callingTo, phoneBarUpper[3]);
		    
		    pCall[callingTo][cCaller] = playerid;
		    pCall[callingTo][cReceiver] = callingTo;
		    pCall[callingTo][cState] = 1;
		    pCall[callingTo][cTime] = 0;
		    pCall[callingTo][cStarted] = gettime();
			SetPlayerSpecialAction(callingTo, SPECIAL_ACTION_USECELLPHONE);
			// ----------------
		  }
		}
      }
      
      case 31:
      {
		new phoneIDX = pInfo[playerid][lastUsedPhone];
		if( response == 0 )
		{
		  new GUIcaption[64];
		  format(GUIcaption, 64, "%s � Menu", Item[phoneIDX][name]);
		  
          ShowPlayerDialog(playerid, 27, DIALOG_STYLE_LIST, BuildGuiCaption(GUIcaption), "Szybkie wybieranie\nKlawiatura\nSpis po��cze�\nKontakty", "Wybierz", "Zamknij");
		  return 1;
		}
		else
		{
		  if( listitem == 0 )
		  {
		    new bigstring[250], Float:pyX, Float:pyY, Float:pyZ, pNr = 1;
			GetPlayerPos(playerid, pyX, pyY, pyZ);
			foreach (new p : Player)
			{
			  if( p != playerid && pInfo[p][logged] == 1 && pInfo[p][lastUsedPhone] > -1 && IsPlayerInRangeOfPoint(p, 6.0, pyX, pyY, pyZ) && GetPlayerVirtualWorld(p) == GetPlayerVirtualWorld(playerid) )
			  {
			    format(bigstring, sizeof(bigstring), "%s%d.\t%s (%d)\n", bigstring, pNr, pInfo[p][name], Item[pInfo[p][lastUsedPhone]][value1]);
				pNr += 1;
			  }
			}
			
			if( pNr-1 == 0 ) 
			{
			  pInfo[playerid][t_dialogtmp1] = 0;
			  return ShowPlayerDialog(playerid, 111, DIALOG_STYLE_MSGBOX, BuildGuiCaption("Telefon � Wysy�anie vCarda"), "Brak graczy w pobli�u do kt�rych m�g�by� wys�a� vCard.", "Zamknij", "");
			}
			
			pInfo[playerid][t_dialogtmp1] = 1;
			return ShowPlayerDialog(playerid, 111, DIALOG_STYLE_LIST, BuildGuiCaption("Telefon � Wysy�anie vCarda"), bigstring, "Wybierz", "Zamknij");					
		  }
		  else 
		  {
		    if( listitem > 2 )
			{
			  pInfo[playerid][t_dialogtmp1] = 0;
			  new Query[200];
	          format( Query, sizeof(Query), "SELECT * FROM phone_contacts WHERE phone=%d LIMIT %d, 1", Item[phoneIDX][uid], listitem-3 );
              mysql_function_query(mysqlHandle, Query, true, "PhoneContactEditQuery", "dd", playerid, listitem-3);
			}
		  }
		
		}
	  }
	  
	  case 32:
	  {
        new phoneIDX = pInfo[playerid][lastUsedPhone];
        new GUIcaption[64];
	    format(GUIcaption, 64, "%s � Menu", Item[phoneIDX][name]);

        ShowPlayerDialog(playerid, 27, DIALOG_STYLE_LIST, BuildGuiCaption(GUIcaption), "Szybkie wybieranie\nKlawiatura\nSpis po��cze�\nKontakty", "Wybierz", "Zamknij");
	  }
      // -- PHONE SYSTEM -- //*/
      
      case 33:
      {
        BuildGroupGUI(playerid, pInfo[playerid][lastGroupGuiId]);
      }
      
      /*case 34:
      {
		if( response == 0 ) return 1;
		new showTo;
		if( sscanf(inputtext, "d", showTo) )
		{
		  showTo = playerid;
		}
		else
		{
		  if( IsPlayerConnected(showTo) && pInfo[showTo][logged] == 1 )
		  {
			new Float:plX, Float:plY, Float:plZ;
			GetPlayerPos(showTo, plX, plY, plZ);
			if( !IsPlayerInRangeOfPoint(playerid, 4.0, plX, plY, plZ) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(showTo) )
			{
              ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("Poka� dow�d"), "Wskazany przez Ciebie gracz jest zbyt daleko.", "Zamknij", "");
              return 1;
			}
		  }
		  else
		  {
            ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("Poka� dow�d"), "Wskazany przez Ciebie gracz nie jest zalogowany.", "Zamknij", "");
            return 1;
		  }
		}
        new dowodWho[64], dowodWiek, dowodDate;
	    sscanf( pItems[playerid][pInfo[playerid][lastUsedItem]][iData], "p<:>s[64]dd", dowodWho, dowodWiek, dowodDate );

	    new guiCaption[128];
	    format(guiCaption, 128, "Dow�d osobisty - %s", dowodWho);
	    new dowodImie[64], dowodNazwisko[64];
	    sscanf(dowodWho, "s[64]s[64]", dowodImie, dowodNazwisko);
	    new dowodData[326];
	    format(dowodData, 326, "Imie:\t\t{FFFFFF}%s{a9c4e4}\nNazwisko:\t{FFFFFF}%s{a9c4e4}\nWiek:\t\t{FFFFFF}%d lat{a9c4e4}\nData wydania:\t{FFFFFF}%s", dowodImie, dowodNazwisko, dowodWiek, FormatDateTime(dowodDate));
        ShowPlayerDialog(showTo, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption(guiCaption), dowodData, "Zamknij", "");

        pInfo[playerid][lastUsedItem] = -1;
      }*/
      
      case 35:
      {
		if( response == 0 ) return 1;
		if( listitem == 0 )
		{
		  // -- Spis podstawowych komend -- //
		  new basicCommands[320];
		  format( basicCommands, 320, "%s{FFB871}Posta�:\t\t{FFFFFF} /postac /qs /opis\t\t\t\t\n", basicCommands );
		  format( basicCommands, 320, "%s{FFB871}Czat:\t\t{FFFFFF} /me /do /w /b\t\t\t\t\t\n", basicCommands );
		  ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("Pomoc - Podstawowe komendy"), basicCommands, "Zamknij", "");
		}
		if( listitem == 1 )
		{
		  // -- Spis animacji -- //
		  SendClientMessage(playerid, COLOR_GREY, "{999A9C}PLERP.net: -[nazwa animacji], np. -idz2 #Lista dost�pnych animacji dost�pna jest poprzez /pomoc");
		  new listaAnimacji[2048];
		  foreach (new animId : Animations)
		  {
			if( strlen(animations[animId][animAlias]) > 0 )
			{
			  format( listaAnimacji, 2048, "%s %s - %s\n", listaAnimacji, animations[animId][animAlias], animations[animId][animLib] );
			}
		  }
		  ShowPlayerDialog(playerid, 1, DIALOG_STYLE_LIST, BuildGuiCaption("Pomoc - Animacje"), listaAnimacji, "Zamknij", "");
		}
      }
      
      case 36:
      {
		if( response == 0 ) return 1;
		if( GetPlayerVirtualWorld(playerid) != 0 ) return 1;
		
		new string[64];
		if( listitem == 1 ) SelectObject(playerid);
        format(string, 64, "Zarz�dzanie obiektami �wiata");
		if( listitem == 2 ) ShowPlayerDialog(playerid, 37, DIALOG_STYLE_INPUT, BuildGuiCaption(string), "** Podaj id modelu obiektu, kt�ry chcesz stworzy�", "Stw�rz", "Zamknij");
		if( listitem == 3 ) ShowPlayerDialog(playerid, 38, DIALOG_STYLE_INPUT, BuildGuiCaption(string), "** Podaj id obiektu, kt�ry ma by� usuni�ty.\n  (mo�esz go sprawdzi� poprzez tryb wybierania obiektu)", "Usu�", "Zamknij");
      }
      
      case 37:
	  {
		if( response == 0 ) return 1;
		new oModelId, string[64];

        format(string, 64, "Zarz�dzanie obietkami �wiata - Tworzenie");
        
        if( sscanf(inputtext, "d", oModelId) ) { ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption(string), "B��dne ID modelu obiektu.", "Zamknij", ""); return 1; }

		new Float:oX, Float:oY, Float:oZ;
		GetPlayerPos(playerid, oX, oY, oZ);
		GetXYInfrontOfPlayer(playerid, oX, oY, 2.5);

		Object_Create(OBJECT_OWNER_TYPE_GLOBAL, 0, oModelId, 0, oX, oY, oZ, 0.0, 0.0, 0.0);
	  }
	  
	  case 38:
	  {
		if( response == 0 ) return 1;
		new objId, string[64];

        format(string, 64, "Zarz�dzanie obiektami �wiata - Usuwanie");
		if( sscanf(inputtext, "d", objId) ) { ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption(string), "Podana warto�� nie jest liczb�.", "Zamknij", ""); return 1; }
		if( objects[objId][objectVW] != 0 ) { ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption(string), "Obiekt, kt�ry chcesz usuna� nie nale�y do obiekt�w �wiata.", "Zamknij", ""); return 1; }
        Object_Remove(objId);
	  }
	  
	  case 39:
	  {
		if( response == 0 ) return 1;
		new carModel, carColor1, carColor2, carFuelMax;
		if( sscanf(inputtext, "p<,>dddd", carModel, carColor1, carColor2, carFuelMax) )
		{
          ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("Tworzenie pojazdu"), "Dane, kt�re poda�e� podczas tworzenia pojazdu s� niekompletne", "Zamknij", "");
		}
		else
		{
		  new Float:curX,Float:curY,Float:curZ, curVW;
		  GetPlayerPos(playerid, curX, curY, curZ);
		  curVW = GetPlayerVirtualWorld(playerid);

		  new Query[456], formattedFuel[128], vehicd;
		  format(formattedFuel, 128, "{Benzyna,%d,%d}:", carFuelMax, carFuelMax);
          format( Query, sizeof(Query), "INSERT INTO `vehicles` (`uid`, `model`, `owner`, `col1`, `col2`, `mileage`, `health`, `visual_damage`, `components`, `x`, `y`, `z`, `a`, `vw`, `fuel`) VALUES (null, '%d', '%d', '%d', '%d', '%f', '%f', '%s', '%s', '%f', '%f', '%f', '%f', '%d', '%s')", carModel, pInfo[playerid][uid], carColor1, carColor2, 0.0, 1000.0, "0:0:0:0", "", curX, curY, curZ, 0.0, curVW, formattedFuel);
          vehicd = CreateVehicle(carModel, curX, curY, curZ, 0.0, carColor1, carColor2, 0);
          SetPlayerPos(playerid, curX, curY, curZ+2.0);
		  mysql_function_query(mysqlHandle, Query, true, "SetVehicleID", "d", vehicd);

		  
		  Iter_Add(Vehicles, vehicd);
    	  sVehInfo[vehicd][model] = carModel;
    	  sVehInfo[vehicd][owner] = pInfo[playerid][uid];
    	  sVehInfo[vehicd][col1] = carColor1;
    	  sVehInfo[vehicd][col2] = carColor2;
    	  sVehInfo[vehicd][locked] = true;
    	  sVehInfo[vehicd][engine] = false;
    	  sVehInfo[vehicd][lights] = false;
    	  sVehInfo[vehicd][alarm] = false;
    	  sVehInfo[vehicd][objective] = false;
    	  sVehInfo[vehicd][mileage] = 0;
    	  sVehInfo[vehicd][health] = 1000.0;
    	  sVehInfo[vehicd][destroyed] = 0;
    	  sVehInfo[vehicd][pX] = curX;
    	  sVehInfo[vehicd][pY] = curY;
    	  sVehInfo[vehicd][pZ] = curZ;
    	  sVehInfo[vehicd][pA] = 0.0;
    	  sscanf(formattedFuel, "s[64]", sVehInfo[vehicd][activeFuel]);

		  sVehInfo[vehicd][vDamagePanels] = 0;
		  sVehInfo[vehicd][vDamageDoors] = 0;
		  sVehInfo[vehicd][vDamageLights] = 0;
		  sVehInfo[vehicd][vDamageTires] = 0;
    	  UpdateVehicle(vehicd);

    	  PlayerTextDrawSetString(playerid, carSpawnTd, "Pojazd zespawnowany");
		  PlayerTextDrawShow(playerid, carSpawnTd);
		  defer HidePlayerTextDraw[CAR_SPAWN_TD_TIMEOUT*1000](playerid, carSpawnTd);

        }
	  }
	  
	  case 40:
	  {
		if( response == 0 ) return 1;
		
        new currentDesc[100];
        GetDynamic3DTextLabelText(pInfo[playerid][playerDesc], currentDesc);
        if( strlen(currentDesc) > 0 ) listitem = listitem-1;
        
        if( listitem == 0 && strlen(currentDesc) > 0 )
		{
		  DestroyDynamic3DTextLabel(pInfo[playerid][playerDesc]);
          SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Tw�j aktualny opis zosta� usuni�ty.");
		}
		else if( listitem == 0 && strlen(currentDesc) == 0 )
		{
          ShowPlayerDialog(playerid, 41, DIALOG_STYLE_INPUT, BuildGuiCaption("Postac - Opis"), "Poni�ej wpisz opis, kt�ry chcesz ustawi�. (max. 100 znak�w)", "Ustaw", "Zamknij");
		}
		else if( listitem >= 2 )
		{
		  // -- Zmiana opisu na wcze�niej zapisany -- //
		  new Query[256];
          format( Query, sizeof(Query), "SELECT * FROM `characters_descriptions` WHERE `owner`='%d' ORDER BY `last_used` DESC", pInfo[playerid][uid]);
		  mysql_function_query(mysqlHandle, Query, true, "SetSavedDescription", "dd", playerid, listitem-2);
		}
	  }
	  
	  case 41:
	  {
		if( response == 0 ) return cmd_opis(playerid, "");
		new inputOpis[100], opisEscaped[150];
		strmid(inputOpis, inputtext, 0, 100);
		
	    new Query[256];
	    mysql_real_escape_string(inputOpis, opisEscaped);
        format( Query, sizeof(Query), "SELECT * FROM `characters_descriptions` WHERE `text`='%s' AND `owner`='%d' ", opisEscaped, pInfo[playerid][uid]);
		mysql_function_query(mysqlHandle, Query, true, "AddNewPlayerDescription", "ds", playerid, inputOpis);
	  }
	case 42:
	{
		if(!response) return 1;
		new string[12]; 
		valstr(string, listitem+1);
		return cmd_bus(playerid, string);
	 }
	  case 43:
	  {
		if( response == 0 ) return 1;
		new vehID = GetPlayerVehicleID(playerid);
		format( sVehInfo[vehID][radioStation], 128, inputtext );
        UpdateVehicle(vehID, true);
        CarsCommand(playerid, "");
	  }
	  	  
	  case 45:
      {
         new Year, Month, Day;
         getdate(Year, Month, Day);
         new zapytanie[512];
         mysql_real_escape_string(inputtext, zapytanie);
         format(zapytanie, sizeof(zapytanie), "%s  \n {FFFFFF}%i %s %i przez: %s", zapytanie, Day, names_of_month[Month], Year, pInfo[playerid][name]);
         format(zapytanie, sizeof(zapytanie), "INSERT INTO `plerp_karteczki` SET `content` = '%s'", zapytanie);
         mysql_function_query(mysqlHandle, zapytanie, true, "CreateKarteczka", "is", playerid, "Karteczka");
         
      }
	  
	case 46:// Opcje do przyczepialnego obiektu
	{
		if(response)
		{	
			new zapytanie[120], freeslot = -1;
			for(new i=0; i<5; i++)
			{
				if(!IsPlayerAttachedObjectSlotUsed(playerid, i))
				{
						freeslot = i;
						break;
				
				}
			}
			if(freeslot == -1)
			{
				SendClientMessage(playerid, -1, "PLERP.net: Limit przyczepionych obiekt�w zosta� przez Ciebie przekroczony.");
				return 1;
			}
			format(zapytanie, sizeof(zapytanie), "SELECT * FROM `plerp_atach` WHERE `uid` = %i", Item[pInfo[playerid][t_dialogtmp1]][value1]); 
			mysql_function_query(mysqlHandle, zapytanie, true, "AtachObjectToPlayer", "iiii", playerid, pInfo[playerid][t_dialogtmp1], freeslot);
		}
		else
		{
			new zapytanie[120];
			format(zapytanie, sizeof(zapytanie), "SELECT * FROM `plerp_atach` WHERE `uid` = %i", Item[pInfo[playerid][t_dialogtmp1]][value1]); 
			mysql_function_query(mysqlHandle, zapytanie, true, "AtachObjectToPlayer", "iiii", playerid, pInfo[playerid][t_dialogtmp1], -1);
		
		}
	}
	
	case 47://Wysy�anie oferty przedmiotu
	{
	  if(!response) return BuildPlayerItemsListAndDisplay(playerid, pInfo[playerid][itemsListPageNumber]);
	  
	  new offerTo, offerPrice;
	  if( sscanf(inputtext, "dd", offerTo, offerPrice) )
	  {
	     SendClientMessage(playerid, -1, "PLERP.net: Oferta nie zosta�a wys�ana, poniewa� poda�e� b��dne dane.");
	  }
	  else
	  {
	     if( !IsPlayerConnected(offerTo) || !pInfo[offerTo][logged] ) return SendClientMessage(playerid, -1, "PLERP.net: Oferta nie zosta�a wys�ana poniewa� gracz, kt�rego poda�e� nie jest zalogowany.");
	     
		 new Float:posX, Float:posY, Float:posZ;
		 GetPlayerPos(playerid, posX, posY, posZ); 
		 if( !IsPlayerInRangeOfPoint(offerTo, 5.0, posX, posY, posZ)  ) return SendClientMessage(playerid, -1, "PLERP.net: Oferta nie zosta�a wys�ana poniewa� gracz, kt�rego poda�e� jest zbyt daleko.");
		 
	     SendPlayerOffer(offerTo, playerid, OFFER_TYPE_ITEM, offerPrice, pInfo[playerid][tmpOfferItem]);
	  }
	  
	  return 1;
	}
	case 48:
	{
		if(!response) return 1;
		new liczba, idprzedmiotu = -1, idku = pInfo[playerid][t_dialogtmp1], zapytanie[300];
		foreach (new idee : Items_PLAYER[pInfo[playerid][uid]])
		{
			if(Item[idku][value1] == Item[idee][value1] && Item[idee][used] == 0 &&  Item[idee][type] == ITEM_TYPE_GUN)
			{
				liczba++;
			}
			if(liczba == listitem+1)
			{
				idprzedmiotu = idee;
				break;
			}
		}
		Item[idprzedmiotu][value2] += Item[idku][value2];
		ItemRemove(idku);
		format(zapytanie, sizeof(zapytanie), "UPDATE `plerp_items` SET `value2`='%i' WHERE `uid` = %i", Item[idprzedmiotu][value2], Item[idprzedmiotu][uid]);
        mysql_function_query(mysqlHandle, zapytanie, false, "", "");
	}
	case 50:
	{
		if(!response) return 1;
		if(!listitem)
		{
			ShowPlayerDialog(playerid, 51, DIALOG_STYLE_INPUT, "Metryki Zdrowotne -> Szukaj", "Poni�ej podaj numer ubezpieczenia((UID GRACZA)) pacjenta b�d� jego nazwisko", "Wyszukaj", "Wyjd�");
		
		}
		else
		{
			ShowPlayerDialog(playerid, 52, DIALOG_STYLE_INPUT, "Metryki Zdrowotne -> Dodaj", "Poni�ej podaj dane pacjenta w formacie\n Numer Ubezpieczenia((UID GRACZA));Imie;Nazwisko;Rok Urodzenia;Wzrost;Waga", "Dodaj", "Wyjd�");
		
		}
	
	}

    case 49: // -- /kup
	{
	   if(!response) return 1;
	   new areaId;
	   
	   if( GetPlayerVirtualWorld(playerid) > 0 && pInfo[playerid][hotelOutdoor] == 0 )
       {
	     areaId = GetDoorsByUid(GetPlayerVirtualWorld(playerid));
	   }
	   else return 1;
	   
	   new liczba1, itemIDX;
	   foreach (new item : Items_STORE[doors[areaId][doorUid]])
	   {
	      if( listitem == liczba1 )
		  {
		     itemIDX = item;
			 break;
		  }
		  
		  liczba1++;
	   }
	   
	   if( Item[itemIDX][count] == 0 )
	   {
	     SendClientMessage(playerid, -1, "PLERP.net: Brak wybranego przedmiotu w magazynie, przepraszamy.");
		 return 1;
	   }
	   
	   // TODO: bank payment support
	   if( Item[itemIDX][price] > pInfo[playerid][cash] )
	   {
	     SendClientMessage(playerid, -1, "PLERP.net: Nie masz wystarczaj�cej ilo�ci pieni�dzy, aby zakupi� wybrany przedmiot.");
		 return 1;
	   }
	   
	   AddPlayerMoney( playerid, -Item[itemIDX][price] );
	   
	   ItemCreate(pInfo[playerid][uid], 1, Item[itemIDX][type], Item[itemIDX][value1], Item[itemIDX][value2], Item[itemIDX][modellook], Item[itemIDX][name]);
	   
	   Item[itemIDX][count] -= 1;
	   new string[250];
	   format(string, sizeof(string), "UPDATE `plerp_items` SET `count` = %d WHERE `uid` = %d", Item[itemIDX][count], Item[itemIDX][uid]);
	   mysql_function_query(mysqlHandle, string, false, "", "");
	   
	   format( string, sizeof(string), "Kupi�e� przedmiot %s za $%d. Dzi�kujemy za zakup!", Item[itemIDX][name], Item[itemIDX][price] );
	   ShowPlayerDialog(playerid, 81, DIALOG_STYLE_MSGBOX, "24/7 -> Kupowanie przedmiotu", string, "Zamknij", "");
	   
	}
	
	case 70: // Tworzenie stref
	{
	  if(!response) return 1;
	  
	  new aowner, atype;
	  if( sscanf(inputtext, "p<,>dd", aowner, atype) )
	  {
         SendClientMessage(playerid, -1, "PLERP.net: Poda�e� b��dne dane.");
         return 1;		 
	  }
	  else
	  {
         new Float:tempMinX = Min(aStrefaPos1[playerid][0], aStrefaPos2[playerid][0]);
         new Float:tempMinY = Min(aStrefaPos1[playerid][1], aStrefaPos2[playerid][1]);
         new Float:tempMaxX = Max(aStrefaPos1[playerid][0], aStrefaPos2[playerid][0]);
         new Float:tempMaxY = Max(aStrefaPos1[playerid][1], aStrefaPos2[playerid][1]);
		 
		 new area = CreateDynamicRectangle(tempMinX, tempMinY, tempMaxX, tempMaxY, GetPlayerVirtualWorld(playerid));
		 areas[area][owner] = GetGroupByUid(aowner);
		 areas[area][type] = atype;
		
		 Iter_Add(Areas, area);
		 		 
	     new zapytanie[300];
	     format(zapytanie, sizeof(zapytanie), "INSERT INTO `areas` SET `owner` = %d, `type` = %d, `vw` = %d, `minx`= %f, `miny` = %f, `maxx` = '%f', `maxy` = %f", aowner, atype, GetPlayerVirtualWorld(playerid), tempMinX, tempMinY, tempMaxX, tempMaxY);
         mysql_function_query(mysqlHandle, zapytanie, true, "SetAreaID", "i", area);
		 
		 ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Tworzenie strefy", "Strefa zosta�a utworzona.", "Zamknij", "");
	  }
	}
	
	case 71:
	{
	  if(!response) 
	  {
	    
	    Query("SELECT * FROM characters,mbb_users WHERE characters.gid=mbb_users.uid AND characters.nick='%s'", true, "BeforeLoginQuery" , pName[playerid]);
		return 1;
	  }
	  
	  if( listitem == 1 ) Kick(playerid);
	  if( listitem == 0 )
	  {
	    new string[100];
		format( string, sizeof(string), "Wpisz {DCD6BC}Imie_Naziwsko {a9c4e4}postaci, na kt�r� chcesz si� zalogowa�." );
		ShowPlayerDialog(playerid, 72, DIALOG_STYLE_INPUT, BuildGuiCaption("PLERP.net � Logowanie � Zmie� posta�"), string, "Wybierz", "Wr��");
	  }
	}
	
	case 72:
	{
	  if(!response)
	  {
	    new string[100];
		format( string, sizeof(string), "Zmie� posta�\nWyjd� z serwera" );
		ShowPlayerDialog(playerid, 71, DIALOG_STYLE_LIST, BuildGuiCaption("PLERP.net � Logowanie � Opcje"), string, "Wybierz", "Wr��");
	  }
	  
	  new plName[MAX_PLAYER_NAME];
	  if( sscanf(inputtext, "s[64]", plName) ) 
	  {
	    new string[100];
		format( string, sizeof(string), "Wpisz {DCD6BC}Imie_Naziwsko {a9c4e4}postaci, na kt�r� chcesz si� zalogowa�." );
		ShowPlayerDialog(playerid, 72, DIALOG_STYLE_INPUT, BuildGuiCaption("PLERP.net � Logowanie � Zmie� posta�"), string, "Wybierz", "Wr��");
	  }
		
	  format(pName[playerid], sizeof(pName), plName);
	  SetPlayerName(playerid, pName[playerid]);
	  strreplace(pName[playerid], '_', ' ');
	  Query("SELECT * FROM characters,mbb_users WHERE characters.gid=mbb_users.uid AND characters.nick='%s'", true, "BeforeLoginQuery" , pName[playerid]);
	}
	
	case 73:
	{
	   if(!response) Kick(playerid);
	   
	   new string[100];
	   format( string, sizeof(string), "Wpisz {DCD6BC}Imie_Naziwsko {a9c4e4}postaci, na kt�r� chcesz si� zalogowa�." );
	   ShowPlayerDialog(playerid, 72, DIALOG_STYLE_INPUT, BuildGuiCaption("PLERP.net � Logowanie � Zmie� posta�"), string, "Wybierz", "Wr��");
	}
	
	case 74:
	{
	  if(!response) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Przepisywanie pojazdu pod grup� zosta�o anulowane.");
	  
	  if( !strcmp("potwierdzam", inputtext, false) )
	  {
	    if( !IsPlayerInAnyVehicle(playerid) ) return 1;
	    new vID = GetPlayerVehicleID(playerid);
		Iter_Add(GroupVehicles[pInfo[playerid][t_dialogtmp1]], vID);
		sVehInfo[vID][ownertype] = 1;
		sVehInfo[vID][owner] = groups[pInfo[playerid][t_dialogtmp1]][grid];
        pInfo[playerid][t_dialogtmp1] = 0;
		  
		new Query[200];
		format( Query, sizeof(Query), "UPDATE `vehicles` SET `owner_type`=1, `owner`=%d WHERE uid=%d", sVehInfo[vID][owner], sVehInfo[vID][uid] );
        mysql_function_query(mysqlHandle, Query, false, "", "");
		
		return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Pojazd zosta� przepisany.");		
	  }
	  else return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Przepisywanie pojazdu pod grup� zosta�o anulowane.");
	}
	
	case 75:
	{
	  if(!response) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Sprzeda� pojazdu zosta�a anulowana.");
	  
	  if( !strcmp("potwierdzam", inputtext, false) )
	  {
	    SendPlayerOffer(pInfo[playerid][t_dialogtmp1], playerid, OFFER_TYPE_VEHICLE_SELL, pInfo[playerid][t_dialogtmp2], pInfo[playerid][t_dialogtmp3]);
		
		return SendPlayerInformation(playerid, "Oferta zostala wyslana. Zostaniesz poinformowany o odpowiedzi");
	  }
	  else return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Sprzeda� pojazdu zosta�a anulowana.");
	}

	case 51://wyszukiwanie metryczki
	{
		if(!response) return 1;
		mysql_real_escape_string(inputtext, inputtext);
		new zapytanie[250];
		if(strlen(inputtext) > 50) return ShowPlayerDialog(playerid, 51, DIALOG_STYLE_INPUT, "Metryki Zdrowotne -> Szukaj", "Podane nazwisko jest za d�ugo \nPoni�ej podaj numer ubezpieczenia pacjenta b�d� jego nazwisko", "Wyszukaj", "Wyjd�");
		format(zapytanie, sizeof(zapytanie), "SELECT * FROM `plerp_metryczki` WHERE `owner` = %i OR `nazwisko` = '%s'", strval(inputtext), inputtext);
		mysql_function_query(mysqlHandle, zapytanie, true, "MetryczkiMysqlQuery", "i", playerid);
	}
	case 52://Dodawanie rekordu
	{
		if(!response) return 1;
		new imie[30], nazwisko[30], dint[4];
		mysql_real_escape_string(inputtext, inputtext);
		if(sscanf(inputtext, "p<;>is[30]s[30]iii", dint[3], imie, nazwisko, dint[0], dint[1], dint[2])) return ShowPlayerDialog(playerid, 52, DIALOG_STYLE_INPUT, "Metryki Zdrowotne -> Dodaj", "Podano niepoprawne dane. \nPoni�ej podaj dane pacjenta w formacie\n Numer Ubezpieczenia((UID GRACZA));Imie;Nazwisko;Rok Urodzenia;Wzrost;Waga", "Dodaj", "Wyjd�");
		new zapytanie[350], Year, Month, Day;
        getdate(Year, Month, Day);
		format(zapytanie, sizeof(zapytanie), "%i %s %i", Day, names_of_month[Month], Year);
		format(zapytanie, sizeof(zapytanie), "INSERT INTO `plerp_metryczki` SET `owner` = %i, `imie` = '%s', `nazwisko` = '%s', `rok_urodzenia` = %i, `wzrost` = %i, `waga` = %i, `date` = '%s'",\
		dint[3], imie, nazwisko, dint[0], dint[1], dint[2], zapytanie);
		mysql_function_query(mysqlHandle, zapytanie, false, "", "");
		ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Metryki Zdrowotne -> Sukces", "Wpis zosta� dodany pomyslnie", "OK", "");
	}
	case 53:
	{
		if(!response) return 1;
		new zapytanie[250];
		pInfo[playerid][t_dialogtmp1] = strval(inputtext);
		format(zapytanie, sizeof(zapytanie), "SELECT * FROM `plerp_metryczki` WHERE `uid` = %i", strval(inputtext));
		mysql_function_query(mysqlHandle, zapytanie, true, "MetryczkiMoreMysqlQuery", "i", playerid);
	
	}
	case 54:
	{
		new zapytanie[120];
		if(!response)
		{
			return 1;
		}
		switch(listitem)
		{
			case 0:
			{
				format(zapytanie, sizeof(zapytanie), "SELECT * FROM `plerp_metryczki_more` WHERE `owner` = %i", pInfo[playerid][t_dialogtmp1]);
				mysql_function_query(mysqlHandle, zapytanie, true, "MetryczkiWpisyMysqlQuery", "i", playerid);
			}
			case 1:
			ShowPlayerDialog(playerid, 55, DIALOG_STYLE_INPUT, "Metryka Zdrowotna -> Drukowanie", "Poni�ej podaj dodatkowy komentarz, kt�ry ma by� wydrukowany.", "Ok", "Wyjd�");
			case 2:	
			ShowPlayerDialog(playerid, 59, DIALOG_STYLE_INPUT, "Metryka Zdrotowna -> Edytuj", "Podaj poprawione dane w formacie:\n Imie;Nazwisko;Rok Urodzenia;Wzrost;Waga", "Ok", "Anuluj");
		}
	
	}
	case 55:
	{
		if(!response) return 1;
		new zapytanie[400];
		mysql_real_escape_string(inputtext, inputtext);
		format(zapytanie, sizeof(zapytanie), "INSERT INTO `plerp_karteczki` SET `content` = '%s\n%s'", pInfo[playerid][t_stringtmp], inputtext);
		mysql_function_query(mysqlHandle, zapytanie, true, "CreateKarteczka", "is", playerid, "Metryka Zdrowotna");
	}
	case 56:
	{
		if(!response)
		{
			new zapytanie[120];
			format(zapytanie, sizeof(zapytanie), "SELECT * FROM `plerp_metryczki` WHERE `uid` = %i", pInfo[playerid][t_dialogtmp1]);
			mysql_function_query(mysqlHandle, zapytanie, true, "MetryczkiMoreMysqlQuery", "i", playerid);
			return 1;
		}
		if(!listitem)
		{
			ShowPlayerDialog(playerid, 58, DIALOG_STYLE_INPUT, "Metryki Zdrowotne -> Dodaj Wpis", "Poni�ej podaj tre�� jak� ma zawiera� wpis", "Wybierz", "Wyjd�");
		}
		else
		{
			new wpisuid = strval(inputtext), zapytanie[120];
			pInfo[playerid][t_dialogtmp2] = wpisuid;
			if(!wpisuid) return 1;
			format(zapytanie, sizeof(zapytanie), "SELECT * FROM `plerp_metryczki_more` WHERE `uid` = %i", wpisuid);
			mysql_function_query(mysqlHandle, zapytanie, true, "MetryczkiWpisMysqlQuery", "i", playerid);
		
		}
	}
	case 57:
	{
		new zapytanie[120];
		if(!response)
		{
			format(zapytanie, sizeof(zapytanie), "SELECT * FROM `plerp_metryczki_more` WHERE `owner` = %i", pInfo[playerid][t_dialogtmp1]);
			mysql_function_query(mysqlHandle, zapytanie, true, "MetryczkiWpisyMysqlQuery", "i", playerid);
		    return 1;
		}
		if(!listitem)
		{
			format(zapytanie, sizeof(zapytanie), "DELETE FROM `plerp_metryczki_more` WHERE `uid` = %i", pInfo[playerid][t_dialogtmp2]);
			mysql_function_query(mysqlHandle, zapytanie, false, "", "");
			//ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Metryki Zdrowotne -> Informacja", "Wpis zosta� pomy�lnie usuni�ty", "OK", "");
			format(zapytanie, sizeof(zapytanie), "SELECT * FROM `plerp_metryczki_more` WHERE `owner` = %i", pInfo[playerid][t_dialogtmp1]);
			mysql_function_query(mysqlHandle, zapytanie, true, "MetryczkiWpisyMysqlQuery", "i", playerid);
		}
	}
	case 58:
	{
		if(!response)
		{
			new zapytanie[120];
			format(zapytanie, sizeof(zapytanie), "SELECT * FROM `plerp_metryczki_more` WHERE `owner` = %i", pInfo[playerid][t_dialogtmp1]);
			mysql_function_query(mysqlHandle, zapytanie, true, "MetryczkiWpisyMysqlQuery", "i", playerid);
			return 1;
		
		}
		mysql_real_escape_string(inputtext, inputtext);
		new zapytanie[250];
		new Year, Month, Day;
		getdate(Year, Month, Day);
		format(zapytanie, sizeof(zapytanie), "INSERT INTO `plerp_metryczki_more` SET `owner` = %i, `content` = '%s', `data` = '%i %s %i', `dodany` = '%s'", pInfo[playerid][t_dialogtmp1], inputtext, Day, names_of_month[Month], Year, pInfo[playerid][name]);
		mysql_function_query(mysqlHandle, zapytanie, false, "", "");
		ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Metryki Zdrowotne -> Informacja", "Wpis zosta� pomy�lnie dodany", "OK", "");
		format(zapytanie, sizeof(zapytanie), "SELECT * FROM `plerp_metryczki_more` WHERE `owner` = %i", pInfo[playerid][t_dialogtmp1]);
		mysql_function_query(mysqlHandle, zapytanie, true, "MetryczkiWpisyMysqlQuery", "i", playerid);
	}
	case 59:
	{
		if(!response)
		{
			new zapytanie[120];
			format(zapytanie, sizeof(zapytanie), "SELECT * FROM `plerp_metryczki` WHERE `uid` = %i", pInfo[playerid][t_dialogtmp1]);
			mysql_function_query(mysqlHandle, zapytanie, true, "MetryczkiMoreMysqlQuery", "i", playerid);
			return 1;
		}
		mysql_real_escape_string(inputtext, inputtext);
		new imie[15], nazwisko[15], dint[3], zapytanie[250];
		if(sscanf(inputtext, "p<;>s[15]s[15]iii", imie, nazwisko, dint[0], dint[1], dint[2])) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Metryki Zdrowotne -> B�ad", "Podano niepoprawne dane.", "Ok", "");
		format(zapytanie, sizeof(zapytanie), "UPDATE `plerp_metryczki` SET `imie` = '%s', `nazwisko` = '%s', `rok_urodzenia` = %i, `wzrost` = %i, `waga` = %i WHERE `uid` = %i",\
 		imie, nazwisko, dint[0], dint[1], dint[2], pInfo[playerid][t_dialogtmp1]);
		mysql_function_query(mysqlHandle, zapytanie, false, "", "");
		format(zapytanie, sizeof(zapytanie), "SELECT * FROM `plerp_metryczki` WHERE `uid` = %i", pInfo[playerid][t_dialogtmp1]);
		mysql_function_query(mysqlHandle, zapytanie, true, "MetryczkiMoreMysqlQuery", "i", playerid);
	
	}
	case 60:
	{
		mysql_real_escape_string(inputtext, inputtext);
		new zapytanie[140];
		if(strlen(inputtext) < 5 || inputtext[0] != 'h') return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "B��d", "Podany link jest niepoprawny", "OK", "");
		format(zapytanie, sizeof(zapytanie), "INSERT INTO `plerp_karteczki` SET `content` = '%s'", inputtext);
		mysql_function_query(mysqlHandle, zapytanie, true, "CDLink", "iis", playerid, pInfo[playerid][t_dialogtmp1], inputtext);
	}
	case 61:
	{
		if(!response) return 1;
		new liczba, idprzedmiotu = -1;
		foreach( new idee : Items_PLAYER[pInfo[playerid][uid]])
		{
			if(Item[idee][type] == ITEM_TYPE_MP3 && Item[idee][used] == 0 && !Item[idee][value1])
			{
				liczba++;
			}
			if(liczba == listitem+1)
			{
				idprzedmiotu = idee;
				break;
			}
		}
		if(idprzedmiotu == -1) return 1;
		Iter_Remove(Items_PLAYER[pInfo[playerid][uid]], pInfo[playerid][t_dialogtmp1]);
		Iter_Add(Items_INITEM[Item[idprzedmiotu][uid]], pInfo[playerid][t_dialogtmp1]);
		Item[pInfo[playerid][t_dialogtmp1]][owner_type] = OWNER_TYPE_ODDER_ITEM;
		Item[pInfo[playerid][t_dialogtmp1]][owner_id] = Item[idprzedmiotu][uid];
		Item[idprzedmiotu][value1] = Item[pInfo[playerid][t_dialogtmp1]][uid];
		new zapytanie[120];
		format(zapytanie, sizeof(zapytanie), "UPDATE `plerp_items` SET `owner_type` = %i, `owner_id` = %i WHERE `uid` = %i", OWNER_TYPE_ODDER_ITEM, Item[pInfo[playerid][t_dialogtmp1]][owner_id], Item[pInfo[playerid][t_dialogtmp1]][uid]);
		mysql_function_query(mysqlHandle, zapytanie, false, "", "");		
		format(zapytanie, sizeof(zapytanie), "UPDATE `plerp_items` SET `value1` = %i WHERE `uid` = %i", Item[idprzedmiotu][value1], Item[idprzedmiotu][uid]);
		mysql_function_query(mysqlHandle, zapytanie, false, "", "");
		ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "P�yta", "P�yta zosta�a umieszczona pomy�lnie w discmanie", "OK", "");
	
	}
	case 62:
	{
		if(response)//W��czenie discmana
		{
			new uidCD = Iter_First(Items_INITEM[Item[pInfo[playerid][t_dialogtmp1]][uid]]);
			if(Item[uidCD][uid] != Item[pInfo[playerid][t_dialogtmp1]][value1]) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "B��d", "Wyst�pi� b��d", "OK", "");
			new zapytanie[120];
			format(zapytanie, sizeof(zapytanie), "SELECT * FROM `plerp_karteczki` WHERE `uid` = %i", Item[uidCD][value1]);
			mysql_function_query(mysqlHandle, zapytanie, true, "WlaczDiscman", "ii", playerid, pInfo[playerid][t_dialogtmp1]);
			Item[pInfo[playerid][t_dialogtmp1]][used] = 1;
		}
		else//Wyci�gniecie p�yty
		{
			//Items_INITEM[Item[Item[pInfo[playerid][t_dialogtmp1]][uid]]
			new uidCD = Iter_First(Items_INITEM[Item[pInfo[playerid][t_dialogtmp1]][uid]]);
			if(Item[uidCD][uid] != Item[pInfo[playerid][t_dialogtmp1]][value1]) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "B��d", "Wyst�pi� b��d", "OK", "");
			Iter_Remove(Items_INITEM[Item[pInfo[playerid][t_dialogtmp1]][uid]], uidCD);
			Iter_Add(Items_PLAYER[pInfo[playerid][uid]], uidCD);		
			Item[uidCD][owner_id] = pInfo[playerid][uid];
			Item[uidCD][owner_type] = OWNER_TYPE_PLAYER;
			Item[pInfo[playerid][t_dialogtmp1]][value1] = 0;
			new zapytanie[120];
			format(zapytanie, sizeof(zapytanie), "UPDATE `plerp_items` SET `owner_type` = %i, `owner_id` = %i WHERE `uid` = %i", OWNER_TYPE_PLAYER, pInfo[playerid][uid], Item[uidCD][uid]);
			mysql_function_query(mysqlHandle, zapytanie, false, "", "");		
			format(zapytanie, sizeof(zapytanie), "UPDATE `plerp_items` SET `value1` = %i WHERE `uid` = %i", Item[pInfo[playerid][t_dialogtmp1]][value1], Item[pInfo[playerid][t_dialogtmp1]][uid]);
			mysql_function_query(mysqlHandle, zapytanie, false, "", "");
			ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Wyj�cie p�yty", "Pomy�lnie wyj��e� p�yt� z discman'a", "OK", "");
		}
	}
	case 63:
	{
		if(!response) return 1;
		new ItemIDX = strval(inputtext);
		if(Item[ItemIDX][owner_type] != OWNER_TYPE_WAREHOUSE) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Oferta -> B��d", "Przedmiot kt�ry chcesz oferowa� nie istnieje", "Zamknij", "");
		//Jestes chujem 2
		SendPlayerOffer(pInfo[playerid][t_dialogtmp1], playerid, OFFER_TYPE_PODAJ, ItemIDX, pInfo[playerid][t_dialogtmp2], pInfo[playerid][t_dialogtmp3]);
	
	}
	  // -- LSPD - BARTEK -- //
	  case 80: // COMMAND:db
		{
			if(!response) return 1;
		
			switch(listitem)
			{
				case 0: // Szukaj
				{
					ShowPlayerDialog(playerid, 81, DIALOG_STYLE_LIST, "Baza danych LSPD -> Szukaj", "Poszukiwane pojazdy\nPoszukiwane osoby\nZarekwirowane pojazdy\nKartoteki\nMandaty\nBlokady", "Wybierz", "Anuluj");
				}
				case 1: // Dodaj wpis
				{
					ShowPlayerDialog(playerid, 84, DIALOG_STYLE_LIST, "Baza danych LSPD -> Dodaj wpis", "Dodaj poszukiwany pojazd\nDodaj poszukiwan� osob�\nDodaj zarekwirowany pojazd\nDodaj kartotek�", "Wybierz", "Anuluj");
				}
				case 2: // Usu� wpis
				{
					if(!HasPlayerPermission(playerid, "group", GPREM_leader, 4)) return ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Usu� wpis", "Nie jeste� liderem Los Santos Police Department.", "OK", "");
					ShowPlayerDialog(playerid, 86, DIALOG_STYLE_LIST, "Baza danych LSPD -> Usu� wpis", "Usu� poszukiwany pojazd\nUsu� poszukiwan� osob�\nUsu� zarekwirowany pojazd\nUsu� kartotek�", "Wybierz", "Anuluj");
				}
				case 3: // Edytuj wpis
				{
					ShowPlayerDialog(playerid, 88, DIALOG_STYLE_LIST, "Baza danych LSPD -> Edytuj wpis", "Edytuj poszukiwany pojazd\nEdytuj poszukiwan� osob�\nEdytuj zarekwirowany pojazd\nEdytuj kartotek�", "Wybierz", "Anuluj");
				}
			}
		}
		case 81: // Baza LSPD -> Szukaj
		{
			if(!response) return ShowPlayerDialog(playerid, 80, DIALOG_STYLE_LIST, "Baza danych LSPD", "Szukaj\nDodaj wpis\nUsu� wpis\nEdytuj wpis", "Wybierz", "Anuluj");
		
			switch(listitem)
			{
				case 0:
				{
					ShowPlayerDialog(playerid, 82, DIALOG_STYLE_INPUT, "Baza danych LSPD -> Szukaj", "Wpisz rejestracj� poszukiwanego pojazdu.", "Akceptuj", "Anuluj");
					pInfo[playerid][t_dialogtmp1] = 1; // Poszukiwane pojazdy
				}
				case 1:
				{
					ShowPlayerDialog(playerid, 82, DIALOG_STYLE_INPUT, "Baza danych LSPD -> Szukaj", "Wpisz nazwisko lub pseudonim poszukiwanej osoby.", "Akceptuj", "Anuluj");
					pInfo[playerid][t_dialogtmp1] = 2;// Poszukiwane osoby
				}
				case 2:
				{
					ShowPlayerDialog(playerid, 82, DIALOG_STYLE_INPUT, "Baza danych LSPD -> Szukaj", "Wpisz mark� odholowanego pojazdu.", "Akceptuj", "Anuluj");
					pInfo[playerid][t_dialogtmp1] = 3; // Odholowane pojazdy
				}
				case 3:
				{ 
					ShowPlayerDialog(playerid, 82, DIALOG_STYLE_INPUT, "Baza danych LSPD -> Szukaj", "Wpisz nazwisko lub pseudonim podejrzanego.", "Akceptuj", "Anuluj");
					pInfo[playerid][t_dialogtmp1] = 4; // Kartoteki
				}
				case 4: 
				{
					ShowPlayerDialog(playerid, 82, DIALOG_STYLE_INPUT, "Baza danych LSPD -> Szukaj", "Wpisz imi� i nazwisko na kt�re zosta� wypisany mandat w formacie: \
																		\nImi�;Nazwisko", "Akceptuj", "Anuluj");
					pInfo[playerid][t_dialogtmp1] = 5; // Mandaty
				}
				case 5:
				{
					ShowPlayerDialog(playerid, 82, DIALOG_STYLE_INPUT, "Baza danych LSPD -> Szukaj", "Wpisz rejestracj� pojazdu na kt�ry zosta�a na�o�ona blokada.", "Akceptuj", "Anuluj");
					pInfo[playerid][t_dialogtmp1] = 6; // Bloady k�
				}
			}
		}
		case 82: // Baza LSPD -> Szukaj
		{
			if(!response) return ShowPlayerDialog(playerid, 81, DIALOG_STYLE_LIST, "Baza danych LSPD -> Szukaj", "Poszukiwane pojazdy\nPoszukiwane osoby\nZarekwirowane pojazdy\nKartoteki\nMandaty\nBlokady", "Wybierz", "Anuluj");
		
			new string[128];
			new int = pInfo[playerid][t_dialogtmp1];
			mysql_real_escape_string(inputtext, inputtext);
		
			switch(int)
			{
				case 1: // Baza LSPD -> Szukaj -> Poszukiwane pojazdy
				{
					format(string, sizeof(string), "SELECT `id`, `model`, `color`, `registration`, `madedate` FROM `plerp_wantedvehicles` WHERE `registration`='%s'", inputtext);
					
					mysql_function_query(mysqlHandle, string, true, "WantedVehicleQuery", "dsdd", playerid, inputtext, 1, 0);
				}
				case 2: // Baza LSPD -> Szukaj -> Poszukiwane osoby
				{
					format(string, sizeof(string), "SELECT `id`, `name`, `surname`, `nick`, `madedate` FROM `plerp_wantedpersons` WHERE `surname`='%s' OR `nick`='%s'", inputtext, inputtext);
					
					mysql_function_query(mysqlHandle, string, true, "WantedPersonQuery", "dsdd", playerid, inputtext, 1, 0);
				}
				case 3: // Baza LSPD -> Szukaj -> Zarekwirowane pojazdy
				{
					format(string, sizeof(string), "SELECT `id`, `model`, `color`, `madedate` FROM `plerp_towedvehicles` WHERE `model`='%s'", inputtext);
					
					mysql_function_query(mysqlHandle, string, true, "TowedVehicleQuery", "dsdd", playerid, inputtext, 1, 0);
				}
				case 4:	// Baza LSPD -> Szukaj -> Kartoteki
				{
					format(string, sizeof(string), "SELECT `id`, `name`, `surname`, `nick`, `madedate` FROM `plerp_policefiles` WHERE `surname`='%s' OR `nick`='%s'", inputtext, inputtext);
					
					mysql_function_query(mysqlHandle, string, true, "PoliceFileQuery", "dsdd", playerid, inputtext, 1, 0);
				}
				case 5: // Baza LSPD -> Szukaj -> Mandaty
				{
					new m_name[32], surname[32];
					
					if(sscanf(inputtext, "p<;>s[32]s[32]", m_name, surname))
					{
						ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Szukaj", "Z�y format danych.", "OK", "");
					} else
					{
						format(string, sizeof(string), "SELECT `id`, `name`, `surname`, `date` FROM `plerp_tickets` WHERE `name`='%s' AND `surname`='%s'", m_name, surname);
						
						mysql_function_query(mysqlHandle, string, true, "TicketQuery", "dsdd", playerid, inputtext, 1, 0);
					}
				}
				case 6: // Baza LSPD -> Szukaj -> Blokady
				{
					format(string, sizeof(string), "SELECT * FROM `plerp_tireblockades` WHERE `registration`='%s'", inputtext);
					
					mysql_function_query(mysqlHandle, string, true, "TireBlockadeQuery", "dsdd", playerid, inputtext, 2, 0);
				}
			}
		}
		case 83: // Baza LSPD -> Szukaj
		{
			new int = pInfo[playerid][t_dialogtmp2], stringtmp[128], string[512];
		
			format(stringtmp, sizeof(stringtmp), "%s", pInfo[playerid][t_stringtmp]);
		
		
			if(!response) return ShowPlayerDialog(playerid, 81, DIALOG_STYLE_LIST, "Baza danych LSPD -> Szukaj", "Poszukiwane pojazdy\nPoszukiwane osoby\nZarekwirowane pojazdy\nKartoteki\nMandaty\nBlokady", "Wybierz", "Anuluj");
		
			switch(int)
			{
				case 1: // Poszukiwane pojazdy
				{
					format(string, sizeof(string), "SELECT * FROM `plerp_wantedvehicles` WHERE `registration`='%s'", stringtmp);
					
					mysql_function_query(mysqlHandle, string, true, "WantedVehicleQuery", "dsdd", playerid, "", 2, listitem);
				}
				case 2: // Poszukiwane osoby
				{
					format(string, sizeof(string), "SELECT * FROM `plerp_wantedpersons` WHERE `surname`='%s' OR `nick`='%s'", stringtmp, stringtmp);
					
					mysql_function_query(mysqlHandle, string, true, "WantedPersonQuery", "dsdd", playerid, "", 2, listitem);
				}					
				case 3: // Odholowane pojazdy
				{
					format(string, sizeof(string), "SELECT * FROM `plerp_towedvehicles` WHERE `model`='%s'", stringtmp);
					
					mysql_function_query(mysqlHandle, string, true, "TowedVehicleQuery", "dsdd", playerid, "", 2, listitem);
				}
				case 4: // Kartoteki
				{
					format(string, sizeof(string), "SELECT * FROM `plerp_policefiles` WHERE `surname`='%s' OR `nick`='%s'", stringtmp, stringtmp);
					
					mysql_function_query(mysqlHandle, string, true, "PoliceFileQuery", "dsdd", playerid, "", 2, listitem);
				}		
				case 5: // Mandaty
				{
					new m_name[32], surname[32];
					
					sscanf(stringtmp, "p<;>s[32]s[32]", m_name, surname);
					format(string, sizeof(string), "SELECT * FROM `plerp_tickets` WHERE `name`='%s' AND `surname`='%s'", m_name, surname);
					
					mysql_function_query(mysqlHandle, string, true, "TicketQuery", "dsdd", playerid, "", 2, listitem);
				}
				case 6: // Blokady k�
				{
					format(string, sizeof(string), "SELECT * FROM `plerp_tireblockades` WHERE `registration`='%s'", stringtmp);
					
					mysql_function_query(mysqlHandle, string, true, "TireBlockadeQuery", "dsdd", playerid, "", 3, listitem);
				}
			}
		}		
		case 84:
		{
			if(!response) return ShowPlayerDialog(playerid, 80, DIALOG_STYLE_LIST, "Baza danych LSPD", "Szukaj\nDodaj wpis\nUsu� wpis\nEdytuj wpis", "Wybierz", "Anuluj");
		
			switch(listitem)
			{
				case 0: // Dodaj poszukiwany pojazd
				{
					ShowPlayerDialog(playerid, 85, DIALOG_STYLE_INPUT, "Baza danych LSPD -> Dodaj wpis", "Dodaj wpis w formacie: \
																		\nModel;Kolor;Rejestracja;Znaki szczeg�lne;Opis kierowcy;Ostatnio widziany", "Akceptuj", "Anuluj");
					pInfo[playerid][t_dialogtmp1] = 1;
				}
				case 1: // Dodaj poszukiwan� osob�
				{
					ShowPlayerDialog(playerid, 85, DIALOG_STYLE_INPUT, "Baza danych LSPD -> Dodaj wpis", "Dodaj wpis w formacie: \
																		\nImi�;Nazwisko;Ksywa;Adres;Pojazdy;Wzrost;Kolor sk�ry;Kolor oczu;Ostatnio widziany", "Akceptuj", "Anuluj");
					pInfo[playerid][t_dialogtmp1] = 2;
				}
				case 2: // Dodaj zarekwirowany pojazd
				{
					ShowPlayerDialog(playerid, 85, DIALOG_STYLE_INPUT, "Baza danych LSPD -> Dodaj wpis", "Dodaj wpis w formacie: \
																		\nNumer seryjny(UID);Marka;Kolor;Znaki szczeg�lne;Sk�d odholowany;Pow�d odholowania;Cena wykupu", "Akceptuj", "Anuluj");
					pInfo[playerid][t_dialogtmp1] = 3;
				}
				case 3: // Dodaj kartotek�
				{
					ShowPlayerDialog(playerid, 85, DIALOG_STYLE_INPUT, "Baza danych LSPD -> Dodaj wpis", "Dodaj wpis w formacie: \
																		\nImi�;Nazwisko;Ksywa;Adres;Pojazdy;Wzrost;Kolor sk�ry;Kolor oczu;Aresztowania(ilo��);Powody aresztowa�", "Akceptuj", "Anuluj");
					pInfo[playerid][t_dialogtmp1] = 4;
				}
			}
		}
		case 85:
		{
			if(!response) return ShowPlayerDialog(playerid, 84, DIALOG_STYLE_LIST, "Baza danych LSPD -> Dodaj wpis", "Dodaj poszukiwany pojazd\nDodaj poszukiwan� osob�\nDodaj zarekwirowany pojazd\nDodaj kartotek�", "Wybierz", "Anuluj");
		
			new int = pInfo[playerid][t_dialogtmp1], string[512];
			mysql_real_escape_string(inputtext, inputtext);
		
			switch(int)
			{
				case 1: // Baza danych LSPD -> Dodaj wpis -> Poszukiwany pojazd
				{
					new vmodel[32], color[32], reg[64], special[128], driver[128], lastseen[64], date[32];
				
					if(sscanf(inputtext, "p<;>s[32]s[32]s[64]s[128]s[128]s[64]", vmodel, color, reg, special, driver, lastseen))
					{
						ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Dodaj wpis", "Z�y format danych", "OK", "");
					} else
					{
						date = FormatDate();
						format(string, sizeof(string), "INSERT INTO `plerp_wantedvehicles` SET `model`='%s', `color`='%s', `registration`='%s', `special`='%s', \
														`driver_desc`='%s', `last_seen`='%s', `madedate`='%s', `actualdate`='%s'", vmodel, color, reg, special, driver, lastseen, date, date);
						
						mysql_function_query(mysqlHandle, string, false, "", "");
					
						ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Dodaj wpis", "Utworzy�e� nowy wpis w bazie danych LSPD", "OK", "");
					}
				}
				case 2: // Baza danych LSPD -> Dodaj wpis -> Poszukiwana osoba
				{
					new namee[32], surname[32], nick[32], adres[64], vehicles[64], height, skincolor[32], eyescolor[32], lastseen[64], date[32];
				
					if(sscanf(inputtext, "p<;>s[32]s[32]s[32]s[64]s[64]is[32]s[32]s[64]", namee, surname, nick, adres, vehicles, height, skincolor, eyescolor, lastseen))
					{
						ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Dodaj wpis", "Z�y format danych", "OK", "");
					} else
					{
						date = FormatDate();
						format(string, sizeof(string), "INSERT INTO `plerp_wantedpersons` SET `name`='%s', `surname`='%s', `nick`='%s', `adres`='%s', `vehicles`='%s', \
														`height`='%d', `skincolor`='%s', `eyescolor`='%s', `lastseen`='%s', `madedate`='%s', `actualdate`='%s'", namee, surname, 
														nick, adres, vehicles, height, skincolor, eyescolor, lastseen, date, date);
							
						mysql_function_query(mysqlHandle, string, false, "", "");
					
						ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Dodaj wpis", "Utworzy�e� nowy wpis w bazie danych LSPD", "OK", "");
					}
				}
				case 3: // Baza danych LSPD -> Dodaj wpis -> Odholowany pojazd
				{
					new uidd, vmodel[32], color[32], special[128], towedfrom[64], towedreason[64], towprice, date[32];

					if(sscanf(inputtext, "p<;>is[32]s[32]s[128]s[64]s[64]i", uidd, vmodel, color, special, towedfrom, towedreason, towprice))
					{
						ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Dodaj wpis", "Z�y format danych", "OK", "");
					} else
					{
						date = FormatDate();
						format(string, sizeof(string), "INSERT INTO `plerp_towedvehicles` SET `uid`='%d', `model`='%s', `color`='%s', `special`='%s', `towedfrom`='%s', \
														`towedreason`='%s', `price`='%d', `madedate`='%s', `actualdate`='%s'", uidd, vmodel, color, special, towedfrom, towedreason, towprice, date, date);
						
						mysql_function_query(mysqlHandle, string, false, "", "");
					
						ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Dodaj wpis", "Utworzy�e� nowy wpis w bazie danych LSPD.", "OK", "");
					}
				}
				case 4: // Baza danych LSPD -> Dodaj wpis -> Kartoteka
				{
					new namee[32], surname[32], nick[32], adres[64], vehicles[128], height, skincolor[32], eyescolor[32], arrestnum, arrestreason[128], date[32];
				
					if(sscanf(inputtext, "p<;>s[32]s[32]s[32]s[64]s[128]is[32]s[32]is[128]", namee, surname, nick, adres, vehicles, height, skincolor, eyescolor, arrestnum, arrestreason))
					{
						ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Dodaj wpis", "Z�y format danych", "OK", "");
					} else
					{
						date = FormatDate();
						format(string, sizeof(string), "INSERT INTO `plerp_policefiles` SET `name`='%s', `surname`='%s', `nick`='%s', `adres`='%s', `vehicles`='%s', \
														`height`='%d', `skincolor`='%s', `eyescolor`='%s', `arrestnum`='%d', `arrestreason`='%s', `madedate`='%s', `actualdate`='%s'", namee, surname, nick,
														adres, vehicles, height, skincolor, eyescolor, arrestnum, arrestreason, date, date);
													
						mysql_function_query(mysqlHandle, string, false, "", "");
						
						ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Dodaj wpis", "Utworzy�e� nowy wpis w bazie danych LSPD.", "OK", "");
					}
				}
			}
		}
		case 86:
		{
			if(!response) return ShowPlayerDialog(playerid, 80, DIALOG_STYLE_LIST, "Baza danych LSPD", "Szukaj\nDodaj wpis\nUsu� wpis\nEdytuj wpis", "Wybierz", "Anuluj");
		
			switch(listitem)
			{
				case 0: // Baza danych LSPD -> Usu� wpis -> Poszukiwany pojazd
				{
					ShowPlayerDialog(playerid, 87, DIALOG_STYLE_INPUT, "Baza danych LSPD -> Usu� wpis", "Wpisz numer (UID) wpisu kt�ry chcesz usun��", "Usu�", "Wyjd�");
					pInfo[playerid][t_dialogtmp1] = 1;
				}
				case 1: // Baza danych LSPD -> Usu� wpis -> Poszukiwana osoba
				{
					ShowPlayerDialog(playerid, 87, DIALOG_STYLE_INPUT, "Baza danych LSPD -> Usu� wpis", "Wpisz numer (UID) wpisu kt�ry chcesz usun��", "Usu�", "Wyjd�");
					pInfo[playerid][t_dialogtmp1] = 2;
				}
				case 2: // Baza danych LSPD -> Usu� wpis -> Zarekwirowany pojazd
				{
					ShowPlayerDialog(playerid, 87, DIALOG_STYLE_INPUT, "Baza danych LSPD -> Usu� wpis", "Wpisz numer (UID) wpisu kt�ry chcesz usun��", "Usu�", "Wyjd�");
					pInfo[playerid][t_dialogtmp1] = 3;
				}
				case 3: // Baza danych LSPD -> Usu� wpis -> Kartoteka
				{
					ShowPlayerDialog(playerid, 87, DIALOG_STYLE_INPUT, "Baza danych LSPD -> Usu� wpis", "Wpisz numer (UID) wpisu kt�ry chcesz usun��", "Usu�", "Wyjd�");
					pInfo[playerid][t_dialogtmp1] = 4;
				}
			}
		}
		case 87:
		{
			if(!response) return ShowPlayerDialog(playerid, 86, DIALOG_STYLE_LIST, "Baza danych LSPD -> Usu� wpis", "Usu� poszukiwany pojazd\nUsu� poszukiwan� osob�\nUsu� zarekwirowany pojazd\nUsu� kartotek�", "Wybierz", "Anuluj");
		
			new int = pInfo[playerid][t_dialogtmp1];
			mysql_real_escape_string(inputtext, inputtext);
			new uidd = strval(inputtext);
			new string[128];
		
			switch(int)
			{
				case 1: // Baza danych LSPD -> Usu� wpis -> Poszukiwany pojazd
				{	

					format(string, sizeof(string), "SELECT * FROM `plerp_wantedvehicles` WHERE `id`='%d'", uidd);
					
					mysql_function_query(mysqlHandle, string, true, "DeletePoliceRecord", "ddd", playerid, uidd, 1);
				}
				case 2: // Baza danych LSPD -> Usu� wpis -> Poszukiwana osoba
				{
					format(string, sizeof(string), "SELECT * FROM `plerp_wantedpersons` WHERE `id`='%d'", uidd);
					
					mysql_function_query(mysqlHandle, string, true, "DeletePoliceRecord", "ddd", playerid, uidd, 2);
				}
				case 3: // Baza danych LSPD -> Usu� wpis -> Zarekwirowany pojazd
				{
					format(string, sizeof(string), "SELECT * FROM `plerp_towedvehicles` WHERE `id`='%d'", uidd);
					
					mysql_function_query(mysqlHandle, string, true, "DeletePoliceRecord", "ddd", playerid, uidd, 3);
				}
				case 4: // Baza danych LSPD -> Usu� wpis -> Kartoteka
				{
					format(string, sizeof(string), "SELECT * FROM `plerp_policefiles` WHERE `id`='%d'", uidd);
					
					mysql_function_query(mysqlHandle, string, true, "DeletePoliceRecord", "ddd", playerid, uidd, 4);	
				}
			}
		}
		case 88:
		{
			if(!response) return ShowPlayerDialog(playerid, 80, DIALOG_STYLE_LIST, "Baza danych LSPD", "Szukaj\nDodaj wpis\nUsu� wpis\nEdytuj wpis", "Wybierz", "Anuluj");
		
			switch(listitem)
			{
				case 0: // Baza danych LSPD -> Edytuj wpis -> Poszukiwany pojazd
				{
					ShowPlayerDialog(playerid, 89, DIALOG_STYLE_INPUT, "Baza danych LSPD -> Edytuj wpis", "Wpisz numer (UID) wpisu kt�ry chcesz edytowa�.", "Edytuj", "Anuluj");
					pInfo[playerid][t_dialogtmp1] = 1;
				}
				case 1: // Baza danych LSPD -> Edytuj wpis -> Poszukiwana osoba
				{
					ShowPlayerDialog(playerid, 89, DIALOG_STYLE_INPUT, "Baza danych LSPD -> Edytuj wpis", "Wpisz numer (UID) wpisu kt�ry chcesz edytowa�.", "Edytuj", "Anuluj");
					pInfo[playerid][t_dialogtmp1] = 2;
				}
				case 2: // Baza danych LSPD -> Edytuj wpis -> Zarekwirowany pojazd
				{
					ShowPlayerDialog(playerid, 89, DIALOG_STYLE_INPUT, "Baza danych LSPD -> Edytuj wpis", "Wpisz numer (UID) wpisu kt�ry chcesz edytowa�.", "Edytuj", "Anuluj");
					pInfo[playerid][t_dialogtmp1] = 3;
				}
				case 3: // Baza danych LSPD -> Edytuj wpis -> Kartoteka
				{
					ShowPlayerDialog(playerid, 89, DIALOG_STYLE_INPUT, "Baza danych LSPD -> Edytuj wpis", "Wpisz numer (UID) wpisu kt�ry chcesz edytowa�.", "Edytuj", "Anuluj");
					pInfo[playerid][t_dialogtmp1] = 4;
				}
			}
		}
		case 89:
		{
			if(!response) return ShowPlayerDialog(playerid, 88, DIALOG_STYLE_LIST, "Baza danych LSPD -> Edytuj wpis", "Edytuj poszukiwany pojazd\nEdytuj poszukiwan� osob�\nEdytuj zarekwirowany pojazd\nEdytuj kartotek�", "Wybierz", "Anuluj");
		
			new int = pInfo[playerid][t_dialogtmp1];
			mysql_real_escape_string(inputtext, inputtext);
			new uidd = strval(inputtext);
			new string[128];
		
			switch(int)
			{
				case 1: // Baza danych LSPD -> Edytuj wpis -> Poszukiwany pojazd
				{
					format(string, sizeof(string), "SELECT * FROM `plerp_wantedvehicles` WHERE `id`='%d'", uidd);
					
					mysql_function_query(mysqlHandle, string, true, "EditPoliceRecord", "ddd", playerid, uidd, 1);
				}
				case 2: // Baza danych LSPD -> Edytuj wpis -> Poszukiwana osoba
				{
					format(string, sizeof(string), "SELECT * FROM `plerp_wantedpersons` WHERE `id`='%d'", uidd);
					
					mysql_function_query(mysqlHandle, string, true, "EditPoliceRecord", "ddd", playerid, uidd, 2);
				}
				case 3: // Baza danych LSPD -> Edytuj wpis -> Zarekwirowany pojazd
				{
					format(string, sizeof(string), "SELECT * FROM `plerp_towedvehicles` WHERE `id`='%d'", uidd);
					
					mysql_function_query(mysqlHandle, string, true, "EditPoliceRecord", "ddd", playerid, uidd, 3);
				}
				case 4: // Baza danych LSPD -> Edytuj wpis -> Kartoteka
				{
					format(string, sizeof(string), "SELECT * FROM `plerp_policefiles` WHERE `id`='%d'", uidd);
					
					mysql_function_query(mysqlHandle, string, true, "EditPoliceRecord", "ddd", playerid, uidd, 4);
				}
			}
		}
		case 90:
		{
			if(!response) return ShowPlayerDialog(playerid, 88, DIALOG_STYLE_LIST, "Baza danych LSPD -> Edytuj wpis", "Edytuj poszukiwany pojazd\nEdytuj poszukiwan� osob�\nEdytuj zarekwirowany pojazd\nEdytuj kartotek�", "Wybierz", "Anuluj");
		
			new int = pInfo[playerid][t_dialogtmp1];
			new uidd = pInfo[playerid][t_dialogtmp2];
		    mysql_real_escape_string(inputtext, inputtext);
			
			switch(int)
			{
				case 1: // Baza danych LSPD -> Edytuj wpis -> Poszukiwany pojazd
				{
					new vmodel[32], color[32], reg[64], special[128], driver[128], lastseen[64];
				
					if(sscanf(inputtext, "p<;>s[32]s[32]s[64]s[128]s[128]s[64]", vmodel, color, reg, special, driver, lastseen))
					{
						ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Edytuj wpis", "Z�y format danych.", "OK", "");
					} else
					{
						UpdateWantedVehicle(uidd, vmodel, color, reg, special, driver, lastseen);
						ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Edytuj", "Z powodzeniem zmieni�e� wpis w bazie danych LSPD.", "OK", "");
					}
				}
				case 2: // Baza danych LSPD -> Edytuj wpis -> Poszukiwana osoba
				{
					new namee[32], surname[32], nick[32], adres[64], vehicles[64], height, skincolor[32], eyescolor[32], lastseen[64];
				
					if(sscanf(inputtext, "p<;>s[32]s[32]s[32]s[64]s[64]is[32]s[32]s[64]", namee, surname, nick, adres, vehicles, height, skincolor, eyescolor, lastseen))
					{
						ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Edytuj wpis", "Z�y format danych.", "OK", "");
					} else
					{
						UpdateWantedPerson(uidd, namee, surname, nick, adres, vehicles, height, skincolor, eyescolor, lastseen);
						ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Dodaj wpis", "Z powodzeniem zmieni�e� wpis w bazie danych LSPD", "OK", "");
					}
				}
				case 3: // Baza danych LSPD -> Edytuj wpis -> Zarekwirowany pojazd
				{
					new uid2, vmodel[32], color[32], special[128], towedfrom[64], towedreason[64], towprice;

					if(sscanf(inputtext, "p<;>is[32]s[32]s[128]s[64]s[64]i", uid2, vmodel, color, special, towedfrom, towedreason, towprice))
					{
						ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Edytuj wpis", "Z�y format danych.", "OK", "");
					} else
					{
						UpdateTowedVehicle(uidd, uid2, vmodel, color, special, towedfrom, towedreason, towprice);
						ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Dodaj wpis", "Z powodzeniem zmieni�e� wpis w bazie danych LSPD.", "OK", "");
					}
				}
				case 4: // Baza danych LSPD -> Edytuj wpis -> Kartoteka
				{
					new namee[32], surname[32], nick[32], adres[64], vehicles[128], height, skincolor[32], eyescolor[32], arrestnum, arrestreason[128];
				
					if(sscanf(inputtext, "p<;>s[32]s[32]s[32]s[64]s[128]sis[32]s[32]is[128]", namee, surname, nick, adres, vehicles, height, skincolor, eyescolor, arrestnum, arrestreason))
					{
						ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Edytuj wpis", "Z�y format danych.", "OK", "");
					} else
					{
						UpdatePoliceFile(uidd, namee, surname, nick, adres, vehicles, height, skincolor, eyescolor, arrestnum, arrestreason);
						ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Baza danych LSPD -> Edytuj wpis", "Z powodzeniem zmieni�e� wpis w bazie danych LSPD.", "OK", "");
					}
				}
			}
		}	
		case 91: // COMMAND: mandat -> Wypisz mandat
		{
			new string[512], date[32], id, money, pkt, reason[128], plName[128], pSurname[128];
		    mysql_real_escape_string(inputtext, inputtext);
			
			if(sscanf(inputtext, "p<;>iiis[128]", id, money, pkt, reason))
			{
				ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Wystaw mandat", "Z�y format danych.", "OK", "");
			} else
			{
				pSurname = GetPlayerSurname(playerid);
				plName = GetPlayerNameFunc(playerid);
				date = FormatDate();
				format(string, sizeof(string), "INSERT INTO `plerp_tickets` SET `p_uid`='%d', `name`='%s', `surname`='%s', `cost`='%d', `pkt`='%d', `reason`='%s', `status`='0', `date`='%s'", id, plName, pSurname, money, pkt, reason, date);
				
				mysql_function_query(mysqlHandle, string, false, "", "");
			
				format(string, sizeof(string), "Wypisa�e� mandat w wysoko�ci $%d oraz %d punkt�w karnych graczowi %s. Pow�d: %s.", money, pkt, pInfo[id][name], reason);
				SendClientMessage(playerid, COLOR_GREEN, string);
				format(string, sizeof(string), "Funkcjonariusz %s wypisa� Ci mandat w wysoko�ci $%d oraz %d punkt�w karnych. Pow�d: %s.", pInfo[id][name], money, pkt, reason);
				SendClientMessage(id, COLOR_RED, string);
			}
		}
		case 92: // COMMAND: mandat -> Zdejmij mandat
		{
		    mysql_real_escape_string(inputtext, inputtext);
			new string[512];
			new id = strval(inputtext);
			
			format(string, sizeof(string), "SELECT `status` FROM `plerp_tickets` WHERE `id`='%d'", id);
			
			mysql_function_query(mysqlHandle, string, true, "TicketQuery", "dsdd", playerid, "", 3, 0);
			
			format(string, sizeof(string), "UPDATE `plerp_tickets` SET `status`='1'");
			
			mysql_function_query(mysqlHandle, string, false, "", "");
					
			ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Zdejmij mandat", "Z powodzeniem zdj��e� mandat.", "OK", "");
		}
		case 93: // COMMAND: blokada -> naloz
		{
			new string[512], reg[32], cost, reason[64];
			mysql_real_escape_string(inputtext, inputtext);
			
			if(sscanf(inputtext, "p<;>s[32]is[64]", reg, cost, reason))
			{
				ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Blokada pojazdu", "Z�y format danych.", "OK", "");
			} else
			{
				//// Zapytnie MySQL i zmiana w tablicy pojazdu. 
				
				format(string, sizeof(string), "INSERT INTO `plerp_tireblockades` SET `registration`='%s', `cost`='%d', `reason`='%s'", reg, cost, reason);
				
				mysql_function_query(mysqlHandle, string, false, "", "");

				format(string, sizeof(string), "Za�o�y�e� blokad� na ko�o pojazdowi o rejestracji: %s", reg);
				SendClientMessage(playerid, COLOR_RED, string);
			}
		}
		case 94: // COMMAND: blokada -> zdejmij
		{
			new string[512];
			mysql_real_escape_string(inputtext, inputtext);
			
			format(string, sizeof(string), "SELECT * FROM `plerp_tireblockades` WHERE `registration`='%s'", inputtext);
			
			mysql_function_query(mysqlHandle, string, true, "TireBlockadeQuery", "dsdd", playerid, inputtext, 1, 1);
		}
		// -- LSPD - BARTEK -- //
		case 95: // COMMAND: /usmierc 1/2
        {
            if(!response) return 1;
                       
            ShowPlayerDialog(playerid, 96, DIALOG_STYLE_INPUT, "U�mier� posta�", "Wpisz okoliczno�ci �mierci swojej postaci.", "Akceptuj", "Anuluj");
        }
		
        case 96: // COMMAND /usmierc 2/2
        {
            if(!response) return 1;
                       
            new string[512], mminute, hhour, ssecond, dday, mmonth, yyear, date[32];
            //TODO: zawijanie tekstu
            gettime(hhour, mminute, ssecond);
            getdate(yyear, mmonth, dday);
            format(date, sizeof(date), "%d/%d/%d (%d:%d)", dday, mmonth, yyear, hhour, mminute);
            format(string, sizeof(string), "INSERT INTO `plerp_corpses` SET `killer`='%s', `victim`='%s', `reason`='%d', `date`='%s', `surcom`='%s'", pInfo[pInfo[playerid][t_killerid]][name], pInfo[playerid][name], pInfo[playerid][t_reason], date, inputtext);
            mysql_function_query(mysqlHandle, string, true, "CreateCorpse", "d", playerid);
        }
 
		case 97:
        {
                        if(!response) return 1;
                       
                        new id, gID, string[256];
                       
                        if(pInfo[playerid][t_dialogtmp1] == 1)
                        {
                                gID = FindGroupByUID(5);
                                foreach(GroupReports[gID], i)
                                {
                                        if(id == listitem)
                                        {
                                                format(string, sizeof(string), "Zg�aszaj�cy: %s\nMiejsce: %s\nNapastnicy: %s\nOpis napastnik�w: %s\nRodzaj: %s\nCzas zdarzenia: %s",
                                                                                                                GroupReport[i][caller],
                                                                                                                GroupReport[i][place],
                                                                                                                GroupReport[i][attackers],
                                                                                                                GroupReport[i][details],
                                                                                                                GroupReport[i][type],
                                                                                                                GroupReport[i][r_date]);
                       
                                                ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "911 -> Zgloszenie", string, "OK", "");
                                        }
                                        id++;
                                }
                        } else if(pInfo[playerid][t_dialogtmp1] == 2)
                        {
                                gID = FindGroupByUID(8);
                                foreach(GroupReports[gID], i)
                                {
                                        if(id == listitem)
                                        {
                                                format(string, sizeof(string), "Zg�aszaj�cy: %s\nMiejsce: %s\nOfiary: %s\nRodzaj: %s\nCzas zdarzenia: %s",
                                                                                                                GroupReport[i][caller],
                                                                                                                GroupReport[i][place],
                                                                                                                GroupReport[i][victims],
                                                                                                                GroupReport[i][type],
                                                                                                                GroupReport[i][r_date]);
                                                                                               
                                                ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "911 -> Zgloszenie", string, "OK", "");
                                        }
                                        id++;
                                }
                        }                      
        }
		
		case 98: // COMMAND:/ban 1/2 AND COMMAND:/aj 1/2
                {
                        if(!response) return 1;
                       
                        switch(pInfo[playerid][t_dialogtmp1])
                        {
                                case 1:
                                {
                                        switch(listitem)
                                        {
                                                case 0: // 24h
                                                {
                                                        pInfo[playerid][t_dialogtmp1] = gettime() + 24*(60*60);
                                                        ShowPlayerDialog(playerid, 99, DIALOG_STYLE_INPUT, "Pow�d", "Wpisz pow�d nadania banicji", "Zbanuj", "Anuluj");
                                                }
                                                case 1: // 48h
                                                {
                                                        pInfo[playerid][t_dialogtmp1] = gettime() + 48*(60*60);
                                                        ShowPlayerDialog(playerid, 99, DIALOG_STYLE_INPUT, "Pow�d", "Wpisz pow�d nadania banicji", "Zbanuj", "Anuluj");
                                                }
                                                case 3: // Tydzie�
                                                {
                                                        pInfo[playerid][t_dialogtmp1] = gettime() + 7*24*(60*60);
                                                        ShowPlayerDialog(playerid, 99, DIALOG_STYLE_INPUT, "Pow�d", "Wpisz pow�d nadania banicji", "Zbanuj", "Anuluj");
                                                }
                                                case 4: // 2 Tygodnie
                                                {
                                                        pInfo[playerid][t_dialogtmp1] = gettime() + 2*7*24*(60*60);
                                                        ShowPlayerDialog(playerid, 99, DIALOG_STYLE_INPUT, "Pow�d", "Wpisz pow�d nadania banicji", "Zbanuj", "Anuluj");
                                                }
                                                case 5: // Miesi�c
                                                {
                                                        pInfo[playerid][t_dialogtmp1] = gettime() + 4*7*24*(60*60);
                                                        ShowPlayerDialog(playerid, 99, DIALOG_STYLE_INPUT, "Pow�d", "Wpisz pow�d nadania banicji", "Zbanuj", "Anuluj");
                                                }
                                                case 6: // 4 Miesi�ce
                                                {
                                                        pInfo[playerid][t_dialogtmp1] = gettime() + 4*4*7*24*(60*60);
                                                        ShowPlayerDialog(playerid, 99, DIALOG_STYLE_INPUT, "Pow�d", "Wpisz pow�d nadania banicji", "Zbanuj", "Anuluj");
                                                }
                                                case 7: // Na zawsze
                                                {
                                                        pInfo[playerid][t_dialogtmp1] = gettime() + 5*12*4*7*24*(60*60); // 5 lat
                                                        ShowPlayerDialog(playerid, 99, DIALOG_STYLE_INPUT, "Pow�d", "Wpisz pow�d nadania banicji", "Zbanuj", "Anuluj");
                                                }
                                        }
                                        pInfo[playerid][t_dialogtmp3] = 1;
                                }
                                case 2:
                                {
                                        switch(listitem)
                                        {
                                                case 0: // 30 min
                                                {
                                                        pInfo[playerid][t_dialogtmp1] = gettime() + 60*30;
                                                        ShowPlayerDialog(playerid, 99, DIALOG_STYLE_INPUT, "Pow�d", "Wpisz pow�d nadania Admin Jaila", "Akceptuj", "Anuluj");
                                                }
                                                case 1: // 1h
                                                {
                                                        pInfo[playerid][t_dialogtmp1] = gettime() + 60*60;
                                                        ShowPlayerDialog(playerid, 99, DIALOG_STYLE_INPUT, "Pow�d", "Wpisz pow�d nadania Admin Jaila", "Akceptuj", "Anuluj");
                                                }
                                                case 2: // 2h
                                                {
                                                        pInfo[playerid][t_dialogtmp1] = gettime() + 2*(60*60);
                                                        ShowPlayerDialog(playerid, 99, DIALOG_STYLE_INPUT, "Pow�d", "Wpisz pow�d nadania Admin Jaila", "Akceptuj", "Anuluj");
                                                }
                                                case 3: // 6h
                                                {
                                                        pInfo[playerid][t_dialogtmp1] = gettime() + 6*(60*60);
                                                        ShowPlayerDialog(playerid, 99, DIALOG_STYLE_INPUT, "Pow�d", "Wpisz pow�d nadania Admin Jaila", "Akceptuj", "Anuluj");
                                                }
                                                case 4: // 24h
                                                {
                                                        pInfo[playerid][t_dialogtmp1] = gettime() + 24*(60*60);
                                                        ShowPlayerDialog(playerid, 99, DIALOG_STYLE_INPUT, "Pow�d", "Wpisz pow�d nadania Admin Jaila", "Akceptuj", "Anuluj");
                                                }
                                        }
                                        pInfo[playerid][t_dialogtmp3] = 2;
                                }
                        }
                }
                case 99: // COMMAND:ban 2/2
                {
                        if(!response) return 1;
                       
                        mysql_real_escape_string(inputtext, inputtext);
                        if(pInfo[playerid][t_dialogtmp3] == 1)
                        {
                                PenaltyTextdraw(playerid, pInfo[playerid][t_dialogtmp2], inputtext, "Ban");
                                BanPlayer(playerid, pInfo[playerid][t_dialogtmp2], inputtext, pInfo[playerid][t_dialogtmp1]);
                        } else
                        {
                                PenaltyTextdraw(playerid, pInfo[playerid][t_dialogtmp2], inputtext, "Admin Jail");
                                AdminJail(playerid, pInfo[playerid][t_dialogtmp2], inputtext, pInfo[playerid][t_dialogtmp1]);
                        }
                }
                case 100:
                {
                        if(!response) return 1;
                       
                        mysql_real_escape_string(inputtext, inputtext);
                        PenaltyTextdraw(playerid, pInfo[playerid][t_dialogtmp2], inputtext, "Kick");
                        KickEx(playerid, pInfo[playerid][t_dialogtmp2], inputtext);
                }
                case 101:
                {
                        if(!response) return 1;
                       
                        mysql_real_escape_string(inputtext, inputtext);
                        PenaltyTextdraw(playerid, pInfo[playerid][t_dialogtmp2], inputtext, "Warn");
                        WarnPlayer(playerid, pInfo[playerid][t_dialogtmp2], inputtext);
                }
                case 102: // COMMAND:acp
                {
                        if(!response) return 1;
                       
                        switch(listitem)
                        {
                                case 0: // Podstawowe komendy
                                {
                                        ShowPlayerDialog(playerid, 103, DIALOG_STYLE_LIST, "Admin Control Panel", "Zbanuj gracza\nWyrzu� gracza\nNadaj warna graczowi\nAdmin Jail", "Wybierz", "Anuluj");
                                }
                                case 1: // Blokady
                                {
                                        ShowPlayerDialog(playerid, 105, DIALOG_STYLE_LIST, "Admin Control Panel", "Blokada czatu OOC\nBlokada biegania\nBlokada bicia", "Wybierz", "Anuluj");
                                }
                                case 2: // Dodatki
                                {
                                        ShowPlayerDialog(playerid, 109, DIALOG_STYLE_LIST, "Admin Control Panel", "Teleportacja\nSlapowanie\nNadaj HP\nNadaj pancerz\nSpectating", "Wybierz", "Anuluj");
                                }
                        }
                }
                case 103: // COMMAND:acp -> Podstawowe komendy
                {
                        if(!response) return ShowPlayerDialog(playerid, 102, DIALOG_STYLE_LIST, "Admin Control Panel", "Podstawowe komendy\nBlokady\nDodatki", "Wybierz", "Wr��");
                       
                        switch(listitem)
                        {
                                case 0: // COMMAND:acp -> Zbanuj gracza
                                {
                                        ShowPlayerDialog(playerid, 104, DIALOG_STYLE_INPUT, "Zbanuj gracza", "Wpisz ID gracza kt�rego chcesz zbanowa�.", "Akceptuj", "Anuluj");
                                        pInfo[playerid][t_dialogtmp1] = 1;
                                }
                                case 1: // COMMAND:acp -> Wyrzu� gracza
                                {
                                        ShowPlayerDialog(playerid, 104, DIALOG_STYLE_INPUT, "Wyrzu� gracza", "Wpisz ID kt�rego chcesz wyrzuci�.", "Akceptuj", "Anuluj");
                                        pInfo[playerid][t_dialogtmp1] = 2;
                                }
                                case 2: // COMMAND:acp -> Nadaj warna
                                {
                                        ShowPlayerDialog(playerid, 104, DIALOG_STYLE_INPUT, "Nadaj warna graczowi", "Wpisz ID gracza kt�remu chcesz nada� warna.", "Akceptuj", "Anuluj");
                                        pInfo[playerid][t_dialogtmp1] = 3;
                                }
                                case 3: // COMMAND:acp -> Admin Jail
                                {
                                        ShowPlayerDialog(playerid, 104, DIALOG_STYLE_INPUT, "Wrzu� gracza do Admin Jaila", "Wpisz ID gracza kt�rego chcesz zamkn�� w Admin Jail.", "Akceptuj", "Anuluj");
                                        pInfo[playerid][t_dialogtmp1] = 4;
                                }
                        }
                }
                case 104: // COMMAND:acp -> Podstawowe komendy
                {
                        if(!response) return 1;
                       
                        switch(pInfo[playerid][t_dialogtmp1])
                        {
                                case 1: // Banicja
                                {
                                        mysql_real_escape_string(inputtext, inputtext);
                                        pInfo[playerid][t_dialogtmp2] = strval(inputtext);
                                        pInfo[playerid][t_dialogtmp1] = 1;
                                        ShowPlayerDialog(playerid, 98, DIALOG_STYLE_LIST, "Zbanuj gracza", "24h\n48h\nTydzie�\nDwa tygodnie\nMiesi�c\nCztery miesi�ce\nNa zawsze", "Wybierz", "Anuluj");
                                }
                                case 2: // Kick
                                {
                                        mysql_real_escape_string(inputtext, inputtext);
                                        pInfo[playerid][t_dialogtmp2] = strval(inputtext);
                                        ShowPlayerDialog(playerid, 100, DIALOG_STYLE_INPUT, "Wyrzu� gracza", "Wpisz pow�d wyrzucenia gracza z serwera.", "Wyrzu�", "Anuluj");
                                }
                                case 3: // Warn
                                {
                                        mysql_real_escape_string(inputtext, inputtext);
                                        pInfo[playerid][t_dialogtmp2] = strval(inputtext);
                                        ShowPlayerDialog(playerid, 101, DIALOG_STYLE_INPUT, "Nadaj warna graczowi", "Wpisz pow�d nadania warna graczowi.", "Akceptuj", "Anuluj");
                                }
                                case 4: // AJ
                                {
                                        mysql_real_escape_string(inputtext, inputtext);
                                        pInfo[playerid][t_dialogtmp2] = strval(inputtext);
                                        pInfo[playerid][t_dialogtmp1] = 2;
                                        ShowPlayerDialog(playerid, 98, DIALOG_STYLE_LIST, "Admin Jail", "30min\n1h\n2h\n6h\n24h", "Wybierz", "Anuluj");
                                }
                        }
                }              
                case 105: // COMMAND:acp -> Blokady
                {
                        if(!response) return ShowPlayerDialog(playerid, 102, DIALOG_STYLE_LIST, "Admin Control Panel", "Podstawowe komendy\nBlokady\nDodatki", "Wybierz", "Wr��");
                       
                        switch(listitem)
                        {
                                case 0: // Blokada czatu OOC
                                {
                                        ShowPlayerDialog(playerid, 106, DIALOG_STYLE_INPUT, "Blokada czatu OOC", "Wpisz ID gracza kt�remu chcesz nada� blokad�.", "Akceptuj", "Anuluj");
                                        pInfo[playerid][t_dialogtmp1] = 1;
                                }
                                case 1: // Blokada biegania
                                {
                                        ShowPlayerDialog(playerid, 106, DIALOG_STYLE_INPUT, "Blokada biegania", "Wpisz ID gracza kt�remu chcesz nada� blokad�.", "Akceptuj", "Anuluj");
                                        pInfo[playerid][t_dialogtmp1] = 2;
                                }
                                case 2: // Blokada bicia
                                {
                                        ShowPlayerDialog(playerid, 106, DIALOG_STYLE_INPUT, "Blokada bicia", "Wpisz ID gracza kt�remu chcesz nada� blokad�.", "Akceptuj", "Anuluj");
                                        pInfo[playerid][t_dialogtmp1] = 3;
                                }
                        }
                }
                case 106: // COMMAND:acp -> Blokady
                {
                        if(!response) return 1;
                       
                        switch(pInfo[playerid][t_dialogtmp1])
                        {
                                case 1: // Blokada czatu OOC
                                {
                                        mysql_real_escape_string(inputtext, inputtext);
                                        pInfo[playerid][t_dialogtmp2] = strval(inputtext);
                                        ShowPlayerDialog(playerid, 107, DIALOG_STYLE_INPUT, "Blokada czatu OOC", "Wpisz pow�d nadania blokady.", "Akceptuj", "Anuluj");
                                        pInfo[playerid][t_dialogtmp1] = 1;
                                }
                                case 2: // Blokada biegania
                                {
                                        mysql_real_escape_string(inputtext, inputtext);
                                        pInfo[playerid][t_dialogtmp2] = strval(inputtext);
                                        ShowPlayerDialog(playerid, 107, DIALOG_STYLE_INPUT, "Blokada biegania", "Wpisz pow�d nadania blokady.", "Akceptuj", "Anuluj");
                                        pInfo[playerid][t_dialogtmp1] = 2;
                                }
                                case 3: // Blokada bicia
                                {
                                        mysql_real_escape_string(inputtext, inputtext);
                                        pInfo[playerid][t_dialogtmp2] = strval(inputtext);
                                        ShowPlayerDialog(playerid, 107, DIALOG_STYLE_INPUT, "Blokada bicia", "Wpisz pow�d nadania blokady.", "Akceptuj", "Anuluj");
                                        pInfo[playerid][t_dialogtmp1] = 3;
                                }
                        }
                }
                case 107: // COMMAND:acp -> Blokady
                {
                        if(!response) return 1;
                       
                        switch(pInfo[playerid][t_dialogtmp1])
                        {
                                case 1: // Blokada czatu OOC
                                {
                                        mysql_real_escape_string(inputtext, inputtext);
                                        format(pInfo[playerid][t_stringtmp], 128, "%s", inputtext);
                                        ShowPlayerDialog(playerid, 108, DIALOG_STYLE_LIST, "Blokada czatu OOC", "2h\n4h\n24h\nTydzie�", "Akceptuj", "Anuluj");
                                        pInfo[playerid][t_dialogtmp1] = 1;
                                }
                                case 2: // Blokada biegania
                                {
                                        mysql_real_escape_string(inputtext, inputtext);
                                        format(pInfo[playerid][t_stringtmp], 128, "%s", inputtext);
                                        ShowPlayerDialog(playerid, 108, DIALOG_STYLE_LIST, "Blokada biegania", "2h\n4h\n24h\nTydzie�", "Akceptuj", "Anuluj");
                                        pInfo[playerid][t_dialogtmp1] = 2;
                                }
                                case 3: // Blokada bicia
                                {
                                        mysql_real_escape_string(inputtext, inputtext);
                                        format(pInfo[playerid][t_stringtmp], 128, "%s", inputtext);
                                        ShowPlayerDialog(playerid, 108, DIALOG_STYLE_LIST, "Blokada bicia", "2h\n4h\n24h\nTydzie�", "Akceptuj", "Anuluj");
                                        pInfo[playerid][t_dialogtmp1] = 3;
                                }
                        }
                }
                case 108: // COMMAND:acp -> Blokady
                {
                        if(!response) return 1;
                       
                        switch(listitem)
                        {
                                case 0: // 2h
                                {
                                        new duration = gettime() + 2*(60*60);
                                        new targetid = pInfo[playerid][t_dialogtmp2];
                                       
                                        switch(pInfo[playerid][t_dialogtmp1])
                                        {
                                                case 1: // Blokada OOC
                                                {
                                                        pInfo[targetid][OOC_block] = 1;
                                                        BlockOOC(playerid, targetid, pInfo[playerid][t_stringtmp], duration);
                                                        PenaltyTextdraw(playerid, targetid, pInfo[playerid][t_stringtmp], "Blokada czatu OOC");
                                                }
                                                case 2: // Blokada biegania
                                                {
                                                        pInfo[targetid][RUN_block] = 1;
                                                        BlockSprint(playerid, targetid, pInfo[playerid][t_stringtmp], duration);
                                                        PenaltyTextdraw(playerid, targetid, pInfo[playerid][t_stringtmp], "Blokada biegania");
                                                }
                                                case 3: // Blokada bicia
                                                {
                                                        pInfo[targetid][FIGHT_block] = 1;
                                                        BlockFight(playerid, targetid, pInfo[playerid][t_stringtmp], duration);
                                                        PenaltyTextdraw(playerid, targetid, pInfo[playerid][t_stringtmp], "Blokada bicia");
                                                }
                                        }
                                }
                                case 1: // 4h
                                {
                                        new duration = gettime() + 4*(60*60);
                                        new targetid = pInfo[playerid][t_dialogtmp2];
                                       
                                        switch(pInfo[playerid][t_dialogtmp1])
                                        {
                                                case 1: // Blokada OOC
                                                {
                                                        pInfo[targetid][OOC_block] = 1;
                                                        BlockOOC(playerid, targetid, pInfo[playerid][t_stringtmp], duration);
                                                        PenaltyTextdraw(playerid, targetid, pInfo[playerid][t_stringtmp], "Blokada czatu OOC");
                                                }
                                                case 2: // Blokada biegania
                                                {
                                                        pInfo[targetid][RUN_block] = 1;
                                                        BlockSprint(playerid, targetid, pInfo[playerid][t_stringtmp], duration);
                                                        PenaltyTextdraw(playerid, targetid, pInfo[playerid][t_stringtmp], "Blokada biegania");
                                                }
                                                case 3: // Blokada bicia
                                                {
                                                        pInfo[targetid][FIGHT_block] = 1;
                                                        BlockFight(playerid, targetid, pInfo[playerid][t_stringtmp], duration);
                                                        PenaltyTextdraw(playerid, targetid, pInfo[playerid][t_stringtmp], "Blokada bicia");
                                                }
                                        }
                                }
                                case 2: // 24h
                                {
                                        new duration = gettime() + 24*(60*60);
                                        new targetid = pInfo[playerid][t_dialogtmp2];
                                       
                                        switch(pInfo[playerid][t_dialogtmp1])
                                        {
                                                case 1: // Blokada OOC
                                                {
                                                        pInfo[targetid][OOC_block] = 1;
                                                        BlockOOC(playerid, targetid, pInfo[playerid][t_stringtmp], duration);
                                                        PenaltyTextdraw(playerid, targetid, pInfo[playerid][t_stringtmp], "Blokada czatu OOC");
                                                }
                                                case 2: // Blokada biegania
                                                {
                                                        pInfo[targetid][RUN_block] = 1;
                                                        BlockSprint(playerid, targetid, pInfo[playerid][t_stringtmp], duration);
                                                        PenaltyTextdraw(playerid, targetid, pInfo[playerid][t_stringtmp], "Blokada biegania");
                                                }
                                                case 3: // Blokada bicia
                                                {
                                                        pInfo[targetid][FIGHT_block] = 1;
                                                        BlockFight(playerid, targetid, pInfo[playerid][t_stringtmp], duration);
                                                        PenaltyTextdraw(playerid, targetid, pInfo[playerid][t_stringtmp], "Blokada bicia");
                                                }
                                        }
                                }
                                case 3: // Tydzie�
                                {
                                        new duration = gettime() + 7*24*(60*60);
                                        new targetid = pInfo[playerid][t_dialogtmp2];
                                       
                                        switch(pInfo[playerid][t_dialogtmp1])
                                        {
                                                case 1: // Blokada OOC
                                                {
                                                        pInfo[targetid][OOC_block] = 1;
                                                        BlockOOC(playerid, targetid, pInfo[playerid][t_stringtmp], duration);
                                                        PenaltyTextdraw(playerid, targetid, pInfo[playerid][t_stringtmp], "Blokada czatu OOC");
                                                }
                                                case 2: // Blokada biegania
                                                {
                                                        pInfo[targetid][RUN_block] = 1;
                                                        BlockSprint(playerid, targetid, pInfo[playerid][t_stringtmp], duration);
                                                        PenaltyTextdraw(playerid, targetid, pInfo[playerid][t_stringtmp], "Blokada biegania");
                                                }
                                                case 3: // Blokada bicia
                                                {
                                                        pInfo[targetid][FIGHT_block] = 1;
                                                        BlockFight(playerid, targetid, pInfo[playerid][t_stringtmp], duration);
                                                        PenaltyTextdraw(playerid, targetid, pInfo[playerid][t_stringtmp], "Blokada bicia");
                                                }
                                        }
                                }
                        }
                }
                case 109:
                {
                        if(!response) return ShowPlayerDialog(playerid, 102, DIALOG_STYLE_LIST, "Admin Control Panel", "Podstawowe komendy\nBlokady\nDodatki", "Wybierz", "Anuluj");
                       
                        switch(listitem)
                        {
                                case 0: // Teleportacja
                                {
                                        ShowPlayerDialog(playerid, 110, DIALOG_STYLE_INPUT, "Teleportuj", "Wpisz ID graczy kt�rych chcesz teleportowa� w formacie:\n\
                                                                                                                                                                                ID teleportowanego;ID gracza docelowego", "Akceptuj", "Anuluj");
                                        pInfo[playerid][t_dialogtmp1] = 1;
                                }
                                case 1: // Slapowanie
                                {
                                        ShowPlayerDialog(playerid, 110, DIALOG_STYLE_INPUT, "Slapuj", "Wpisz ID gracza kt�rego chcesz zeslapowa�.", "Slap", "Anuluj");
                                        pInfo[playerid][t_dialogtmp1] = 2;
                                }
                                case 2: // Nadaj HP
                                {
                                        ShowPlayerDialog(playerid, 110, DIALOG_STYLE_INPUT, "Nadaj HP", "Wpisz dane w formacie:\n\
                                                                                                                                                                                ID gracza;Ilo�� �ycia", "Akceptuj", "Anuluj");
                                        pInfo[playerid][t_dialogtmp1] = 3;
                                }
                                case 3: // Nadaj pancerz
                                {
                                        ShowPlayerDialog(playerid, 110, DIALOG_STYLE_INPUT, "Nadaj pancerz", "Wpisz dane w formacie:\n\
                                                                                                                                                                                        ID gracza;Ilo�� pancerza", "Akceptuj", "Anuluj");
                                        pInfo[playerid][t_dialogtmp1] = 4;
                                }
                                case 4: // Spec
                                {
                                        ShowPlayerDialog(playerid, 110, DIALOG_STYLE_INPUT, "Spectating", "Wpisz ID gracza kt�rego chcesz podgl�da�.", "Akceptuj", "Anuluj");
                                        pInfo[playerid][t_dialogtmp1] = 5;
                                }
                        }
                }
                case 110:
                {
                        if(!response) return 1;
                       
                        switch(pInfo[playerid][t_dialogtmp1])
                        {
                                case 1: // Teleportacja
                                {
                                        new tar1, tar2, string[128];
                                        if(sscanf(inputtext, "p<;>dd", tar1, tar2))
                                        {
                                                ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Teleportuj", "Z�y format danych.", "OK", "");
                                        } else
                                        {
                                                format(string, sizeof(string), "%d %d", tar1, tar2);
                                                return cmd_tp(playerid, string);
                                        }
                                }
                                case 2: // Slapowanie
                                {
                                        new string[64];
                                        format(string, sizeof(string), "%d", strval(inputtext));
                                        return cmd_slap(playerid, string);
                                }
                                case 3: // Nadaj HP
                                {
                                        new tar1, value, string[64];
                                        if(sscanf(inputtext, "p<;>dd", tar1, value))
                                        {
                                                ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Nadaj HP", "Z�y format danych.", "OK", "");
                                        } else
                                        {
                                                format(string, sizeof(string), "%d %d", tar1, value);
                                                return cmd_zycie(playerid, string);
                                        }
                                }
                                case 4: // Nadaj pancerz
                                {
                                        new tar1, value, string[64];
                                        if(sscanf(inputtext, "p<;>dd", tar1, value))
                                        {
                                                ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Nadaj pancerz", "Z�y format danych.", "OK", "");
                                        } else
                                        {
                                                format(string, sizeof(string), "%d %d", tar1, value);
                                                return cmd_armor(playerid, string);
                                        }
                                }
                                case 5: // Spec
                                {
                                        new string[64];
                                        format(string, sizeof(string), "%d", strval(inputtext));
                                        return cmd_spec(playerid, string);
                                }
                        }
                }
				
		// == PHONES PART 2 == //
	    case 111:
		{
		   new phoneIDX = pInfo[playerid][lastUsedPhone];
		   if( pInfo[playerid][t_dialogtmp1] == 0 || response == 0 )
		   {
		      Query("SELECT * FROM phone_contacts WHERE phone=%d", true, "PhoneContactsListQuery" , Item[phoneIDX][uid]);
		      return 1;
		   }
		   
		   new Float:pyX, Float:pyY, Float:pyZ, pNr = 0, offerFor = -1;
		   GetPlayerPos(playerid, pyX, pyY, pyZ);
		   foreach (new p : Player)
		   {
			  if( p != playerid && pInfo[p][logged] == 1 && pInfo[p][lastUsedPhone] > -1 && IsPlayerInRangeOfPoint(p, 6.0, pyX, pyY, pyZ) && GetPlayerVirtualWorld(p) == GetPlayerVirtualWorld(playerid) )
			  {
                 if( pNr == listitem )
				 {
				   offerFor = p;
				   break;
				 }
				 pNr += 1;
			  }
		   }
		   
		   if( offerFor == -1 )
		   {
		      Query("SELECT * FROM phone_contacts WHERE phone=%d", true, "PhoneContactsListQuery" , Item[phoneIDX][uid]);
			  return 1;
		   }
		   
		   SendPlayerOffer(offerFor, playerid, OFFER_TYPE_VCARD, 0, phoneIDX);
		}
		
		case 112:
		{
		   new phoneIDX = pInfo[playerid][lastUsedPhone];
		   if(!response)
		   {
		     Query("SELECT * FROM phone_contacts WHERE phone=%d", true, "PhoneContactsListQuery" , Item[phoneIDX][uid]);
			 return 1;
		   }
		   
		   if( listitem == 2 )
		   {
			 return cmd_tel(playerid, pInfo[playerid][t_dialogtmp3]);
		   }
		   
		   if( listitem == 3 )
		   {
		     new msgTo[50];
			 format( msgTo, sizeof(msgTo), "Telefon � Wysy�anie wiadomo�ci do %d [2/2]", pInfo[playerid][t_dialogtmp3] );
		     ShowPlayerDialog(playerid, 116, DIALOG_STYLE_INPUT, BuildGuiCaption(msgTo), "Aby wys�a� wiadomo�c tekstow� na podany numer musisz poda� jej tre�� w poni�szym polu:", "Wy�lij", "Anuluj");
		   }
		   
		   if( listitem == 4 )
		   {
		     ShowPlayerDialog(playerid, 113, DIALOG_STYLE_INPUT, BuildGuiCaption("Telefon � Edycja kontaktu � Zmie� nazw�"), "Podaj now� nazw� kontaktu. Nazwa ta b�dzie r�wnie� wy�wietlana w spisie po��cze�, wiadomo�ciach oraz na ekranie po��czenia.", "Zapisz", "Anuluj");
		   }
		   
		   if( listitem == 5 )
		   {
		     ShowPlayerDialog(playerid, 114, DIALOG_STYLE_MSGBOX, BuildGuiCaption("Telefon � Edycja kontaktu � Usu�"), "Czy na pewno chcesz usun�� ten kontakt? Ta operacja jest permanentna.", "Usu�", "Anuluj");
		   }
		}
		
		case 113:
		{
		  new phoneIDX = pInfo[playerid][lastUsedPhone];
		  new Query[200];
		  if(response && !isnull(inputtext))
		  {
		    mysql_real_escape_string(inputtext, inputtext);
	        format( Query, sizeof(Query), "UPDATE phone_contacts SET `name`='%s' WHERE uid=%d", inputtext, pInfo[playerid][t_dialogtmp2] );
            mysql_function_query(mysqlHandle, Query, false, "", "");
		  }
		  
	      format( Query, sizeof(Query), "SELECT * FROM phone_contacts WHERE phone=%d LIMIT %d, 1", Item[phoneIDX][uid], pInfo[playerid][t_dialogtmp1] );
          mysql_function_query(mysqlHandle, Query, true, "PhoneContactEditQuery", "dd", playerid, pInfo[playerid][t_dialogtmp1]);
		}
		
		case 114:
		{
		  new phoneIDX = pInfo[playerid][lastUsedPhone];
		  if(response)
		  {
		    new Query[200];
	        format( Query, sizeof(Query), "DELETE FROM phone_contacts WHERE uid=%d", pInfo[playerid][t_dialogtmp2] );
            mysql_function_query(mysqlHandle, Query, false, "", "");
		  }
		  
		  Query("SELECT * FROM phone_contacts WHERE phone=%d", true, "PhoneContactsListQuery" , Item[phoneIDX][uid]);
		}
		
		case 115:
		{
		  new GUIcaption[64], phoneIDX = pInfo[playerid][lastUsedPhone];
		  format(GUIcaption, 64, "%s � Menu", Item[phoneIDX][name]);
		  if(!response || isnull(inputtext) || !IsNumeric(inputtext) || strlen(inputtext) != 7 || strval(inputtext) == Item[phoneIDX][value1]) return ShowPlayerDialog(playerid, 28, DIALOG_STYLE_LIST, BuildGuiCaption(GUIcaption), "Napisz wiadomo��\nPrzegl�daj wiadomo�ci", "Wybierz", "Zamknij"); 
		  
		  new phoneNr = strval(inputtext);
		  pInfo[playerid][t_dialogtmp3] = phoneNr;
		  		  
		  new msgTo[50];
		  format( msgTo, sizeof(msgTo), "Telefon � Wysy�anie wiadomo�ci do %d [2/2]", pInfo[playerid][t_dialogtmp3] );
		  ShowPlayerDialog(playerid, 116, DIALOG_STYLE_INPUT, BuildGuiCaption(msgTo), "Aby wys�a� wiadomo�c tekstow� na podany numer musisz poda� jej tre�� w poni�szym polu:", "Wy�lij", "Anuluj");
		  
		}
		
		case 116:
		{
		  new phoneIDX = pInfo[playerid][lastUsedPhone];
		  if( !response ) return OpenPhoneGUI(playerid, phoneIDX);
		  
		  if( isnull(inputtext) ) return OpenPhoneGUI(playerid, phoneIDX);
		  mysql_real_escape_string(inputtext, inputtext);
		  
		  SendPhoneMessage(playerid, pInfo[playerid][t_dialogtmp3], inputtext);		  
		}
		
		case 117:
		{
		  new GUIcaption[64], phoneIDX = pInfo[playerid][lastUsedPhone];
		  format(GUIcaption, 64, "%s � Menu", Item[phoneIDX][name]);
		  
		  if(!response) return ShowPlayerDialog(playerid, 28, DIALOG_STYLE_LIST, BuildGuiCaption(GUIcaption), "Napisz wiadomo��\nPrzegl�daj wiadomo�ci", "Wybierz", "Zamknij");
		  
		  if( pInfo[playerid][t_dialogtmp3] == 1 )
		  {
		    new Query[200];
	        format( Query, sizeof(Query), "SELECT * FROM phone_messages WHERE `from`=%d OR `to`=%d LIMIT %d,1", Item[phoneIDX][value1], Item[phoneIDX][value1], listitem );
            mysql_function_query(mysqlHandle, Query, true, "PhoneMessageDetailsQuery", "dd", playerid);
		  }
		}
		
		case 118:
		{
		  new phoneIDX = pInfo[playerid][lastUsedPhone];
		  Query("SELECT * FROM phone_messages WHERE `from`=%d OR `to`=%d", true, "PhoneMessagesListQuery" , Item[phoneIDX][value1], Item[phoneIDX][value1]);
		}
		
		case 119: // LSN
        {
            switch(pInfo[playerid][t_dialogtmp1])
            {
                case 1: // Wiadomo�ci
                {
                    ShowLSNBar(playerid, "~y~Wiadomosci", inputtext, 60000);
                }
				
                case 2: // Sport
                {
                    ShowLSNBar(playerid, "~y~Sport", inputtext, 60000);
                }
				
                case 3: // Pogoda
                {
                    ShowLSNBar(playerid, "~g~Pogoda", inputtext, 60000);
                }
				
                case 4: // Hot
                {
                    ShowLSNBar(playerid, "~r~Z ostatniej chwili", inputtext, 60000);
                }
				
                case 5: // Reklama
                {
                    format(pInfo[playerid][t_stringtmp], 128, "%s", inputtext);
                    ShowPlayerDialog(playerid, 120, DIALOG_STYLE_INPUT, "Reklama", "Wpisz dane w formacie:\n\
                                                                                    ID gracza;Cena;Czas[sekundy]", "Akceptuj", "Anuluj");
                }
				
                case 6: // Wywiad
                {
                    new targetid = strval(inputtext);
                                                       
                    if(IsPlayerInAnyVehicle(playerid))
                    {
                        new vID = GetPlayerVehicleID(playerid);
                        if(sVehInfo[vID][ownertype] == 1 && sVehInfo[vID][owner] == 10)
                        {
                            SendPlayerOffer(targetid, playerid, OFFER_TYPE_LIVE, 0, 0);
                        } else return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Ten pojazd nie nale�y do Los Santos Fresh News.");
                    }
                                                       
                    if(GetPlayerVirtualWorld(playerid) > 0 && GetPlayerVirtualWorld(targetid) > 0 && pInfo[playerid][hotelOutdoor] == 0 && pInfo[targetid][hotelOutdoor] == 0)
                    {
                        SendPlayerOffer(targetid, playerid, OFFER_TYPE_LIVE, 0, 0);
                    } else return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Jeden z uczestnik�w wywiadu nie znajduje si� w siedzibie LSN.");
                }
            }
        }
		
        case 120: // LSN
        {
            new targetid, pprice, ttime;
                                       
            if(sscanf(inputtext, "p<;>ddd", targetid, pprice, ttime))
            {
                ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Reklama", "Z�y format danych.", "OK", "");
            } 
			else
            {
                new ftime = ttime * 1000;
                                               
                SendPlayerOffer(targetid, playerid, OFFER_TYPE_ADVERTISMENT, pprice, ftime);
            }
        }
		
		case 121: //Bank
		{
		  if(!response) return 1;
		  
		  new Query[200], string1[300], bankNumber = GeneratePlayerBankNumber(playerid);
	      format( Query, sizeof(Query), "UPDATE `characters` SET `bank`=%d WHERE `uid`=%d", bankNumber, pInfo[playerid][uid] );
          mysql_function_query(mysqlHandle, Query, false, "", "");
		  
		  pInfo[playerid][bank] = bankNumber;
		  format(string1, sizeof(string1), "Twoje konto bankowe zosta�o pomy�lnie za�o�one!\n\n\
		                                    Numer konta: %d\n\
											Od teraz mo�esz dokonywa� wszelkich transakacji w banku\n\
											oraz bankomatach, kt�re mo�esz znale�� na terenie miasta.", bankNumber);
		  ShowPlayerDialog(playerid, 122, DIALOG_STYLE_MSGBOX, "Bank � Zak�adanie konta [2/2]", string1, "Dalej", "Zamknij");
		}
		
		case 122: // Bank
		{
		  if(!response) return 1;
		  
		  new string1[150], strprzel[50], strcapt[100];
		  if( pInfo[playerid][t_dialogtmp3] == 1 ) 
		  {
		   format(strprzel, sizeof(strprzel), "\nWp�ata\nPrzelew");
		   format(strcapt, sizeof(strcapt), "Bank");
		  }
		  else format(strcapt, sizeof(strcapt), "Bankomat");
		  format(string1, sizeof(string1), "Nr. rachunku: %d\n-----------------------\nSaldo konta\nWyp�ata%s", pInfo[playerid][bank], "\nPrzelew");
		  ShowPlayerDialog(playerid, 123, DIALOG_STYLE_LIST, strcapt, string1, "Wybierz", "Zamknij");
		}
		
		case 123: //Bank
		{
		  if(!response) return 1;
		  
		  if( listitem == 2 )
		  {
		    new string1[150];
			format(string1, sizeof(string1), "Pami�taj, �e wszelkie wyp�aty jakie dostaniesz pojawi� si� w�a�nie tu - na Twoim koncie bankowym.\n\
			                                  {DCD6BC}Aktualne saldo: $%d", pInfo[playerid][bankcash]);
		    ShowPlayerDialog(playerid, 124, DIALOG_STYLE_MSGBOX, "Bank � Saldo konta", string1, "Wr��", "");
		  }
		  else if( listitem == 3 )
		  {
		    ShowPlayerDialog(playerid, 125, DIALOG_STYLE_INPUT, "Bank � Wyp�ata", "Wpisz poni�ej kwote, kt�r� chcesz wyp�aci� ze swojego konta bankowego:", "Dalej", "Anuluj");
		  }
		  else if( listitem == 4 )
		  {
		    ShowPlayerDialog(playerid, 126, DIALOG_STYLE_INPUT, "Bank � Wp�ata", "Wpisz poni�ej kwote, kt�r� chcesz wp�aci� na swoje konto bankowe:", "Dalej", "Anuluj");
		  }
		  else if( listitem == 5 )
		  {
		    ShowPlayerDialog(playerid, 127, DIALOG_STYLE_INPUT, "Bank � Przelew [1/3]", "Wpisz poni�ej numer konta, na kt�ry chcesz przela� pieni�dze:", "Dalej", "Anuluj"); 
		  }
		}
		
		case 124: //Bank
		{
		  new string1[150], strprzel[50], strcapt[100];
		  if( pInfo[playerid][t_dialogtmp3] == 1 ) 
		  {
		   format(strprzel, sizeof(strprzel), "\nWp�ata\nPrzelew");
		   format(strcapt, sizeof(strcapt), "Bank");
		  }
		  else format(strcapt, sizeof(strcapt), "Bankomat");
		  format(string1, sizeof(string1), "Nr. rachunku: %d\n-----------------------\nSaldo konta\nWyp�ata%s", pInfo[playerid][bank], strprzel);
		  ShowPlayerDialog(playerid, 123, DIALOG_STYLE_LIST, strcapt, string1, "Wybierz", "Zamknij");
		}
		
		case 125: //Bank
		{
		  if(!response || !IsNumeric(inputtext))
		  {
		    new string1[150], strprzel[50], strcapt[100];
		    if( pInfo[playerid][t_dialogtmp3] == 1 ) 
		    { 
		      format(strprzel, sizeof(strprzel), "\nWp�ata\nPrzelew");
		      format(strcapt, sizeof(strcapt), "Bank");
		    }
		    else format(strcapt, sizeof(strcapt), "Bankomat");
		    format(string1, sizeof(string1), "Nr. rachunku: %d\n-----------------------\nSaldo konta\nWyp�ata%s", pInfo[playerid][bank], strprzel);
		    ShowPlayerDialog(playerid, 123, DIALOG_STYLE_LIST, strcapt, string1, "Wybierz", "Zamknij");
		  }
		  else
		  {
		    new tCash = strval(inputtext);
		    if( pInfo[playerid][bankcash] < tCash )
			{
		      ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Bank � Wyp�ata", "Na swoim koncie bankowym nie posiadasz takiej kwoty pieni�dzy.", "Zamknij", "");		  
			}
			else
			{
			  AddBankMoney(pInfo[playerid][bank], -tCash);
			  AddPlayerMoney(playerid, tCash);
			  ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Bank � Wyp�ata", "Wyp�aci�e� ��dan� kwot� pieni�dzy ze swojego konta bankowego.", "Zamknij", "");	
			}
		  }
		}
		
		case 126: //Bank
		{
		  if(!response || !IsNumeric(inputtext))
		  {
		    new string1[150], strprzel[50], strcapt[100];
		    if( pInfo[playerid][t_dialogtmp3] == 1 ) 
		    {
		     format(strprzel, sizeof(strprzel), "\nWp�ata\nPrzelew");
		     format(strcapt, sizeof(strcapt), "Bank");
		    }
		    else format(strcapt, sizeof(strcapt), "Bankomat");
		    format(string1, sizeof(string1), "Nr. rachunku: %d\n-----------------------\nSaldo konta\nWyp�ata%s", pInfo[playerid][bank], strprzel);
		    ShowPlayerDialog(playerid, 123, DIALOG_STYLE_LIST, strcapt, string1, "Wybierz", "Zamknij");
		  }
		  else
		  {
		    new tCash = strval(inputtext);
			if( pInfo[playerid][cash] < tCash )
			{
			  ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Bank � Wp�ata", "Przy sobie nie posiadasz takiej kwoty pieni�dzy.", "Zamknij", "");	
			}
			else
			{
			  AddBankMoney(pInfo[playerid][bank], tCash);
			  AddPlayerMoney(playerid, -tCash);
			  ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Bank � Wp�ata", "Wp�aci�e� ��dan� kwot� pieni�dzy na swoje konto bankowe.", "Zamknij", "");	
			}
		  }
		}
		
		case 127: //Bank
		{
		  if(!response || !IsNumeric(inputtext))
		  {
		    new string1[150], strprzel[50], strcapt[100];
		    if( pInfo[playerid][t_dialogtmp3] == 1 ) 
		    {
		     format(strprzel, sizeof(strprzel), "\nWp�ata\nPrzelew");
		     format(strcapt, sizeof(strcapt), "Bank");
		    }
		    else format(strcapt, sizeof(strcapt), "Bankomat");
		    format(string1, sizeof(string1), "Nr. rachunku: %d\n-----------------------\nSaldo konta\nWyp�ata%s", pInfo[playerid][bank], strprzel);
		    ShowPlayerDialog(playerid, 123, DIALOG_STYLE_LIST, strcapt, string1, "Wybierz", "Zamknij");
		  }
		  else
		  {
		    pInfo[playerid][t_dialogtmp1] = strval(inputtext);
			
			new Query[200];
            format( Query, sizeof(Query), "SELECT `uid` FROM `characters` WHERE `bank`=%d", pInfo[playerid][t_dialogtmp1] );
            mysql_function_query(mysqlHandle, Query, true, "PrzelewBank", "d", playerid);  
		  }
		}
		
		case 128: //Bank
		{
		  if(!response || !IsNumeric(inputtext))
		  {
		    new string1[150], strprzel[50], strcapt[100];
		    if( pInfo[playerid][t_dialogtmp3] == 1 ) 
		    {
		     format(strprzel, sizeof(strprzel), "\nWp�ata\nPrzelew");
		     format(strcapt, sizeof(strcapt), "Bank");
		    }
		    else format(strcapt, sizeof(strcapt), "Bankomat");
		    format(string1, sizeof(string1), "Nr. rachunku: %d\n-----------------------\nSaldo konta\nWyp�ata%s", pInfo[playerid][bank], strprzel);
		    ShowPlayerDialog(playerid, 123, DIALOG_STYLE_LIST, strcapt, string1, "Wybierz", "Zamknij");
		  }
		  else
		  {
		    new tCash = strval(inputtext);
			if( pInfo[playerid][cash] < tCash )
			{
			  ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Bank � Przelew", "Na swoim koncie bankowym nie posiadasz takiej kwoty pieni�dzy.", "Zamknij", "");	
			}
			else
			{
			  pInfo[playerid][t_dialogtmp2] = tCash;
			  new string1[300];
	          format(string1, sizeof(string1), "{f90012}Ta akcja wymaga potwierdzenia, poniewa� jest nieodwracalna.\n\n\
			                                    {a9c4e4}Czy na pewno chcesz przela� $%d na konto %d?\n\
												Aby potwierdzi� t� akcj�, wpisz poni�ej 'potwierdzam':", pInfo[playerid][t_dialogtmp2], pInfo[playerid][t_dialogtmp1]);
              ShowPlayerDialog(playerid, 129, DIALOG_STYLE_INPUT, "Bank � Przelew [3/3]", string1, "Dalej", "Anuluj"); 
			}		
		  }
		}
		
		case 129: //Bank
		{
		  if(!response)
		  {
		    new string1[150], strprzel[50], strcapt[100];
		    if( pInfo[playerid][t_dialogtmp3] == 1 ) 
		    {
		     format(strprzel, sizeof(strprzel), "\nWp�ata\nPrzelew");
		     format(strcapt, sizeof(strcapt), "Bank");
		    }
		    else format(strcapt, sizeof(strcapt), "Bankomat");
		    format(string1, sizeof(string1), "Nr. rachunku: %d\n-----------------------\nSaldo konta\nWyp�ata%s", pInfo[playerid][bank], strprzel);
		    ShowPlayerDialog(playerid, 123, DIALOG_STYLE_LIST, strcapt, string1, "Wybierz", "Zamknij");
		  }
		  else
		  {
		    if( !strcmp(inputtext, "potwierdzam", true) )
			{
			  if( pInfo[playerid][t_dialogtmp2] > pInfo[playerid][bankcash] )
			  {
			    return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Bank � Przelew", "Transakcja zosta�a anulowana, poniewa� na swoim koncie nie masz wymaganej ilo�ci pieni�dzy.", "Zamknij", "");	
			  }
			  AddBankMoney(pInfo[playerid][t_dialogtmp1], pInfo[playerid][t_dialogtmp2]);
			  AddBankMoney(pInfo[playerid][bank], -pInfo[playerid][t_dialogtmp2]);
			  ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Bank � Przelew", "Transakcja zosta�a wykonana, a pieni�dz� powinny znajdowa� si� na docelowym koncie.", "Zamknij", "");	
			}
			else
			{
			  ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Bank � Przelew", "Transakcja zosta�a anulowana, poniewa� jej nie potwierdzi�e�.", "Zamknij", "");	
			}
		  }
		}
		
		case 130: //sklep z ciuchami
		{
		  if(!response) return 1;
		  
		  if( listitem == 0 )
		  {
		    HideItemList(playerid);
		    DestroyClothesMenu(playerid);
		
	        pInfo[playerid][clothes_gui] = 1;
	        pInfo[playerid][clothes_page] = 0;
	    
	        CreateClothesMenu(playerid);
	        SelectTextDraw(playerid, 0xACCBF1FF);
		  }
		}
		
		case 140:
		{
			if(!response) return 1;
			//bartek chujem
			switch(listitem)
			{
				case 0:
				{
					if(groups[pInfo[playerid][t_dialogtmp2]][type] != 1) return ShowPlayerDialog(playerid, 140, DIALOG_STYLE_LIST, "Magazyn", "Gastronomia\nWarsztat\nGangi\nMafia\nPolicja", "Wybierz", "Wyjd�");
					mysql_function_query(mysqlHandle, "SELECT * FROM `plerp_items` WHERE `owner_type` = 8 AND `owner_id` = 1", true, "StoreToBuy", "i", playerid);
					return 1;
				}
				case 1:
				{
					if(groups[pInfo[playerid][t_dialogtmp2]][type] != 3) return ShowPlayerDialog(playerid, 140, DIALOG_STYLE_LIST, "Magazyn", "Gastronomia\nWarsztat\nGangi\nMafia\nPolicja", "Wybierz", "Wyjd�");
					mysql_function_query(mysqlHandle, "SELECT * FROM `plerp_items` WHERE `owner_type` = 8 AND `owner_id` = 3", true, "StoreToBuy", "i", playerid);
					return 1;
				}
				case 2:
				{
					if(groups[pInfo[playerid][t_dialogtmp2]][type] != 10) return ShowPlayerDialog(playerid, 140, DIALOG_STYLE_LIST, "Magazyn", "Gastronomia\nWarsztat\nGangi\nMafia\nPolicja", "Wybierz", "Wyjd�");
					mysql_function_query(mysqlHandle, "SELECT * FROM `plerp_items` WHERE `owner_type` = 8 AND `owner_id` = 13", true, "StoreToBuy", "i", playerid);
					return 1;
				}
				case 3:
				{
					if(groups[pInfo[playerid][t_dialogtmp2]][type] != 9) return ShowPlayerDialog(playerid, 140, DIALOG_STYLE_LIST, "Magazyn", "Gastronomia\nWarsztat\nGangi\nMafia\nPolicja", "Wybierz", "Wyjd�");
					mysql_function_query(mysqlHandle, "SELECT * FROM `plerp_items` WHERE `owner_type` = 8 AND `owner_id` = 12", true, "StoreToBuy", "i", playerid);
					return 1;
				}
				case 4:
				{
					if(groups[pInfo[playerid][t_dialogtmp2]][type] != 4) return ShowPlayerDialog(playerid, 140, DIALOG_STYLE_LIST, "Magazyn", "Gastronomia\nWarsztat\nGangi\nMafia\nPolicja", "Wybierz", "Wyjd�");
					mysql_function_query(mysqlHandle, "SELECT * FROM `plerp_items` WHERE `owner_type` = 8 AND `owner_id` = 4", true, "StoreToBuy", "i", playerid);
					return 1;
				}
			}
		
		
		}
		case 141:
		{	
			if(!response) return ShowPlayerDialog(playerid, 140, DIALOG_STYLE_LIST, "Magazyn", "Gastronomia\nWarsztat\nGangi\nMafia\nPolicja", "Wybierz", "Wyjd�");
			pInfo[playerid][t_dialogtmp1] = strval(inputtext);
			ShowPlayerDialog(playerid, 142, DIALOG_STYLE_INPUT, "Magazyn -> Step 1", "Podaj cene za kt�r� zamierzasz sprzedawa� przedmiot.\nPami�taj, �e zawsze mo�esz j� zmieni�.", "Ok", "Zamknij");
		
		}
		case 142:
		{
			if(!response) return ShowPlayerDialog(playerid, 140, DIALOG_STYLE_LIST, "Magazyn", "Gastronomia\nWarsztat\nGangi\nMafia\nPolicja", "Wybierz", "Wyjd�");
			pInfo[playerid][t_dialogtmp3] = strval(inputtext);
			if(pInfo[playerid][t_dialogtmp3] < 1 || pInfo[playerid][t_dialogtmp3] > 2000000) return ShowPlayerDialog(playerid, 141, DIALOG_STYLE_INPUT, "Magazyn -> Step 1", "Kwota musi by� wi�ksza od 0 i nie wi�ksza od 2 000 000.\nPodaj cene za kt�r� zamierzasz sprzedawa� przedmiot.\nPami�taj, �e zawsze mo�esz j� zmieni�.", "Ok", "Zamknij");
			ShowPlayerDialog(playerid, 143, DIALOG_STYLE_INPUT, "Magazyn -> Step 2", "Podaj ilo�� produkt�w kt�r� zamierasz zakupi�.", "Ok", "Zamknij");
		}
		case 143:
		{
			if(!response) return ShowPlayerDialog(playerid, 140, DIALOG_STYLE_LIST, "Magazyn", "Gastronomia\nWarsztat\nGangi\nMafia\nPolicja", "Wybierz", "Wyjd�");
			if(strval(inputtext) < 1 || strval(inputtext) > 100) return ShowPlayerDialog(playerid, 142, DIALOG_STYLE_INPUT, "Magazyn -> Step 2", "Podana ilo�� produkt�w jest nieprawid�owa, liczba musi mie�ci� si� w przedziale 1, 100.\n Podaj ilo�� produkt�w kt�r� zamierasz zakupi�", "Ok", "Zamknij");
			new zapytanie[60];
			format(zapytanie, sizeof(zapytanie), "SELECT * FROM `plerp_items` WHERE `uid` = %i", pInfo[playerid][t_dialogtmp1]);
			mysql_function_query(mysqlHandle, zapytanie, true, "StoreToBuyS2", "ii", playerid, strval(inputtext));
		
		}
		case 144:
		{
			if(!response) return 1;
			new zapytanie[120];
			format(zapytanie, sizeof(zapytanie), "SELECT * FROM `plerp_items` WHERE `uid` = %i", strval(inputtext));
			mysql_function_query(mysqlHandle, zapytanie, true, "GdzieDos", "i", playerid);
		}

		case 155: // CMD:wydaj -> rejestracja
        {
            new targetid, pprice, vuid;
                       
            if(sscanf(inputtext, "p<;>ddd", targetid, vuid, pprice))
            {
                ShowPlayerDialog(playerid, 1, DIALOG_STYLE_INPUT, "Wydaj tablice rejestracyjne", "Z�y format danych.", "OK", "");
            } else
            {
                SendPlayerOffer(targetid, playerid, OFFER_TYPE_REGISTRATION, pprice, vuid);
            }
        }
	}
	return 1;
}

forward PrzelewBank(playerid);
public PrzelewBank(playerid)
{
  new rows, fields;
  cache_get_data( rows, fields, mysqlHandle);
  if( rows == 1 )
  {
    new string1[100];
	format(string1, sizeof(string1), "Wpisz poni�ej kwote, kt�r� chcesz przela� na konto %d:", pInfo[playerid][t_dialogtmp1]);
    ShowPlayerDialog(playerid, 128, DIALOG_STYLE_INPUT, "Bank � Przelew [2/3]", string1, "Dalej", "Anuluj"); 
  }
  else
  {
    ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Bank � Przelew", "Konto o podanym numerze nie istnieje w naszym banku.", "Zamknij", "");	
  }
}

public OnPlayerCommandReceived(playerid, cmdtext[])
{
        new cmdName[32];
		sscanf(cmdtext, "s[64] ", cmdName);
		if( pInfo[playerid][bw] > 0 )
		{
          if( !strcmp(cmdName, "/do", true) || !strcmp(cmdName, "/usmierc", true) || !strcmp(cmdName, "/unbw", true) ) {}
		  else 
		  {
		      SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Podczas BW mo�esz jedynie u�ywa� komendy /do, /report oraz /usmierc.");
              return 0;
		  } 
		}
		
		if( pInfo[playerid][OOC_block] == 1 && !strcmp(cmdName, "/b", true) )
		{
		   SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Na Twoj� posta� na�o�ona jest blokada czatu ooc.");
		   return 0;
		}
        return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
	return 1;
}

forward PlayerSpawnChangeList(playerid);
public PlayerSpawnChangeList(playerid)
{
   new rows, fields;
   cache_get_data( rows, fields, mysqlHandle);
   if( rows > 0 )
   {
	  new spawnPlaces[456], spawnName[64], spawnUid[10];
	  format( spawnPlaces, 456, "1. Centrum miasta, spawn podstawowy\n" );
	  for(new i=0;i<rows;i++)
	  {
         cache_get_field_content(i, "uid", spawnUid);
         cache_get_field_content(i, "doorsName", spawnName);

         format(spawnPlaces, 456, "%s%d. %s\t[UID:%d]\n", spawnPlaces, i+2, spawnName, strval(spawnUid));
	  }
	  ShowPlayerDialog(playerid, 22, DIALOG_STYLE_LIST, BuildGuiCaption("Zmiana miejsca spawnu"), spawnPlaces, "Wybierz", "Zamknij");
   }
   else
   {
      ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("B��d"), "Nie masz �adnych miejsc, w kt�rych mo�esz si� spawnowa�.", "Zamknij", "");
   }
   return 1;
	
}

public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
   // -- /v namierz -- //
   if( checkpointid == carNamierz[playerid][0] )
   {
     DestroyDynamicCP(carNamierz[playerid][0]);
	 DestroyDynamicMapIcon(carNamierz[playerid][1]);
		   
	SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Namierzanie pojazdu zosta�o wy��czone.");
   }   
   if( checkpointid == Dostawa[playerid][0] && Dostawa[playerid][2] == 1)
   {
     DestroyDynamicCP(Dostawa[playerid][0]);
	 DestroyDynamicMapIcon(Dostawa[playerid][1]);
	 Dostawa[playerid][2] = 0;
   }   
   if(checkpointid == Dostawa[playerid][0] && Dostawa[playerid][2] == 2)
   {
     DestroyDynamicCP(Dostawa[playerid][0]);
	 DestroyDynamicMapIcon(Dostawa[playerid][1]);
	 new zapytanie[60];
	 format(zapytanie, sizeof(zapytanie), "SELECT * FROM `plerp_items` WHERE `uid` = %i", Dostawa[playerid][3]);
	 mysql_function_query(mysqlHandle, zapytanie, true, "DosFin", "iii", playerid, Dostawa[playerid][4], Dostawa[playerid][5]);
	 Dostawa[playerid][2] = 0;
	 Dostawa[playerid][3] = 0;
	 Dostawa[playerid][4] = 0;
	 Dostawa[playerid][5] = 0;
	 printf("dostarczono paczke o UID %i", Dostawa[playerid][3]);
   }
}

public OnPlayerSelectDynamicObject(playerid, objectid, modelid, Float:x, Float:y, Float:z)
{
   if( objects[objectid][objectUid] == 0 )
   {
	 EditDynamicObject(playerid, objectid);
	 CancelEdit(playerid);
   }
   else
   {
	 new adminsGroup = GetGroupByUid(1);
     new areaId;
	 
	 if( IsPlayerInGroup(playerid, adminsGroup) ) goto skip;
	 if( GetPlayerVirtualWorld(playerid) > 0 && pInfo[playerid][hotelOutdoor] == 0 )
     {
	     areaId = GetDoorsByUid(GetPlayerVirtualWorld(playerid));
	 }
	 else return 1;
	 
     if( !HasPermissionToEditDoors(playerid, areaId) ) return 1;
     skip:
     EditDynamicObject(playerid, objectid);
	 PlayerTextDrawShow(playerid, objectInfoTd);
	 UpdateObjectInfoTextDraw(playerid, objectid, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
	 pInfo[playerid][editedObject] = objectid;
   }
   
   return 1;
}

public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
        if(!response)
        {
                ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Edycja obiektu", "Anulowa� edycje obiektu", "OK", "");
                pInfo[playerid][EditorAttItem] = -1;
                RemovePlayerAttachedObject(playerid, 5);
        }
        else
        {
                if(pInfo[playerid][EditorAttItem] == -1) return 1;
                new zapytanie[500];
                format(zapytanie, sizeof(zapytanie), "UPDATE `plerp_atach` SET `pos_x` = %f, `pos_y` = %f, `pos_z` = %f, `rot_x` = %f, `rot_y` = %f, `rot_z` = %f, `scale_x` = %f, `scale_y` = %f, `scale_z` = %f WHERE `uid` = %i", fOffsetX, fOffsetY, fOffsetZ, fRotX, fRotY, fRotZ, fScaleX, fScaleY, fScaleZ, Item[pInfo[playerid][EditorAttItem]][value1]);
                mysql_function_query(mysqlHandle, zapytanie, false, "", "");
                RemovePlayerAttachedObject(playerid, 5);
        }
        return 1;
}

public OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
   if( response == EDIT_RESPONSE_FINAL)
   {
	 SetDynamicObjectPos(objectid, x, y, z);
	 SetDynamicObjectRot(objectid, rx, ry, rz);
     Streamer_UpdateEx(playerid, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
     new Query[256];
     format( Query, sizeof(Query), "UPDATE `objects` SET `x`='%f', `y`='%f', `z`='%f', `rotX`='%f', `rotY`='%f', `rotZ`='%f' WHERE `id`='%d'", x, y, z, rx, ry, rz, objects[objectid][objectUid]);
     mysql_function_query(mysqlHandle, Query, false, "", "");
	 PlayerTextDrawHide(playerid, objectInfoTd);
	 pInfo[playerid][editedObject] = -1;
	 
	 PrepareActionObject(objectid, 1);
	 
   }
   else if( response == EDIT_RESPONSE_UPDATE )
   {
      UpdateObjectInfoTextDraw(playerid, objectid, x, y, z, rx, ry, rz);
   }
   else if( response == EDIT_RESPONSE_CANCEL )
   {
      PlayerTextDrawHide(playerid, objectInfoTd);
	  pInfo[playerid][editedObject] = -1;
   }
   
   return 1;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if( playertextid == offersTd[4] )
    {
	  HandleOfferResponse(playerid, 1);
      CancelSelectTextDraw(playerid);
    }
    else if( playertextid == offersTd[5] )
    {
      HandleOfferResponse(playerid, 0);
      CancelSelectTextDraw(playerid);
    }
    else if( playertextid == phoneBarUpper[1] )
    {
	  HandleCallAction(playerid, 1);
      CancelSelectTextDraw(playerid);
    }
    else if( playertextid == phoneBarUpper[2] )
    {
      HandleCallAction(playerid, 0);
      CancelSelectTextDraw(playerid);
    }
	else if( playertextid == phoneBarUpper[4] )
	{
	  new phoneIDX = pInfo[playerid][lastUsedPhone];
	  PlayerTextDrawHide(playerid, phoneBarUpper[4]);
	  CancelSelectTextDraw(playerid);
	  Query("SELECT * FROM phone_messages WHERE `from`=%d OR `to`=%d", true, "PhoneMessagesListQuery" , Item[phoneIDX][value1], Item[phoneIDX][value1]);
	}
    
	new curpage = pInfo[playerid][clothes_page];
	
	// Handle: next button
	if(playertextid == gNextButtonTextDrawId[playerid]) {
	    if(curpage < (GetNumberOfPages() - 1)) {
	        pInfo[playerid][clothes_page] = curpage + 1;
	        ShowPlayerModelPreviews(playerid);
         	UpdatePageTextDraw(playerid);
         	PlayerPlaySound(playerid, 1083, 0.0, 0.0, 0.0);
		} else {
		    PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
		}
		return 1;
	}
	
	// Handle: previous button
	if(playertextid == gPrevButtonTextDrawId[playerid]) {
	    if(curpage > 0) {
	    	pInfo[playerid][clothes_page] = curpage - 1;
	    	ShowPlayerModelPreviews(playerid);
	    	UpdatePageTextDraw(playerid);
	    	PlayerPlaySound(playerid, 1084, 0.0, 0.0, 0.0);
		} else {
		    PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
		}
		return 1;
	}
	
	// Search in the array of textdraws used for the items
	new x=0;
	while(x != SELECTION_ITEMS) {
	    if(playertextid == gSelectionItems[playerid][x]) {
	        HandlePlayerItemSelection(playerid, x);
	        PlayerPlaySound(playerid, 1083, 0.0, 0.0, 0.0);
	        DestroyClothesMenu(playerid);
	        CancelSelectTextDraw(playerid);
        	pInfo[playerid][clothes_gui] = 0;
        	return 1;
		}
		x++;
	}
	
	HandleItemsList(playerid, playertextid);
	
	return 0;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(clickedid == td_911)
    {
        new string[512], gID[2];
        gID[0] = FindGroupByUID(5);
        gID[1] = FindGroupByUID(8);
        if(IsPlayerInGroupType(playerid, gID[0]))
        {
            format(string, sizeof(string), "Zg�aszaj�cy: %s\nMiejsce: %s\nNapastnicy: %s\nOpis napastnik�w: %s\nRodzaj: %s\nCzas zdarzenia: %s",
                                                                                        GroupReport[Iter_Last(GroupReports[gID[0]])][caller],
                                                                                        GroupReport[Iter_Last(GroupReports[gID[0]])][place],
                                                                                        GroupReport[Iter_Last(GroupReports[gID[0]])][attackers],
                                                                                        GroupReport[Iter_Last(GroupReports[gID[0]])][details],
                                                                                        GroupReport[Iter_Last(GroupReports[gID[0]])][type],
                                                                                        GroupReport[Iter_Last(GroupReports[gID[0]])][r_date]);
                       
            ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "911 -> Zgloszenie", string, "OK", "");
        } else if(IsPlayerInGroupType(playerid, gID[1]))
        {
            format(string, sizeof(string), "Zg�aszaj�cy: %s\nMiejsce: %s\nOfiary: %s\nRodzaj: %s\nCzas zdarzenia: %s",
                                                                                        GroupReport[Iter_Last(GroupReports[gID[1]])][caller],
                                                                                        GroupReport[Iter_Last(GroupReports[gID[1]])][place],
                                                                                        GroupReport[Iter_Last(GroupReports[gID[1]])][victims],
                                                                                        GroupReport[Iter_Last(GroupReports[gID[1]])][type],
                                                                                        GroupReport[Iter_Last(GroupReports[gID[1]])][r_date]);
                                                                                       
            ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "911 -> Zgloszenie", string, "OK", "");
        }
    }
	
	if(clickedid == Text:INVALID_TEXT_DRAW) {
	  if( pInfo[playerid][itemsPopupOpened] > 0 ) HideItemList(playerid);
	  if( pInfo[playerid][clothes_gui] == 1 ) DestroyClothesMenu(playerid);
	}
	
    return 1;
}

public OnQueryError(errorid, error[], callback[], query[], connectionHandle)
{
	new formatted[126];
	format(formatted, sizeof(formatted), "Something is wrong in query: %s",query);
	Crp->Notify("mysql", formatted);
	return 1;
}

COMMAND:v(playerid, params[])
{
   #pragma unused params
   CarsCommand(playerid, params);
   return 1;
}

COMMAND:tel(playerid, params[])
{
   #pragma unused params
   if( pInfo[playerid][lastUsedPhone] != -1 )
   {
      if( !isnull(params) )
      {
		  new numberTo;
		  if( sscanf(params, "d", numberTo) )
		  {
		    SendClientMessage(playerid, WHITE, "{999A9C}PLERP.net: /tel [numer(aby zadzwoni�)] (reszta opcji dost�pna w menu telefonu)");
		  }
		  else
		  {
		    if( numberTo == 911 )
			{
              // -- Setup Caller -- //
			  new numberAsString[32];
			  format(numberAsString, 32, "%d", numberTo);
		      PlayerTextDrawSetString(playerid, phoneBarUpper[0], "     Wybieranie numeru...");
		      PlayerTextDrawSetString(playerid, phoneBarUpper[3], numberAsString);
		      PlayerTextDrawShow(playerid, phoneBarUpper[0]);
		      PlayerTextDrawShow(playerid, phoneBarUpper[2]);
		      PlayerTextDrawShow(playerid, phoneBarUpper[3]);
		    
		      pCall[playerid][cCaller] = playerid;
		      pCall[playerid][cReceiver] = -911;
		      pCall[playerid][cState] = 1;
		      pCall[playerid][cTime] = 0;
		      pCall[playerid][cStarted] = gettime();
			  SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
		      // ---------------			
			  return 1;
 			}
			if( numberTo == 777)
			{
				  // -- Setup Caller -- //
				new vw = GetPlayerVirtualWorld(playerid);
				if(pInfo[playerid][hotelOutdoor] != 0 ) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Oferta -> B��d", "Nie posiadasz odpowiednich uprawnie�.", "Zamknij", "");
				if(vw == 0 ) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Oferta -> B��d", "Nie posiadasz odpowiednich uprawnie�.", "Zamknij", "");
				new doorsid = GetDoorsByUid(vw);
				if(doors[doorsid][type] != 0) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Oferta -> B��d", "Nie posiadasz odpowiednich uprawnie�.", "Zamknij", "");
				new IDXGroup = GetGroupByUid(doors[doorsid][owner]);
				if(IDXGroup == -1) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Oferta -> B��d", "Nie posiadasz odpowiednich uprawnie�.", "Zamknij", "");
				new PlayerSlot = GetGroupPlayerSlot(playerid, IDXGroup);
				if(PlayerSlot == -1) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Oferta -> B��d", "Nie posiadasz odpowiednich uprawnie�.", "Zamknij", "");
				if(!HasPlayerPermission(playerid, "group", GPREM_storage, PlayerSlot)) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Oferta -> B��d", "Nie posiadasz odpowiednich uprawnie�", "Zamknij", "");
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
				ShowPlayerDialog(playerid, 140, DIALOG_STYLE_LIST, "Magazyn", "Gastronomia\nWarsztat\nGangi\nMafia\nPolicja", "Wybierz", "Wyjd�");
				  // ---------------		
				pInfo[playerid][t_dialogtmp2] = IDXGroup;
				pInfo[playerid][t_dialogtmp4] = vw;
				return 1;
 			}
		    new callingTo = -1;
			foreach (new p : Player)
			{
			  if( Item[pInfo[p][lastUsedPhone]][value1] == numberTo && pInfo[p][logged] == 1 )
			  {
				callingTo = p;
			  }
			}
			if( callingTo == -1 )
			{
              SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Numer niepoprawny lub telefon wy��czony.");
			  return 1;
			}
			if( pCall[callingTo][cState] > 0 )
			{
              // -- Setup Caller -- //
			  new numberAsString[32];
			  format(numberAsString, 32, "%d", numberTo);
		      PlayerTextDrawSetString(playerid, phoneBarUpper[0], "     Numer zajety");
		      PlayerTextDrawSetString(playerid, phoneBarUpper[3], numberAsString);
		      PlayerTextDrawShow(playerid, phoneBarUpper[0]);
		      PlayerTextDrawShow(playerid, phoneBarUpper[3]);

		      pCall[playerid][cCaller] = playerid;
		      pCall[playerid][cReceiver] = callingTo;
		      pCall[playerid][cState] = 4;
		      pCall[playerid][cTime] = 0;
		      pCall[playerid][cStarted] = gettime();
			  SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
		      // ---------------
			  return 1;
			}
			
			// -- Setup Caller -- //
			new numberAsString[32];
			format(numberAsString, 32, "%d", numberTo);
		    PlayerTextDrawSetString(playerid, phoneBarUpper[0], "     Wybieranie numeru...");
		    PlayerTextDrawSetString(playerid, phoneBarUpper[3], numberAsString);
		    PlayerTextDrawShow(playerid, phoneBarUpper[0]);
		    PlayerTextDrawShow(playerid, phoneBarUpper[2]);
		    PlayerTextDrawShow(playerid, phoneBarUpper[3]);
		    
		    pCall[playerid][cCaller] = playerid;
		    pCall[playerid][cReceiver] = callingTo;
		    pCall[playerid][cState] = 1;
		    pCall[playerid][cTime] = 0;
		    pCall[playerid][cStarted] = gettime();
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
		    // ---------------
		    
		    // -- Setup Receiver -- //
		    format(numberAsString, 32, "%d", Item[pInfo[playerid][lastUsedPhone]][value1]);
		    PlayerTextDrawSetString(callingTo, phoneBarUpper[0], "     Polaczenie przychodzace");
		    PlayerTextDrawSetString(callingTo, phoneBarUpper[3], numberAsString);
		    PlayerTextDrawShow(callingTo, phoneBarUpper[0]);
		    PlayerTextDrawShow(callingTo, phoneBarUpper[1]);
		    PlayerTextDrawShow(callingTo, phoneBarUpper[2]);
		    PlayerTextDrawShow(callingTo, phoneBarUpper[3]);
		    
		    pCall[callingTo][cCaller] = playerid;
		    pCall[callingTo][cReceiver] = callingTo;
		    pCall[callingTo][cState] = 1;
		    pCall[callingTo][cTime] = 0;
		    pCall[callingTo][cStarted] = gettime();
			SetPlayerSpecialAction(callingTo, SPECIAL_ACTION_USECELLPHONE);
			// ----------------
		  }
      }
      else
	  {
	    OpenPhoneGUI(playerid, pInfo[playerid][lastUsedPhone]);
		SendClientMessage(playerid, WHITE, "{999A9C}PLERP.net: /tel [numer(aby zadzwoni�)] (reszta opcji dost�pna w menu telefonu)");
	  }	       
   }
   else
   {
     SendClientMessage(playerid, -1, "PLERP.net: Nie posiadasz �adnego w��czonego telefonu.");
   }
   
   return 1;
}

COMMAND:przedmioty(playerid, params[])
{
   #pragma unused params
   PrzedmiotyCommand(playerid, params);
   return 1;
}
COMMAND:p(playerid, params[])
{
   #pragma unused params
   cmd_przedmioty(playerid, params);
   return 1;
}
COMMAND:pos(playerid, params[])
{
   #pragma unused params
   new
	  Float:x,
	  Float:y,
	  Float:z;
   GetPlayerPos(playerid, x, y, z);
   printf( "x: %f, y: %f, z: %f", x, y, z);
   return 1;
}

COMMAND:do(playerid, params[])
{
	#pragma unused params
    if (isnull(params))
    {
       SendClientMessage(playerid, COLOR_GREY, "{999A9C}PLERP.net: /do [obserwacje]");
    }
    else
    {
       NewProx(playerid, "do", params);
    }
    return 1;
}

COMMAND:me(playerid, params[])
{
	#pragma unused params
    if (isnull(params))
    {
       SendClientMessage(playerid, COLOR_GREY, "{999A9C}PLERP.net: /me [czynno��]");
    }
    else
    {
       NewProx(playerid, "me", params);
    }
    return 1;
}

COMMAND:w(playerid, params[])
{
	cmd_wiadomosc(playerid, params);
    return 1;
}

COMMAND:wiadomosc(playerid, params[])
{
	#pragma unused params
    if (isnull(params))
    {
       SendClientMessage(playerid, COLOR_GREY, "{999A9C}PLERP.net: /(w)iadomosc [id gracza] [tre��]");
    }
    else
    {
	   new toId, sub[350];
       if( sscanf(params, "d s[350]", toId, sub) )
       {
         SendClientMessage(playerid, COLOR_GREY, "{999A9C}PLERP.net: /(w)iadomosc [id gracza] [tre��]");
       }
       else
       {
         if( IsPlayerConnected(toId) )
	     {
	       if( pInfo[toId][logged] == 1 )
	       {
	     	 new wMsg[350];
	     	 format(wMsg, 350, "%s", BeautyString(sub, true, true));
	     	 NewProxPersonal(playerid, toId, "pm", sub);
	       }
	       else SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Gracz do kt�rego pr�bujesz napisa� nie jest zalogowany.");
	     }
	     else SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Gracz do kt�rego pr�bujesz napisa� jest offline.");
       }
    }
    return 1;
}

COMMAND:g(playerid, params[])
{
	cmd_grupy(playerid, params);
    return 1;
}

COMMAND:grupy(playerid, params[])
{
	#pragma unused params
    GroupsCommand(playerid, params);
    return 1;
}

COMMAND:oadd(playerid, params[])
{
    #pragma unused params
	new areaId = -1;
	if( GetPlayerVirtualWorld(playerid) > 0 && pInfo[playerid][hotelOutdoor] == 0 )
    {
	    areaId = GetDoorsByUid(GetPlayerVirtualWorld(playerid));
	}
	
	new isAdmin = IsPlayerInGroupType(playerid, 0);
	new adminPerm = 0;
    if( isAdmin > -1 ) 
	{
	   if( HasPlayerPermission(playerid, "group", GPREM_special, pGroups[playerid][isAdmin][groupIndx]) ) adminPerm = 1;
	}
	
	if( areaId == -1 && adminPerm == 0 ) return 1;	
	if( areaId >= 0 )
	{
	  if( !HasPermissionToEditDoors(playerid, areaId) ) return 1;
	}
	
	new modelId;
	if( sscanf(params, "d", modelId) )
	{
	   SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /oadd [model]");
	}
	else
	{
	  if( areaId >= 0 )
	  {
	    new usedObjects = GetDoorsUsedObjects(doors[areaId][doorUid]);
	    if( doors[areaId][maxObjects]-usedObjects == 0 ) { SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Te drzwi osi�gn�y maksymaln� ilo�� obiekt�w."); return 1; }
	  }

	  new Float:oX, Float:oY, Float:oZ;
	  GetPlayerPos(playerid, oX, oY, oZ);
	  GetXYInfrontOfPlayer(playerid, oX, oY, 2.5);
        
	  new obVW, oowner, oownertype = OBJECT_OWNER_TYPE_GLOBAL;
	  if( areaId >= 0 ) 
	  {
	   obVW = doors[areaId][doorUid];
	   oownertype = OBJECT_OWNER_TYPE_DOORS;
	   oowner = doors[areaId][doorUid];
	  } 
	  else obVW = 0;

	  Object_Create(oownertype, oowner, modelId, obVW, oX, oY, oZ, 0.0, 0.0, 0.0);	
	}
	
	return 1;
}

COMMAND:odel(playerid, params[])
{
    #pragma unused params
	
	new areaId = -1;
	if( GetPlayerVirtualWorld(playerid) > 0 && pInfo[playerid][hotelOutdoor] == 0 )
    {
	    areaId = GetDoorsByUid(GetPlayerVirtualWorld(playerid));
	}
	
	new isAdmin = IsPlayerInGroupType(playerid, 0);
	new adminPerm = 0;
    if( isAdmin > -1 ) 
	{
	   if( HasPlayerPermission(playerid, "group", GPREM_special, pGroups[playerid][isAdmin][groupIndx]) ) adminPerm = 1;
	}
	
	if( areaId == -1 && adminPerm == 0 ) return 1;
	if( areaId >= 0 )
	{
	  if( !HasPermissionToEditDoors(playerid, areaId) ) return 1;
	}
	
	new objectId;
	if( sscanf(params, "d", objectId) )
	{
	   SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /odel [id obiektu]");
	}
	else
	{
	  if( areaId >= 0 )
      {
	    if( objects[objectId][objectVW] != doors[areaId][doorUid] ) { SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Obiekt o podanym ID nie nale�y do tych drzwi."); return 1; }
	  }
        
	  if( !IsValidDynamicObject(objectId) ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Obiekt o tym ID nie istnieje.");
		
	  if( pInfo[playerid][editedObject] == objectId )
	  {
		CancelEdit(playerid);
		PlayerTextDrawHide(playerid, objectInfoTd);
	  }
	  
	  Object_Remove(objectId);
      SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Obiekt o podanym ID zosta� usuni�ty.");
	}
	
	return 1;
}

COMMAND:osel(playerid, params[])
{
    #pragma unused params
	
	new areaId = -1;
	if( GetPlayerVirtualWorld(playerid) > 0 && pInfo[playerid][hotelOutdoor] == 0 )
    {
	    areaId = GetDoorsByUid(GetPlayerVirtualWorld(playerid));
	}
	
	new isAdmin = IsPlayerInGroupType(playerid, 0);
	new adminPerm = 0;
    if( isAdmin > -1 ) 
	{
	   if( HasPlayerPermission(playerid, "group", GPREM_special, pGroups[playerid][isAdmin][groupIndx]) ) adminPerm = 1;
	}
	
	if( areaId == -1 && adminPerm == 0 ) return 1;
	if( areaId >= 0 )
	{
	  if( !HasPermissionToEditDoors(playerid, areaId) ) return 1;
	}
	
	new modelId;
	if( sscanf(params, "d", modelId) )
	{
	   SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /osel [model]");
	}
	else
	{
       new objectId = GetClosestObjectWithType(playerid, modelId);
	   if( objectId == -1 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Brak obiektu o podanym modelu w odleg�o�ci 10 metr�w.");
		 
	   EditDynamicObject(playerid, objectId);
	   pInfo[playerid][editedObject] = objectId;
	   PlayerTextDrawShow(playerid, objectInfoTd);
	   UpdateObjectInfoTextDraw(playerid, objectId, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);	 
	}
	
	return 1;
}

COMMAND:ocopy(playerid, params[])
{
    #pragma unused params
		
	new areaId = -1;
	if( GetPlayerVirtualWorld(playerid) > 0 && pInfo[playerid][hotelOutdoor] == 0 )
    {
	    areaId = GetDoorsByUid(GetPlayerVirtualWorld(playerid));
	}
	
	new isAdmin = IsPlayerInGroupType(playerid, 0);
	new adminPerm = 0;
    if( isAdmin > -1 ) 
	{
	   if( HasPlayerPermission(playerid, "group", GPREM_special, pGroups[playerid][isAdmin][groupIndx]) ) adminPerm = 1;
	}
	
	if( areaId == -1 && adminPerm == 0 ) return 1;	
	if( areaId >= 0 )
	{
	  if( !HasPermissionToEditDoors(playerid, areaId) ) return 1;
	}
	
	if( pInfo[playerid][editedObject] != -1 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Aby skopiowa� obiekt, wy��cz tryb edycji obiektu.");
	
	new objectId;
	if( sscanf(params, "d", objectId) )
	{
	   return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /ocopy [id obiektu]");
	}
	else
	{
	   if( !IsValidDynamicObject(objectId) ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Obiekt o podanym ID nie istnieje.");
	   if( areaId >= 0 )
	   {
	      new usedObjects = GetDoorsUsedObjects(doors[areaId][doorUid]);
	      if( doors[areaId][maxObjects]-usedObjects == 0 ) { SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Te drzwi osi�gn�y maksymaln� ilo�� obiekt�w."); return 1; }
	   }
		
	   new Float:oX, Float:oY, Float:oZ, Float:oRX, Float:oRY, Float:oRZ;
       GetDynamicObjectPos(objectId, oX, oY, oZ);
	   GetDynamicObjectRot(objectId, oRX, oRY, oRZ);
        
	   oZ += 1.0;
		
	   new obVW = objects[objectId][objectVW];
	   new modelId = objects[objectId][model];
		
	   new oowner, otype = OBJECT_OWNER_TYPE_GLOBAL;
	   if( GetPlayerVirtualWorld(playerid) > 0 ) 
	   {
	     otype = OBJECT_OWNER_TYPE_DOORS;
		 oowner = GetPlayerVirtualWorld(playerid);
	   }	 

       new createdObject = Object_Create(otype, oowner, modelId, obVW, oX, oY, oZ, oRX, oRY, oRZ);
	   
	   EditDynamicObject(playerid, createdObject);
	   PlayerTextDrawShow(playerid, objectInfoTd);
	   UpdateObjectInfoTextDraw(playerid, createdObject, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
	   pInfo[playerid][editedObject] = createdObject;
	
	   SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Obiekt zosta� skopiowany i zaznaczony do edycji.");
	   
	}
	
    return 1;
}

COMMAND:s(playerid, params[])
{
        new option[64];
       
        if( IsPlayerInGroupType(playerid, 9) == -1 ) return 1;
       
        if(sscanf(params, "s[64]", option))
        {
                SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /s [wiadomosci/sport/pogoda/hot/reklama/live/stoplive]");
        } else
        {
                if(!strcmp(option, "wiadomosci", true))
                {
                        ShowPlayerDialog(playerid, 119, DIALOG_STYLE_INPUT, "Wpisz tre��", "Wpisz w poni�sze pole tre�� wiadomo�ci, kt�ra ma by� nadana na kanale radia Los Santos News:", "Akceptuj", "Anuluj");
                        pInfo[playerid][t_dialogtmp1] = 1;
                } else if(!strcmp(option, "sport", true))
                {
                        ShowPlayerDialog(playerid, 119, DIALOG_STYLE_INPUT, "Wpisz tre��", "Wpisz w poni�sze pole tre�� wiadomo�ci, kt�ra ma by� nadana na kanale radia Los Santos News:", "Akceptuj", "Anuluj");
                        pInfo[playerid][t_dialogtmp1] = 2;
                } else if(!strcmp(option, "pogoda", true))
                {
                        ShowPlayerDialog(playerid, 119, DIALOG_STYLE_INPUT, "Wpisz tre��", "Wpisz w poni�sze pole tre�� wiadomo�ci, kt�ra ma by� nadana na kanale radia Los Santos News:", "Akceptuj", "Anuluj");
                        pInfo[playerid][t_dialogtmp1] = 3;
                } else if(!strcmp(option, "hot", true))
                {
                        ShowPlayerDialog(playerid, 119, DIALOG_STYLE_INPUT, "Wpisz tre��", "Wpisz w poni�sze pole tre�� wiadomo�ci, kt�ra ma by� nadana na kanale radia Los Santos News:", "Akceptuj", "Anuluj");
                        pInfo[playerid][t_dialogtmp1] = 4;
                } else if(!strcmp(option, "reklama", true))
                {
                        ShowPlayerDialog(playerid, 119, DIALOG_STYLE_INPUT, "Wpisz tre��", "Wpisz w poni�sze pole tre�� reklamy, kt�ra ma by� nadana na kanale radia Los Santos News:", "Dalej", "Anuluj");
                        pInfo[playerid][t_dialogtmp1] = 5;
                } else if(!strcmp(option, "live", true))
                {
                        ShowPlayerDialog(playerid, 119, DIALOG_STYLE_INPUT, "Wywiad", "Wpisz ID gracza kt�rym chcesz przeprowadzi� wywiad.", "Akceptuj", "Anuluj");
                        pInfo[playerid][t_dialogtmp1] = 6;
                } else if(!strcmp(option, "stoplive", true))
                {
                        new string[128], pid;
                        if(pInfo[playerid][t_live] == 0) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie prowadzisz w tej chwili wywiadu na �ywo.");
                       
                        pInfo[playerid][t_live] = 0;
                        pInfo[pInfo[playerid][t_live_pid]][t_live] = 0;
                       
                        format(string, sizeof(string), "LSN: Zako�czy�e� wywiad na �ywo z %s.", pInfo[pid][name]);
                        SendClientMessage(playerid, COLOR_GREEN, string);
                        format(string, sizeof(string), "LSN: Dziennikarz %s zako�czy� wywiad na �ywo.", pInfo[playerid][name]);
                        SendClientMessage(playerid, COLOR_GREEN, string);
                }
                       
        }
        return 1;
}

COMMAND:drzwi(playerid, params[])
{
   new areaId = GetPlayerStandingInDoors(playerid);

   if( areaId != -1 )
   {
	 if( HasPermissionToEditDoors(playerid, areaId) )
	 {
		if( strlen(params) > 0 && (!strcmp( params, "z" ) || !strcmp( params, "zamknij" )) )
		{
		  if( doors[areaId][locked] )
		  {
		   doors[areaId][locked] = false;
		  }
		  else
		  {
		   doors[areaId][locked] = true;
		  }
		  ApplyAnimation(playerid, "BD_FIRE", "wash_up", 4.1, 0, 1, 1, 1, 1, 1);
		  defer ClearPlayerAnimation[1000](playerid);
		  return 1;
		}
        new string[64], autoClose[64], carsCrose[64], doorsOpt[300];
        format(string, 64, "Edycja drzwi - [UID: %d]", doors[areaId][doorUid]);
        // -- Auto locking format -- //
        format(autoClose, 64, "\nZamykanie drzwi po restarcie\t\tNie");
        if( doors[areaId][automaticLock] ) format(autoClose, 64, "\nZamykanie drzwi po restarcie\t\tTak");
		// -- Cars crosing format -- //
		format(carsCrose, 64, "\nPrzejazd pojazdami\t\t\tNie");
        if( doors[areaId][carCrosing] ) format(carsCrose, 64, "\nPrzejazd pojazdami\t\t\tTak");
        
        format(doorsOpt, 300, "Zmie� nazw�\nZmie� op�at� za wej�cie\nZarz�dzaj obiektami\n---------%s%s", autoClose, carsCrose);
	    ShowPlayerDialog(playerid, 13, DIALOG_STYLE_LIST, BuildGuiCaption(string), doorsOpt, "Wybierz", "Zamknij");
	 }
   }
   else
   {
      if( GetPlayerVirtualWorld(playerid) > 0 && pInfo[playerid][hotelOutdoor] == 0 )
      {
	     areaId = GetDoorsByUid(GetPlayerVirtualWorld(playerid));
		 if( !HasPermissionToEditDoors(playerid, areaId) ) return 1;
		 
         if( strlen(params) > 0 && (!strcmp( params, "z" ) || !strcmp( params, "zamknij" )) )
		 {
		   if( doors[areaId][locked] )
		   {
		    doors[areaId][locked] = false;
		   }
		   else
		   {
		    doors[areaId][locked] = true;
		   }
		   ApplyAnimation(playerid, "BD_FIRE", "wash_up", 4.1, 0, 1, 1, 1, 1, 1);
		   defer ClearPlayerAnimation[1000](playerid);
		   return 1;
		 }
         new string[64], autoClose[64], carsCrose[64], doorsOpt[400];
         format(string, 64, "Edycja drzwi - [UID: %d]", doors[areaId][doorUid]);
         // -- Auto locking format -- //
         format(autoClose, 64, "\nZamykanie drzwi po restarcie\t\tNie");
         if( doors[areaId][automaticLock] ) format(autoClose, 64, "\nZamykanie drzwi po restarcie\t\tTak");
         // -- Cars crosing format -- //
		 format(carsCrose, 64, "\nPrzejazd pojazdami\t\t\tNie");
         if( doors[areaId][carCrosing] ) format(carsCrose, 64, "\nPrzejazd pojazdami\t\t\tTak");
         
         format(doorsOpt, 400, "Zmie� nazw�\nZmie� op�at� za wej�cie\nZmie� poyzcj� wej�ciow�\nZarz�dzaj obiektami\n---------%s%s", autoClose, carsCrose);
         
	     ShowPlayerDialog(playerid, 13, DIALOG_STYLE_LIST, BuildGuiCaption(string), doorsOpt, "Wybierz", "Zamknij");
      }
   }
   return 1;
}

COMMAND:stats(playerid, params[])
{
  new string[64], options[428];
  new lastLoginF[64];
  format(lastLoginF, 54, "nigdy");
  if( pInfo[playerid][lastLogin] > 0 ) format(lastLoginF, 64, "%s", FormatDataForShow(pInfo[playerid][lastLogin]));
  
  format(string, 64, "Informacje o postaci - %s [UID %d, ID %d]", pInfo[playerid][name], pInfo[playerid][uid], playerid);
  
  new whereSpawn[64];
  if( GetPlayerSpawnType(playerid) == 0 ) format(whereSpawn, 64, "{CFFD66}Centrum miasta");
  new doorsUid;
  sscanf(pInfo[playerid][baseSpawn], "p<,>{d}d", doorsUid);
  new doorsId = GetDoorsByUid(doorsUid);
  
  if( GetPlayerSpawnType(playerid) == 1 ) format(whereSpawn, 64, "{CFFD66}Budynek: %s", doors[doorsId][name]);
  if( GetPlayerSpawnType(playerid) == 2 ) format(whereSpawn, 64, "{CFFD66}Hotel: %s", doors[doorsId][name]);
  
  // -- Time online format -- //
  new timeOnlineF[32], activeSkin[64], sexFormatted[32];
  format(timeOnlineF, 32, "%s", FormatTime(pInfo[playerid][timeOnline]));
  
  format( activeSkin, 64, "%d", GetPlayerSkin(playerid) );
  if( pInfo[playerid][activeClothes] > -1 )
  {
    if( Item[pInfo[playerid][activeClothes]][value1] == GetPlayerSkin(playerid) ) format( activeSkin, 64, "%s (ubranie)", activeSkin );
  }
  else if( GetPlayerSkin(playerid) != pInfo[playerid][skin] )
  {
    format( activeSkin, 64, "%s (grupowy)", activeSkin );
  }
  
  if( pInfo[playerid][sex] == 1 ) format( sexFormatted, 32, "kobieta" );
  else format( sexFormatted, 32, "m�czyzna" );
  
  format(options, 428, "[{ABABAB} Podstawowe informacje {FFFFFF}]\n Czas online\t\t\t{a9c4e4}%s\n Ostatnie logowanie\t\t{a9c4e4}%s\n P�e�\t\t\t\t{a9c4e4}%s\n Got�wka\t\t\t{a9c4e4}$%d\n Bank\t\t\t\t{a9c4e4}$%d (%d)\n Podstawowy skin\t\t{a9c4e4}%d\n Aktywny skin\t\t\t{a9c4e4}%s\n[{ABABAB} Spawn {FFFFFF}]\n %s\n   {a9c4e4}zmie� miejsce spawnu", timeOnlineF, lastLoginF, sexFormatted, pInfo[playerid][cash], pInfo[playerid][bankcash], pInfo[playerid][bank], pInfo[playerid][skin], activeSkin, whereSpawn);

  ShowPlayerDialog(playerid, 21, DIALOG_STYLE_LIST, BuildGuiCaption(string), options, "Wybierz", "Zamknij");
  return 1;
}

COMMAND:oferuj(playerid, params[])
{
   #pragma unused params
   
   new offersCmdHelp[200];
   format(offersCmdHelp, sizeof(offersCmdHelp), "{999A9C}PLERP.net: /(o)feruj [pojazd/drzwi]");
   
   if(isnull(params))
   {
     SendClientMessage(playerid, COLOR_GREY, offersCmdHelp);
   }
   else
   {
     new cmdParams[5][64];
     sscanf(params, "a<s[64]>[5]", cmdParams);
	 
	 if(isnull(cmdParams[0])) return SendClientMessage(playerid, COLOR_GREY, offersCmdHelp);
	 
	 if( !strcmp("pojazd", cmdParams[0], true) )
	 {
	    if(isnull(cmdParams[1]) || !IsNumeric(cmdParams[1]) || !IsPlayerConnected(strval(cmdParams[1])) || pInfo[strval(cmdParams[1])][logged] == 0 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /(o)feruj pojazd [id gracza] [cena]");
		if(isnull(cmdParams[2]) || !IsNumeric(cmdParams[2]) ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /(o)feruj pojazd [id gracza] [cena]");
		
		if( !IsPlayerInAnyVehicle(playerid) ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Aby oferowa� pojazd, musisz si� w nim znajdowa�.");
		
		new vID = GetPlayerVehicleID(playerid);
		if( !CanEditCar(playerid, vID) || sVehInfo[vID][ownertype] != 0 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie mo�esz oferowa� tego pojazdu.");
		
		new offerTo = strval(cmdParams[1]);
		new offerPrice = strval(cmdParams[2]);
		
		new Float:bX, Float:bY, Float:bZ;
		GetPlayerPos(offerTo, bX, bY, bZ);
		if( GetVehicleDistanceFromPoint(vID, bX, bY, bZ) > 10.0 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Gracz kt�remu sk�adasz ofert� znajduje si� zbyt daleko.");
		
		pInfo[playerid][t_dialogtmp1] = offerTo;
		pInfo[playerid][t_dialogtmp2] = offerPrice;
		pInfo[playerid][t_dialogtmp3] = vID;
		
	    new string2[350];
	    format(string2, sizeof(string2), "{f90012}Ta akcja wymaga potwierdzenia, poniewa� nie mo�esz cofn�� jej sam.\n\
	                                     {a9c4e4}Czy napewno chcesz sprzeda� pojazd %s o uid %d graczowi %s za kwot� $%d?\n\n\
										 {ffffff}Aby potwierdzi� sw�j wyb�r, wpisz w pole poni�ej 'potwierdzam'.", VehicleNames[sVehInfo[vID][model]-400], sVehInfo[vID][uid], pInfo[offerTo][tdnick], offerPrice);
	    ShowPlayerDialog(playerid, 75, DIALOG_STYLE_INPUT, BuildGuiCaption("Potwierd� akcj� -> Sprzeda� pojazdu"), string2, "Dalej","Anuluj");
	 }
	 
	 if(!strcmp("ulecz", cmdParams[0], true))
	 {
		if(isnull(cmdParams[1]) || !IsNumeric(cmdParams[1]) || !IsPlayerConnected(strval(cmdParams[1])) || pInfo[strval(cmdParams[1])][logged] == 0 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /(o)feruj ulecz [id gracza] [cena]");
		if(isnull(cmdParams[2]) || !IsNumeric(cmdParams[2]) ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /(o)feruj ulecz [id gracza] [cena]");
		new Float:pos[3];
		GetPlayerPos(strval(cmdParams[1]), pos[0], pos[1], pos[2]);
		if( GetPlayerDistanceFromPoint(playerid, pos[0], pos[1], pos[2]) > 10.0 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Gracz kt�remu sk�adasz ofert� znajduje si� zbyt daleko.");

		if(pInfo[playerid][currentDuty] == -1) return  ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX,("Oferty -> B��d"), "Aby u�y� tej komendy musisz by� na duty w s�u�bie zdrowia.", "Zamknij", "");
		if(groups[pGroups[playerid][pInfo[playerid][currentDuty]][groupIndx]][type] != 7)return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX,("Oferty -> B��d"), "Aby u�y� tej komendy musisz by� na duty w s�u�bie zdrowia.", "Zamknij", "");
		
		new offerTo = strval(cmdParams[1]);
		new offerPrice = strval(cmdParams[2]);
		if(offerPrice < 100 || offerPrice > 300) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX,("Oferty -> B��d"), "Kwota oferty musi by� w przedziale od 100$ do 300$.", "Zamknij", "");
		if(pInfo[offerTo][bwStatus] < 1) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX,("Oferty -> B��d"), "Nie mo�esz oferowa� leczenia temu graczowi, poniewa� ten nie jest os�abiony", "Zamknij", "");
		new Float:bX, Float:bY, Float:bZ;
		GetPlayerPos(offerTo, bX, bY, bZ);
		if(GetPlayerDistanceFromPoint(playerid, bX, bY, bZ) > 10.0 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Gracz kt�remu sk�adasz ofert� znajduje si� zbyt daleko.");
		SendPlayerOffer(offerTo, playerid, OFFER_TYPE_HEAL, offerPrice, 0);
	 }
	 
	 if(!strcmp("jazdy", cmdParams[0], true))
     {
        if(isnull(cmdParams[1]) || !IsNumeric(cmdParams[1]) || !IsPlayerConnected(strval(cmdParams[1])) || pInfo[strval(cmdParams[1])][logged] == 0 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /(o)feruj jazdy [id gracza] [cena]");
        if(isnull(cmdParams[2]) || !IsNumeric(cmdParams[2]) ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /(o)feruj jazdy [id gracza] [cena]");
               
        new targetid = strval(cmdParams[1]);
        new pprice = strval(cmdParams[2]);
               
        SendPlayerOffer(targetid, playerid, OFFER_TYPE_LESSON, pprice, 0);
     }
	 
	 if(!strcmp("podaj", cmdParams[0], true))
	 {
		new vw = GetPlayerVirtualWorld(playerid);
		if(isnull(cmdParams[1]) || !IsNumeric(cmdParams[1]) || !IsPlayerConnected(strval(cmdParams[1])) || pInfo[strval(cmdParams[1])][logged] == 0 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /(o)feruj podaj [id gracza]");
		new Float:pos[3];
		GetPlayerPos(strval(cmdParams[1]), pos[0], pos[1], pos[2]);
		if( GetPlayerDistanceFromPoint(playerid, pos[0], pos[1], pos[2]) > 10.0 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Gracz kt�remu sk�adasz ofert� znajduje si� zbyt daleko.");
		if(pInfo[playerid][hotelOutdoor] != 0 ) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Oferta -> B��d", "Nie mo�esz nic poda� w tym miejscu.", "Zamknij", "");
		if(vw == 0 ) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Oferta -> B��d", "Nie mo�esz nic poda� w tym miejscu.", "Zamknij", "");
		new doorsid = GetDoorsByUid(vw);
		if(doors[doorsid][type] != 0) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Oferta -> B��d", "Nie mo�esz nic poda� w tym miejscu", "Zamknij", "");
		new IDXGroup = GetGroupByUid(doors[doorsid][owner]);
		if(IDXGroup == -1) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Oferta -> B��d", "Nie mo�esz nic poda� w tym miejscu", "Zamknij", "");
		new PlayerSlot = GetGroupPlayerSlot(playerid, IDXGroup);
		if(PlayerSlot == -1) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Oferta -> B��d", "Nie posiadasz odpowiednich uprawnie�", "Zamknij", "");
		if(!HasPlayerPermission(playerid, "group", GPREM_offers, PlayerSlot)) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Oferta -> B��d", "Nie posiadasz odpowiednich uprawnie�", "Zamknij", "");
		new bigstring[512], string[35];
		foreach(new idee : Items_STORE[vw])
		{
			format(string, sizeof(string), "\n%i\t%s Cena: %i, Ilosc: %i", idee, Item[idee][name], Item[idee][price], Item[idee][count]);
			strcat(bigstring, string);
		
		}
		if(!strlen(bigstring)) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "Magazyn", "Magazyn jest pusty", "Zamknij", "");
		ShowPlayerDialog(playerid, 63, DIALOG_STYLE_LIST, "Oferta -> Podaj", bigstring, "Sprzedaj", "Wyjd�");
		//Jestes chujem
		pInfo[playerid][t_dialogtmp1] = strval(cmdParams[1]);
		pInfo[playerid][t_dialogtmp2] = doorsid;
		pInfo[playerid][t_dialogtmp3] = IDXGroup;
	 }
	 
	 if(!strcmp("naprawe", cmdParams[0], true))
	 {
	   new grSlot = IsPlayerInGroupType(playerid, 3);
	   if( grSlot == -1 ) return 1;
	   
	   if( GetPlayerVirtualWorld(playerid) > 0 && pInfo[playerid][hotelOutdoor] == 0)
	   {
	     new doorsId = GetDoorsByUid(GetPlayerVirtualWorld(playerid));
		 if( doors[doorsId][type] != 0 || groups[GetGroupByUid(doors[doorsId][owner])][type] != 3 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: W tym miejscu nie mo�esz oferowa� naprawy.");
	   }
	   else return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: W tym miejscu nie mo�esz oferowa� naprawy.");
	   
	   if(isnull(cmdParams[1]) || !IsNumeric(cmdParams[1]) || !IsPlayerConnected(strval(cmdParams[1])) || pInfo[strval(cmdParams[1])][logged] == 0 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /(o)feruj naprawe [id gracza] [cena]");
	   if(isnull(cmdParams[2]) || !IsNumeric(cmdParams[2]) || strval(cmdParams[2]) < 0 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /(o)feruj naprawe [id gracza] [cena]");
	   new offerTo = strval(cmdParams[1]);
	   new vID = GetPlayerVehicleID(offerTo);
	   
	   if( vID == -1 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Gracz musi siedzie� w poje�dzie, kt�ry chce naprawi�.");
	   if( sVehInfo[vID][engine] == true ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Pojazd musi mie� zgaszony silnik.");
	   new visualDamage = sVehInfo[vID][vDamagePanels] + sVehInfo[vID][vDamageDoors] + sVehInfo[vID][vDamageLights] + sVehInfo[vID][vDamageTires];
	   new Float:missingHealth = 1000.0 - sVehInfo[vID][health];
	   
	   if( visualDamage + missingHealth == 0 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Ten pojazd jest w pe�ni sprawny.");
	   
	   new Float:sX, Float:sY, Float:sZ;
	   GetPlayerPos(playerid, sX, sY, sZ);
	   
	   if( GetPlayerDistanceFromPoint(offerTo, sX, sY, sZ) > 15.0 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Gracz znajduje si� zbyt daleko.");
	   
	   SendPlayerOffer(offerTo, playerid, OFFER_TYPE_VEHICLE_REPAIR, strval(cmdParams[2]), vID); 
	 }
	 
	 if(!strcmp("malowanie", cmdParams[0], true))
	 {
	   new grSlot = IsPlayerInGroupType(playerid, 3);
	   if( grSlot == -1 ) return 1;
	   
	   if( GetPlayerVirtualWorld(playerid) > 0 && pInfo[playerid][hotelOutdoor] == 0)
	   {
	     new doorsId = GetDoorsByUid(GetPlayerVirtualWorld(playerid));
		 if( doors[doorsId][type] != 0 || groups[GetGroupByUid(doors[doorsId][owner])][type] != 3 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: W tym miejscu nie mo�esz oferowa� malowania.");
	   }
	   else return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: W tym miejscu nie mo�esz oferowa� malowania.");
	   
	   if(isnull(cmdParams[1]) || !IsNumeric(cmdParams[1]) || !IsPlayerConnected(strval(cmdParams[1])) || pInfo[strval(cmdParams[1])][logged] == 0 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /(o)feruj malowanie [id gracza] [cena] [kolor 1] [kolor 2]");
	   if(isnull(cmdParams[2]) || !IsNumeric(cmdParams[2]) || strval(cmdParams[2]) < 0 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /(o)feruj malowanie [id gracza] [cena] [kolor 1] [kolor 2]");
	   if(isnull(cmdParams[3]) || !IsNumeric(cmdParams[3]) || strval(cmdParams[3]) < 0 || strval(cmdParams[3]) > 255 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /(o)feruj malowanie [id gracza] [cena] [kolor 1] [kolor 2]");
       if(isnull(cmdParams[4]) || !IsNumeric(cmdParams[4]) || strval(cmdParams[4]) < 0 || strval(cmdParams[4]) > 255 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /(o)feruj malowanie [id gracza] [cena] [kolor 1] [kolor 2]");

	   new offerTo = strval(cmdParams[1]);
	   new vID = GetPlayerVehicleID(offerTo);
	   
	   if( vID == -1 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Gracz musi siedzie� w poje�dzie, kt�ry chce naprawi�.");
	   if( sVehInfo[vID][engine] == true ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Pojazd musi mie� zgaszony silnik.");
	   	   
	   new Float:sX, Float:sY, Float:sZ;
	   GetPlayerPos(playerid, sX, sY, sZ);
	   
	   if( GetPlayerDistanceFromPoint(offerTo, sX, sY, sZ) > 15.0 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Gracz znajduje si� zbyt daleko.");
	   
	   SendPlayerOffer(offerTo, playerid, OFFER_TYPE_VEHICLE_REPAIR, strval(cmdParams[2]), vID, strval(cmdParams[3]), strval(cmdParams[4])); 
	 }
   }
   
   return 1;
}

/*COMMAND:oferta2(playerid, params[])
{
  new offType[40], sub[350];
  if( sscanf(params, "s[40]", offType) )
  {
    SendClientMessage(playerid, COLOR_GREY, "{999A9C}PLERP.net: /(o)ferta [przedmioty oferty] [parametry]");
  }
  else
  {
	sscanf( params, "s[40]s[350]", offType, sub );
	if( (!strcmp("g", offType, false) || !strcmp("grupa", offType, false)) )
	{
	  new offerItem[32], offerFor, offerPrice;
	  if( sscanf(sub, "s[32] ", offerItem) )
	  {
        SendClientMessage(playerid, COLOR_GREY, "{999A9C}PLERP.net: /(o)ferta (g)rupa [przedmiot oferty] [id gracza] (dodatkowe parametry)");
	  }
	  else
	  {
		new gIdx = pGroups[playerid][pInfo[playerid][currentDuty]][groupIndx];
		if( !IsPlayerConnected(offerFor) || pInfo[offerFor][logged] == 0 )
		{
          SendClientMessage(playerid, COLOR_GREY, "{FFB871}[B��d] {FFFFFF}Gracz, kt�remu pr�bujesz z�o�y� ofert� nie jest zalogowany.");
          return 1;
		}
		
		// -- oferty urzedu miasta
		if( groups[gIdx][type] == 2 )
		{
          if( !strcmp("dok", offerItem, false) || !strcmp("dowod", offerItem, false) )
		  {
			SendClientMessage(playerid, COLOR_GREY, "{999A9C}PLERP.net: /(o)ferta (g)rupa dok/[(dow)od/prawko/dowrej] [id gracza] (dodatkowe parametry), np. /o g dok/dow 32");
		  }
		  if( !strcmp("drzwi", offerItem, false) || !strcmp("drz", offerItem, false) )
		  {
			SendClientMessage(playerid, COLOR_GREY, "{999A9C}PLERP.net: /(o)ferta (g)rupa drzwi [id gracza] (dodatkowe parametry), np. /o g drzwi 32");
		  }
		  
		  
		  if( !strcmp("dok/dow", offerItem, false) || !strcmp("dok/dowod", offerItem, false) )
		  {
			SendPlayerOffer(offerFor, playerid, 2, 59, 50);
		  }
		  if( !strcmp("dok/prawko", offerItem, false) )
		  {
			new prawkoType[32];
            if( sscanf(sub, "{s[32]}{d}s[32]", prawkoType) )
            {
              SendClientMessage(playerid, COLOR_GREY, "{999A9C}PLERP.net: /(o)ferta (g)rupa dok/prawko [id gracza] [kategoria: A/B/C/C+E/D]");
            }
            else
            {
			  if( !strcmp("A", prawkoType, false) )
			  {
                SendPlayerOffer(offerFor, playerid, 2, 6001, 150);
			  }
			  else if( !strcmp("B", prawkoType, false) )
			  {
                SendPlayerOffer(offerFor, playerid, 2, 6002, 200);
			  }
			  else if( !strcmp("C", prawkoType, false) )
			  {
			    SendPlayerOffer(offerFor, playerid, 2, 6003, 400);
			  }
			  else if( !strcmp("C+E", prawkoType, false) )
			  {
			    SendPlayerOffer(offerFor, playerid, 2, 6004, 600);
			  }
			  else if( !strcmp("D", prawkoType, false) )
			  {
			    SendPlayerOffer(offerFor, playerid, 2, 6005, 700);
			  }
            }
			
		  }
		  if( !strcmp("dok/dowrej", offerItem, false) )
		  {
			//SendPlayerOffer(offerFor, playerid, 2, 59, 50);
		  }
		}
		// -- Oferty warsztatu samochodowego -- //
		if( groups[gIdx][type] == 3 )
		{
          if( !strcmp("naprawa", offerItem, false) )
		  {
			if( !IsPlayerInDutyArea(playerid) )
			{
              ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("Oferty - B��d"), "Aby sk�ada� oferty warsztatu musisz znajdywa� si� w jego budynku.", "Zamknij", "");
		      return 1;
			}
			if( sscanf(sub, "s[32]dd", offerItem, offerFor, offerPrice) )
			{
			  SendClientMessage(playerid, COLOR_GREY, "{999A9C}PLERP.net: /(o)ferta (g)rupa naprawa [id gracza] [koszt]");
			  return 1;
			}
			if( IsPlayerInAnyVehicle(offerFor) == 0 )
			{
              ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("Oferty - B��d"), "Gracz, kt�remu sk�adasz ofert� naprawy nie znajduje si� w poje�dzie.", "Zamknij", "");
			  return 1;
			}
			new vehID = GetPlayerVehicleID(offerFor);
			new Float:wX,Float:wY,Float:wZ;
			GetPlayerPos(playerid, wX, wY, wZ);
            if( GetVehicleDistanceFromPoint(vehID, wX, wY, wZ) > 15.0 && GetVehicleVirtualWorld(vehID) != GetPlayerVirtualWorld(playerid) )
            {
              ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("Oferty - B��d"), "Gracz, kt�remu sk�adasz ofert� jest zbyt daleko.", "Zamknij", "");
			  return 1;
            }
            if( sVehInfo[vehID][engine] == true )
            {
              ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("Oferty - B��d"), "Pojazd w kt�rym siedzi gracz ma odpalony silnik.", "Zamknij", "");
			  return 1;
			}
			new Float:vehHealth, vpanels, vdoors, vlights, vtires, visualDamage;
			GetVehicleDamageStatus(vehID, vpanels, vdoors, vlights, vtires);
			GetVehicleHealth(vehID, vehHealth);
			visualDamage = vpanels+vdoors+vlights+vtires;
			if( vehHealth == 1000 && visualDamage == 0 )
			{
              ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, BuildGuiCaption("Oferty - B��d"), "Gracz, kt�remu sk�adasz ofert� naprawy siedzi w pe�ni sprawnym poje�dzie.", "Zamknij", "");
			  return 1;
			}
            SendPlayerOffer(offerFor, playerid, 3, offerPrice, vehID);
		  }
		}
	  }
	}
  }
  return 1;
}*/

COMMAND:o(playerid, params[])
{
  return cmd_oferuj(playerid, params);
}

COMMAND:pomoc(playerid, params[])
{
  ShowPlayerDialog(playerid, 35, DIALOG_STYLE_LIST, BuildGuiCaption("Pomoc"), "1. Podstawowe komendy\n2. Animacje", "Wybierz", "Zamknij");
  return 1;
}

COMMAND:qs(playerid, params[])
{
  new Query[456],
      Float: currX,
	  Float: currY,
	  Float: currZ;
  GetPlayerPos(playerid, currX, currY, currZ);
  format( Query, sizeof(Query), "UPDATE `characters` SET `qsX`='%f', `qsY`='%f', `qsZ`='%f', `qsVW`='%d', `qsTime`='%d' WHERE `uid`='%d'", currX, currY, currZ, GetPlayerVirtualWorld(playerid), gettime(), pInfo[playerid][uid]);
  mysql_function_query(mysqlHandle, Query, false, "", "");
  
  new formattedReason[84];
  format( formattedReason, 84, "(( %s ))\n(( /qs ))", pInfo[playerid][name] );
  new Text3D:disconnectNotif = CreateDynamic3DTextLabel(formattedReason, 0xA4A4A4FF, currX, currY, currZ-0.3, ITEMS_LABEL_DRAWDISTANCE, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), INVALID_PLAYER_ID, OBJECTS_STREAM_DISTANCE);
  defer DeleteDisconnectNotif[3000](disconnectNotif);

  Kick(playerid);
  return 1;
}

COMMAND:opis(playerid, params[])
{
  new Query[256];
  format( Query, sizeof(Query), "SELECT * FROM `characters_descriptions` WHERE `owner`='%d' ORDER BY `last_used` DESC", pInfo[playerid][uid]);
  
  mysql_function_query(mysqlHandle, Query, true, "PrepareOpisGui", "d", playerid);
  return 1;
}

COMMAND:b(playerid, params[])
{
  if( strlen(params) > 0 ) NewProx(playerid, "talk-ooc", params);
  else SendClientMessage(playerid, COLOR_GREY, "{999A9C}PLERP.net: /b [tre��]");
  
  return 1;
}

COMMAND:k(playerid, params[])
{
  if( strlen(params) > 0 ) NewProx(playerid, "talk-shout", params);
  else SendClientMessage(playerid, COLOR_GREY, "{999A9C}PLERP.net: /k [tre��]");
  
  return 1;
}

COMMAND:c(playerid, params[])
{
  if( strlen(params) > 0 ) NewProx(playerid, "talk-szept", params);
  else SendClientMessage(playerid, COLOR_GREY, "{999A9C}PLERP.net: /c [tre��]");
  
  return 1;
}

COMMAND:kup(playerid, params[])
{
  new areaId;
  if( GetPlayerVirtualWorld(playerid) > 0 && pInfo[playerid][hotelOutdoor] == 0 )
  {
	areaId = GetDoorsByUid(GetPlayerVirtualWorld(playerid));
  }
  else return 1;
  
  if( doors[areaId][doorUid] == GetPlayerVirtualWorld(playerid) && doors[areaId][type] == 0 )
  {
	new doorsGroup = GetGroupByUid(doors[areaId][owner]);
	  
	if( groups[doorsGroup][type] == 5 || groups[doorsGroup][type] == 6 ) 
	{
	    new liczba1, bigstring[300];
	    foreach (new item : Items_STORE[doors[areaId][doorUid]])
		{
		    liczba1++;
		    format( bigstring, sizeof(bigstring), "%s\n%d.\t\t%s[%d:%d] (Cena: $%d)(Ilo��: %d)", bigstring, liczba1, Item[item][name], Item[item][value1], Item[item][value2], Item[item][price], Item[item][count]);
		    
		}
		 
		if( liczba1 > 0 )
		{
		   ShowPlayerDialog(playerid, 49, DIALOG_STYLE_LIST, "24/7 -> Kupowanie przedmiotu", bigstring, "Kup", "Anuluj");
		}
		else ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "24/7 -> Kupowanie przedmiotu", "Przepraszamy, ale aktulanie brakuje przedmiot�w w magazynie sklepu.", "Zamknij", "");
	}
	
	if( groups[doorsGroup][type] == 11 )
	{
	  ShowPlayerDialog(playerid, 130, DIALOG_STYLE_LIST, "Sklep z ciuchami", "Ubrania (50$ szt.)\nAkcesoria postaci", "Wybierz", "Anuluj");
	}	
  }
  
  return 1;
}

COMMAND:tankuj(playerid, params[])
{
   if( !IsPlayerInAnyDynamicArea(playerid) ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Aby zatankowa� pojazd musisz znajdowa� si� na stacji paliw.");
   new area = GetPlayerDynamicArea(playerid);
   new grIndx = areas[area][owner]; 
   if( groups[grIndx][type] == 6 )
   {
      printf("test0");
      if( IsPlayerInAnyVehicle(playerid) ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Aby zatankowa� pojazd musisz z niego wysi���.");
      new iloscPaliwa;
      if( sscanf(params, "d", iloscPaliwa) ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /tankuj [ilo�� paliwa]");
	  else
	  {	 
	     new vehID = GetClosestVehicle(playerid);
	     printf("test1");
	     if( vehID == -1 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: W pobli�u nie znajduje si� �aden pojazd.");
		 if( sVehInfo[vehID][engine] ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Aby zatankowa� sw�j pojazd, musisz zgasi� silnik.");
		 printf("test2");
		 new Float:missingFuel = floatsub(GetVehicleMaxFuel(vehID), GetVehicleCurrentFuel(vehID));
	     if( floatcmp(missingFuel, iloscPaliwa) == -1 ) iloscPaliwa = floatround(missingFuel, floatround_ceil);
		 printf("test3");
		 new refill_price = iloscPaliwa * PALIWO_CENA;
		 printf("test3");
	     SendPlayerOffer(playerid, INVALID_PLAYER_ID, OFFER_TYPE_VEHICLE_REFILL, refill_price, vehID);
		 printf("test4");
	  }
   }
   else return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Aby zatankowa� pojazd musisz znajdowa� si� na stacji paliw.");
   
   return 1;
}

COMMAND:przejazd(playerid, params[])
{
  if( !IsPlayerInAnyVehicle(playerid) ) return 1;
  
  new vID = GetPlayerVehicleID(playerid);
  if( vID == -1 ) return 1; 
  if( !CanUseCar(playerid, vID) ) return 1;
 
  if( GetPlayerVehicleSeat(playerid) > 0 )
  {
    if( GetNumberOfPlayersInVehicle(vID) > 1 ) return 1;
  }
    
  if( GetPlayerVirtualWorld(playerid) > 0 && pInfo[playerid][hotelOutdoor] == 0)
  {
	// -- quit from interior -- //
	new doorsId = GetDoorsByUid(GetPlayerVirtualWorld(playerid));
	
	new vehiclePassengers[20];
	new vehiclePassengersSeats[20];
	// -- freeze the driver -- //
	new ii;
	foreach (new p : Player)
	{
	  if( IsPlayerInVehicle(p, vID) )
	  {
	    vehiclePassengers[ii] = p;
		vehiclePassengersSeats[ii] = GetPlayerVehicleSeat(p);
		ii++;
	  }
	}
	SetVehiclePos(vID, doors[doorsId][doorX], doors[doorsId][doorY], doors[doorsId][doorZ]);
	SetVehicleVirtualWorld(vID, doors[doorsId][doorVW]);
	LinkVehicleToInterior(vID, doors[doorsId][doorInt]);
	
	for(new y=0;y<=ii;y++)
	{
	  SetPlayerPos(vehiclePassengers[y], doors[doorsId][doorX], doors[doorsId][doorY], doors[doorsId][doorZ]+0.5);
	  SetPlayerVirtualWorld(vehiclePassengers[y], doors[doorsId][doorVW]);
	  SetPlayerInterior(vehiclePassengers[y], doors[doorsId][doorInt]);
	  OnPlayerVirtualWorldChange(playerid, GetDoorsByUid(doors[doorsId][doorVW]));
	  PutPlayerInVehicle(vehiclePassengers[y], vID, vehiclePassengersSeats[y]);
	}
	
  }
  else if( GetPlayerVirtualWorld(playerid) == 0 && pInfo[playerid][hotelOutdoor] == 0 )
  {
	// -- enter interior -- //
    new pretenderDoors, Float:pretenderDistance = 3.0;
    foreach (new dId : Doors)
    {
	   if( !doors[dId][carCrosing] ) continue;
	   if( GetVehicleVirtualWorld(vID) != doors[dId][doorVW] ) continue;
	   new Float:distance = GetVehicleDistanceFromPoint(vID, doors[dId][doorX], doors[dId][doorY], doors[dId][doorZ]);
	   if( distance <= pretenderDistance && distance <= 3.0 )
	   {
	     pretenderDoors = dId;
	     pretenderDistance = distance;
	   }
    }
    if( doors[pretenderDoors][doorUid] > 0 )
    {
      new vehiclePassengers[20];
	  new vehiclePassengersSeats[20];
	  // -- freeze the driver -- //
	  new ii;
	  foreach (new p : Player)
	  {
	    if( IsPlayerInVehicle(p, vID) )
	    {
	      vehiclePassengers[ii] = p;
		  vehiclePassengersSeats[ii] = GetPlayerVehicleSeat(p);
		  ii++;
	    }
	  }
	  SetVehiclePos(vID, doors[pretenderDoors][intSpawnX], doors[pretenderDoors][intSpawnY], doors[pretenderDoors][intSpawnZ]);
	  SetVehicleVirtualWorld(vID, doors[pretenderDoors][intSpawnVW]);
	  LinkVehicleToInterior(vID, doors[pretenderDoors][intSpawnInt]);
	
	  for(new y=0;y<=ii;y++)
	  {
	    SetPlayerPos(vehiclePassengers[y], doors[pretenderDoors][intSpawnX], doors[pretenderDoors][intSpawnY], doors[pretenderDoors][intSpawnZ]+0.5);
	    SetPlayerVirtualWorld(vehiclePassengers[y], doors[pretenderDoors][intSpawnVW]);
	    SetPlayerInterior(vehiclePassengers[y], doors[pretenderDoors][intSpawnInt]);
	    OnPlayerVirtualWorldChange(playerid, GetDoorsByUid(doors[pretenderDoors][intSpawnVW]));
	    PutPlayerInVehicle(vehiclePassengers[y], vID, vehiclePassengersSeats[y]);
	  }
    }
  
  }
  
  return 1;
}

// -- LSPD - BARTEK -- //
COMMAND:db(playerid, params[])
{
	new Idx;
	if( pInfo[playerid][currentDuty] == -1 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie jeste� na s�u�bie, lub nie nale�ysz do LSPD.");
	Idx = pGroups[playerid][pInfo[playerid][currentDuty]][groupIndx];
	if(groups[Idx][type] != 4) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie jeste� na s�u�bie, lub nie nale�ysz do LSPD.");
	
	ShowPlayerDialog(playerid, 80, DIALOG_STYLE_LIST, "Baza danych LSPD", "Szukaj\nDodaj wpis\nUsu� wpis\nEdytuj wpis", "Wybierz", "Anuluj");	
	return 1;
}

COMMAND:taser(playerid, params[])
{
	new Float: Pos[3], string[128], Idx;
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	if( pInfo[playerid][currentDuty] == -1 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie jeste� na s�u�bie, lub nie nale�ysz do LSPD.");
	Idx = pGroups[playerid][pInfo[playerid][currentDuty]][groupIndx];
	if(groups[Idx][type] != 4) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie jeste� na s�u�bie, lub nie nale�ysz do LSPD.");
	
	foreach(Player, i)
	{
		if(IsPlayerInRangeOfPoint(i, 5.0, Pos[0], Pos[1], Pos[2]) && i != playerid)
		{
			TogglePlayerControllable(i, 0);
			format(string, sizeof(string), "Porazi�e� taserem gracza %s.", pInfo[i][name]);
			SendClientMessage(playerid, COLOR_GREY, string);
			format(string, sizeof(string), "Zosta�e� pora�ony taserem przez funkcjonariusza %s.", pInfo[playerid][name]);
			SendClientMessage(i, COLOR_GREY, string);
			SetTimerEx("TaserTime", 10000, 0, "i", playerid);
			return 1;
		}
	}
	SendClientMessage(playerid, COLOR_GREY, "PLERP.net: W pobli�u nie ma �adnych graczy.");
	return 1;
}

COMMAND:mandat(playerid, params[])
{
	new option[64], Idx;
	if( pInfo[playerid][currentDuty] == -1 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie jeste� na s�u�bie, lub nie nale�ysz do LSPD.");
	Idx = pGroups[playerid][pInfo[playerid][currentDuty]][groupIndx];
	if(groups[Idx][type] != 4) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie jeste� na s�u�bie, lub nie nale�ysz do LSPD.");
	
	if(sscanf(params, "s[64]", option))
	{
		SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Wpisz: /mandat [wypisz/zdejmij]");
	} else
	{
		if(!strcmp(option, "wypisz", true))
		{
			ShowPlayerDialog(playerid, 91, DIALOG_STYLE_INPUT, "Wystaw mandat", "Wpisz dane w formacie: \
																\nID gracza;Kwota mandatu;Punkty Karne;Uzasadnienie", "Akceptuj", "Anuluj");
		} else if(!strcmp(option, "zdejmij", true))
		{
			ShowPlayerDialog(playerid, 92, DIALOG_STYLE_INPUT, "Zdejmij mandat", "Wpisz numer (UID) mandatu", "Akceptuj", "Anuluj");
		}
	}															
	return 1;
}

COMMAND:skuj(playerid, params[])
{
	new target, string[64], Idx;
	if( pInfo[playerid][currentDuty] == -1 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie jeste� na s�u�bie, lub nie nale�ysz do LSPD.");
	Idx = pGroups[playerid][pInfo[playerid][currentDuty]][groupIndx];
	if(groups[Idx][type] != 4) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie jeste� na s�u�bie, lub nie nale�ysz do LSPD.");
	
	if(sscanf(params, "d", target))
	{
		SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Wpisz: /skuj [ID gracza]");
	} else
	{
		if(pInfo[target][t_cuffed] == 1) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net:  Ten gracz ma ju� na sobie kajdanki.");
		
		SetPlayerSpecialAction(target, SPECIAL_ACTION_CUFFED);
		SetPlayerAttachedObject(target, 0, 19418, 6, -0.011000, 0.028000, -0.022000, -15.600012, -33.699977, -81.700035, 0.891999, 1.000000, 1.168000);
		pInfo[target][t_cuffed] = 1;
		
		format(string, sizeof(string), "Za�o�y�e� kajdanki podejrzanemu %s.", pInfo[target][name]);
		SendClientMessage(playerid, COLOR_GREEN, string);
		format(string, sizeof(string), "Zosta�e� skuty przez funkcjonariusza %s.", pInfo[playerid][name]);
		SendClientMessage(target, COLOR_RED, string);
	}
	return 1;
}

COMMAND:odkuj(playerid, params[])
{
	new target, string[64], Idx;
	if( pInfo[playerid][currentDuty] == -1 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie jeste� na s�u�bie, lub nie nale�ysz do LSPD.");
	Idx = pGroups[playerid][pInfo[playerid][currentDuty]][groupIndx];
	if(groups[Idx][type] != 4) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie jeste� na s�u�bie, lub nie nale�ysz do LSPD.");
	
	if(sscanf(params, "d", target))
	{
		SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Wpisz: /odkuj [ID gracza]");
	} else
	{
		if(pInfo[target][t_cuffed] == 0) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Ten gracz nie ma na sobie kajdanek.");
		if(playerid == target) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie mo�esz zdj�� sobie kajdanek.");
		
		SetPlayerSpecialAction(target, SPECIAL_ACTION_NONE);
		RemovePlayerAttachedObject(target, 0);
		pInfo[target][t_cuffed] = 0;
		
		format(string, sizeof(string), "Zdj��e� kajdanki podejrzanemu %s.", pInfo[target][name]);
		SendClientMessage(playerid, COLOR_RED, string);
		format(string, sizeof(string), "Funkcjonariusz %s zdj�� Ci kajdanki.", pInfo[playerid][name]);
		SendClientMessage(target, COLOR_GREEN, string);
	}
	return 1;
}

COMMAND:blokada(playerid, params[])
{
	new option[64], Idx;
	if( pInfo[playerid][currentDuty] == -1 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie jeste� na s�u�bie, lub nie nale�ysz do LSPD.");
	Idx = pGroups[playerid][pInfo[playerid][currentDuty]][groupIndx];
	if(groups[Idx][type] != 4) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie jeste� na s�u�bie, lub nie nale�ysz do LSPD.");
	
	if(sscanf(params, "s[64]", option))
	{
		SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Wpisz: /blokada [naloz/zdejmij]");
	} else
	{
		if(!strcmp(option, "naloz", true))
		{
			ShowPlayerDialog(playerid, 93, DIALOG_STYLE_INPUT, "Blokada pojazdu", "Wpisz dane w formacie\n\
																					Rejestracja pojazdu;Kwota zdj�cia blokady;Pow�d", "Akceptuj", "Anuluj");
		} else if(!strcmp(option, "zdejmij", true))
		{
			ShowPlayerDialog(playerid, 94, DIALOG_STYLE_INPUT, "Blokada pojazdu", "Wpisz rejestracj� pojazdu z kt�rego chcesz zdj�� blokad�.", "Akceptuj", "Anuluj");
		}
	}
	return 1;
}

// -- LSPD - BARTEK -- //

COMMAND:usmierc(playerid, params[])
{
        if(pInfo[playerid][bw] > 0)
        {
                ShowPlayerDialog(playerid, 95, DIALOG_STYLE_MSGBOX, "U�miercenie postaci", "U�miercenie postaci spowoduje brak mo�liwo�ci ponownego zalogowania si� na dan� posta�.\nU�mierci� posta�?", "Tak", "Nie");
        } else
        {
                return 1;
        }
        return 1;
}

COMMAND:bwczas(playerid, params[])
{
        #pragma unused params
       
        if(pInfo[playerid][bw] > 0)
        {
                new string[128], bwtime;
                bwtime = pInfo[playerid][bw] / 1000;
                bwtime = bwtime / 60;
                format(string, sizeof(string), "Do konca BW: %d minut", bwtime);
                GameTextForPlayer(playerid, string, 2000, 5);
        }
        return 1;
}

COMMAND:aprzedmiot(playerid, params[])
{
  new iType, iVal1, iVal2, iMdl, iNazwa[64];
  sscanf(params, "p<;>dddds[64]", iType, iVal1, iVal2, iMdl, iNazwa);
  
  ItemCreate(pInfo[playerid][uid], OWNER_TYPE_PLAYER, iType, iVal1, iVal2, iMdl, iNazwa);
  return 1;
}

COMMAND:pokoj(playerid, params[])
{
   if(isnull(params))
   {
     SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /pokoj [wejdz/wyjdz/wymelduj/zamelduj]");
   }
   else
   {
      if( !strcmp("wyjdz", params, true) )
	  {
	    if( pInfo[playerid][hotelOutdoor] > 0 )
		{
		  new areaId = GetDoorsByUid(pInfo[playerid][hotelOutdoor]);
		  TogglePlayerControllable(playerid,0);
		  SetPlayerVirtualWorld(playerid, doors[areaId][intSpawnVW]);
		  SetPlayerInterior(playerid, doors[areaId][intSpawnInt]);
		  SetPlayerPos(playerid, doors[areaId][intSpawnX], doors[areaId][intSpawnY], doors[areaId][intSpawnZ]+0.1);
		  SetCameraBehindPlayer(playerid);
		  defer UnfreezePlayer[1500](playerid);
		  OnPlayerVirtualWorldChange(playerid, areaId);
		  pInfo[playerid][hotelOutdoor] = 0;
		}
	  }
	  
	  if( !strcmp("wymelduj", params, true) )
	  {
	    new areaId = -1;
	    if( GetPlayerVirtualWorld(playerid) > 0)
        {
		  if( pInfo[playerid][hotelOutdoor] == 0 )
		  {
	        areaId = GetDoorsByUid(GetPlayerVirtualWorld(playerid));
		  }
		  else
		  {
		    areaId = GetDoorsByUid(pInfo[playerid][hotelOutdoor]);
		  }
		}
		else return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie znajdujesz si� w hotelu.");

		if( areaId == -1 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie znajdujesz si� w hotelu.");

		if( doors[areaId][type] != 2 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie znajdujesz si� w hotelu.");

		if( !Iter_Contains(Doors_Renters[areaId], pInfo[playerid][uid]) ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie jeste� zameldowany w tym hotelu.");

	    DeleteRenterFromDoors(areaId, playerid);

		if( pInfo[playerid][hotelOutdoor] > 0 )
		{
		  cmd_pokoj(playerid, "wyjdz");
		}
		
		return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Wymeldowa�e� si� z hotelu.");
	  }
	  
	  if( !strcmp("wejdz", params, true) )
	  {
	    new areaId = -1;
	    if( GetPlayerVirtualWorld(playerid) > 0)
        {
		  if( pInfo[playerid][hotelOutdoor] == 0 )
		  {
	        areaId = GetDoorsByUid(GetPlayerVirtualWorld(playerid));
		  }
		  else return 1;
		}
		
		if( areaId == -1 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie znajdujesz si� w hotelu.");
		
		if( doors[areaId][type] != 2 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie znajdujesz si� w hotelu.");
		
		if( !Iter_Contains(Doors_Renters[areaId], pInfo[playerid][uid]) ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie jeste� zameldowany w tym hotelu.");
		
		SetPlayerInterior(playerid, 9);
		TogglePlayerControllable(playerid,0);
		SetPlayerVirtualWorld(playerid, pInfo[playerid][uid]);
		SetPlayerPos(playerid,2251.85, -1138.16, 1050.63+0.1);
		SetCameraBehindPlayer(playerid);
		defer UnfreezePlayer[1500](playerid);
		OnPlayerVirtualWorldChange(playerid, areaId);
	    pInfo[playerid][hotelOutdoor] = doors[areaId][doorUid];
	  }
	  
	  if( !strcmp("zamelduj", params, true) )
	  {
	    if( GetPlayerSpawnType(playerid) == 2 ) return 1;
		
		new areaId = -1;
	    if( GetPlayerVirtualWorld(playerid) > 0)
        {
		  if( pInfo[playerid][hotelOutdoor] == 0 )
		  {
	        areaId = GetDoorsByUid(GetPlayerVirtualWorld(playerid));
		  }
		  else return 1;
		}
		
		if( areaId == -1 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie znajdujesz si� w hotelu.");
		
		if( doors[areaId][type] != 2 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie znajdujesz si� w hotelu.");
		
		if( Iter_Contains(Doors_Renters[areaId], pInfo[playerid][uid]) ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Jeste� ju� zameldowany w tym hotelu.");
		
		AddRenterToDoors(areaId, playerid);
		
		format( pInfo[playerid][baseSpawn], 158, "2,%d", doors[areaId][doorUid] );
		
		cmd_pokoj(playerid, "wejdz");
		
		return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Zameldowa�e� si� w hotelu.");
	  }
  
   }
   
   return 1;
}

COMMAND:ado(playerid, params[])
{
  new grSlot = IsPlayerInGroupType(playerid, 0);
  if( grSlot >= 0 && HasPlayerPermission(playerid, "group", GPREM_special, pGroups[playerid][grSlot][groupIndx]) )
  {
    if(isnull(params)) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /ado [tekst]");
	
	new message[350];
	format(message, 350, "* %s ", BeautyString(params, true, true));
	foreach (new p : Player)
	{
	  if( pInfo[p][logged] == 1 )
	  {
		ExplodeChatString(p, 0x9A9CCDFF, message);
	  }
	}
  }
  return 1;
}

COMMAND:bank(playerid, params[])
{
  if( GetPlayerVirtualWorld(playerid) > 0 && pInfo[playerid][hotelOutdoor] == 0 )
  {
    new doorsId = GetDoorsByUid(GetPlayerVirtualWorld(playerid));
	
	if( doors[doorsId][type] == 0 && groups[GetGroupByUid(doors[doorsId][owner])][type] == 10 )
	{
	   if( pInfo[playerid][bank] == 0 )
	   {
	      new string1[500], string2[250];
		  format( string1, sizeof(string1), "Witaj w g��wnym banku Los Santos!\n\n\
		                                     Nie posiadasz jeszcze swojego konta bankowego, ale nie przejmuj si�\n\
											 poniewa� jego utworzenie zajmie Ci tylko kilka chwil.\n\n\
											 Jakie korzy�ci daje Ci w�asne konto bankowe?\n\
											 \t - bezpiecze�stwo pieni�dzy w banku\n" );
		  format( string2, sizeof(string2), "\t - �atwo�� w dokonywaniu transkacji mi�dzy kontami\n\
											 \t - dost�p do got�wki praktycznie w ca�ym los santos dzi�ki bankomatom\n\n\
											 Aby za�o�y� swoje konto naci�nij poni�szy przycisk 'Za��'.");
		  strcat(string1, string2);
	      ShowPlayerDialog(playerid, 121, DIALOG_STYLE_MSGBOX, "Bank � Zak�adanie konta [1/2]", string1, "Za��", "Anuluj");
	   }
       else
	   {
	      pInfo[playerid][t_dialogtmp3] = 1;
          new string1[150], strprzel[50], strcapt[100];
		  if( pInfo[playerid][t_dialogtmp3] == 1 ) 
		  {
		   format(strprzel, sizeof(strprzel), "\nWp�ata\nPrzelew");
		   format(strcapt, sizeof(strcapt), "Bank");
		  }
		  else format(strcapt, sizeof(strcapt), "Bankomat");
		  format(string1, sizeof(string1), "Nr. rachunku: %d\n-----------------------\nSaldo konta\nWyp�ata%s", pInfo[playerid][bank], strprzel);
		  ShowPlayerDialog(playerid, 123, DIALOG_STYLE_LIST, strcapt, string1, "Wybierz", "Zamknij");
       }	   
	}
	else SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie znajdujesz si� w banku.");
  }
  else SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie znajdujesz si� w banku.");
  return 1;
}

COMMAND:bankomat(playerid, params[])
{
  new areaId = -1;
  foreach (new area : Areas)
  {
    if( areas[area][type] != AREA_TYPE_BANKOMAT ) continue;
	if( !IsValidDynamicArea(area) ) continue;
	if( IsPlayerInDynamicArea(playerid, area) ) 
	{
	  areaId = area;
	}
  }
  
  if( areaId == -1 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie znajdujesz si� w pobli�u bankomatu.");
  
  if( pInfo[playerid][bank] == 0 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie posiadasz konta w banku.");

  pInfo[playerid][t_dialogtmp3] = 2;
  new string1[150];
  format(string1, sizeof(string1), "Nr. rachunku: %d\n-----------------------\nSaldo konta\nWyp�ata", pInfo[playerid][bank]);
  ShowPlayerDialog(playerid, 123, DIALOG_STYLE_LIST, "Bankomat", string1, "Wybierz", "Zamknij");
  
  return 1;
}

COMMAND:plac(playerid, params[])
{
  if( isnull(params) ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /plac [id gracza] [kwota]");
  
  new payTo, payAmount;
  if( sscanf(params, "dd", payTo, payAmount) ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /plac [id gracza] [kwota]");
  
  if( payTo < 0 || payAmount < 0 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: /plac [id gracza] [kwota]");
  
  if( payAmount > pInfo[playerid][cash] ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie masz tyle pieni�dzy.");
  
  if( payTo == playerid ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie mo�esz p�aci� samemu sobie.");
  if( !IsPlayerConnected(payTo) || pInfo[payTo][logged] == 0 ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Gracz, kt�remu chcesz zap�aci� jest nie zalogowany.");
  
  new Float:ppX, Float:ppY, Float:ppZ;
  GetPlayerPos(playerid, ppX, ppY, ppZ);
  if( !IsPlayerInRangeOfPoint(payTo, 5.0, ppX, ppY, ppZ) || GetPlayerVirtualWorld(payTo) != GetPlayerVirtualWorld(playerid) ) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Gracz, kt�remu chcesz zap�aci� jest za daleko.");
  
  new meMSG[100];
  format(meMSG, sizeof(meMSG), "wyci�ga troch� pieni�dzy i podaje je %s", pInfo[payTo][name]);
  NewProx(playerid, "me", meMSG);
  
  AddPlayerMoney(playerid, -payAmount);
  AddPlayerMoney(payTo, payAmount);
 
  return 1;
}
forward SetAreaID(area);
public SetAreaID(area)
{
   areas[area][uid] = mysql_insert_id(mysqlHandle);
   return 1;
}
//bus
stock LoadBus()
{
  new Query[256];
  format(Query, sizeof(Query), "SELECT * FROM plerp_buss");
  mysql_function_query(mysqlHandle, Query, true, "loadBusQuery", "");
}
forward loadBusQuery();
public loadBusQuery()
{
	new rows, fields, string[64];
	cache_get_data(rows, fields, mysqlHandle);
	if( rows > 0 )
	{
		for (new i; i<rows; i++)
		{
			cache_get_field_content(i, "name", Bus[i][name]);
			cache_get_field_content(i, "pos_x", string);
			Bus[i][pos_x] = floatstr(string);			
			cache_get_field_content(i, "pos_y", string);
			Bus[i][pos_y] = floatstr(string);			
			cache_get_field_content(i, "pos_z", string);
			Bus[i][pos_z] = floatstr(string);			
			cache_get_field_content(i, "rot_z", string);
			Bus[i][pos_rz] = floatstr(string);			
			cache_get_field_content(i, "uid", string);
			Bus[i][uid] = strval(string);
			Iter_Add(Bus, i);
			format(string, sizeof(string), "Przystanek \n%s \nnr. %i", Bus[i][name], i+1);
			Bus[i][label] = CreateDynamic3DTextLabel(string, 0xD94100FF, Bus[i][pos_x], Bus[i][pos_y], Bus[i][pos_z]+0.7, 5);
			Bus[i][idobject] = CreateDynamicObject(1257, Bus[i][pos_x], Bus[i][pos_y], Bus[i][pos_z], 0, 0, Bus[i][pos_rz]);
		}
  }


}
COMMAND:bus(playerid, param[])
{
	if(GetPlayerVirtualWorld(playerid) != 0) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie mo�esz tutaj u�y� tej komendy.");
	new idprze = -1, currbus = -1, odleglosc, string[512], sstring[64], numer,liczba = strval(param);
	foreach (new i : Bus)
	{
		numer++;
		format(sstring, sizeof(sstring), "\n%i.\t%s", numer, Bus[i][name]);
		strcat(string, sstring);
		if(IsPlayerInRangeOfPoint(playerid, 10.00, Bus[i][pos_x], Bus[i][pos_y], Bus[i][pos_z]))
		{
			currbus = i;
		}
		if(liczba == numer && idprze == -1)
		{
			idprze = i;
		}
	}
	if(currbus == -1) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie znajdujesz si� w pobli�u �adnego przystanku.");
	if(strval(param))
	{
		if(idprze > MAX_BUS || idprze < 0 ||!Bus[idprze][uid]|| idprze == currbus) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Podany przestanek jest nieprawid�owy");
		odleglosc = floatround(Distance2D(Bus[currbus][pos_z], Bus[currbus][pos_y], Bus[idprze][pos_z], Bus[idprze][pos_y]), floatround_ceil);
		if(pInfo[playerid][cash] < floatround(odleglosc*BUS_CENA, floatround_ceil) && pInfo[playerid][timeOnline] > 18000) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nieposiadasz pieni�dzy na bilet.");
		if(pInfo[playerid][timeOnline] > 18000)
		{
			format(string, sizeof(string), "Zaplaciles ~g~$%i ~w~za autobus.", floatround(odleglosc*BUS_CENA/3, floatround_ceil));
			SendPlayerInformation(playerid, string);
			AddPlayerMoney( playerid, -floatround(odleglosc*BUS_CENA/3, floatround_ceil));
		}
		else
		{
			SendPlayerInformation(playerid, "Tym razem autobus nic Cie nie kosztowa�.");
		}
		SetPlayerPos(playerid, Bus[idprze][pos_x], Bus[idprze][pos_y], Bus[idprze][pos_z]);
		TogglePlayerControllable(playerid, 0);
		SetPlayerVirtualWorld(playerid, 1001);
		SetPlayerCameraLookAt(playerid, Bus[idprze][pos_x], Bus[idprze][pos_y], Bus[idprze][pos_z], CAMERA_CUT);
		InterpolateCameraPos(playerid, Bus[currbus][pos_x], Bus[currbus][pos_y], Bus[currbus][pos_z]+100, Bus[idprze][pos_x], Bus[idprze][pos_y], Bus[idprze][pos_z], odleglosc*200, CAMERA_MOVE);
		defer BusPrzenies[odleglosc*200](playerid);
		return 1;
	}
	else
	{	
		ShowPlayerDialog(playerid, 42, DIALOG_STYLE_LIST, "Wybierz przystanek", string, "Ok", "Wyjd�");
	}

	return 1;
}

forward CheckBanQuery(playerid);
public CheckBanQuery(playerid)
{
        new string[128], reason[64], rows, fields;
       
        cache_get_data(rows, fields);
       
        if(rows == 0) return 1;
       
        cache_get_field_content(0, "why", reason);
       
        format(string, sizeof(string), "Twoja posta� jest zbanowana. Pow�d: %s", reason);
        SendClientMessage(playerid, COLOR_RED, string);
        defer KickTimer[500](playerid);
        return 1;
}      
 
forward CheckWarnQuery(playerid);
public CheckWarnQuery(playerid)
{
        new string[128], rows, fields;
       
        cache_get_data(rows, fields);
       
        if(rows == 0) return 1;
       
        if(rows >= 3)
        {
                format(string, sizeof(string), "Twoja posta� otrzyma�a ostatnio 3 warny, nie mo�esz na niej gra�.");
                SendClientMessage(playerid, COLOR_RED, string);
                defer KickTimer[500](playerid);
        }
        return 1;
}
 
forward CheckBlockadesQuery(playerid);
public CheckBlockadesQuery(playerid)
{
        new tempField[32], rows, fields, typee;
       
        cache_get_data(rows, fields);
       
        if(rows == 0) return 1;
       
        for(new i=0; i<rows; i++)
        {
                cache_get_field_content(i, "type", tempField); typee = strval(tempField);
                switch(typee)
                {
                        case 4: pInfo[playerid][OOC_block] = 1;
                        case 5: pInfo[playerid][RUN_block] = 1;
                        case 6: pInfo[playerid][FIGHT_block] = 1;
                }
				printf("PLAYER ID: %d --- STATE: %d", playerid, typee);
        }
        return 1;
}

COMMAND:zgloszenia(playerid, params[])
{
        #pragma unused params
       
        new gID[3], ttime;
        gID[0] = FindGroupByUID(5);
        gID[1] = FindGroupByUID(8);
       
        if(IsPlayerInGroupType(playerid, gID[0]))
        {
                new string[1024];
               
                foreach(GroupReports[gID[0]], i)
                {
                                        ttime = gettime();
                                        if(ttime < (GroupReport[i][r_time] + 2*60))
                                                format(string, sizeof(string), "%s\n%s %s", string, GroupReport[i][r_date], GroupReport[i][place]);
                                        else
                                                format(string, sizeof(string), "%s\n{838B8B}%s {838B8B}%s", string, GroupReport[i][r_date], GroupReport[i][place]);
                }
               
                ShowPlayerDialog(playerid, 97, DIALOG_STYLE_LIST, "911 -> Zgloszenia", string, "Wybierz", "Anuluj");
                pInfo[playerid][t_dialogtmp1] = 1;
        } else if(IsPlayerInGroupType(playerid, gID[1]))
        {
                new string[1024];
               
                foreach(GroupReports[gID[1]], i)
                {
                                        ttime = gettime();
                                        if(ttime < (GroupReport[i][r_time] + 2*60))
                                                format(string, sizeof(string), "%s\n%s %s", string, GroupReport[i][r_date], GroupReport[i][place]);
                                        else
                                                format(string, sizeof(string), "%s\n{838B8B}%s {838B8B}%s", string, GroupReport[i][r_date], GroupReport[i][place]);
                }
               
                ShowPlayerDialog(playerid, 97, DIALOG_STYLE_LIST, "911 -> Zgloszenia", string, "Wybierz", "Anuluj");
                pInfo[playerid][t_dialogtmp1] = 2;
        } else
        {
                SendClientMessage(playerid, COLOR_GREY, "Plerp.net: Nie nalezysz do s�u�b porz�dkowych.");
        }
        return 1;
}

COMMAND:wydaj(playerid, params[])
{
        new option[64];
       
        if(sscanf(params, "s[64]", option))
        {
                SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Wpisz /wydaj [dowod/prawko/rejestracja]");
        } else
        {
                if(!strcmp(option, "rejestracja", true))
                {
                        ShowPlayerDialog(playerid, 155, DIALOG_STYLE_INPUT, "Wyr�b tablice rejestracyjne", "Wpisz dane w formacie:\n\
                                                                                                                                                                                                ID gracza;UID pojazdu;Kwota", "Akceptuj", "Anuluj");
                }
        }
        return 1;
}

forward CheckAdminJailQuery(playerid);
public CheckAdminJailQuery(playerid)
{
        new tempField[32], rows, fields, endtime;
       
        cache_get_data(rows, fields, mysqlHandle);
       
        if(rows == 0) return 1;
       
        cache_get_field_content(0, "endtime", tempField); endtime = strval(tempField);
       
        SendClientMessage(playerid, COLOR_RED, "PLERP.net: Wr�ci�e� do Admin Jaila. Poczekaj a� twoja kara si� sko�czy.");
        SetPlayerVirtualWorld(playerid, pInfo[playerid][uid]);
        SetPlayerPos(playerid, 1770.73, -2411.71, 13.55);
        pInfo[playerid][AJ_endtime] = endtime;
        pInfo[playerid][AJ_timer] = repeat CheckAdminJail(playerid);
        return 1;
}
 

//KOmendy dla Transportowych
COMMAND:magazyn(playerid)
{
		if(IsValidDynamicCP(Dostawa[playerid][0]) && Dostawa[playerid][2] == 1)
		{
			DestroyDynamicCP(Dostawa[playerid][0]);
			DestroyDynamicMapIcon(Dostawa[playerid][1]);
			Dostawa[playerid][2] = 0;
			return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Namierzanie zosta�o wy��czone");
		}
		if(pInfo[playerid][currentDuty] == -1) return  ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX,("Oferty -> B��d"), "Aby u�y� tej komendy musisz by� na duty w firmie transportowej.", "Zamknij", "");
		if(groups[pGroups[playerid][pInfo[playerid][currentDuty]][groupIndx]][type] != 14) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX,("B��d"), "Aby u�y� tej komendy musisz by� na duty w firmie transportowej.", "Zamknij", "");
		if(GetPlayerDistanceFromPoint(playerid, 1644.54, 1068.87, 10.82) > 10.0 ) 
		{
			if(IsValidDynamicCP(Dostawa[playerid][0])) return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Masz ju� w��czone namierzanie. Aby je wy��czy� u�yj /magazyn.");
			Dostawa[playerid][0] = CreateDynamicCP(1644.54, 1068.87, 10.82, 5.0, 0, -1, playerid);
			Dostawa[playerid][1] = CreateDynamicMapIcon(1644.54, 1068.87, 10.82, 23, 0xFFFFFFFF, 0, 0, playerid, 10000.00);
			Dostawa[playerid][2] = 1;
			return SendClientMessage(playerid, COLOR_GREY, "PLERP.net: Nie znajdujesz si� w pobli�u magazynu, zosta� on zaznaczony na mapie.");
		}
		if(Dostawa[playerid][2])return  ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX,("Oferty -> B��d"), "Nie mo�esz teraz u�y� tej komendy.", "Zamknij", "");
		mysql_function_query(mysqlHandle, "SELECT * FROM `plerp_items` WHERE `owner_type` = 9", true, "MagazynOdbierz", "ii", playerid, pGroups[playerid][pInfo[playerid][currentDuty]][groupIndx]);
		return 1;

}
forward MagazynOdbierz(playerid, GROUP);
public MagazynOdbierz(playerid, GROUP)
{
	new rows, fields, dint[2], string[60], bigstring[600], doorsid;
	cache_get_data(rows, fields, mysqlHandle);
	if(!rows) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "B��d", "Magazyn jest pusty", "ZAMKNIJ", "");
	for (new i; i<rows; i++)
	{
		cache_get_field_content(i, "uid", string);
		dint[0] = strval(string);			
		cache_get_field_content(i, "owner_id", string);
		dint[1] = strval(string);
		doorsid = GetDoorsByUid(dint[1]);
		if(doorsid == -1) continue;
		format(string, sizeof(string), "\n%i\t%s", dint[0], doors[doorsid][name]);
		strcat(bigstring, string);
	}
		pInfo[playerid][t_dialogtmp1] = GROUP;
		ShowPlayerDialog(playerid, 144, DIALOG_STYLE_LIST, "Magazyn -> Odbi�r", bigstring, "Wybierz", "Zamknij");
	return 1;
}
forward GdzieDos(playerid);
public GdzieDos(playerid)
{
	new rows, fields, dint[2], string[60], bigstring[600];
	cache_get_data(rows, fields, mysqlHandle);
	if(!rows) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "B��d", "Wyst�pi� b��d.", "ZAMKNIJ", "");
		cache_get_field_content(0, "uid", string);
		dint[0] = strval(string);			
		cache_get_field_content(0, "owner_id", string);
		dint[1] = strval(string);
		new doorsid = GetDoorsByUid(dint[1]);
		if(doorsid == -1) return  ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "B��d", "Magazyn jest pusty", "ZAMKNIJ", "");
		DestroyDynamicCP(Dostawa[playerid][0]);
		DestroyDynamicMapIcon(Dostawa[playerid][1]);
		Dostawa[playerid][2] = 0;
		Dostawa[playerid][3] = 0;
		Dostawa[playerid][4] = 0;
		foreach(new gracz : Player)
		{
			if(Dostawa[gracz][3] == doorsid) return  ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "B��d", "Kto� ju� dostarcza t� paczke.", "ZAMKNIJ", "");
		}
		Dostawa[playerid][0] = CreateDynamicCP(doors[doorsid][doorX], doors[doorsid][doorY], doors[doorsid][doorZ], 5.0, 0, -1, playerid);
		Dostawa[playerid][1] = CreateDynamicMapIcon(doors[doorsid][doorX], doors[doorsid][doorY], doors[doorsid][doorZ], 23, 0xFFFFFFFF, 0, 0, playerid, 10000.00);
		Dostawa[playerid][2] = 2;
		Dostawa[playerid][3] = dint[0];
		Dostawa[playerid][4] = pInfo[playerid][t_dialogtmp1];
		Dostawa[playerid][5] = doorsid;
	return 1;
}
forward DosFin(playerid, GROUP, ownerek);
public 	DosFin(playerid, GROUP, ownerek)
{
	new rows, fields, string[64], dint[8];
	cache_get_data(rows, fields, mysqlHandle);
	if(!rows) return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "B��d", "Wyst�pi� b��d", "Zamknij", "");
	cache_get_field_content(0, "price", string);
	dint[0] = strval(string);		
	cache_get_field_content(0, "uid", string);
	dint[7] = strval(string);	
	cache_get_field_content(0, "count", string);
	dint[5] = strval(string);
	cache_get_field_content(0, "type", string);
	dint[1] = strval(string);//Typ przedmiotu	
	cache_get_field_content(0, "value1", string);
	dint[2] = strval(string);//Value 1	
	cache_get_field_content(0, "value2", string);
	dint[3] = strval(string);//Value 2
	cache_get_field_content(0, "modellook", string);
	dint[4] = strval(string);//moodellook	
	cache_get_field_content(0, "owner_id", string);
	dint[6] = strval(string);//moodellook
	cache_get_field_content(0, "name", string);
	ItemCreate(dint[6], OWNER_TYPE_WAREHOUSE, dint[1], dint[2], dint[3], dint[4], string, dint[5], dint[0]);
	mysql_function_query(mysqlHandle, "DELETE FROM `plerp_items` WHERE `owner_id` = %i", false, "", dint[7]);

	return 1;
}