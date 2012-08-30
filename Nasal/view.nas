#
#
#
# Project Tupolev for FlightGear
#
# Yurik V. Nikiforoff, yurik@megasignal.com
# Novosibirsk, Russia
# mar 2008
#
# Custom views 
#

var forceView = func{
	var n = arg[0];
	# Hide levers on navigator view
	if( n == 2 ) setprop("tu154/mod-views/nav-view", 1);
	else setprop("tu154/mod-views/nav-view", 0);
	# Hide right yoke
	if( n == 1 ) setprop("tu154/mod-views/copilot-view", 1);
	else setprop("tu154/mod-views/copilot-view", 0);

	var offset = getprop("tu154/mod-views/view-offset");
	if( n > 0 ) n = n + offset;
	setprop("sim/current-view/view-number", n);
	gui.popupTip(views[n].getNode("name").getValue());
};

var modView  = func{
	var n = getprop("sim/current-view/view-number");
	var offset = getprop("tu154/mod-views/view-offset");
	if( n == nil ) n = 0;
	if( n > 0 ) n = n - offset;
	if( n < 0 ) return;
	var mode = arg[0];
	if( mode == nil ) mode = 0;
	# get mod view coordinates	
	var mv = props.globals.getNode("tu154/mod-views").getChildren("mod-view");
	if( mode == 1 )
	{
	setprop("tu154/mod-views/mod", 1 );
# save current position
	setprop("tu154/var/save-x", getprop("sim/current-view/x-offset-m") );
	setprop("tu154/var/save-y", getprop("sim/current-view/y-offset-m") );
	setprop("tu154/var/save-z", getprop("sim/current-view/z-offset-m") );
	setprop("tu154/var/save-fov", getprop("sim/current-view/field-of-view") );
	setprop("tu154/var/save-pitch", getprop("sim/current-view/pitch-offset-deg") );
	setprop("tu154/var/save-heading",getprop("sim/current-view/heading-offset-deg"));
	setprop("tu154/var/save-roll",getprop("sim/current-view/roll-offset-deg"));
# set modified view	
	setprop("sim/current-view/x-offset-m", mv[n].getNode("x-offset-m").getValue() );
	setprop("sim/current-view/y-offset-m", mv[n].getNode("y-offset-m").getValue() );
	setprop("sim/current-view/z-offset-m", mv[n].getNode("z-offset-m").getValue() );
	setprop("sim/current-view/field-of-view",
		mv[n].getNode("field-of-view").getValue() );
	setprop("sim/current-view/pitch-offset-deg", 
		mv[n].getNode("pitch-offset-deg").getValue() );
	setprop("sim/current-view/heading-offset-deg", 
		mv[n].getNode("heading-offset-deg").getValue() );
	setprop("sim/current-view/roll-offset-deg", 
		mv[n].getNode("roll-offset-deg").getValue() );

	return;
	}
	else
	{
	setprop("tu154/mod-views/mod", 0 );
# save modified view	

#	mv[n].getNode("x-offset-m").setValue(getprop("sim/current-view/x-offset-m"));
#	mv[n].getNode("y-offset-m").setValue(getprop("sim/current-view/y-offset-m"));
#	mv[n].getNode("z-offset-m").setValue(getprop("sim/current-view/z-offset-m"));
# 	mv[n].getNode("field-of-view").setValue(
# 		getprop("sim/current-view/field-of-view"));
# 	mv[n].getNode("pitch-offset-deg").setValue(
# 		getprop("sim/current-view/pitch-offset-deg"));
# 	mv[n].getNode("heading-offset-deg").setValue(
# 		getprop("sim/current-view/heading-offset-deg"));
# 	mv[n].getNode("roll-offset-deg").setValue(
# 		getprop("sim/current-view/roll-offset-deg"));
				
	setprop("sim/current-view/x-offset-m", getprop("tu154/var/save-x") );
	setprop("sim/current-view/y-offset-m", getprop("tu154/var/save-y") );
	setprop("sim/current-view/z-offset-m", getprop("tu154/var/save-z") );
	setprop("sim/current-view/field-of-view", getprop("tu154/var/save-fov") );
	setprop("sim/current-view/pitch-offset-deg", getprop("tu154/var/save-pitch") );
	setprop("sim/current-view/heading-offset-deg",getprop("tu154/var/save-heading"));
	setprop("sim/current-view/roll-offset-deg",getprop("tu154/var/save-roll"));
	}
};

# Flight Engineer view

var fe_view = {
	start: func {
		setprop("sim/current-view/config/heading-offset-deg", 
			getprop("sim/view[104]/config/heading-offset-deg"));
		},
};


var init_offset = func{
setprop("/tu154/mod-views/nav-view", 0);
setprop("/tu154/mod-views/copilot-view", 0);
# Do we have Model View?
if( props.globals.getNode("/sim/view[7]") != nil )
  setprop("/tu154/mod-views/view-offset", 7 );
else setprop("/tu154/mod-views/view-offset", 6 );
}

init_offset();

setlistener("/sim/signals/fdm-initialized", func {
view.manager.register("Flight Engineer View", fe_view );});


print("View registered");