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

setprop("tu154/contrail/contrail1", 0 );
setprop("engines/engine/rpm", 0);
var contrail1 = func() {
      if((getprop("engines/engine/rpm") > 6200) and (getprop("position/altitude-ft") > 21450) and (getprop("environment/temperature-degc") < -29)) {
                setprop("tu154/contrail/contrail1", 1 );
        } else {
                setprop("tu154/contrail/contrail1", 0 );
}
        settimer(contrail1, 1);
}
_setlistener("/sim/signals/fdm-initialized", func { contrail1() });

setprop("tu154/contrail/contrail2", 0 );
setprop("engines/engine[1]/rpm", 0);
var contrail2 = func() {
      if((getprop("engines/engine[1]/rpm") > 6200) and (getprop("position/altitude-ft") > 21450) and (getprop("environment/temperature-degc") < -29)) {
                setprop("tu154/contrail/contrail2", 1 );
        } else {
                setprop("tu154/contrail/contrail2", 0 );
}
        settimer(contrail2, 1);
}
_setlistener("/sim/signals/fdm-initialized", func { contrail2() });

setprop("tu154/contrail/contrail3", 0 );
setprop("engines/engine[2]/rpm", 0);
var contrail3 = func() {
      if((getprop("engines/engine[2]/rpm") > 6200) and (getprop("position/altitude-ft") > 21450) and (getprop("environment/temperature-degc") < -29)) {
                setprop("tu154/contrail/contrail3", 1 );
        } else {
                setprop("tu154/contrail/contrail3", 0 );
}
        settimer(contrail3, 1);
}
_setlistener("/sim/signals/fdm-initialized", func { contrail3() });

setprop("tu154/contrail/condensation", 0 );
var condensation = func() {
      if((getprop("environment/relative-humidity") > 95) and (getprop("environment/temperature-degc") > 0) and (getprop("velocities/airspeed-kt") > 180)) {
                setprop("tu154/contrail/condensation", 1 );
        } else {
                setprop("tu154/contrail/condensation", 0 );
}
        settimer(condensation, 1);
}
_setlistener("/sim/signals/fdm-initialized", func { condensation() });


print ( "Contrail system started" );