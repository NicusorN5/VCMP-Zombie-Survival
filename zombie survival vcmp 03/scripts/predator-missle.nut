PREDATOR_PLR <- -1;
PREDATOR_OBJ <- -1;
MisslePos <- Vector(0,0,0);
PREDATOR_WAIT_LIST <- array(100,false);

function PredatorEnter(plr)
{
	//Set player
	for(local i =0 ; i < 100;i++)
	{
		if(PREDATOR_WAIT_LIST[i] == true)
		{
			::MessagePlayer("[#FF0000]Predator UAV is already used!",plr);
			PREDATOR_WAIT_LIST[i] = true;
			return;
		}
	}
	PREDATOR_PLR = plr.ID;
	PREDATOR_WAIT_LIST[plr.ID] = true;
	//Create Missle
	MisslePos = LOADEDMAP.AirDrop + Vector(0,0,100);
	local Missle = ::CreateObject(273,ZOMBIE_WORLD,MisslePos,255);
	PREDATOR_OBJ = Missle.ID;
	Missle.RotateToEuler(Vector(0,3.1415926/2,0),0);
	//Edit camera.
	plr.SetCameraPos(MisslePos+ Vector(0,0,10), MisslePos);
	plr.WhiteScanlines = true;
}

function PredatorUpdate()
{
	if(PREDATOR_PLR == -1) return;
	local plr = FindPlayer(PREDATOR_PLR);
	MisslePos.z -= 1;
	FindObject(PREDATOR_OBJ).Pos = MisslePos;
	plr.SetCameraPos(MisslePos+ Vector(0,0,10), MisslePos);
	if((MisslePos.z - LOADEDMAP.AirDrop.z ) <= 2)
	{
		PredatorDetonate();
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
	::CreateExplosion(ZOMBIE_WORLD,2,MisslePos,-1,false);
	for(local i =0 ; i < 20;i++)
	{
		local victim = ZOMBIES[i];
		if(DistanceFromPoint(victim.object.Pos.x,victim.object.Pos.y,MisslePos.x,MisslePos.y) <= 30)
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
	PREDATOR_WAIT_LIST[plr.ID] = false;
	for(local i =0 ; i < 100;i++)
	{
		if(PREDATOR_WAIT_LIST[i] == true)
		{
			if(FindPlayer(i) != null)
			{
				PredatorEnter(FindPlayer(i));
			}
			else PREDATOR_WAIT_LIST[i] = false;
		}
	}
}