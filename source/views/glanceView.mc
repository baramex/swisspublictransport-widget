import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Sensor;

class GlanceView extends WatchUi.GlanceView {
  var azimuth as Float?;

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

  function onShow() {
    Sensor.registerSensorDataListener(method(:onMag), {
      :period => 1,
      :magnetometer => {
        :enabled => true,
        :sampleRate => 4,
      },
    });
  }

  function onHide() {
    Sensor.unregisterSensorDataListener();
  }

  function onMag(sensorData as SensorData) as Void {
    if (sensorData.magnetometerData == null) {
      return;
    }
    azimuth =
      Math.atan2(
        sensorData.magnetometerData.y[0],
        sensorData.magnetometerData.x[0]
      ) + Math.PI;
    requestUpdate();
  }

  function onUpdate(dc as Dc) {
    var app = getApp();
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    if (app.currentStop == null) {
      dc.drawText(
        0,
        dc.getHeight() / 2,
        Graphics.FONT_SMALL,
        Rez.Strings.NoStopSelected,
        Graphics.TEXT_JUSTIFY_VCENTER
      );
    } else {
      var stop = app.stops.get(app.currentStop);
      dc.drawText(
        0,
        0,
        Graphics.FONT_TINY,
        stop.name,
        Graphics.TEXT_JUSTIFY_LEFT
      );

      if (app.position != null) {
        if (azimuth == null) {
          azimuth = 0.0;
        }
        var angle =
          PositionUtils.getAngle(app.position, stop.getLocation()) - azimuth;
        var x = dc.getWidth()-3;
        var y = dc.getFontHeight(Graphics.FONT_TINY)/2;
        var x1 = x + 10 * Math.cos(angle);
        var y1 = y + 6 * Math.sin(angle);
        var x2 = x - 10 * Math.cos(angle);
        var y2 = y - 6 * Math.sin(angle);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.setPenWidth(3);
        dc.drawLine(x1, y1, x2, y2);
        var x3 = x - 5 * Math.cos(angle + Math.PI / 2);
        var y3 = y - 3 * Math.sin(angle + Math.PI / 2);
        var x4 = x - 5 * Math.cos(angle - Math.PI / 2);
        var y4 = y - 3 * Math.sin(angle - Math.PI / 2);
        dc.drawLine(x2, y2, x3, y3);
        dc.drawLine(x2, y2, x4, y4);

        var distance = PositionUtils.getDistance(
          app.position,
          stop.getLocation()
        );
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(
          x - 7,
          y,
          Graphics.FONT_XTINY,
          Math.round(distance).toNumber() + "m",
          Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        );
      }

      if (app.appState == app.GET_DEPARTURES) {
        dc.drawText(
          0,
          dc.getHeight() / 2,
          Graphics.FONT_SMALL,
          Rez.Strings.GettingDepartures,
          Graphics.TEXT_JUSTIFY_VCENTER
        );
      }
      if (app.departures != null && app.departures.size() == 0) {
        dc.drawText(
          0,
          dc.getHeight() / 2,
          Graphics.FONT_SMALL,
          Rez.Strings.NoDepartureFound,
          Graphics.TEXT_JUSTIFY_VCENTER
        );
      }
    }
  }
}
