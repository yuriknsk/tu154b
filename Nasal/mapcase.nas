######################################################################
#
# Map case inserted paper images (.svg or .png).
#

# Pages will be shown in the following order.  You may add/delete file names
# to this list.  Duplicates are OK.
var filenames = [
    "Instruments-3d/mapcase/limits.png",
    "Instruments-3d/mapcase/Vr-V2.png",
    "Instruments-3d/mapcase/before-engine-start.png",
    "Instruments-3d/mapcase/before-taxiing.png",
    "Instruments-3d/mapcase/on-taxiing.png",
    "Instruments-3d/mapcase/before-the-line.png",
    "Instruments-3d/mapcase/after-lineup.png",
    "Instruments-3d/mapcase/Vr-V2.png",
    "Instruments-3d/mapcase/climb-transition-level.png",
    "Instruments-3d/mapcase/climb-rates-distance.png",
    "Instruments-3d/mapcase/climb-rates-speed.png",
    "Instruments-3d/mapcase/turn-radius-fast.png",
    "Instruments-3d/mapcase/before-descend.png",
    "Instruments-3d/mapcase/descend-rates.png",
    "Instruments-3d/mapcase/mps2kmph.png",
    "Instruments-3d/mapcase/descend-transition-level.png",
    "Instruments-3d/mapcase/before-base-turn.png",
    "Instruments-3d/mapcase/turn-radius-slow.png",
    "Instruments-3d/mapcase/on-final.png",
    "Instruments-3d/mapcase/Vref.png",
    "Instruments-3d/mapcase/Vstall.png",
    "Instruments-3d/mapcase/kts2kmph.png",
    "Instruments-3d/mapcase/back-course.png",
];

var images = {};
var switch_page = func(i) {
    var total = size(filenames);
    if (total == 0)
        return;
    var page = getprop("tu154/instrumentation/mapcase/page");
    images[filenames[page - 1]].hide();
    page += i;
    if (page < 1)
        page = total;
    else if (page > total)
        page = 1;
    images[filenames[page - 1]].show();
    setprop("tu154/instrumentation/mapcase/page", page);
}

var init = func {
    removelistener(init_event);
    print("Map case page loader started");
    var mapcase = canvas.new({
        name: "MapCase",
        size: [1024, 1024],
        view: [1024, 988],
        mipmapping: 1,
    });
    mapcase.addPlacement({ node: "mapcase" });
    mapcase.setColorBackground(0.82, 0.82, 0.82, 1);

    var root = mapcase.createGroup();
    foreach (var name; filenames) {
        if (images[name] != nil)
            continue;
        print("Loading ", name);
        var path = getprop("sim/aircraft-dir")~"/"~name;
        var g = root.createChild("group", name);
        if (substr(name, -4) == ".svg")
            canvas.parsesvg(g, path);
        else
            g.createChild("image").setFile(path).setSize(1024, 988);
        g.hide();
        images[name] = g;
    }
    print("Map case page loader done");

    setprop("tu154/instrumentation/mapcase/total_pages", size(filenames));
    setprop("tu154/instrumentation/mapcase/page", 1);
    switch_page(0);
}
var init_event = setlistener("nasal/mapcase/loaded", init);
