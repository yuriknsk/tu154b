#
# debug & control
# Yurik V. Nikiforoff, yurik@megasignal.com
# Novosibirsk, Russia
# oct 2007
#

util_win = screen.window.new( 0, 0, 1, 0 );
util_win.fg = [0,1,1,1];

show_param_update = func {
settimer( show_param_update, 1 );

var mass = getprop("fdm/jsbsim/inertia/mass-slugs");
var cg = getprop("fdm/jsbsim/inertia/cg-x-in");
var ias = getprop("fdm/jsbsim/velocities/vc-fps");
#ias = getprop("instrumentation/airspeed-indicator/indicated-speed-kt");
var elev = getprop("fdm/jsbsim/fcs/elevator-pos-rad");
var cy = getprop("fdm/jsbsim/aero/function/cy");
var alpha = getprop("fdm/jsbsim/aero/alpha-wing-rad");

thrust_1 = getprop("engines/engine/thrust_lb");
thrust_2 = getprop("engines/engine[1]/thrust_lb");
thrust_3 = getprop("engines/engine[2]/thrust_lb");


if( mass == nil ){ mass=0.0;}
if( cg == nil ){ cg=0.0;}
if( ias == nil ){ ias=0.0;}
if( elev == nil ){ elev=0.0;}
if( cy == nil ){ cy=0.0;}
if( alpha == nil ){ alpha=0.0;}
if( thrust_1 == nil ){ thrust_1=0.0;}
if( thrust_2 == nil ){ thrust_2=0.0;}
if( thrust_3 == nil ){ thrust_3=0.0;}


mass = mass * 14.5939;
cg = (cg * 0.0254 - 24.04) * (100/5.285);
ias = ias * 1.1;
#ias = ias * 1.852;
elev = elev * 57.3;	# from rad to deg
alpha = alpha * 57.3;

#thrust = ( thrust_1 + thrust_2 + thrust_3 ) * 0.454 * 9.8 / 1000;
thrust = thrust_1 * 0.454 * 9.8 / 1000;

util_win.write(sprintf("mass: %d kg, CG: %.2f %% CAX, airspeed: %d km/h, AOA: %.2f',Cy: %.2f total thrust: %.2f kN, elevator: %.2f", 
int(mass), cg, int(ias), alpha, cy, thrust, elev ));

}

print("Debug subsystem started");
show_param_update();