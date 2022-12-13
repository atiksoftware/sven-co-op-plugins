// bind "m" "say /admin_menu"
// bind "n" "clear;as_reloadplugins;as_listplugins; npc_attackmytarget"
CTextMenu@ AdminMenu; 
CTextMenu@ TeleportMenu; 
CTextMenu@ GiveMenu; 
CTextMenu@ GiveWeaponMenu; 
CTextMenu@ TeamMenu; 
// CConCommand _CallMenu( "call_menu", "Show Menu", @CallMenu );

class TeleportPlayerLocationData{
	Vector origin;
	float pitch, yaw;
}
dictionary g_TeleportPlayerLocations;


// 2d array for weapons
const array<array<string>> WeaponList = {
  {"weapon_crowbar", "Crowbar - Levye"},
  {"weapon_pipewrench", "Pipe Wrench - Boru Anahtari" },
  {"weapon_medkit", "Medkit"},
  {"weapon_grapple", "Barnacle Grapple"},
  {"weapon_glock", "Glock"},
  {"weapon_357", ".357 Magnum"}, 
  {"weapon_eagle", "Desert Eagle"},
  {"weapon_uzi", "Uzi"},
  {"weapon_uziakimbo", "Uzi Kimbo"},
  {"weapon_mp5", "Mp5"},
  {"weapon_shotgun", "Shotgun - Pompali"},
  {"weapon_crossbow", "Crossbow - Arbalet"},
  {"weapon_m16", "Assault Rifle"},
  {"weapon_rpg", "RPG - Roket"},
  {"weapon_gauss", "Tau Cannon - Lazer"},
  {"weapon_egon", "Gluon Gun - Elektrik"},
  {"weapon_hornetgun", "Hivehand - Sinek"},

  {"weapon_handgrenade", "Grenade"},
  {"weapon_satchel", "Satchel Charge"},
  {"weapon_tripmine", "Laser Tripmine"},
  {"weapon_snark", "Snark - Bocek"},

  {"weapon_sniperrifle", "Sniper Rifle"},
  {"weapon_m249", "M249"},
  // {"weapon_minigun", "Minigun"},
  {"weapon_sporelauncher", "Spore Launcher"},
  // {"weapon_shockrifle", "Shock Roach"},
  {"weapon_displacer", "Displacer Cannon"}
  // {"weapon_glock", "Glock"},
  // {"weapon_glock", "Glock"},
  // {"weapon_glock", "Glock"},
};



void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Amiral Router" );
	g_Module.ScriptInfo.SetContactInfo( "Admin menu" );  
	// g_Module.ScriptInfo.SetContactInfo( "aaaaaaaaaaaaaaaaaa clear;as_reloadplugins;as_listplugins;" );  
  
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );

  // add user command show_menu
 
  
}

void MapInit()
{
	g_TeleportPlayerLocations.deleteAll(); // Deletes all saved locations

}

HookReturnCode ClientSay( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ pArguments = pParams.GetArguments();
	
	if( pArguments.ArgC() >= 1 ){
		if( pArguments[ 0 ] == "/admin_menu" ){
      pParams.ShouldHide = true;
      AdminMenuShow(pPlayer);
			return HOOK_HANDLED;
    }
	}
	
	return HOOK_CONTINUE;
}

void AdminMenuShow(CBasePlayer@ pPlayer){ 
  @AdminMenu = CTextMenu(@AdminMenuCallback);
  AdminMenu.SetTitle("Main Menu: ");
  AdminMenu.AddItem("Teleport", any("Teleport"));
  AdminMenu.AddItem("Give", any("Give"));
  AdminMenu.AddItem("Team", any("Team"));
  AdminMenu.Register();
  AdminMenu.Open(0, 0, pPlayer);
}
void AdminMenuCallback(CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item) {
  if (item !is null && pPlayer !is null){
    if (item.m_szName == "Teleport"){
      TeleportMenuShow(pPlayer);
    }
    if (item.m_szName == "Give"){
      GiveMenuShow(pPlayer);
    }
    if (item.m_szName == "Team"){
      TeamMenuShow(pPlayer);
    }
  }
  if (@menu !is null && menu.IsRegistered()){
    menu.Unregister();
    @menu = null;
  }
}


void TeleportMenuShow(CBasePlayer@ pPlayer){
  @TeleportMenu = CTextMenu(@TeleportMenuCallback);
  TeleportMenu.SetTitle("Teleport Menu: ");
  TeleportMenu.AddItem("Save current location", any("Save current location"));
  TeleportMenu.AddItem("Load last location", any("Load last location"));
  TeleportMenu.AddItem("Teleport me to aim", any("Teleport me to aim"));
  TeleportMenu.Register();
  TeleportMenu.Open(0, 0, pPlayer);
}
void TeleportMenuCallback(CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item) {
  if (item !is null && pPlayer !is null){
    if (item.m_szName == "Save current location"){
      TeleportSavePlayerLocation(pPlayer);
    }
    else if (item.m_szName == "Load last location"){
      TeleportLoadPlayerLocation(pPlayer);
    }
    else if (item.m_szName == "Teleport me to aim"){
      TeleportMeToAim(pPlayer);
    }
  }

  if (@menu !is null && menu.IsRegistered())
    menu.Unregister();
    @menu = null;
}

void TeleportSavePlayerLocation(CBasePlayer@ pPlayer){
  if( ( pPlayer.pev.flags & FL_DUCKING ) != 0 ){
    g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Cannot save while ducking!\n" );
    return;
  }
  string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ); // Assigns the player their SteamID
  TeleportPlayerLocationData data;
  data.origin = pPlayer.pev.origin;
  data.pitch = pPlayer.pev.v_angle.x;
  data.yaw = pPlayer.pev.angles.y;
  g_TeleportPlayerLocations[ szSteamId ] = data;
  g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_STATIC, "items/r_item2.wav", 1.0f, 1.0f, 0, 100);
  g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Position saved!\n" );
  g_EngineFuncs.ClientPrintf(pPlayer, print_console, "Your saved position has been set to: " + data.origin.x + ' ' + data.origin.y + ' ' + data.origin.z + '\n');
}

void TeleportLoadPlayerLocation(CBasePlayer@ pPlayer){
  string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
  if( g_TeleportPlayerLocations.exists( szSteamId ) ){
    TeleportPlayerLocationData@ data = cast<TeleportPlayerLocationData@>( g_TeleportPlayerLocations[ szSteamId ] );
    TeleportPlayer( pPlayer, data.origin, data.pitch, data.yaw );
  }
}
void TeleportMeToAim(CBasePlayer@ pPlayer){
  TraceResult tr;
  Vector vecSrc = pPlayer.GetGunPosition();
  Vector vecAiming = pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
  Vector vecEnd = vecSrc + vecAiming * 8192; 

  g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, pPlayer.edict(), tr );
  if( tr.flFraction < 1.0 ){
    tr.vecEndPos.z += 50;
    TeleportPlayer( pPlayer, tr.vecEndPos, pPlayer.pev.v_angle.x, pPlayer.pev.angles.y );
  }
}
void TeleportPlayer(CBasePlayer@ pPlayer, Vector origin, float pitch, float yaw){
  pPlayer.SetOrigin( origin ); // Sets the player origin
  // Sets the player angles
  pPlayer.pev.angles.x = pitch;
  pPlayer.pev.angles.y = yaw;
  pPlayer.pev.angles.z = 0; //Do a barrel roll, not
  pPlayer.pev.fixangle = FAM_FORCEVIEWANGLES; // Applies the player angles
  NetworkMessage message( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY ); // Begin "swirling cloud of particles" effect
  message.WriteByte( TE_TELEPORT );
  message.WriteCoord( origin.x );
  message.WriteCoord( origin.y );
  message.WriteCoord( origin.z );
  message.End(); // End "swirling cloud of particles" effect
  g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_STATIC, "items/r_item1.wav", 1.0f, 1.0f, 0, 100); // Play "Position loaded" sound
  g_Game.AlertMessage( at_console, "Sending Player \"%1\" to: " + origin.x + ' ' + origin.y + ' ' + origin.z + "\n", pPlayer.pev.netname ); // Shows the player's coordinates in console
}


void GiveMenuShow(CBasePlayer@ pPlayer){
  @GiveMenu = CTextMenu(@GiveMenuCallback);
  GiveMenu.SetTitle("Give Menu: ");
  GiveMenu.AddItem("Give Suit", any("Give Suit"));
  GiveMenu.AddItem("Give Weapons", any("Give Weapons"));
  GiveMenu.AddItem("Give Ammo", any("Give Ammo"));
  GiveMenu.AddItem("Give Health", any("Give Health"));
  GiveMenu.AddItem("Give Armor", any("Give Armor"));
  GiveMenu.Register();
  GiveMenu.Open(0, 0, pPlayer);
}
void GiveMenuCallback(CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item) {
  if (item !is null && pPlayer !is null){
    if (item.m_szName == "Give Suit"){
      GiveSuit(pPlayer);
    }
    else if (item.m_szName == "Give Weapons"){
      GiveWeaponMenuShow(pPlayer);
    }
    else if (item.m_szName == "Give Ammo"){
      GiveAmmo(pPlayer);
    }
    else if (item.m_szName == "Give Health"){
      GiveHealth(pPlayer);
    }
    else if (item.m_szName == "Give Armor"){
      GiveArmor(pPlayer);
    }
  }

  if (@menu !is null && menu.IsRegistered())
    menu.Unregister();
    @menu = null;
}

void GiveSuit(CBasePlayer@ pPlayer){
  pPlayer.GiveNamedItem("item_suit");
  g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_STATIC, "items/r_item1.wav", 1.0f, 1.0f, 0, 100);
  g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Suit given!\n" );
}

void GiveWeaponMenuShow(CBasePlayer@ pPlayer){
  @GiveWeaponMenu = CTextMenu(@GiveWeaponMenuCallback);
  GiveWeaponMenu.SetTitle("Give Weapon Menu: ");
  GiveWeaponMenu.AddItem("ALL", any("ALL")); 
  for (uint i = 0; i < WeaponList.length(); ++i) {
    GiveWeaponMenu.AddItem(WeaponList[i][1], any(WeaponList[i][1])); 
  }
  GiveWeaponMenu.AddItem("Shock Roach", any("Shock Roach")); 
  GiveWeaponMenu.AddItem("Monster Roach", any("Monster Roach")); 
  GiveWeaponMenu.Register();
  GiveWeaponMenu.Open(0, 0, pPlayer);
}

void GiveWeaponMenuCallback(CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item) {
  if (item !is null && pPlayer !is null){
    for (uint i = 0; i < WeaponList.length(); ++i) {
      if (item.m_szName == "ALL" || item.m_szName == WeaponList[i][1])
        pPlayer.GiveNamedItem(WeaponList[i][0]);
    }
    if (item.m_szName == "Shock Roach")
      pPlayer.GiveNamedItem("weapon_shockrifle");
    if (item.m_szName == "Monster Roach")
      pPlayer.GiveNamedItem("monster_shockroach");
    g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_STATIC, "items/r_item1.wav", 1.0f, 1.0f, 0, 100);
    g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Weapons given!\n" );
  }
  if (@menu !is null && menu.IsRegistered())
    menu.Unregister();
    @menu = null;
}


void GiveAmmo(CBasePlayer@ pPlayer){
  pPlayer.GiveAmmo(9999, "9mm", 9999);
  pPlayer.GiveAmmo(9999, "357", 9999);
  pPlayer.GiveAmmo(9999, "ARgrenades", 9999);
  pPlayer.GiveAmmo(9999, "bolts", 9999);
  pPlayer.GiveAmmo(9999, "buckshot", 9999);
  pPlayer.GiveAmmo(9999, "uranium", 9999);
  pPlayer.GiveAmmo(9999, "rockets", 9999);
  pPlayer.GiveAmmo(9999, "snarks", 9999);
  pPlayer.GiveAmmo(9999, "hvr_rocket", 9999);
  pPlayer.GiveAmmo(9999, "556", 9999);
  pPlayer.GiveAmmo(9999, "762", 9999);
  pPlayer.GiveAmmo(9999, "gaussenergy", 9999);
  pPlayer.GiveAmmo(9999, "hornet", 9999);
  pPlayer.GiveAmmo(9999, "m203", 9999);
  pPlayer.GiveAmmo(9999, "mp5", 9999);
  pPlayer.GiveAmmo(9999, "tripmine", 9999);
  pPlayer.GiveAmmo(9999, "uranium", 9999);
  pPlayer.GiveAmmo(9999, "rpg_round", 9999);
  pPlayer.GiveAmmo(9999, "slam", 9999);
  pPlayer.GiveAmmo(9999, "satchel", 9999);
  pPlayer.GiveAmmo(9999, "snarks", 9999); 
  g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_STATIC, "items/r_item1.wav", 1.0f, 1.0f, 0, 100);
  g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Ammo given!\n" );
}

void GiveHealth(CBasePlayer@ pPlayer){
  pPlayer.TakeHealth(9999, DMG_GENERIC);
  g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_STATIC, "items/r_item1.wav", 1.0f, 1.0f, 0, 100);
  g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Health given!\n" );
}

void GiveArmor(CBasePlayer@ pPlayer){
  pPlayer.TakeArmor(9999, DMG_GENERIC);
  g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_STATIC, "items/r_item1.wav", 1.0f, 1.0f, 0, 100);
  g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Armor given!\n" );
}

void TeamMenuShow(CBasePlayer@ pPlayer){
  @TeamMenu = CTextMenu(@TeamMenuCallback);
  TeamMenu.SetTitle("Team Menu: ");
  TeamMenu.AddItem("Add Health 10", any("Add Health 10")); 
  TeamMenu.AddItem("Add Armor 10", any("Add Armor 10"));
  TeamMenu.AddItem("Full Health", any("Full Health")); 
  TeamMenu.AddItem("Full Armor", any("Full Armor"));
  TeamMenu.Register();
  TeamMenu.Open(0, 0, pPlayer);
}

void TeamMenuCallback(CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item) {
  if (item !is null && pPlayer !is null){
    if (item.m_szName == "Add Health 10"){
      TeamAddHealth(10); 
    }
    else if (item.m_szName == "Add Armor 10"){
      TeamAddArmor(10);
    }
    else if (item.m_szName == "Full Health"){
      TeamAddHealth(9999);
    }
    else if (item.m_szName == "Full Armor"){
      TeamAddArmor(9999);
    }
    g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_STATIC, "items/r_item1.wav", 1.0f, 1.0f, 0, 100);
    g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Team given!\n" );
  }
  if (@menu !is null && menu.IsRegistered())
    menu.Unregister();
    @menu = null;
}

void TeamAddHealth(int health){
  for (int i = 1; i <= g_Engine.maxClients; ++i){
    CBasePlayer@ mPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
    if (mPlayer !is null && mPlayer.IsConnected() && mPlayer.IsAlive()){
      mPlayer.TakeHealth(health, DMG_GENERIC);
    }
  }
}

void TeamAddArmor(int armor){
  for (int i = 1; i <= g_Engine.maxClients; ++i){
    CBasePlayer@ mPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
    if (mPlayer !is null && mPlayer.IsConnected() && mPlayer.IsAlive()){
      mPlayer.TakeArmor(armor, DMG_GENERIC);
    }
  }
}
