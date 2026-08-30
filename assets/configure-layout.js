// Evaluated by org.kde.PlasmaShell. IDs are intentionally discovered at run time.
var existingPanels = panels();
for (var i = existingPanels.length - 1; i >= 0; --i) {
    existingPanels[i].remove();
}

var dock = new Panel;
dock.location = "bottom";
dock.height = 64;
dock.alignment = "center";
dock.lengthMode = "fit";
dock.floating = true;
dock.hiding = "dodgewindows";
dock.opacityMode = "translucent";

var launcher = dock.addWidget("org.kde.plasma.kickoff");
launcher.currentConfigGroup = ["General"];
launcher.writeConfig("icon", "/usr/share/icons/cachyos.svg");

dock.addWidget("org.kde.plasma.pager");

var tasks = dock.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers",
    "applications:systemsettings.desktop," +
    "preferred://filemanager," +
    "applications:org.kde.konsole.desktop," +
    "applications:org.kde.spectacle.desktop");
tasks.writeConfig("iconSpacing", "0");
tasks.writeConfig("wheelEnabled", "AdjustVolume");

dock.addWidget("org.kde.plasma.marginsseparator");

var top = new Panel;
top.location = "top";
top.height = 38;
top.alignment = "center";
top.lengthMode = "fit";
top.floating = true;
top.hiding = "dodgewindows";
top.opacityMode = "translucent";

var tray = top.addWidget("org.kde.plasma.systemtray");
tray.currentConfigGroup = ["General"];
var trayItems =
    "org.kde.plasma.networkmanagement," +
    "org.kde.plasma.bluetooth," +
    "org.kde.plasma.volume," +
    "org.kde.plasma.battery," +
    "org.kde.plasma.brightness";
tray.writeConfig("extraItems", trayItems);
tray.writeConfig("shownItems", trayItems);

top.addWidget("org.kde.plasma.digitalclock");

print("Created dock=" + dock.id + " topbar=" + top.id);
