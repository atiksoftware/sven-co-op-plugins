void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Amiral Router" );
	g_Module.ScriptInfo.SetContactInfo( "Aim laser plugin" );  
    g_Scheduler.SetInterval( "Check", 1 );
}

void MapInit()
{

}

void MapActivate()
{
}

void Check()
{
    // find current player
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(1);
    if(pPlayer is null)
        return;
    if(pPlayer.IsConnected() == false)
        return;
    if(pPlayer.IsAlive() == false)
        return;
    // draw a laser line to all entities from current player head 
    Vector vecSrc = pPlayer.GetOrigin(); 
     

    // find all entities in the line
    CBaseEntity@ pEntity = null;
    while((@pEntity = g_EntityFuncs.FindEntityInSphere(pEntity, vecSrc, 50, "*", "classname")) !is null)
    { 
        string szClassname = pEntity.GetClassname();
        // if szClassname starts with "func_" then skip it
        if(szClassname.SubString(0, 7) == "weapon_")
            continue;
        // if(szClassname != "multi_manager")
        //     continue;
        if(szClassname == "player")
            continue;
        te_line(vecSrc, pEntity.GetOrigin());
        // print the entity classname on screen
        g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, pEntity.GetClassname() + " - " + pEntity.GetTargetname() + '\n');
        // pEntity.SUB_Remove();
        // draw a laser line to the entity
        // g_Utility.DrawBeamPoints(pPlayer.pev.origin + pPlayer.pev.view_ofs, pEntity.pev.origin, 10, 2, 255, 0, 0, 255, 10);
    }
}

class Color
{ 
	uint8 r, g, b, a;
	
	Color() { r = g = b = a = 0; }
	Color(uint8 _r, uint8 _g, uint8 _b, uint8 _a = 255 ) { r = _r; g = _g; b = _b; a = _a; }
	Color (Vector v) { r = int(v.x); g = int(v.y); b = int(v.z); a = 255; }
	string ToString() { return "" + r + " " + g + " " + b + " " + a; }
}

const Color RED(255,0,0);
const Color GREEN(0,255,0);
const Color BLUE(0,0,255);
const Color YELLOW(255,255,0);
const Color ORANGE(255,127,0);
const Color PURPLE(127,0,255);
const Color PINK(255,0,127);
const Color TEAL(0,255,255);
const Color WHITE(255,255,255);
const Color BLACK(0,0,0);
const Color GRAY(127,127,127);

// Beam effect between two points
void te_line(Vector start, Vector end, uint16 life=1, Color c=RED,
	NetworkMessageDest msgType=MSG_BROADCAST, edict_t@ dest=null)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_LINE);
	m.WriteCoord(start.x);
	m.WriteCoord(start.y);
	m.WriteCoord(start.z);
	m.WriteCoord(end.x);
	m.WriteCoord(end.y);
	m.WriteCoord(end.z);
	m.WriteShort(life);
	m.WriteByte(c.r);
	m.WriteByte(c.g);
	m.WriteByte(c.b);
	m.End();
}
