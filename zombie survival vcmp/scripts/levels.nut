DIFFICULTY <- 1;
ZOMBIE_INTERMISSION <- 30;
LOADINGMAP <- false;
class Level
{
	constructor(cname,cpos,cdistance,s1,s2,s3)
	{
		name = cname;
		pos = cpos;
		distance = cdistance;
		spawn1 =s1;
		spawn2 =s2;
		spawn3 = s3;
	}
	name = "Empty Map";
	difficulty = 1;
	pos = null;
	distance = 0;
	
	spawn1 = null;
	spawn2 = null;
	spawn3 = null;
	
	AirDrop = null;
	AirDropPlanePoint1 = null;
	AirDropPlanePoint2 = null;
	AirDropAngle = 0;
	SpecialWeapon = 0;
}
function GetDifficultyStr(difficulty)
{
	if(difficulty == 1) return "Normal";
	if(difficulty == 2) return "Hard";
	if(difficulty == 3) return "Insane";
	if(difficulty == 4) return "Hardcore";
	if(difficulty == 5) return "VIRTUALLY IMPOSSIBLE";
}
function LoadMap()
{
	if(LOADINGMAP == true) return;
	
		ZOMBIE_INTERMISSION = 30;
		local mapSelect = rand() % 6;
		local difSelect =  1+rand() % 5;
		switch(mapSelect)
		{
			case 0:
			{
				LOADEDMAP = MAP_MANSION;
				LOADEDMAP.AirDropPlanePoint1 = Vector(-520.448, -519.213, 100);
				LOADEDMAP.AirDropPlanePoint2 = Vector(-190.222, -523.893, 100);
				LOADEDMAP.AirDrop = Vector(-376.491, -534.852, 17.2822);
				LOADEDMAP.AirDropAngle = 0
				break;
			}
			case 1:
			{
				LOADEDMAP = MAP_ICE;
				LOADEDMAP.AirDrop = Vector(-844.579, -570.227, 10.9275);
				LOADEDMAP.AirDropPlanePoint1 = Vector(-864.271, -417.264, 100);
				LOADEDMAP.AirDropPlanePoint2 = Vector(-837.06, -597.762, 100);
				LOADEDMAP.AirDropAngle = -2.96418
				break;
			}
			case 2:
			{
				LOADEDMAP = MAP_BANK;
				LOADEDMAP.AirDropPlanePoint1 = Vector(-858.566, -192.889, 100)
				LOADEDMAP.AirDropPlanePoint2 = Vector(-837.06, -597.762, 100);
				LOADEDMAP.AirDrop = Vector(-875.759, -341.003, 11.1034);
				LOADEDMAP.AirDropAngle = -2.96418
				break;
			}
			case 3:
			{
				LOADEDMAP = MAP_SUNSHINE;
				LOADEDMAP.AirDropPlanePoint1 = Vector(-1136.09, -717.701, 100);
				LOADEDMAP.AirDropPlanePoint2 = Vector(-921.441, -1047.1, 100);
				LOADEDMAP.AirDrop = Vector(-1028.7, -909.357, 13.8489);
				LOADEDMAP.AirDropAngle = 0.780329;
				break;
			}
			case 4:
			{
				LOADEDMAP = MAP_BRIDGE;
				LOADEDMAP.AirDropPlanePoint1 = Vector(-794.117, -922.004, 100);
				LOADEDMAP.AirDropPlanePoint2 = Vector(-121.202, -902.281, 100);
				LOADEDMAP.AirDrop = Vector(-477.854, -931.619, 26.2538);
				LOADEDMAP.AirDropAngle = 0
				break;
			}
			case 5:
			{
				LOADEDMAP = MAP_HOSPITAL;
				LOADEDMAP.AirDropPlanePoint1 = Vector(-864.271, -417.264, 100);
				LOADEDMAP.AirDropPlanePoint2 = Vector(-837.06, -597.762, 100);
				LOADEDMAP.AirDrop = Vector(-862.378, -475.016, 10.9289);
				LOADEDMAP.AirDropAngle = -2.96418
				break;
			}
			default: 
			{
				LoadMap();
				return;
			}
		}
	DIFFICULTY = difSelect;
	LOADINGMAP = true;
	Message(WHITE+"Loaded Map:"+LOADEDMAP.name+" Difficulty :"+GetDifficultyStr(DIFFICULTY));
}
///Maps:
MAP_MANSION <- Level("Mansion",Vector(-378.817, -587.702, 25.3209),50,Vector(-378.697, -597.882, 25.8263),Vector(-371.468, -515.602, 12.8085),Vector(-383.661, -516.205, 12.8039));
MAP_ICE <- Level("Ice Cream Factory",Vector(-882.274, -574.215, 15.0619),30,Vector(-853.546, -580.217, 11.103),Vector(-854.714, -557.391, 11.1036),Vector(-851.913, -568.214, 11.1028));
MAP_BANK <- Level("Bank",Vector(-916.622, -339.324, 13.3802),30,Vector(-879.508, -340.849, 11.1034),Vector(-885.067, -348.51, 11.1034),Vector(-883.977, -334.804, 11.1034));
MAP_SUNSHINE <- Level("Sunshine Autos",Vector(-1034.18, -847.141, 13.0852),70,Vector(-1039.5, -886.733, 13.6245),Vector(-1026.19, -906.372, 14.0892),Vector(-977.815, -882.934, 13.0613));
MAP_BRIDGE <- Level("Highway Brige",Vector(-477.854, -931.619, 26.2538),50,Vector(-438.14, -941.295, 25.7964),Vector(-432.096, -933.107, 25.4393),Vector(-547.16, -932.415, 24.3074));
MAP_HOSPITAL <- Level("Hospital",Vector(-885.34, -473.458, 13.1106),40,Vector(-864.748, -487.484, 11.1026),Vector(-869.502, -454.276, 11.1004),Vector(-866.848, -467.735, 11.1005));

CreateCheckpoint(null,0, true,Vector(-885.487, -458.286, 13.1107),ARGB(255,255,0,0),2) 
CreateCheckpoint(null,0, true,Vector(-373.24, -597.208, 25.8263),ARGB(255,255,0,0),2) 
CreateCheckpoint(null,0, true,Vector(-879.347, -575.733, 11.2621),ARGB(255,255,0,0),2) 
CreateCheckpoint(null,0, true,Vector(-475.327, -940.816, 26.448),ARGB(255,255,0,0),2) 
CreateCheckpoint(null,0, true,Vector(-902.485, -333.524, 13.3802),ARGB(255,255,0,0),2) 
CreateCheckpoint(null,0, true,Vector(-1033.42, -842.443, 13.0852),ARGB(255,255,0,0),2)