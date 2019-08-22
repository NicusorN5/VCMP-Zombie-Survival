//Pickup Perks: x2 Score, Immunity, InstaKill, Minigun, Freezer
class Survivor
{
	constructor(cplayer)
	{
		player = cplayer;
		Killstreaks = array(20,-1);
	}
	player = null;
	FastHealthRegen = false;
	FastRevive = false;
	SalvationTime = 0;
	MaxHP = 100;
	Joined = false;
	NeedToBeSaved = false;
	DamagePerk = false;
	FastReviveCounter = 0;
	PlayingInKillStreak = 0;
	Killstreaks = array(20,-1);
	Killed = false;
	CurrentlySpectating = 0;
}
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
function Survivor::Down()
{
	::Message(::RED+this.player+" needs to be revived!");
	::Message(::RED+"To revive "+this.player+" use the "+::BLUE+"[R]"+::RED+" key.");
	this.player.Frozen = true;
	this.player.SetAnim(25,210);
	this.NeedToBeSaved = true;
}
function Survivor::Up()
{
	this.player.Frozen = false;
	this.player.SetAnim(0,1);
	this.NeedToBeSaved = false;
	this.player.Health = 100;
	if(this.FastRevive)
	{
		this.FastReviveCounter += 1;
		::SendDataToClient(this.player,StreamData.RemovePerk,Perks.QuickRevive);
	}
}
function Survivor::Revive(Saviour)
{
	Saviour.player.Score += 1;
	GetKillStreakReward(Saviour.player);
	this.Up();
	::Message(GREEN+Saviour.player+" revived "+this.player);
}
function Survivor::Update()
{
	if(this.NeedToBeSaved == false)
	{
		if(this.player.Health < this.MaxHP)
		{
			this.player.Health += 1;
			if(this.FastHealthRegen) this.player.Health += 4;
			if(this.player.Health > this.MaxHP) this.player.Health = this.MaxHP;
		}
		if(this.player.Health <= 25) this.Down();
	}
	local oldHealth = this.player.Health;//used to detect uint8_t overflows
	if(this.NeedToBeSaved)
	{
		this.player.Health -= 1;
		if(this.player.Spawned && player.Health != 0)
		{
			if(this.player.Health > oldHealth)
			{
				this.player.Frozen = false;
				this.player.Kill();
				this.Killed = true;
				::Message(RED+this.player+" was killed by zombies!");
			}
			else if(this.player.Health == 1)
			{
				this.player.Frozen = false;
				this.player.Kill();
				::Message(RED+this.player+" was killed by zombies!");
			}
		}
		if(this.FastRevive)
		{
			this.player.Health += 6;
			if(this.player.Health >= 100)
			{
				this.Up();
				this.player.Health = this.MaxHP;
				this.FastRevive = false;
			}
		}
	}
	if(LOADEDMAP != null)
	{
		if(::DistanceFromPoint(this.player.Pos.x,this.player.Pos.y,::LOADEDMAP.pos.x,::LOADEDMAP.pos.y) > ::LOADEDMAP.distance)
		{
			if(this.player.Spawned == true)
			{
				::Announce("~o~GET BACK TO THE FIGHTNING ZONE COMRADE!",this.player,0);
				this.player.Health -= 5;
				if(this.FastHealthRegen) this.player.Health -= 4;
				if(this.player.Health > oldHealth)
				{
					player.Kill();
					::Message("[#ff0000]"+player+" is a traitor. He didn't got back to the fighting zone.");
				}
			}
		}
		else if(ZOMBIE_IMMUNITY >0 )
		{
			this.player.Health = this.MaxHP;
			if(this.NeedToBeSaved) this.Up();
		}
	}
}
function Survivor::GetDamagePerkStatus()
{
	if(this.DamagePerk == false) return 1;
	else return 2;
}
function Survivor::GivePerk(Perk)
{
	switch(Perk)
	{
		case Perks.Jugg:
		{
			this.MaxHP = 200;
			break;
		}
		case Perks.QuickRevive:
		{
			this.FastRevive = true;
			break;
		}
		case Perks.Damage: 
		{
			this.DamagePerk = true;
			break;
		}
		case Perks.FastHealthRegen:
		{
			this.FastHealthRegen = true;
			break;
		}
		default:
		{
			break;
		}
	}
	::SendDataToClient(this.player,StreamData.GivePerk,Perk+"");
}
function Survivor::AddKillstreak(killstreak)
{
	for(local i =0 ; i < 20;i++)
	{
		if(this.Killstreaks[i] == -1)
		{
			this.Killstreaks[i] = killstreak;
			break;
		}
	}
}
function Survivor::UseKillstreak()
{
	for(local i = 19; i >= 0 ; i--)
	{
		if(this.Killstreaks[i] != -1)
		{
			::UseKillstreak(this.player,GetKillstreakName(this.Killstreaks[i]));
			this.Killstreaks[i] = -1;
			break;
		}
	}
}

function CPlayer::Kill()
{
	this.Eject();
	this.Health = 0;
	this.Frozen = false;
}
function CPlayer::SpectateServer()
{
	for(local i =0 ; i < 100; i++)
	{
		if(i != this.ID)
		{
			if(::FindPlayer(i) != null)
			{
				this.SpectateTarget = ::FindPlayer(i);
				::PLAYERS[this.ID].CurrentlySpectating = i;
				::Announce("Use [SPACE] to spectate next player",this,0);
			}
		}
	}
}
function CPlayer::SpectateNextPlayer(current)
{
	for(local i =0 ; i < 100;i++)
	{
		if(i != this.ID)
		{
			if(i != current)
			{
				if(::FindPlayer(i) != null)
				{
					this.SpectateTarget = ::FindPlayer(i);
					::PLAYERS[this.ID].CurrentlySpectating = i;
					::Announce("Use [SPACE] to spectate next player",this,0);
				}
			}
		}
	}
}

ZOMBIE_WAVE <- 0;
ZOMBIE_REMAINING <- 0;
ZOMBIE_HEALTH <- 50;
ZOMBIE_GAMETIME <- 0;
ZOMBIE_POWER <- false;
ZOMBIE_PAUSE <- 0;
ZOMBIE_UAV <- 0;
ZOMBIE_UAV_ARRAY <- array(20,-1);
ZOMBIE_NUKE_TIMER <- -1;

function GetKillStreakReward(plr)
{
	local a = false;
	switch(plr.Score)
	{
		case 10:
		{
				SendDataToClient(plr,StreamData.Killstreak,GetKillstreakName(0));
				PLAYERS[plr.ID].AddKillstreak(0);
				a =  true;
				break;
		}
		case 25:
		{
				SendDataToClient(plr,StreamData.Killstreak,GetKillstreakName(1));
				PLAYERS[plr.ID].AddKillstreak(1);
				a =  true;
				break;
		}
		case 50:
		{
				SendDataToClient(plr,StreamData.Killstreak,GetKillstreakName(2));
				PLAYERS[plr.ID].AddKillstreak(2);
				a =  true;
				break;
		}
		case 75:
		{
				SendDataToClient(plr,StreamData.Killstreak,GetKillstreakName(3));
				PLAYERS[plr.ID].AddKillstreak(3);
				a =  true;
				break;			
		}
		case 100:
		{
				SendDataToClient(plr,StreamData.Killstreak,GetKillstreakName(4));
				PLAYERS[plr.ID].AddKillstreak(4);
				a =  true;
				break;
		}
		case 150:
		{
				SendDataToClient(plr,StreamData.Killstreak,GetKillstreakName(5));
				PLAYERS[plr.ID].AddKillstreak(5);
				a =  true;
				break;
		}
		case 200:
		{
				SendDataToClient(plr,StreamData.Killstreak,GetKillstreakName(6));
				PLAYERS[plr.ID].AddKillstreak(6);
				a =  true;
				break;
		}
		case 250:
		{
				SendDataToClient(plr,StreamData.Killstreak,GetKillstreakName(7));
				PLAYERS[plr.ID].AddKillstreak(7);
				a =  true;
				break;
		}
		case 300:
		{
				SendDataToClient(plr,StreamData.Killstreak,GetKillstreakName(8));
				PLAYERS[plr.ID].AddKillstreak(8);
				a =  true;
				break;
		}
		case 350:
		{
				SendDataToClient(plr,StreamData.Killstreak,GetKillstreakName(12));
				PLAYERS[plr.ID].AddKillstreak(12);
				a =  true;
				break;
		}
		case 400:
		{
				SendDataToClient(plr,StreamData.Killstreak,GetKillstreakName(9));
				PLAYERS[plr.ID].AddKillstreak(9);
				a =  true;
				break;
		}
		case 500:
		{
				SendDataToClient(plr,StreamData.Killstreak,GetKillstreakName(10));
				PLAYERS[plr.ID].AddKillstreak(10);
				a =  true;
				break;
		}
		case 600:
		{
				SendDataToClient(plr,StreamData.Killstreak,GetKillstreakName(11));
				PLAYERS[plr.ID].AddKillstreak(11);
				a =  true;
				break;			
		}
		default: break;
	}
	if(a)
	{
		::MessagePlayer(::RED+"Press [K] to activate!",plr);
	}
	
}

function CreateAirDropPickup(n)
{
	for(local i =0 ; i < n;i++)
	{
		local r = rand() % 4;
		if(r == 0)
		{
			local r2 = ::Random(274,290);
			::CreatePickup(r2,ZOMBIE_WORLD,500,LOADEDMAP.AirDrop+Vector(0,2*i,0),255,true);
		}
		if(r == 2)
		{
			local r2 = ::Random(274,290);
			::CreatePickup(r2,ZOMBIE_WORLD,500,LOADEDMAP.AirDrop+Vector(0,2*i,0),255,true);
		}
		if(r == 1)
		{
			::CreatePickup(383,ZOMBIE_WORLD,500,LOADEDMAP.AirDrop+Vector(0,2*i,0),255,true);
		}
		if(r == 3)
		{
			::CreatePickup(335,ZOMBIE_WORLD,500,LOADEDMAP.AirDrop+Vector(0,2*i,0),255,true);
		}
	}
}
function UpdateS()
{
	if(ZOMBIE_DEBUG == true) return;
	if(ZOMBIE_PAUSE > 0 )
	{
		Message("[#ffffff]New match starting in:"+ZOMBIE_PAUSE);
		ZOMBIE_PAUSE -= 1;
		return;
	}
	local ZombiesToSpawn = ZOMBIE_REMAINING;
	local players_remaining =0;
	for(local i =0; i < 100;i++)
	{
		local player = FindPlayer(i);
		if(player)
		{
			if(player.World == ZOMBIE_WORLD)
			{
				players_remaining ++;
				local survivor = PLAYERS[player.ID];
				if(survivor == null) {
					PLAYERS[player.ID] = Survivor(player);
					survivor = PLAYERS[player.ID];
				}
				survivor.Update();
			}
		}
	}
	for(local i =0 ; i < MAX_NPCS; i++)
	{
		if(ZOMBIES[i] != null)
		{
			if(ZOMBIES[i].object.World == ZOMBIE_WORLD)
			{
				ZombiesToSpawn -= 1;
			}
		}
	}
	if(ZOMBIE_INTERMISSION > 0)
	{
		ZOMBIE_INTERMISSION -=1;
		AnnounceAll("~h~Time left until next round:"+ZOMBIE_INTERMISSION,1);
		if(ZOMBIE_INTERMISSION == 0)
		{
			for(local i =0 ; i < 100;i++)
			{
				if(PLAYERS[i] != null)
				{
					if(PLAYERS[i].Killed == true)
					{
						PLAYERS[i].Killed = false;
						PLAYERS[i].CurrentlySpectating = 0;
						FindPlayer(i).SpectateTarget = null;
						onPlayerSpawn(FindPlayer(i));
					}
				}
			}
			StartWave();
		}
	}
	if(ZOMBIE_REMAINING != 0)
	{
		if(!ZOMBIE_INTERMISSION)
		{
			if(ZombiesToSpawn)
			{
				for(local i =0; i < MAX_NPCS;i++)
				{
					if(ZOMBIES[i].object.World != ZOMBIE_WORLD)
					{
						ZOMBIES[i].Respawn();
						break;
					}
				}
			}
		}	
	}
	if(ZOMBIE_REMAINING <= 0) 
	{
		if(!ZOMBIE_INTERMISSION)
		{
			ZOMBIE_INTERMISSION = 20;
			ZOMBIE_WAVE += 1;
			if(ZOMBIE_WAVE == 21)
			{
				ZS_Win();
			}
		}
	}
	if(players_remaining == 0)
	{
		ZS_Lost();
	}
	if(ZOMBIE_WAVE == 0)
	{
		KillAllZombies();
	}
	if(!ZOMBIE_INTERMISSION)
	{
		AnnounceAll("~o~Zombies left :~b~"+ZOMBIE_REMAINING);
	}
	ZOMBIE_GAMETIME += 1;
	if(ZOMBIE_IMMUNITY >0)
	{
		ZOMBIE_IMMUNITY -= 1;
		if(ZOMBIE_IMMUNITY == 0) SendDataToAllClient(StreamData.RemovePerk,Perks.Immunity+"");
	}
	if(ZOMBIE_INSTAKILL >0)
	{
		ZOMBIE_INSTAKILL -= 1;
		if(ZOMBIE_INSTAKILL == 0) SendDataToAllClient(StreamData.RemovePerk,Perks.InstaKill+"");
	}
	if(ZOMBIE_DOUBLE >0)
	{
		ZOMBIE_DOUBLE -= 1;
		if(ZOMBIE_DOUBLE == 0) SendDataToAllClient(StreamData.RemovePerk,Perks.DoubleScore+"");
	}
	if(ZOMBIE_FROZEN >0)
	{
		ZOMBIE_FROZEN -= 1;
		if(ZOMBIE_FROZEN == 0) SendDataToAllClient(StreamData.RemovePerk,Perks.Freeze+"");
	}
	if(ZOMBIE_UAV > 0)
	{
		for(local i =0 ; i < 20;i++)
		{
			DestroyMarker(ZOMBIE_UAV_ARRAY[i]);

			if(ZOMBIES[i].object.World == ZOMBIE_WORLD) {
				ZOMBIE_UAV_ARRAY[i] = CreateMarker( ZOMBIE_WORLD, ZOMBIES[i].object.Pos, 2, RGB(255,255,0), 0 );
			}
		}
		ZOMBIE_UAV -= 1;
		if(ZOMBIE_UAV == 0)
		{
			for(local i =0 ; i < 20;i++)
			{
				DestroyMarker(ZOMBIE_UAV_ARRAY[i]);
			}
		}
	}
	if(ZOMBIE_NUKE_TIMER >0)
	{
		ZOMBIE_MUTED = true;
		ZOMBIE_NUKE_TIMER -= 1;
		PlaySoundAll(50003);
		Message("[#ff0000]Nuke incoming in:"+ZOMBIE_NUKE_TIMER);
		if(ZOMBIE_NUKE_TIMER == 3)
		{
			SetGamespeed(0.25);
		}
		if(ZOMBIE_NUKE_TIMER == 0)
		{
			KillAllZombies();
			CreateExplosion(ZOMBIE_WORLD,2,LOADEDMAP.spawn1,-1,false);
			CreateExplosion(ZOMBIE_WORLD,2,LOADEDMAP.spawn2,-1,false);
			CreateExplosion(ZOMBIE_WORLD,2,LOADEDMAP.spawn3,-1,false);
			SetWeather(111);
			ZOMBIE_REMAINING = 0;
			ZOMBIE_NUKE_TIMER = -30;
			ZOMBIE_IMMUNITY = 0;
			SendDataToAllClient(StreamData.RemovePerk,Perks.Immunity+"");
			for(local i =0 ; i < 100;i++)
			{
				if(FindPlayer(i) != null) FindPlayer(i).Health = 30;
			}
		}
	}
	if(ZOMBIE_NUKE_TIMER < -1)
	{
		if(ZOMBIE_NUKE_TIMER == -30)
		{
			SetGamespeed(1);
		}
		ZOMBIE_NUKE_TIMER += 1;
		if(ZOMBIE_NUKE_TIMER == -1)
		{
			SetWeather(2);
			ZOMBIE_MUTED = false;
		}
	}
}


function UpdateZ()
{
	for(local i =0 ; i < MAX_NPCS; i++)
	{
		if(ZOMBIES[i] != null)
		{
			ZOMBIES[i].Update();
		}
	}
}
function LotteryItem(player)
{
	local r = rand() % 17;
	switch(r)
	{
		case 0 :
		{
			player.Cash += 3000;
			MessagePlayer("[#00ff00]You got your cash back!",player);
			break;
		}
		case 1 :
		{
			player.Health = 10;
			MessagePlayer("[#ff0000]Unlucky! hehehe",player);
			break;
		}
		case 2:
		{
			player.Kill();
			MessagePlayer("[#ff0000]Unlucky! OOF",player);
			break;
		}
		case 3:
		{
			player.Disarm();
			MessagePlayer("[#ff0000]Lost all weapons!",player);
			break;
		}
		case 4:
		{
			player.Cash -= 1000;
			MessagePlayer("[#ff0000]You lost 4000 $!",player);
			if(player.Cash < 0) player.Cash = 0;
			break;
		}
		case 5:
		{
			player.Cash = 3000;
			MessagePlayer("[#ff0000]You lost all your money",player);
			break;
		}
		case 6:
		{
			RandomKillstreakReward(player);
			MessagePlayer("[#00ff00]Killstreak reward!",player);
			break;
		}
		case 7:
		{
			player.Cash += 4000;
			MessagePlayer("[#00ff00]You won 1000!",player);
			break;
		}
		case 8:
		{
			player.Cash += 13000;
			MessagePlayer("[#00ff00]You won 10000!",player);
			break;
		}
		case 9:
		{
			player.GiveWeapon(33,2500);
			MessagePlayer("[#00ff00]You a minigun!",player);
			break;
		}
		case 10:
		{
			player.Armour = 200;
			MessagePlayer("[#00ff00]You won armour!",player);
			break;
		}
		case 11:
		{
			MessagePlayer("[#ff0000]Nothing!",player);
			break;
		}
		case 12:
		{
			player.Cash += 103000;
			MessagePlayer("[#00ff00]You won 100000!",player);
			break;
		}
		case 13:
		{
			player.Health = PLAYERS[player.ID].MaxHP;
			MessagePlayer("[#00ff00]You won a Insta-Heal!",player);
			break;
		}
		case 14:
		{
			player.GiveWeapon(133,2500);
			MessagePlayer("[#00ff00]You won a upgraded minigun",player);
			break;
		}
		case 15:
		{
			CreatePickup(383,ZOMBIE_WORLD,1,player.Pos,255,true);
			MessagePlayer("[#00ff00]You won a pickup bonus",player);
			break;
		}
		case 16:
		{
			player.Health = PLAYERS[player.ID].MaxHP;
			player.Armour = 200;
			MessagePlayer("[#00ff00]You won a Insta-Heal and a armour!",player);
			break;
		}
		default: break;
	}
}
function StartWave()
{
	switch(ZOMBIE_WAVE)
	{
		case 0:
		{
			ZOMBIE_WAVE = 1;
			StartWave();
			break;
		}
		case 1:
		{
			ZOMBIE_REMAINING = 1 * DIFFICULTY;
			ZOMBIE_HEALTH = 50;
			break;
		}
		case 2:
		{
			ZOMBIE_REMAINING = 2 * DIFFICULTY;
			ZOMBIE_HEALTH = 50;
			break;
		}
		case 3:
		{
			ZOMBIE_REMAINING = 3 * DIFFICULTY;
			ZOMBIE_HEALTH = 50;
			break;
		}
		case 3:
		{
			ZOMBIE_REMAINING = 3 * DIFFICULTY;
			ZOMBIE_HEALTH = 50;
			break;
		}
		case 4:
		{
			ZOMBIE_REMAINING = 5 * DIFFICULTY;
			ZOMBIE_HEALTH = 50;
			break;
		}
		case 5:
		{
			ZOMBIE_REMAINING = 1;
			ZOMBIE_HEALTH = 1000*DIFFICULTY;
			break;
		}
		case 6:
		{
			ZOMBIE_REMAINING = 5 * DIFFICULTY;
			ZOMBIE_HEALTH = 100;
			break;
		}
		case 7:
		{
			ZOMBIE_REMAINING = 10 * DIFFICULTY;
			ZOMBIE_HEALTH = 100;
			break;
		}
		case 8:
		{
			ZOMBIE_REMAINING = 15 * DIFFICULTY;
			ZOMBIE_HEALTH = 100;
			break;
		}
		case 9:
		{
			ZOMBIE_REMAINING = 20 * DIFFICULTY;
			ZOMBIE_HEALTH = 100;
			break;
		}
		case 10:
		{
			ZOMBIE_REMAINING = 2;
			ZOMBIE_HEALTH = 1000*DIFFICULTY;
			break;
		}
		case 11:
		{
			ZOMBIE_REMAINING = 20 * DIFFICULTY;
			ZOMBIE_HEALTH = 150;
			break;
		}
		case 12:
		{
			ZOMBIE_REMAINING = 25 * DIFFICULTY;
			ZOMBIE_HEALTH = 150;
			break;
		}
		case 13:
		{
			ZOMBIE_REMAINING = 30 * DIFFICULTY;
			ZOMBIE_HEALTH = 150;
			break;
		}
		case 14:
		{
			ZOMBIE_REMAINING = 40 * DIFFICULTY;
			ZOMBIE_HEALTH = 150;
			break;
		}
		case 15:
		{
			ZOMBIE_REMAINING = 1 
			ZOMBIE_HEALTH = 1000* DIFFICULTY;
			break;
		}
		case 16:
		{
			ZOMBIE_REMAINING = 40 * DIFFICULTY;
			ZOMBIE_HEALTH = 200;
			break;
		}
		case 17:
		{
			ZOMBIE_REMAINING = 50 * DIFFICULTY;
			ZOMBIE_HEALTH = 200;
			break;
		}
		case 18:
		{
			ZOMBIE_REMAINING = 60 * DIFFICULTY;
			ZOMBIE_HEALTH = 200;
			break;
		}
		case 19:
		{
			ZOMBIE_REMAINING = 70 * DIFFICULTY;
			ZOMBIE_HEALTH = 200;
			break;
		}
		case 20:
		{
			ZOMBIE_REMAINING = 10;
			ZOMBIE_HEALTH = 1000*DIFFICULTY;
			break;
		}
	}
	AnnounceAll("~o~Wave "+ZOMBIE_WAVE,3);
}
function PlaySoundAll(sound)
{
	for(local i =0 ; i < 100;i++)
	{
		if(FindPlayer(i) != null)
		{
			FindPlayer(i).PlaySound(sound);
		}
	}
}
function ZS_Lost()
{
	ZOMBIE_POWER = false;
	ZOMBIE_INTERMISSION = 15;
	AnnounceAll("~o~ZOMBIES ATE THE HUMANS!",3);
	local minutes = ZOMBIE_GAMETIME / 60;
	local hours = minutes / 60;
	AnnounceAll("Rounds survived:"+ZOMBIE_WAVE+" Time: "+hours+":"+minutes+":"+ZOMBIE_GAMETIME % 60,1);
	LOADINGMAP = false;
	KillAllZombies();
	if((CountAndSpawnPlayers()) && (CountPlayersInZombieWorld())) LoadMap();
	
	ResetAllPlayers();
	ResetMatch();
}
function ZS_Win()
{
	ZOMBIE_POWER = false;
	AnnounceAll("~h~HUMANS KILLED ALL THE ZOMBIES!",3);
	local minutes = ZOMBIE_GAMETIME / 60;
	local hours = minutes / 60;
	AnnounceAll("Time: "+hours+"h "+minutes+"m "+ZOMBIE_GAMETIME % 60,1);
	LOADINGMAP = false;
	KillAllZombies();
	LoadMap();
	ResetAllPlayers();
	ResetMatch();
}
function KillAllZombies()
{
	for(local i =0; i < MAX_NPCS ;i++)
	{
		if(ZOMBIES[i] != null) ZOMBIES[i].Kill(null);
	}
}
function CountAndSpawnPlayers()
{
	for(local i =0; i < 100; i++)
	{
		if(FindPlayer(i) != null)
		{
			FindPlayer(i).Spawn();
			return true;
		}
	}
	return false;
}
function CountPlayersInZombieWorld()
{
	for(local i =0; i < 100; i++)
	{
		if(FindPlayer(i))
		{
			if(FindPlayer(i).World == ZOMBIE_WORLD) return true;
		}
	}
	return false;
}
function ResetAllPlayers()
{
	for(local i =0 ; i < 100;i++)
	{
		if(FindPlayer(i) != null)
		{
			onPlayerSpawn(FindPlayer(i));
		}
	}
	SendDataToAllClient(StreamData.ResetPlayer,0);
}
function ResetMatch()
{
	ZOMBIE_WAVE = 0;
	ZOMBIE_REMAINING = 0;
	ZOMBIE_HEALTH = 50;
	ZOMBIE_GAMETIME = 0;
	ZOMBIE_POWER = false;
	ZOMBIE_PAUSE = 30;
}
SECTIMER <- NewTimer("UpdateS",1000,0);
TIMERzombie <- NewTimer("UpdateZ",200,0);