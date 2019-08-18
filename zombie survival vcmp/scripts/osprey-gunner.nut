OSPREY <- -1;
OSPREY_PLR <- -1
OSPREY_OFFSET <- Vector(0,6,-3);
OSPREY_TIMER <- 0.0;
OSPREY_DROPPED <- false;
OSPREY_GONE <- false;

function AddInOSPREY(plr)
{
	//put player in OSPREY gunner
	plr.WhiteScanlines = true;
	OSPREY_TIMER = 120000; //ms
	OSPREY_PLR = plr.ID;
	plr.GiveWeapon(132,600);
	plr.SetAlpha(0,0);
	//create OSPREY
	OSPREY = ::CreateObject(6002,ZOMBIE_WORLD,Vector(-1308.24, -953.786, 100.868),255).ID;
	FindObject(OSPREY).MoveTo(LOADEDMAP.AirDrop+Vector(0,0,40),30000);
	//create timer duration.
	OSPREY_DROPPED = false;
	OSPREY_GONE = false;
	return true;
}
function OSPREYUpdate()
{
	if(FindPlayer(OSPREY_PLR) == null)
	{
		OSPREY_PLR = -1;
		if(FindObject(OSPREY) == null) return;
		FindObject(OSPREY).MoveTo(LOADEDMAP.AirDrop+Vector(0,0,40),30000);
		OSPREY_GONE = true;
	}
	if(OSPREY_TIMER <= 0)
	{
		RemoveFromOSPREY();
		return;
	}
	if(OSPREY_PLR == -1) return;
	if(OSPREY_DROPPED == false)
	{
		local drop = LOADEDMAP.AirDrop+Vector(0,0,40);
		if(DistanceFromPoint(FindObject(OSPREY).Pos.x,FindObject(OSPREY).Pos.y,drop.x,drop.y) <= 3)
		{
			::CreateAirDropPickup(Random(7,12));
			OSPREY_DROPPED = true;
		}
	}
	OSPREY_TIMER -= 50; //timer interval
	if(OSPREY_TIMER <= 10000)
	{
		if(OSPREY_GONE == false)
		{
			FindObject(OSPREY).MoveTo(LOADEDMAP.AirDrop+Vector(-1308.24, -953.786, 100.868),30000);
			OSPREY_GONE = true;
		}
	}
	local player = FindPlayer(OSPREY_PLR);
	if(player.GetAmmoAtSlot(7) == 0)
	{
		RemoveFromOSPREY();
		return;
	}
	//update player and OSPREY
	player.Health = 255;
	player.Pos = FindObject(OSPREY).Pos + OSPREY_OFFSET;
}
function RemoveFromOSPREY()
{
	//reset player
	local player = FindPlayer(OSPREY_PLR);
	if(player)
	{
		player.WhiteScanlines = false;	
		player.SetAlpha(255,255);
		player.Health = 100;
		player.Pos = LOADEDMAP.AirDrop;
	}
	OSPREY_PLR = -1;
	SendDataToClient(player,13,null);
	FindObject(OSPREY).Delete();
	OSPREY = -1;
}