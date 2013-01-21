#
#
# Engine support
#
# Project Tupolev for FlightGear
#
# Yurik V. Nikiforoff, yurik.nsk@gmail.com
# Novosibirsk, Russia
# sep 2008, 2010
#

# Fuel support

var FUEL_UPDATE_PERIOD = 1.0;
var PORTIONER_TIME = 5.0;

var AUTO_LEVEL_1 = 1566;
var AUTO_LEVEL_2 = 264;
var AUTO_LEVEL_3 = 20;


var TANK_2_CONST = 4.0;
var TANK_3_CONST = 2.0;
var TANK_4_CONST = 2.0;

var TRANSFER_CONST = 0.74;
var ADJUST_CONST = 26.7;

var FUEL_ALT = 16404; # ft



var fuel_handler = func{
settimer( fuel_handler, FUEL_UPDATE_PERIOD );

# Check electrical power
#First, check DC
var pwr = getprop("tu154/systems/electrical/buses/DC27-bus-L/volts");
if( pwr == nil ) return;
# check 27V and exit if power off 
if(  pwr < 13.0 ){  
	blank_fuel_lamps(); 
	return; 
	}
	
# check AC
var ac200_1 = getprop("tu154/systems/electrical/buses/AC3x200-bus-1L/volts");
if( ac200_1 == nil ) ac200_1 = 0.0;
var ac200_2 = getprop("tu154/systems/electrical/buses/AC3x200-bus-2/volts");
if( ac200_2 == nil ) ac200_2 = 0.0;
var ac200_3 = getprop("tu154/systems/electrical/buses/AC3x200-bus-3L/volts");
if( ac200_3 == nil ) ac200_3 = 0.0;

pwr = ac200_1 + ac200_2 + ac200_3;
if( pwr < 130.0 ) pwr = 0.0;
	
var altitude = getprop("position/altitude-ft");
if( altitude == nil ) altitude = 0.0;


# Fuel tanks
# tank 1
var total = getprop("consumables/fuel/tank[0]/capacity-gal_us" );
if( total == nil ) total = 0.0;
var level = getprop("consumables/fuel/tank[0]/level-gal_us");
if( level == nil ) level = 0.0;
var total_consumed = getprop("tu154/systems/fuel/total-consumed-gal_us");
if( total_consumed == nil ) total_consumed = 0.0;
var total_fill = getprop("tu154/systems/fuel/total-fill-gal_us");
if( total_fill == nil ) total_fill = 0.0;

# Left wing
var tank_2_l = getprop("consumables/fuel/tank[1]/level-gal_us" );
if( tank_2_l == nil ) tank_2_l = 0.0;
var tank_3_l = getprop("consumables/fuel/tank[2]/level-gal_us" );
if( tank_3_l == nil ) tank_3_l = 0.0;
# Right wing
var tank_2_r = getprop("consumables/fuel/tank[3]/level-gal_us" );
if( tank_2_r == nil ) tank_2_r = 0.0;
var tank_3_r = getprop("consumables/fuel/tank[4]/level-gal_us" );
if( tank_3_r == nil ) tank_3_r = 0.0;
# Tank 4
var tank_4 = getprop("consumables/fuel/tank[5]/level-gal_us" );
if( tank_4 == nil ) tank_4_level = 0.0;

var density = getprop("consumables/fuel/tank[0]/density-ppg" );
if( density == nil ) density = 0.0;
density = density * 0.454;	# kg/gallon

# portioner
var portioner_flag = getprop("tu154/systems/fuel/portioner");
if( portioner_flag == nil ) portioner_flag = 0.0;
# ECN-319 fuel pumps
var ext_fuel_pump = getprop("tu154/systems/fuel/ecn-319-1");
if( ext_fuel_pump == nil ) ext_fuel_pump = 0.0;
var apu_fuel_pump = getprop("tu154/systems/fuel/ecn-319-2");
if( apu_fuel_pump == nil ) apu_fuel_pump = 0.0;

#switches
var autocon_ok = getprop("tu154/switches/fuel-autoconsumption-serviceable");
if( autocon_ok == nil ) autocon_ok = 0;
var autocon_selected = getprop("tu154/switches/fuel-autoconsumption-mode");
if( autocon_selected == nil ) autocon_selected = 0;
var autolevel = getprop("tu154/switches/fuel-autolevel-serviceable");
if( autolevel == nil ) autolevel = 0;

var trans_valve_1 = getprop("tu154/switches/transfer-valve-1");
if( trans_valve_1 == nil ) trans_valve_1 = 0;
var trans_valve_2 = getprop("tu154/switches/transfer-valve-2");
if( trans_valve_2 == nil ) trans_valve_2 = 0;

var fuel_meter = getprop("tu154/switches/fuel-meter-serviceable");
if( fuel_meter == nil ) fuel_meter = 0;
var cons_meter = getprop("tu154/switches/fuel-consumption-meter");
if( cons_meter == nil ) fuel_meter = 0;


var autolevel_1 = 0;
var autolevel_2 = 0;
var autolevel_3 = 0;
var autolevel_4 = 0;
var autolevel_failure = 0;

# cutoff valve
var cv1 = getprop("tu154/switches/fuel-cutoff-valve-1");
if( cv1 == nil ) cv1 = 0;
var cv2 = getprop("tu154/switches/fuel-cutoff-valve-2");
if( cv2 == nil ) cv2 = 0;
var cv3 = getprop("tu154/switches/fuel-cutoff-valve-3");
if( cv3 == nil ) cv3 = 0;

# stop engine levers
var cl1 = getprop("tu154/switches/cutoff-lever-1");
if( cl1 == nil ) cl1 = 0;
var cl2 = getprop("tu154/switches/cutoff-lever-2");
if( cl2 == nil ) cl2 = 0;
var cl3 = getprop("tu154/switches/cutoff-lever-3");
if( cl3 == nil ) cl3 = 0;


# APU support
var apu_cv = getprop("tu154/switches/APU-cutoff-valve-delay");
if( apu_cv == nil ) apu_cv = 0;
if( apu_cv > 0.9 ) apu_fuel_pump = 1.0;
else apu_fuel_pump = 0.0;
setprop("tu154/systems/fuel/ecn-319-2", apu_fuel_pump );

# manu pumps control
var p_1_1 = getprop("tu154/switches/pump-1-serviceable");
if( p_1_1 == nil ) p_1_1 = 0;
var p_1_2 = getprop("tu154/switches/pump-2-serviceable");
if( p_1_2 == nil ) p_1_2 = 0;
var p_1_3 = getprop("tu154/switches/pump-3-serviceable");
if( p_1_3 == nil ) p_1_3 = 0;
var p_1_4 = getprop("tu154/switches/pump-4-serviceable");
if( p_1_4 == nil ) p_1_4 = 0;

var p_2_l = getprop("tu154/switches/tank-2-left-serviceable");
if( p_2_l == nil ) p_2_l = 0;
var p_2_r = getprop("tu154/switches/tank-2-right-serviceable");
if( p_2_r == nil ) p_2_r = 0;
var p_3_l = getprop("tu154/switches/tank-3-left-serviceable");
if( p_3_l == nil ) p_3_l = 0;
var p_3_r = getprop("tu154/switches/tank-3-right-serviceable");
if( p_3_r == nil ) p_3_r = 0;
var p_4 = getprop("tu154/switches/tank-4-serviceable");
if( p_4 == nil ) p_4 = 0;

# Auto consume procedure
# check fuel and select auto consume mode
var auto_cons_state = 0;

if( (tank_2_l + tank_2_r) > AUTO_LEVEL_1 ) auto_cons_state = 1;
else auto_cons_state = 2;
if( (tank_2_l + tank_2_r) < 1.0 ) auto_cons_state = 3;
if( ((tank_3_l + tank_3_r) < 1.0) and ((tank_2_l + tank_2_r) < 1.0) ) auto_cons_state = 4;
if( tank_4 < 1.0 ) auto_cons_state = 5;
if( autocon_ok == 0 ) auto_cons_state = 5;

# fuel pump coeft
var k2_l = 0.0;
var k2_r = 0.0;
var k3_l = 0.0;
var k3_r = 0.0;
var k4 = 0.0;

if( autocon_ok == 1 ) {
      if( auto_cons_state == 1 ) { 	k2_l = TANK_2_CONST; 
					k2_r = TANK_2_CONST; }
					
      if( auto_cons_state == 2 ) { 	k2_l = TANK_2_CONST; 
					k2_r = TANK_2_CONST; 
					k3_l = TANK_3_CONST;
 					k3_r = TANK_3_CONST; }
 					
      if( auto_cons_state == 3 ) { 	k3_l = TANK_3_CONST; 
					k3_r = TANK_3_CONST; }
					
      if( auto_cons_state == 4 ) { 	k4 = TANK_4_CONST; }
      
# autolevel support
if( autolevel == 1 )
	{
	if( abs( tank_2_l - tank_2_r ) > AUTO_LEVEL_3 )
		{
		if( tank_2_l > tank_2_r ) autolevel_1 = 1;
		else autolevel_2 = 1;
		}
	if( abs( tank_3_l - tank_3_r ) > AUTO_LEVEL_3 )
		{
		if( tank_3_l > tank_3_r ) autolevel_3 = 1;
		else autolevel_4 = 1;
		}
 	if( abs( tank_2_l - tank_2_r ) > AUTO_LEVEL_2 ) autolevel_failure = 1;
 	if( abs( tank_3_l - tank_3_r ) > AUTO_LEVEL_2 ) autolevel_failure = 1;
	}
}
      
if( autolevel_failure == 0 )
	{
	# stop pump for auto level
	if( autolevel_1 == 1 ) k2_l = 0;
	if( autolevel_2 == 1 ) k2_r = 0;
	if( autolevel_3 == 1 ) k3_l = 0;
	if( autolevel_4 == 1 ) k3_r = 0;
	}
else	{ # clear flags cause autolevel failure at all
	autolevel_1 = 0;
	autolevel_2 = 0;
	autolevel_3 = 0;
	autolevel_4 = 0;
	}
# if auto mode deselected, let's set pumps manually      
if( autocon_selected == 0 ) {
	k2_l = p_2_l * TANK_2_CONST;	# 3 pumps per tanks 2, 2 per tanks 3, 2 per tank 4
	k2_r = p_2_r * TANK_2_CONST;
	k3_l = p_3_l * TANK_3_CONST;
	k3_r = p_3_r * TANK_3_CONST;
	k4 = p_4 * TANK_4_CONST;
	}
            
      
# check empty tanks
if( tank_2_l == 0.0 ) k2_l = 0.0;
if( tank_2_r == 0.0 ) k2_r = 0.0;
if( tank_3_l == 0.0 ) k3_l = 0.0;
if( tank_3_r == 0.0 ) k3_r = 0.0;
if( tank_4 == 0.0 ) k4 = 0.0;

# check AC power
if( pwr == 0.0 )
	{ # stop all pumps, automatic and manual mode
	k2_l = 0.0;
	k2_r = 0.0;
	k3_l = 0.0;
	k3_r = 0.0;
	k4 = 0.0;
	p_1_1 = 0.0;
	p_1_2 = 0.0;
	p_1_3 = 0.0;
	p_1_4 = 0.0;
	p_2_l = 0.0;
	p_2_r = 0.0;
	p_3_l = 0.0;
	p_3_r = 0.0;
	p_4 = 0.0;
	}
# lamps support
if( k2_l > 0 )
	{
	setprop( "tu154/lamps/pump-l-5", 1.0 );
	setprop( "tu154/lamps/pump-l-6", 1.0 );
	}
else	{
	setprop( "tu154/lamps/pump-l-5", 0.0 );
	setprop( "tu154/lamps/pump-l-6", 0.0 );
	}
if( k2_r > 0 )
	{
	setprop( "tu154/lamps/pump-r-5", 1.0 );
	setprop( "tu154/lamps/pump-r-6", 1.0 );
	}
else	{
	setprop( "tu154/lamps/pump-r-5", 0.0 );
	setprop( "tu154/lamps/pump-r-6", 0.0 );
	}
if( k3_l > 0 )
	{
	setprop( "tu154/lamps/pump-l-7", 1.0 );
	setprop( "tu154/lamps/pump-l-8", 1.0 );
	setprop( "tu154/lamps/pump-l-9", 1.0 );
	}
else	{
	setprop( "tu154/lamps/pump-l-7", 0.0 );
	setprop( "tu154/lamps/pump-l-8", 0.0 );
	setprop( "tu154/lamps/pump-l-9", 0.0 );
	}
if( k3_r > 0 )
	{
	setprop( "tu154/lamps/pump-r-7", 1.0 );
	setprop( "tu154/lamps/pump-r-8", 1.0 );
	setprop( "tu154/lamps/pump-r-9", 1.0 );
	}
else	{
	setprop( "tu154/lamps/pump-r-7", 0.0 );
	setprop( "tu154/lamps/pump-r-8", 0.0 );
	setprop( "tu154/lamps/pump-r-9", 0.0 );
	}
if( k4 > 0 )
	{
	setprop( "tu154/lamps/pump-10", 1.0 );
	setprop( "tu154/lamps/pump-11", 1.0 );
	}
else	{
	setprop( "tu154/lamps/pump-10", 0.0 );
	setprop( "tu154/lamps/pump-11", 0.0 );
	}

if( autocon_ok == 1 )	setprop( "tu154/lamps/auto-consumption-failure", 0.0 );
else	setprop( "tu154/lamps/auto-consumption-failure", 1.0 );	

if( auto_cons_state == 1 )	
	{
	setprop( "tu154/lamps/consumption-tank-2", 1.0 );
	setprop( "tu154/lamps/consumption-tank-3", 0.0 );
	setprop( "tu154/lamps/consumption-tank-4", 0.0 );	
	}
if( auto_cons_state == 2 )	
	{
	setprop( "tu154/lamps/consumption-tank-2", 1.0 );
	setprop( "tu154/lamps/consumption-tank-3", 1.0 );
	setprop( "tu154/lamps/consumption-tank-4", 0.0 );
	}
if( auto_cons_state == 3 )	
	{
	setprop( "tu154/lamps/consumption-tank-2", 0.0 );
	setprop( "tu154/lamps/consumption-tank-3", 1.0 );
	setprop( "tu154/lamps/consumption-tank-4", 0.0 );
	}
if( auto_cons_state == 4 )	
	{
	setprop( "tu154/lamps/consumption-tank-2", 0.0 );
	setprop( "tu154/lamps/consumption-tank-3", 0.0 );
	setprop( "tu154/lamps/consumption-tank-4", 1.0 );
	}
if( auto_cons_state == 5 )	
	{
	setprop( "tu154/lamps/consumption-tank-2", 0.0 );
	setprop( "tu154/lamps/consumption-tank-3", 0.0 );
	setprop( "tu154/lamps/consumption-tank-4", 0.0 );
	}
# auto level lamps
if( autolevel_1 == 1 ) setprop( "tu154/lamps/tank-2-l-level", 1.0 );
else setprop( "tu154/lamps/tank-2-l-level", 0.0 );
if( autolevel_2 == 1 ) setprop( "tu154/lamps/tank-2-r-level", 1.0 );
else setprop( "tu154/lamps/tank-2-r-level", 0.0 );
if( autolevel_3 == 1 ) setprop( "tu154/lamps/tank-3-l-level", 1.0 );
else setprop( "tu154/lamps/tank-3-l-level", 0.0 );
if( autolevel_4 == 1 ) setprop( "tu154/lamps/tank-3-r-level", 1.0 );
else setprop( "tu154/lamps/tank-3-r-level", 0.0 );

if( autolevel == 1 ) 
	{
	if( autocon_ok == 1 ) { setprop( "tu154/lamps/fuel-level-auto", 1.0 ); }
	else 	{
		setprop( "tu154/lamps/fuel-level-auto", 0.0 );
		setprop( "tu154/lamps/tank-2-l-level", 0.0 );
		setprop( "tu154/lamps/tank-2-r-level", 0.0 );
		setprop( "tu154/lamps/tank-3-l-level", 0.0 );
		setprop( "tu154/lamps/tank-3-r-level", 0.0 );
		}
	}
else 	{
	setprop( "tu154/lamps/fuel-level-auto", 0.0 );
	setprop( "tu154/lamps/tank-2-l-level", 0.0 );
	setprop( "tu154/lamps/tank-2-r-level", 0.0 );
	setprop( "tu154/lamps/tank-3-l-level", 0.0 );
	setprop( "tu154/lamps/tank-3-r-level", 0.0 );
	}

if( autolevel_failure == 1 ) 
	{
	setprop( "tu154/lamps/tank-2-l-level", 1.0 );
	setprop( "tu154/lamps/tank-2-r-level", 1.0 );
	setprop( "tu154/lamps/tank-3-l-level", 1.0 );
	setprop( "tu154/lamps/tank-3-r-level", 1.0 );
	setprop( "tu154/lamps/fuel-level-auto", 0.0 );
	}

if( trans_valve_1 > 0 )
	{
	setprop( "tu154/lamps/valve-l-1", 1.0 );
	setprop( "tu154/lamps/valve-r-1", 1.0 );
	}
else	{
	setprop( "tu154/lamps/valve-l-1", 0.0 );
	setprop( "tu154/lamps/valve-r-1", 0.0 );
	}
if( trans_valve_2 > 0 )
	{
	setprop( "tu154/lamps/valve-l-2", 1.0 );
	setprop( "tu154/lamps/valve-r-2", 1.0 );
	}
else	{
	setprop( "tu154/lamps/valve-l-2", 0.0 );
	setprop( "tu154/lamps/valve-r-2", 0.0 );
	}
	
if( p_1_1 > 0 ) setprop( "tu154/lamps/pump-1", 1.0 );
else setprop( "tu154/lamps/pump-1", 0.0 );
if( p_1_2 > 0 ) setprop( "tu154/lamps/pump-2", 1.0 );
else setprop( "tu154/lamps/pump-2", 0.0 );
if( p_1_3 > 0 ) setprop( "tu154/lamps/pump-3", 1.0 );
else setprop( "tu154/lamps/pump-3", 0.0 );
if( p_1_4 > 0 ) setprop( "tu154/lamps/pump-4", 1.0 );
else setprop( "tu154/lamps/pump-4", 0.0 );

if( cv1 > 0 ) setprop( "tu154/lamps/fuel-cutoff-1", 1.0 );
else setprop( "tu154/lamps/fuel-cutoff-1", 0.0 );
if( cv2 > 0 ) setprop( "tu154/lamps/fuel-cutoff-2", 1.0 );
else setprop( "tu154/lamps/fuel-cutoff-2", 0.0 );
if( cv3 > 0 ) setprop( "tu154/lamps/fuel-cutoff-3", 1.0 );
else setprop( "tu154/lamps/fuel-cutoff-3", 0.0 );

# end lamps support	


# portioner procedure
var pumps_pressure = k2_l + k2_r + k3_l + k3_r + k4;
var consumed = total - level;
var consumed_norm = level/total;
var overfull = 0.0;

if( consumed_norm < 0.9545 )    # -150 kg in tank 1
 {
  if( portioner_flag == 0.0 )	# avoid multiple start portioner procedure
  {
     if( pumps_pressure > 0 )   # deny portioner procedure if tanks 2,3,4 are empty
	{
	# total consume value - only for consume gauge
	setprop("tu154/systems/fuel/total-consumed-gal_us", total_consumed + consumed );
	
	# start portioner procedure
	consumed = consumed/pumps_pressure;
	portioner_flag = 1.0;
	setprop( "tu154/systems/fuel/portioner", portioner_flag );
	interpolate( "tu154/systems/fuel/portioner", 0.0, PORTIONER_TIME );
	# refueling tank 1
	setprop( "consumables/fuel/tank[0]/last-gal_us", total);
	interpolate( "consumables/fuel/tank[0]/level-gal_us", total, PORTIONER_TIME );
	# get fuel from tanks 2
	tank_2_l = tank_2_l - consumed * k2_l;
	if( tank_2_l < 1.0 ) tank_2_l = 0.0;
	interpolate( "consumables/fuel/tank[1]/level-gal_us", tank_2_l, PORTIONER_TIME );
	tank_2_r = tank_2_r - consumed * k2_r;
	if( tank_2_r < 1.0 ) tank_2_r = 0.0;
	interpolate( "consumables/fuel/tank[3]/level-gal_us", tank_2_r, PORTIONER_TIME );
	# get fuel from tanks 3
	tank_3_l = tank_3_l - consumed * k3_l;
	if( tank_3_l < 1.0 ) tank_3_l = 0.0;
	interpolate( "consumables/fuel/tank[2]/level-gal_us", tank_3_l, PORTIONER_TIME );
	tank_3_r = tank_3_r - consumed * k3_r;
	if( tank_3_r < 1.0 ) tank_3_r = 0.0;
	interpolate( "consumables/fuel/tank[4]/level-gal_us", tank_3_r, PORTIONER_TIME );
	# get fuel from tank 4
	tank_4 = tank_4 - consumed * k4;
	if( tank_4 < 1.0 ) tank_4 = 0.0;
	interpolate( "consumables/fuel/tank[5]/level-gal_us", tank_4, PORTIONER_TIME );
	  } 
	 } 
	} # end portioner procedure
	
# fuel transfer procedure
if( portioner_flag == 0.0 ) # don't transfer if portioner in operate 
	{
# From 3 to 2 fuel transfer
	if( trans_valve_1 == 1.0 )
		{
		#get
		consumed = ( k3_l + k3_r ) * TRANSFER_CONST;
		tank_3_l = tank_3_l - k3_l * TRANSFER_CONST;
		if( tank_3_l < 1.0 ) tank_3_l = 0.0;
		setprop( "consumables/fuel/tank[2]/level-gal_us", tank_3_l );
		tank_3_r = tank_3_r - k3_r * TRANSFER_CONST;
		if( tank_3_r < 1.0 ) tank_3_r = 0.0;
		setprop( "consumables/fuel/tank[4]/level-gal_us", tank_3_r );
		# put to tank 1
		level = level + consumed;
		if( level > total ){
			overfull = level - total;
			level = total;
			}
		setprop( "consumables/fuel/tank[0]/level-gal_us", level );
		}
# From 4 to 2
	if( trans_valve_2 == 1.0 )
		{
		#get
		consumed = k4 * TRANSFER_CONST;
		tank_4 = tank_4 - consumed;
		if( tank_4 < 1.0 ) tank_4 = 0.0;
		setprop( "consumables/fuel/tank[5]/level-gal_us", tank_4 );
		# put to tank 1
		level = level + consumed;
		if( level > total ){
			overfull = overfull + level - total;
			level = total;
			}
		setprop( "consumables/fuel/tank[0]/level-gal_us", level );
		}
# Puts fuel into
	tank_2_l = tank_2_l + overfull/2;
	tank_2_r = tank_2_r + overfull/2;
	setprop( "consumables/fuel/tank[1]/level-gal_us", tank_2_l );
	setprop( "consumables/fuel/tank[3]/level-gal_us", tank_2_r );
	} 
# end fuel transfer procedure

# fuel level meters support
setprop("tu154/systems/fuel/fuel-meter-serviceable", fuel_meter );
setprop("tu154/systems/fuel/fuel-consumption-serviceable", cons_meter );
# reload fuel level of cons tank
level = getprop("consumables/fuel/tank[0]/level-gal_us");
if( level == nil ) level = 0.0;
	
	if( fuel_meter == 1.0 ) {
interpolate("tu154/systems/fuel/tank-1-kg", level * density, FUEL_UPDATE_PERIOD );
interpolate("tu154/systems/fuel/tank-2-l-kg", tank_2_l * density, FUEL_UPDATE_PERIOD );
interpolate("tu154/systems/fuel/tank-2-r-kg", tank_2_r * density, FUEL_UPDATE_PERIOD );
interpolate("tu154/systems/fuel/tank-3-l-kg", tank_3_l * density, FUEL_UPDATE_PERIOD );
interpolate("tu154/systems/fuel/tank-3-r-kg", tank_3_r * density, FUEL_UPDATE_PERIOD );
interpolate("tu154/systems/fuel/tank-4-kg", tank_4 * density, FUEL_UPDATE_PERIOD );
# total
interpolate( "tu154/systems/fuel/total-kg", 
 ( level + tank_2_l + tank_2_r + tank_3_l + tank_3_r + tank_4 ) * density,
 FUEL_UPDATE_PERIOD );
	}
	else {
interpolate("tu154/systems/fuel/tank-1-kg", 0.0, FUEL_UPDATE_PERIOD );
interpolate("tu154/systems/fuel/tank-2-l-kg", 0.0, FUEL_UPDATE_PERIOD );
interpolate("tu154/systems/fuel/tank-2-r-kg", 0.0, FUEL_UPDATE_PERIOD );
interpolate("tu154/systems/fuel/tank-3-l-kg", 0.0, FUEL_UPDATE_PERIOD );
interpolate("tu154/systems/fuel/tank-3-r-kg", 0.0, FUEL_UPDATE_PERIOD );
interpolate("tu154/systems/fuel/tank-4-kg", 0.0, FUEL_UPDATE_PERIOD );
interpolate( "tu154/systems/fuel/total-kg", 0.0, FUEL_UPDATE_PERIOD );
	}

# Fuel consume meter procedure
	
if( cons_meter == 1.0 ) {
	total_consumed = getprop("tu154/systems/fuel/total-consumed-gal_us" );
	if( total_consumed == nil ) total_consumed = 0.0;
	level = ( total_fill - total_consumed ) * density;
	if( level < 0.0 ) level = 0.0;
	interpolate("tu154/systems/fuel/rest-kg", level, FUEL_UPDATE_PERIOD );
	}
else	{
	interpolate("tu154/systems/fuel/rest-kg", 0.0, FUEL_UPDATE_PERIOD );
	}
	
# cutoff procedure
if( cv1 < 1.0 ) setprop( "controls/engines/engine[0]/cutoff", 1 );
if( cv2 < 1.0 ) setprop( "controls/engines/engine[1]/cutoff", 1 );
if( cv3 < 1.0 ) setprop( "controls/engines/engine[2]/cutoff", 1 );	
# stop levers
if( cl1 < 1.0 ) setprop( "controls/engines/engine[0]/cutoff", 1 );
if( cl2 < 1.0 ) setprop( "controls/engines/engine[1]/cutoff", 1 );
if( cl3 < 1.0 ) setprop( "controls/engines/engine[2]/cutoff", 1 );	


var tank_1_pumps = p_1_1 + p_1_2 + p_1_3 + p_1_4 + ext_fuel_pump;
if( tank_1_pumps < 1.0 )
	{
	if( altitude > FUEL_ALT ) {
         setprop( "controls/engines/engine[0]/cutoff", 1 );
         setprop( "controls/engines/engine[1]/cutoff", 1 );
         setprop( "controls/engines/engine[2]/cutoff", 1 );
		}}

# P fuel indicators
# reload fuel level of cons tank
level = getprop("consumables/fuel/tank[0]/level-gal_us");
if( level == nil ) level = 0.0;


if( level > 0.0 ){
	if( apu_fuel_pump > 0 ) 
		setprop( "tu154/systems/electrical/indicators/apu-fuel-pressure", 1.0 );
	else	setprop( "tu154/systems/electrical/indicators/apu-fuel-pressure", 0.0 );
	if( tank_1_pumps > 0.0 ){
 if( cv1 > 0.0 ){ setprop( "tu154/systems/electrical/indicators/engine-1/p-fuel", 0 ); }
 else { setprop( "tu154/systems/electrical/indicators/engine-1/p-fuel", 1 ); }
 if( cv2 > 0.0 ){ setprop( "tu154/systems/electrical/indicators/engine-2/p-fuel", 0 ); }
 else { setprop( "tu154/systems/electrical/indicators/engine-2/p-fuel", 1 ); }
 if( cv3 > 0.0 ){ setprop( "tu154/systems/electrical/indicators/engine-3/p-fuel", 0 ); }
 else { setprop( "tu154/systems/electrical/indicators/engine-3/p-fuel", 1 ); }
	}
	else {
      setprop( "tu154/systems/electrical/indicators/engine-1/p-fuel", 1 ); 
      setprop( "tu154/systems/electrical/indicators/engine-2/p-fuel", 1 ); 
      setprop( "tu154/systems/electrical/indicators/engine-3/p-fuel", 1 );
	}
     }
else { 
 setprop( "tu154/systems/electrical/indicators/engine-1/p-fuel", 1 ); 
 setprop( "tu154/systems/electrical/indicators/engine-2/p-fuel", 1 ); 
 setprop( "tu154/systems/electrical/indicators/engine-3/p-fuel", 1 ); 
 setprop( "tu154/systems/electrical/indicators/apu-fuel-pressure", 0.0 );
     }


# end cutoff procedure
} # end fuel handler

var blank_fuel_lamps = func{
	setprop( "tu154/lamps/pump-l-5", 0.0 );
	setprop( "tu154/lamps/pump-l-6", 0.0 );
	setprop( "tu154/lamps/pump-r-5", 0.0 );
	setprop( "tu154/lamps/pump-r-6", 0.0 );
	setprop( "tu154/lamps/pump-l-7", 0.0 );
	setprop( "tu154/lamps/pump-l-8", 0.0 );
	setprop( "tu154/lamps/pump-l-9", 0.0 );
	setprop( "tu154/lamps/pump-r-7", 0.0 );
	setprop( "tu154/lamps/pump-r-8", 0.0 );
	setprop( "tu154/lamps/pump-r-9", 0.0 );
	setprop( "tu154/lamps/pump-10", 0.0 );
	setprop( "tu154/lamps/pump-11", 0.0 );
	setprop( "tu154/lamps/auto-consumption-failure", 0.0 );
	setprop( "tu154/lamps/consumption-tank-2", 0.0 );
	setprop( "tu154/lamps/consumption-tank-3", 0.0 );
	setprop( "tu154/lamps/consumption-tank-4", 0.0 );	
        setprop( "tu154/lamps/tank-2-l-level", 0.0 );
        setprop( "tu154/lamps/tank-2-r-level", 0.0 );
        setprop( "tu154/lamps/tank-3-l-level", 0.0 );
        setprop( "tu154/lamps/tank-3-r-level", 0.0 );
        setprop( "tu154/lamps/fuel-level-auto", 0.0 );
        setprop( "tu154/lamps/tank-2-l-level", 0.0 );
        setprop( "tu154/lamps/tank-2-r-level", 0.0 );
        setprop( "tu154/lamps/tank-3-l-level", 0.0 );
        setprop( "tu154/lamps/tank-3-r-level", 0.0 );
	setprop( "tu154/lamps/valve-l-1", 0.0 );
	setprop( "tu154/lamps/valve-r-1", 0.0 );
	setprop( "tu154/lamps/valve-l-2", 0.0 );
	setprop( "tu154/lamps/valve-r-2", 0.0 );
	setprop( "tu154/lamps/pump-1", 0.0 );
	setprop( "tu154/lamps/pump-2", 0.0 );
	setprop( "tu154/lamps/pump-3", 0.0 );
	setprop( "tu154/lamps/pump-4", 0.0 );
	setprop( "tu154/lamps/fuel-cutoff-1", 0.0 );
	setprop( "tu154/lamps/fuel-cutoff-2", 0.0 );
	setprop( "tu154/lamps/fuel-cutoff-3", 0.0 );
	setprop( "tu154/systems/electrical/indicators/apu-fuel-pressure", 0.0 );
	
        interpolate("tu154/systems/fuel/tank-1-kg", 0.0, FUEL_UPDATE_PERIOD );
        interpolate("tu154/systems/fuel/tank-2-l-kg", 0.0, FUEL_UPDATE_PERIOD );
        interpolate("tu154/systems/fuel/tank-2-r-kg", 0.0, FUEL_UPDATE_PERIOD );
        interpolate("tu154/systems/fuel/tank-3-l-kg", 0.0, FUEL_UPDATE_PERIOD );
        interpolate("tu154/systems/fuel/tank-3-r-kg", 0.0, FUEL_UPDATE_PERIOD );
        interpolate("tu154/systems/fuel/tank-4-kg", 0.0, FUEL_UPDATE_PERIOD );
        interpolate( "tu154/systems/fuel/total-kg", 0.0, FUEL_UPDATE_PERIOD );

}


# Fuel consume meter adjust
cons_meter_adjust = func{
var level = getprop("tu154/systems/fuel/total-fill-gal_us");
if( level == nil ) level = 0.0;
level = level + arg[0] * ADJUST_CONST;
if( level < 0.0 ) level = 0.0;
setprop("tu154/systems/fuel/total-fill-gal_us", level);
}

# load buses

# start fuel support
fuel_handler();

print("Fuel support started");
