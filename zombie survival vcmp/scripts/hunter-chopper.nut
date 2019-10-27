CHOPPER_VEH <- -1;
CHOPPER_OBJ <- -1;
CHOPPER_WAIT_LIST <- array(100,false);
CHOPPER_PLR <- -1
CHOPPER_OFFSET <- Vector(0,3.5,-2.5);
CHOPPER_TIMER <- 0.0;

function AddInChopper(plr)
{
	for(local i =0 ; i < 100;i++)
	{
		if(CHOPPER_WAIT_LIST[i] == true)
		{
			::MessagePlayer("[#FF0000]Hunter is already used!",plr);
			CHOPPER_WAIT_LIST[i] = true;
			return false;
		}
	}
	//put player in chopper gunner
	CHOPPER_TIMER = 120000; //ms
	CHOPPER_WAIT_LIST[plr.ID] = true;
	CHOPPER_PLR = plr.ID;
	plr.GiveWeapon(33,2500);
	plr.WhiteScanlines = true;
	plr.SetAlpha(0,0);
	//create chopper
	CHOPPER_OBJ = ::CreateObject(405,ZOMBIE_WORLD,(LOADEDMAP.AirDrop+Vector(200,0,30)),0).ID;
	FindObject(CHOPPER_OBJ).MoveTo(LOADEDMAP.spawn1 + Vector(0,0,40),10000);
	CHOPPER_VEH = ::CreateVehicle(VEH_HUNTER,ZOMBIE_WORLD,(LOADEDMAP.AirDrop+Vector(0,0,40)),0,1,1).ID;
	FindVehicle(CHOPPER_VEH).Health = 0x7fffffff;
	//create timer duration.
	return true;
}
function ChopperUpdate()
{
	if(CHOPPER_PLR == -1) return;
	CHOPPER_TIMER -= 50; //timer interval
	if((CHOPPER_TIMER % 10000) == 0)
	{
		local r = rand() % 4;
		if(r == 0)
		{
			FindObject(CHOPPER_OBJ).MoveTo(LOADEDMAP.spawn1 + Vector(0,0,40),10000);
		}
		if(r == 1)
		{
			FindObject(CHOPPER_OBJ).MoveTo(LOADEDMAP.spawn2 + Vector(0,0,40),10000);
		}
		if(r == 2)
		{
			FindObject(CHOPPER_OBJ).MoveTo(LOADEDMAP.spawn3 + Vector(0,0,40),10000);
		}
		if(r == 3)
		{
			FindObject(CHOPPER_OBJ).MoveTo(LOADEDMAP.AirDrop + Vector(0,0,40),10000);
		}
	}
	if(CHOPPER_TIMER <= 0)
	{
		RemoveFromChopper();
		return;
	}
	local player = FindPlayer(CHOPPER_PLR);
	if(player.GetAmmoAtSlot(7) == 0)
	{
		RemoveFromChopper();
		return;
	}
	//update player and chopper
	local chopper = FindVehicle(CHOPPER_VEH);
	player.Health = 255;
	chopper.Pos = FindObject(CHOPPER_OBJ).Pos;
	chopper.Angle = Quaternion(0,0,0,0);
	player.Pos = chopper.Pos + CHOPPER_OFFSET;
	chopper.Health = 0x7fffffff;
}
function RemoveFromChopper()
{
	//reset player
	local player = FindPlayer(CHOPPER_PLR);
	player.WhiteScanlines = false;	
	player.SetAlpha(255,255);
	player.Health = 100;
	player.Pos = LOADEDMAP.AirDrop;
	CHOPPER_WAIT_LIST[CHOPPER_PLR] = false;
	CHOPPER_PLR = -1;
	//reset chopper
	FindVehicle(CHOPPER_VEH).Delete();
	FindObject(CHOPPER_OBJ).Delete();
	CHOPPER_VEH = -1;
	for(local i =0 ; i < 100;i++)
	{
		if(CHOPPER_WAIT_LIST[i] == true)
		{
			if(FindPlayer(i) != null)
			{
				AddInChopper(FindPlayer(i));
			}
			else CHOPPER_WAIT_LIST[i] = false;
		}
	}
}
function CrashChopper()
{
	if(CHOPPER_PLR == -1) return;
	//reset player
	local player = FindPlayer(CHOPPER_PLR);
	player.GreenScanlines = false;	
	player.SetAlpha(255,255);
	player.Health = 100;
	player.Pos = LOADEDMAP.AirDrop;
	CHOPPER_WAIT_LIST[CHOPPER_PLR] = false;
	CHOPPER_PLR = -1;
	//reset chopper
	FindVehicle(CHOPPER_VEH).Health = 250;
	for(local i =0 ; i < 100;i++)
	{
		if(CHOPPER_WAIT_LIST[i] == true)
		{
			if(FindPlayer(i) != null)
			{
				AddInChopper(FindPlayer(i));
			}
			else CHOPPER_WAIT_LIST[i] = false;
		}
	}
}
function UpdateKillstreaks()
{
	ChopperUpdate();
	PredatorUpdate();
	REAPERUpdate();
	OSPREYUpdate();
}
KILLSTREAK_TIMER <- NewTimer("UpdateKillstreaks",50,0); // <-- create Update function timer.