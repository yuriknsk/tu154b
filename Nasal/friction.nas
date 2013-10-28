terrain_under = func {

  var lat = getprop ("position/latitude-deg");
  var lon = getprop ("position/longitude-deg");
  var info = geodinfo (lat,lon);

  if (info != nil) {
    if (info[1] != nil) {
      if (info[1].solid != nil) setprop ("/environment/terrain", info[1].solid);
      if (info[1].load_resistance != nil) setprop ("/environment/terrain-load-resistance", info[1].load_resistance);
      if (info[1].bumpiness != nil) setprop ("/environment/terrain-bumpiness", info[1].bumpiness);
      if (info[1].friction_factor != nil) setprop ("/environment/terrain-friction-factor", info[1].friction_factor);
      if (info[1].rolling_friction != nil) setprop ("/environment/terrain-rolling-friction", info[1].rolling_friction);
      }
    } else {
      setprop ("environment/terrain", 1);
    }

    settimer (terrain_under, 0.1);
}

terrain_under();

set_friction = func {

  var friction_terrain = getprop ("/environment/terrain-friction-factor");
  var rain = getprop ("/environment/metar/rain-norm");
  var snow = getprop ("/environment/metar/snow-norm");
  if (rain != nil) {friction_water = 0.3 * rain} else {friction_water = 0}
  if (snow != nil) {friction_snow = 0.45 * snow} else {friction_snow = 0}
  
  if (friction_terrain != nil) {
    friction = (0.6 - friction_water - friction_snow) * friction_terrain;
    
    setprop ("/fdm/jsbsim/gear/unit[0]/static_friction_coeff", friction);
    setprop ("/fdm/jsbsim/gear/unit[1]/static_friction_coeff", friction);
    setprop ("/fdm/jsbsim/gear/unit[2]/static_friction_coeff", friction);
  }
  
  settimer (set_friction, 0.1);
}

set_friction();
