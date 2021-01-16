//GLOBAL VARIABLES SECTION

//CONSTANTS

MAX_NPCS <- 20;
NPC_FOLLOWDISTANCE <- 50;
ZOMBIE_WORLD <- 3;
ZOMBIE_FROZEN <- 0;
ZOMBIE_INSTAKILL <- 0;
ZOMBIE_DOUBLE <- 0;
ZOMBIE_IMMUNITY <- 0;
ZOMBIE_SPEED <- 0.2;
ZOMBIE_MUTED <- false;

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
	Hit = 10
}

class ZNPC
{
	constructor(pname,phealth,pdmg)
	{
		Name = pname;
		Health = phealth;
		damage = pdmg;
		this.Create();
	}
	BotReference = -1;
	Health = 0;
	ActorRef = -1;
	damage = 0;
	PlayerRef = -1;
	Name = "";
}

SpawnedZombiesCounter <- 0;
function ZNPC::Create()
{
	this.ActorRef = create_actor("Zombie"+SpawnedZombiesCounter,200, 388.031, -473.993, 12.3432, -2.15);
	this.PlayerRef = GetPlayerIDActor(this.ActorRef);
	::SpawnedZombiesCounter++;
	this.Health = 0;
}

function ZNPC::Respawn()
{
	local i = ::FindPlayer(this.PlayerRef);
	::spawn_actor(this.ActorRef);
	local p = GetSpawnPos();
	::correct_actor_pos(this.ActorRef,p.x,p.y,p.z);
	i.Pos = p;
	this.Health = ZOMBIE_HEALTH;
	i.World = ZOMBIE_WORLD;
	i.Colour = RGB(255,0,0);
	if(this.Health < 255) 
	{
		set_actor_health(this.ActorRef,this.Health);
		i.Health = this.Health;
	}
}

function ZNPC::Damage(player,weapon)
{
	local i = ::FindPlayer(this.PlayerRef);
	SendDataToClient(player,StreamData.Hit,null);
	local dec = WeaponDMG(weapon) * PLAYERS[player.ID].GetDamagePerkStatus();
	print("damage = "+dec+" current health "+this.Health); 
	this.Health -= dec;
	if(this.Health < 255) 
	{
		set_actor_health(this.ActorRef,this.Health);
		i.Health = this.Health;
	}
	if(this.Health <= 0)
	{
		kill_actor(this.ActorRef, weapon, player.ID, 0, true);
		this.Kill(player);
	}
}
function ZNPC::Hurt(player)
{
	local i = ::FindPlayer(this.PlayerRef);
	player.Health -= this.damage;
	::PlaySound( ZOMBIE_WORLD, 50001, i.Pos );
}
function ZNPC::Update()
{
	local zombie = ::FindPlayer(this.PlayerRef);
	if(ZOMBIE_FROZEN > 0) return;
	local distm = 1000000;
	local t = -1;
	local player = null;
	for(local i =0; i < 100; i++)
	{
		player = FindPlayer(i);
		if(this.PlayerRef == i) continue;
		if(player != null)
		{
			if(IsActor(i) == true) continue;
			if(zombie.World != player.World ) continue;
			if(i == CHOPPER_PLR) continue;
			if(i == OSPREY_PLR) continue;
			
			local distantce = ::DistanceFromPoint(zombie.Pos.x,zombie.Pos.y,player.Pos.x,player.Pos.y)
			if(distantce < distm);
			{
				distm = distantce;
				t = i;
			}
			local r = rand () % 100;
			if(r == 0) if(!ZOMBIE_MUTED) ::PlaySound( ZOMBIE_WORLD, 50001, zombie.Pos );
			
			if(distantce < 2 && PLAYERS[player.ID].NeedToBeSaved == false)
			{
				if(player.Armour > 0)
				{
					local originalarmour = player.Armour;
					player.Armour -= 1;
					if(player.Armour > originalarmour) player.Health -= 10;
				}
				else
				{
					local originalhealth = player.Health;
					player.Health -= 1;
					if(player.Health > originalhealth) player.Kill();
				}
			}			
		}
	}
	if(player)
	{
		local theta = player.Angle + 3.1415926;
		set_actor_angle(this.ActorRef,theta);
		this.Pos += Vector(sin(theta),cos(theta),0);
		correct_actor_pos(this.ActorRef,this.Pos);
		zombie.SetAnim(0,1);
	}
}
function ZNPC::Kill(killer)
{
	local i = FindPlayer(this.PlayerRef);
	if(i == null) return;
	local rng = rand() % 10;
	if(rng == 5)
	{
		if(ZOMBIE_INTERMISSION <= 0) ::CreatePickup(383,ZOMBIE_WORLD,1,i.Pos,255,true);
	}
	if(i.World == ZOMBIE_WORLD)
	{
		if(!ZOMBIE_MUTED) ::PlaySound( ZOMBIE_WORLD, 50002, i.Pos );
	}
	if(::ZOMBIEDEATHEX == true) ::CreateExplosion(ZOMBIE_WORLD,1,i.Pos,this.PlayerRef,false);
	if(killer != null)
	{
		if(ZOMBIE_DOUBLE > 0) killer.Cash += ZOMBIE_HEALTH*2;
		else killer.Cash += ZOMBIE_HEALTH;
		killer.Score += 1;
		::GetKillStreakReward(killer);
	}
	i.World = 1;
	i.Pos = Vector(0,0,0);
	correct_actor_pos(this.ActorRef,0,0,0);
	ZOMBIE_REMAINING -= 1;
}

function GetSpawnPos()
{
	if(LOADEDMAP != null)
	{
		local r = rand() % 3;
		if(r == 0) return LOADEDMAP.spawn1;
		if(r == 1) return LOADEDMAP.spawn2;
		if(r == 2) return LOADEDMAP.spawn3;
		return LOADEDMAP.spawn3;
	}
	return Vector(0,0,0);
}

function WeaponDMG(weapon)
{
	local hp = 25
		if(weapon == 17) hp = 25 ; //colt17
		if(weapon == 18) hp =125; //357
		if(weapon == 19) hp = 80 ; //shotgun
		if(weapon == 20) hp =100; //spas
		if(weapon == 21) hp = 120; //stubby
		if(weapon == 22) hp = 20 ; //tec9
		if(weapon == 23) hp = 20; //uzil
		if(weapon == 24) hp = 15 ; //mac10
		if(weapon == 25) hp = 35; //mp5
		if(weapon == 26) hp = 40 ; //m4
		if(weapon == 27) hp = 35; //ruger
		if((weapon == 28) || ( weapon == 29)) hp = 120 ; //sniper
		if(weapon == 32) hp = 120;//m60
		if(weapon == 33) hp = 140;//minigun
		//Upgraded Weapons.
		if(weapon == 117) hp = 50 ; //colt17
		if(weapon == 118) hp = 250; //357
		if(weapon == 119) hp = 160 ; //shotgun
		if(weapon == 120) hp = 200; //spas
		if(weapon == 121) hp = 240; //stubby
		if(weapon == 122) hp = 40 ; //tec9
		if(weapon == 123) hp = 40; //uzil
		if(weapon == 124) hp = 30 ; //mac10
		if(weapon == 125) hp = 70; //mp5
		if(weapon == 126) hp = 80 ; //m4
		if(weapon == 127) hp = 70; //ruger
		if((weapon == 128) || ( weapon == 29)) hp = 120 ; //sniper
		if(weapon == 132) hp = 240;//m60
		if(weapon == 133) hp = 280;//minigun

	if(ZOMBIE_INSTAKILL > 0) return 10*hp;
	return hp;
}