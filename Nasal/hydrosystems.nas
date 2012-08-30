#
#
# Hydro systems NASAL support
#
# Project Tupolev for FlightGear
#
# Yurik V. Nikiforoff, yurik@megasignal.com
# Novosibirsk, Russia
# may 2008
#

var UPDATE_PERIOD = 0.1;
var hs_handler = func{
settimer( hs_handler, UPDATE_PERIOD );

# Freese aero surfaces & over hydro system consumers if hydrosystems are empty
var param = getprop("fdm/jsbsim/hs/busters-serviceable");
if( param == nil ) param = 0;
if( param != 0 ) # if 0 - hydro power failure, surfaces are freese
    {  
    # copy current position of surfaces if hydro power OK
    param = getprop("fdm/jsbsim/fcs/pitch-absu-sum");
    if( param == nil ) param = 0;
    setprop("fdm/jsbsim/fcs/elevator-pos-static", param );
    param = getprop("fdm/jsbsim/fcs/roll-absu-sum");
    if( param == nil ) param = 0;
    setprop("fdm/jsbsim/fcs/aileron-pos-static", param );
    param = getprop("fdm/jsbsim/fcs/rudder-sum");
    if( param == nil ) param = 0;
    setprop("fdm/jsbsim/fcs/rudder-pos-static", param );
    }
#flaps
    param = getprop("fdm/jsbsim/hs/flaps-serviceable");
    if( param == nil ) param = 0;
    if( param != 0 )
	{
    param = getprop("fdm/jsbsim/fcs/flap-cmd-norm");
    if( param == nil ) param = 0;
    setprop("fdm/jsbsim/fcs/flap-cmd-static", param );
	}
#gear and spoilers
    param = getprop("fdm/jsbsim/hs/hs1-busters-ok");
    if( param == nil ) param = 0;
    if( param != 0 )
	{
    param = getprop("fdm/jsbsim/fcs/speedbrake-cmd");
    if( param == nil ) param = 0;
    setprop("fdm/jsbsim/fcs/speedbrake-cmd-static", param );
    param = getprop("fdm/jsbsim/gear/gear-cmd-norm");
    if( param == nil ) param = 0;
    setprop("fdm/jsbsim/gear/gear-cmd-static", param );
	}
# delivery info about direct 27V electrical power into FDM property tree
# for correct operating of electrical switch 
    param = getprop("tu154/systems/electrical/buses/DC27-bus-L/volts");
    if( param == nil ) param = 0.0;
    if( param > 13.0 ) setprop("fdm/jsbsim/systems/electrical-ok", 1.0 );
    else setprop("fdm/jsbsim/systems/electrical-ok", 0.0 );

    
}

hs_handler();

print("Hydro systems started");
