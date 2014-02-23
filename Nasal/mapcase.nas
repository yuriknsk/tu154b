######################################################################
#
# Map case inserted paper images (.svg or .png in Instruments-3d/mapcase/).
#

var mapcase = canvas.new({
    name: "MapCase",
    size: [1024, 1024],
    view: [1024, 988],
    mipmapping: 1,
});
mapcase.addPlacement({ node: "mapcase" });
mapcase.setColorBackground(0.82, 0.82, 0.82, 0);

var root = mapcase.createGroup();

var load_page = func(i) {
    var dir = getprop("sim/aircraft-dir")~"/";
    var filename = "Instruments-3d/mapcase/"~page~".svg";
    var svg = 1;
    if (io.stat(dir~filename) == nil) {
       filename = "Instruments-3d/mapcase/"~page~".png";
       svg = 0;
       if (io.stat(dir~filename) == nil)
           return nil;
    }
    print("Loading ", filename);
    var g = root.createChild("group", page);
    if (svg)
        canvas.parsesvg(g, filename);
    else
        g.createChild("image").setFile(filename).setSize(1024, 988);
    g.hide();
    return g;
}

print("Map case page loader started");
var page = 1;
while (load_page(page) != nil)
    page += 1;
print("Map case page loader done");

setprop("tu154/instrumentation/mapcase/page", 1);

var switch_page = func(i) {
    var pages = size(root.getChildren());
    if (!pages)
        return;
    var page = getprop("tu154/instrumentation/mapcase/page");
    root.getElementById(page).hide();
    page += i;
    if (page < 1)
        page = pages;
    else if (page > pages)
        page = 1;
    setprop("tu154/instrumentation/mapcase/page", page);
    root.getElementById(page).show();
}
switch_page(0);
