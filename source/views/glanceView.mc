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

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
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

      var stopData =
        Application.Storage.getValue("glanceStop") as StorageUtils.StopObject?;
      var isSelected =
        stopData != null ? stopData.get("ref") == stop.ref : false;

      dc.drawText(
        isSelected ? Drawables.star.getWidth() + 3 : 0,
        0,
        Graphics.FONT_TINY,
        stop.name,
        Graphics.TEXT_JUSTIFY_LEFT
      );

      if (isSelected) {
        dc.drawBitmap(0, 0, Drawables.star);
      }

      if (app.position != null && !isSelected) {
        if (azimuth == null) {
          azimuth = 0.0;
        }
        var angle =
          PositionUtils.getAngle(app.position, stop.getLocation()) - azimuth;
        var x = dc.getWidth() - 5;
        var y = dc.getFontHeight(Graphics.FONT_TINY) / 2;
        var x1 = x + 10 * Math.cos(angle);
        var y1 = y + 6 * Math.sin(angle);
        var x2 = x - 10 * Math.cos(angle);
        var y2 = y - 6 * Math.sin(angle);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.setPenWidth(2);
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
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
          x - 10,
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
      } else if (app.departures != null && app.departures.size() > 0) {
        var y = dc.getHeight() / 2;
        for (var i = 0; i < 2; i++) {
          var x = (dc.getWidth() / 2) * i;

          var departure = app.departures.get(i);

          var txt = "";
          var time = departure.departureTime;
          var relative = time.compare(Time.now());
          if (relative < 20) {
            if (relative >= 0) {
              txt = "🚌";
            } else {
              txt = "💨";
            }
          } else {
            txt = Math.ceil(relative / 60.0).toNumber() + "'";
          }

          var lineElement = new LineElement({
            :lineName => departure.lineName,
            :lineColor => departure.lineColor,
            :lineTextColor => departure.lineTextColor,
            :locX => x + 2 + dc.getTextWidthInPixels(txt, Graphics.FONT_TINY),
            :locY => y,
          });
          lineElement.draw(dc);
          
          dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
          dc.drawText(
            x +
              lineElement.getWidth(dc) +
              4 +
              dc.getTextWidthInPixels(txt, Graphics.FONT_TINY),
            y + lineElement.getHeight(dc) / 2,
            Graphics.FONT_XTINY,
            Graphics.fitTextToArea(
              departure.destinationName,
              Graphics.FONT_XTINY,
              dc.getWidth() / 2 -
                lineElement.getWidth(dc) -
                4 -
                dc.getTextWidthInPixels(txt, Graphics.FONT_TINY),
              dc.getHeight() / 2,
              true
            ),
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
          );
          dc.drawText(
            x,
            y + lineElement.getHeight(dc) / 2,
            Graphics.FONT_TINY,
            txt,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
          );
        }
      } else {
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
