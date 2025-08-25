import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Application;
import Toybox.Lang;

class GlanceView extends WatchUi.GlanceView {
  function initialize() {
    GlanceView.initialize();

    var app = getApp();
    var stopData =
      Application.Storage.getValue("glanceStop") as StorageUtils.StopObject?;
    if (stopData != null) {
      var stop = Stop.fromDictionary(stopData);
      if (app.stops == null || app.stops.size() == 0) {
        app.stops = {};
        app.stops.put(0, stop);
        app.currentStop = 0;
        app.updateDepartures(true);
        app.appState = app.GET_DEPARTURES;
      }
    }
  }

  function onUpdate(dc as Dc) {}
}
