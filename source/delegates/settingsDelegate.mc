import Toybox.WatchUi;
import Toybox.Application;

class SettingsDelegate extends WatchUi.MenuInputDelegate {
  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    var app = getApp();
    var stop = app.stops[app.currentStop];
    if(item == :favorite) {
        stop.favorite = !stop.favorite;
        if (stop.favorite) {
            StorageUtils.addToFavorites(stop);
        }
        else {
            StorageUtils.removeFromFavorites(stop.ref);
        }
        // Test: more than 4 favorites ? -> show toast
    }
    else if(item == :glance) {
        StorageUtils.setGlanceStop(stop);
    }
  }
}