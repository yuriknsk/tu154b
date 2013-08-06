#
# ABSU-154 support
# Yurik V. Nikiforoff, yurik.nsk@gmail.com
# Novosibirsk, Russia
# 2007 - 2008,2010
#

var HEADING_DEVIATION_LIMIT = 20.0;
var GLIDESLOPE_DEVIATION_LIMIT = 10.0;
var GO_AROUND_PITCH_RAD = 0.2;
var PITCH_YOKE_LIMIT = 0.5;
var BANK_YOKE_LIMIT = 0.5;

var absu_property_update = func {
settimer( absu_property_update, 0 );

# pn-5 selected mode
#var az1 = getprop("tu154/instrumentation/pn-5/az-1");
#if( az1 == nil ) az1 = 0.0;
var az2 = getprop("tu154/instrumentation/pn-5/az-2");
if( az2 == nil ) az2 = 0.0;



# Heading ILS ABSU support
var LOCALIZER_CONST = 0.7;
var GLIDESLOPE_CONST = 0.7;

var param = num( getprop("instrumentation/nav[0]/heading-needle-deflection") );
if( param == nil ) param = 0.0;
setprop("fdm/jsbsim/ap/ils-epsilon", param * LOCALIZER_CONST );

# Glideslope ILS ABSU support
  param = num( getprop("instrumentation/nav[0]/gs-rate-of-climb") );
  if( param == nil ) param = 0.0;

  # with sanity check
  if( abs( param ) < 100 ) setprop("fdm/jsbsim/ap/input-glideslope-speed", param *
  GLIDESLOPE_CONST);

  param = num(getprop("instrumentation/nav[0]/gs-needle-deflection") );
  if( param == nil ) param = 0.0;
  if( abs( param ) < 100 ) setprop("fdm/jsbsim/ap/input-glideslope-delta", param *  GLIDESLOPE_CONST );


# VOR support
if( az2 )
        {
        var radial_actual = "instrumentation/nav[1]/radials/actual-deg";
        var radial_reciprocal = "instrumentation/nav[1]/radials/reciprocal-radial-deg";
        var radial_selected = "instrumentation/nav[1]/radials/selected-deg";
        var to_flag_prop = "instrumentation/nav[1]/to-flag";
        }
else	{
	var radial_actual = "instrumentation/nav[0]/radials/actual-deg";
	var radial_reciprocal = "instrumentation/nav[0]/radials/reciprocal-radial-deg";
	var radial_selected = "instrumentation/nav[0]/radials/selected-deg";
	var to_flag_prop = "instrumentation/nav[0]/to-flag";
	}
var to_flag = getprop( to_flag_prop );
if( to_flag == nil ) to_flag = 0.0;
if( to_flag ) param = getprop(radial_reciprocal);
else param = getprop(radial_actual);
if( param == nil ) param = 0.0;
var param2 = getprop(radial_selected);
if( param2 == nil ) param2 = 0.0;
param = param - param2;
if( param < -180.0 ) param = 360.0 + param;
if( param > 180.0 ) param = 360.0 - param;
if( to_flag ) param = -param;
setprop("fdm/jsbsim/ap/input-heading-delta", param);

#Delivery gyro heading to TKS compass system
param = getprop("orientation/heading-deg")+
	getprop("instrumentation/heading-indicator[0]/offset-deg");
if( param < 0.0 ) param = param + 360.0;
if( param > 360.0 ) param = param - 360.0;
setprop("fdm/jsbsim/ap/input-heading-gyro-1", param);

param = getprop("orientation/heading-deg")+
	getprop("instrumentation/heading-indicator[1]/offset-deg");
if( param < 0.0 ) param = param + 360.0;
if( param > 360.0 ) param = param - 360.0;
setprop("fdm/jsbsim/ap/input-heading-gyro-2", param);

#Delivery magnetic heading to TKS compass system

param = getprop("orientation/heading-magnetic-deg");
if( param == nil ) param = 0.0;
setprop("fdm/jsbsim/ap/input-magnetic-heading", param);

#Delivery brakes
param = getprop("controls/gear/brake-left");
if( param == nil ) param = 0.0;
setprop("fdm/jsbsim/gear/brake-left", param);
param = getprop("controls/gear/brake-right");
if( param == nil ) param = 0.0;
setprop("fdm/jsbsim/gear/brake-right", param);
param = getprop("controls/gear/brake-parking");
if( param == nil ) param = 0.0;
setprop("fdm/jsbsim/gear/brake-parking", param);
# delivery steering parameters
param = getprop("controls/gear/steering");
if( param == nil ) param = 0.0;
setprop("fdm/jsbsim/gear/steering", param);
param = getprop("controls/gear/nose-wheel-steering");
if( param == nil ) param = 0.0;
setprop("fdm/jsbsim/gear/nose-wheel-steering", param);


# PNP 


# "Plane" handle
var src_plane = "tu154/instrumentation/pnp[0]/plane-deg";
param = getprop("tu154/switches/pn-5-pnp-selector");
if( param == nil ) param = 0.0;
if( param ) src_plane = "tu154/instrumentation/pnp[1]/plane-deg";
param = getprop(src_plane);
if( param == nil ) param = 0.0;
setprop("fdm/jsbsim/ap/input-heading-pnp", param);

# ZK handle
param = getprop("tu154/switches/zk-selector");
if( param == nil ) param = 0.0;

if( param ) src_plane = "tu154/instrumentation/pnp[1]/heading-deg";
else src_plane = "tu154/instrumentation/pnp[0]/heading-deg";

param = getprop(src_plane);
if( param == nil ) param = 0.0;
setprop("fdm/jsbsim/ap/input-heading-zk", param);


var needles = getprop("tu154/switches/pn-5-strelki" );
if( needles == nil )  needles = 0.0; 
if( needles != 0.0 )
	{ 
	# Directors
	param = getprop("fdm/jsbsim/ap/pitch-error");
	if( param == nil )  param = 0.0;
	if( getprop("fdm/jsbsim/ap/pitch-selector") != 5.0 ) param = 0.0;
	setprop("tu154/instrumentation/pkp[0]/pitch-director", param );

	param = getprop("fdm/jsbsim/ap/roll-error");
	if( param == nil )  param = 0.0; 
	if( getprop("fdm/jsbsim/ap/roll-selector") != 5.0 ) param = 0.0;
	setprop("tu154/instrumentation/pkp[0]/roll-director", param );
	}
else{
	interpolate("tu154/instrumentation/pkp[0]/pitch-director", 0.3, 1.0 );
	interpolate("tu154/instrumentation/pkp[0]/roll-director", 0.3, 1.0 );
	}	


# Pitch auto trim
var K_AUTOTRIM = -0.001;#-0.01
var THRESHOLD_AUTOTRIM = 0.05;

if( getprop("fdm/jsbsim/ap/pitch-hold") == 1.0 )
    if( getprop("tu154/switches/long-control") == 1.0 )
	{
	var pitch_error = getprop("fdm/jsbsim/ap/pitch-hold-pid");
	if( pitch_error == nil ) pitch_error = 0.0;
	var pitch_trim = getprop("controls/flight/elevator-trim");
	if( pitch_trim == nil ) pitch_trim = 0.0;
	if( abs( pitch_error ) > THRESHOLD_AUTOTRIM )
	setprop("controls/flight/elevator-trim", pitch_trim + K_AUTOTRIM * pitch_error );
	}
	
# Glideslope auto switch
if( getprop("fdm/jsbsim/fcs/flap-pos-deg") > 40.0 )
   if( getprop("fdm/jsbsim/ap/roll-selector") == 5.0 )
    if( getprop("fdm/jsbsim/ap/pitch-selector") != 5.0 )
      if( getprop("instrumentation/nav[0]/gs-needle-deflection") < 0.2 )
       if( getprop("instrumentation/nav[0]/gs-needle-deflection") > 0.0 )
	absu_glideslope();
		
# Go around procedure
if( getprop("fdm/jsbsim/ap/pitch-selector") == 5.0 )
    if( getprop("fdm/jsbsim/fcs/throttle-cmd-norm[0]") > 0.9 )
    	if( !getprop("fdm/jsbsim/ap/go-around") )
    		absu_start_go_around();
    		

}


# ABSU control

var absu_stab_on = func {
if( absu_powered() == 0 ) return;

var kren = getprop("tu154/switches/pu-46-kren");
if( kren == nil ) kren = 0.0;
var tang = getprop("tu154/switches/pu-46-tang");
if( tang == nil ) tang = 0.0;

	if( kren != 0  ) 
	{
	setprop("tu154/instrumentation/pu-46/stab", 1.0 );
	absu_stab_roll();
	setprop("fdm/jsbsim/ap/roll-hold", 1.0 );
	}
	
	if( tang != 0  )
	{
	setprop("tu154/instrumentation/pu-46/stab", 1.0 );
	absu_stab_current_pitch();
	setprop("fdm/jsbsim/ap/pitch-hold", 1.0 );
	}

}

# Go to manual control
var absu_stab_off = func {
# Autopilot state
# Clear audio warning if stale interpolation
	setprop("tu154/systems/warning/alarm/absu_warn", 0.0 );
	var state = 0;
	if( getprop("fdm/jsbsim/ap/pitch-hold") ) state = 1;
	if( getprop("fdm/jsbsim/ap/roll-hold") ) state = state + 1;
	if( getprop("tu154/instrumentation/pu-46/stab") ) state = state + 1;
	if( getprop("tu154/instrumentation/pn-6/stab") ) state = state + 1;
	if( state ) absu_alarm();
	
	setprop("fdm/jsbsim/ap/roll-selector", 0.0 );
	setprop("fdm/jsbsim/ap/pitch-selector", 0.0 );
	setprop("fdm/jsbsim/ap/pitch-hold", 0.0 );
	setprop("fdm/jsbsim/ap/roll-hold", 0.0 );
# Blue lamp on PU-46
	setprop("tu154/instrumentation/pu-46/stab", 0.0 );
# stop go around 	
	setprop("fdm/jsbsim/ap/go-around", 0.0);
        clr_pitch_lamp();
        clr_heading_lamp();
	
	if( absu_powered() == 1 )
	{
# PN-5 indicators
	setprop( "tu154/instrumentation/pn-5/pitch-state", 1 );
	setprop( "tu154/instrumentation/pn-5/heading-state", 1 );
	setprop("tu154/instrumentation/pn-5/sbros", 1.0 );
	}
	else{
	setprop( "tu154/instrumentation/pn-5/pitch-state", 0 );
	setprop( "tu154/instrumentation/pn-5/heading-state", 0 );
	}
}

# switches on PN-5 
# for XML animation
var absu_stab_kren = func {

var state = getprop("tu154/instrumentation/pu-46/stab");
if ( state == nil ) return;
if ( arg[0] != 0 )	# start roll stabilizer
	{
	if( state != 0 ) 
		{
		absu_stab_roll();
		setprop("fdm/jsbsim/ap/roll-hold", 1.0 );
		}
	}

else	# stop roll stabilizer
	{
        setprop("tu154/systems/electrical/indicators/nvu", 0.0 );
        setprop("tu154/systems/electrical/indicators/vor", 0.0 );
        setprop("tu154/systems/electrical/indicators/zk", 0.0 );
        setprop("tu154/systems/electrical/indicators/heading", 0.0 );
        setprop("tu154/systems/electrical/indicators/stab-heading", 0.0 );
	setprop("fdm/jsbsim/ap/roll-hold", 0.0 );
	if( absu_powered() == 1 )
		{
		absu_alarm();
		setprop( "tu154/instrumentation/pn-5/heading-state", 1 );
		}
	if( getprop("tu154/switches/pu-46-tang") != 1.0 )
		 setprop("tu154/instrumentation/pu-46/stab", 0.0 ); 
	}
}


var absu_stab_tang = func {
var state = getprop("tu154/instrumentation/pu-46/stab");
if ( state == nil ) return;
if ( arg[0] != 0 )	# start pitch stabilizer
	{
	if( state != 0 ){ 
		absu_stab_current_pitch();
		setprop("fdm/jsbsim/ap/pitch-hold", 1.0 );
		}
	}

else	# stop pitch stabilizer
	{
#	interpolate("tu154/switches/pu-46-tang", 0.0, 0.1 );
#	interpolate("tu154/systems/electrical/indicators/stab-pitch", 0.0, 0.1 );
#        setprop("tu154/systems/electrical/indicators/glideslope", 0.0 );
#        setprop("tu154/systems/electrical/indicators/stab-pitch", 0.0 );
#        setprop("tu154/systems/electrical/indicators/stab-h", 0.0 );
#        setprop("tu154/systems/electrical/indicators/stab-v", 0.0 );
#        setprop("tu154/systems/electrical/indicators/stab-m", 0.0 );
	clr_pitch_lamp();
	setprop("fdm/jsbsim/ap/pitch-hold", 0.0 );
	if( absu_powered() == 1 )
		{
		absu_alarm();
		setprop( "tu154/instrumentation/pn-5/pitch-state", 1 );
		}
	if( getprop("tu154/switches/pu-46-kren") != 1.0 )
		 setprop("tu154/instrumentation/pu-46/stab", 0.0 );
	}
}

# Helpers


var absu_powered = func{
if( getprop("tu154/systems/absu/serviceable" ) == 1 ) return 1;
else return 0;
}

var absu_stab_current_pitch = func{
	var current_pitch = getprop("fdm/jsbsim/attitude/pitch-rad");
	if( current_pitch == nil ) current_pitch = 0.0; 
	setprop("fdm/jsbsim/ap/stab-input-pitch-rad", current_pitch );
	setprop("fdm/jsbsim/ap/pitch-selector", 1.0 ); # 1 - stabilize pitch
	setprop( "tu154/instrumentation/pn-5/pitch-state", 2 );
	setprop("tu154/systems/electrical/indicators/stab-pitch", 1.0 );
}

var absu_stab_roll = func{
	setprop("fdm/jsbsim/ap/stab-input-roll-rad", 0.0 ); # roll=0, stabilize wing level
	setprop("fdm/jsbsim/ap/roll-selector", 1.0 ); # 1 - stabilize roll
	setprop( "tu154/instrumentation/pn-5/heading-state", 2 );
	setprop("tu154/systems/electrical/indicators/stab-heading", 1.0 );
}

var clr_heading_lamp = func{
# PU-5
setprop("tu154/instrumentation/pn-5/sbros", 0.0 );
setprop("tu154/instrumentation/pn-5/zk", 0.0 );
setprop("tu154/instrumentation/pn-5/nvu", 0.0 );
setprop("tu154/instrumentation/pn-5/az-1", 0.0 );
setprop("tu154/instrumentation/pn-5/az-2", 0.0 );
setprop("tu154/instrumentation/pn-5/zahod", 0.0 );
# Indicators on captain panel
setprop("tu154/systems/electrical/indicators/nvu", 0.0 );
setprop("tu154/systems/electrical/indicators/vor", 0.0 );
setprop("tu154/systems/electrical/indicators/zk", 0.0 );
setprop("tu154/systems/electrical/indicators/heading", 0.0 );
setprop("tu154/systems/electrical/indicators/stab-heading", 0.0 );
}

var clr_pitch_lamp = func{
setprop("tu154/instrumentation/pu-46/m", 0.0 );
setprop("tu154/instrumentation/pu-46/v", 0.0 );
setprop("tu154/instrumentation/pu-46/h", 0.0 );
setprop("tu154/instrumentation/pn-5/gliss", 0.0  );
# Indicators on captain panel
setprop("tu154/systems/electrical/indicators/glideslope", 0.0 );
setprop("tu154/systems/electrical/indicators/stab-pitch", 0.0 );
setprop("tu154/systems/electrical/indicators/stab-h", 0.0 );
setprop("tu154/systems/electrical/indicators/stab-v", 0.0 );
setprop("tu154/systems/electrical/indicators/stab-m", 0.0 );
setprop("tu154/systems/electrical/indicators/reject", 0.0 );
}


# "Sbros progr" lamp - reset AP to zero roll state
# also use in heading wheel animation
var absu_reset = func {
if( absu_powered() == 0 ) return;
clr_heading_lamp();
setprop("fdm/jsbsim/ap/roll-selector", 0.0 );
setprop("tu154/instrumentation/pn-5/sbros", 1.0  );
if( getprop("fdm/jsbsim/ap/pitch-selector" ) == 5 )
	if( getprop("tu154/instrumentation/pu-46/stab" ) == 1.0 )
		absu_stab_current_pitch(); # Glideslope mode -> stab current pitch
		
setprop("tu154/instrumentation/pn-5/gliss", 0.0  );
setprop("tu154/systems/electrical/indicators/glideslope", 0.0 );

setprop("fdm/jsbsim/ap/go-around", 0.0);
setprop("tu154/systems/electrical/indicators/reject", 0.0 );

if( getprop("tu154/instrumentation/pu-46/stab" ) == 1.0 
    and getprop("tu154/switches/pu-46-kren" ) == 1.0 ) 
    {
    absu_stab_roll();
    setprop("fdm/jsbsim/ap/roll-hold", 1.0 );
#    setprop("tu154/systems/electrical/indicators/stab-heading", 1.0 );# lamps on
    }
}


# --------------- Pitch modes ------------------------------

var absu_drop_mvh = func{
if( absu_powered() == 0 ) return;
if( getprop("tu154/instrumentation/pu-46/stab" ) == 1.0 )
if( getprop("fdm/jsbsim/ap/pitch-selector" ) != 1.0 )
	{
        clr_pitch_lamp();
        setprop("fdm/jsbsim/ap/pitch-selector",1);
        setprop("fdm/jsbsim/ap/pitch-hold",1);
        if( getprop("tu154/switches/pu-46-tang" ) == 1.0 )
		{
       		setprop( "tu154/instrumentation/pn-5/pitch-state", 2 );
		setprop("tu154/systems/electrical/indicators/stab-pitch", 1.0 );
		}
	}
}

# Altitude stabilizer
var absu_h = func{
if( absu_powered() == 0 ) return;
#if( getprop("tu154/switches/pu-46-tang" ) != 1.0 ) return;
#if( getprop("tu154/instrumentation/pu-46/stab" ) != 1.0 ) return;
clr_pitch_lamp();
var alt = getprop("instrumentation/altimeter/indicated-altitude-ft");
if ( alt == nil ) return;
setprop("fdm/jsbsim/ap/input-altitude", alt );
setprop("fdm/jsbsim/ap/pitch-selector", 2 ); # H stab code
setprop("tu154/instrumentation/pu-46/h", 1.0 );
if( getprop("tu154/switches/pu-46-tang" ) == 1.0 )
	if( getprop("tu154/instrumentation/pu-46/stab" ) == 1.0 )
	      setprop("tu154/systems/electrical/indicators/stab-h", 1.0 );
}

# Air speed stabilizer
var absu_v = func{
if( absu_powered() == 0 ) return;
#if( getprop("tu154/switches/pu-46-tang" ) != 1.0 ) return;
#if( getprop("tu154/instrumentation/pu-46/stab" ) != 1.0 ) return;
var ias = getprop("fdm/jsbsim/velocities/vc-fps");
if ( ias == nil ) return;
clr_pitch_lamp();
setprop("fdm/jsbsim/ap/input-speed", ias );
setprop("fdm/jsbsim/ap/pitch-selector", 3 ); # V stab code
setprop("tu154/instrumentation/pu-46/v", 1.0 );
if( getprop("tu154/switches/pu-46-tang" ) == 1.0 )
	if( getprop("tu154/instrumentation/pu-46/stab" ) == 1.0 )
	      setprop("tu154/systems/electrical/indicators/stab-v", 1.0 );
}

# Mach stabilizer
var absu_m = func{
if( absu_powered() == 0 ) return;
#if( getprop("tu154/switches/pu-46-tang" ) != 1.0 ) return;
#if( getprop("tu154/instrumentation/pu-46/stab" ) != 1.0 ) return;
var mach = getprop("fdm/jsbsim/velocities/mach");
if ( mach == nil ) return;
clr_pitch_lamp();
setprop("fdm/jsbsim/ap/input-mach", mach );
setprop("fdm/jsbsim/ap/pitch-selector", 4 ); # M stab code
setprop("tu154/instrumentation/pu-46/m", 1.0 );
if( getprop("tu154/switches/pu-46-tang" ) == 1.0 )
	if( getprop("tu154/instrumentation/pu-46/stab" ) == 1.0 )
	      setprop("tu154/systems/electrical/indicators/stab-m", 1.0 );
}

# GLideslope
var absu_glideslope = func{
if( absu_powered() == 0 ) return;
if( getprop("tu154/switches/pn-5-posadk") != 1.0)return;# "podgotovka posadki" not engaged
if( getprop("tu154/switches/pn-5-navigac" ) != 0.0 ) return; # wrong control!
#if( getprop("instrumentation/nav[0]/data-is-valid" ) != 1 ) return; # Silence in air!
#if( getprop("instrumentation/nav[0]/has-gs" ) != 1 ) return; # has not glideslope from nav radio!
#deviation too big:
#if(  abs( getprop("instrumentation/nav[0]/gs-needle-deflection") ) > GLIDESLOPE_DEVIATION_LIMIT ) return;

clr_pitch_lamp();
setprop("tu154/instrumentation/pn-5/sbros", 0.0 );
setprop("fdm/jsbsim/ap/pitch-selector", 5.0 ); # Glideslope code
setprop("tu154/instrumentation/pn-5/gliss", 1.0 );
if( getprop("tu154/switches/pu-46-tang" ) == 1.0 )
	if( getprop("tu154/instrumentation/pu-46/stab" ) == 1.0 )
		setprop("tu154/systems/electrical/indicators/glideslope", 1.0 );
}

# --------------- Heading modes ------------------------------

# ZK
var absu_zk = func{
if( absu_powered() == 0 ) return;
#if( getprop("tu154/switches/pu-46-kren" ) != 1.0 ) return;
#if( getprop("tu154/instrumentation/pu-46/stab" ) != 1.0 ) return;
clr_heading_lamp();
setprop("fdm/jsbsim/ap/roll-selector", 2 ); # ZK code
setprop("tu154/instrumentation/pn-5/zk", 1.0 );
if( getprop("tu154/switches/pu-46-kren" ) == 1.0 )
	if( getprop("tu154/instrumentation/pu-46/stab" ) == 1.0 )
	      setprop("tu154/systems/electrical/indicators/zk", 1.0);
}
# VOR 1
var absu_az1 = func{
if( absu_powered() == 0 ) return;
#if( getprop("instrumentation/nav[0]/data-is-valid" ) != 1 ) return; # Silence in air!
#if( getprop("instrumentation/nav[0]/nav-loc" ) != 0 ) return; # Is it ILS?

clr_heading_lamp();

setprop("tu154/instrumentation/pn-5/az-1", 1.0 );
setprop("fdm/jsbsim/ap/roll-selector", 3 ); # VOR code

if( getprop("tu154/switches/pu-46-kren" ) == 1.0 )
    if( getprop("tu154/instrumentation/pu-46/stab") == 1.0) {
        if(getprop("tu154/switches/pn-5-navigac") == 1.0 and
           getprop("tu154/switches/pn-5-posadk") == 0.0)
	    setprop("tu154/systems/electrical/indicators/vor", 1.0);
        else
            setprop("tu154/systems/electrical/indicators/stab-heading", 1.0);
    }
}
# VOR 2
var absu_az2 = func{
if( absu_powered() == 0 ) return;
#if( getprop("instrumentation/nav[1]/data-is-valid" ) != 1 ) return; # Silence in air!
#if( getprop("instrumentation/nav[1]/nav-loc" ) != 0 ) return; # Is it ILS?

clr_heading_lamp();

setprop("tu154/instrumentation/pn-5/az-2", 1.0 );
setprop("fdm/jsbsim/ap/roll-selector", 3 ); # VOR code
if( getprop("tu154/switches/pu-46-kren" ) == 1.0 )
    if( getprop("tu154/instrumentation/pu-46/stab") == 1.0) {
        if(getprop("tu154/switches/pn-5-navigac") == 1.0 and
           getprop("tu154/switches/pn-5-posadk") == 0.0)
	    setprop("tu154/systems/electrical/indicators/vor", 1.0);
        else
            setprop("tu154/systems/electrical/indicators/stab-heading", 1.0);
    }
}
# NVU
var absu_nvu = func{
if( absu_powered() == 0 ) return;
clr_heading_lamp();

setprop("fdm/jsbsim/ap/roll-selector", 4 ); # NVU code
setprop("tu154/instrumentation/pn-5/nvu", 1.0 );
if( getprop("tu154/switches/pu-46-kren" ) == 1.0 )
    if( getprop("tu154/instrumentation/pu-46/stab") == 1.0) {
        if(getprop("tu154/switches/pn-5-navigac") == 1.0 and
           getprop("tu154/switches/pn-5-posadk") == 0.0)
	    setprop("tu154/systems/electrical/indicators/nvu", 1.0);
        else
            setprop("tu154/systems/electrical/indicators/stab-heading", 1.0);
    }
}

# Approach
var absu_approach = func{
if( absu_powered() == 0 ) return;
#if( getprop("instrumentation/nav[0]/data-is-valid" ) != 1 ) return; # Silence in air!
#if( getprop("instrumentation/nav[0]/nav-loc" ) != 1 ) return; # has not localizer signal from nav radio!
# deviation too big:
#if(  getprop("fdm/jsbsim/ap/ils-angle-deviation-abs") > HEADING_DEVIATION_LIMIT ) return;

clr_heading_lamp();
setprop("fdm/jsbsim/ap/roll-selector", 5 ); # ILS approach code
setprop("tu154/instrumentation/pn-5/zahod", 1.0 );
if( getprop("tu154/switches/pu-46-kren" ) == 1.0 )
    if( getprop("tu154/instrumentation/pu-46/stab" ) == 1.0 ) {
        if(getprop("tu154/switches/pn-5-navigac") == 0.0 and
           getprop("tu154/switches/pn-5-posadk") == 1.0)
	    setprop("tu154/systems/electrical/indicators/heading", 1.0 );
        else
            setprop("tu154/systems/electrical/indicators/stab-heading", 1.0);
    }
}



var absu_shutdown = func {
# Drop ABSU to idle state
absu_reset();
absu_stab_off();
#setprop( "tu154/instrumentation/pn-5/heading-state", 0 );
#setprop( "tu154/instrumentation/pn-5/pitch-state", 0 );

setprop("tu154/systems/electrical/indicators/stab-heading", 0.0 );
setprop("tu154/systems/electrical/indicators/stab-pitch", 0.0 );

if( getprop( "tu154/systems/absu/serviceable" ) == 0 )
	{
	absu_drop_mvh();
	clr_heading_lamp();
	clr_pitch_lamp()
	}
}


var absu_alarm = func{
setprop("tu154/systems/warning/alarm/absu_warn", 1.0 );
interpolate("tu154/systems/warning/alarm/absu_warn", 0.0, 1.4 );
}

var absu_alarm_watchdog = func{
if( getprop("tu154/systems/warning/alarm/absu_warn") < 0.1 )
	setprop("tu154/systems/warning/alarm/absu_warn", 0.0 );
}


setlistener("tu154/systems/absu/serviceable", absu_shutdown, 0, 0 );
setlistener("tu154/systems/absu/serviceable", absu_alarm, 0, 0 );
setlistener("tu154/systems/warning/alarm/absu_warn", absu_alarm_watchdog, 0, 0 );

absu_property_update();

# ********************** Go around procedure ********************************

var absu_start_go_around = func{
	absu_at_stop();
	absu_stab_roll();
	absu_stab_current_pitch();
	setprop("fdm/jsbsim/ap/stab-input-pitch-rad", GO_AROUND_PITCH_RAD );
	setprop("fdm/jsbsim/ap/go-around", 1.0);
	setprop("fdm/jsbsim/ap/roll-selector", 1.0);
	setprop("fdm/jsbsim/ap/input-speed", getprop("fdm/jsbsim/velocities/vc-fps") );
	interpolate("fdm/jsbsim/ap/input-speed", 260.0, 35.0 );
#	setprop("fdm/jsbsim/ap/pitch-selector", 3.0);
# Blank indicators, but stay button-lamps on PN-5 untouched
	setprop("tu154/systems/electrical/indicators/nvu", 0.0 );
        setprop("tu154/systems/electrical/indicators/vor", 0.0 );
        setprop("tu154/systems/electrical/indicators/zk", 0.0 );
        setprop("tu154/systems/electrical/indicators/heading", 0.0 );
        
	setprop("tu154/systems/electrical/indicators/glideslope", 0.0 );
        setprop("tu154/systems/electrical/indicators/stab-pitch", 0.0 );
        setprop("tu154/systems/electrical/indicators/stab-h", 0.0 );
        setprop("tu154/systems/electrical/indicators/stab-v", 0.0 );
        setprop("tu154/systems/electrical/indicators/stab-m", 0.0 );
        setprop("tu154/systems/electrical/indicators/reject", 0.0 );
        
       	setprop("tu154/systems/electrical/indicators/reject", 1.0 );
	setprop("tu154/systems/electrical/indicators/stab-heading", 1.0 );
	absu_go_around_handler();
}

var absu_go_around_handler = func{
if( getprop("fdm/jsbsim/ap/go-around") ) # if not, stop handler
 {
# wait until speed will be increase
 if( getprop("fdm/jsbsim/velocities/vc-fps") > getprop("fdm/jsbsim/ap/go-around-speed") )
  settimer( absu_go_around_handler, 0.5 ); # repeat 
 else setprop("fdm/jsbsim/ap/pitch-selector", 3.0); # speed OK, let's stabilise V
 } 
}

# ========================== yoke ap off =============================
var check_yoke_pitch = func{
var pitch = abs( getprop("/controls/flight/elevator") );
if( pitch < PITCH_YOKE_LIMIT ) return;
if( getprop( "fdm/jsbsim/ap/pitch-hold" ) ) absu_stab_tang(0); # drop pitch stabilizer
}
var check_yoke_bank = func{
var bank = abs( getprop("/controls/flight/aileron") );
if( bank < BANK_YOKE_LIMIT ) return;
if( getprop( "fdm/jsbsim/ap/roll-hold" ) ) absu_stab_kren(0); # drop roll
}

setlistener("/controls/flight/elevator", check_yoke_pitch, 0, 0 );
setlistener("/controls/flight/aileron", check_yoke_bank, 0, 0 );

# ================== AT-6 autothrottle subsystem =====================


var absu_at_handler = func{
var param = getprop ( "tu154/instrumentation/pn-6/serviceable" );
if( param == nil ) return;
if( param == 0 ) {	# drop to power off state
	absu_at_stop();
	setprop("tu154/instrumentation/pn-6/g1", 0 );
	setprop("tu154/instrumentation/pn-6/g2", 0 );
	setprop("tu154/instrumentation/pn-6/g3", 0 );
# 	setprop("tu154/instrumentation/pn-6/lamp-1", 0.0 );
# 	setprop("tu154/instrumentation/pn-6/lamp-2", 0.0 );
# 	setprop("tu154/instrumentation/pn-6/lamp-3", 0.0 );
 	setprop("tu154/instrumentation/pn-6/lamp-4", 0.0 );
 	setprop("tu154/instrumentation/pn-6/lamp-5", 0.0 );
	setprop("tu154/instrumentation/pn-6/stab", 0 );
	setprop("tu154/instrumentation/pn-6/mode", 0.0 );
	setprop("tu154/systems/electrical/indicators/autothrottle", 0.0 );
	setprop("fdm/jsbsim/ap/at-podg", 0.0 );
	return;
	}
param = arg[0];
# work mode
if( param == 0.0 ) # power off
	{
	absu_at_stop();
	setprop("tu154/instrumentation/pn-6/g1", 0 );
	setprop("tu154/instrumentation/pn-6/g2", 0 );
	setprop("tu154/instrumentation/pn-6/g3", 0 );
# 	setprop("tu154/instrumentation/pn-6/lamp-1", 0.0 );
# 	setprop("tu154/instrumentation/pn-6/lamp-2", 0.0 );
# 	setprop("tu154/instrumentation/pn-6/lamp-3", 0.0 );
 	setprop("tu154/instrumentation/pn-6/lamp-4", 0.0 );
 	setprop("tu154/instrumentation/pn-6/lamp-5", 0.0 );
	setprop("tu154/instrumentation/pn-6/stab", 0 );
	setprop("tu154/instrumentation/pn-6/mode", 0.0 );
	setprop("tu154/systems/electrical/indicators/autothrottle", 0.0 );
	setprop("fdm/jsbsim/ap/at-podg", 0.0 );
	return;	
	}
	
if( param == 1.0 ) # power on ( mode "soglasovanie" )
	{
	setprop("tu154/instrumentation/pn-6/mode", 1.0 );
	setprop("fdm/jsbsim/ap/at-podg", 1.0 );
	absu_at_sogl(); # start "soglasovanie" cycle
	return;
	}
	

if( param == 2.0 ) # mode "podgotovka" off 
	{
    if( getprop( "tu154/instrumentation/pn-6/mode" ) >= 1.0 )
	{
	absu_at_stop();
	setprop("tu154/instrumentation/pn-6/mode", 1.0 );
	return;
	}}

if( param == 3.0 ) # mode "podgotovka" on
	{
#print(param);
#print( getprop("tu154/instrumentation/pn-6/mode") );
    if( getprop("tu154/instrumentation/pn-6/mode") >= 1.0 )
	{
	interpolate("tu154/instrumentation/pn-6/mode", 3.0, 10.0 );
	return;
	}}
}


setlistener("tu154/instrumentation/pn-6/serviceable", absu_at_handler, 0, 0 );

# ABSU AT timer procedure
var absu_at_sogl = func{
if( getprop("tu154/instrumentation/pn-6/mode") == 0.0 ) return;
settimer( absu_at_sogl, 0.3 );


# control lamps
 if( getprop("tu154/instrumentation/pn-6/mode") > 2.0 )
 {
 setprop("tu154/instrumentation/pn-6/lamp-4", 1.0 );
 setprop("tu154/instrumentation/pn-6/lamp-5", 1.0 );
 }
 else
 {
 setprop("tu154/instrumentation/pn-6/lamp-4", 0.0 );
 setprop("tu154/instrumentation/pn-6/lamp-5", 0.0 );
 }

# end control lamps
if( getprop("tu154/instrumentation/pn-6/stab") == 0 ) # soglasovanie
	{
	setprop("fdm/jsbsim/ap/at-podg", 1.0 );
        setprop("fdm/jsbsim/ap/at-hold-0", 0.0 );
        setprop("fdm/jsbsim/ap/at-hold-1", 0.0 );
        setprop("fdm/jsbsim/ap/at-hold-2", 0.0 );

	var kias = getprop("instrumentation/airspeed-indicator/indicated-speed-kt");
	if( kias != nil ) interpolate("tu154/instrumentation/pn-6/at-kt", kias, 0.3); 
	}
else {
	var kias = getprop("tu154/instrumentation/pn-6/at-kt");
if( kias != nil ) setprop( "fdm/jsbsim/ap/input-at", kias*1.688 ); # from knots to fps
	absu_at_check_thr(); # check off-line state

	}	

	
}

var absu_at_check = func{
if( getprop("tu154/instrumentation/pn-6/mode") > 2.0 )
	{
	var state = !arg[0];
 	setprop("tu154/instrumentation/pn-6/lamp-4", state );
 	setprop("tu154/instrumentation/pn-6/lamp-5", state );
# 	setprop("tu154/instrumentation/pn-6/check-lamp", state );
	}

}

# Start stabilize speed
var absu_at_start = func{
if( getprop("tu154/instrumentation/pn-6/mode") < 2.0 ) return;
if( absu_at_check_thr() ) return; # 2 or 3 engines are offline now
# Set AT to stab mode
var kias = getprop("instrumentation/airspeed-indicator/indicated-speed-kt");
if( kias != nil ){
 	interpolate("tu154/instrumentation/pn-6/at-kt", kias, 0.3);
	setprop("fdm/jsbsim/ap/input-at", kias*1.688 );
	}

setprop("fdm/jsbsim/ap/at-hold-0", 1.0 );
setprop("fdm/jsbsim/ap/at-hold-1", 1.0 );
setprop("fdm/jsbsim/ap/at-hold-2", 1.0 );


setprop("tu154/instrumentation/pn-6/stab", 1.0 );
setprop("tu154/systems/electrical/indicators/autothrottle", 1.0 );
}

# Stop stabilize speed
var absu_at_stop = func{
setprop("fdm/jsbsim/ap/at-podg", 1.0 );
setprop("fdm/jsbsim/ap/at-hold-0", 0.0 );
setprop("fdm/jsbsim/ap/at-hold-1", 0.0 );
setprop("fdm/jsbsim/ap/at-hold-2", 0.0 );

setprop("tu154/instrumentation/pn-6/lamp-4", 0.0 );
setprop("tu154/instrumentation/pn-6/lamp-5", 0.0 );

if( getprop("tu154/instrumentation/pn-6/stab" ) ) absu_alarm();

setprop("tu154/instrumentation/pn-6/stab", 0.0 );

setprop("tu154/systems/electrical/indicators/autothrottle", 0.0 );

}

var absu_at_check_thr = func{
# Check off-line engines
var eng_1 = getprop( "tu154/instrumentation/pn-6/g1" );
if( eng_1 == nil ) eng_1 = 0;
var eng_2 = getprop( "tu154/instrumentation/pn-6/g2" );
if( eng_2 == nil ) eng_2 = 0;
var eng_3 = getprop( "tu154/instrumentation/pn-6/g3" );
if( eng_3 == nil ) eng_3 = 0;

if( (eng_1 + eng_2 + eng_3) > 1.0 ) {
	absu_at_stop();
	return 1;
	}
if( eng_1 ) setprop("fdm/jsbsim/ap/at-hold-0", 0.0 );
else setprop("fdm/jsbsim/ap/at-hold-0", 1.0 );
if( eng_2 ) setprop("fdm/jsbsim/ap/at-hold-1", 0.0 );
else setprop("fdm/jsbsim/ap/at-hold-1", 1.0 );
if( eng_3 ) setprop("fdm/jsbsim/ap/at-hold-2", 0.0 );
else setprop("fdm/jsbsim/ap/at-hold-2", 1.0 );
return 0;
}

# Power support
absu_power = func{
var acpwr = getprop( "tu154/systems/electrical/buses/AC3x200-bus-3L/volts" );
var mgv1 = getprop("tu154/instrumentation/bkk/mgv-1-failure");
if( mgv1 == nil ) mgv1 = 1;
var mgv2 = getprop("tu154/instrumentation/bkk/mgv-2-failure");
if( mgv2 == nil ) mgv2 = 1;
var mgvc = getprop("tu154/instrumentation/bkk/mgv-contr-failure");
if( mgvc == nil ) mgvc = 1;

    	if( getprop("tu154/switches/SAU-STU")==1 )
	{
	    if( acpwr == nil ) return; # system not ready yet
	    if( acpwr < 150.0 ) return;
	    # hydrosystem fails or busters off
	    if(  getprop("fdm/jsbsim/hs/busters-serviceable") < 2.5 ) return; 
	    # MGV check
	    var mgv = mgv1 + mgv2 + mgvc;
	    if( mgv > 1 ) return;	# deny stab autopilot if all MGV failure
	    # check hydropower of RA-56 
	    if( getprop("fdm/jsbsim/hs/ra-56-roll-serviceable") < 1.0 ) return;
	    if( getprop("fdm/jsbsim/hs/ra-56-yaw-serviceable") < 1.0 ) return;
	    if( getprop("fdm/jsbsim/hs/ra-56-pitch-serviceable") < 1.0 ) return;
	    if( getprop("fdm/jsbsim/ap/suu-enable") != 1.0 ) return;
	    # All OK, let's turn power on for ABSU
	     setprop("tu154/systems/absu/serviceable", 1 );
	     electrical.AC3x200_bus_3R.add_output( "ABSU", 100.0);
	}
   	else {
	     setprop("tu154/systems/absu/serviceable", 0 );
	     electrical.AC3x200_bus_3R.rm_output( "ABSU" );
	}
}



setlistener("tu154/switches/SAU-STU", absu_power, 0, 0 );
# ============================== End AT-6 support ===========================

gui.Dialog.new("/sim/gui/dialogs/Tu-154B-2/nav/dialog", "Aircraft/tu154b/Dialogs/nav.xml");


setprop("sim/menubar/default/menu[3]/enabled", 0 );

print("ABSU started, default autopilot disabled");
