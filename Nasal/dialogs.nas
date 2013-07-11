var load_dlg=gui.Dialog.new("tu154/dialogs/Loads/dialog","Aircraft/tu154b/Dialogs/Loads.xml"); 
var fl= props.globals.getNode( "/fdm/jsbsim/tu154/systems/flight/fl" , 1 );
var dist= props.globals.getNode( "/fdm/jsbsim/tu154/systems/flight/dist" , 1 );
var altdist= props.globals.getNode( "/fdm/jsbsim/tu154/systems/flight/altdist" , 1 );
var f15t= props.globals.getNode( "/fdm/jsbsim/tu154/systems/flight/f15t" , 1 );
var f20t= props.globals.getNode( "/fdm/jsbsim/tu154/systems/flight/f20t" , 1 );
var f25t= props.globals.getNode( "/fdm/jsbsim/tu154/systems/flight/f25t" , 1 );
var ffullt= props.globals.getNode( "/fdm/jsbsim/tu154/systems/flight/ffullt" , 1 );
var fly_cap= props.globals.getNode( "/fdm/jsbsim/tu154/systems/flight/ffullt" , 1 );
var kg2lb = 2.2046226;
fl.setValue(9600.0);
dist.setValue(500.0);
f15t.setValue(1);
f20t.setValue(1);
f25t.setValue(1);
ffullt.setValue(1);
fly_cap.setValue(12750.0*kg2lb);

var calc_fly_by_tanks = func{
    fly_f = getprop("/fdm/jsbsim/aero/function/fly_fuel");
    print("test ref");
    var t1  = 3300;
    var t2l = 1500;
    var t2r = 1500;
    var t3l = 3225;
    var t3r = 3225;
    var t4 = 0.0;
    if( fly_f >= 12.750 and fly_f <= 15 ){
	var dft = (fly_f-12.750)*1000/4;
	t2l = t2l + dft;
	t2r = t2r + dft;
	t3l = t3l + dft;
	t3r = t3r + dft;
	
	setprop("/consumables/fuel/tank[0]/level-lb",tl*kg2lb );
	setprop("/consumables/fuel/tank[1]/level-lb",t2l*kg2lb );
	setprop("/consumables/fuel/tank[3]/level-lb",t2r*kg2lb );
	setprop("/consumables/fuel/tank[2]/level-lb",t3l*kg2lb );
	setprop("/consumables/fuel/tank[4]/level-lb",t3r*kg2lb );
	setprop("/consumables/fuel/tank[5]/level-lb",t4*kg2lb );

	
    }
    if( fly_f > 15 ){
	var dft = (fly_f-15)*1000/4;
	t1  = 3300;
	t2l = 4125/2;
	t2r = 4125/2;
	t3l = 7575/2;
	t3r = 7575/2;


	t2l = t2l + dft;
	t2r = t2r + dft;
	t3l = t3l + dft;
	t3r = t3r + dft;
	
	setprop("/consumables/fuel/tank[0]/level-lb",tl*kg2lb );
	setprop("/consumables/fuel/tank[1]/level-lb",t2l*kg2lb );
	setprop("/consumables/fuel/tank[3]/level-lb",t2r*kg2lb );
	setprop("/consumables/fuel/tank[2]/level-lb",t3l*kg2lb );
	setprop("/consumables/fuel/tank[4]/level-lb",t3r*kg2lb );
	setprop("/consumables/fuel/tank[5]/level-lb",t4*kg2lb );

	
    }
    return 0;
}

print("Load manager started");
