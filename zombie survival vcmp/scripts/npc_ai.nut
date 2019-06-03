//GLOBAL VARIABLES SECTION

//CONSTANTS

MAX_NPCS <- 20;
NPC_FOLLOWDISTANCE <- 50;
ZOMBIE_WORLD <- 3;
ZOMBIE_FROZEN <- 0;
ZOMBIE_INSTAKILL <- 0;
ZOMBIE_DOUBLE <- 0;
ZOMBIE_IMMUNITY <- 0;

class ZNPC
{
	constructor(cname,chealth,cdamage)
	{
		object = ::CreateObject(6001,6,Vector(0,0,0),255);
		object.TrackingBumps = true;
		object.TrackingShots = true;
		name = cname;
		health = chealth;
		damage = cdamage;
	}
	name = "";
	object = null;
	originalhealth =0;
	health =0;
	damage = 0;
}
function ZNPC::Update()
{
	if(ZOMBIE_FROZEN > 0) return;
	for(local i =0; i < 100; i++)
	{
		local player = FindPlayer(i);
		if(player != null)
		{
			if(this.object.World != player.World ) continue;
			if(i == CHOPPER_PLR) continue;
			local distante = ::DistanceFromPoint(this.object.Pos.x,this.object.Pos.y,player.Pos.x,player.Pos.y)
			if(distante < NPC_FOLLOWDISTANCE);
			{
				if(this.object.Pos.x > player.Pos.x) this.object.Pos.x -= 0.1;
				if(this.object.Pos.x < player.Pos.x) this.object.Pos.x += 0.1;
				if(this.object.Pos.y > player.Pos.y) this.object.Pos.y -= 0.1;
				if(this.object.Pos.y < player.Pos.y) this.object.Pos.y += 0.1;
				if(this.object.Pos.z > player.Pos.z) this.object.Pos.z -= 0.1;
				if(this.object.Pos.z < player.Pos.z) this.object.Pos.z += 0.1;
				this.object.RotateToEuler(Vector(0,0,player.Angle),0);
				local r = rand () % 100;
				if(r == 0) ::PlaySound( ZOMBIE_WORLD, 50001, this.object.Pos );
			}	
			if(distante < 2 && PLAYERS[player.ID].NeedToBeSaved == false)
			{
				local originalhealth = player.Health;
				player.Health -= 1;
				if(player.Health > originalhealth) player.Kill();
			}			
		}
	}
}
function ZNPC::Kill(killer)
{
	local rng = rand() % 10;
	if(rng == 5)
	{
		if(ZOMBIE_INTERMISSION <= 0) ::CreatePickup(383,ZOMBIE_WORLD,1,this.object.Pos,255,true);
	}
	if(this.object.World ==  ZOMBIE_WORLD)
	{
		::PlaySound( ZOMBIE_WORLD, 50002, this.object.Pos );
	}
	if(::ZOMBIEDEATHEX == true)::CreateExplosion(this.object.World,1,this.object.Pos,-1,false);
	this.object.Pos = GetSpawnPos();
	this.object.World = 6;
	if(killer != null)
	{
		if(ZOMBIE_DOUBLE > 0) killer.Cash += ZOMBIE_HEALTH*2;
		else killer.Cash += ZOMBIE_HEALTH;
		killer.Score += 1;
		GetKillStreakReward(killer);
	}
	ZOMBIE_REMAINING -= 1;
}
function ZNPC::Respawn()
{
	this.object.Pos = GetSpawnPos();
	this.object.World = ZOMBIE_WORLD;
	this.health = ZOMBIE_HEALTH;
}
function ZNPC::Damage(player,weapon)
{
	this.health -= WeaponDMG(weapon) * PLAYERS[player.ID].GetDamagePerkStatus();
	if(this.health <= 0 ) this.Kill(player);
}
function ZNPC::Hurt(player)
{
	player.Health -= this.damage;
	::PlaySound( ZOMBIE_WORLD, 50001, this.object.Pos );
}


function GetNPC(objectID)
{
	for(local i =0 ; i < MAX_NPCS; i++)
	{
		if(ZOMBIES[i] != null)
		{
			if(ZOMBIES[i].object.ID == objectID) return i;
		}
	}
	return -1;
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

	if(ZOMBIE_INSTAKILL > 0) return 2*hp;
	return hp;
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