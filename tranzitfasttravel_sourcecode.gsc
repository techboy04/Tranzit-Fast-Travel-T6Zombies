#include maps\mp\_utility;
#include common_scripts\utility;
#include maps/mp/zombies/_zm;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;

init()
{
    level thread onPlayerConnect();
    create_dvar("fasttravel_price", 1500);
    create_dvar("fasttravel_activateonpower", 0);
	checkTransit();
}

onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread onPlayerSpawned();
    }
}

onPlayerSpawned()
{
    self endon("disconnect");
	level endon("game_ended");
    for(;;)
    {
        self waittill("spawned_player");
        
        if( getDvar( "g_gametype" ) == "zclassic" && level.scr_zm_map_start_location == "transit" )
        {
        	self iprintln("^4Tranzit Fast Travel ^7created by ^1techboy04gaming");
        }
    }
}

checkTransit()
{
	if( getDvar( "g_gametype" ) == "zclassic" && level.scr_zm_map_start_location == "transit" )
	{
		createTriggers();
		level.activatefasttravel = 0;
	}
}


createTravel(location, destination, angle, whereto)
{
	travelTrigger = spawn( "trigger_radius", (location), 1, 50, 50 );
	travelTrigger setHintString("^7Something needs to be activated...");
	travelTrigger setcursorhint( "HINT_NOICON" );
	travelModel = spawn( "script_model", (location));
	travelModel setmodel ("p6_zm_screecher_hole");
	travelModel rotateTo(angle,.1);
	level waittill ("fasttravel_on");
	playfx( level._effect[ "screecher_vortex" ], (location), anglestoforward( 0, 45, 55 ) );
	travelTrigger setHintString("^7Press ^3&&1 ^7to travel to ^3" + whereto + "^7 [Cost: " + getdvar("fasttravel_price") + "]");
	while(1)
	{
		travelTrigger waittill( "trigger", i );
		if (i.score >= getdvarInt("fasttravel_price"))
		{
		
			if (level.activatefasttravel == 1)
			{

				if ( i usebuttonpressed() )
				{
					i.score -= getdvarInt("fasttravel_price");
					i playsound( "zmb_weap_wall" );
					fadetowhite = newhudelem();
					fadetowhite.x = 0;
					fadetowhite.y = 0;
					fadetowhite.alpha = 0;
					fadetowhite.horzalign = "fullscreen";
					fadetowhite.vertalign = "fullscreen";
					fadetowhite.foreground = 1;
					fadetowhite setshader( "black", 640, 480 );
					fadetowhite fadeovertime( 0.2 );
					fadetowhite.alpha = 1;
					i.ignoreme = 1;
					i EnableInvulnerability();
					wait 2;
					
					i setorigin (destination);
					
					fadetowhite fadeovertime( 1 );
					fadetowhite.alpha = 0;
					
					wait 1.1;
					fadetowhite destroy();
					i.ignoreme = 0;
					i DisableInvulnerability();
				}
			}
		}
	}
}

createTriggers()
{
	//Bus Depot Triggers
	level thread createTravel((-7424.21,4201.22,-63.5),(-5143.78,-7402.17,-69),(0,77,0),"Diner"); //To Diner
	level thread createTravel((-6073.19,4519.49,-54.216),(1992.76,-437.126,-61.875),(0,160,0),"Town"); //To Town
	
	//Diner Triggers
	level thread createTravel((-4145.74,-7440.28,-63.875),(6929.9,-5716.29,-59),(0,133,0),"Farm"); //To Farm
	level thread createTravel((-6235.26,-7147.53,-62.744),(-6764.35,5460.54,-55.875),(0,53,0),"Bus Depot"); //To Bus Depot
	
	//Farm Triggers
	level thread createTravel((6821.2,-5470.26,-67),(10889.5,7554.89,-588),(0,164,0),"Power Station"); //To Power
	level thread createTravel((6770.84,-5973.64,-64),(-5143.78,-7402.17,-69),(0,141,0),"Diner"); //To Diner
	
	//Power Triggers
	level thread createTravel((10745.1,7790.9,-585.129),(1992.76,-437.126,-61.875),(0,-90,0),"Town"); //To Town
	level thread createTravel((11310.6,7792.6,-545),(6929.9,-5716.29,-59),(0,-164,0),"Farm"); //To Farm
	
	//Town Triggers
	level thread createTravel((686.931,-732.29,-55.875),(-6764.35,5460.54,-55.875),(0,90,0),"Bus Depot"); //To Bus Depot
	level thread createTravel((1897.9,846.475,-55.2886),(10889.5,7554.89,-588),(0,177,0),"Power"); //To Power
	
	if (getDvarInt("fasttravel_activateonpower") == 1)
	{
		level waittill ("power_on");
		level notify ("fasttravel_on");
		level.activatefasttravel = 1;
	}
	else
	{
		level thread spawnTravelActivator(993.641,258.615,-39.875);
	}
}

spawnTravelActivator(x,y,z)
{
	travelActivatorTrigger = spawn( "trigger_radius", ( x,y,z ), 1, 50, 50 );
	travelActivatorTrigger setHintString("^7The power must be activated first!");
	travelActivatorTrigger setcursorhint( "HINT_NOICON" );
	level waittill ("power_on");
	travelActivatorTrigger setHintString("^7Press ^3&&1 ^7to activate Fast Travel phones");
	while(1)
	{
		travelActivatorTrigger waittill( "trigger", i );
		if ( i usebuttonpressed() )
		{
			i playsound( "zmb_weap_wall" );
			level notify ("fasttravel_on");
			level.activatefasttravel = 1;
			travelActivatorTrigger delete();
			break;
		}
	}
}

create_dvar( dvar, set )
{
    if( getDvar( dvar ) == "" )
		setDvar( dvar, set );
}


