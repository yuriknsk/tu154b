setprop("tu154/contrail/smoke1", 0 );
setprop("engines/engine/rpm", 0);
var smoke1 = func() {
      if((getprop("engines/engine/rpm") > 6200) and (getprop("position/altitude-agl-ft") > 50) and (getprop("position/altitude-agl-ft") < 1678)) {
                setprop("tu154/contrail/smoke1", 1 );
        } else {
                setprop("tu154/contrail/smoke1", 0 );
}
        settimer(smoke1, 1);
}
_setlistener("/sim/signals/fdm-initialized", func { smoke1() });

setprop("tu154/contrail/smoke2", 0 );
setprop("engines/engine[1]/rpm", 0);
var smoke2 = func() {
      if((getprop("engines/engine[1]/rpm") > 6200) and (getprop("position/altitude-agl-ft") > 50) and (getprop("position/altitude-agl-ft") < 1678)) {
                setprop("tu154/contrail/smoke2", 1 );
        } else {
                setprop("tu154/contrail/smoke2", 0 );
}
        settimer(smoke2, 1);
}
_setlistener("/sim/signals/fdm-initialized", func { smoke2() }); 

setprop("tu154/contrail/smoke3", 0 );
setprop("engines/engine[2]/rpm", 0);
var smoke3 = func() {
      if((getprop("engines/engine[2]/rpm") > 6200) and (getprop("position/altitude-agl-ft") > 50) and (getprop("position/altitude-agl-ft") < 1678)) {
                setprop("tu154/contrail/smoke3", 1 );
        } else {
                setprop("tu154/contrail/smoke3", 0 );
}
        settimer(smoke3, 1);
}
_setlistener("/sim/signals/fdm-initialized", func { smoke3() }); 
print ( "Smoke system started" );