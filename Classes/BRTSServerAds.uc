class BRTSServerAds extends Actor
    config(BRTSServerAds);

enum String_Day
{
    NULL,
    Mon,
    Tue,
    Wed,
    Thu,
    Fri,
    Sat,
    Sun
};

enum String_Mth
{
    NULL,
    Jan,
    Feb,
    Mar,
    Apr,
    May,
    Jun,
    Jul,
    Aug,
    Sep,
    Oct,
    Nov,
    Dec
};

struct DateTime
{
    var string Day;
    var string Month;
    var string Year;
    var string Hour;
    var string Minute;
    var string Second;
    var string AMPM;
    var string DayStr;
    var string MonthStr;
};

struct Wildcard
{
    var string WildcardString;
    var string ActualValue;
};

// ---------------------- VARS ------------------------------

var array<string> SupportedWildcards;
var array<Wildcard> WildCardList;
var int CurrentMsgID;

// ---------------- .ini file variables ----------------------
var config array<config string> ServerAdsList;  // Messages
var config float MsgInterval;                   // Time between messages
var config bool bUse24HrFormat;                 // 24h switch
var config int ConfigVer;                       // Version control for INI

// -------------------- INIT  ----------------------------
function PostBeginPlay()
{
    if( Role == ROLE_Authority )
    {
        Log2Srv("====================== Brutus Server Ads Loaded ======================");
        Log2Srv(TimeStamp());
        Log2Srv(ServerAdsList.Length @ "messages loaded");
        Log2Srv("MsgInterval:"@MsgInterval);
        Log2Srv("======================================================================");
        RefreshWildcardValues();
        CurrentMsgID = 0;
        UpdateConfigs();
    }
}

function UpdateConfigs()
{
    // If missing, create INI with default values
    if( ConfigVer == 0 )
    {
        ConfigVer = 1;
        MsgInterval = 45.f;
        bUse24HrFormat = true;
        ServerAdsList.AddItem("Welcome to" @ SupportedWildcards[0]);
        SaveConfig();
    }
}

// -------------------- TOKEN FUNCTIONS  ----------------------------

/** 
    Gets dynamic information like time or players for the wildcard struct.
**/
function RefreshWildcardValues()
{
    local int i;
    local bool found;
    local DateTime DTG;
    local Wildcard WildcardItem;

    DTG = GetDateTime();
    WildCardList.Length = 0;

    for( i = 0; i < SupportedWildcards.Length; i++ )
    {
        found = true;
        WildcardItem.WildcardString = SupportedWildcards[i];
        switch( WildcardItem.WildcardString ) 
        {
            case "{SERVERNAME}":    WildcardItem.ActualValue = GetServerName();     break;
            case "{DAY}":           WildcardItem.ActualValue = DTG.Day;             break;
            case "{MTH}":           WildcardItem.ActualValue = DTG.Month;           break;
            case "{YR}":            WildcardItem.ActualValue = DTG.Year;            break;
            case "{HR}":            WildcardItem.ActualValue = DTG.Hour;            break;
            case "{MIN}":           WildcardItem.ActualValue = DTG.Minute;          break;
            case "{SEC}":           WildcardItem.ActualValue = DTG.Second;          break;
            case "{AMPM}":          WildcardItem.ActualValue = DTG.AMPM;            break;
            case "{SDAY}":          WildcardItem.ActualValue = DTG.DayStr;          break;
            case "{SMTH}":          WildcardItem.ActualValue = DTG.MonthStr;        break;
            case "{MAPNAME}":       WildcardItem.ActualValue = GetMapName();        break;
            case "{PLAYERCOUNT}":   WildcardItem.ActualValue = GetNumPlayers();     break;
            case "{SERVERSLOTS}":   WildcardItem.ActualValue = GetServerSlots();    break;
            default: 
                found = false; 
                Log2Srv("Unrecognized Token:" @ SupportedWildcards[i]);     
                break;
        }

        if(found) WildCardList.AddItem(WildcardItem);
    }
}

/**
    Prepares a message for broadcast by replacing tokens with the wildcard value.
**/
function string ReplWildcardsInString( string S )
{
    local int i, MatchIndex;
    local string MessageText;

    MessageText = S;

    for( i = 0; i < WildCardList.Length; i++ )
    {
        MatchIndex = InStr(MessageText, WildCardList[i].WildcardString);
        // If token detected, replace it with the corresponding value
        if(MatchIndex != INDEX_NONE) ReplaceText(MessageText, WildCardList[i].WildcardString, WildCardList[i].ActualValue);
    }
    return MessageText; 
}

// -------------------- STRING HELPERS  ----------------------------

/**
    Loads and formats current time values into DateTime struct.
**/
function DateTime GetDateTime()
{
    local DateTime DTG;
    local int Year, Month, DayOfWeek, Day, Hour, Min, Sec, MSec;
    GetSystemTime(Year, Month, DayOfWeek, Day, Hour, Min, Sec, MSec);

    DTG.Year        = string(Year);
    DTG.Month       = string(Month);
    DTG.DayStr      = string(GetEnum(enum'String_Day', DayOfWeek));
    DTG.Day         = string(Day);
    DTG.Hour        = bUse24HrFormat ? LeadingZeroes(string(Hour), 2) : LeadingZeroes(string(Hour - 12), 2);
    DTG.Minute      = LeadingZeroes(string(Min), 2);
    DTG.Second      = LeadingZeroes(string(Sec), 2);
    DTG.MonthStr    = string(GetEnum(enum'String_Mth', Month));
    DTG.AMPM        = bUse24HrFormat ? "" : (Hour > 12 ? "PM" : "AM");
    return DTG;  
}

/**
    Return current name of the Server.
**/
function string GetServerName()
{
    return RunningProperly() ? WorldInfo.static.GetWorldInfo().GRI.ServerName : "Unknown Server Name";   
}

/**
    Return name of the current map.
**/
function string GetMapName()
{
   return RunningProperly() ? WorldInfo.static.GetWorldInfo().GetMapName(true) : "Unknown Map";
}

/**
    Return current number of players.
**/
function string GetNumPlayers()
{
    return RunningProperly() ? string(WorldInfo.static.GetWorldInfo().Game.NumPlayers) : "0";
}

/**
    Return total player slots available.
**/
function string GetServerSlots()
{
    return RunningProperly() ? string(WorldInfo.static.GetWorldInfo().Game.MaxPlayers) : "0";
}

/**
    Helper function to check if world and server are in the right mode. 
**/
function bool RunningProperly()
{
    return WorldInfo.static.GetWorldInfo() != none 
        && WorldInfo.static.GetWorldInfo().NetMode == NM_DedicatedServer 
        && WorldInfo.static.GetWorldInfo().Game != none;
}

/**
    Padding helper function, as there doesn't seem to be a string formatter.
**/
function string LeadingZeroes( coerce string InputStr, int TargetLength )
{
    local int i;
    local string Padding;

    Padding = "";
    for( i = Len(InputStr); i < TargetLength; i++ )
    {
        Padding $= "0";
    }

    return Padding $ InputStr;
}

/**
    Prepend log messages with the mod name so the source is easier to find. 
**/
function Log2Srv( coerce string S )
{
    LogInternal("[BRTSServerAds]" @ S);
}

// -------------------- BROADCAST LOOP ----------------------------
auto state Loop
{
    function BroadcastMsg()
    {
        local string sMsg;
        local int msgID;
        local PlayerController PC;

        RefreshWildcardValues();

        if( (WorldInfo != none) && Role == ROLE_Authority )
        {
            msgID = CurrentMsgID;
            sMsg = ReplWildcardsInString(ServerAdsList[msgID]);

            foreach WorldInfo.AllControllers(class'PlayerController', PC)
            {
                // System Announcement
                if( PC.bIsPlayer ) WorldInfo.Game.Broadcast(PC, sMsg);
            }

        }
        // Queue next message
        CurrentMsgID++;

        // If reached last msg already, start from the first again
        if( CurrentMsgID >= (ServerAdsList.Length) ) CurrentMsgID = 0;
    }

Begin:
    BroadcastMsg();
    Sleep(MsgInterval);
    goto 'Begin';
    stop;
}

defaultproperties
{
    bHidden=false
    bSkipActorPropertyReplication=false
    bOnlyDirtyReplication=false
    NetUpdateFrequency=100.0
    SupportedWildcards(0)="{SERVERNAME}"
    SupportedWildcards(1)="{DAY}"
    SupportedWildcards(2)="{MTH}"
    SupportedWildcards(3)="{YR}"
    SupportedWildcards(4)="{HR}"
    SupportedWildcards(5)="{MIN}"
    SupportedWildcards(6)="{SEC}"
    SupportedWildcards(7)="{AMPM}"
    SupportedWildcards(8)="{SDAY}"
    SupportedWildcards(9)="{SMTH}"
    SupportedWildcards(10)="{MAPNAME}"
    SupportedWildcards(11)="{PLAYERCOUNT}"
    SupportedWildcards(12)="{SERVERSLOTS}"
}
