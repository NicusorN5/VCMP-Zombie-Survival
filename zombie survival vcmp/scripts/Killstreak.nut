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
	AnnounceKillstreak = 12
	OspreyStopCamera = 13
}

function UseKillstreak(plr,killstreak)
{
	switch(killstreak)
	{
		case "Power":
		{
			::Message(GREEN+"Player "+plr+" used Power!");
			::Message(WHITE+"Shop online!");
			::ZOMBIE_POWER = true;
			break;
		}
		case "UAV Radar":
		{
			::Message(GREEN+"Player "+plr+" used UAV Radar!");
			::ZOMBIE_UAV += 120;
			break;
		}
		case "Predator Missile":
		{
			::Message(GREEN+"Player "+plr+" used Predator Missile");
			if(PredatorEnter(plr) == false)
			{
				SendDataToClient(plr,StreamData.Killstreak,GetKillstreakName(4));
				PLAYERS[plr.ID].AddKillstreak(4);
			}
			break;
		}
		case "Insta Heal":
		{
			::Message(GREEN+"Player "+plr+" used Insta Heal");
			for(local i =0 ; i < 100;i++)
			{
				if(FindPlayer(i) != null)
				{
					::FindPlayer(i).Health = PLAYERS[i].MaxHP;
				}
			}
			break;
		}
		case "Care Package":
		{
			::Message(GREEN+"Player "+plr+" used Care Package");
			::FindObject(PLANEID).Pos = ::LOADEDMAP.AirDropPlanePoint1;
			::FindObject(PLANEID).RotateToEuler(Vector(0.0,0.0,::LOADEDMAP.AirDropAngle),0);
			::FindObject(PLANEID).MoveTo(::LOADEDMAP.AirDropPlanePoint2,10000);
			::CreateAirDropPickup(1);
			break;
		}
		case "Armour Airdrop Package":
		{
			::Message(GREEN+"Player "+plr+" used Armour Airdrop Package");
			::FindObject(PLANEID).Pos = ::LOADEDMAP.AirDropPlanePoint1;
			::FindObject(PLANEID).RotateToEuler(Vector(0.0,0.0,::LOADEDMAP.AirDropAngle),0);
			::FindObject(PLANEID).MoveTo(::LOADEDMAP.AirDropPlanePoint2,10000);
			::CreatePickup(368,ZOMBIE_WORLD,1+ rand() % 20 ,::LOADEDMAP.AirDrop,255,true);
			break;
		}
		case "Ammo Package":
		{
			::Message(GREEN+"Player "+plr+" used Ammo Airdrop Package");
			::FindObject(PLANEID).Pos = ::LOADEDMAP.AirDropPlanePoint1;
			::FindObject(PLANEID).RotateToEuler(Vector(0.0,0.0,::LOADEDMAP.AirDropAngle),0);
			::FindObject(PLANEID).MoveTo(::LOADEDMAP.AirDropPlanePoint2,10000);
			::CreatePickup(405,ZOMBIE_WORLD,1+ rand() % 20 ,::LOADEDMAP.AirDrop,255,true);
			break;
		}
		case "Chopper Gunner":
		{
			::Message(GREEN+"Player "+plr+" used Chopper Gunner");
			if(AddInChopper(plr) == false)
			{
				SendDataToClient(plr,StreamData.Killstreak,GetKillstreakName(7));
				PLAYERS[plr.ID].AddKillstreak(7);
			}
			break;
		}
		case "Care Package":
		{
			::Message(GREEN+"Player "+plr+" used Care Package");
			::FindObject(PLANEID).Pos = ::LOADEDMAP.AirDropPlanePoint1;
			::FindObject(PLANEID).RotateToEuler(Vector(0.0,0.0,::LOADEDMAP.AirDropAngle),0);
			::FindObject(PLANEID).MoveTo(::LOADEDMAP.AirDropPlanePoint2,10000);
			::CreateAirDropPickup(1);
			break;
		}
		case "Emergency AirDrop":
		{
			::Message(GREEN+"Player "+plr+" used Emergency AirDrop");
			::FindObject(PLANEID).Pos = ::LOADEDMAP.AirDropPlanePoint1;
			::FindObject(PLANEID).RotateToEuler(Vector(0.0,0.0,::LOADEDMAP.AirDropAngle),0);
			::FindObject(PLANEID).MoveTo(::LOADEDMAP.AirDropPlanePoint2,10000);
			::CreateAirDropPickup(Random(5,10));
			break;
		}
		case "Reaper":
		{
			::Message(GREEN+"Player "+plr+" used Reaper");
			::MessagePlayer(RED+"Spam the arrows to control the missiles!",plr);
			if(REAPEREnter(plr) == false)
			{
				SendDataToClient(plr,StreamData.Killstreak,GetKillstreakName(10));
				PLAYERS[plr.ID].AddKillstreak(10);
			}
			break;
		}
		case "Airstrike":
		{
			::Message(GREEN+"Player "+plr+" used Airstrike");
			::FindObject(PLANEID).Pos = ::LOADEDMAP.AirDropPlanePoint1;
			::FindObject(PLANEID).RotateToEuler(Vector(0.0,0.0,::LOADEDMAP.AirDropAngle),0);
			::FindObject(PLANEID).MoveTo(::LOADEDMAP.AirDropPlanePoint2,10000);
			::KillAllZombies();
			::CreateExplosion(ZOMBIE_WORLD,2,LOADEDMAP.spawn1,-1,false);
			::CreateExplosion(ZOMBIE_WORLD,2,LOADEDMAP.spawn2,-1,false);
			::CreateExplosion(ZOMBIE_WORLD,2,LOADEDMAP.spawn3,-1,false);
			break;
		}
		case "Nuke":
		{
			::Message(GREEN+"Player "+plr+" used Nuke");
			ZOMBIE_NUKE_TIMER = 11;
			break;
		}
		case "Osprey Gunner":
		{
			::Message(GREEN+"Player "+plr+" used Osprey Gunner");
			if(AddInOSPREY(plr) == false)
			{
				SendDataToClient(plr,StreamData.Killstreak,GetKillstreakName(12));
				PLAYERS[plr.ID].AddKillstreak(12);
			}
			break;
		}
		default: break;
	}
	SendDataToAllClient(StreamData.AnnounceKillstreak,plr.Name+" "+GetKillstreakID(killstreak));
	PlaySoundAllPlayers(50004);
}
function GetKillstreakName(id)
{
	switch(id)
	{
		case -1: return "Destroyed Chopper Gunner";
		case 0: return "Power";
		case 1: return "UAV Radar";
		case 2: return "Predator Missile";
		case 3: return "Insta Heal";
		case 4: return "Care Package";
		case 5: return "Armour Airdrop Package";
		case 6: return "Ammo Package";
		case 7: return "Chopper Gunner";
		case 8: return "Emergency AirDrop";
		case 9: return "Reaper";
		case 10: return "Airstrike";
		case 11: return "Nuke";
		case 12: return "Osprey Gunner";
	}
}
function GetKillstreakID(name)
{
	switch(name)
	{
		case "Power": return 0;
		case "UAV Radar": return 1;
		case "Predator Missile": return 2;
		case "Insta Heal" : return 3;
		case "Care Package": return 4;
		case "Armour Airdrop Package": return 5;
		case "Ammo Package": return  6;
		case "Chopper Gunner": return 7;
		case "Emergency AirDrop": return 8;
		case "Reaper": return 9;
		case "Airstrike": return 10;
		case "Nuke": return 11;
		case "Osprey Gunner" : return 12;
	}
}
function RandomKillstreakReward(player)
{
	local oldScore = player.Score, gen = rand () % 13, newScore = 0;
	switch(gen)
	{
		case 0:
		{
			newScore = 10; break;
		}
		case 1:
		{
			newScore = 50; break;
		}
		case 2:
		{
			newScore = 50; break;
		}
		case 3:
		{
			newScore = 75; break;
		}
		case 4:
		{
			newScore = 100; break;
		}
		case 5:
		{
			newScore = 150; break;
		}
		case 6:
		{
			newScore = 200; break;
		}
		case 7:
		{
			newScore = 250; break;
		}
		case 8:
		{
			newScore = 300; break;
		}
		case 9:
		{
			newScore = 400; break;
		}
		case 10:
		{
			newScore = 500; break;
		}
		case 10:
		{
		newScore = 600; break;
		}
		case 11:
		{
			newScore = 25; break;
		}
		case 12:
		{
			newScore = 350; break;
		}
		default: 
		{
			newScore = 10; break;
		}
	}
	player.Score = newScore;
	GetKillStreakReward(player);
	player.Score = oldScore;
}