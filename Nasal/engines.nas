#
#
# Engine support
#
# Project Tupolev for FlightGear
#
# Yurik V. Nikiforoff, yurik@megasignal.com
# Novosibirsk, Russia
# aug 2008
#

# engine support

var ENGINE_UPDATE_PERIOD = 0.5;
var starter_rpm_1 = 0.0;
var starter_rpm_2 = 0.0;
var starter_rpm_3 = 0.0;

var start_engine = func{
	var engine_prop = -1;
	# Is start subsystem  serviceable?
	if( getprop("tu154/switches/startpanel-start" ) != 1.0 ) return;
	if( getprop("tu154/lamps/pump-1") != 1.0 ) return;
	if( getprop("tu154/lamps/pump-2") != 1.0 ) return;
	if( getprop("tu154/lamps/pump-3") != 1.0 ) return;
	if( getprop("tu154/lamps/pump-4") != 1.0 ) return;
	if( getprop("tu154/lamps/auto-consumption-failure") == 1.0 ) return;
	if( getprop( "tu154/systems/APU/APU-ready" ) == 0 ) return;
	if( getprop( "tu154/systems/APU/APU-bleed" ) != 5.0 ) return;	# need bleed
	
	# which engine we want start?
	if( getprop("tu154/switches/startpanel-selector-1" ) == 1.0 )
		engine_prop = "controls/engines/engine[0]/starter";
	if( getprop("tu154/switches/startpanel-selector-2" ) == 1.0 )
		engine_prop = "controls/engines/engine[1]/starter";
	if( getprop("tu154/switches/startpanel-selector-3" ) == 1.0 )
		engine_prop = "controls/engines/engine[2]/starter";
	if( engine_prop == -1 ) return;	# engine not selected
	
#let's start selected engine
	setprop(engine_prop, 1);
}


var break_start = func{
# which engine we start now?
	var engine_prop = -1;
	if( getprop("tu154/switches/startpanel-selector-1" ) == 1.0 )
		{
		engine_prop = "controls/engines/engine[0]/starter";
		var engine_cutoff = "controls/engines/engine[0]/cutoff";
		}
	if( getprop("tu154/switches/startpanel-selector-2" ) == 1.0 )
		{
		engine_prop = "controls/engines/engine[1]/starter";
		var engine_cutoff = "controls/engines/engine[1]/cutoff";
		}
	if( getprop("tu154/switches/startpanel-selector-3" ) == 1.0 )
		{
		engine_prop = "controls/engines/engine[2]/starter";
		var engine_cutoff = "controls/engines/engine[2]/cutoff";
		}
	if( engine_prop == -1 ) return;	# engine not selected
	
#break start procedure of selected engine
	setprop(engine_prop, 0);
	setprop(engine_cutoff, 1);
}

var start_apu = func{
# Is start subsystem  serviceable?

if( getprop( "tu154/switches/APU-starter-selector" ) != 1.0 ) return;
if( getprop("tu154/systems/electrical/indicators/apu-ready-to-start") != 1.0 ) return;
#let's start selected engine
	setprop("controls/engines/engine[3]/starter", 1);
	setprop("tu154/systems/electrical/indicators/apu-start", 1.0 );
}

var stop_apu = func{
	setprop("controls/engines/engine[3]/starter", 0);
	setprop("controls/engines/engine[3]/cutoff", 1);
}


var eng_1_handler = func{
settimer( eng_1_handler, ENGINE_UPDATE_PERIOD );

if( getprop( "engines/engine[0]/egt-degf" ) == nil ) return;		
if( getprop( "controls/engines/engine[0]/cutoff" ) == nil ) return;
if( getprop( "engines/engine[0]/n2" ) == nil ) return;
var pwr = getprop("tu154/systems/electrical/buses/DC27-bus-L/volts");
if( pwr == nil ) return;
# check 27V and blank lamps and exit if power off 
if(  pwr < 13.0 ) { check_lamps_eng(); return; }

# EGT delivery to fdm property tree
setprop( "fdm/jsbsim/propulsion/engine[0]/egt-degc", 
		getprop( "engines/engine[0]/egt-degf" ) * 0.55 - 17 );


if( getprop( "tu154/switches/startpanel-cold" ) == nil ) return;

if( getprop( "controls/engines/engine[0]/cutoff" ) == 1 )
 if( getprop( "engines/engine[0]/n2" ) > 20.0 )
      if( getprop( "tu154/switches/startpanel-cold" ) == 1 )
 	 if( getprop( "engines/engine[0]/starter" ) == 1 )
 		setprop( "controls/engines/engine[0]/cutoff",0 );
# indicator support
 if( getprop( "engines/engine[0]/oil-pressure-psi" ) < 20 )
 	setprop("tu154/systems/electrical/indicators/engine-1/p-oil", 1.0 );
 else setprop("tu154/systems/electrical/indicators/engine-1/p-oil", 0.0 );	

 if( getprop( "engines/engine[0]/n2" ) < 40 )
 	setprop("tu154/systems/electrical/indicators/engine-failure-1", 1.0 );
 else setprop("tu154/systems/electrical/indicators/engine-failure-1", 0.0 );	
 
 if( getprop( "controls/engines/engine[0]/throttle" ) > 0.8 )
 	setprop("tu154/systems/electrical/indicators/throttle-levers-unlocked", 1.0 );
 else setprop("tu154/systems/electrical/indicators/throttle-levers-unlocked", 0.0 );	

 if( getprop( "engines/engine[0]/n2" ) > 48.5 )
		 starter_rpm_1 = getprop( "engines/engine[0]/starter" );
 else starter_rpm_1 = 0.0;
 
 setprop("tu154/lamps/hi-starter-rpm", starter_rpm_1 + starter_rpm_2 + starter_rpm_3 ); 


}

var eng_2_handler = func{
settimer( eng_2_handler, ENGINE_UPDATE_PERIOD );
if( getprop( "controls/engines/engine[1]/cutoff" ) == nil ) return;
if( getprop( "engines/engine[1]/n2" ) == nil ) return;
# EGT delivery to fdm property tree
setprop( "fdm/jsbsim/propulsion/engine[1]/egt-degc", 
		getprop( "engines/engine[1]/egt-degf" ) * 0.55 - 17 );

if( getprop( "tu154/switches/startpanel-cold" ) == nil ) return;
var pwr = getprop("tu154/systems/electrical/buses/DC27-bus-L/volts");
if( pwr == nil ) return;
if(  pwr < 13.0 ) return;

if( getprop( "controls/engines/engine[1]/cutoff" ) == 1 ) 
 if( getprop( "engines/engine[1]/n2" ) > 20.0 )
      if( getprop( "tu154/switches/startpanel-cold" ) == 1 )
 	 if( getprop( "engines/engine[1]/starter" ) == 1 )
 		setprop( "controls/engines/engine[1]/cutoff",0 );
# indicator support
 if( getprop( "engines/engine[1]/oil-pressure-psi" ) < 20 )
 	setprop("tu154/systems/electrical/indicators/engine-2/p-oil", 1.0 );
 else setprop("tu154/systems/electrical/indicators/engine-2/p-oil", 0.0 );	

 if( getprop( "engines/engine[1]/n2" ) < 40 )
 	setprop("tu154/systems/electrical/indicators/engine-failure-2", 1.0 );
 else setprop("tu154/systems/electrical/indicators/engine-failure-2", 0.0 );	

 if( getprop( "engines/engine[1]/n2" ) > 48.5 )
		 starter_rpm_2 = getprop( "engines/engine[1]/starter" );
 else starter_rpm_2 = 0.0;
 		
}

var eng_3_handler = func{
settimer( eng_3_handler, ENGINE_UPDATE_PERIOD );

if( getprop( "controls/engines/engine[2]/cutoff" ) == nil ) return;
if( getprop( "engines/engine[2]/n2" ) == nil ) return;
# EGT delivery to fdm property tree
setprop( "fdm/jsbsim/propulsion/engine[2]/egt-degc", 
		getprop( "engines/engine[2]/egt-degf" ) * 0.55 - 17 );

if( getprop( "tu154/switches/startpanel-cold" ) == nil ) return;
var pwr = getprop("tu154/systems/electrical/buses/DC27-bus-L/volts");
if( pwr == nil ) return;
if(  pwr < 13.0 ) return;

if( getprop( "controls/engines/engine[2]/cutoff" ) == 1 )
   if( getprop( "engines/engine[2]/n2" ) > 20.0 )
 	 if( getprop( "engines/engine[2]/starter" ) == 1 )
 		setprop( "controls/engines/engine[2]/cutoff",0 );
# indicator support
 if( getprop( "engines/engine[2]/oil-pressure-psi" ) < 20 )
 	setprop("tu154/systems/electrical/indicators/engine-3/p-oil", 1.0 );
 else setprop("tu154/systems/electrical/indicators/engine-3/p-oil", 0.0 );	

 if( getprop( "engines/engine[2]/n2" ) < 40 )
 	setprop("tu154/systems/electrical/indicators/engine-failure-3", 1.0 );
 else setprop("tu154/systems/electrical/indicators/engine-failure-3", 0.0 );	
 
 if( getprop( "engines/engine[2]/n2" ) > 48.5 )
		 starter_rpm_3 = getprop( "engines/engine[2]/starter" );
 else starter_rpm_3 = 0.0;

	
}

var apu_handler = func{
settimer( apu_handler, ENGINE_UPDATE_PERIOD );
var param = 0.0;
if( getprop( "controls/engines/engine[3]/cutoff" ) == nil ) return;
if( getprop( "engines/engine[3]/n2" ) == nil ) return;
var pwr = getprop("tu154/systems/electrical/buses/DC27-bus-L/volts");
if( pwr == nil ) return;
# stop APU if 27 V failure
if(  (pwr < 13.0) or (getprop( "tu154/switches/APU-starter-switch" ) != 1 ) ) 
	{
	setprop("tu154/systems/electrical/indicators/apu-ready", 0.0 );
	setprop("tu154/systems/electrical/indicators/apu-oil-pressure", 0.0 );
	setprop("tu154/systems/electrical/indicators/apu-fuel-pressure", 0.0 );
	setprop("tu154/systems/electrical/indicators/apu-start", 0.0 );	
	setprop("tu154/systems/electrical/indicators/apu-levers-open", 0.0 );	
	setprop("tu154/systems/electrical/indicators/apu-ready-to-start", 0.0 );
	setprop( "controls/engines/engine[3]/cutoff",1 );
	return;
	}

if( getprop( "controls/engines/engine[3]/cutoff" ) == 1 )
 if( getprop( "engines/engine[3]/n2" ) > 20.0 )
      if( getprop( "tu154/switches/APU-starter-selector" ) == 1 )
 	 if( getprop( "engines/engine[3]/starter" ) == 1 )
 		setprop( "controls/engines/engine[3]/cutoff",0 );
# indicator support
  if( getprop( "engines/engine[3]/oil-pressure-psi" ) < 20 )
  	setprop("tu154/systems/electrical/indicators/apu-oil-pressure", 1.0 );
  else setprop("tu154/systems/electrical/indicators/apu-oil-pressure", 0.0 );	

  param = 0.0;
    
  if( getprop( "tu154/systems/APU/APU-damper" ) > 0.95 )
  	setprop("tu154/systems/electrical/indicators/apu-levers-open", 1.0 );
  else setprop("tu154/systems/electrical/indicators/apu-levers-open", 0.0 );	
  if( getprop( "tu154/systems/electrical/indicators/apu-levers-open" ) == 1.0 )
  	param = param + 1;
   if( getprop( "tu154/systems/electrical/indicators/apu-fuel-pressure" ) == 1.0 )
  	param = param + 1; 
    if( getprop( "tu154/systems/APU/APU-bleed" ) < 4.8 )
  	param = param + 1;
 if( param == 3.0 ) 
	setprop("tu154/systems/electrical/indicators/apu-ready-to-start", 1.0 );
 else setprop("tu154/systems/electrical/indicators/apu-ready-to-start", 0.0 );
     
  if( getprop( "engines/engine[3]/n2" ) > 90.0 )
	{
  	setprop("tu154/systems/APU/APU-ready", 1.0 );
  	setprop("tu154/systems/electrical/indicators/apu-ready", 1.0 );
  	setprop("tu154/systems/electrical/indicators/apu-start", 0.0 );
	}
  else {
	setprop("tu154/systems/APU/APU-ready", 0.0 );
	setprop("tu154/systems/electrical/indicators/apu-ready", 0.0 );
	}

if( getprop( "engines/engine[3]/n2" ) > 90.0 and getprop( "tu154/systems/electrical/indicators/apu-fuel-pressure") < 0.2 ) stop_apu();

}

var check_lamps_eng = func{
	var pwr = getprop("tu154/systems/electrical/buses/DC27-bus-L/volts");
	if( pwr == nil ) return;
	var param = getprop( "tu154/systems/electrical/checking-lamps/engine-panel" );
	if( param == nil ) param = 0.0;
	if(  pwr < 13.0 ) param = 0.0;
	setprop("tu154/systems/electrical/indicators/autothrottle-on", param );
	setprop("tu154/systems/electrical/indicators/throttle-levers-unlocked", param );
        setprop("tu154/systems/electrical/indicators/engine-1/egt-danger", param );
        setprop("tu154/systems/electrical/indicators/engine-1/egt-stop", param );
        setprop("tu154/systems/electrical/indicators/engine-1/filter-clog", param );
        setprop("tu154/systems/electrical/indicators/engine-1/low-oil", param );
        setprop("tu154/systems/electrical/indicators/engine-1/metal-in-oil", param );
        setprop("tu154/systems/electrical/indicators/engine-1/overflow-oil", param );
        setprop("tu154/systems/electrical/indicators/engine-1/p-fuel", param );
        setprop("tu154/systems/electrical/indicators/engine-1/p-oil", param );
        setprop("tu154/systems/electrical/indicators/engine-1/revers-dampers", param );
        setprop("tu154/systems/electrical/indicators/engine-1/revers-lock", param );
        setprop("tu154/systems/electrical/indicators/engine-1/t-bearing-danger", param );
        setprop("tu154/systems/electrical/indicators/engine-1/vibration", param );
        setprop("tu154/systems/electrical/indicators/engine-2/egt-danger", param );
        setprop("tu154/systems/electrical/indicators/engine-2/egt-stop", param );
        setprop("tu154/systems/electrical/indicators/engine-2/filter-clog", param );
        setprop("tu154/systems/electrical/indicators/engine-2/low-oil", param );
        setprop("tu154/systems/electrical/indicators/engine-2/metal-in-oil", param );
        setprop("tu154/systems/electrical/indicators/engine-2/overflow-oil", param );
        setprop("tu154/systems/electrical/indicators/engine-2/p-fuel", param );
        setprop("tu154/systems/electrical/indicators/engine-2/p-oil", param );
        setprop("tu154/systems/electrical/indicators/engine-2/t-bearing-danger", param );
        setprop("tu154/systems/electrical/indicators/engine-2/vibration", param );       
        setprop("tu154/systems/electrical/indicators/engine-3/egt-danger", param );
        setprop("tu154/systems/electrical/indicators/engine-3/egt-stop", param );
        setprop("tu154/systems/electrical/indicators/engine-3/filter-clog", param );
        setprop("tu154/systems/electrical/indicators/engine-3/low-oil", param );
        setprop("tu154/systems/electrical/indicators/engine-3/metal-in-oil", param );
        setprop("tu154/systems/electrical/indicators/engine-3/overflow-oil", param );
        setprop("tu154/systems/electrical/indicators/engine-3/p-fuel", param );
        setprop("tu154/systems/electrical/indicators/engine-3/p-oil", param );
        setprop("tu154/systems/electrical/indicators/engine-3/revers-dampers", param );
        setprop("tu154/systems/electrical/indicators/engine-3/revers-lock", param );
        setprop("tu154/systems/electrical/indicators/engine-3/t-bearing-danger", param );
        setprop("tu154/systems/electrical/indicators/engine-3/vibration", param );  
}

eng_1_handler();
eng_2_handler();
eng_3_handler();
apu_handler();

print("Engines support started");
