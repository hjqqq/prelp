stock strreplace(string[], find, replace)
{
    for(new i=0; string[i]; i++)
    {
        if(string[i] == find)
        {
            string[i] = replace;
        }
    }
}

stock BuildGuiCaption( build[] )
{
	new str[128];
	format(str, sizeof(str), "%s", build);
	return str;
}

stock ChatClean(playerid)
{
   for(new i = 0; i < 50; i++) SendClientMessage(playerid, WHITE, " ");
}

stock ApplyCommandAnim(playerid, alias[])
{
  new bool:animFound = false;
  
  foreach (new animId : Animations)
  {
	if( !strcmp(animations[animId][animAlias], alias, true, strlen(alias)) )
	{
	  animFound = true;
	  printf( "%s.%s.%f.%d.%d.%d.%d.%d.%d", animations[animId][animLib], animations[animId][animName], animations[animId][delta], animations[animId][loop], animations[animId][lockx], animations[animId][locky], animations[animId][freeze], animations[animId][time], animations[animId][forcesync]);
	  ApplyAnimation(playerid, animations[animId][animLib], animations[animId][animName], animations[animId][delta], animations[animId][loop], animations[animId][lockx], animations[animId][locky], animations[animId][freeze], animations[animId][time], animations[animId][forcesync]);
	  break;
	}
  }
  
  if( animFound == false )
  {
    SendClientMessage(playerid, 0xFF0000AA, "{B2C5D3}[U¿ycie] {FFFFFF}-[nazwa animacji], np. -idz2 #Lista dostêpnych animacji dostêpna jest poprzez /pomoc");
  }
}

stock strtolower(string[])
{
  for(new x = 0; x < strlen(string); x++)
  {  
    string[x] = tolower(string[x]);
  }
	
  return _:string;
}

stock BeautyString(string[], upperCase, endOffset, shout=false)
{
  // -- Turn first character upper case
  if( upperCase )
  {
    string[0] = toupper(string[0]);
  }
  // -- Add dot at the end
  new Zstring[350];
  if( endOffset )
  {
   new d = strlen(string)-1;
   
   new tmpStr[5];
   format(tmpStr, sizeof(tmpStr), "%s", string[d]);  
   if( strcmp(tmpStr, ".", true) != 0 && strcmp(tmpStr, "!", true) != 0  && strcmp(tmpStr, "?", true) != 0  )
   {
     if( shout ) format(Zstring, 350, "%s!!!", string);
	 else format(Zstring, 350, "%s.", string);
   }
   else
   {
     format(Zstring, 350, "%s", string);
   }
  }
  else { format(Zstring, 350, "%s", string); }
  // -- End up
  return Zstring;
}

stock RGBAToHex(r, g, b, a)
{
    return (r<<24 | g<<16 | b<<8 | a);
}

stock HexToRGBA(colour, &r, &g, &b, &a)
{
    r = (colour >> 24) & 0xFF;
    g = (colour >> 16) & 0xFF;
    b = (colour >> 8) & 0xFF;
    a = colour & 0xFF;
}

stock NewProx(playerid, typee[], string[])
{
	new
	   color[6],
	   message[350],
	   Float:radi;
	format(message, 350, "%s", string);
	if( !strcmp(typee, "do") )
	{
	  format(message, 350, "* %s (( %s ))", BeautyString(message, true, true), pInfo[playerid][name]);
	  color = {0x9A9CCDFF, 0x9A9CCDFF, 0x9A9CCDFF, 0x9A9CCDFF, 0x9A9CCDFF, 0x9A9CCDFF};
	  radi = 20.0;
	}
	else if( !strcmp(typee, "me") )
	{
      format(message, 350, "** %s %s", pInfo[playerid][name], BeautyString(message, false, true));
	  color = {0xC2A2DAFF, 0xC2A2DAFF, 0xC2A2DAFF, 0xC2A2DAFF, 0xC2A2DAFF, 0xC2A2DAFF};
	  radi = 20.0;
	}
	else if( !strcmp(typee, "talk") )
	{
      format(message, 350, "%s mówi: %s", pInfo[playerid][name], BeautyString(message, true, true));
	  color = {0xFFFFFFFF, 0xD4D4D4FF, 0xBEBEBEFF, 0x969696FF, 0x7D7D7DFF, 0x646464FF};
	  radi = 15.0;
	}
	else if( !strcmp(typee, "talk-szept") )
	{
      format(message, 350, "%s szepcze: %s", pInfo[playerid][name], BeautyString(message, true, true));
	  color = {0xFFFFFFFF, 0xD4D4D4FF, 0xBEBEBEFF, 0x969696FF, 0x7D7D7DFF, 0x646464FF};
	  radi = 6.0;
	}
	else if( !strcmp(typee, "talk-shout") )
	{
      format(message, 350, "%s krzyczy: %s", pInfo[playerid][name], BeautyString(message, true, true, true));
	  color = {0xFFFFFFFF, 0xD4D4D4FF, 0xBEBEBEFF, 0x969696FF, 0x7D7D7DFF, 0x646464FF};
	  radi = 30.0;
	}
	else if( !strcmp(typee, "talk-ooc") )
	{
      format(message, 350, "(( %s: %s ))", pInfo[playerid][name], message);
	  color = {0xABABABFF, 0xABABABFF, 0xABABABFF, 0xABABABFF, 0xABABABFF, 0xABABABFF};
	  radi = 6.0;
	}
	else if( !strcmp(typee, "phone-talk") )
	{
	  color = {0xFFFFFFFF, 0xD4D4D4FF, 0xBEBEBEFF, 0x969696FF, 0x7D7D7DFF, 0x646464FF};
	  radi = 8.0;
	  new sendTo = pCall[playerid][cCaller];
	  if( pCall[playerid][cCaller] == playerid ) sendTo = pCall[playerid][cReceiver];
	  
	  new text[250];
	  format(text, sizeof(text), message);
	  format(message, 350, "%s mówi(telefon): %s", pInfo[playerid][name], BeautyString(message, true, true));
	  if( sendTo >= 0 )
	  {
	    new Float:callerX, Float:callerY, Float:callerZ;
	    GetPlayerPos(sendTo, callerX, callerY, callerZ);
	    if( !IsPlayerInRangeOfPoint(playerid, radi, callerX, callerY, callerZ) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(sendTo) )
	    {
          ExplodeChatString(sendTo, 0xFFFFFFFF, message);
	    }  
	  }
	}
    new Float:pposx, Float:pposy, Float:pposz;
	// TODO: Cleanup loop
    for(new i = 0; i < MAX_PLAYERS; i++)
        {
            if(IsPlayerConnected(i) && (GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i)))
            {
                GetPlayerPos(i, pposx, pposy, pposz);
                new Float: fDistance = GetPlayerDistanceFromPoint(playerid, pposx, pposy, pposz);
                
                if ( fDistance <= radi )
                {
                    new Float:percentageDistance = floatmul(floatdiv(fDistance, radi), 100.0);
                    new perfectColor;
					if( percentageDistance <= 10.0 ) perfectColor = color[0];
					if( percentageDistance > 10.0 && percentageDistance <= 30.0 ) perfectColor = color[1];
					if( percentageDistance > 30.0 && percentageDistance <= 50.0 ) perfectColor = color[2];
					if( percentageDistance > 50.0 && percentageDistance <= 70.0 ) perfectColor = color[3];
					if( percentageDistance > 70.0 && percentageDistance <= 90.0 ) perfectColor = color[4];
					if( percentageDistance > 90.0 ) perfectColor = color[5];
                    ExplodeChatString(i, perfectColor, message);
                }
            }
        }
    return 1;
}

stock SendPlayerInformation(playerid, text[], showTime=2000)
{
  PlayerTextDrawHide(playerid, informationTd);
  
  PlayerTextDrawSetString(playerid, informationTd, text);
  PlayerTextDrawShow(playerid, informationTd);
  
  defer HidePlayerTextDraw[showTime](playerid, informationTd);
  
  return 1;
}

stock OnlineTimeInHours(onlineTime)
{
  new Float:hours = onlineTime / 3600;
  
  return floatround(hours, floatround_floor);
}

stock NewProxPersonal(playerid, obtainer, pType[], string[])
{
   if( !strcmp(pType, "pm") )
   {
     new wMessage[2][200];
     format(wMessage[0], 200, "(( > %s: %s ))", pInfo[obtainer][tdnick], BeautyString(string, true, true));
     format(wMessage[1], 200, "(( %s: %s ))", pInfo[playerid][tdnick], BeautyString(string, true, true));
     SendClientMessage(playerid, 0xFFC973FF, wMessage[0]);
     SendClientMessage(obtainer, 0xFDAE33FF, wMessage[1]);
   }
}

stock ExplodeChatString(playerid, color, string[], embededColor[] = "")
{
  new messageE[2][144];
  if( strlen(string) > MAX_CHAT_STRING )
  {
	strmid( messageE[0], string, 1, 140, 144 );
	format( messageE[0], 144, "%s%s ...", embededColor, messageE[0] );

	strmid( messageE[1], string, 140, 350, 144 );
	format( messageE[1], 144, "%s... %s", embededColor, messageE[1] );

	SendClientMessage(playerid, color, messageE[0]);
    SendClientMessage(playerid, color, messageE[1]);
  }
  else
  {
    format( messageE[0], 144, "%s%s", embededColor, string );
    SendClientMessage(playerid, color, messageE[0]);
  }
}

stock FormatDataForShow(timestamp, onlydata=0)
{
   new nYear, nMonth, nDay, nHour, nMinute, nSecond, formattedData[128];
   TimestampToDate(timestamp, nYear, nMonth, nDay, nHour, nMinute, nSecond, 1);
   
   
   if( !onlydata ) format(formattedData, 128, "%02d.%02d.%d - %02d:%02d", nDay, nMonth, nYear, nHour, nMinute);
   else format(formattedData, 128, "%02d.%02d.%d", nDay, nMonth, nYear);
   return formattedData;
}

IsNumeric(const string[])
{
    for (new i = 0, j = strlen(string); i < j; i++)
    {
        if (string[i] > '9' || string[i] < '0') return 0;
    }
    return 1;
}

stock StringNewLiner(string[], limit, insert[])
{
    // TODO
    new howMuch = 1;
	new text[500], find = ' ';
	format(text, sizeof(text), string);
	
    for (new i = 0, j = strlen(string); i < j; i++)
    {
        if( i >= limit*howMuch && string[i] == find )
        {
		  strins(text, insert, i+((howMuch-1)*2));
		  howMuch +=1;
		}
    }
	
	return text;
}

stock IsPlayerFacingVehicle(playerid,vehicleid)
{
    new Float:ptX,Float:ptY,Float:ptZ,Float:X,Float:Y,Float:Z,Float:ang;
 
    if(!IsPlayerConnected(playerid)) return 0;
 
    GetVehiclePos(vehicleid, X, Y, Z);
    GetPlayerPos(playerid, ptX, ptY, ptZ);
 
    if( Y > ptY ) ang = (-acos((X - ptX) / floatsqroot((X - ptX)*(X - ptX) + (Y - ptY)*(Y - ptY))) - 90.0);
    else if( Y < ptY && X < ptX ) ang = (acos((X - ptX) / floatsqroot((X - ptX)*(X - ptX) + (Y - ptY)*(Y - ptY))) - 450.0);
    else if( Y < ptY ) ang = (acos((X - ptX) / floatsqroot((X - ptX)*(X - ptX) + (Y - ptY)*(Y - ptY))) - 90.0);
 
    if(X > ptX) ang = (floatabs(floatabs(ang) + 180.0));
    else ang = (floatabs(ang) - 180.0);
    new Float:russia;
    GetPlayerFacingAngle(playerid,russia);
    if(ang-russia<-130 || ang-russia>130) return 0;
    else return 1;
}

stock Float:GetDistanceBetweenPoints(Float:X, Float:Y, Float:Z, Float:PointX, Float:PointY, Float:PointZ)
{
    new Float:Distance;
    Distance = floatabs(floatsub(X, PointX)) + floatabs(floatsub(Y, PointY)) + floatabs(floatsub(Z, PointZ));
    return Distance;
}

stock GeneratePlayerBankNumber(playerid)
{
  new generated = random(99999);
  if( generated < 10000 ) return GeneratePlayerBankNumber(playerid);
  
  new str[30];
  format(str, sizeof(str), "%d%d", generated, pInfo[playerid][uid]);
  
  return strval(str);
}

stock PercentageChance( Float:chance )
{
  new generated = random(1000);
  generated += 1;
  
  if( generated <= (generated*chance) )  return 1;
  
  return 0;
}

stock GetDateTimeToMySQL()
{
   new Year, Month, Day, Hour, Minute, Second, DateTime[64];
   getdate(Year, Month, Day);
   gettime(Hour, Minute, Second);
   format(DateTime, sizeof(DateTime), "%02d:%02d:%02d %02d/%02d/%d", Hour, Minute, Second, Day, Month, Year);

   return DateTime;
}

stock Float: Min(Float:numberOne, Float:numberTwo)
{
  if( floatcmp(numberOne, numberTwo) == 1 ) return numberTwo;
  return numberOne;
}
stock Float: Max(Float:numberOne, Float:numberTwo)
{
  if( floatcmp(numberOne, numberTwo) == 1 ) return numberOne;
  return numberTwo;
}

stock FormatTime(timeToFormat)
{
	new hours, minutes, seconds, formattedTime[32];
	
    hours = (timeToFormat / (60 * 60)) % 24;
    minutes = (timeToFormat / 60) % 60;
    seconds = timeToFormat % 60;
    format(formattedTime, 32, "%dh %dm %ds", hours, minutes, seconds);
    
    return formattedTime;
}

stock FormatDateTime( timestamp, _form=0 )
{
    new year=1970, day=0, month=0, hours=0, mins=0, sec=0;

    new days_of_month[12] = { 31,28,31,30,31,30,31,31,30,31,30,31 };
    new returnstring[32];

    while(timestamp>31622400){
        timestamp -= 31536000;
        if ( ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0) ) timestamp -= 86400;
        year++;
    }

    if ( ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0) )
        days_of_month[1] = 29;
    else
        days_of_month[1] = 28;


    while(timestamp>86400){
        timestamp -= 86400, day++;
        if(day==days_of_month[month]) day=0, month++;
    }

    while(timestamp>60){
        timestamp -= 60, mins++;
        if( mins == 60) mins=0, hours++;
    }

    sec=timestamp;

    switch( _form ){
        case 1: format(returnstring, 31, "%02d/%02d/%d %02d:%02d:%02d", day+1, month+1, year, hours, mins, sec);
        case 2: format(returnstring, 31, "%s %02d, %d, %02d:%02d:%02d", names_of_month[month],day+1,year, hours, mins, sec);
        case 3: format(returnstring, 31, "%d %c%c%c %d, %02d:%02d", day+1,names_of_month[month][0],names_of_month[month][1],names_of_month[month][2], year,hours,mins);

        default: format(returnstring, 31, "%02d.%02d.%d, %02d:%02d:%02d", day+1, month+1, year, hours, mins, sec);
    }

    return returnstring;
}

stock PreloadAnimLib(playerid, animlib[])
{
	ApplyAnimation(playerid,animlib,"null",0.0,0,0,0,0,0);
}

stock Float: GetAngleForPoints(Float:x1, Float:y1, Float:x2, Float:y2)
{
  // arctan with x/y offset of the points
  new Float:angle = atan2(x1 - x2, y1 - y2);
  // angle of point 1
  // correction
  if(angle > 360.0) angle -= 360.0;
}
stock Float:Distance2D(Float:x1, Float:y1, Float:x2, Float:y2, bool:sqrt = true)
{
  x1 -= x2;
  x1 *= x1;

  y1 -= y2;
  y1 *= y1;

  x1 += y1;

  return sqrt ? floatsqroot(x1) : x1;
}