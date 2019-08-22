::SHOP_WND <- null;
::SHOP_IMG <- null;
::SHOP_B1 <- null;
::SHOP_B2 <- null;
::SHOP_B3 <- null;
::SHOP_L1 <- null;
::SHOP_L2 <- null;

::PerksA <- array(8,-1);
::PERK_1 <- GUISprite();
::PERK_2 <- GUISprite();
::PERK_3 <- GUISprite();
::PERK_4 <- GUISprite();
::PERK_5 <- GUISprite();
::PERK_6 <- GUISprite();
::PERK_7 <- GUISprite();
::PERK_8 <- GUISprite();
::itemname <- "Random Weapon";
::itemprice <- 1000;
::itemID <- 0;

::sX <- GUI.GetScreenSize().X;
::sY <- GUI.GetScreenSize().Y;

::UP_KEY <- KeyBind(0x26);
::DOWN_KEY <- KeyBind(0x28);
::LEFT_KEY <- KeyBind(0x25);
::RIGHT_KEY <- KeyBind(0x27);

::K_KEY <- KeyBind(0x4B);

::SPACE_KEY <- KeyBind(0x20);

::HITMARKER <- GUISprite("Hitmarker.png",VectorScreen((::sX * 0.53) - 16,(::sY * 0.4) - 16));
::HITMARKER.Size = VectorScreen(32,32);
::HITMARKER.Alpha = 0;

::KILLSTREAK_CENTER_S <- GUISprite("Killstreak_none.png",VectorScreen((::sX * 0.5) - 32,(::sY * 0.5) - 32));
::KILLSTREAK_CENTER_S.Size = VectorScreen(64,64);
::KILLSTREAK_CENTER_S.Alpha = 0;

::KILLSTREAK_CENTER_T <- GUILabel(VectorScreen((::sX * 0.5) - 32,(::sY * 0.5) + 32),Colour(0,0,0),"Nothing");
::KILLSTREAK_CENTER_T.FontSize = 20;
::KILLSTREAK_CENTER_T.Alpha = 0;
::KILLSTREAK_CENTER_T.TextAlignment = GUI_ALIGN_LEFT;

::KILLSTREAK_ICON <- GUISprite("Killstreak_none.png",VectorScreen(::sX * 0.85,sY * 0.85));
::KILLSTREAK_ICON.Size = VectorScreen(64,64);
::KILLSTREAK_ICON.Alpha = 0;
::KILLSTREAK_ICON_T <- GUILabel(VectorScreen(::sX * 0.85,(::sY * 0.85) + 65),Colour(0,0,0),"Nothing");
::KILLSTREAK_ICON_T.FontSize = 20;
::KILLSTREAK_ICON_T.Alpha = 0;
::KILLSTREAK_ICON_T.TextAlignment = GUI_ALIGN_LEFT;

::CurrentKillStreakSprite <- "Killstreak_none.png";
::CurrentKillStreak <- "None";
::KillStreaksA <- array(20,-1);

::AnnounceKillstreak_TextPlayer <- GUILabel(VectorScreen(::sX *0.75,sY*0.5),Colour(255,0,0),"Athanatos");
::AnnounceKillstreak_TextPlayer.FontSize = 25;
::AnnounceKillstreak_TextPlayer.Alpha = 0;
::AnnounceKillstreak_TextPlayer.TextAlignment = GUI_ALIGN_LEFT;
::AnnounceKillstreak_TextStatus <- GUILabel(VectorScreen(::sX *0.75,sY*0.5 + 25),Colour(255,255,255),"Armour Airdrop Package");
::AnnounceKillstreak_TextStatus.FontSize = 25;
::AnnounceKillstreak_TextStatus.Alpha = 0;
::AnnounceKillstreak_TextStatus.TextAlignment = GUI_ALIGN_LEFT;

::NukeIcon <- GUISprite("Nuke.png",VectorScreen(sX*0.9,sY*0.25));
::NukeIcon.Size = VectorScreen(128,128);
::NukeIcon.Alpha = 0;

::Osprey_Camera <- GUISprite("Osprey_Camera.png",VectorScreen(0,0));
::Osprey_Camera.Size = VectorScreen(sX,sY);
::Osprey_Camera.Alpha = 0;

::REVIVE_KEY <- KeyBind(0x52);
enum Perks
{
	None = -1,
	Jugg = 1,
	QuickRevive = 2,
	Immunity = 3,
	InstaKill = 4,
	DoubleScore = 5,
	Freeze = 6,
	Damage = 7,
	FastHealthRegen = 8,
}
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
	AnnounceKillstreak = 12,
	OspreyStopCamera = 13,
	Spectate = 14
}

function GetPerkImage(perk)
{
	switch(perk)
	{
		case Perks.None: return null;
		case Perks.Jugg: return "jugg.png"
		case Perks.QuickRevive: return "quick_revive.png"
		case Perks.Immunity: return "immunity.png"
		case Perks.InstaKill: return "instakill.png"
		case Perks.DoubleScore: return "double_score.png"
		case Perks.Freeze: return "freeze.png"
		case Perks.Damage: return "damage_perk.png"
		case Perks.FastHealthRegen: return "FastHealthRegen.png"
		default: return null;
	}
}


function Script::ScriptLoad()
{
}

function Script::ScriptProcess()
{
	local dec = ::HITMARKER.Alpha 
	if(dec > 0) dec -= 3;
	if(dec < 0) dec = 0;
	::HITMARKER.Alpha = dec;
	
	local dec2 = ::AnnounceKillstreak_TextPlayer.Alpha;
	if(dec2 > 0 ) dec2 -= 0.25;
	::AnnounceKillstreak_TextPlayer.Alpha = dec2;
	::AnnounceKillstreak_TextStatus.Alpha = dec2;
	
	local dec3 = ::KILLSTREAK_CENTER_S.Alpha;
	if(dec3 > 0) dec3 -= 0.5;
	if(dec3 < 0) dec3 = 0;
	::KILLSTREAK_CENTER_S.Alpha = dec3;
	::KILLSTREAK_CENTER_T.Alpha = dec3;
}

function Player::PlayerShoot( player, weapon, hitEntity, hitPosition )
{
}

function Server::ServerData( stream )
{
	local int = stream.ReadInt();
	local string = stream.ReadString();
	switch(int)
	{
		case StreamData.Initialise:
		{
			break;
		}
		case StreamData.WeaponShop :
		{
			GUI.SetMouseEnabled(true);
			::SHOP_WND = GUIWindow(VectorScreen(sX / 2, sY / 2),VectorScreen(250,250),Colour(255,255,255),"Shop");
			::SHOP_IMG = GUISprite( "gun_shop.png", VectorScreen( 10, 10));
			::SHOP_IMG.Size = VectorScreen(60,60);
			::SHOP_B1 = GUIButton(VectorScreen(10,70),VectorScreen(30,20),Colour(0,255,0),"<");
			::SHOP_B2 = GUIButton(VectorScreen(40,70),VectorScreen(30,20),Colour(0,255,0),">");
			::SHOP_B3 = GUIButton(VectorScreen(10,110),VectorScreen(60,20),Colour(0,255,0),"Buy");
			::SHOP_L1 = GUILabel(VectorScreen(70,10),Colour(0,0,0),itemname);
			::SHOP_L2 = GUILabel(VectorScreen(70,30),Colour(0,0,0),"Cost: $"+itemprice);
			::SHOP_WND.AddChild(SHOP_IMG);
			::SHOP_WND.AddChild(SHOP_B1);
			::SHOP_WND.AddChild(SHOP_B2);
			::SHOP_WND.AddChild(SHOP_B3);
			::SHOP_WND.AddChild(SHOP_L1);
			::SHOP_WND.AddChild(SHOP_L2);
			Shop_Event();
			break;
		}
		case StreamData.GivePerk :
		{
			local gperk = string.tointeger();
			if(gperk <= 0) return;
			for(local i =0; i < 8;i++)
			{
				if(::PerksA[i] == gperk) return;
			}
			for(local i =0; i < 8;i++)
			{
				if(::PerksA[i] == -1)
				{
					if(gperk == ::PerksA[i]) break;
					else
					{
						::PerksA[i] = gperk;
						break;
					}
				}
			}
			ShowPerks();
			break;
		}
		case StreamData.ResetPlayer :
		{
			for(local i =0 ; i < 8; i++)
			{
				::PerksA[i] = -1;
			}
			ShowPerks();
			break;
		}
		case StreamData.RemovePerk:
		{
			for(local i =0 ; i < 8; i++)
			{
				local gperk = string.tointeger();
				if(::PerksA[i] == gperk) 
				{
					::PerksA[i] = -1;
					break;
				}
			}
			ShowPerks();
			break;
		}
		case StreamData.Hit:
		{
			::HITMARKER.Alpha = 255;
			break;
		}
		case StreamData.Killstreak:
		{
			for(local i =0 ; i < 20; i++)
			{
				if(::KillStreaksA[i] == -1)
				{
					::KillStreaksA[i] = GetKillstreakID(string);
					::CurrentKillStreak = string;
					SetKillStreakIcon(GetKillstreakID(string));
					::KILLSTREAK_ICON_T.Text = string;
					::KILLSTREAK_CENTER_S.Alpha = 255;
					::KILLSTREAK_CENTER_T.Text = string
					::KILLSTREAK_CENTER_T.Alpha = 255;
					::KILLSTREAK_ICON.Alpha = 255;
					::KILLSTREAK_ICON_T.Alpha = 255;
					break;
				}
			}
			break;
		}
		case StreamData.AnnounceKillstreak:
		{
			::AnnounceKillstreak_TextStatus.Text = GetKillstreakName(GetTok(string," ",2).tointeger()) ;
			::AnnounceKillstreak_TextStatus.Alpha = 255;
			::AnnounceKillstreak_TextPlayer.Text = GetTok(string," ",1);
			::AnnounceKillstreak_TextPlayer.Alpha = 255;
			break;
		}
		case StreamData.OspreyStopCamera:
		{
			::Osprey_Camera.Alpha = 0;
			Hud.AddFlags(HUD_FLAG_CASH | HUD_FLAG_CLOCK | HUD_FLAG_HEALTH | HUD_FLAG_WEAPON | HUD_FLAG_WANTED | HUD_FLAG_RADAR )
			break;
		}
		default:
		{
			Console.Print(int+"");
			break;
		}
	}
}
function GetKillstreakName(id)
{
	switch(id)
	{
		case -2: return "Destroyed Osprey Gunner";
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
function SetKillStreakIcon(id)
{
	::KILLSTREAK_ICON.SetTexture(GetKillstreakImage(id));
	::KILLSTREAK_CENTER_S.SetTexture(GetKillstreakImage(id));
}
function GetKillstreakImage(id)
{
	switch(id)
	{
		case 0 : return "Killstreak_power.png";
		case 1 : return "Killstreak_UAV.png";
		case 2 : return "Killstreak_Hellfire.png";
		case 3 : return "Killstreak_Instaheal.png";
		case 4 : return "Killstreak_CarePackage.png";
		case 5 : return "Killstreak_ArmourPackage.png";
		case 6 : return "Killstreak_AmmoPackage.png";
		case 7 : return "Killstreak_HunterChopper.png";
		case 8 : return "Killstreak_AirDrop.png";
		case 9 : return "Killstreak_Reaper.png";
		case 10 : return "Killstreak_Airstrike.png";
		case 11 : return "Killstreak_Nuke.png";
		case 12 : return "Killstreak_OspreyGunner.png"
		default: return "Killstreak_none.png";
	}
}
function ShowPerks()
{
	local i = 0;
	for(i = 0 ; i < 8;i++)
	{
		if(::PerksA[i] != -1)
		{
			switch(i)
			{
				case 0:
				{
					::PERK_1 = GUISprite(GetPerkImage(::PerksA[i]),VectorScreen((::sX* 0.5) + (40 * i) , ::sY * 0.70));
					::PERK_1.Size = VectorScreen(30,30);
					::PERK_1.SendToBottom();
					break;
				}
				case 1:
				{
					::PERK_2 = GUISprite(GetPerkImage(::PerksA[i]),VectorScreen((::sX* 0.5) + (40 * i) , ::sY * 0.70));
					::PERK_2.Size = VectorScreen(30,30);
					::PERK_2.SendToBottom();
					break;
				}
				case 2:
				{
					::PERK_3 = GUISprite(GetPerkImage(::PerksA[i]),VectorScreen((::sX* 0.5) + (40 * i) , ::sY * 0.70));
					::PERK_3.Size = VectorScreen(30,30);
					::PERK_3.SendToBottom();
					break;
				}
				case 3:
				{
					::PERK_4 = GUISprite(GetPerkImage(::PerksA[i]),VectorScreen((::sX* 0.5) + (40 * i) , ::sY * 0.70));
					::PERK_4.Size = VectorScreen(30,30);
					::PERK_4.SendToBottom();
					break;
				}
				case 4:
				{
					::PERK_5 = GUISprite(GetPerkImage(::PerksA[i]),VectorScreen((::sX* 0.5) + (40 * i) , ::sY * 0.70));
					::PERK_5.Size = VectorScreen(30,30);
					::PERK_5.SendToBottom();
					break;
				}
				case 5:
				{
					::PERK_6 = GUISprite(GetPerkImage(::PerksA[i]),VectorScreen((::sX* 0.5) + (40 * i) , ::sY * 0.70));
					::PERK_6.Size = VectorScreen(30,30);
					::PERK_6.SendToBottom();
					break;
				}
				case 6:
				{
					::PERK_7 = GUISprite(GetPerkImage(::PerksA[i]),VectorScreen((::sX* 0.5) + (40 * i) , ::sY * 0.70));
					::PERK_7.Size = VectorScreen(30,30);
					::PERK_7.SendToBottom();
					break;
				}
				case 7:
				{
					::PERK_8 = GUISprite(GetPerkImage(::PerksA[i]),VectorScreen((::sX* 0.5) + (40 * i) , ::sY * 0.70));
					::PERK_8.Size = VectorScreen(30,30);
					::PERK_8.SendToBottom();
					break;
				}
				default:
				{
					::PERK_1 = GUISprite(GetPerkImage(::PerksA[i]),VectorScreen((::sX* 0.5) + (40 * i) , ::sY * 0.70));
					::PERK_1.Size = VectorScreen(30,30);
					Console.Print("[DEBUG]Reached Unknown perk sprite instance.");
					break;
				}
			}	
		}
		if(::PerksA[i] == -1)
		{
			switch(i)
			{
				case 0:
				{
					::PERK_1 = null;
					break;
				}
				case 1:
				{
					::PERK_2 = null;
					break;
				}
				case 2:
				{
					::PERK_3 = null
					break;
				}
				case 3:
				{
					::PERK_4 = null;
					break;
				}
				case 4:
				{
					::PERK_5 = null;
					break;
				}
				case 5:
				{
					::PERK_6 = null;
					break;
				}
				case 6:
				{
					::PERK_7 = null;
					break;
				}
				case 7:
				{
					::PERK_8 = null;
					break;
				}
				default:
				{
					::PERK_1 = null;
					Console.Print("[DEBUG]Perk unknown deleted "+i);
					break;
				}
			}
		}			
	}
}
function Shop_Event()
{
	GetItem();
	::SHOP_IMG.SetTexture(GetItemImage());
	::SHOP_L2.Text = "Cost: $"+::itemprice;
	::SHOP_L1.Text = ::itemname;
}
function GetItemImage()
{
	switch(itemID)
	{
		case 0: return "gun_shop.png";
		case 1: return GetPerkImage(Perks.Jugg);
		case 2: return GetPerkImage(Perks.QuickRevive);
		case 3: return GetPerkImage(Perks.FastHealthRegen);
		case 4: return GetPerkImage(Perks.Damage);
		case 5: return "gun_upgrade.png";
		case 6: return "gun_ammo.png";
		case 7: return "killstreak.png";
		case 8: return "lottery.png";
		default: return "time_perk.png";
	}
}
function GetItem()
{
	switch(::itemID)
	{
		case 0:
		{
			::itemname = "Random Weapon";
			::itemprice = 1000;
			break;
		}
		case 1:
		{
			::itemname = "Juggernaut";
			::itemprice = 2500;
			break;
		}
		case 2:
		{
			::itemname = "Quick Revive";
			::itemprice = 5000;
			break;
		}
		case 3:
		{
			::itemname = "Fast Health Regeneration";
			::itemprice = 7500;
			break;
		}
		case 4:
		{
			::itemname = "Extra Damage";
			::itemprice = 10000;
			break;
		}
		case 5:
		{
			::itemname = "Weapon Upgrade";
			::itemprice = 10000;
			break;
		}
		case 6:
		{
			::itemname = "Ammo";
			::itemprice = 4000;
			break;
		}
		case 7:
		{
			::itemname = "Random Killstreak";
			::itemprice = 20000;
			break;
		}
		case 8:
		{
			::itemname = "Lottery";
			::itemprice = 3000;
			break;
		}
		default:
		{
			if(::itemID < 0) ::itemID = 8;
			if(::itemID > 8) ::itemID = 0;
			GetItem();
		}
	}
	return;
}
function onGameResize( width, height )
{
}

function GUI::GameResize( width, height )
{
}

function GUI::ElementClick( element, mouseX, mouseY )
{
	if(element == SHOP_B1)
	{
		::itemID +=1;
		Shop_Event();
	}
	if(element == SHOP_B2)
	{
		::itemID -= 1;
		Shop_Event();
	}
	if(element == SHOP_B3)
	{
		SendDataToServer(StreamData.WeaponShop,::itemID+" "+itemprice);
	}
}

function GUI::ElementRelease( element, mouseX, mouseY )
{
}

function GUI::ElementBlur( element )
{
}

function GUI::CheckboxToggle( checkbox, checked )
{
}

function GUI::InputReturn( editbox )
{
}

function KeyBind::OnUp(key)
{
}

function KeyBind::OnDown(key)
{
	if(key == ::REVIVE_KEY)
	{
		SendDataToServer(StreamData.Revive,null);
	}
	if(key == ::UP_KEY)
	{
		SendDataToServer(StreamData.ButtonUp,null);
	}
	if(key == ::DOWN_KEY)
	{
		SendDataToServer(StreamData.ButtonDown,null);
	}
	if(key == ::LEFT_KEY)
	{
		SendDataToServer(StreamData.ButtonLeft,null);
	}
	if(key == ::RIGHT_KEY)
	{
		SendDataToServer(StreamData.ButtonRight,null);
	}
	if(key == ::K_KEY)
	{
		SendDataToServer(StreamData.Killstreak,null);
		if(CurrentKillStreak == "Osprey Gunner")
		{
			Hud.RemoveFlags(HUD_FLAG_CASH | HUD_FLAG_CLOCK | HUD_FLAG_HEALTH | HUD_FLAG_WEAPON | HUD_FLAG_WANTED | HUD_FLAG_RADAR )
			::Osprey_Camera.Alpha = 255;
		}
		for(local i = 19; i >= 0; i--)
		{
			if(KillStreaksA[i] != -1)
			{
				KillStreaksA[i] = -1;
				if( i == 0)
				{
					::KILLSTREAK_ICON.Alpha = 0;
					::KILLSTREAK_ICON_T.Alpha = 0;
					break;
				}
				::KILLSTREAK_ICON.SetTexture(GetKillstreakImage(KillStreaksA[i-1]));
				::KILLSTREAK_ICON_T.Text = GetKillstreakName(KillStreaksA[i-1]);
				break;
			}
		}
	}
	if(key == ::SPACE_KEY)
	{
		SendDataToServer(StreamData.Spectate);
	}
}
function GUI::WindowClose(window)
{
	GUI.SetMouseEnabled(false);
}
function SendDataToServer(int,string)
{
	local msg = Stream();
	msg.WriteInt(int);
	if(string != null) msg.WriteString(string)
	Server.SendData(msg);
}

function GetTok(string, separator, n, ...)
{
	local m = vargv.len() > 0 ? vargv[0] : n,
	tokenized = split(string, separator),
	text = "";
	if (n > tokenized.len() || n < 1) return null;
	for (; n <= m; n++)
	{
		text += text == "" ? tokenized[n-1] : separator + tokenized[n-1];
	}
	return text;
}