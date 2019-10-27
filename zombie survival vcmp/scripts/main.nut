/*

			ZOMBIE SURVIVAL 0.4
							by Athanatos
	
	Update for Zombie Survival 0.4. See the changelog...
	
	
	
	Change Log:
	
	'✓'  <- (added)
	'--' <- (to be added)
	'X' <- (not added)
	
	Added:
		✓ Killstreak Icons
		✓ Killstreak UI announce
		✓ New killstreak: Osprey Gunner
	Changed:
		✓ How killstreaks generally work
		✓ Fixed some player resetting issues when starting a new round
		✓ Armour is now more usefull
	Removed:
		✓ Nothing
*/


///IMPORT SECTION


dofile("scripts/SETTINGS.nut",true); //gamemode settings
dofile("scripts/npc_ai.nut",true); //zombie `ai`
dofile("scripts/levels.nut",true); //arenas
dofile("scripts/zombie.nut",true); //gamemode itself
dofile("scripts/hunter-chopper.nut",true); //chopper gunner killstreak
dofile("scripts/predator-missile.nut",true); //predator missile killstreak
dofile("scripts/reaper-agm.nut",true); //reaper uav killstreak
dofile("scripts/osprey-gunner.nut",true); //reaper uav killstreak
dofile("scripts/Killstreak.nut",true); //Killstreak functions

enum StreamData
{
	Initialise = 0,
	WeaponShop = 1,
	GivePerk = 2,
	ResetPlayer = 3,
	RemovePerk = 4,
	Revive = 5,
	ButtonUp = 6,
	ButtonDown = 7,
	ButtonLeft = 8,
	ButtonRight = 9,
	Hit = 10,
	Killstreak = 11,
	AnnounceKillstreak = 12,
	OspreyStopCamera = 13,
	Spectate = 14
}

enum Perks
{
	None = -1,
	Jugg = 1,
	QuickRevive = 2,
	Immunity = 3,
	InstaKill = 4,
	DoubleScore = 5,
	Freeze = 6,
	Damage = 7,
	FastHealthRegen = 8,
}
///GLOBAL VAIRABLES SECTION


RED <- "[#ff0000]";
GREEN <- "[#00ff00]";
BLUE <- "[#0000FF]";
WHITE <- "[#FFFFFF]";

PLAYERS <- array(100,null);
ZOMBIES <- array(20,null);

LOADEDMAP <- null;

//CODE SECTION


function onScriptLoad()
{
	print("Loading scripts...");
	SetServerName("Zombie Survival 0.4");
	SetGameModeName("Zombie Survival 0.4");
	SetTime(0,0);
	SetWeather(2);
	SetShootInAir(true);
	SetFriendlyFire(true);
	PLANEID <- CreateObject(638,ZOMBIE_WORLD,Vector(0,0,0),255).ID;
	for(local i =0; i < MAX_NPCS;i++)
	{
		ZOMBIES[i] = ZNPC("Zombie",100,25);
	}
	print("<=====================================>");
	print("VC:MP Zombie Survival 0.4 by Athanatos");
	print("<== KILLSTREAK SYSTEM UPDATE ==>");
	print("<=====================================>");
	print("Scripts Loaded Successfully!");
	print("You are free to modify, publish and host this server how much you want, BUT please keep a little credit to me(Athanatos)");
}

function onScriptUnload()
{
}

function onPlayerJoin( player )
{
	MessagePlayer(GREEN+"Welcome "+RED+player+GREEN+" to "+BLUE+"Zombie Survival 0.4",player);
}

function onPlayerPart( player, reason )
{
	PLAYERS[player.ID] = null;
}

function onPlayerRequestClass( player, classID, team, skin )
{
	return 1;
}

function onPlayerRequestSpawn( player )
{
	return 1;
}

function onPlayerSpawn( player )
{
	if(PLAYERS[player.ID] != null)
	{
		if(PLAYERS[player.ID].Killed == true)
		{
			player.SpectateServer();
			Announce("Wait till the end of the round!",player,1);
			//return 1;
		}
	}
	PLAYERS[player.ID] = Survivor(player);
	player.Disarm();
	if(LOADEDMAP == null)
	{
		LoadMap();
	}
		player.Pos = LOADEDMAP.pos;
		PLAYERS[player.ID].Joined = true;
		player.World = ZOMBIE_WORLD;
		player.GiveWeapon(ZOMBIEDEFAULTWEAPON,ZOMBIEDEFAULTWEAPONAMMO);
		player.GiveWeapon(ZOMBIEDEFAULTWEAPONTWO,ZOMBIEDEFAULTWEAPONTWOAMMO);
		player.GiveWeapon(ZOMBIEDEFAULTWEAPONTHREE,ZOMBIEDEFAULTWEAPONTHREEAMMO);
		player.Cash = 500;
		player.Skin = rand() % 160;
		player.Score = 0;
		player.Health = 100;
		player.Armour = 0;
}

function onPlayerDeath( player, reason )
{
	player.World = 1;
	player.Frozen = false;
	PLAYERS[player.ID].Killed = true;
}

function onPlayerKill( player, killer, reason, bodypart )
{
}

function onPlayerTeamKill( player, killer, reason, bodypart )
{
}

function onPlayerChat( player, text )
{
	print( player.Name + ": " + text );
	return 1;
}

function onPlayerCommand( player, cmd, text )
{
	cmd = cmd.tolower();
	switch(cmd)
	{
		///Commands for players:
		case "help":
		{
			MessagePlayer("[#ffffff]Zombie Gamemode Commands: /skin , /stats",player);
			break;
		}
		case "skin":
		{
			if(text == null)
			{
				MessagePlayer("[#ff0000]Use /skin <id>",player);
				break;
			}
			try{
				player.Skin = text.tointeger();
			}
			catch(e)
			{
				MessagePlayer("[#ff0000]Use /skin <id number>",player);
				MessagePlayer("More details:"+e,player);
			}
			break;
		}
		case "stats":
		{
			if(text == null) 
			{
				MessagePlayer("[#ff0000]Use /stats <player>",player);
				break;
			}
			if(FindPlayer(text) == null)
			{
				MessagePlayer("[#ff0000]This player doesn't exist",player);
				break;
			}
			Message("[#0000ff]Stats: "+FindPlayer(text).Name);
			Message("[#ffffff]Cash: "+FindPlayer(text).Cash);
			Message("[#ffffff]Kills: "+FindPlayer(text).Score);
			break;
		}
		///Administration commands:
		case "pos":
		{
			Message(player.Pos+"");
			break;
		}
		case "scriptreload":
		{
			if(player.IP == "127.0.0.1")
			{
				for(local i =0; i < 3000; i ++)
				{
					if(FindObject(i) != null) FindObject(i).Delete();
					if(FindPickup(i) != null) FindPickup(i).Remove();
					if(FindVehicle(i) != null) FindVehicle(i).Remove();
					if(FindCheckpoint(i) != null) FindCheckpoint(i).Remove();
				}
				ReloadScripts();
			}
			break;
		}
		case "exec":
		{
			if(player.IP == "127.0.0.1")
			{
				if( !text ) MessagePlayer( "Error - Syntax: /exec <Squirrel code>", player);
				else
				{
					try
					{
						local script = compilestring( text );
						Message(WHITE+"Executed:"+text);
						script();
					}
					catch(e) MessagePlayer( "Error: " + e, player);
				}	
			}
			break;
		}
	}
}

function onPlayerPM( player, playerTo, message )
{
	return 1;
}

function onPlayerBeginTyping( player )
{
}

function onPlayerEndTyping( player )
{
}
function onNameChangeable( player )
{
}

function onPlayerSpectate( player, target )
{
}

function onPlayerCrashDump( player, crash )
{
}

function onPlayerMove( player, lastX, lastY, lastZ, newX, newY, newZ )
{
}

function onPlayerHealthChange( player, lastHP, newHP )
{
}

function onPlayerArmourChange( player, lastArmour, newArmour )
{
}

function onPlayerWeaponChange( player, oldWep, newWep )
{
}

function onPlayerAwayChange( player, status )
{
}

function onPlayerNameChange( player, oldName, newName )
{
}

function onPlayerActionChange( player, oldAction, newAction )
{
}

function onPlayerStateChange( player, oldState, newState )
{
}

function onPlayerOnFireChange( player, IsOnFireNow )
{
}

function onPlayerCrouchChange( player, IsCrouchingNow )
{
}

function onPlayerGameKeysChange( player, oldKeys, newKeys )
{
}

function onPlayerUpdate( player, update )
{
}
function onClientScriptData( player )
{
	local integer = Stream.ReadInt();
	local str = Stream.ReadString();
	local s = PLAYERS[player.ID];
	switch(integer)
	{
		case StreamData.Initialise:
		{
			break;
		}
		case StreamData.WeaponShop:
		{
			local id = GetTok(str," ",1).tointeger(), price = GetTok(str," ",2).tointeger();
			if(player.Cash >= price)
			{
				switch(id)
				{
					case 0:
					{
						local wep = Random(17,34);
						if(wep == 30) wep = 32
						if(wep == 31) wep = 32
						player.GiveWeapon(wep,500);
						break;
					}
					case 1:
					{
						if(s.MaxHP == 200) 
						{
							MessagePlayer("[#ff0000]You already have Juggernaut!",player);
							return;
						}
						s.MaxHP = 200;
						s.GivePerk(Perks.Jugg);
						break;
					}
					case 2:
					{
						if(s.FastRevive) 
						{
							MessagePlayer("[#ff0000]You already have Fast Revive!",player);
							return;
						}
						if(s.FastReviveCounter == 5)
						{
							MessagePlayer("[#ff0000]You can only get Fast Revive 5 times per session!",player);
						}
						s.FastRevive = true;
						s.GivePerk(Perks.QuickRevive);
						break;
					}
					case 3:
					{
						if(s.FastHealthRegen) 
						{
							MessagePlayer("[#ff0000]You already have Fast Health Regeneration!",player);
							return;
						}
						s.FastHealthRegen = true;
						s.GivePerk(Perks.FastHealthRegen);
						break;
					}
					case 4:
					{
						if(s.DamagePerk) 
						{
							MessagePlayer("[#ff0000]You already have Extra Damage!",player);
							return;
						}
						s.DamagePerk = true;
						s.GivePerk(Perks.Damage);
						break;
					}
					case 5:
					{
						local oldWep = player.Weapon;
						if(player.Weapon < 15)
						{
							MessagePlayer("[#ff0000]You must have a weapon!",player);
							break;
						}
						if(player.Weapon > 33)
						{
							MessagePlayer("[#ff0000]This weapon cannot be upgraded!",player);
							break;
						}
						player.RemoveWeapon(player.Weapon);
						player.GiveWeapon(oldWep+100,500);
						break;
					}
					case 6:
					{
						if(player.Weapon >= 16) player.GiveWeapon(player.Weapon,100);
						else MessagePlayer("[#ff0000]You must have a weapon!",player);
						break;
					}
					case 7:
					{
						RandomKillstreakReward(player);
						break;
					}
					case 8:
					{
						LotteryItem(player);
						break;
					}
					default:
					{
						Message("Error: WEP_BUY ID"+id);
						break; 
					}
				}
				player.Cash -= price;				
			}
			else MessagePlayer(RED+"You need "+price+" cash",player);
			break;
		}
		case StreamData.GivePerk:
		{
			break;
		}
		case StreamData.ResetPlayer:
		{
			break;
		}
		case StreamData.RemovePerk:
		{
			break;
		}
		///TODO : Something is really wrong here.
		case StreamData.Revive:
		{
			if(PLAYERS[player.ID].NeedToBeSaved == true)
			{
				MessagePlayer("[#ff0000]You can't save someone else when you are down!",player);
				break;
			}
			local d = 0x7fffffff,s ; //d = int32 max
			for(local i =0 ; i < 100 ; i++)
			{
				if(i == player.ID ) continue;
				local survivor = PLAYERS[i];
				if(survivor != null)
				{
					if(survivor.player != null)
					{
						if(survivor.NeedToBeSaved == true)
						{
							local a = DistanceFromPoint(player.Pos.x,player.Pos.y,survivor.player.Pos.x,survivor.player.Pos.y);
							if( a <= d){
								d = a;
								if( d <= 5 )
								{
									s = survivor;
									break;
								}
								else
								{
									s = "[#ff0000]You are too far from any downed player!";
								}
							}
						}
					}
				}
			}
			if(s == "[#ff0000]You are too far from any downed player!")
			{
				MessagePlayer(s,player);
				break;
			}
			if(s != null)
			{
				s.Revive(PLAYERS[player.ID]);
			}
			break;
		}
		case StreamData.ButtonUp:
		{
			if(REAPER_PLR == player.ID)
			{
				REAPERMissilePos.y += 1;
			}
			break;
		}
		case StreamData.ButtonDown:
		{
			if(REAPER_PLR == player.ID)
			{
				REAPERMissilePos.y -= 1;
			}
			break;
		}
		case StreamData.ButtonRight:
		{
			if(REAPER_PLR == player.ID)
			{
				REAPERMissilePos.x += 1;
			}
			break;
		}
		case StreamData.ButtonLeft:
		{
			if(REAPER_PLR == player.ID)
			{
				REAPERMissilePos.x -= 1;
			}
			break;
		}
		case StreamData.Killstreak:
		{
			PLAYERS[player.ID].UseKillstreak();
			break;
		}
		case StreamData.Spectate:
		{
			if(PLAYERS[player.ID].Killed == true)
			{
				player.SpectateNextPlayer(PLAYERS[player.ID].CurrentlySpectating);
			}
		}
	}
}
function GetTok(string, separator, n, ...)
{
 local m = vargv.len() > 0 ? vargv[0] : n,
   tokenized = split(string, separator),
   text = "";
 if (n > tokenized.len() || n < 1) return null;
 for (; n <= m; n++)
 {
 text += text == "" ? tokenized[n-1] : separator + tokenized[n-1];
 }
 return text;
}

function Random(min,max) { return min + (rand() % (max-min)); }

function onPlayerEnteringVehicle( player, vehicle, door )
{
	return 1;
}

function onPlayerEnterVehicle( player, vehicle, door )
{
}

function onPlayerExitVehicle( player, vehicle )
{
}

function onVehicleExplode( vehicle )
{
	if( vehicle.ID == CHOPPER_VEH)
	{
		vehicle.Delete();
	}
}

function onVehicleRespawn( vehicle )
{
}

function onVehicleHealthChange( vehicle, oldHP, newHP )
{
}

function onVehicleMove( vehicle, lastX, lastY, lastZ, newX, newY, newZ )
{
}
function onPickupClaimPicked( player, pickup )
{
	return 1;
}
enum Perks
{
	None = -1,
	Jugg = 1,
	QuickRevive = 2,
	Immunity = 3,
	InstaKill = 4,
	DoubleScore = 5,
	Freeze = 6,
	Damage = 7,
	FastHealthRegen = 8,
}
function onPickupPickedUp( player, pickup )
{
	if(pickup.Model == 383)
	{
		local pickperk = rand() % 7;
		if(pickperk == 0)
		{
			player.GiveWeapon(33,100);
			Announce("Minigun",player,0);
		}
		if(pickperk == 1)
		{
			ZOMBIE_DOUBLE += 30;
			SendDataToAllClient(StreamData.GivePerk,Perks.DoubleScore+"");
			AnnounceAll("Double score",0);
		}
		if(pickperk == 2)
		{
			ZOMBIE_FROZEN += 30;
			SendDataToAllClient(StreamData.GivePerk,Perks.Freeze+"");
			AnnounceAll("Freezer",0);
		}
		if(pickperk == 3)
		{
			ZOMBIE_INSTAKILL += 30;
			SendDataToAllClient(StreamData.GivePerk,Perks.InstaKill+"");
			AnnounceAll("InstaKill",0);
		}
		if(pickperk == 4)
		{
			ZOMBIE_IMMUNITY += 30;
			SendDataToAllClient(StreamData.GivePerk,Perks.Immunity+"");
			AnnounceAll("Invincibility",0);
		}
		if(pickperk == 5)
		{
			player.Cash += 500;
			Announce("Extra cash!",player,0);
		}
		if(pickperk == 6)
		{
			Message("[#ff0000]There was nothing in the bonus pickup >:) hehhehe");
		}
		pickup.Remove();
	}
	if(pickup.Model >= 274 && pickup.Model <= 290) pickup.Remove();
	if(pickup.Model == 368)
	{
		local arm = player.Armour;
		arm += 50;
		if(arm > 250) arm = 250;
		player.Armour = arm;
		
		local r = rand() % 10;
		if(r == 0) pickup.Remove();
	}
	if(pickup.Model == 405 )
	{
		for(local i =0 ; i < 8;i++)
		{
			player.GiveWeapon(player.GetWeaponAtSlot(i),100);
		}
		local r = rand() % 10;
		if(r == 0) pickup.Remove();
	}
	if(pickup.Model == 335)
	{
		RandomKillstreakReward(player);
		pickup.Remove();
	}
}

function onPickupRespawn( pickup )
{
}
function onObjectShot( object, player, weapon )
{
	local id = GetNPC(object.ID);
	if(id != -1)
	{
		ZOMBIES[id].Damage(player,player.Weapon);
	}
}

function onObjectBump( object, player )
{
	local id = GetNPC(object.ID);
	if(id != -1)
	{
		ZOMBIES[id].Hurt(player);
	}
}

function CheckpointColors(checkpoint,Colour)
{
	if(checkpoint.Color.r == Colour.r)
	{
		if(checkpoint.Color.g == Colour.g)
		{
			if(checkpoint.Color.b == Colour.b) return true;
			else return false;
		}
		else return false;
	}
	else return false;
}
function onCheckpointEntered( player, checkpoint )
{
	if(CheckpointColors(checkpoint,RGB(255,0,0)))
	{
		if(ZOMBIE_POWER == true) SendDataToClient(player,StreamData.WeaponShop,null);
		else MessagePlayer(RED+"Power needs to be activated!",player);
	}
}

function onCheckpointExited( player, checkpoint )
{
}
function onKeyDown( player, key )
{
}

function onKeyUp( player, key )
{
}

function SendDataToClient(player,int,string)
{
	Stream.StartWrite();
	Stream.WriteInt(int)
	if(string != null) Stream.WriteString(string);
	Stream.SendStream(player);
}
function SendDataToAllClient(int,string)
{
	for(local i =0 ; i < 100;i++)
	{
		if(FindPlayer(i) != null)
		{
			SendDataToClient(FindPlayer(i),int,string);
		}
	}
}
function PlaySoundAllPlayers(sound)
{
	for(local i =0 ; i < 100;i++)
	{
		if(FindPlayer(i) != null) {
			FindPlayer(i).PlaySound(sound);
			FindPlayer(i).PlaySound(sound);
			FindPlayer(i).PlaySound(sound);
		    FindPlayer(i).PlaySound(sound);
		}
	}
}