#
# NASAL instruments for TU-154B
# Yurik V. Nikiforoff, yurik.nsk@gmail.com
# Novosibirsk, Russia
# jun 2007
#


# digit wheels support for UVO-15 SVS altimeter
# meters
altimeter1_handler = func {
settimer( altimeter1_handler, 0 );
if( getprop("tu154/systems/svs/powered") != 1 ) return;
var alt = getprop("instrumentation/altimeter/indicated-altitude-ft");
if( alt == nil ) { return; }

alt = alt * 0.3048;	# go to meters

setprop("tu154/instrumentation/altimeter/indicated-wheels_dec_m", 
(alt/10.0) - int( alt/100.0 )*10.0 );

setprop("tu154/instrumentation/altimeter/indicated-wheels_hund_m", 
(alt/100.0) - int( alt/1000.0 )*10.0 );

setprop("tu154/instrumentation/altimeter/indicated-wheels_ths_m", 
(alt/1000.0) - int( alt/10000.0 )*10.0 );

setprop("tu154/instrumentation/altimeter/indicated-wheels_decths_m", 
(alt/10000.0) - int( alt/100000.0 )*10.0 );

}

svs_power = func{
if( getprop( "tu154/switches/SVS-power" ) == 1.0 )
	electrical.AC3x200_bus_1L.add_output( "SVS", 10.0);
else electrical.AC3x200_bus_1L.rm_output( "SVS" );
}

setlistener("tu154/switches/SVS-power", svs_power, 0, 0);



# feet
altimeter2_handler = func {
settimer( altimeter2_handler, 0 );
if( getprop("tu154/instrumentation/altimeter[1]/powered") != 1 ) return;
var alt = getprop("instrumentation/altimeter[1]/indicated-altitude-ft");
if( alt == nil ) { return; }

setprop("tu154/instrumentation/altimeter[1]/indicated-wheels_dec_ft", 
(alt/10.0) - int( alt/100.0 )*10.0 );

setprop("tu154/instrumentation/altimeter[1]/indicated-wheels_hund_ft", 
(alt/100.0) - int( alt/1000.0 )*10.0 );

setprop("tu154/instrumentation/altimeter[1]/indicated-wheels_ths_ft", 
(alt/1000.0) - int( alt/10000.0 )*10.0 );

setprop("tu154/instrumentation/altimeter[1]/indicated-wheels_decths_ft", 
(alt/10000.0) - int( alt/100000.0 )*10.0 );
}

uvid15_power = func{
if( getprop( "tu154/switches/UVID" ) == 1.0 )
	electrical.AC3x200_bus_1L.add_output( "UVID-15", 10.0);
else electrical.AC3x200_bus_1L.rm_output( "UVID-15" );
}

setlistener("tu154/switches/UVID", uvid15_power, 0, 0 );


#pressure setting
altimeter1_pressure_handler = func{
var pressure = getprop("instrumentation/altimeter/setting-inhg");
if( pressure == nil ) { return; }
pressure = pressure * 25.4;	# go to metrics (mmhg)

setprop("tu154/instrumentation/altimeter/mmhg", pressure );

setprop("tu154/instrumentation/altimeter/mmhg-wheels_dec", 
(pressure/10.0) - int( pressure/100.0 )*10.0 );

setprop("tu154/instrumentation/altimeter/mmhg-wheels_hund", 
(pressure/100.0) - int( pressure/1000.0 )*10.0 );

}

altimeter2_pressure_handler = func{
var pressure = getprop("instrumentation/altimeter[1]/setting-inhg");
if( pressure == nil ) { return; }
pressure = pressure * 100.0;
setprop("tu154/instrumentation/altimeter[1]/inhg", pressure );

setprop("tu154/instrumentation/altimeter[1]/inhg-wheels_dec", 
(pressure/10.0) - int( pressure/100.0 )*10.0 );

setprop("tu154/instrumentation/altimeter[1]/inhg-wheels_hund", 
(pressure/100.0) - int( pressure/1000.0 )*10.0 );

setprop("tu154/instrumentation/altimeter[1]/inhg-wheels_ths", 
(pressure/1000.0) - int( pressure/10000.0 )*10.0 );
}

setlistener("instrumentation/altimeter/setting-inhg", altimeter1_pressure_handler, 0, 0);
setlistener("instrumentation/altimeter[1]/setting-inhg", altimeter2_pressure_handler, 0, 0);




altimeter1_handler();
altimeter2_handler();

altimeter1_pressure_handler();
altimeter2_pressure_handler();

# PNP support

pnp0_hdg_handler = func{
#settimer( pnp0_hdg_handler, 0 );
var hdg = getprop("tu154/instrumentation/pnp[0]/heading-deg-delayed");
if( hdg == nil )return; 
setprop("tu154/instrumentation/pnp[0]/heading/ones", hdg );
setprop("tu154/instrumentation/pnp[0]/heading/dec", 
(hdg/10.0) - int( hdg/100.0 )*10.0 );
setprop("tu154/instrumentation/pnp[0]/heading/hund", 
(hdg/100.0) - int( hdg/1000.0 )*10.0 );
}
pnp1_hdg_handler = func{
#settimer( pnp0_hdg_handler, 0 );
var hdg = getprop("tu154/instrumentation/pnp[1]/heading-deg-delayed");
if( hdg == nil )return; 
setprop("tu154/instrumentation/pnp[1]/heading/ones", hdg );
setprop("tu154/instrumentation/pnp[1]/heading/dec", 
(hdg/10.0) - int( hdg/100.0 )*10.0 );
setprop("tu154/instrumentation/pnp[1]/heading/hund", 
(hdg/100.0) - int( hdg/1000.0 )*10.0 );
}


pnp0_plane_handler = func{
var hdg = getprop("tu154/instrumentation/pnp[0]/plane-deg-delayed");
if( hdg == nil )return; 
setprop("tu154/instrumentation/pnp[0]/plane/ones", hdg );
setprop("tu154/instrumentation/pnp[0]/plane/dec", 
(hdg/10.0) - int( hdg/100.0 )*10.0 );
setprop("tu154/instrumentation/pnp[0]/plane/hund", 
(hdg/100.0) - int( hdg/1000.0 )*10.0 );
}

pnp1_plane_handler = func{
var hdg = getprop("tu154/instrumentation/pnp[1]/plane-deg-delayed");
if( hdg == nil )return; 
setprop("tu154/instrumentation/pnp[1]/plane/ones", hdg );
setprop("tu154/instrumentation/pnp[1]/plane/dec", 
(hdg/10.0) - int( hdg/100.0 )*10.0 );
setprop("tu154/instrumentation/pnp[1]/plane/hund", 
(hdg/100.0) - int( hdg/1000.0 )*10.0 );
}

# Tu-154 not use hdg digit, yellow bug only!
setlistener("tu154/instrumentation/pnp[0]/heading-deg-delayed", pnp0_hdg_handler,0,0 );
setlistener("tu154/instrumentation/pnp[1]/heading-deg-delayed", pnp1_hdg_handler,0,0 );


setlistener("tu154/instrumentation/pnp[0]/plane-deg-delayed", pnp0_plane_handler,0,0 );
setlistener("tu154/instrumentation/pnp[1]/plane-deg-delayed", pnp1_plane_handler,0,0 );


pnp0_hdg_handler();
pnp0_plane_handler();
pnp1_hdg_handler();
pnp1_plane_handler();

# SKAWK support

var skawk_handler = func{
  var digit_1 = getprop( "tu154/instrumentation/skawk/handle-1" );
  var digit_2 = getprop( "tu154/instrumentation/skawk/handle-2" );
  var digit_3 = getprop( "tu154/instrumentation/skawk/handle-3" );
  var digit_4 = getprop( "tu154/instrumentation/skawk/handle-4" );
  var mode_handle = getprop("tu154/instrumentation/skawk/handle-5" );
  var mode = 1;

  if( mode_handle == 0 ) mode = 4;	# A mode
  if( mode_handle == 2 ) mode = 5;	# C mode
  if( mode_handle == 1 ) mode = 1;	# Standby mode (B)
  if( mode_handle == 3 ) mode = 3;	# Ground mode (D)

  setprop("instrumentation/transponder/inputs/knob-mode", mode );
  setprop("instrumentation/transponder/inputs/digit[3]", digit_1 );
  setprop("instrumentation/transponder/inputs/digit[2]", digit_2 );
  setprop("instrumentation/transponder/inputs/digit[1]", digit_3 );
  setprop("instrumentation/transponder/inputs/digit", digit_4 );
}


# Load defaults at startup
setprop( "tu154/instrumentation/skawk/handle-1", getprop( "instrumentation/transponder/inputs/digit[3]" ) );
setprop( "tu154/instrumentation/skawk/handle-2", getprop( "instrumentation/transponder/inputs/digit[2]" ) );
setprop( "tu154/instrumentation/skawk/handle-3", getprop( "instrumentation/transponder/inputs/digit[1]" ) );
setprop( "tu154/instrumentation/skawk/handle-4", getprop( "instrumentation/transponder/inputs/digit" ) );
setprop( "tu154/instrumentation/skawk/handle-5", 1 );
setprop( "instrumentation/transponder/inputs/knob-mode", 1 );


setlistener("tu154/instrumentation/skawk/handle-1", skawk_handler,0,0 );
setlistener("tu154/instrumentation/skawk/handle-2", skawk_handler,0,0 );
setlistener("tu154/instrumentation/skawk/handle-3", skawk_handler,0,0 );
setlistener("tu154/instrumentation/skawk/handle-4", skawk_handler,0,0 );
setlistener("tu154/instrumentation/skawk/handle-5", skawk_handler,0,0 );



# IKU support
iku_handler = func {
settimer( iku_handler, 0.1 );

#Captain panel
# yellow needle
var sel_yellow = getprop("tu154/instrumentation/iku-1[0]/l-mode");
if( sel_yellow == nil ) sel_yellow = 0.0;
var param_yellow = getprop("instrumentation/nav[0]/radials/reciprocal-radial-deg");
if( param_yellow == nil ) param_yellow = 0.0;
var compass = getprop("fdm/jsbsim/instrumentation/bgmk-1");
if( compass == nil ) compass = 0.0;
if( sel_yellow == 0.0 ) # ADF
	param_yellow = getprop("instrumentation/adf[0]/indicated-bearing-deg");
else param_yellow -= compass;
if( param_yellow == nil ) param_yellow = 0.0;
setprop("tu154/instrumentation/iku-1[0]/indicated-heading-l", param_yellow );
# White needle
var sel_white = getprop("tu154/instrumentation/iku-1[0]/r-mode");
if( sel_white == nil ) sel_white = 0.0;
var param_white = getprop("instrumentation/nav[1]/radials/reciprocal-radial-deg");
if( param_white == nil ) param_white = 0.0;
if( sel_white == 0.0 ) # ADF
	param_white = getprop("instrumentation/adf[1]/indicated-bearing-deg");
else param_white -= compass;
if( param_white == nil ) param_white = 0.0;
setprop("tu154/instrumentation/iku-1[0]/indicated-heading-r", param_white );

#Copilot panel
compass = getprop("fdm/jsbsim/instrumentation/bgmk-2");
if( compass == nil ) compass = 0.0;
# yellow needle
sel_yellow = getprop("tu154/instrumentation/iku-1[1]/l-mode");
if( sel_yellow == nil ) sel_yellow = 0.0; 
param_yellow = getprop("instrumentation/nav[0]/radials/reciprocal-radial-deg");
if( param_yellow == nil ) param_yellow = 0.0;
if( sel_yellow == 0.0 ) # ADF
	param_yellow = getprop("instrumentation/adf[0]/indicated-bearing-deg");
else param_yellow -= compass;
if( param_yellow == nil ) param_yellow = 0.0;
setprop("tu154/instrumentation/iku-1[1]/indicated-heading-l", param_yellow );
# White needle
sel_white = getprop("tu154/instrumentation/iku-1[1]/r-mode");
if( sel_white == nil ) sel_white = 0.0; 
 getprop("instrumentation/nav[1]/radials/reciprocal-radial-deg");
if( param_white == nil ) param_white = 0.0;
if( sel_white == 0.0 ) # ADF
	param_white = getprop("instrumentation/adf[1]/indicated-bearing-deg");
else param_white -= compass;
if( param_white == nil ) param_white = 0.0;
setprop("tu154/instrumentation/iku-1[1]/indicated-heading-r", param_white );
}

iku_handler();

# Heading (yellow index, left handle)

compass_adjust_hdg = func {
var prop = "tu154/instrumentation/pnp[0]/heading-deg";
if( arg[0] == 1 ) prop = "tu154/instrumentation/pnp[1]/heading-deg";

var delta = arg[1];
var heading = getprop( prop );
if( heading == nil ) return;

heading = heading + delta;
if( heading >= 360.0 ) heading = heading - 360.0;
if( 0 > heading ) heading = heading + 360.0; 
setprop( prop, heading );
# proceed delayed property for smooth digit wheel animation
prop = sprintf("%s-delayed", prop);
interpolate( prop, heading, 0.2 );

}

# "Plane" (white needle, right handle with plane symbol)

compass_adjust_plane = func {
var prop = "tu154/instrumentation/pnp[0]/plane-deg";
if( arg[0] == 1 ) prop = "tu154/instrumentation/pnp[1]/plane-deg";

var delta = arg[1];
# proceed delayed property for smooth digit wheel animation
var delayed_prop = sprintf("%s-delayed", prop);
var local_prop = sprintf("%s-local", prop);

var heading = getprop( local_prop );
if( heading == nil ) return;
heading = heading + delta;
if( heading >= 360.0 ) heading = heading - 360.0;
if( 0 > heading ) heading = heading + 360.0; 

setprop( local_prop, heading );
interpolate( delayed_prop, heading, 0.2 );
# proceed white needle
var absu_roll_mode = getprop( "fdm/jsbsim/ap/roll-selector" );
if( absu_roll_mode == nil ) absu_roll_mode = 0;
if( absu_roll_mode == 4 ) return; # NVU selected; needle will operate from NVU source
if( absu_roll_mode == 3 ) # VOR selected
      {
      var zpu_src = getprop( "tu154/switches/pn-5-pnp-selector" );
      if( zpu_src == nil ) zpu_src = 0;
      if( zpu_src != arg[0] ) return; # Both needles operate from another PNP
      setprop( "tu154/instrumentation/pnp[0]/plane-deg", heading );
      setprop( "tu154/instrumentation/pnp[1]/plane-deg", heading );
      }
else { setprop( prop, heading ); }
}


# RV-5M support
rv5m_handler = func{
settimer( rv5m_handler, 0.1 );
# Arretir:
if( getprop("tu154/instrumentation/rv-5m/caged-flag" ) != 0 )
	{
	setprop("tu154/instrumentation/rv-5m/warn", 0 );
	setprop("tu154/instrumentation/rv-5m/indicated-altitude-m", 0.0 );
	return;
	}
if( getprop("tu154/instrumentation/rv-5m/serviceable" ) != 1 ) 
	{
        setprop("tu154/instrumentation/rv-5m/warn", 0 );
        return;
	}
# get altitude and check if device is warmed
var alt = getprop("fdm/jsbsim/instrumentation/indicated-altitude-m");
var hot = getprop("tu154/instrumentation/rv-5m/hot");
if( alt == nil ) alt = 0.0;
if( hot == nil ) hot = 0.0;
if( alt < hot ) alt = hot;
interpolate("tu154/instrumentation/rv-5m/indicated-altitude-m", alt, 0.1 );
# check warning
var limit = getprop("tu154/instrumentation/rv-5m/index-m");
if( limit == nil ) return;
if( alt < limit ) 
	{
	setprop("tu154/instrumentation/rv-5m/warn", 1 );
#	interpolate("tu154/systems/electrical/indicators/radioaltimeter-limit", 1.0, 0.1);
	}
else { 
	setprop("tu154/instrumentation/rv-5m/warn", 0 );
#	interpolate("tu154/systems/electrical/indicators/radioaltimeter-limit", 0.0, 0.1);
	}
}

rv5m_power = func{
if( getprop( "tu154/switches/RV-5-1" ) == 1.0 )
	{
	setprop("tu154/instrumentation/rv-5m/hot", 5000.0 );
	electrical.AC3x200_bus_1L.add_output( "RV-5-1", 10.0);
	if( getprop( "tu154/systems/electrical/buses/AC3x200-bus-1L/volts" ) > 150.0 )
		interpolate("tu154/instrumentation/rv-5m/hot", -1.0, 20.0 );
	}
else {
	setprop("tu154/instrumentation/rv-5m/hot", 0 );
	electrical.AC3x200_bus_1L.rm_output( "RV-5-1" );
	}
}

setlistener("tu154/switches/RV-5-1", rv5m_power,0,0);
setlistener("tu154/instrumentation/rv-5m/serviceable", rv5m_power,0,0);


rv5m_handler();

# COM radio support
var com_1_handler = func {
var hi_digit = getprop( "tu154/instrumentation/com-1/digit-f-hi" );
if ( hi_digit == nil ) hi_digit = 108.0;
var low_digit = getprop( "tu154/instrumentation/com-1/digit-f-low" );
if ( low_digit == nil ) low_digit = 0;
setprop("instrumentation/comm[0]/frequencies/selected-mhz", hi_digit + low_digit/100 );
}

var com_2_handler = func {
var hi_digit = getprop( "tu154/instrumentation/com-2/digit-f-hi" );
if ( hi_digit == nil ) hi_digit = 108.0;
var low_digit = getprop( "tu154/instrumentation/com-2/digit-f-low" );
if ( low_digit == nil ) low_digit = 0;
setprop("instrumentation/comm[1]/frequencies/selected-mhz", hi_digit + low_digit/100 );
}

var com_radio_init = func {

var freq = getprop( "instrumentation/comm[0]/frequencies/selected-mhz" );
    if ( freq == nil ) freq = 108.00;
    setprop( "tu154/instrumentation/com-1/digit-f-hi", int(freq) );
    setprop( "tu154/instrumentation/com-1/digit-f-low", (freq - int(freq)) * 100 );
    freq = getprop( "instrumentation/comm[1]/frequencies/selected-mhz" );
    if ( freq == nil ) freq = 108.00;
    setprop( "tu154/instrumentation/com-2/digit-f-hi", int(freq) );
    setprop( "tu154/instrumentation/com-2/digit-f-low", (freq - int(freq)) * 100 );
    setprop("instrumentation/comm[0]/serviceable", 0 );
    setprop("instrumentation/comm[1]/serviceable", 0 );
}

com_radio_init();

setlistener("tu154/instrumentation/com-1/digit-f-hi", com_1_handler,0,0);
setlistener("tu154/instrumentation/com-1/digit-f-low", com_1_handler,0,0);
setlistener("tu154/instrumentation/com-2/digit-f-hi", com_2_handler,0,0);
setlistener("tu154/instrumentation/com-2/digit-f-low", com_2_handler,0,0);


# DISS support
var diss_handler = func{
settimer( diss_handler, 0.5 );
var param = getprop("tu154/instrumentation/diss/powered");
if( param != 1 ) { setprop("tu154/instrumentation/diss/serviceable", 0 ); return; }

var check = getprop("tu154/switches/DISS-check");
if( check == nil ) check = 0.0;
var speed  = getprop("fdm/jsbsim/velocities/vg-fps");
if( speed == nil ) speed = 0.0;
if( speed > 164.0 )
{
 if( getprop("tu154/instrumentation/diss/serviceable") != 1 )
	setprop("tu154/instrumentation/diss/serviceable", 1 );
}
else { speed = 0.0; setprop("tu154/instrumentation/diss/serviceable", 0 ); }

var drift  = getprop("fdm/jsbsim/instrumentation/drift-angle-deg");
if( drift == nil ) drift = 0.0;

if( check != 1.0 ) { # check in fly
	drift = -1.0;
	speed = 647.055; # 710 kmh
}

setprop("tu154/instrumentation/diss/drift-deg", drift );
#setprop("fdm/jsbsim/ap/input-drift-deg", drift );

setprop("tu154/instrumentation/diss/groundspeed-kmh", speed * 1.09728 );
#setprop("fdm/jsbsim/instrumentation/input-vg-fps", speed );

}

diss_power = func{
if( getprop( "tu154/switches/DISS-power" ) == 1.0 )
	electrical.AC3x200_bus_1L.add_output( "DISS", 25.0);
else electrical.AC3x200_bus_1L.rm_output( "DISS" );
}

setlistener("tu154/switches/DISS-power", diss_power,0,0);
diss_handler();

# BKK support

bkk_handler = func{
settimer( bkk_handler, 0.5 );
var param = getprop("tu154/instrumentation/bkk/serviceable");
if( param == nil ) return;
if( param == 0 )
	{
	var lamp_pwr = getprop("tu154/systems/electrical/buses/DC27-bus-L/volts");
	if( lamp_pwr == nil ) lamp_pwr = 0.0;
	if( lamp_pwr > 0 ) lamp_pwr = 1.0;
	setprop("tu154/systems/electrical/indicators/contr-gyro", lamp_pwr );
	setprop("tu154/instrumentation/bkk/mgv-1-failure", lamp_pwr);
	setprop("tu154/instrumentation/bkk/mgv-2-failure", lamp_pwr);
	setprop("tu154/instrumentation/bkk/mgv-contr-failure", lamp_pwr);
	setprop("tu154/systems/electrical/indicators/mgvk-failure", lamp_pwr);
	return;
	}
# check MGV
# Get MGV data
var mgv_1_pitch = getprop("instrumentation/attitude-indicator[0]/indicated-pitch-deg");
if( mgv_1_pitch == nil ) return;
var mgv_1_roll = getprop("instrumentation/attitude-indicator[0]/indicated-roll-deg");
if( mgv_1_roll  == nil ) return;
var mgv_2_pitch = getprop("instrumentation/attitude-indicator[1]/indicated-pitch-deg");
if( mgv_2_pitch  == nil ) return;
var mgv_2_roll = getprop("instrumentation/attitude-indicator[1]/indicated-roll-deg");
if( mgv_2_roll  == nil ) return;
var mgv_c_pitch = getprop("instrumentation/attitude-indicator[2]/indicated-pitch-deg");
if( mgv_c_pitch  == nil ) return;
var mgv_c_roll = getprop("instrumentation/attitude-indicator[2]/indicated-roll-deg");
if( mgv_c_roll  == nil ) return;
var delta = getprop("tu154/instrumentation/bkk/delta-deg");

# check MGV-1
if( delta < abs( mgv_1_pitch - mgv_c_pitch ) )
	setprop("tu154/instrumentation/bkk/mgv-1-failure", 1);
if( delta < abs( mgv_1_roll - mgv_c_roll ) )
	setprop("tu154/instrumentation/bkk/mgv-1-failure", 1);

# check MGV-2	
if( delta < abs( mgv_2_pitch - mgv_c_pitch ) )
	setprop("tu154/instrumentation/bkk/mgv-2-failure", 1);
if( delta < abs( mgv_2_roll - mgv_c_roll ) )
	setprop("tu154/instrumentation/bkk/mgv-2-failure", 1);

# check MGV-contr		
if( getprop("tu154/instrumentation/bkk/mgv-1-failure" ) == 1 ){
	if( getprop("tu154/instrumentation/bkk/mgv-2-failure" ) == 1 )
		{
		setprop("tu154/instrumentation/bkk/mgv-contr-failure", 1);
		setprop("tu154/systems/electrical/indicators/contr-gyro", 1);
		setprop("tu154/systems/electrical/indicators/mgvk-failure", 1);
}}
		
# Check roll limit

var ias = getprop( "instrumentation/airspeed-indicator/indicated-speed-kt" );
if( ias == nil ) ias = 0.0;
ias = ias * 1.852; # to kmh
var alt = getprop( "instrumentation/altimeter/indicated-altitude-ft" );
if( alt == nil ) alt = 0.0;
alt = alt * 0.3048; # to m
var limit = 15.0;
if( getprop( "tu154/switches/pn-5-posadk" ) == 1 ){
	if( alt >= 250.0 ) limit = 33.0;	
	if( alt < 250.0 ) limit = 15.0;
	}
else {
	if( ias > 340.0 ) limit = 33.0;	
	if( alt < 280.0 ) limit = 15.0;

	}

if( getprop("tu154/instrumentation/bkk/mgv-1-failure" == 0 ) ){
	if( abs( mgv_1_roll ) > limit ){
		if( mgv_1_roll < 0 ){
		setprop("tu154/systems/electrical/indicators/left-bank", 1); }
		else { setprop("tu154/systems/electrical/indicators/right-bank", 1); }
		}
	if( abs( mgv_1_roll ) < limit )	{
		if( mgv_1_roll < 0 ){
		setprop("tu154/systems/electrical/indicators/left-bank", 0); }
		else { setprop("tu154/systems/electrical/indicators/right-bank", 0); }
		}
	}
else	{
if( getprop("tu154/instrumentation/bkk/mgv-2-failure" ) == 0 )
	if( abs( mgv_2_roll ) > limit ){
		if( mgv_2_roll < 0 ){
		setprop("tu154/systems/electrical/indicators/left-bank", 1); }
		else { setprop("tu154/systems/electrical/indicators/right-bank", 1); }
		}
	if( abs( mgv_1_roll ) < limit )	{
		if( mgv_2_roll < 0 ){
		setprop("tu154/systems/electrical/indicators/left-bank", 0); }
		else { setprop("tu154/systems/electrical/indicators/right-bank", 0); }
		}
	}
}



bkk_adjust = func{

	var param = getprop("tu154/systems/mgv/one");
	if( param == nil ) return;
	param = param + 0.1;
	if( param >= 6.0 ) param = 6.0; 
	setprop("tu154/systems/mgv/one", param);
	
	param = getprop("tu154/systems/mgv/two");
	if( param == nil ) return;
	param = param + 0.1;
	if( param >= 6.0 ) param = 6.0; 
	setprop("tu154/systems/mgv/two", param);
	
	param = getprop("tu154/systems/mgv/contr");
	if( param == nil ) return;
	param = param + 0.1;
	if( param >= 6.0 ) param = 6.0; 
	setprop("tu154/systems/mgv/contr", param);
		
}

bkk_shutdown = func{
if ( arg[0] == 0 ) 
	{
#	setprop( "instrumentation/attitude-indicator[0]/serviceable", 0 );
	setprop("tu154/systems/mgv/one", 0.0);
#setprop( "instrumentation/attitude-indicator[0]/internal-pitch-deg",-rand()*30.0 );
#setprop( "instrumentation/attitude-indicator[0]/internal-roll-deg", -rand()*15.0 );
	}
if ( arg[0] == 1 ) 
	{
#	setprop( "instrumentation/attitude-indicator[1]/serviceable", 0 );
	setprop("tu154/systems/mgv/two", 0.0);
#setprop( "instrumentation/attitude-indicator[1]/internal-pitch-deg",-rand()*30.0 );
#setprop( "instrumentation/attitude-indicator[1]/internal-roll-deg", -rand()*15.0 );
	}
if ( arg[0] == 2 ) 
	{
	setprop( "instrumentation/attitude-indicator[2]/serviceable", 0 );
	setprop("tu154/systems/mgv/contr", 0.0);
#setprop( "instrumentation/attitude-indicator[2]/internal-pitch-deg",-rand()*30.0 );
#setprop( "instrumentation/attitude-indicator[2]/internal-roll-deg", -rand()*15.0 );
	}
if ( arg[0] == 3 ) 
	{
	setprop( "instrumentation/attitude-indicator[3]/serviceable", 0 );
#setprop( "instrumentation/attitude-indicator[3]/internal-pitch-deg",-rand()*30.0 );
#setprop( "instrumentation/attitude-indicator[3]/internal-roll-deg", -rand()*15.0 );
	}

	

}

bkk_reset = func{
setprop("tu154/instrumentation/bkk/mgv-1-failure", 0);
setprop("tu154/instrumentation/bkk/mgv-2-failure", 0);
setprop("tu154/instrumentation/bkk/mgv-contr-failure", 0);
setprop("tu154/systems/electrical/indicators/contr-gyro", 0);
setprop("tu154/systems/electrical/indicators/mgvk-failure", 0);
}



bkk_handler();

# BKK power support
bkk_power = func{
if( getprop( "tu154/switches/BKK-power" ) == 1.0 )
	electrical.AC3x200_bus_1L.add_output( "BKK", 25.0);
else electrical.AC3x200_bus_1L.rm_output( "BKK" );
}

setlistener("tu154/switches/BKK-power", bkk_power,0,0);

# AGR power support
agr_power = func{
if( getprop( "tu154/switches/AGR" ) == 1.0 )
	electrical.AC3x200_bus_1L.add_output( "AGR", 10.0);
else electrical.AC3x200_bus_1L.rm_output( "AGR" );
}
# MGV-1 power support
mgv_1_power = func{
if( getprop( "tu154/switches/PKP-left" ) == 1.0 )
	electrical.AC3x200_bus_1L.add_output( "MGV-1", 10.0);
else electrical.AC3x200_bus_1L.rm_output( "MGV-1" );
}
# MGV-2 power support
mgv_2_power = func{
if( getprop( "tu154/switches/PKP-right" ) == 1.0 )
	electrical.AC3x200_bus_3R.add_output( "MGV-2", 10.0);
else electrical.AC3x200_bus_3R.rm_output( "MGV-2" );
}
# MGV contr power support
mgv_c_power = func{
if( getprop( "tu154/switches/MGV-contr" ) == 1.0 )
	electrical.AC3x200_bus_3R.add_output( "MGV-contr", 10.0);
else electrical.AC3x200_bus_3R.rm_output( "MGV-contr" );
}

setlistener("tu154/switches/AGR", agr_power,0,0);
setlistener("tu154/switches/PKP-left", mgv_1_power,0,0);
setlistener("tu154/switches/PKP-right", mgv_2_power,0,0);
setlistener("tu154/switches/MGV-contr", mgv_c_power,0,0);

# =============================== IDR-1 support =============================
idr_capt_handler = func{
settimer( idr_capt_handler, 0 );
var distance = 0.0;
var caged = 1;
if( getprop("tu154/switches/capt-idr-selector") == nil )
 		setprop("tu154/switches/capt-idr-selector", 0.0 );
 		
if( getprop("tu154/switches/capt-idr-selector") == 0 )
	{
	if( getprop( "instrumentation/nav[0]/in-range") == 1 ) {
	  if( (getprop( "instrumentation/nav[0]/nav-loc") == 0 ) # not ILS (VOR)
	      or (getprop( "instrumentation/nav[0]/dme-in-range") == 1 ) # ILS with DME
		) {
	     setprop("tu154/instrumentation/idr-1[0]/caged-flag",0 );
	     distance = getprop("instrumentation/nav[0]/nav-distance");     
	     caged = 0;
		}
	else distance = 0.0;
	}}
if( getprop("tu154/switches/capt-idr-selector") == 1 )
	{
	if( getprop( "instrumentation/nav[2]/in-range") == 1 ) {
	  if( (getprop( "instrumentation/nav[2]/nav-loc") == 0 ) # not ILS
	      or (getprop( "instrumentation/nav[2]/dme-in-range") == 1 ) # ILS with DME
		) {
	     setprop("tu154/instrumentation/idr-1[0]/caged-flag",0 );
	     distance = getprop("instrumentation/nav[2]/nav-distance");     
	     caged = 0;
		}}
	else distance = 0.0;
	}
	
if( getprop("tu154/switches/capt-idr-selector") == 2 )
	{
	if( getprop( "instrumentation/nav[1]/in-range") == 1 ) {
	  if( (getprop( "instrumentation/nav[1]/nav-loc") == 0 ) # not ILS
		or (getprop( "instrumentation/nav[1]/dme-in-range") == 1 ) # ILS with DME
		) {
	     setprop("tu154/instrumentation/idr-1[0]/caged-flag",0 );
	     distance = getprop("instrumentation/nav[1]/nav-distance");     
	     caged = 0;
		}}
	else  distance = 0.0;
	}
setprop("tu154/instrumentation/idr-1[0]/caged-flag", caged ); 
if( distance == nil ){ setprop("tu154/instrumentation/idr-1[0]/caged-flag",1 ); return; } 
  distance = distance/10.0; # to dec meters, it need for correct work of digit wheels
  setprop("tu154/instrumentation/idr-1[0]/indicated-wheels_dec_m", 
  (distance/10.0) - int( distance/100.0 )*10.0 );
  setprop("tu154/instrumentation/idr-1[0]/indicated-wheels_hund_m", 
  (distance/100.0) - int( distance/1000.0 )*10.0 );
  setprop("tu154/instrumentation/idr-1[0]/indicated-wheels_ths_m", 
  (distance/1000.0) - int( distance/10000.0 )*10.0 );
  setprop("tu154/instrumentation/idr-1[0]/indicated-wheels_decths_m", 
  (distance/10000.0) - int( distance/100000.0 )*10.0 );
}

idr_capt_handler();

# ************************* TKS staff ***********************************

# auto corrector for GA-3 and BGMK
var tks_corr = func{
var mk1 = getprop("fdm/jsbsim/instrumentation/km-5-1");
if( mk1 == nil ) return;
var mk2 = getprop("fdm/jsbsim/instrumentation/km-5-2");
if( mk2 == nil ) return;
help.tks();	# show help string
if( getprop("tu154/switches/pu-11-gpk") == 1 ) { # GA-3 correction
# parameters GA-3
   var gpk_1 = getprop("fdm/jsbsim/instrumentation/ga3-corrected-1");
   var gpk_2 = getprop("fdm/jsbsim/instrumentation/ga3-corrected-2");
   if( gpk_1 == nil ) return;
   if( gpk_2 == nil ) return;
   if( getprop("tu154/switches/pu-11-corr") == 0 ) # kontr
	{
	if( getprop("instrumentation/heading-indicator[1]/serviceable" ) != 1 ) return;
	var delta = gpk_2 - mk2;
	if( abs( delta ) < 0.5 ) return; 		# not adjust small values
	if( delta > 360.0 ) delta = delta - 360.0;	# bias control
	if( delta < 0.0 ) delta = delta + 360.0;
	if( delta > 180 ) delta = 0.5; else delta = -0.5;# find short way	
	var offset = getprop("instrumentation/heading-indicator[1]/offset-deg");
	if( offset == nil ) return;
	setprop("instrumentation/heading-indicator[1]/offset-deg", offset+delta );
	return;
	}
else	{ # osn
	if( getprop("instrumentation/heading-indicator[0]/serviceable" ) != 1 ) return;
	var delta = gpk_1 - mk1;
	if( abs( delta ) < 1.0 ) return; 		# not adjust small values
	if( delta > 360.0 ) delta = delta - 360.0;	# bias control
	if( delta < 0.0 ) delta = delta + 360.0;
	if( delta > 180 ) delta = 0.5; else delta = -0.5;# find short way	
	var offset = getprop("instrumentation/heading-indicator[0]/offset-deg");
	if( offset == nil ) return;
	setprop("instrumentation/heading-indicator[0]/offset-deg", offset+delta );
	return;
	}
   } # end GA-3 correction
   if( getprop("tu154/switches/pu-11-gpk") == 0 ) { # BGMK correction
# parameters BGMK
   if( getprop("tu154/switches/pu-11-corr") == 0 ) # BGMK-2
	{
        setprop("fdm/jsbsim/instrumentation/bgmk-corrector-2",1);
	}
else	{ # BGMK-1
        setprop("fdm/jsbsim/instrumentation/bgmk-corrector-1",1);
	} 
   } # end BGMK correction
}

# manually adjust gyro heading - GA-3 only
tks_adj = func{
if( getprop("tu154/switches/pu-11-gpk") != 0 ) return;
help.tks();	# show help string
var delta = 0.1;
if( getprop("tu154/switches/pu-11-corr") == 0 ) # kontr
	{
	if( getprop("instrumentation/heading-indicator[1]/serviceable" ) != 1 ) return;
	if( arg[0] == 1 ) # to right
		{
		var offset = getprop("instrumentation/heading-indicator[1]/offset-deg");
		if( offset == nil ) return;
		setprop("instrumentation/heading-indicator[1]/offset-deg", offset+delta );
		return;
		}
	else	{ # to left
		var offset = getprop("instrumentation/heading-indicator[1]/offset-deg");
		if( offset == nil ) return;
		setprop("instrumentation/heading-indicator[1]/offset-deg", offset-delta );
		return;
		}
	}
else	{	# osn
	 if( getprop("instrumentation/heading-indicator[0]/serviceable" ) != 1 ) return;
	if( arg[0] == 1 ) # to right
		{
		var offset = getprop("instrumentation/heading-indicator[0]/offset-deg");
		if( offset == nil ) return;
		setprop("instrumentation/heading-indicator[0]/offset-deg", offset+delta );
		return;
		}
	else	{ # to left
		var offset = getprop("instrumentation/heading-indicator[0]/offset-deg");
		if( offset == nil ) return;
		setprop("instrumentation/heading-indicator[0]/offset-deg", offset-delta );
		return;
		}

	}
}

# TKS power support

tks_power_1 = func{
if( getprop( "tu154/switches/TKC-power-1" ) == 1.0 )
	electrical.AC3x200_bus_1L.add_output( "GA3-1", 10.0);
else electrical.AC3x200_bus_1L.rm_output( "GA3-1" );		
}

tks_bgmk_1 = func{
if( getprop( "tu154/switches/TKC-BGMK-1" ) == 1.0 )
	electrical.AC3x200_bus_1L.add_output( "BGMK-1", 10.0);
else electrical.AC3x200_bus_1L.rm_output( "BGMK-1" );		
}

tks_power_2 = func{
if( getprop( "tu154/switches/TKC-power-2" ) == 1.0 )
	electrical.AC3x200_bus_3R.add_output( "GA3-2", 10.0);
else electrical.AC3x200_bus_3R.rm_output( "GA3-2" );		
}

tks_bgmk_2 = func{
if( getprop( "tu154/switches/TKC-BGMK-2" ) == 1.0 )
	electrical.AC3x200_bus_3R.add_output( "BGMK-2", 10.0);
else electrical.AC3x200_bus_3R.rm_output( "BGMK-2" );		
}


setlistener( "tu154/switches/TKC-power-1", tks_power_1 ,0,0);
setlistener( "tu154/switches/TKC-power-2", tks_power_2 ,0,0);
setlistener( "tu154/switches/TKC-BGMK-1", tks_bgmk_1 ,0,0);
setlistener( "tu154/switches/TKC-BGMK-2", tks_bgmk_2 ,0,0);

# Aug 2009
# Azimuthal error for gyroscope

var last_point = geo.Coord.new();
var current_point = geo.Coord.new();

# Initialise
last_point = geo.aircraft_position();
current_point = last_point;
setprop("/fdm/jsbsim/instrumentation/az-err", 0.0 );

# Azimuth error handler
var tks_az_handler = func{
settimer(tks_az_handler, 60.0 );
current_point = geo.aircraft_position();
if( last_point.distance_to( current_point ) < 1000.0 ) return; # skip small distance

az_err = getprop("/fdm/jsbsim/instrumentation/az-err" );
var zipu = last_point.course_to( current_point );
var ozipu = current_point.course_to( last_point );
az_err += zipu - (ozipu - 180.0);
if( az_err > 180.0 ) az_err -= 360.0;
if( -180.0 > az_err ) az_err += 360.0;
setprop("/fdm/jsbsim/instrumentation/az-err", az_err );
last_point = current_point;
}

settimer(tks_az_handler, 60.0 );


# ************************* End TKS staff ***********************************
var HEADING_DEVIATION_LIMIT = 10.0;
var GLIDESLOPE_DEVIATION_LIMIT = 4.0;

# Blankers
var blanker_support = func{
settimer( blanker_support, 1.0 );
var param = 0.0;

# --------------------------- Captain -----------------------------------
	var mode = get_mp_mode( 0 );
	# ILS
	if( mode == 4 )
	{ # Heading
          param = 0.0;
          if( getprop("instrumentation/nav[0]/in-range" ) == 1 ) param = 1.0;
          if(  abs( getprop("instrumentation/nav[0]/heading-needle-deflection") ) < HEADING_DEVIATION_LIMIT ) param = param + 1.0;
          if( param == 2.0 ) {
                  setprop("tu154/instrumentation/pkp[0]/kurs-blanker", 0.0 );
                  setprop("tu154/instrumentation/pnp[0]/kurs-blanker", 0.0 );
                  }
          else {	
          setprop("tu154/instrumentation/pkp[0]/kurs-blanker", 1.0 );
          setprop("tu154/instrumentation/pnp[0]/kurs-blanker", 1.0 );
          }
	  # Glideslope
          param = 0.0;
          if( getprop("instrumentation/nav[0]/in-range" ) == 1 ) param = 1.0;
          if(  abs( getprop("instrumentation/nav[0]/gs-needle-deflection") ) < GLIDESLOPE_DEVIATION_LIMIT ) param = param + 1.0;
          if( param == 2.0 ) {
          setprop("tu154/instrumentation/pkp[0]/gliss-blanker", 0.0 );
          setprop("tu154/instrumentation/pnp[0]/gliss-blanker", 0.0 );
          }
          else {	
          setprop("tu154/instrumentation/pkp[0]/gliss-blanker", 1.0 );
          setprop("tu154/instrumentation/pnp[0]/gliss-blanker", 1.0 );
          }
	} # end mode == 4
	if( mode == 2 ) {
	# VOR-1
	if( getprop("instrumentation/nav[0]/in-range" ) == 1 )
		setprop("tu154/instrumentation/pnp[0]/kurs-blanker", 0.0 );
	else setprop("tu154/instrumentation/pnp[0]/kurs-blanker", 1.0 );
	setprop("tu154/instrumentation/pnp[0]/gliss-blanker", 1.0 );
	setprop("tu154/instrumentation/pkp[0]/kurs-blanker", 1.0 );
	setprop("tu154/instrumentation/pkp[0]/gliss-blanker", 1.0 );
	} # end mode == 2
	if( mode == 3 ) {
	# VOR-2
	if( getprop("instrumentation/nav[1]/in-range" ) == 1 )
		setprop("tu154/instrumentation/pnp[0]/kurs-blanker", 0.0 );
	else setprop("tu154/instrumentation/pnp[0]/kurs-blanker", 1.0 );
	setprop("tu154/instrumentation/pnp[0]/gliss-blanker", 1.0 );
	setprop("tu154/instrumentation/pkp[0]/kurs-blanker", 1.0 );
	setprop("tu154/instrumentation/pkp[0]/gliss-blanker", 1.0 );
	} # end mode == 3
	if( mode == 1 ) {
	# NVU
	if( getprop("tu154/instrumentation/pn-5/nvu" ) == 1 )
	    if( getprop("tu154/systems/nvu/powered" ) == 1 )
		setprop("tu154/instrumentation/pnp[0]/kurs-blanker", 0.0 );
	else setprop("tu154/instrumentation/pnp[0]/kurs-blanker", 1.0 );
	setprop("tu154/instrumentation/pnp[0]/gliss-blanker", 1.0 );
	setprop("tu154/instrumentation/pkp[0]/kurs-blanker", 1.0 );
	setprop("tu154/instrumentation/pkp[0]/gliss-blanker", 1.0 );
	} # end mode == 1
	if( mode == 0 ) {
	# Off-line
	setprop("tu154/instrumentation/pnp[0]/kurs-blanker", 1.0 );
	setprop("tu154/instrumentation/pnp[0]/gliss-blanker", 1.0 );
	setprop("tu154/instrumentation/pkp[0]/kurs-blanker", 1.0 );
	setprop("tu154/instrumentation/pkp[0]/gliss-blanker", 1.0 );
	} # end mode == 1
# --------------------------- second pilot -----------------------------------
	mode = get_mp_mode( 1 );
# ILS
	if( mode == 4 )
	{ # Heading
          param = 0.0;
          if( getprop("instrumentation/nav[0]/in-range" ) == 1 ) param = 1.0;
          if(  abs( getprop("instrumentation/nav[0]/heading-needle-deflection") ) < HEADING_DEVIATION_LIMIT ) param = param + 1.0;
          if( param == 2.0 ) {
                  setprop("tu154/instrumentation/pkp[1]/kurs-blanker", 0.0 );
                  setprop("tu154/instrumentation/pnp[1]/kurs-blanker", 0.0 );
	}
          else {	
          setprop("tu154/instrumentation/pkp[1]/kurs-blanker", 1.0 );
          setprop("tu154/instrumentation/pnp[1]/kurs-blanker", 1.0 );
	}
	# Glideslope
          param = 0.0;
          if( getprop("instrumentation/nav[0]/in-range" ) == 1 ) param = 1.0;
          if(  abs( getprop("instrumentation/nav[0]/gs-needle-deflection") ) < GLIDESLOPE_DEVIATION_LIMIT ) param = param + 1.0;
          if( param == 2.0 ) {
          setprop("tu154/instrumentation/pkp[1]/gliss-blanker", 0.0 );
          setprop("tu154/instrumentation/pnp[1]/gliss-blanker", 0.0 );
	}
          else {	
          setprop("tu154/instrumentation/pkp[1]/gliss-blanker", 1.0 );
          setprop("tu154/instrumentation/pnp[1]/gliss-blanker", 1.0 );
	}
	} # end mode == 4
	if( mode == 2 ) {
	# VOR-1
	if( getprop("instrumentation/nav[0]/in-range" ) == 1 )
		setprop("tu154/instrumentation/pnp[1]/kurs-blanker", 0.0 );
	else setprop("tu154/instrumentation/pnp[1]/kurs-blanker", 1.0 );
	setprop("tu154/instrumentation/pnp[1]/gliss-blanker", 1.0 );
	setprop("tu154/instrumentation/pkp[1]/kurs-blanker", 1.0 );
	setprop("tu154/instrumentation/pkp[1]/gliss-blanker", 1.0 );
	} # end mode == 2
	if( mode == 3 ) {
	# VOR-2
	if( getprop("instrumentation/nav[1]/in-range" ) == 1 )
		setprop("tu154/instrumentation/pnp[1]/kurs-blanker", 0.0 );
	else setprop("tu154/instrumentation/pnp[1]/kurs-blanker", 1.0 );
	setprop("tu154/instrumentation/pnp[1]/gliss-blanker", 1.0 );
	setprop("tu154/instrumentation/pkp[1]/kurs-blanker", 1.0 );
	setprop("tu154/instrumentation/pkp[1]/gliss-blanker", 1.0 );
	} # end mode == 3
	if( mode == 1 ) {
	# NVU
	if( getprop("tu154/instrumentation/pn-5/nvu" ) == 1 )
	    if( getprop("tu154/systems/nvu/powered" ) == 1 )
		setprop("tu154/instrumentation/pnp[1]/kurs-blanker", 0.0 );
	else setprop("tu154/instrumentation/pnp[1]/kurs-blanker", 1.0 );
	setprop("tu154/instrumentation/pnp[1]/gliss-blanker", 1.0 );
	setprop("tu154/instrumentation/pkp[1]/kurs-blanker", 1.0 );
	setprop("tu154/instrumentation/pkp[1]/gliss-blanker", 1.0 );
	} # end mode == 1
	if( mode == 0 ) {
	# Off-line
	setprop("tu154/instrumentation/pnp[1]/kurs-blanker", 1.0 );
	setprop("tu154/instrumentation/pnp[1]/gliss-blanker", 1.0 );
	setprop("tu154/instrumentation/pkp[1]/kurs-blanker", 1.0 );
	setprop("tu154/instrumentation/pkp[1]/gliss-blanker", 1.0 );
	} # end mode == 1
	
}


var get_mp_mode = func{
if( arg[0] == 0 ){ # captain pkp - pnp
        if( getprop("tu154/switches/pn-5-posadk") == 1.0)
        if( getprop("tu154/switches/pn-5-navigac" ) == 0.0 ) return 4; # ILS mode
        # VOR
        if( getprop("tu154/instrumentation/pn-5/az-1") == 1.0 ) return 2; # VOR-1
        if( getprop("tu154/instrumentation/pn-5/az-2") == 1.0 ) return 3; # VOR-2
        # NVU
        if( getprop("tu154/instrumentation/pn-5/nvu") == 1.0 ) return 1; # NVU
	return 0; # idle
	}
else {	# second pilot pkp-pnp
	var param = getprop("tu154/switches/pn-6-selector" );
	if( param == nil ) param = 0.0;
	return param;
	}
}

blanker_support();

#                           KURS-MP frequency support

var kursmp_sync = func{
var frequency = 0.0;
var heading = 0.0;
if( arg[0] == 0 )	# proceed captain panel
	{ #frequency
	var freq_hi = getprop("tu154/instrumentation/kurs-mp-1/digit-f-hi");
	if( freq_hi == nil ) return;
	var freq_low = getprop("tu154/instrumentation/kurs-mp-1/digit-f-low");
	if( freq_low == nil ) return;
	frequency = freq_hi + freq_low/100.0;
	setprop("instrumentation/nav[0]/frequencies/selected-mhz", frequency );
	# heading
	var hdg_ones = getprop("tu154/instrumentation/kurs-mp-1/digit-h-ones");
	if( hdg_ones == nil ) return;
	var hdg_dec = getprop("tu154/instrumentation/kurs-mp-1/digit-h-dec");
	if( hdg_dec == nil ) return;
	var hdg_hund = getprop("tu154/instrumentation/kurs-mp-1/digit-h-hund");
	if( hdg_hund == nil ) return;
	heading = hdg_hund * 100 + hdg_dec * 10 + hdg_ones;
	if( heading > 359.0 ) { 
		heading = 0.0;
                setprop("tu154/instrumentation/kurs-mp-1/digit-h-hund", 0.0 );
                setprop("tu154/instrumentation/kurs-mp-1/digit-h-dec", 0.0 );
                setprop("tu154/instrumentation/kurs-mp-1/digit-h-ones", 0.0 );
		}
	setprop("instrumentation/nav[0]/radials/selected-deg", heading );
	return;
	}
if( arg[0] == 1 ) # co-pilot
	{ #frequency
	var freq_hi = getprop("tu154/instrumentation/kurs-mp-2/digit-f-hi");
	if( freq_hi == nil ) return;
	var freq_low = getprop("tu154/instrumentation/kurs-mp-2/digit-f-low");
	if( freq_low == nil ) return;
	frequency = freq_hi + freq_low/100.0;
	setprop("instrumentation/nav[1]/frequencies/selected-mhz", frequency );
	# heading
	var hdg_ones = getprop("tu154/instrumentation/kurs-mp-2/digit-h-ones");
	if( hdg_ones == nil ) return;
	var hdg_dec = getprop("tu154/instrumentation/kurs-mp-2/digit-h-dec");
	if( hdg_dec == nil ) return;
	var hdg_hund = getprop("tu154/instrumentation/kurs-mp-2/digit-h-hund");
	if( hdg_hund == nil ) return;
	heading = hdg_hund * 100 + hdg_dec * 10 + hdg_ones;
		if( heading > 359.0 ) { 
		heading = 0.0;
                setprop("tu154/instrumentation/kurs-mp-2/digit-h-hund", 0.0 );
                setprop("tu154/instrumentation/kurs-mp-2/digit-h-dec", 0.0 );
                setprop("tu154/instrumentation/kurs-mp-2/digit-h-ones", 0.0 );
		}
	setprop("instrumentation/nav[1]/radials/selected-deg", heading );
	}
}

# initialize KURS-MP frequencies & headings
var kursmp_init = func{
var freq = getprop("instrumentation/nav[0]/frequencies/selected-mhz");
if( freq == nil ) { settimer( kursmp_init, 1.0 ); return; } # try until success
setprop("tu154/instrumentation/kurs-mp-1/digit-f-hi", int(freq) );
setprop("tu154/instrumentation/kurs-mp-1/digit-f-low", (freq - int(freq) ) * 100 );
var hdg = getprop("instrumentation/nav[0]/radials/selected-deg");
if( hdg == nil ) { settimer( kursmp_init, 1.0 ); return; }
setprop("tu154/instrumentation/kurs-mp-1/digit-h-hund", int(hdg/100) );
setprop("tu154/instrumentation/kurs-mp-1/digit-h-dec", int( (hdg/10.0)-int(hdg/100.0 )*10.0) );
setprop("tu154/instrumentation/kurs-mp-1/digit-h-ones", int(hdg-int(hdg/10.0 )*10.0) );
# second KURS-MP
freq = getprop("instrumentation/nav[1]/frequencies/selected-mhz");
if( freq == nil ) { settimer( kursmp_init, 1.0 ); return; } # try until success
setprop("tu154/instrumentation/kurs-mp-2/digit-f-hi", int(freq) );
setprop("tu154/instrumentation/kurs-mp-2/digit-f-low", (freq - int(freq) ) * 100 );
hdg = getprop("instrumentation/nav[1]/radials/selected-deg");
if( hdg == nil ) { settimer( kursmp_init, 1.0 ); return; }
setprop("tu154/instrumentation/kurs-mp-2/digit-h-hund", int( hdg/100) );
setprop("tu154/instrumentation/kurs-mp-2/digit-h-dec",int( ( hdg / 10.0 )-int( hdg / 100.0 ) * 10.0 ) );
setprop("tu154/instrumentation/kurs-mp-2/digit-h-ones", int( hdg-int( hdg/10.0 )* 10.0 ) );

}

var kursmp_watchdog_1 = func{
#settimer( kursmp_watchdog_1, 0.5 );
if( getprop("instrumentation/nav[0]/in-range" ) == 1 ) return;
 if( getprop("tu154/instrumentation/pn-5/gliss" ) == 1.0 ) absu.absu_reset();
 if( getprop("tu154/instrumentation/pn-5/az-1" ) == 1.0 ) absu.absu_reset();
 if( getprop("tu154/instrumentation/pn-5/zahod" ) == 1.0 ) absu.absu_reset();
}

var kursmp_watchdog_2 = func{
#settimer( kursmp_watchdog_2, 0.5 );
if( getprop("instrumentation/nav[1]/in-range" ) == 1 ) return;
if( getprop("tu154/instrumentation/pn-5/az-2" ) == 1.0 ) absu.absu_reset();
}

setlistener( "instrumentation/nav[0]/in-range", kursmp_watchdog_1, 0,0 );
setlistener( "instrumentation/nav[1]/in-range", kursmp_watchdog_2, 0,0 );

var kursmp_power_1 = func{
if( getprop( "tu154/switches/KURS-MP-1" ) == 1.0 )
	electrical.AC3x200_bus_1L.add_output( "KURS-MP-1", 20.0);
else electrical.AC3x200_bus_1L.rm_output( "KURS-MP-1" );		
}

var kursmp_power_2 = func{
if( getprop( "tu154/switches/KURS-MP-2" ) == 1.0 )
	electrical.AC3x200_bus_3R.add_output( "KURS-MP-2", 20.0);
else electrical.AC3x200_bus_3R.rm_output( "KURS-MP-2" );		
}

setlistener( "tu154/switches/KURS-MP-1", kursmp_power_1 ,0,0);
setlistener( "tu154/switches/KURS-MP-2", kursmp_power_2 ,0,0);
#kursmp_watchdog_1();
#kursmp_watchdog_2();
kursmp_init();

# ******************************** end KURS-MP *******************************
#                            NVU staff 
#*****************************************************************************
# digit wheels support for V-52
# meters
var nvu_handler = func {
settimer( nvu_handler, 0 );
if( getprop("tu154/systems/nvu/powered" ) == 0 ) return;	# offline now
var mode = 10.0; 
if( getprop("tu154/systems/nvu/mode" ) == 1 ) mode = 100.0;
#if( mode == nil ) mode = 1;
# ----------------- Aircraft S - 1 -----------------------------
var distance = getprop("fdm/jsbsim/instrumentation/aircraft-integrator-s-1");
if( distance == nil )  return; 
nvu_ldr_handler( distance, 0 );
distance = distance/mode; # to dec meters, it need for correct work of digit wheels
if( distance >= 0.0 ) { 
  setprop("tu154/instrumentation/v-52[0]/aircraft/s-plus-indicated-wheels_dec_m", 
  (distance/10.0) - int( distance/100.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/aircraft/s-plus-indicated-wheels_hund_m", 
  (distance/100.0) - int( distance/1000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/aircraft/s-plus-indicated-wheels_ths_m", 
  (distance/1000.0) - int( distance/10000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/aircraft/s-plus-indicated-wheels_decths_m", 
  (distance/10000.0) - int( distance/100000.0 )*10.0 );
	}
else {
  distance = abs( distance ); 
  setprop("tu154/instrumentation/v-52[0]/aircraft/s-minus-indicated-wheels_dec_m", 
  (distance/10.0) - int( distance/100.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/aircraft/s-minus-indicated-wheels_hund_m", 
  (distance/100.0) - int( distance/1000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/aircraft/s-minus-indicated-wheels_ths_m", 
  (distance/1000.0) - int( distance/10000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/aircraft/s-minus-indicated-wheels_decths_m", 
  (distance/10000.0) - int( distance/100000.0 )*10.0 );
	}
# ----------------- Aircraft Z - 1 -----------------------------
distance = getprop("fdm/jsbsim/instrumentation/aircraft-integrator-z-1");
if( distance == nil )  return; 
nvu_ldr_handler( distance, 1 );
distance = distance/mode; # to dec meters, it need for correct work of digit wheels
if( distance >= 0.0 ) { 
  setprop("tu154/instrumentation/v-52[0]/aircraft/z-plus-indicated-wheels_dec_m", 
  (distance/10.0) - int( distance/100.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/aircraft/z-plus-indicated-wheels_hund_m", 
  (distance/100.0) - int( distance/1000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/aircraft/z-plus-indicated-wheels_ths_m", 
  (distance/1000.0) - int( distance/10000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/aircraft/z-plus-indicated-wheels_decths_m", 
  (distance/10000.0) - int( distance/100000.0 )*10.0 );
	}
else { 
  distance = abs( distance );
  setprop("tu154/instrumentation/v-52[0]/aircraft/z-minus-indicated-wheels_dec_m", 
  (distance/10.0) - int( distance/100.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/aircraft/z-minus-indicated-wheels_hund_m", 
  (distance/100.0) - int( distance/1000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/aircraft/z-minus-indicated-wheels_ths_m", 
  (distance/1000.0) - int( distance/10000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/aircraft/z-minus-indicated-wheels_decths_m", 
  (distance/10000.0) - int( distance/100000.0 )*10.0 );
	}
# ----------------- Point S - 1 -----------------------------
distance = getprop("fdm/jsbsim/instrumentation/point-integrator-s-1");
if( distance == nil )  return; 
nvu_ldr_handler( distance, 2 );
distance = distance/mode; # to dec meters, it need for correct work of digit wheels
if( distance >= 0.0 ) { 
  setprop("tu154/instrumentation/v-52[0]/point/s-plus-indicated-wheels_dec_m", 
  (distance/10.0) - int( distance/100.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/point/s-plus-indicated-wheels_hund_m", 
  (distance/100.0) - int( distance/1000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/point/s-plus-indicated-wheels_ths_m", 
  (distance/1000.0) - int( distance/10000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/point/s-plus-indicated-wheels_decths_m", 
  (distance/10000.0) - int( distance/100000.0 )*10.0 );
}
else {
  distance = abs( distance ); 
  setprop("tu154/instrumentation/v-52[0]/point/s-minus-indicated-wheels_dec_m", 
  (distance/10.0) - int( distance/100.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/point/s-minus-indicated-wheels_hund_m", 
  (distance/100.0) - int( distance/1000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/point/s-minus-indicated-wheels_ths_m", 
  (distance/1000.0) - int( distance/10000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/point/s-minus-indicated-wheels_decths_m", 
  (distance/10000.0) - int( distance/100000.0 )*10.0 );
	}
# ----------------- Point Z - 1 -----------------------------
distance = getprop("fdm/jsbsim/instrumentation/point-integrator-z-1");
if( distance == nil )  return; 
nvu_ldr_handler( distance, 3 );
distance = distance/mode; # to dec meters, it need for correct work of digit wheels
if( distance >= 0.0 ) { 
  setprop("tu154/instrumentation/v-52[0]/point/z-plus-indicated-wheels_dec_m", 
  (distance/10.0) - int( distance/100.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/point/z-plus-indicated-wheels_hund_m", 
  (distance/100.0) - int( distance/1000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/point/z-plus-indicated-wheels_ths_m", 
  (distance/1000.0) - int( distance/10000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/point/z-plus-indicated-wheels_decths_m", 
  (distance/10000.0) - int( distance/100000.0 )*10.0 );
	}
else { 
  distance = abs( distance );
  setprop("tu154/instrumentation/v-52[0]/point/z-minus-indicated-wheels_dec_m", 
  (distance/10.0) - int( distance/100.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/point/z-minus-indicated-wheels_hund_m", 
  (distance/100.0) - int( distance/1000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/point/z-minus-indicated-wheels_ths_m", 
  (distance/1000.0) - int( distance/10000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[0]/point/z-minus-indicated-wheels_decths_m", 
  (distance/10000.0) - int( distance/100000.0 )*10.0 );
	}
# V-52-2
# ---------------- Aircraft - S -2 -------------------------------------
distance = getprop("fdm/jsbsim/instrumentation/aircraft-integrator-s-2");
if( distance == nil )  return; 
nvu_ldr_handler( distance, 4 );
distance = distance/mode; # to dec meters, it need for correct work of digit wheels
if( distance >= 0.0 ) { 
  setprop("tu154/instrumentation/v-52[1]/aircraft/s-plus-indicated-wheels_dec_m", 
  (distance/10.0) - int( distance/100.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/aircraft/s-plus-indicated-wheels_hund_m", 
  (distance/100.0) - int( distance/1000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/aircraft/s-plus-indicated-wheels_ths_m", 
  (distance/1000.0) - int( distance/10000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/aircraft/s-plus-indicated-wheels_decths_m", 
  (distance/10000.0) - int( distance/100000.0 )*10.0 );
	}
else {
  distance = abs( distance ); 
  setprop("tu154/instrumentation/v-52[1]/aircraft/s-minus-indicated-wheels_dec_m", 
  (distance/10.0) - int( distance/100.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/aircraft/s-minus-indicated-wheels_hund_m", 
  (distance/100.0) - int( distance/1000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/aircraft/s-minus-indicated-wheels_ths_m", 
  (distance/1000.0) - int( distance/10000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/aircraft/s-minus-indicated-wheels_decths_m", 
  (distance/10000.0) - int( distance/100000.0 )*10.0 );
	}
# ----------------- Aircraft Z - 2 -----------------------------
distance = getprop("fdm/jsbsim/instrumentation/aircraft-integrator-z-2");
if( distance == nil )  return; 
nvu_ldr_handler( distance, 5 );
distance = distance/mode; # to dec meters, it need for correct work of digit wheels
if( distance >= 0.0 ) { 
  setprop("tu154/instrumentation/v-52[1]/aircraft/z-plus-indicated-wheels_dec_m", 
  (distance/10.0) - int( distance/100.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/aircraft/z-plus-indicated-wheels_hund_m", 
  (distance/100.0) - int( distance/1000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/aircraft/z-plus-indicated-wheels_ths_m", 
  (distance/1000.0) - int( distance/10000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/aircraft/z-plus-indicated-wheels_decths_m", 
  (distance/10000.0) - int( distance/100000.0 )*10.0 );
}
else { 
  distance = abs( distance );
  setprop("tu154/instrumentation/v-52[1]/aircraft/z-minus-indicated-wheels_dec_m", 
  (distance/10.0) - int( distance/100.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/aircraft/z-minus-indicated-wheels_hund_m", 
  (distance/100.0) - int( distance/1000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/aircraft/z-minus-indicated-wheels_ths_m", 
  (distance/1000.0) - int( distance/10000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/aircraft/z-minus-indicated-wheels_decths_m", 
  (distance/10000.0) - int( distance/100000.0 )*10.0 );
	}
# ----------------- Point S - 2 -----------------------------
distance = getprop("fdm/jsbsim/instrumentation/point-integrator-s-2");
if( distance == nil )  return; 
nvu_ldr_handler( distance, 6 );
distance = distance/mode; # to dec meters, it need for correct work of digit wheels
if( distance >= 0.0 ) { 
  setprop("tu154/instrumentation/v-52[1]/point/s-plus-indicated-wheels_dec_m", 
  (distance/10.0) - int( distance/100.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/point/s-plus-indicated-wheels_hund_m", 
  (distance/100.0) - int( distance/1000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/point/s-plus-indicated-wheels_ths_m", 
  (distance/1000.0) - int( distance/10000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/point/s-plus-indicated-wheels_decths_m", 
  (distance/10000.0) - int( distance/100000.0 )*10.0 );
	}
else {
  distance = abs( distance ); 
  setprop("tu154/instrumentation/v-52[1]/point/s-minus-indicated-wheels_dec_m", 
  (distance/10.0) - int( distance/100.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/point/s-minus-indicated-wheels_hund_m", 
  (distance/100.0) - int( distance/1000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/point/s-minus-indicated-wheels_ths_m", 
  (distance/1000.0) - int( distance/10000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/point/s-minus-indicated-wheels_decths_m", 
  (distance/10000.0) - int( distance/100000.0 )*10.0 );
	}
# ----------------- Point Z - 2 -----------------------------
distance = getprop("fdm/jsbsim/instrumentation/point-integrator-z-2");
if( distance == nil )  return; 
nvu_ldr_handler( distance, 7 );
distance = distance/mode; # to dec meters, it need for correct work of digit wheels
if( distance >= 0.0 ) { 
  setprop("tu154/instrumentation/v-52[1]/point/z-plus-indicated-wheels_dec_m", 
  (distance/10.0) - int( distance/100.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/point/z-plus-indicated-wheels_hund_m", 
  (distance/100.0) - int( distance/1000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/point/z-plus-indicated-wheels_ths_m", 
  (distance/1000.0) - int( distance/10000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/point/z-plus-indicated-wheels_decths_m", 
  (distance/10000.0) - int( distance/100000.0 )*10.0 );
	}
else { 
  distance = abs( distance );
  setprop("tu154/instrumentation/v-52[1]/point/z-minus-indicated-wheels_dec_m", 
  (distance/10.0) - int( distance/100.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/point/z-minus-indicated-wheels_hund_m", 
  (distance/100.0) - int( distance/1000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/point/z-minus-indicated-wheels_ths_m", 
  (distance/1000.0) - int( distance/10000.0 )*10.0 );
  setprop("tu154/instrumentation/v-52[1]/point/z-minus-indicated-wheels_decths_m", 
  (distance/10000.0) - int( distance/100000.0 )*10.0 );
	}

# Wind direction	
var wind_deg = getprop("environment/wind-from-heading-deg");
if( wind_deg == nil )  return;
  wind_deg = wind_deg + 180.0; # wind-to
  
var tks_heading = getprop("fdm/jsbsim/instrumentation/tks-heading");
if( tks_heading == nil )  return;

var fork = getprop("tu154/instrumentation/v-57[0]/fork-deg");
if( fork == nil )  return;

var true_heading = getprop("fdm/jsbsim/attitude/heading-true-rad");
if( true_heading == nil )  return;
    true_heading = true_heading * 57.2958; # to deg
    
    wind_deg = wind_deg + fork + true_heading - tks_heading;    
    
  if( wind_deg >= 360.0 ) wind_deg = wind_deg - 360.0;
  if( wind_deg <= 0.0 ) wind_deg = wind_deg + 360.0;
  
var wind_speed = getprop("environment/wind-speed-kt");
if( wind_speed == nil )  return;
    wind_speed = wind_speed * 1.852; # to kmh
  
  setprop("tu154/instrumentation/v-57[0]/direction/indicated-wheels_ones", 
  (wind_deg) - int( wind_deg/10.0 )*10.0 );
  setprop("tu154/instrumentation/v-57[0]/direction/indicated-wheels_dec", 
  (wind_deg/10.0) - int( wind_deg/100.0 )*10.0 );
  setprop("tu154/instrumentation/v-57[0]/direction/indicated-wheels_hund", 
  (wind_deg/100.0) - int( wind_deg/1000.0 )*10.0 );

  setprop("tu154/instrumentation/v-57[0]/speed/indicated-wheels_ones", 
  (wind_speed) - int( wind_speed/10.0 )*10.0 );
  setprop("tu154/instrumentation/v-57[0]/speed/indicated-wheels_dec", 
  (wind_speed/10.0) - int( wind_speed/100.0 )*10.0 );
  setprop("tu154/instrumentation/v-57[0]/speed/indicated-wheels_hund", 
  (wind_speed/100.0) - int( wind_speed/1000.0 )*10.0 );

  if( fork >= 0.0 ){
  setprop("tu154/instrumentation/v-57[0]/fork/indicated-wheels_ones", 
  (fork) - int( fork/10.0 )*10.0 );
  setprop("tu154/instrumentation/v-57[0]/fork/indicated-wheels_dec", 
  (fork/10.0) - int( fork/100.0 )*10.0 );
  }
  if( fork <= 0.0 ){
  fork = abs( fork );
  setprop("tu154/instrumentation/v-57[0]/fork/minus-indicated-wheels_ones", 
  (fork) - int( fork/10.0 )*10.0 );
  setprop("tu154/instrumentation/v-57[0]/fork/minus-indicated-wheels_dec", 
  (fork/10.0) - int( fork/100.0 )*10.0 );
  }

}

settimer( nvu_handler, 0 );

# controls for NVU

var nvu_set_d = func{
if( getprop("tu154/systems/nvu/powered" ) == 0 ) return;	# offline now
if( getprop("tu154/systems/nvu/serviceable" ) == 0 ) return;	# inop now
var rotate_speed = 2000.0;
var multiplier = getprop("tu154/systems/nvu/mult-1" );
if( multiplier == nil ) return;
if( getprop("tu154/systems/nvu/selector" ) == 0 )
	{

	#	Aircraft
	if( getprop("tu154/switches/v-51-selector-1" ) == 0 )
	     setprop("fdm/jsbsim/instrumentation/a-input-z-2", arg[0]*multiplier*rotate_speed );
	    
	if( getprop("tu154/switches/v-51-selector-1" ) == 1 )
	     setprop("fdm/jsbsim/instrumentation/a-input-s-2", arg[0]*multiplier*rotate_speed );
	#	Beacon
	if( getprop("tu154/switches/v-51-selector-1" ) == 2 )
	     setprop("fdm/jsbsim/instrumentation/p-input-z-2", arg[0]*multiplier*rotate_speed );
	    
	if( getprop("tu154/switches/v-51-selector-1" ) == 3 )
	     setprop("fdm/jsbsim/instrumentation/p-input-s-2", arg[0]*multiplier*rotate_speed );
	# 	Point
	if( getprop("tu154/switches/v-51-selector-1" ) == 5 )
	     setprop("fdm/jsbsim/instrumentation/p-input-s-1", arg[0]*multiplier*rotate_speed );
	    
	if( getprop("tu154/switches/v-51-selector-1" ) == 6 )
	     setprop("fdm/jsbsim/instrumentation/p-input-z-1", arg[0]*multiplier*rotate_speed );
	#	Aircraft
	if( getprop("tu154/switches/v-51-selector-1" ) == 7 )
	     setprop("fdm/jsbsim/instrumentation/a-input-s-2", arg[0]*multiplier*rotate_speed );
	    
	if( getprop("tu154/switches/v-51-selector-1" ) == 8 )
	     setprop("fdm/jsbsim/instrumentation/a-input-z-2", arg[0]*multiplier*rotate_speed );
	}
if( getprop("tu154/systems/nvu/selector" ) == 1 )
	{
	#	Aircraft
	if( getprop("tu154/switches/v-51-selector-1" ) == 0 )
	     setprop("fdm/jsbsim/instrumentation/a-input-z-1", arg[0]*multiplier*rotate_speed );
	    
	if( getprop("tu154/switches/v-51-selector-1" ) == 1 )
	     setprop("fdm/jsbsim/instrumentation/a-input-s-1", arg[0]*multiplier*rotate_speed );
	#	Beacon
	if( getprop("tu154/switches/v-51-selector-1" ) == 2 )
	     setprop("fdm/jsbsim/instrumentation/p-input-z-1", arg[0]*multiplier*rotate_speed );
	    
	if( getprop("tu154/switches/v-51-selector-1" ) == 3 )
	     setprop("fdm/jsbsim/instrumentation/p-input-s-1", arg[0]*multiplier*rotate_speed );
	# 	Point
	if( getprop("tu154/switches/v-51-selector-1" ) == 5 )
	     setprop("fdm/jsbsim/instrumentation/p-input-s-2", arg[0]*multiplier*rotate_speed );
	    
	if( getprop("tu154/switches/v-51-selector-1" ) == 6 )
	     setprop("fdm/jsbsim/instrumentation/p-input-z-2", arg[0]*multiplier*rotate_speed );
	#	Aircraft
	if( getprop("tu154/switches/v-51-selector-1" ) == 7 )
	     setprop("fdm/jsbsim/instrumentation/a-input-s-1", arg[0]*multiplier*rotate_speed );
	    
	if( getprop("tu154/switches/v-51-selector-1" ) == 8 )
	     setprop("fdm/jsbsim/instrumentation/a-input-z-1", arg[0]*multiplier*rotate_speed );
	}

}


var zpu_1_handler = func{
var zpu = getprop("tu154/instrumentation/v-140[0]/zpu-1-delayed" );
if( zpu == nil )return; 
setprop("tu154/instrumentation/v-140[0]/I/min", zpu*10 );
setprop("tu154/instrumentation/v-140[0]/I/ones", zpu - int( zpu/10.0 )*10.0 );
setprop("tu154/instrumentation/v-140[0]/I/dec", 
(zpu/10.0) - int( zpu/100.0 )*10.0 );
setprop("tu154/instrumentation/v-140[0]/I/hund", 
(zpu/100.0) - int( zpu/1000.0 )*10.0 );
}

var zpu_2_handler = func{
var zpu = getprop("tu154/instrumentation/v-140[0]/zpu-2-delayed" );
if( zpu == nil )return; 
setprop("tu154/instrumentation/v-140[0]/II/min", zpu*10 );
setprop("tu154/instrumentation/v-140[0]/II/ones", zpu - int( zpu/10.0 )*10.0 );
setprop("tu154/instrumentation/v-140[0]/II/dec", 
(zpu/10.0) - int( zpu/100.0 )*10.0 );
setprop("tu154/instrumentation/v-140[0]/II/hund", 
(zpu/100.0) - int( zpu/1000.0 )*10.0 );
}

# helper
var min2dec = func{
var integer = int( arg[0] );
var min = arg[0] - integer;
return integer + min/0.6;
}

# Proceed fork
var fork_loader = func{

var fork_flag = getprop( "/tu154/systems/nvu-calc/fork-flag" );
if( fork_flag == nil ) fork_flag = 0;
var fork = getprop( "/tu154/systems/nvu-calc/fork" );
if( fork == nil ) fork = 0.0;

if( !fork_flag ) {	# Apply fork
	var offset = getprop("instrumentation/heading-indicator[0]/offset-deg");
	if( offset == nil ) offset = 0.0;
	offset += fork;
	setprop("instrumentation/heading-indicator[0]/offset-deg", offset );
	offset = getprop("instrumentation/heading-indicator[1]/offset-deg");
	if( offset == nil ) offset = 0.0;
	offset += fork;
	setprop("instrumentation/heading-indicator[1]/offset-deg", offset );
	# re-write ZPU
	var zpu = getprop("fdm/jsbsim/instrumentation/zpu-deg-1" );
	if( zpu == nil ) zpu = 0.0;
	zpu += fork;
     	setprop("fdm/jsbsim/instrumentation/zpu-deg-1", zpu );
     	interpolate("tu154/instrumentation/v-140[0]/zpu-1-delayed", zpu, 1.0 );
	zpu = getprop("fdm/jsbsim/instrumentation/zpu-deg-2" );
	if( zpu == nil ) zpu = 0.0;
	zpu += fork;
     	setprop("fdm/jsbsim/instrumentation/zpu-deg-2", zpu );
     	interpolate("tu154/instrumentation/v-140[0]/zpu-2-delayed", zpu, 1.0 );
	setprop( "/tu154/systems/nvu-calc/fork-flag", 1 );
	}
else {	# Revert fork
	var offset = getprop("instrumentation/heading-indicator[0]/offset-deg");
	if( offset == nil ) offset = 0.0;
	offset -= fork;
	setprop("instrumentation/heading-indicator[0]/offset-deg", offset );
	offset = getprop("instrumentation/heading-indicator[1]/offset-deg");
	if( offset == nil ) offset = 0.0;
	offset -= fork;
	setprop("instrumentation/heading-indicator[1]/offset-deg", offset );
	# re-write ZPU
	var zpu = getprop("fdm/jsbsim/instrumentation/zpu-deg-1" );
	if( zpu == nil ) zpu = 0.0;
	zpu -= fork;
     	setprop("fdm/jsbsim/instrumentation/zpu-deg-1", zpu );
     	interpolate("tu154/instrumentation/v-140[0]/zpu-1-delayed", zpu, 1.0 );
	zpu = getprop("fdm/jsbsim/instrumentation/zpu-deg-2" );
	if( zpu == nil ) zpu = 0.0;
	zpu -= fork;
     	setprop("fdm/jsbsim/instrumentation/zpu-deg-2", zpu );
     	interpolate("tu154/instrumentation/v-140[0]/zpu-2-delayed", zpu, 1.0 );

	setprop( "/tu154/systems/nvu-calc/fork-flag", 0 );
	}

}

#Virtual navigator
var virtual_navigator = func{
var route_num = getprop("/tu154/systems/nvu-calc/route-selected");
if( route_num == nil ) route_num = 0;

# Get route and max route number
var route_list = props.globals.getNode("/sim/gui/dialogs/Tu-154B-2/nav/dialog/list", 1);
var route = route_list.getChildren("value");
var max_route = size( route );

# Select new route
if( route_num >= max_route ) return; # end of route list ashieved
help.messenger(sprintf("Virtual navigator: next route %s", route[route_num].getValue() ));
# Save result
setprop( "/tu154/systems/nvu-calc/list", route[route_num].getValue() );
# Loader into NVU
#nvu_load() will be invoke from listener 

}

# loader for S, ZPU, etc from nav calc to NVU
# Aug 2009
var nvu_load = func{
# Get input parameters - first route
var input_string = getprop( "/tu154/systems/nvu-calc/list" );
var vect = split( " ", input_string );
# save number of selected route
setprop("/tu154/systems/nvu-calc/route-selected",num(substr(vect[0], 0, size(vect[0])-1)));
#print("Get:", input_string );

#print("S:", num(vect[5]), " Z:", num(substr(vect[8], 0, size(vect[8])-1)  ) );
#forindex( var i; vect ){
#print(i, "->", vect[i])
#}

var distance_selected = num(vect[5]) * 1000.0;
var zpu_dep_selected = min2dec(num(substr(vect[8], 0, size(vect[8])-1)));
var zpu_dest_selected = min2dec(num(substr(vect[10], 0, size(vect[10])-1)));

# load last beacon parameter
var sm_selected = getprop( "/tu154/systems/nvu-calc/sm-next" );
var zm_selected = getprop( "/tu154/systems/nvu-calc/zm-next" );
var uk_selected = getprop( "/tu154/systems/nvu-calc/uk-next" );

var sm = props.globals.getNode("/tu154/systems/nvu-calc/sm-next", 1);
var zm = props.globals.getNode("/tu154/systems/nvu-calc/zm-next", 1);
var uk = props.globals.getNode("/tu154/systems/nvu-calc/uk-next", 1);

# save current beacon - it will be load into NVU next time
if( size(vect) > 13 ) {
setprop( "/tu154/systems/nvu-calc/sm-next", num(vect[13]) * 1000.0 );
setprop( "/tu154/systems/nvu-calc/zm-next", num(vect[16]) * 1000.0 );
setprop( "/tu154/systems/nvu-calc/uk-next", num(substr(vect[19], 0, size(vect[19])-1)) );
			}
else	{
sm.remove();
zm.remove();
uk.remove();
}

# get next route if present

# Get route and max route number
var route_num = getprop("/tu154/systems/nvu-calc/route-selected");
if( route_num == nil ) route_num = 0;

var route_list = props.globals.getNode("/sim/gui/dialogs/Tu-154B-2/nav/dialog/list", 1);
var route = route_list.getChildren("value");
var max_route = size( route );
var count = getprop("fdm/jsbsim/instrumentation/enable-count");
if( count == nil ) count = 0;

# Select new route
route_num += 1;
var have_next = 0;	# double loading flag
if( (max_route >= route_num) and (count == 0) ) {
	# increment route number - only for double loading
	setprop("/tu154/systems/nvu-calc/route-selected", route_num);
	have_next = 1;
	input_string = route[route_num-1].getValue();
	vect = split( " ", input_string );
	var distance_selected_next = num(vect[5]) * 1000.0;
	var zpu_dep_selected_next = min2dec(num(substr(vect[8], 0, size(vect[8])-1)));
	var zpu_dest_selected_next = min2dec(num(substr(vect[10], 0, size(vect[10])-1)));
	# Beacon parameters overwritten if presents!
	if( size(vect) > 13 ) {
	setprop( "/tu154/systems/nvu-calc/sm-next", num(vect[13]) * 1000.0 );
	setprop( "/tu154/systems/nvu-calc/zm-next", num(vect[16]) * 1000.0 );
	setprop( "/tu154/systems/nvu-calc/uk-next", num(substr(vect[19], 0, size(vect[19])-1)) );
		}

	}

var dist_current = 0.0;
var gradient = 0.0;

var selector = getprop("tu154/systems/nvu/selector" );
if( selector == nil ) selector = 0;
var fork_flag = getprop( "/tu154/systems/nvu-calc/fork-flag" );
if( fork_flag == nil ) fork_flag = 0;
# We use departure OZPU obviosly.
# If fork applied, operate with destination OZPU instead
if( fork_flag ) var zpu_selected = zpu_dest_selected;
else var zpu_selected = zpu_dep_selected;



if( have_next ){
	if( fork_flag ) var zpu_selected_next = zpu_dest_selected_next;
	else var zpu_selected_next = zpu_dep_selected_next;
}
# ------------------ NVU LOADER ---------------------

# select 
if( selector ) {	# First b-52 block active
	if( count )  {  # count enabled
		#Load Point - S - 2
	dist_current = getprop("fdm/jsbsim/instrumentation/point-integrator-s-2");
	if( dist_current == nil )  dist_current = 0.0;
	gradient = distance_selected - dist_current;
	setprop("fdm/jsbsim/instrumentation/p-input-s-2", gradient );
	setprop("/tu154/systems/nvu-calc/nvu-loader/selected-ps2", distance_selected );
	if( gradient > 0 ) setprop("/tu154/systems/nvu-calc/nvu-loader/mode-ps2", 1 );
	else setprop("/tu154/systems/nvu-calc/nvu-loader/mode-ps2", 2 );
		#Clear Point - Z - 2	
	distance_selected = 0.0;
	dist_current = getprop("fdm/jsbsim/instrumentation/point-integrator-z-2");
	if( dist_current == nil )  dist_current = 0.0;
	gradient = distance_selected - dist_current;
	setprop("fdm/jsbsim/instrumentation/p-input-z-2", gradient );
	setprop("/tu154/systems/nvu-calc/nvu-loader/selected-pz2", distance_selected );
	if( gradient > 0 ) setprop("/tu154/systems/nvu-calc/nvu-loader/mode-pz2", 1 );
	else setprop("/tu154/systems/nvu-calc/nvu-loader/mode-pz2", 2 );
		#Load ZPU-2
     	setprop("fdm/jsbsim/instrumentation/zpu-deg-2", zpu_selected );
     	interpolate("tu154/instrumentation/v-140[0]/zpu-2-delayed", zpu_selected, 1.0 );
	}
	else {		# count disabled
		#Load Aircraft - S - 1
	dist_current = getprop("fdm/jsbsim/instrumentation/aircraft-integrator-s-1");
	if( dist_current == nil )  dist_current = 0.0;
	gradient = distance_selected - dist_current;
	setprop("fdm/jsbsim/instrumentation/a-input-s-1", gradient );
	setprop("/tu154/systems/nvu-calc/nvu-loader/selected-as1", distance_selected );
	if( gradient > 0 ) setprop("/tu154/systems/nvu-calc/nvu-loader/mode-as1", 1 );
	else setprop("/tu154/systems/nvu-calc/nvu-loader/mode-as1", 2 );
		#Clear Aircraft - Z - 1
	distance_selected = 0.0;
	dist_current = getprop("fdm/jsbsim/instrumentation/aircraft-integrator-z-1");
	if( dist_current == nil )  dist_current = 0.0;
	gradient = distance_selected - dist_current;
	setprop("fdm/jsbsim/instrumentation/a-input-z-1", gradient );
	setprop("/tu154/systems/nvu-calc/nvu-loader/selected-az1", distance_selected );
	if( gradient > 0 ) setprop("/tu154/systems/nvu-calc/nvu-loader/mode-az1", 1 );
	else setprop("/tu154/systems/nvu-calc/nvu-loader/mode-az1", 2 );
		#Load ZPU-1
     	setprop("fdm/jsbsim/instrumentation/zpu-deg-1", zpu_selected );
     	interpolate("tu154/instrumentation/v-140[0]/zpu-1-delayed", zpu_selected, 1.0 );
	# Load next block if there is a next route
	if( have_next ){
			#Load Point - S - 2
		dist_current = getprop("fdm/jsbsim/instrumentation/point-integrator-s-2");
		if( dist_current == nil )  dist_current = 0.0;
		gradient = distance_selected_next - dist_current;
		setprop("fdm/jsbsim/instrumentation/p-input-s-2", gradient );
		setprop("/tu154/systems/nvu-calc/nvu-loader/selected-ps2", distance_selected_next );
		if( gradient > 0 ) setprop("/tu154/systems/nvu-calc/nvu-loader/mode-ps2", 1 );
		else setprop("/tu154/systems/nvu-calc/nvu-loader/mode-ps2", 2 );
		#Clear Point - Z - 2
		distance_selected_next = 0.0;
		dist_current = getprop("fdm/jsbsim/instrumentation/point-integrator-z-2");
		if( dist_current == nil )  dist_current = 0.0;
		gradient = distance_selected_next - dist_current;
		setprop("fdm/jsbsim/instrumentation/p-input-z-2", gradient );
		setprop("/tu154/systems/nvu-calc/nvu-loader/selected-pz2", distance_selected );
		if( gradient > 0 ) setprop("/tu154/systems/nvu-calc/nvu-loader/mode-pz2", 1 );
		else setprop("/tu154/systems/nvu-calc/nvu-loader/mode-pz2", 2 );
			#Load ZPU-2
		setprop("fdm/jsbsim/instrumentation/zpu-deg-2", zpu_selected_next );
		interpolate("tu154/instrumentation/v-140[0]/zpu-2-delayed", zpu_selected_next, 1.0 );
		}
	}
	if( sm_selected != nil ) {	# load beacon
		#Load Point - S - 1
	dist_current = getprop("fdm/jsbsim/instrumentation/point-integrator-s-1");
	if( dist_current == nil )  dist_current = 0.0;
	gradient = sm_selected - dist_current;
	setprop("fdm/jsbsim/instrumentation/p-input-s-1", gradient );
	setprop("/tu154/systems/nvu-calc/nvu-loader/selected-ps1", sm_selected );
	if( gradient > 0 ) setprop("/tu154/systems/nvu-calc/nvu-loader/mode-ps1", 1 );
	else setprop("/tu154/systems/nvu-calc/nvu-loader/mode-ps1", 2 );
		#Load Point - Z - 1
	dist_current = getprop("fdm/jsbsim/instrumentation/point-integrator-z-1");
	if( dist_current == nil )  dist_current = 0.0;
	gradient = zm_selected - dist_current;
	setprop("fdm/jsbsim/instrumentation/p-input-z-1", gradient );
	setprop("/tu154/systems/nvu-calc/nvu-loader/selected-pz1", zm_selected );
	if( gradient > 0 ) setprop("/tu154/systems/nvu-calc/nvu-loader/mode-pz1", 1 );
	else setprop("/tu154/systems/nvu-calc/nvu-loader/mode-pz1", 2 );
	}
}
else {			# Second b-52 block
	if( count )  {  # count enabled
		#Load Point - S - 1
	dist_current = getprop("fdm/jsbsim/instrumentation/point-integrator-s-1");
	if( dist_current == nil )  dist_current = 0.0;
	gradient = distance_selected - dist_current;
	setprop("fdm/jsbsim/instrumentation/p-input-s-1", gradient );
	setprop("/tu154/systems/nvu-calc/nvu-loader/selected-ps1", distance_selected );
	if( gradient > 0 ) setprop("/tu154/systems/nvu-calc/nvu-loader/mode-ps1", 1 );
	else setprop("/tu154/systems/nvu-calc/nvu-loader/mode-ps1", 2 );
		#Clear Point - Z - 1
	distance_selected = 0.0;
	dist_current = getprop("fdm/jsbsim/instrumentation/point-integrator-z-1");
	if( dist_current == nil )  dist_current = 0.0;
	gradient = distance_selected - dist_current;
	setprop("fdm/jsbsim/instrumentation/p-input-z-1", gradient );
	setprop("/tu154/systems/nvu-calc/nvu-loader/selected-pz1", distance_selected );
	if( gradient > 0 ) setprop("/tu154/systems/nvu-calc/nvu-loader/mode-pz1", 1 );
	else setprop("/tu154/systems/nvu-calc/nvu-loader/mode-pz1", 2 );
		#Load ZPU-1
     	setprop("fdm/jsbsim/instrumentation/zpu-deg-1", zpu_selected );
     	interpolate("tu154/instrumentation/v-140[0]/zpu-1-delayed", zpu_selected, 1.0 );
		}
	else {		# count disabled
		#Load Aircraft - S - 2
	dist_current = getprop("fdm/jsbsim/instrumentation/aircraft-integrator-s-2");
	if( dist_current == nil )  dist_current = 0.0;
	gradient = distance_selected - dist_current;
	setprop("fdm/jsbsim/instrumentation/a-input-s-2", gradient );
	setprop("/tu154/systems/nvu-calc/nvu-loader/selected-as2", distance_selected );
	if( gradient > 0 ) setprop("/tu154/systems/nvu-calc/nvu-loader/mode-as2", 1 );
	else setprop("/tu154/systems/nvu-calc/nvu-loader/mode-as2", 2 );
		#Clear Aircraft - Z - 2
	distance_selected = 0.0;
	dist_current = getprop("fdm/jsbsim/instrumentation/aircraft-integrator-z-2");
	if( dist_current == nil )  dist_current = 0.0;
	gradient = distance_selected - dist_current;
	setprop("fdm/jsbsim/instrumentation/a-input-z-2", gradient );
	setprop("/tu154/systems/nvu-calc/nvu-loader/selected-az2", distance_selected );
	if( gradient > 0 ) setprop("/tu154/systems/nvu-calc/nvu-loader/mode-az2", 1 );
	else setprop("/tu154/systems/nvu-calc/nvu-loader/mode-az2", 2 );
		#Load ZPU-2
     	setprop("fdm/jsbsim/instrumentation/zpu-deg-2", zpu_selected );
     	interpolate("tu154/instrumentation/v-140[0]/zpu-2-delayed", zpu_selected, 1.0 );
	# Load next block if there is a next route
	if( have_next ){
			#Load Point - S - 1
		dist_current = getprop("fdm/jsbsim/instrumentation/point-integrator-s-1");
		if( dist_current == nil )  dist_current = 0.0;
		gradient = distance_selected_next - dist_current;
		setprop("fdm/jsbsim/instrumentation/p-input-s-1", gradient );
		setprop("/tu154/systems/nvu-calc/nvu-loader/selected-ps1", distance_selected_next );
		if( gradient > 0 ) setprop("/tu154/systems/nvu-calc/nvu-loader/mode-ps1", 1 );
		else setprop("/tu154/systems/nvu-calc/nvu-loader/mode-ps1", 2 );
			#Clear Point - Z - 1
		#distance_selected_next = 0.0;
		dist_current = getprop("fdm/jsbsim/instrumentation/point-integrator-z-1");
		if( dist_current == nil )  dist_current = 0.0;
		gradient = - dist_current;
		setprop("fdm/jsbsim/instrumentation/p-input-z-1", gradient );
		setprop("/tu154/systems/nvu-calc/nvu-loader/selected-pz1", 0.0 );
		if( gradient > 0 ) setprop("/tu154/systems/nvu-calc/nvu-loader/mode-pz1", 1 );
		else setprop("/tu154/systems/nvu-calc/nvu-loader/mode-pz1", 2 );
			#Load ZPU-1
		setprop("fdm/jsbsim/instrumentation/zpu-deg-1", zpu_selected_next );
		interpolate("tu154/instrumentation/v-140[0]/zpu-1-delayed", zpu_selected_next, 1.0 );
		}
	}
	if( sm_selected != nil ) {	# load beacon
		#Load Point - S - 2
	dist_current = getprop("fdm/jsbsim/instrumentation/point-integrator-s-2");
	if( dist_current == nil )  dist_current = 0.0;
	gradient = sm_selected - dist_current;
	setprop("fdm/jsbsim/instrumentation/p-input-s-2", gradient );
	setprop("/tu154/systems/nvu-calc/nvu-loader/selected-ps2", sm_selected );
	if( gradient > 0 ) setprop("/tu154/systems/nvu-calc/nvu-loader/mode-ps2", 1 );
	else setprop("/tu154/systems/nvu-calc/nvu-loader/mode-ps2", 2 );
		#Load Point - Z - 2
	dist_current = getprop("fdm/jsbsim/instrumentation/point-integrator-z-2");
	if( dist_current == nil )  dist_current = 0.0;
	gradient = zm_selected - dist_current;
	setprop("fdm/jsbsim/instrumentation/p-input-z-2", gradient );
	setprop("/tu154/systems/nvu-calc/nvu-loader/selected-pz2", zm_selected );
	if( gradient > 0 ) setprop("/tu154/systems/nvu-calc/nvu-loader/mode-pz2", 1 );
	else setprop("/tu154/systems/nvu-calc/nvu-loader/mode-pz2", 2 );
	}
}

if( uk_selected != nil ) {
# Load UK
setprop("tu154/instrumentation/b-8m/outer", int(uk_selected/10.0)*10.0 );
setprop("tu154/instrumentation/b-8m/inner", ( uk_selected - int(uk_selected/10.0)*10.0 )*36.0 );
}

} # -------------------------- END NVU LOADER ----------------------------------

setlistener("/tu154/systems/nvu-calc/list", nvu_load );



var nvu_ldr_handler = func{

var prop_mode = "";
var prop_sel_dist = "";
var prop_input = "";

# select source 
var source = arg[1];
if( source == 0 ) {
	prop_mode = "/tu154/systems/nvu-calc/nvu-loader/mode-as1";
	prop_sel_dist = "/tu154/systems/nvu-calc/nvu-loader/selected-as1";
	prop_input = "/fdm/jsbsim/instrumentation/a-input-s-1";
	}
if( source == 1 ) {
	prop_mode = "/tu154/systems/nvu-calc/nvu-loader/mode-az1";
	prop_sel_dist = "/tu154/systems/nvu-calc/nvu-loader/selected-az1";
	prop_input = "/fdm/jsbsim/instrumentation/a-input-z-1";
	}
if( source == 2 ) {
	prop_mode = "/tu154/systems/nvu-calc/nvu-loader/mode-ps1";
	prop_sel_dist = "/tu154/systems/nvu-calc/nvu-loader/selected-ps1";
	prop_input = "/fdm/jsbsim/instrumentation/p-input-s-1";
	}	
if( source == 3 ) {
	prop_mode = "/tu154/systems/nvu-calc/nvu-loader/mode-pz1";
	prop_sel_dist = "/tu154/systems/nvu-calc/nvu-loader/selected-pz1";
	prop_input = "/fdm/jsbsim/instrumentation/p-input-z-1";
	}	
if( source == 4 ) {
	prop_mode = "/tu154/systems/nvu-calc/nvu-loader/mode-as2";
	prop_sel_dist = "/tu154/systems/nvu-calc/nvu-loader/selected-as2";
	prop_input = "/fdm/jsbsim/instrumentation/a-input-s-2";
	}
if( source == 5 ) {
	prop_mode = "/tu154/systems/nvu-calc/nvu-loader/mode-az2";
	prop_sel_dist = "/tu154/systems/nvu-calc/nvu-loader/selected-az2";
	prop_input = "/fdm/jsbsim/instrumentation/a-input-z-2";
	}
if( source == 6 ) {
	prop_mode = "/tu154/systems/nvu-calc/nvu-loader/mode-ps2";
	prop_sel_dist = "/tu154/systems/nvu-calc/nvu-loader/selected-ps2";
	prop_input = "/fdm/jsbsim/instrumentation/p-input-s-2";
	}	
if( source == 7 ) {
	prop_mode = "/tu154/systems/nvu-calc/nvu-loader/mode-pz2";
	prop_sel_dist = "/tu154/systems/nvu-calc/nvu-loader/selected-pz2";
	prop_input = "/fdm/jsbsim/instrumentation/p-input-z-2";
	}	

var mode = getprop( prop_mode );
if( mode == nil ) return;
if( !mode ) return;
var current_dist = arg[0];	# current distance (m)
# selected dist here:
var selected_dist = getprop( prop_sel_dist );
if( selected_dist == nil ) return;
# gradient <- speed and direction parameter
var gradient = getprop( prop_input );
if( gradient != nil ) gradient = abs( gradient );
if( abs( current_dist - selected_dist ) < 10000.0 ) gradient = 2000.0; # slow speed!
if( mode == 2 ) gradient = -gradient;
setprop( prop_input, gradient );
# check dist counter with direction
if( current_dist < selected_dist and mode == 1 ) return;
if( current_dist > selected_dist and mode == 2 ) return;
# stop adjust counter
setprop( prop_input, 0.0 );
# clear flag and selected value
setprop( prop_mode, 0 );
setprop( prop_sel_dist, 0.0 );
}



var nvu_set_zpu_1 = func{
if( getprop("tu154/systems/nvu/powered" ) == 0 ) return;	# offline now
if( getprop("tu154/systems/nvu/serviceable" ) == 0 ) return;	# inop now
var rotate_speed = 0.1;
var multiplier = getprop("tu154/systems/nvu/mult-2" );
if( multiplier == nil ) return;
if( multiplier > 5.0  ) multiplier = multiplier * 10;
	var zpu = getprop("fdm/jsbsim/instrumentation/zpu-deg-1" );
	if( zpu == nil ) zpu = 0.0;
	zpu = zpu + arg[0]*multiplier*rotate_speed;
	if( zpu > 359.9 ) zpu = zpu - 360.0;
	if( zpu < 0.0 ) zpu = zpu + 360.0;
     	setprop("fdm/jsbsim/instrumentation/zpu-deg-1", zpu );
     	interpolate("tu154/instrumentation/v-140[0]/zpu-1-delayed", zpu, 0.15 );
# PNP needles
if( getprop( "fdm/jsbsim/instrumentation/nvu-selector") )
	{
	interpolate( "tu154/instrumentation/pnp[0]/plane-deg", zpu, 0.5 );
	interpolate( "tu154/instrumentation/pnp[1]/plane-deg", zpu, 0.5 );
	}
}


var nvu_set_zpu_2 = func{
if( getprop("tu154/systems/nvu/powered" ) == 0 ) return;	# offline now
if( getprop("tu154/systems/nvu/serviceable" ) == 0 ) return;	# inop now
var rotate_speed = 0.1;
var multiplier = getprop("tu154/systems/nvu/mult-3" );
if( multiplier == nil ) return;
if( multiplier > 5.0  ) multiplier = multiplier * 10;
	var zpu = getprop("fdm/jsbsim/instrumentation/zpu-deg-2" );
	if( zpu == nil ) zpu = 0.0;
	zpu = zpu + arg[0]*multiplier*rotate_speed;
	if( zpu > 359.9 ) zpu = zpu - 360.0;
	if( zpu < 0.0 ) zpu = zpu + 360.0;
     	setprop("fdm/jsbsim/instrumentation/zpu-deg-2", zpu );
     	interpolate("tu154/instrumentation/v-140[0]/zpu-2-delayed", zpu, 0.15 );
# PNP needles
	if( !getprop( "fdm/jsbsim/instrumentation/nvu-selector") )
	{
	interpolate( "tu154/instrumentation/pnp[0]/plane-deg", zpu, 0.5 );
	interpolate( "tu154/instrumentation/pnp[1]/plane-deg", zpu, 0.5 );
	}

}


var nvu_toggle_multiplier = func{
  var selector = arg[0];
  
  if( selector == 1 )
  {
   var multiplier = getprop("tu154/systems/nvu/mult-1" );
   if( multiplier == nil ) return;
   if( multiplier == 1.0 ){ setprop("tu154/systems/nvu/mult-1", 10.0 );}
    else { setprop("tu154/systems/nvu/mult-1", 1.0 );}
   return;
  }
  if( selector == 2 )
  {
   var multiplier = getprop("tu154/systems/nvu/mult-2" );
   if( multiplier == nil ) return;
   if( multiplier == 1.0 ){ setprop("tu154/systems/nvu/mult-2", 10.0 );}
    else { setprop("tu154/systems/nvu/mult-2", 1.0 );}
   return;
  }
  if( selector == 3 )
  {
   var multiplier = getprop("tu154/systems/nvu/mult-3" );
   if( multiplier == nil ) return;
   if( multiplier == 1.0 ){ setprop("tu154/systems/nvu/mult-3", 10.0 );}
    else { setprop("tu154/systems/nvu/mult-3", 1.0 );}
   return;
  }
}


var nvu_power_on = func{
 electrical.AC3x200_bus_1L.add_output( "NVU", 150.0);
if( getprop( "tu154/systems/electrical/buses/AC3x200-bus-1L/volts" ) > 150.0 )
 {
 setprop("tu154/systems/nvu/serviceable", 1.0 );
 setprop("tu154/systems/nvu/selector", 0 );
 nvu_watchdog();
 nvu_ort_changer();
 }
rsbn_range_watchdog();	# kick on RSBN warn lamps first time
}

var nvu_power_off = func{
# setprop("tu154/systems/nvu/powered", 0.0 );
 setprop("tu154/systems/nvu/serviceable", 0.0 );
 electrical.AC3x200_bus_1L.rm_output( "NVU" );
 nvu_watchdog();
# Clear RSBN lamps
rsbn_range_watchdog();
}

var nvu_start_corr = func{
if( getprop("tu154/systems/nvu/powered") != 1 ) return;
if( getprop("tu154/systems/nvu/serviceable") != 1 ) return;
if( getprop("tu154/systems/nvu/selector" ) == 1 )
	setprop("fdm/jsbsim/instrumentation/rsbn-cft-1", -5.1 );
if( getprop("tu154/systems/nvu/selector" ) == 0 )
	setprop("fdm/jsbsim/instrumentation/rsbn-cft-2", -5.1 );
}

var nvu_stop_corr = func{
setprop("fdm/jsbsim/instrumentation/rsbn-cft-1", 0.0 );
setprop("fdm/jsbsim/instrumentation/rsbn-cft-2", 0.0 );
}

var nvu_start_count = func{
if( getprop("tu154/systems/nvu/powered") != 1 ) return;
if( getprop("tu154/systems/nvu/serviceable") != 1 ) return;
setprop("fdm/jsbsim/instrumentation/enable-count", 1.09728 );
setprop("fdm/jsbsim/instrumentation/enable-convertion", 1.0 );
}

var nvu_stop_count = func{
setprop("fdm/jsbsim/instrumentation/enable-count", 0.0 );
setprop("fdm/jsbsim/instrumentation/enable-convertion", 0.0 );
nvu_clear_input();
}


var nvu_lur_selector = func{
var selector = getprop("tu154/switches/v-51-selector-2" );
if( selector == nil ) return;	# sanity check
if( selector == 0.0 )	# persist change V-52
   if( getprop("tu154/systems/nvu/powered") == 1 )
	nvu_ort_changer();	
}

var nvu_clear_input = func{
setprop("fdm/jsbsim/instrumentation/a-input-s-1", 0.0 );
setprop("fdm/jsbsim/instrumentation/a-input-s-2", 0.0 );
setprop("fdm/jsbsim/instrumentation/a-input-z-1", 0.0 );
setprop("fdm/jsbsim/instrumentation/a-input-z-2", 0.0 );
setprop("fdm/jsbsim/instrumentation/p-input-s-1", 0.0 );
setprop("fdm/jsbsim/instrumentation/p-input-s-2", 0.0 );
setprop("fdm/jsbsim/instrumentation/p-input-z-1", 0.0 );
setprop("fdm/jsbsim/instrumentation/p-input-z-2", 0.0 );
}

var nvu_ort_changer = func{
setprop("tu154/systems/nvu/trigger", 0 );
nvu_clear_input();
setprop("tu154/systems/electrical/indicators/change-waypoint", 1 );
	if( getprop("tu154/systems/nvu/selector" ) == 1 )
	{
	# turn OFF V-52[0]
		setprop("tu154/instrumentation/v-52[0]/ind-aircraft", 0 );
		setprop("tu154/instrumentation/v-52[0]/ind-point", 1 );
		setprop("tu154/instrumentation/v-52[0]/ind-beacon", 0 );
	# turn ON V-52[1]
		setprop("tu154/instrumentation/v-52[1]/ind-aircraft", 1 );
		setprop("tu154/instrumentation/v-52[1]/ind-point", 0 );
		setprop("tu154/instrumentation/v-52[1]/ind-beacon", 1 );
	# Proceed V-140
		setprop("tu154/instrumentation/v-140/lamp-I", 0 );
		setprop("tu154/instrumentation/v-140/lamp-II", 1 );
	# change active selector
		setprop("tu154/systems/nvu/selector", 0 );
		setprop("fdm/jsbsim/instrumentation/nvu-selector", 0 );
	# PNP needles procedure
		if( getprop( "fdm/jsbsim/ap/roll-selector") == 4 ){
		 var heading = getprop( "fdm/jsbsim/instrumentation/zpu-deg-2");
		 interpolate( "tu154/instrumentation/pnp[0]/plane-deg", heading, 0.5 );
		 interpolate( "tu154/instrumentation/pnp[1]/plane-deg", heading, 0.5 );
		}
	}
	else #if( getprop("tu154/systems/nvu/selector" ) == 0 )
	{
	# turn OFF V-52[1]
		setprop("tu154/instrumentation/v-52[1]/ind-aircraft", 0 );
		setprop("tu154/instrumentation/v-52[1]/ind-point", 1 );
		setprop("tu154/instrumentation/v-52[1]/ind-beacon", 0 );
	# turn ON V-52[0]
		setprop("tu154/instrumentation/v-52[0]/ind-aircraft", 1 );
		setprop("tu154/instrumentation/v-52[0]/ind-point", 0 );
		setprop("tu154/instrumentation/v-52[0]/ind-beacon", 1 );
	# Proceed V-140
		setprop("tu154/instrumentation/v-140/lamp-I", 1 );
		setprop("tu154/instrumentation/v-140/lamp-II", 0 );
	# change active selector
		setprop("tu154/systems/nvu/selector", 1 );
		setprop("fdm/jsbsim/instrumentation/nvu-selector", 1 );
	# PNP needles procedure
		if( getprop( "fdm/jsbsim/ap/roll-selector") == 4 ){
		 var heading = getprop( "fdm/jsbsim/instrumentation/zpu-deg-1");
		 interpolate( "tu154/instrumentation/pnp[0]/plane-deg", heading, 0.5 );
		 interpolate( "tu154/instrumentation/pnp[1]/plane-deg", heading, 0.5 );
		}
	}
# virtual navigator
var ena_vn = num( getprop("/tu154/systems/nvu-calc/vn") );
if( ena_vn == nil ) ena_vn = 0;
if( ena_vn and getprop("fdm/jsbsim/instrumentation/enable-count" )
#	getprop("tu154/systems/nvu/powered")
) virtual_navigator();

}


var nvu_watchdog = func{
settimer( nvu_watchdog, 1.0 );
if( getprop("tu154/systems/nvu/powered" ) == 0 ) # offline now
	{
		setprop("tu154/instrumentation/v-52[1]/ind-aircraft", 0 );
		setprop("tu154/instrumentation/v-52[1]/ind-point", 0 );
		setprop("tu154/instrumentation/v-52[1]/ind-beacon", 0 );
		setprop("tu154/instrumentation/v-52[0]/ind-aircraft", 0 );
		setprop("tu154/instrumentation/v-52[0]/ind-point", 0 );
		setprop("tu154/instrumentation/v-52[0]/ind-beacon", 0 );
		setprop("tu154/instrumentation/v-140/lamp-I", 0 );
		setprop("tu154/instrumentation/v-140/lamp-II", 0 );
		
		setprop("tu154/systems/electrical/indicators/nvu-failure", 0 );
		setprop("tu154/systems/electrical/indicators/change-waypoint", 0 );
		setprop("tu154/systems/electrical/indicators/nvu-vor-avton", 0 ); 
		setprop("tu154/systems/electrical/indicators/nvu-correction-on", 0 ); 
		nvu_stop_corr();
		nvu_stop_count();
		setprop("tu154/systems/nvu/serviceable", 0.0 );
	return;	
	}
if( getprop( "tu154/switches/v-51-power" ) != 1.0 )
{
		setprop("tu154/instrumentation/v-52[1]/ind-aircraft", 0 );
		setprop("tu154/instrumentation/v-52[1]/ind-point", 0 );
		setprop("tu154/instrumentation/v-52[1]/ind-beacon", 0 );
		setprop("tu154/instrumentation/v-52[0]/ind-aircraft", 0 );
		setprop("tu154/instrumentation/v-52[0]/ind-point", 0 );
		setprop("tu154/instrumentation/v-52[0]/ind-beacon", 0 );
		setprop("tu154/instrumentation/v-140/lamp-I", 0 );
		setprop("tu154/instrumentation/v-140/lamp-II", 0 );
		
		setprop("tu154/systems/electrical/indicators/nvu-failure", 0 );
		setprop("tu154/systems/electrical/indicators/change-waypoint", 0 );
		setprop("tu154/systems/electrical/indicators/nvu-vor-avton", 0 ); 
		setprop("tu154/systems/electrical/indicators/nvu-correction-on", 0 ); 
		nvu_stop_corr();
		nvu_stop_count();
		setprop("tu154/systems/nvu/serviceable", 0.0 );
	return;	
}

# check NVU speed source 
var src_speed = 0.0;
if( getprop("tu154/instrumentation/diss/serviceable" ) == 1 )
	src_speed = 1.0;


if( getprop("tu154/systems/svs/powered" ) == 1.0 ) src_speed = src_speed + 1.0;

if( src_speed == 0.0 ){
 	setprop("tu154/systems/nvu/serviceable", 0 ); 
 	setprop("tu154/systems/electrical/indicators/nvu-failure", 1 );
	}
else 	{
 	setprop("tu154/systems/nvu/serviceable", 1 ); 
 	setprop("tu154/systems/electrical/indicators/nvu-failure", 0 );
	}

if( getprop("tu154/systems/nvu/serviceable" ) == 0 ) # inop
{
	nvu_clear_input();
	nvu_stop_corr();
	nvu_stop_count();
	return;	
}

# RSBN correction control
if( getprop("tu154/switches/v-51-corr" ) == 1.0 )
	{
	if( getprop("tu154/instrumentation/rsbn/serviceable" ) == 1 )
		{ 
		setprop("tu154/systems/electrical/indicators/nvu-vor-avton", 0 ); 
		setprop("tu154/systems/nvu/rsbn-corr", 1 );
		setprop("tu154/systems/electrical/indicators/nvu-correction-on", 1 ); 
		nvu_start_corr();
		}
	else {
              setprop("tu154/systems/electrical/indicators/nvu-vor-avton", 1 ); 
              setprop("tu154/systems/nvu/rsbn-corr", 0 ); 
              setprop("tu154/systems/electrical/indicators/nvu-correction-on", 0 ); 
              nvu_stop_corr();	
		} }	
else	{
	setprop("tu154/systems/electrical/indicators/nvu-vor-avton", 0 ); 
	setprop("tu154/systems/nvu/rsbn-corr", 0 ); 
	setprop("tu154/systems/electrical/indicators/nvu-correction-on", 0 ); 
	nvu_stop_corr();
	}
# END RSBN correction	
var lur = getprop("tu154/switches/v-51-selector-2" );
var lur_limit = 0.0;

if( lur == nil ) return;
if( lur == 0.0 ) return; # change manually
if( lur == 1.0 ) 
	{ # changing waypoint disabled
	setprop("tu154/systems/electrical/indicators/change-waypoint", 0 ); 
	return; 
	}
if( lur == 2.0 ) lur_limit = 5000.0;
if( lur == 3.0 ) lur_limit = 10000.0;
if( lur == 4.0 ) lur_limit = 15000.0;
if( lur == 5.0 ) lur_limit = 20000.0;
if( lur == 6.0 ) lur_limit = 25000.0;

# ort change trigger procedure
if( getprop("tu154/systems/nvu/selector" ) == 1 )
 if( abs( getprop("fdm/jsbsim/instrumentation/aircraft-integrator-s-1") ) > lur_limit )
  setprop("tu154/systems/nvu/trigger", 1 );
if( getprop("tu154/systems/nvu/selector" ) == 0 )
 if( abs( getprop("fdm/jsbsim/instrumentation/aircraft-integrator-s-2") ) > lur_limit )
  setprop("tu154/systems/nvu/trigger", 1 );
# end trigger procedure

# ort change procedure
if( getprop("tu154/systems/nvu/trigger" ) == 1 )
	{
    if( getprop("tu154/systems/nvu/selector" ) == 1 )
    if( abs( getprop("fdm/jsbsim/instrumentation/aircraft-integrator-s-1") ) < lur_limit )
      nvu_ort_changer();
     
    if( getprop("tu154/systems/nvu/selector" ) == 0 )
    if( abs( getprop("fdm/jsbsim/instrumentation/aircraft-integrator-s-2") ) < lur_limit )
      nvu_ort_changer();
	}
# end ort change procedure

# Change Warning

if( getprop("tu154/systems/nvu/trigger" ) == 1 )
 {
  if( getprop("tu154/systems/nvu/selector" ) == 1 ){
   if( abs( getprop("fdm/jsbsim/instrumentation/aircraft-integrator-s-1") ) < lur_limit+2000 ) {
    setprop("tu154/systems/electrical/indicators/change-waypoint", 1 );
          }
   else { setprop("tu154/systems/nvu/warning", 0.0 ); }}
  
  if( getprop("tu154/systems/nvu/selector" ) == 0 ){
   if( abs( getprop("fdm/jsbsim/instrumentation/aircraft-integrator-s-2") ) < lur_limit+2000 ) {
    setprop("tu154/systems/electrical/indicators/change-waypoint", 1 );
   }
   else { setprop("tu154/systems/electrical/indicators/change-waypoint", 0 ); }}
 }
else { setprop("tu154/systems/electrical/indicators/change-waypoint", 0 ); }


}
# END NVU watchdog

nvu_watchdog();

# UK gauge support
var b_8m_handler = func{
var outer_deg = getprop("tu154/instrumentation/b-8m/outer");
if( outer_deg == nil ) outer_deg = 0.0;
if( outer_deg >= 360.0 ) outer_deg = outer_deg - 360.0;
if( outer_deg < 0.0 ) outer_deg = outer_deg + 360.0;
setprop("tu154/instrumentation/b-8m/outer", outer_deg );
var inner_deg = getprop("tu154/instrumentation/b-8m/inner");
if( inner_deg == nil ) inner_deg = 0.0;
if( inner_deg >= 360.0 ) inner_deg = inner_deg - 360.0;
if( inner_deg < 0.0 ) inner_deg = inner_deg + 360.0;
setprop("tu154/instrumentation/b-8m/inner", inner_deg );

var uk_deg = int( outer_deg/10.0 )*10.0 + inner_deg/36.0;
setprop("fdm/jsbsim/instrumentation/rsbn-uk-deg", uk_deg );
help.uk();
}




setlistener("tu154/instrumentation/b-8m/outer", b_8m_handler ,0,0);
setlistener("tu154/instrumentation/b-8m/inner", b_8m_handler ,0,0);
setlistener("tu154/switches/v-51-selector-2", nvu_lur_selector ,0,0);
setlistener( "tu154/instrumentation/v-140[0]/zpu-1-delayed", zpu_1_handler ,0,0);
setlistener( "tu154/instrumentation/v-140[0]/zpu-2-delayed", zpu_2_handler ,0,0);


#                            END NVU staff 
#*****************************************************************************

#RSBN support
var rsbn_handler = func{
settimer(rsbn_handler, 0.0);

if( getprop("tu154/instrumentation/rsbn/serviceable" ) != 1 ) return; # Something is wrong

var distance = getprop("instrumentation/nav[2]/nav-distance"); 
if( distance == nil ) distance = 0.0;
setprop( "tu154/instrumentation/rsbn/distance-m", distance ); 
setprop( "fdm/jsbsim/instrumentation/rsbn-d-m", distance ); 
var hdg = getprop("instrumentation/nav[2]/radials/actual-deg"); 
if( hdg == nil ) hdg = 0.0;
# 
var magvar = getprop("instrumentation/nav[2]/radials/target-radial-deg");
if( magvar == nil ) magvar = 0.0;
hdg = hdg + magvar;
#hdg = hdg + 180.0;
if( hdg >= 360.0 ) hdg = hdg - 360.0;
if( hdg < 0.0 ) hdg = hdg + 360.0;

setprop( "fdm/jsbsim/instrumentation/rsbn-angle-deg", hdg ); 
setprop( "tu154/instrumentation/rsbn/heading-deg", hdg );

distance = distance/10.0;
setprop("tu154/instrumentation/rsbn/indicated-wheels_ones", 
(distance/10.0) - int( distance/100.0 )*10.0 );
setprop("tu154/instrumentation/rsbn/indicated-wheels_dec", 
(distance/100.0) - int( distance/1000.0 )*10.0 );
setprop("tu154/instrumentation/rsbn/indicated-wheels_hund", 
(distance/1000.0) - int( distance/10000.0 )*10.0 );
setprop("tu154/instrumentation/rsbn/indicated-wheels_ths", 
(distance/10000.0) - int( distance/100000.0 )*10.0 );

}

rsbn_handler();

var rsbn_set_f_1 = func{
var handle = getprop("tu154/instrumentation/rsbn/handle-1");
if( handle == nil ) handle = 0.0;
var step = arg[0];
if( getprop("tu154/instrumentation/rsbn/mode") == 0)
 {
  handle = handle + step;
  if( handle > 4.0 ) handle = 4.0;
  if( handle < 0.0 ) handle = 0.0;
  setprop("tu154/instrumentation/rsbn/handle-1", handle );
  rsbn_chan_to_f();
  return;
 }
else {
  handle = handle + step/2.5;
  if( handle > 4.0 ) handle = 4.0;
  if( handle < 0.0 ) handle = 0.0;
  setprop("tu154/instrumentation/rsbn/handle-1", handle );
  var freq = getprop("tu154/instrumentation/rsbn/frequency" );
  if( freq == nil ) freq = 108.0;
  var khz = freq - int( freq );
  setprop("tu154/instrumentation/rsbn/frequency", 108.0 + handle*2.5 + khz );
  setprop("instrumentation/nav[2]/frequencies/selected-mhz", 108.0 + handle*2.5 + khz );
  help.rsbn();
 } 
}

var rsbn_set_f_2 = func{
var handle = getprop("tu154/instrumentation/rsbn/handle-2");
if( handle == nil ) handle = 0.0;
var step = arg[0];
if( getprop("tu154/instrumentation/rsbn/mode") == 0)
  {
  handle = handle + step;
  if( handle > 9.0 ) handle = 9.0;
  if( handle < 0.0 ) handle = 0.0;
  setprop("tu154/instrumentation/rsbn/handle-2", handle );
  rsbn_chan_to_f();
  return;
  }
else {
  handle = handle + step/20.0;
  if( handle > 9.0 ) handle = 9.0;
  if( handle < 0.0 ) handle = 0.0;
  var freq = getprop("tu154/instrumentation/rsbn/frequency" );
  if( freq == nil ) freq = 108.0;
  setprop("tu154/instrumentation/rsbn/handle-2", handle );
  setprop("tu154/instrumentation/rsbn/frequency", int(freq) + handle/10.0 );
  setprop("instrumentation/nav[2]/frequencies/selected-mhz", int(freq) + handle/10.0 );
  help.rsbn();
  } 
}

var rsbn_set_mode = func{
if( arg[0] == 0 )
	{
	setprop("tu154/instrumentation/rsbn/mode", 0 );
	var handle = getprop("tu154/instrumentation/rsbn/handle-1");
	if( handle  == nil ) handle = 0.0;
	handle = int( handle ); 
	setprop("tu154/instrumentation/rsbn/handle-1", handle );
	handle = getprop("tu154/instrumentation/rsbn/handle-2");
	if( handle  == nil ) handle = 0.0;
	handle = int( handle ); 
	setprop("tu154/instrumentation/rsbn/handle-2", handle );
	}
else {
	setprop("tu154/instrumentation/rsbn/mode", 1 );
	}
	
rsbn_set_f_1(0);
rsbn_set_f_2(0);

}

var rsbn_chan_to_f = func{
var handle_1 = getprop("tu154/instrumentation/rsbn/handle-1");
var handle_2 = getprop("tu154/instrumentation/rsbn/handle-2");
if( handle_1 == nil ) handle_1 = 0.0;
if( handle_2 == nil ) handle_2 = 0.0;

var channel = handle_1 * 10 + handle_2;
if( channel < 1.0 ) channel = 1.0;
if( channel > 40.0 ) channel = 40.0;

var freq = 115.95 + channel * 0.05;
setprop("tu154/instrumentation/rsbn/frequency", freq );
setprop("instrumentation/nav[2]/frequencies/selected-mhz", freq );
}


var rsbn_power = func{
if( arg[0] == 1 )
	{
      if( getprop("instrumentation/nav[2]/powered") == 1 )
	  {
	  rsbn_set_f_1(0);
	  rsbn_set_f_2(0);
	  electrical.AC3x200_bus_1L.add_output( "RSBN", 50.0);
	  setprop("instrumentation/nav[2]/power-btn", 1 );
	  }
	}
else { 
	electrical.AC3x200_bus_1L.rm_output( "RSBN" );
#	setprop("instrumentation/nav[2]/serviceable", 0 ); 
	setprop("instrumentation/nav[2]/power-btn", 0 );
	setprop("tu154/instrumentation/rsbn/serviceable", 0 );
	setprop("instrumentation/nav[2]/powered", 0 );
	}
}

var rsbn_pwr_watchdog = func{
if( getprop("instrumentation/nav[2]/powered" ) != 1 ) # power off
	{
#	setprop("instrumentation/nav[2]/serviceable", 0 );
	setprop("instrumentation/nav[2]/power-btn", 0 );
#	setprop("tu154/systems/electrical/indicators/range-avton", 0 );  
#	setprop("tu154/systems/electrical/indicators/azimuth-avton", 0 );
	setprop("tu154/instrumentation/rsbn/serviceable", 0 );
	return;
	}
else 	{ 
	if( getprop( "tu154/switches/RSBN-power" ) == 1.0 ) 
	    {
	    setprop("instrumentation/nav[2]/power-btn", 1 );
	    setprop("tu154/instrumentation/rsbn/serviceable", 1 ); 
	    }
	}

if( getprop( "tu154/switches/RSBN-power" ) != 1.0 ) 
        {
        setprop("tu154/instrumentation/rsbn/serviceable", 0 );
	setprop("instrumentation/nav[2]/power-btn", 0 );
        return;
        }
}
#var rsbn_serv_watchdog = func{
#if( getprop("instrumentation/nav[2]/serviceable" ) != 1 ) # inop
#	{
#	setprop("tu154/systems/electrical/indicators/range-avton", 1 );  
#	setprop("tu154/systems/electrical/indicators/azimuth-avton", 1 );
#	setprop("tu154/instrumentation/rsbn/serviceable", 0 );
#	}
#}

var rsbn_range_watchdog = func{
if( getprop("tu154/systems/nvu/serviceable" ) ){
	if( getprop("instrumentation/nav[2]/in-range" ) != 1 ) # out of range
	{
		setprop("tu154/systems/electrical/indicators/range-avton", 1 );  
		setprop("tu154/systems/electrical/indicators/azimuth-avton", 1 );
		setprop("tu154/instrumentation/rsbn/serviceable", 0 );
	}
	else
	{
		setprop("tu154/systems/electrical/indicators/range-avton", 0 );  
		setprop("tu154/systems/electrical/indicators/azimuth-avton", 0 );
		setprop("tu154/instrumentation/rsbn/serviceable", 1 );
	}
}
else {
	setprop("tu154/systems/electrical/indicators/range-avton", 0 );  
	setprop("tu154/systems/electrical/indicators/azimuth-avton", 0 );
	setprop("tu154/instrumentation/rsbn/serviceable", 1 );
	}
}

setlistener("instrumentation/nav[2]/powered", rsbn_pwr_watchdog, 0,0 );
#setlistener("instrumentation/nav[2]/serviceable", rsbn_serv_watchdog, 0,0 );
setlistener("instrumentation/nav[2]/in-range", rsbn_range_watchdog,0,0 );



# USHDB support
var ushdb_handler = func{
settimer(ushdb_handler, 0.0);

if( getprop( "tu154/switches/ushdb-sel-1" ) == 1.0 ) 
	var hdg_1 = getprop( "instrumentation/nav[0]/radials/reciprocal-radial-deg");
else var hdg_1 = getprop( "instrumentation/adf[0]/indicated-bearing-deg");
	if( hdg_1 == nil ) hdg_1 = 0.0;
if( getprop( "tu154/switches/ushdb-sel-2" ) == 1.0 )
	var hdg_2 = getprop( "instrumentation/nav[1]/radials/reciprocal-radial-deg");
else var hdg_2 = getprop( "instrumentation/adf[1]/indicated-bearing-deg");
	if( hdg_2 == nil ) hdg_2 = 0.0;
setprop( "tu154/instrumentation/ushdb/heading-deg-1", hdg_1 );	
setprop( "tu154/instrumentation/ushdb/heading-deg-2", hdg_2 );	

}

ushdb_handler();

# ARK support

ark_1_2_handler = func {
	var ones = getprop("tu154/instrumentation/ark-15[0]/digit-2-1");
	if( ones == nil ) ones = 0.0;
	var dec = getprop("tu154/instrumentation/ark-15[0]/digit-2-2");
	if( dec == nil ) dec = 0.0;
	var hund = getprop("tu154/instrumentation/ark-15[0]/digit-2-3");
	if( hund == nil ) hund = 0.0;
	var freq = hund * 100 + dec * 10 + ones;
	if( getprop("tu154/switches/adf-1-selector") == 1 )
		setprop("instrumentation/adf[0]/frequencies/selected-khz", freq );
}

ark_1_1_handler = func {
	var ones = getprop("tu154/instrumentation/ark-15[0]/digit-1-1");
	if( ones == nil ) ones = 0.0;
	var dec = getprop("tu154/instrumentation/ark-15[0]/digit-1-2");
	if( dec == nil ) dec = 0.0;
	var hund = getprop("tu154/instrumentation/ark-15[0]/digit-1-3");
	if( hund == nil ) hund = 0.0;
	var freq = hund * 100 + dec * 10 + ones;
	if( getprop("tu154/switches/adf-1-selector") == 0 )
		setprop("instrumentation/adf[0]/frequencies/selected-khz", freq );
}

ark_2_2_handler = func {
	var ones = getprop("tu154/instrumentation/ark-15[1]/digit-2-1");
	if( ones == nil ) ones = 0.0;
	var dec = getprop("tu154/instrumentation/ark-15[1]/digit-2-2");
	if( dec == nil ) dec = 0.0;
	var hund = getprop("tu154/instrumentation/ark-15[1]/digit-2-3");
	if( hund == nil ) hund = 0.0;
	var freq = hund * 100 + dec * 10 + ones;
	if( getprop("tu154/switches/adf-2-selector") == 1 )
		setprop("instrumentation/adf[1]/frequencies/selected-khz", freq );
}

ark_2_1_handler = func {
	var ones = getprop("tu154/instrumentation/ark-15[1]/digit-1-1");
	if( ones == nil ) ones = 0.0;
	var dec = getprop("tu154/instrumentation/ark-15[1]/digit-1-2");
	if( dec == nil ) dec = 0.0;
	var hund = getprop("tu154/instrumentation/ark-15[1]/digit-1-3");
	if( hund == nil ) hund = 0.0;
	var freq = hund * 100 + dec * 10 + ones;
	if( getprop("tu154/switches/adf-2-selector") == 0 )
		setprop("instrumentation/adf[1]/frequencies/selected-khz", freq );
}


ark_1_power = func{
    if( getprop("tu154/instrumentation/ark-15[0]/powered") == 1 )
	{
    	if( getprop("tu154/switches/adf-power-1")==1 )
		{
	     electrical.AC3x200_bus_1L.add_output( "ARK-15-1", 20.0);
	     setprop("instrumentation/adf[0]/serviceable", 1 );
		}
 	else {
	     electrical.AC3x200_bus_1L.rm_output( "ARK-15-1" );
	     setprop("instrumentation/adf[0]/serviceable", 0 );
	     }
	} 
   else {
	electrical.AC3x200_bus_1L.rm_output( "ARK-15-1" );
	setprop("instrumentation/adf[0]/serviceable", 0 );
	}
}

ark_2_power = func{
    if( getprop("tu154/instrumentation/ark-15[1]/powered") == 1 )
	{
    	if( getprop("tu154/switches/adf-power-2")==1 )
		{
	     electrical.AC3x200_bus_3R.add_output( "ARK-15-2", 20.0);
	     setprop("instrumentation/adf[1]/serviceable", 1 );
		}
 	else {
	     electrical.AC3x200_bus_3R.rm_output( "ARK-15-2" );
	     setprop("instrumentation/adf[1]/serviceable", 0 );
		}
	} 
   else {
	electrical.AC3x200_bus_3R.rm_output( "ARK-15-2" );
	setprop("instrumentation/adf[1]/serviceable", 0 );
	}
}



# read selected and standby ADF frequencies and copy it to ARK
ark_init = func{
var freq = getprop("instrumentation/adf[0]/frequencies/selected-khz");
if( freq == nil ) freq = 0.0;
setprop("tu154/instrumentation/ark-15[0]/digit-1-3", 
int( (freq/100.0) - int( freq/1000.0 )*10.0 ) );
setprop("tu154/instrumentation/ark-15[0]/digit-1-2", 
int( (freq/10.0) - int( freq/100.0 )*10.0 ) );
setprop("tu154/instrumentation/ark-15[0]/digit-1-1", 
int( freq - int( freq/10.0 )*10.0 ) );

freq = getprop("instrumentation/adf[0]/frequencies/standby-khz");
if( freq == nil ) freq = 0.0;
setprop("tu154/instrumentation/ark-15[0]/digit-2-3", 
int( (freq/100.0) - int( freq/1000.0 )*10.0 ) );
setprop("tu154/instrumentation/ark-15[0]/digit-2-2", 
int( (freq/10.0) - int( freq/100.0 )*10.0 ) );
setprop("tu154/instrumentation/ark-15[0]/digit-2-1", 
int( freq - int( freq/10.0 )*10.0 ) );

freq = getprop("instrumentation/adf[1]/frequencies/selected-khz");
if( freq == nil ) freq = 0.0;
setprop("tu154/instrumentation/ark-15[1]/digit-1-3", 
int( (freq/100.0) - int( freq/1000.0 )*10.0 ) );
setprop("tu154/instrumentation/ark-15[1]/digit-1-2", 
int( (freq/10.0) - int( freq/100.0 )*10.0 ) );
setprop("tu154/instrumentation/ark-15[1]/digit-1-1", 
int( freq - int( freq/10.0 )*10.0 ) );

freq = getprop("instrumentation/adf[1]/frequencies/standby-khz");
if( freq == nil ) freq = 0.0;
setprop("tu154/instrumentation/ark-15[1]/digit-2-3", 
int( (freq/100.0) - int( freq/1000.0 )*10.0 ) );
setprop("tu154/instrumentation/ark-15[1]/digit-2-2", 
int( (freq/10.0) - int( freq/100.0 )*10.0 ) );
setprop("tu154/instrumentation/ark-15[1]/digit-2-1", 
int( freq - int( freq/10.0 )*10.0 ) );

}

ark_init();

setlistener("tu154/switches/adf-power-1", ark_1_power ,0,0);
setlistener("tu154/switches/adf-power-2", ark_2_power ,0,0);

setlistener( "tu154/instrumentation/ark-15[0]/powered", ark_1_power ,0,0);
setlistener( "tu154/instrumentation/ark-15[1]/powered", ark_2_power ,0,0);


setlistener( "tu154/switches/adf-1-selector", ark_1_1_handler ,0,0);
setlistener( "tu154/switches/adf-1-selector", ark_1_2_handler ,0,0);

setlistener( "tu154/switches/adf-2-selector", ark_2_1_handler ,0,0);
setlistener( "tu154/switches/adf-2-selector", ark_2_2_handler ,0,0);

setlistener( "tu154/instrumentation/ark-15[0]/digit-1-1", ark_1_1_handler ,0,0);
setlistener( "tu154/instrumentation/ark-15[0]/digit-1-2", ark_1_1_handler ,0,0);
setlistener( "tu154/instrumentation/ark-15[0]/digit-1-3", ark_1_1_handler ,0,0);

setlistener( "tu154/instrumentation/ark-15[0]/digit-2-1", ark_1_2_handler ,0,0);
setlistener( "tu154/instrumentation/ark-15[0]/digit-2-2", ark_1_2_handler ,0,0);
setlistener( "tu154/instrumentation/ark-15[0]/digit-2-3", ark_1_2_handler ,0,0);

setlistener( "tu154/instrumentation/ark-15[1]/digit-1-1", ark_2_1_handler ,0,0);
setlistener( "tu154/instrumentation/ark-15[1]/digit-1-2", ark_2_1_handler ,0,0);
setlistener( "tu154/instrumentation/ark-15[1]/digit-1-3", ark_2_1_handler ,0,0);

setlistener( "tu154/instrumentation/ark-15[1]/digit-2-1", ark_2_2_handler ,0,0);
setlistener( "tu154/instrumentation/ark-15[1]/digit-2-2", ark_2_2_handler ,0,0);
setlistener( "tu154/instrumentation/ark-15[1]/digit-2-3", ark_2_2_handler ,0,0);


# AUASP (UAP-12) power support
auasp_power = func{
	if( getprop("tu154/switches/AUASP")==1 )
	    {
	     electrical.AC3x200_bus_1L.add_output( "AUASP", 10.0);
	     setprop("tu154/instrumentation/uap-12/powered", 1 );
	    }
 	else {
	     electrical.AC3x200_bus_1L.rm_output( "AUASP" );
	     setprop("tu154/instrumentation/uap-12/powered", 0 );
	    }
}
setlistener("tu154/switches/AUASP", auasp_power, 0,0 );

uap_handler = func{
settimer(uap_handler, 0.0);
if( getprop("tu154/instrumentation/uap-12/powered") == 0.0 ) return;
var n_norm = getprop("fdm/jsbsim/instrumentation/n-norm");
var n_max = getprop("tu154/instrumentation/uap-12/accelerate-max");
var n_min = getprop("tu154/instrumentation/uap-12/accelerate-min");
if( n_norm == nil ) n_norm = -1.0;
if( n_max == nil ) n_max = -1.0;
if( n_min == nil ) n_min = -1.0;
if( n_norm >= n_max ) setprop("tu154/instrumentation/uap-12/accelerate-max", n_norm);
if( n_norm <= n_min ) setprop("tu154/instrumentation/uap-12/accelerate-min", n_norm);
}

uap_handler();

# EUP power support
eup_power = func{
	if( getprop("tu154/switches/EUP")==1 )
{
	     electrical.AC3x200_bus_1L.add_output( "EUP", 5.0);
	     setprop("tu154/instrumentation/eup/powered", 1 );
}
 	else {
	     electrical.AC3x200_bus_1L.rm_output( "EUP" );
	     setprop("tu154/instrumentation/eup/powered", 0 );
}
}
setlistener("tu154/switches/EUP", eup_power, 0,0 );


# electrical system update for PNK

var update_electrical = func{
var dc12 = getprop( "tu154/systems/electrical/buses/DC27-bus-L/volts" );
if( dc12 == nil ) return;
if( dc12 > 12.0 ){
  if( getprop( "tu154/switches/comm-power-1" ) == 1.0 )
	  setprop("instrumentation/comm[0]/serviceable", 1 );  
  else setprop("instrumentation/comm[0]/serviceable", 0 );  

  if( getprop( "tu154/switches/comm-power-2" ) == 1.0 )
	  setprop("instrumentation/comm[1]/serviceable", 1 );  
  else setprop("instrumentation/comm[1]/serviceable", 0 );  
  }
else {
  setprop("instrumentation/comm[0]/serviceable", 0 );
  setprop("instrumentation/comm[1]/serviceable", 0 );
  }

var ac200 = getprop( "tu154/systems/electrical/buses/AC3x200-bus-1L/volts" );
if( ac200 == nil ) return; # system not ready yet
if( ac200 > 150.0 )
	{ # 200 V 400 Hz Line 1 Power OK
	setprop("tu154/instrumentation/ark-15[0]/powered", 1 ); 
	setprop("instrumentation/nav[2]/powered", 1 ); 
	setprop("tu154/systems/nvu/powered", 1.0 );
	# KURS-MP left
	if( getprop( "tu154/switches/KURS-MP-1" ) == 1.0 )
		{
		setprop("instrumentation/nav[0]/power-btn", 1 );
		setprop("instrumentation/nav[0]/serviceable", 1 );
		setprop("instrumentation/marker-beacon[0]/power-btn", 1 );
		setprop("instrumentation/marker-beacon[0]/serviceable", 1 );		
		}
	else	{
		setprop("instrumentation/nav[0]/power-btn", 0 );
		setprop("instrumentation/nav[0]/serviceable", 0 );
		setprop("instrumentation/marker-beacon[0]/power-btn", 0 );
		setprop("instrumentation/marker-beacon[0]/serviceable", 0 );
		}
	# GA3-1
	if( getprop( "tu154/switches/TKC-power-1" ) == 1.0 )
		setprop("instrumentation/heading-indicator[0]/serviceable", 1 );
	else	setprop("instrumentation/heading-indicator[0]/serviceable", 0 );
		
	# BGMK-1
	if( getprop( "tu154/switches/TKC-BGMK-1" ) == 1.0 )
		setprop("fdm/jsbsim/instrumentation/bgmk-failure-1", 0 );
	else	setprop("fdm/jsbsim/instrumentation/bgmk-failure-1", 1 );
	# BKK	
	if( getprop( "tu154/switches/BKK-power" ) == 1.0 )
		setprop("tu154/instrumentation/bkk/serviceable", 1 );
	else	setprop("tu154/instrumentation/bkk/serviceable", 0 );

	# DISS	
	if( getprop( "tu154/switches/DISS-power" ) == 1.0 )
		setprop("tu154/instrumentation/diss/powered", 1 );
	else	setprop("tu154/instrumentation/diss/powered", 0 );

	# RV-5M-1	
	if( getprop( "tu154/switches/RV-5-1" ) == 1.0 )
		setprop("tu154/instrumentation/rv-5m/serviceable", 1 );
	else	setprop("tu154/instrumentation/rv-5m/serviceable", 0 );
		
	# SVS	
	if( getprop( "tu154/switches/SVS-power" ) == 1.0 )
		setprop("tu154/systems/svs/powered", 1 );
	else	setprop("tu154/systems/svs/powered", 0 );

	# UVID-15	
	if( getprop( "tu154/switches/UVID" ) == 1.0 )
		setprop("tu154/instrumentation/altimeter[1]/powered", 1 );
	else	setprop("tu154/instrumentation/altimeter[1]/powered", 0 );

	# AGR
	if( getprop( "tu154/switches/AGR" ) == 1.0 )
		{
		setprop("instrumentation/attitude-indicator[3]/serviceable", 1 );
		setprop("instrumentation/attitude-indicator[3]/caged-flag", 0 );
		}
	else	{
		setprop("instrumentation/attitude-indicator[3]/serviceable", 0 );
		setprop("instrumentation/attitude-indicator[3]/caged-flag", 1 );
		bkk_shutdown(3);
		}
	# PKP-1
	if( getprop( "tu154/switches/PKP-left" ) == 1.0 )
		setprop("instrumentation/attitude-indicator[0]/serviceable", 1 );
	else { bkk_shutdown(0); }
	# AUASP
	if( getprop("tu154/switches/AUASP")==1 )
	     setprop("tu154/instrumentation/uap-12/powered", 1 );
 	else setprop("tu154/instrumentation/uap-12/powered", 0 );
	# EUP
	if( getprop("tu154/switches/EUP")==1 )
	     setprop("tu154/instrumentation/eup/powered", 1 );
 	else setprop("tu154/instrumentation/eup/powered", 0 );

	
	
	}


# turn off all consumers if bus has gone
else	{
	setprop("tu154/instrumentation/ark-15[0]/powered", 0 ); 
	setprop("instrumentation/nav[2]/powered", 0 ); 
	setprop("tu154/systems/nvu/powered", 0.0 );
	setprop("instrumentation/nav[0]/power-btn", 0 );
	setprop("instrumentation/nav[0]/serviceable", 0 );
	setprop("instrumentation/heading-indicator[0]/serviceable", 0 );
	setprop("fdm/jsbsim/instrumentation/bgmk-failure-1", 1 );
	setprop("tu154/instrumentation/bkk/serviceable", 0 );
	setprop("tu154/instrumentation/diss/powered", 0 );
	setprop("tu154/instrumentation/rv-5m/serviceable", 0 );
	setprop("tu154/systems/svs/powered", 0 );
	setprop("tu154/instrumentation/altimeter[1]/powered", 0 );
	setprop("instrumentation/attitude-indicator[3]/caged-flag", 1 );
	setprop("tu154/instrumentation/uap-12/powered", 0 );
	setprop("tu154/instrumentation/eup/powered", 0 );
	setprop("instrumentation/marker-beacon[0]/power-btn", 0 );
	setprop("instrumentation/marker-beacon[0]/serviceable", 0 );		
	
	bkk_shutdown(0);
	bkk_shutdown(1);
	}
	
ac200 = getprop( "tu154/systems/electrical/buses/AC3x200-bus-3L/volts" );
if( ac200 == nil ) return; # system not ready yet
if( ac200 > 150.0 )
	{ # 200 V 400 Hz Line 3 Power OK
	setprop("tu154/instrumentation/ark-15[1]/powered", 1 );
	# KURS-MP right
	if( getprop( "tu154/switches/KURS-MP-2" ) == 1.0 )
		{
		setprop("instrumentation/nav[1]/power-btn", 1 );
		setprop("instrumentation/nav[1]/serviceable", 1 );
		}
	else	{
		setprop("instrumentation/nav[1]/power-btn", 0 );
		setprop("instrumentation/nav[1]/serviceable", 0 );
		}
	# GA3-2
	if( getprop( "tu154/switches/TKC-power-2" ) == 1.0 )
		setprop("instrumentation/heading-indicator[1]/serviceable", 1 );
	else	setprop("instrumentation/heading-indicator[1]/serviceable", 0 );
		
	# BGMK-2
	if( getprop( "tu154/switches/TKC-BGMK-2" ) == 1.0 )
		setprop("fdm/jsbsim/instrumentation/bgmk-failure-2", 0 );
	else	setprop("fdm/jsbsim/instrumentation/bgmk-failure-2", 1 );

	# ABSU
	if( getprop( "tu154/switches/SAU-STU" ) == 1.0 )
		{

	     setprop("tu154/instrumentation/pn-6/serviceable", 1 );
		}
	else	{
	     setprop("tu154/systems/absu/serviceable", 0 );
	     setprop("tu154/instrumentation/pn-6/serviceable", 0 );
		}
# PKP-2
	if( getprop( "tu154/switches/PKP-right" ) == 1.0 )
		setprop("instrumentation/attitude-indicator[1]/serviceable", 1 );
	else { bkk_shutdown(1); }
# Contr
	if( getprop( "tu154/switches/MGV-contr" ) == 1.0 )
		setprop("instrumentation/attitude-indicator[2]/serviceable", 1 );
	else { bkk_shutdown(2); }
	
	
	}

else	{
	setprop("tu154/instrumentation/ark-15[1]/powered", 0 ); 
	setprop("instrumentation/nav[1]/power-btn", 0 );
	setprop("instrumentation/nav[1]/serviceable", 0 );
	setprop("instrumentation/heading-indicator[1]/serviceable", 0 );
	setprop("fdm/jsbsim/instrumentation/bgmk-failure-2", 1 );
        setprop("tu154/systems/absu/serviceable", 0 );
        setprop("tu154/instrumentation/pn-6/serviceable", 0 );
	
       	bkk_shutdown(2);
	bkk_shutdown(3);
	}
	

}

update_electrical();

# It's shoul be at different place...
# Gear animation support
# for animation only
gear_handler = func{
settimer(gear_handler, 0.0);
var rot = getprop("orientation/pitch-deg");
if( rot == nil ) return;
var offset = getprop("tu154/gear/offset");
if( offset == nil ) offset = 0.0;
var gain = getprop("tu154/gear/gain");
if( gain == nil ) gain = 1.0;
#Left gear
var pressure = getprop("gear/gear[1]/compression-norm");
if( pressure == nil ) return;
if( pressure < 0.1 )setprop("tu154/gear/rotation-left-deg", 8.5 );
else setprop("tu154/gear/rotation-left-deg", rot );
setprop("tu154/gear/compression-left-m", pressure*gain+offset );
# Right gear
pressure = getprop("gear/gear[2]/compression-norm");
if( pressure == nil ) return;
if( pressure < 0.1 ) setprop("tu154/gear/rotation-right-deg", 8.5 );
else setprop("tu154/gear/rotation-right-deg", rot );
setprop("tu154/gear/compression-right-m", pressure*gain+offset );

}

gear_handler();

# Set random gyro deviation
setprop("instrumentation/heading-indicator[0]/offset-deg", 359.0 * rand() );
setprop("instrumentation/heading-indicator[1]/offset-deg", 359.0 * rand() );

#save sound volume and deny sound for startup

var vol = getprop("/sim/sound/volume");
	  setprop("tu154/volume", vol);  
	  setprop("/sim/sound/volume", 0.0);
print("PNK started");
