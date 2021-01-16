PREDATOR_PLR <- -1;
PREDATOR_OBJ <- -1;
MissilePos <- Vector(0,0,0);

function PredatorEnter(plr)
{
	//Set player
	PREDATOR_PLR = plr.ID;
	//Create Missile
	MissilePos = LOADEDMAP.AirDrop + Vector(0,0,100);
	local Missile = ::CreateObject(273,ZOMBIE_WORLD,MissilePos,255);
	PREDATOR_OBJ = Missile.ID;
	Missile.RotateToEuler(Vector(0,3.1415926/2,0),0);
	//Edit camera.
	plr.SetCameraPos(MissilePos+ Vector(0,0,10), MissilePos);
	plr.WhiteScanlines = true;
	return true;
}

function PredatorUpdate()
{
	if(PREDATOR_PLR == -1) return;
	local plr = FindPlayer(PREDATOR_PLR);
	MissilePos.z -= 1;
	FindObject(PREDATOR_OBJ).Pos = MissilePos;
	plr.SetCameraPos(MissilePos+ Vector(0,0,10), MissilePos);
	if((MissilePos.z - LOADEDMAP.AirDrop.z ) <= 2)
	{
		PredatorDetonate();
	}
	if(CHOPPER_PLR != -1)
	{
		if(MissilePos.z - (LOADEDMAP.AirDrop.z+ 40) <= 2)
		{
			PredatorDetonate();
			CrashChopper();
			PlaySoundAllPlayers(50004);
			SendDataToAllClient(StreamData.AnnounceKillstreak,plr.Name+" -1");
		}
	}
	if(OSPREY_PLR != -1)
	{
		if(MissilePos.z - (LOADEDMAP.AirDrop.z+ 40) <= 2)
		{
			if(DistanceFromPoint(FindObject(OSPREY).Pos.x,FindObject(OSPREY).Pos.y,LOADEDMAP.AirDrop.x,LOADEDMAP.AirDrop.y) <= 3)
			{
				PredatorDetonate();
				RemoveFromOSPREY();
				PlaySoundAllPlayers(50004);
				SendDataToAllClient(StreamData.AnnounceKillstreak,plr.Name+" -2");
			}
		}
	}
}
function PredatorDetonate()
{
	//reset player camera.
	local plr = FindPlayer(PREDATOR_PLR);
	plr.WhiteScanlines = false;
	plr.RestoreCamera();
	plr.Pos = LOADEDMAP.pos; //teleport to spawn
	//Create predator explosion and kill zombies.
	::CreateExplosion(ZOMBIE_WORLD,2,MissilePos,-1,false);
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
	//reset predator.
	PREDATOR_PLR = -1;
	FindObject(PREDATOR_OBJ).Delete();
}