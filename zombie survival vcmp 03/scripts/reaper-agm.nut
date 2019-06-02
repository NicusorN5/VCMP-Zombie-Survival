///Idea: store player near the camera, and give him a custom kool weapon


REAPER_PLR <- -1;
REAPER_ROCKET_OBJ <- -1;
REAPERMisslePos <- Vector(0,0,0);
REAPER_WAIT_LIST <- array(100,false);
REAPER_Ammo <- 0;
function REAPEREnter(plr)
{
	if(REAPER_PLR == -1) REAPER_Ammo = 2+ rand() % 20;
	//Set player
	for(local i =0 ; i < 100;i++)
	{
		if(REAPER_WAIT_LIST[i] == true)
		{
			::MessagePlayer("[#FF0000]Reaper AGM is already used!",plr);
			REAPER_WAIT_LIST[i] = true;
			return;
		}
	}
	REAPER_PLR = plr.ID;
	REAPER_WAIT_LIST[plr.ID] = true;
	//Create Missile
	REAPERMisslePos = LOADEDMAP.AirDrop + Vector(0,0,100);
	local Missle = ::CreateObject(273,ZOMBIE_WORLD,REAPERMisslePos,255);
	REAPER_ROCKET_OBJ = Missle.ID;
	Missle.RotateToEuler(Vector(0,3.1415926/2,0),0);
	//Edit camera.
	plr.SetCameraPos(REAPERMisslePos+ Vector(0,0,10), REAPERMisslePos);
	plr.WhiteScanlines = true;
}

function REAPERUpdate()
{
	if(REAPER_PLR == -1) return;
	local plr = FindPlayer(REAPER_PLR);
	REAPERMisslePos.z -= 1;
	FindObject(REAPER_ROCKET_OBJ).Pos = REAPERMisslePos;
	plr.SetCameraPos(REAPERMisslePos+ Vector(0,0,10), REAPERMisslePos);
	if((REAPERMisslePos.z - LOADEDMAP.AirDrop.z ) <= 2)
	{
		REAPERDetonate();
	}
}
function REAPERDetonate()
{
	//Create Reaper Missile explosion and kill zombies.
	local plr = FindPlayer(REAPER_PLR);
	::CreateExplosion(ZOMBIE_WORLD,2,REAPERMisslePos,-1,false);
	for(local i =0 ; i < 20;i++)
	{
		local victim = ZOMBIES[i];
		if(DistanceFromPoint(victim.object.Pos.x,victim.object.Pos.y,REAPERMisslePos.x,REAPERMisslePos.y) <= 20)
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
		REAPER_WAIT_LIST[plr.ID] = false;
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
	REAPER_WAIT_LIST[plr.ID] = false;
	REAPER_PLR = -1;
	//reset Reaper.
	for(local i =0 ; i < 100;i++)
	{
		if(REAPER_WAIT_LIST[i] == true)
		{
			if(FindPlayer(i) != null)
			{
				REAPEREnter(FindPlayer(i));
			}
			else REAPER_WAIT_LIST[i] = false;
		}
	}
}