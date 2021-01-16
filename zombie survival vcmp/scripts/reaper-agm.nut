///Idea: store player near the camera, and give him a custom kool weapon


REAPER_PLR <- -1;
REAPER_ROCKET_OBJ <- -1;
REAPERMissilePos <- Vector(0,0,0);
REAPER_Ammo <- 0;
function REAPEREnter(plr)
{
	if(REAPER_PLR == -1) REAPER_Ammo = 2+ rand() % 20;
	//Set player
	REAPER_PLR = plr.ID;
	//Create Missile
	REAPERMissilePos = LOADEDMAP.AirDrop + Vector(0,0,100);
	local Missile = ::CreateObject(273,ZOMBIE_WORLD,REAPERMissilePos,255);
	REAPER_ROCKET_OBJ = Missile.ID;
	Missile.RotateToEuler(Vector(0,3.1415926/2,0),0);
	//Edit camera.
	plr.SetCameraPos(REAPERMissilePos+ Vector(0,0,10), REAPERMissilePos);
	plr.WhiteScanlines = true;
	return true;
}

function REAPERUpdate()
{
	if(FindPlayer(REAPER_PLR) == null) 
	{
		REAPER_PLR = -1;
	}
	if(REAPER_PLR == -1) return;
	local plr = FindPlayer(REAPER_PLR);
	REAPERMissilePos.z -= 1;
	FindObject(REAPER_ROCKET_OBJ).Pos = REAPERMissilePos;
	plr.SetCameraPos(REAPERMissilePos+ Vector(0,0,10), REAPERMissilePos);
	if((REAPERMissilePos.z - LOADEDMAP.AirDrop.z ) <= 2)
	{
		REAPERDetonate();
	}
	if(CHOPPER_PLR != -1)
	{
		if(REAPERMissilePos.z - (LOADEDMAP.AirDrop.z+ 40) <= 2)
		{
			REAPERDetonate();
			PlaySoundAllPlayers(50004);
			CrashChopper();
			SendDataToAllClient(StreamData.AnnounceKillstreak,plr.Name+" -1");
		}
	}
	if(OSPREY_PLR != -1)
	{
		if(MissilePos.z - (LOADEDMAP.AirDrop.z+ 40) <= 2)
		{
			if(DistanceFromPoint(FindObject(OSPREY).Pos.x,FindObject(OSPREY).Pos.y,LOADEDMAP.AirDrop.x,LOADEDMAP.AirDrop.y) <= 3)
			{
				REAPERDetonate();
				PlaySoundAllPlayers(50004);
				RemoveFromOSPREY();
				SendDataToAllClient(StreamData.AnnounceKillstreak,plr.Name+" -2");
			}
		}
	}
}
function REAPERDetonate()
{
	//Create Reaper Missile explosion and kill zombies.
	local plr = FindPlayer(REAPER_PLR);
	::CreateExplosion(ZOMBIE_WORLD,2,REAPERMissilePos,-1,false);
	for(local i =0 ; i < 20;i++)
	{
		local victim = ::FindPlayer(ZOMBIES[i].PlayerRef);
		if(DistanceFromPoint(victim.Pos.x,victim.Pos.y,MissilePos.x,MissilePos.y) <= 30)
		{
			if(victim.object.World == ZOMBIE_WORLD)
			{
				victim.Kill(plr);
			}
		}
	}
	FindObject(REAPER_ROCKET_OBJ).Delete();
	REAPER_Ammo -= 1;
	if(REAPER_Ammo <= 0) ReaperExit();
	else {
		REAPEREnter(FindPlayer(REAPER_PLR));
		MessagePlayer("[#0000ff]Reaper rockets remaining:"+REAPER_Ammo,FindPlayer(REAPER_PLR));
	}
}
function ReaperExit()
{
	REAPER_Ammo = 0;
	//reset player camera.
	local plr = FindPlayer(REAPER_PLR);
	plr.Pos = LOADEDMAP.pos; //teleport to spawn
	plr.WhiteScanlines = false;
	plr.RestoreCamera();
	REAPER_PLR = -1;
	//reset Reaper.
}