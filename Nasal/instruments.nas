#
# NASAL instruments for TU-154B
# Yurik V. Nikiforoff, yurik.nsk@gmail.com
# Novosibirsk, Russia
# jun 2007, 2013
#


######################################################################
#
# Utility classes and functions.
#

# Chase() works like interpolate(), but tracks value changes, supports
# wraparound, and allows cancellation.
var Chase = {
    _active: {},
    new: func(src, dst, delay, wrap=nil) {
        var m = {
            parents: [Chase],
            src: src,
            dst: dst,
            left: delay,
            wrap: wrap,
            ts: systime()
        };
        var om = Chase._active[src];
        if (om != nil)
            om.del();
        Chase._active[src] = m;
        m.t = maketimer(0, m, Chase._update);
        m.t.start();
        return m;
    },
    active: func {
        return (Chase._active[me.src] == me);
    },
    del: func {
        Chase._active[me.src] = nil;
        me.t.stop();
    },
    _update: func {
        var ts = systime();
        var passed = ts - me.ts;
        var dv = (num(me.dst) == nil ? getprop(me.dst) : me.dst);
        if (me.left > passed) {
            var sv = getprop(me.src);
            if (dv == nil)
                dv = sv;
            var delta = dv - sv;
            var w = (me.wrap != nil
                     and abs(delta) > (me.wrap[1] - me.wrap[0]) / 2.0);
            if (w) {
                if (sv < dv)
                    delta -= me.wrap[1] - me.wrap[0];
                else
                    delta += me.wrap[1] - me.wrap[0];
            }
            var nsv = sv + delta * passed / me.left;
            if (w) {
                if (sv < dv)
                    nsv += (nsv < me.wrap[0] ? me.wrap[1] : 0);
                else
                    nsv -= (nsv >= me.wrap[1] ? me.wrap[1] : 0);
            }
            setprop(me.src, nsv);
            me.ts = ts;
            me.left -= passed;
        } else {
            setprop(me.src, dv);
            me.t.stop();
        }
    }
};

# Smooth property re-aliasing.
var realias = func(src, dst, delay, wrap=nil) {
    if (src == dst)
        return;

    var obj = props.globals.getNode(src, 1);
    var v = getprop(src);
    obj.unalias();
    if (v != nil) {
        setprop(src, v);
        var c = Chase.new(src, dst, delay, wrap);
        settimer(func {
            if (c.active()) {
                c.del();
                if (num(dst) == nil)
                    obj.alias(dst);
                else
                    setprop(src, dst);
            }
        }, delay);
    } else {
        if (num(dst) == nil)
            obj.alias(dst);
        else
            setprop(src, dst);
    }
}


######################################################################
#
# PNP
#
# Operation:
#
# Both left and right PNPs are instances of the same pnp.xml model
# parameterized with corresponding properties, and behave identically.
# Each PNP has five modes of operation: normal (no indication), NVU
# (NV indication), VOR1 and VOR2 (both have VOR indication), and SP
# (SP indication).  Left PNP mode is selected with ABSU mode buttons
# (Reset and Heading buttons correspond to normal mode, Landing button
# corresponds to SP mode, and the rest button correspondence is
# one-to-one).  Right PNP mode is selected with the dedicated switch
# on PN-6.
#
# In all modes of PNP operation left handle sets heading (yellow
# rotating marks) and right handle sets course in degrees (shown with
# digit wheels in the top right corner of PNP).  In all modes but NVU
# course needle also points to the dialed course.  In NVU mode course
# needle points to current NVU course from active V-140 set.
#
# Course deflection needle in VOR1 or VOR2 mode shows offset in
# degrees of the VOR radial selected on corresponding KURS-MP up to 10
# degrees at full scale.  In SP mode it shows offset in degrees of the
# ILS-LOC radial (again, up to 10 degrees; ILS frequency is set in
# left KURS-MP set). In NVU mode the needle shows Z offset of NVU
# course in km up to 4 km at full scale (that is, negated Z value from
# active NVU counter clipped to 4 km).  In normal mode (or when
# there's no VOR or ILS-LOC in range) the needle is not deflected and
# course blanker is shown.
#
# Glideslope deflection needle in SP mode shows offset in degrees to
# the ILS-GS up to 0.7 degrees at full scale (ILS frequency is set in
# left KURS-MP set).  In other modes (or when there's no ILS-GS in
# range) the needle is not deflected and glideslope blanker is shown.
#
# Note that VOR1 and SP modes are mutually exclusive: when you tune
# left KURS-MP to VOR then PNP in SP mode will be blanked on both
# channels.  Likewise, when you tune left KURS-MP to ILS then PNP in
# VOR1 mode will be blanked on both channels.  Also note that tuning
# right KURS-MP to ILS will result in VOR2 mode blanked on both
# channels.
#
# When /tu154/instrumentation/distance-to-pnp is set to true distance
# digit wheels show active abs(S) in NVU mode, DME value in VOR modes,
# ILS-DME value in SP mode, or blanked zeroes in normal mode or when
# there's no DME in range.
#
#
# Implementation:
#
# With setlistener() we track changes to all properties that determine
# PNP mode and blankers (but not needle input values).  When any such
# change occurs we recompute PNP mode, set blankers accordingly, and
# alias() PNP needle properties to relevant inputs so that needle
# value updates happen implicitly after that.  This way we track only
# infrequent changes (like button presses or switch toggling), but do
# not have to recompute needle values every frame.  The only exception
# is active NVU Z offset which we can't alias directly but have to
# scale, normalize, and negate, and which is updated every frame when
# NVU is active.
#

# Smooth DME updates.
var dme_distance = func(i) {
    var distance = getprop("instrumentation/dme["~i~"]/indicated-distance-nm");
    # We ignore exact zero distance because it signifies out of range
    # condition, and we want to keep last value in this case.  Within DME
    # proximity exact zero distance is highly unlikely, and close to zero
    # update will be enough.
    if (distance) {
        distance = int(distance * 18.52) * 100;
        interpolate("tu154/instrumentation/dme["~i~"]/distance", distance, 0.2);
    }
}
setlistener("instrumentation/dme[0]/indicated-distance-nm",
            func { dme_distance(0) }, 0, 0);
setlistener("instrumentation/dme[1]/indicated-distance-nm",
            func { dme_distance(1) }, 0, 0);
setlistener("instrumentation/dme[2]/indicated-distance-nm",
            func { dme_distance(2) }, 0, 0);

# Normalize NVU Z offset.
var nvu_z_offset_norm = func(i) {
    var offset = getprop("fdm/jsbsim/instrumentation/aircraft-integrator-z-"~i);
    offset /= 4000;
    if (offset < -1)
        offset = -1;
    else if (offset > 1)
        offset = 1;
    setprop("tu154/instrumentation/nvu/z-"~i~"-offset-norm", -offset);
}
setlistener("fdm/jsbsim/instrumentation/aircraft-integrator-z-1",
            func { nvu_z_offset_norm(1) }, 1);
setlistener("fdm/jsbsim/instrumentation/aircraft-integrator-z-2",
            func { nvu_z_offset_norm(2) }, 1);

var pnp_mode_update = func(i, mode) {
    var plane = "/tu154/instrumentation/pnp["~i~"]/plane-dialed";
    var defl_course = 0;
    var defl_gs = 0;
    var distance = getprop("/tu154/instrumentation/pnp["~i~"]/distance");
    var blank_course = 1;
    var blank_gs = 1;
    var blank_dist = 1;
    if (mode == 1 and getprop("tu154/systems/nvu/serviceable")) { # NVU
        if (getprop("fdm/jsbsim/instrumentation/nvu-selector")) {
            plane = "fdm/jsbsim/instrumentation/zpu-deg-1";
            defl_course = "tu154/instrumentation/nvu/z-1-offset-norm";
        } else {
            plane = "fdm/jsbsim/instrumentation/zpu-deg-2";
            defl_course = "tu154/instrumentation/nvu/z-2-offset-norm";
        }
        blank_course = 0;
        if (getprop("tu154/instrumentation/distance-to-pnp")) {
            if (getprop("fdm/jsbsim/instrumentation/nvu-selector"))
                distance = "fdm/jsbsim/instrumentation/aircraft-integrator-s-1";
            else
                distance = "fdm/jsbsim/instrumentation/aircraft-integrator-s-2";
            blank_dist = 0;
        }
    } else if (mode == 2 and !getprop("instrumentation/nav[0]/nav-loc")) { #VOR1
        if (getprop("instrumentation/nav[0]/in-range")) {
            defl_course =
                "instrumentation/nav[0]/heading-needle-deflection-norm";
            blank_course = 0;
        }
        if (getprop("tu154/instrumentation/distance-to-pnp")
            and getprop("instrumentation/dme[0]/in-range")) {
            distance = "tu154/instrumentation/dme[0]/distance";
            blank_dist = 0;
        }
    } else if (mode == 3 and !getprop("instrumentation/nav[1]/nav-loc")) { #VOR2
        if (getprop("instrumentation/nav[1]/in-range")) {
            defl_course =
                "instrumentation/nav[1]/heading-needle-deflection-norm";
            blank_course = 0;
        }
        if (getprop("tu154/instrumentation/distance-to-pnp")
            and getprop("instrumentation/dme[1]/in-range")) {
            distance = "tu154/instrumentation/dme[1]/distance";
            blank_dist = 0;
        }
    } else if (mode == 4 and getprop("instrumentation/nav[0]/nav-loc")) { # SP
        if (getprop("instrumentation/nav[0]/in-range")) {
            defl_course =
                "instrumentation/nav[0]/heading-needle-deflection-norm";
            blank_course = 0;
        }
        if (getprop("instrumentation/nav[0]/gs-in-range")) {
            defl_gs = "instrumentation/nav[0]/gs-needle-deflection-norm";
            blank_gs = 0;
        }
        if (getprop("tu154/instrumentation/distance-to-pnp")
            and getprop("instrumentation/dme[0]/in-range")) {
            distance = "tu154/instrumentation/dme[0]/distance";
            blank_dist = 0;
        }
    }
    setprop("tu154/instrumentation/pnp["~i~"]/mode", mode);
    realias("/tu154/instrumentation/pnp["~i~"]/plane-deg", plane, 0.5,
            [0, 360]);
    realias("/tu154/instrumentation/pnp["~i~"]/defl-course", defl_course, 0.5);
    realias("/tu154/instrumentation/pnp["~i~"]/defl-gs", defl_gs, 0.5);
    realias("/tu154/instrumentation/pnp["~i~"]/distance", distance, 0.5);
    setprop("tu154/instrumentation/pnp["~i~"]/blank-course", blank_course);
    setprop("tu154/instrumentation/pnp["~i~"]/blank-gs", blank_gs);
    setprop("tu154/instrumentation/pnp["~i~"]/blank-dist", blank_dist);
}

# PNP mode for first pilot.
var pnp0_mode_update = func {
    var sel = getprop("fdm/jsbsim/ap/roll-selector") or 0;
    if (!getprop("instrumentation/heading-indicator[0]/serviceable")
        or !getprop("tu154/systems/absu/serviceable"))
        sel = -1;

    var mode = 0; # Disabled or Stab or ZK (sel == 0 or sel == 1 or sel == 2)
    if (sel == 3) { # VOR
        mode = 2;
        if (getprop("tu154/instrumentation/pn-5/az-2"))
            mode = 3;
    } else if (sel == 4) { # NVU
        mode = 1;
    } else if (sel == 5) { # SP
        mode = 4;
    } else if (sel != -1) {
        if (getprop("tu154/switches/pn-5-navigac") == 0
            and getprop("tu154/switches/pn-5-posadk") == 1
            and getprop("instrumentation/nav[0]/nav-loc")
            and (getprop("instrumentation/nav[0]/in-range")
                 or getprop("instrumentation/nav[0]/gs-in-range")))
            mode = 4;
    }
    pnp_mode_update(0, mode);
}

# PNP mode for second pilot.
var pnp1_mode_update = func {
    var sel = getprop("tu154/switches/pn-6-selector") or 0;
    if (!getprop("instrumentation/heading-indicator[1]/serviceable"))
        sel = 0;
    pnp_mode_update(1, sel);
}

var pnp_both_mode_update = func {
    pnp0_mode_update();
    pnp1_mode_update();
}

setlistener("tu154/systems/absu/serviceable", pnp0_mode_update, 0, 0);
setlistener("tu154/switches/pn-5-navigac", pnp0_mode_update);
setlistener("tu154/switches/pn-5-posadk", pnp0_mode_update);
setlistener("fdm/jsbsim/ap/roll-selector", pnp0_mode_update);
setlistener("instrumentation/heading-indicator[0]/serviceable",
            pnp0_mode_update, 1, 0);

setlistener("tu154/switches/pn-6-selector", pnp1_mode_update);
setlistener("instrumentation/heading-indicator[1]/serviceable",
            pnp1_mode_update, 1, 0);

setlistener("tu154/systems/nvu/serviceable", pnp_both_mode_update, 0, 0);
setlistener("fdm/jsbsim/instrumentation/nvu-selector", pnp_both_mode_update);
setlistener("tu154/instrumentation/distance-to-pnp", pnp_both_mode_update);
setlistener("instrumentation/dme[0]/in-range", pnp_both_mode_update, 0, 0);
setlistener("instrumentation/dme[1]/in-range", pnp_both_mode_update, 0, 0);
setlistener("instrumentation/nav[0]/nav-loc", pnp_both_mode_update, 0, 0);
setlistener("instrumentation/nav[1]/nav-loc", pnp_both_mode_update, 0, 0);
setlistener("instrumentation/nav[0]/in-range", pnp_both_mode_update, 0, 0);
setlistener("instrumentation/nav[1]/in-range", pnp_both_mode_update, 0, 0);
setlistener("instrumentation/nav[0]/gs-in-range", pnp_both_mode_update, 0, 0);


######################################################################
#
# IDR-1
#
# Implementation:
#
# Note that DME cannel in VOR-DME and ILS-DME operates in the same way
# so IDR-1 works with both.
#

var idr_mode_update = func(i, selector) {
    var sel = getprop(selector);
    if (int(sel) != sel) # The switch is in transition.
        return;
    var ni = (sel ? 3 - sel : 0); # 2 -> 1, 1 -> 2, 0 -> 0
    var distance = getprop("/tu154/instrumentation/idr-1["~i~"]/distance");
    var blank = 1;
    if (getprop("instrumentation/dme["~ni~"]/in-range")) {
        distance = "tu154/instrumentation/dme["~ni~"]/distance";
        blank = 0;
    }
    realias("/tu154/instrumentation/idr-1["~i~"]/distance", distance, 0.5);
    setprop("tu154/instrumentation/idr-1["~i~"]/blank", blank);
}

var idr0_mode_update = func {
    idr_mode_update(0, "tu154/switches/capt-idr-selector");
}

var idr1_mode_update = func {
    idr_mode_update(1, "tu154/switches/copilot-idr-selector");
}

var idr_both_mode_update = func {
    idr0_mode_update();
    idr1_mode_update();
}

setlistener("tu154/switches/capt-idr-selector", idr0_mode_update, 1);

setlistener("tu154/switches/copilot-idr-selector", idr1_mode_update, 1);

setlistener("instrumentation/dme[0]/in-range", idr_both_mode_update, 0, 0);
setlistener("instrumentation/dme[1]/in-range", idr_both_mode_update, 0, 0);
setlistener("instrumentation/dme[2]/in-range", idr_both_mode_update, 0, 0);


######################################################################
#
# RV-5M
#

var rv_altitude_update = func {
    var alt_m = getprop("position/altitude-agl-ft") * 0.3048;
    settimer(rv_altitude_update, (alt_m < 1200 ? 0.1 : (alt_m - 900) / 300));
    if (alt_m > 0) {
        var pitch_deg = getprop("orientation/pitch-deg");
        var roll_deg = getprop("orientation/roll-deg");
        if (-90 < pitch_deg and pitch_deg < 90
            and -90 < roll_deg and roll_deg < 90) {
            var beam_rad = math.acos(math.cos(pitch_deg / 57.3)
                                     * math.cos(roll_deg / 57.3));
            if (beam_rad > 0.262) { # > 15 degrees
                beam_rad -= 0.262;
                alt_m /= math.cos(beam_rad);
            }
            if (alt_m > 850)
                alt_m = 850;
        } else {
            alt_m = 850;
        }
    } else {
        alt_m = 0;
    }
    setprop("fdm/jsbsim/instrumentation/indicated-altitude-m", alt_m);
}
rv_altitude_update();

var rv_mode_update = func(i, toggled) {
    # Temporal hack to wait electrical initialization.
    if (getprop("tu154/switches/main-battery") == nil) {
        settimer(func { rv_mode_update(i, 1) }, 0.5);
        return;
    }

    if (i == 0) {
        var ac_obj = electrical.AC3x200_bus_1L;
        var volts = "tu154/systems/electrical/buses/AC3x200-bus-1L/volts";
    } else {
        var ac_obj = electrical.AC3x200_bus_3R;
        var volts = "tu154/systems/electrical/buses/AC3x200-bus-3L/volts";
    }
    volts = getprop(volts) or 0;
    var powered = (volts > 150.0);
    var altitude = "tu154/instrumentation/rv-5m["~i~"]/altitude";
    var switch = "RV-5-"~(i + 1);
    var warn = 0;
    var blank = 1;
    if (powered and getprop("tu154/switches/"~switch)) {
        if (toggled) {
            ac_obj.add_output(switch, 10.0);
            realias(altitude, 850, 3);
            settimer(func {
                realias(altitude,
                        "fdm/jsbsim/instrumentation/indicated-altitude-m", 3);
                settimer(func { rv_mode_update(i, 0) }, 3);
            }, 15); # Up to 2 minutes in reality.
        } else {
            warn = (getprop(altitude) <=
                    getprop("tu154/instrumentation/rv-5m["~i~"]/dialed"));
            blank = 0;
            var agl = getprop("position/altitude-agl-ft");
            if (agl < 4000) { # < ~1200m
                settimer(func { rv_mode_update(i, 0) }, 0.1);
            } else {
                # FIXME: RV should be switched off, but for now we have
                # to track power state.
                settimer(func { rv_mode_update(i, 0) }, 0.5);
            }
        }
    } else {
        if (!toggled) {
            ac_obj.rm_output(switch);
            realias(altitude, 0, 3);
        }
        settimer(func { rv_mode_update(i, 1) }, 0.5);
    }

    setprop("tu154/instrumentation/rv-5m["~i~"]/warn", warn);
    setprop("tu154/instrumentation/rv-5m["~i~"]/blank", blank);
}

rv_mode_update(0, 1);
rv_mode_update(1, 1);


######################################################################
#
# IKU-1
#

var iku_vor_bearing = func(i) {
    setprop("tu154/instrumentation/nav["~i~"]/bearing-deg",
            getprop("instrumentation/nav["~i~"]/radials/reciprocal-radial-deg")
            - getprop("fdm/jsbsim/instrumentation/bgmk-"~(i+1)));
}
iku_vor_bearing_timer = [maketimer(0.1, func { iku_vor_bearing(0) }),
                         maketimer(0.1, func { iku_vor_bearing(1) })];

var iku_mode_update = func(i, b) {
    var sel = getprop("tu154/instrumentation/iku-1["~i~"]/mode-"~b);
    var bearing = 90;
    var j = b - 1;
    if (sel) {
        if (getprop("instrumentation/nav["~j~"]/in-range")
            and !getprop("instrumentation/nav["~j~"]/nav-loc")) {
            iku_vor_bearing_timer[j].start();
            bearing = "tu154/instrumentation/nav["~j~"]/bearing-deg";
        } else {
            iku_vor_bearing_timer[j].stop();
        }
    } else {
        iku_vor_bearing_timer[j].stop();
        if (getprop("instrumentation/adf["~j~"]/in-range"))
            bearing = "instrumentation/adf["~j~"]/indicated-bearing-deg";
    }

    interpolate("tu154/instrumentation/iku-1["~i~"]/trans-"~b, sel, 0.1);
    realias("tu154/instrumentation/iku-1["~i~"]/heading-"~b, bearing, 0.5,
            [0, 360]);
}

var iku0_mode1_update = func {
    iku_mode_update(0, 1);
}

var iku0_mode2_update = func {
    iku_mode_update(0, 2);
}

var iku1_mode1_update = func {
    iku_mode_update(1, 1);
}

var iku1_mode2_update = func {
    iku_mode_update(1, 2);
}

var iku_both_mode1_update = func {
    iku0_mode1_update();
    iku1_mode1_update();
}

var iku_both_mode2_update = func {
    iku0_mode2_update();
    iku1_mode2_update();
}

setlistener("instrumentation/adf[0]/in-range", iku_both_mode1_update, 0, 0);
setlistener("instrumentation/nav[0]/in-range", iku_both_mode1_update, 0, 0);
setlistener("instrumentation/nav[0]/nav-loc", iku_both_mode1_update, 0, 0);
setlistener("instrumentation/adf[1]/in-range", iku_both_mode2_update, 0, 0);
setlistener("instrumentation/nav[1]/in-range", iku_both_mode2_update, 0, 0);
setlistener("instrumentation/nav[1]/nav-loc", iku_both_mode2_update, 0, 0);
setlistener("tu154/instrumentation/iku-1[0]/mode-1", iku0_mode1_update, 1);
setlistener("tu154/instrumentation/iku-1[0]/mode-2", iku0_mode2_update, 1);
setlistener("tu154/instrumentation/iku-1[1]/mode-1", iku1_mode1_update, 1);
setlistener("tu154/instrumentation/iku-1[1]/mode-2", iku1_mode2_update, 1);


######################################################################
#
# UShDB
#

var ushdb_mode_update = func(b) {
    var sel = getprop("tu154/switches/ushdb-sel-"~b);
    if (int(sel) != sel) # The switch is in transition.
        return;
    var bearing = 90;
    var j = b - 1;
    if (sel) {
        if (getprop("instrumentation/nav["~j~"]/in-range")
            and !getprop("instrumentation/nav["~j~"]/nav-loc"))
            bearing =
                "instrumentation/nav["~j~"]/radials/reciprocal-radial-deg";
    } else {
        if (getprop("instrumentation/adf["~j~"]/in-range"))
            bearing = "instrumentation/adf["~j~"]/indicated-bearing-deg";
    }

    realias("tu154/instrumentation/ushdb/heading-deg-"~b, bearing, 0.5,
            [0, 360]);
}

var ushdb_mode1_update = func {
    ushdb_mode_update(1);
}

var ushdb_mode2_update = func {
    ushdb_mode_update(2);
}

setlistener("instrumentation/adf[0]/in-range", ushdb_mode1_update, 0, 0);
setlistener("instrumentation/nav[0]/in-range", ushdb_mode1_update, 0, 0);
setlistener("instrumentation/nav[0]/nav-loc", ushdb_mode1_update, 0, 0);
setlistener("instrumentation/adf[1]/in-range", ushdb_mode2_update, 0, 0);
setlistener("instrumentation/nav[1]/in-range", ushdb_mode2_update, 0, 0);
setlistener("instrumentation/nav[1]/nav-loc", ushdb_mode2_update, 0, 0);
setlistener("tu154/switches/ushdb-sel-1", ushdb_mode1_update, 1);
setlistener("tu154/switches/ushdb-sel-2", ushdb_mode2_update, 1);


######################################################################
#
# UVID
#

var uvid_inhg = func(i) {
    var inhgX100 = getprop("tu154/instrumentation/altimeter["~i~"]/inhgX100");
    setprop("instrumentation/altimeter["~i~"]/setting-inhg", inhgX100 / 100.0);

    if (i == 0)
        setprop("tu154/instrumentation/altimeter[0]/mmhg", inhgX100 * 0.254);

    if (getprop("tu154/instrumentation/altimeters-sync-inhg")) {
        setprop("tu154/instrumentation/altimeter["~(1-i)~"]/inhgX100",
                inhgX100);
    }
}

setlistener("tu154/instrumentation/altimeter[0]/inhgX100",
            func { uvid_inhg(0) }, 1, 0);
setlistener("tu154/instrumentation/altimeter[1]/inhgX100",
            func { uvid_inhg(1) }, 1, 0);


######################################################################
#
# RSBN & PPDA
#
# Implementation note:
#
# instrumentation/nav doesn't export true radial value, only twisted
# one.  Instead of computing true azimuth in Nasal we remember twist
# value (which is zero for RSBN but non-zero for VOR) and alias to
# twisted radial.  rsbn_corr() is sill called every 0.1 second, but
# only when correction is enabled.
#

var rsbn_corr = func {
    var twist = getprop("tu154/instrumentation/rsbn/twist");
    if (!getprop("instrumentation/nav[2]/nav-loc")
        and getprop("instrumentation/nav[2]/in-range")
        and getprop("instrumentation/dme[2]/in-range")) {
        setprop("fdm/jsbsim/instrumentation/rsbn-angle-deg",
                getprop("tu154/instrumentation/rsbn/radial") + twist);
        setprop("fdm/jsbsim/instrumentation/rsbn-d-m",
                getprop("tu154/instrumentation/rsbn/distance"));
    } else {
        var i = 2 - getprop("tu154/systems/nvu/selector");
        var S = getprop("fdm/jsbsim/instrumentation/aircraft-integrator-s-"~i);
        var Z = getprop("fdm/jsbsim/instrumentation/aircraft-integrator-z-"~i);
        var Sm = getprop("fdm/jsbsim/instrumentation/point-integrator-s-"~i);
        var Zm = getprop("fdm/jsbsim/instrumentation/point-integrator-z-"~i);
        var zpu = getprop("fdm/jsbsim/instrumentation/zpu-deg-"~i);
        var tks_heading = getprop("fdm/jsbsim/instrumentation/tks-heading");

        var ds = S - Sm;
        var dz = Z - Zm;
        var deg = (ds or dz ? math.atan2(dz, ds) * 57.3 : 0);
        var radial = deg + tks_heading - zpu - twist;
        if (radial >= 360)
            radial -= 360;
        else if (radial < 0)
            radial += 360;
        var distance = math.sqrt(ds * ds + dz * dz);
        distance = int(distance / 100) * 100;

        setprop("tu154/instrumentation/rsbn/radial-auto", radial);
        if (getprop("tu154/instrumentation/rsbn/distance-target") != distance) {
            setprop("tu154/instrumentation/rsbn/distance-target", distance);
            interpolate("tu154/instrumentation/rsbn/distance-auto", distance,
                        0.2);
        }
    }
}
var rsbn_corr_timer = maketimer(0.1, rsbn_corr);

var ppda_mode_update = func {
    var radial = getprop("tu154/instrumentation/rsbn/radial");
    var distance = getprop("tu154/instrumentation/rsbn/distance");
    var nav_in_range = 1;
    var dme_in_range = 1;
    var twist = 0;

    rsbn_corr_timer.stop();
    if (getprop("tu154/instrumentation/rsbn/serviceable")) {
        if (!getprop("instrumentation/nav[2]/nav-loc")) {
           nav_in_range = getprop("instrumentation/nav[2]/in-range");
           dme_in_range = getprop("instrumentation/dme[2]/in-range");
        }
        if (nav_in_range) {
            radial = "instrumentation/nav[2]/radials/actual-deg";
            twist = getprop("instrumentation/nav[2]/radials/target-radial-deg");
        }
        if (dme_in_range) {
            distance = "tu154/instrumentation/dme[2]/distance";
        }
        if (getprop("tu154/systems/nvu/powered")
            and getprop("tu154/switches/v-51-corr") == 1) {
            if (!nav_in_range)
                radial = "tu154/instrumentation/rsbn/radial-auto";
            if (!dme_in_range)
                distance = "tu154/instrumentation/rsbn/distance-auto";
            rsbn_corr_timer.start();
        }
    }

    interpolate("tu154/instrumentation/rsbn/twist", twist, 0.5);
    realias("/tu154/instrumentation/rsbn/radial", radial, 0.5, [0, 360]);
    realias("/tu154/instrumentation/rsbn/distance", distance, 0.5);
    setprop("tu154/systems/electrical/indicators/azimuth-avton", !nav_in_range);
    setprop("tu154/systems/electrical/indicators/range-avton", !dme_in_range);
}

setlistener("tu154/instrumentation/rsbn/serviceable", ppda_mode_update, 1, 0);
setlistener("instrumentation/nav[2]/nav-loc", ppda_mode_update, 0, 0);
setlistener("instrumentation/nav[2]/in-range", ppda_mode_update, 0, 0);
setlistener("instrumentation/dme[2]/in-range", ppda_mode_update, 0, 0);
setlistener("tu154/systems/nvu/powered", ppda_mode_update, 0, 0);
setlistener("tu154/switches/v-51-corr", ppda_mode_update, 0, 0);
setlistener("tu154/systems/nvu/selector", ppda_mode_update, 0, 0);


######################################################################

svs_power = func{
if( getprop( "tu154/switches/SVS-power" ) == 1.0 )
	electrical.AC3x200_bus_1L.add_output( "SVS", 10.0);
else electrical.AC3x200_bus_1L.rm_output( "SVS" );
}

setlistener("tu154/switches/SVS-power", svs_power, 0, 0);

# feet
uvid15_power = func{
if( getprop( "tu154/switches/UVID" ) == 1.0 )
	electrical.AC3x200_bus_1L.add_output( "UVID-15", 10.0);
else electrical.AC3x200_bus_1L.rm_output( "UVID-15" );
}

setlistener("tu154/switches/UVID", uvid15_power, 0, 0 );


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
var skawk_init = func{
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
}

# We use transponder for FG 2.10 and newest

if( getprop( "instrumentation/transponder/inputs/digit" ) != nil ) skawk_init();


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
	setprop("tu154/instrumentation/bkk/mgv-1-failure", 1.0);
	setprop("tu154/instrumentation/bkk/mgv-2-failure", 1.0);
	setprop("tu154/instrumentation/bkk/mgv-contr-failure", 1.0);

	var lamp_pwr = getprop("tu154/systems/electrical/buses/DC27-bus-L/volts");
	if( lamp_pwr == nil ) lamp_pwr = 0.0;
	if( lamp_pwr > 0 ) lamp_pwr = 1.0;
	setprop("tu154/systems/electrical/indicators/contr-gyro", lamp_pwr );
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
setprop("/tu154/systems/nvu-calc/fork-flag", "not applied");
var fork_loader = func{

var fork_flag = getprop( "/tu154/systems/nvu-calc/fork-flag" );
var fork = getprop( "/tu154/systems/nvu-calc/fork" );
if( fork == nil ) fork = 0.0;

if (fork_flag == "not applied") {
    setprop("/tu154/systems/nvu-calc/fork-flag", "applied");
} else {
    setprop("/tu154/systems/nvu-calc/fork-flag", "not applied");
    fork = -fork;
}

if (num(getprop("/tu154/systems/nvu-calc/fork-route-only")))
   return;

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
zpu = int(zpu * 10 + 0.5) / 10;
setprop("fdm/jsbsim/instrumentation/zpu-deg-1", zpu );
interpolate("tu154/instrumentation/v-140[0]/zpu-1-delayed", zpu, 1.0 );
zpu = getprop("fdm/jsbsim/instrumentation/zpu-deg-2" );
if( zpu == nil ) zpu = 0.0;
zpu += fork;
zpu = int(zpu * 10 + 0.5) / 10;
setprop("fdm/jsbsim/instrumentation/zpu-deg-2", zpu );
interpolate("tu154/instrumentation/v-140[0]/zpu-2-delayed", zpu, 1.0 );
}

#Virtual navigator
var virtual_navigator = func{
var route_num = getprop("/tu154/systems/nvu-calc/route-selected");
if( route_num == nil ) route_num = 0;

# Get route and max route number
var route_list = props.globals.getNode("/sim/gui/dialogs/Tu-154B-2/nav/dialog/list", 1);
var route = route_list.getChildren("value");
var max_route = size( route );

if (route_num > 0) {
   help.messenger(sprintf("Virtual navigator: next route %s",
                          route[route_num-1].getValue()));
}

# Select new route
if( route_num >= max_route ) return; # end of route list ashieved
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
setprop( "/tu154/systems/nvu-calc/uk-next", min2dec(num(substr(vect[19], 0, size(vect[19])-1))) );
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
	setprop( "/tu154/systems/nvu-calc/uk-next", min2dec(num(substr(vect[19], 0, size(vect[19])-1))) );
		}

	}

var dist_current = 0.0;
var gradient = 0.0;

var selector = getprop("tu154/systems/nvu/selector" );
if( selector == nil ) selector = 0;
var fork_flag = getprop( "/tu154/systems/nvu-calc/fork-flag" );
if( fork_flag == nil ) fork_flag = "not applied";
# We use departure OZPU obviosly.
# If fork applied, operate with destination OZPU instead
if( fork_flag == "applied" ) var zpu_selected = zpu_dest_selected;
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
    var outer = int(uk_selected / 10) * 10;
    setprop("tu154/instrumentation/b-8m/outer", outer);
    setprop("tu154/instrumentation/b-8m/inner",
            int((uk_selected - outer) * 10 + 0.5));
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
}

var nvu_power_off = func{
# setprop("tu154/systems/nvu/powered", 0.0 );
 setprop("tu154/systems/nvu/serviceable", 0.0 );
 electrical.AC3x200_bus_1L.rm_output( "NVU" );
 nvu_watchdog();
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
        if(getprop("tu154/instrumentation/rsbn/serviceable")
           and !getprop("instrumentation/nav[2]/nav-loc")
           and getprop("instrumentation/nav[2]/in-range")
           and getprop("instrumentation/dme[2]/in-range"))
		{ 
		setprop("tu154/systems/nvu/rsbn-corr", 1 );
		setprop("tu154/systems/electrical/indicators/nvu-correction-on", 1 ); 
		nvu_start_corr();
		}
	else {
              setprop("tu154/systems/nvu/rsbn-corr", 0 ); 
              setprop("tu154/systems/electrical/indicators/nvu-correction-on", 0 ); 
              nvu_stop_corr();	
		} }	
else	{
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
    var outer = getprop("tu154/instrumentation/b-8m/outer");
    var inner = getprop("tu154/instrumentation/b-8m/inner");
    setprop("fdm/jsbsim/instrumentation/rsbn-uk-deg", outer + inner / 10);
}




setlistener("tu154/instrumentation/b-8m/outer", b_8m_handler ,0,0);
setlistener("tu154/instrumentation/b-8m/inner", b_8m_handler ,0,0);
setlistener("tu154/switches/v-51-selector-2", nvu_lur_selector ,0,0);
setlistener( "tu154/instrumentation/v-140[0]/zpu-1-delayed", zpu_1_handler ,0,0);
setlistener( "tu154/instrumentation/v-140[0]/zpu-2-delayed", zpu_2_handler ,0,0);


#                            END NVU staff 
#*****************************************************************************

#RSBN support
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

var freq = 959.95 + channel * 0.05;
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
          setprop("instrumentation/dme[2]/serviceable", 1 );
	setprop("tu154/instrumentation/rsbn/serviceable", 1 );
	  }
	}
else { 
	electrical.AC3x200_bus_1L.rm_output( "RSBN" );
#	setprop("instrumentation/nav[2]/serviceable", 0 ); 
	setprop("instrumentation/dme[2]/serviceable", 0 );
	setprop("instrumentation/nav[2]/power-btn", 0 );
	setprop("tu154/instrumentation/rsbn/serviceable", 0 );
	setprop("instrumentation/nav[2]/powered", 0 );
	}
}

var rsbn_pwr_watchdog = func{
if( getprop("instrumentation/nav[2]/powered" ) != 1 ) # power off
	{
#	setprop("instrumentation/nav[2]/serviceable", 0 );
	setprop("instrumentation/dme[2]/serviceable", 0 );
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
            setprop("instrumentation/dme[2]/serviceable", 1 );
	    setprop("tu154/instrumentation/rsbn/serviceable", 1 ); 
	    }
	}

if( getprop( "tu154/switches/RSBN-power" ) != 1.0 ) 
        {
        setprop("tu154/instrumentation/rsbn/serviceable", 0 );
	setprop("instrumentation/nav[2]/power-btn", 0 );
        setprop("instrumentation/dme[2]/serviceable", 0 );
        return;
        }
}

setlistener("instrumentation/nav[2]/powered", rsbn_pwr_watchdog, 0,0 );



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
	     setprop("instrumentation/turn-indicator/serviceable", 1 );
}
 	else {
	     electrical.AC3x200_bus_1L.rm_output( "EUP" );
	     setprop("instrumentation/turn-indicator/serviceable", 0 );
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
	setprop("instrumentation/dme[2]/serviceable", 1 );
	setprop("tu154/systems/nvu/powered", 1.0 );
	# KURS-MP left
	if( getprop( "tu154/switches/KURS-MP-1" ) == 1.0 )
		{
		setprop("instrumentation/nav[0]/power-btn", 1 );
		setprop("instrumentation/nav[0]/serviceable", 1 );
		setprop("instrumentation/dme[0]/serviceable", 1 );
		setprop("instrumentation/marker-beacon[0]/power-btn", 1 );
		setprop("instrumentation/marker-beacon[0]/serviceable", 1 );		
		}
	else	{
		setprop("instrumentation/nav[0]/power-btn", 0 );
		setprop("instrumentation/nav[0]/serviceable", 0 );
		setprop("instrumentation/dme[0]/serviceable", 0 );
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
	     setprop("instrumentation/turn-indicator/serviceable", 1 );
	else setprop("instrumentation/turn-indicator/serviceable", 0 );

	
	
	}


# turn off all consumers if bus has gone
else	{
	setprop("tu154/instrumentation/ark-15[0]/powered", 0 ); 
	setprop("instrumentation/nav[2]/powered", 0 ); 
	setprop("instrumentation/dme[2]/serviceable", 0 );
	setprop("tu154/systems/nvu/powered", 0.0 );
	setprop("instrumentation/nav[0]/power-btn", 0 );
	setprop("instrumentation/nav[0]/serviceable", 0 );
	setprop("instrumentation/heading-indicator[0]/serviceable", 0 );
	setprop("fdm/jsbsim/instrumentation/bgmk-failure-1", 1 );
	setprop("tu154/instrumentation/bkk/serviceable", 0 );
	setprop("tu154/instrumentation/diss/powered", 0 );
	setprop("tu154/systems/svs/powered", 0 );
	setprop("tu154/instrumentation/altimeter[1]/powered", 0 );
	setprop("instrumentation/attitude-indicator[3]/caged-flag", 1 );
	setprop("tu154/instrumentation/uap-12/powered", 0 );
	setprop("instrumentation/turn-indicator/serviceable", 0 );
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
		setprop("instrumentation/dme[1]/serviceable", 1 );
		}
	else	{
		setprop("instrumentation/nav[1]/power-btn", 0 );
		setprop("instrumentation/nav[1]/serviceable", 0 );
		setprop("instrumentation/dme[1]/serviceable", 0 );
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
