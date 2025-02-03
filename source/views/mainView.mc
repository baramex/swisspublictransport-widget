import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Position;
import Toybox.Math;
import Toybox.Sensor;

class swisspublictransportView extends WatchUi.View {
  var type = "main";

  var stateText;
  var distanceText;

  var verticalScrollBar;
  var horizontalScrollBar;

  var azimuth as Float?;

  (:smallOctogonal)
  const stateLocY = 64;
  (:anyOctogonal)
  const stateLocY = 72;

  (:smallOctogonal)
  const stateHeight = 66;
  (:anyOctogonal)
  const stateHeight = 76;

  function initialize() {
    View.initialize();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    System.println("layout");
    setLayout(Rez.Layouts.MainLayout(dc));
  }

  // Update the view
  function onUpdate(dc as Dc) as Void {
    System.println("update");
    var app = getApp();

    View.onUpdate(dc);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    if (app.appState == app.GET_LOCATION) {
      stateText.setText("Récupération de la position...");
    } else if (app.appState == app.GET_STOPS) {
      stateText.setText("Récupération des arrêts...");
    } else if (app.appState == app.GET_DEPARTURES) {
      stateText.setText("Récupération des départs...");
    } else if (app.appState == app.DISPLAY) {
      stateText.setText("");
    }

    if (app.stops != null && app.stops.size() == 0) {
      stateText.setText("Aucun arrêt trouvé");
    }
    if (app.departures != null && app.departures.size() == 0) {
      stateText.setText("Aucun départ trouvé");
    }

    if (app.currentStop != null && app.stops.hasKey(app.currentStop)) {
      var stop = app.stops.get(app.currentStop);
      var stopText = stop.name;
      var stopLocation = new Position.Location({
        :latitude => stop.lat,
        :longitude => stop.lon,
        :format => :degrees,
      });

      drawStopName(dc, stopText);

      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
      dc.fillCircle(144, 31, 32);

      var distance = PositionUtils.getDistance(app.position, stopLocation);
      distanceText.setText(Math.round(distance).toNumber() + "m");
      drawDistanceText(dc);

      if (azimuth == null) {
        azimuth = 0.0;
      }
      var angle = PositionUtils.getAngle(app.position, stopLocation) - azimuth;

      var x1 = 140 + 20 * Math.cos(angle);
      var y1 = 20 + 12 * Math.sin(angle);
      var x2 = 140 - 20 * Math.cos(angle);
      var y2 = 20 - 12 * Math.sin(angle);
      dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
      dc.setPenWidth(3);
      dc.drawLine(x1, y1, x2, y2);
      // arrow head
      var x3 = 140 - 10 * Math.cos(angle + Math.PI / 2);
      var y3 = 20 - 6 * Math.sin(angle + Math.PI / 2);
      var x4 = 140 - 10 * Math.cos(angle - Math.PI / 2);
      var y4 = 20 - 6 * Math.sin(angle - Math.PI / 2);
      dc.drawLine(x2, y2, x3, y3);
      dc.drawLine(x2, y2, x4, y4);
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

      if (horizontalScrollBar != null) {
        horizontalScrollBar.draw(dc);
      }
    }

    if (app.appState == app.DISPLAY && app.departureGroups.size() > 0) {
      var pos = 0;
      if (verticalScrollBar != null) {
        pos = verticalScrollBar.position;
      }
      for (var i = pos; i < pos + 2; i++) {
        if (i >= app.departureGroups.size()) {
          break;
        }
        var ldepartures = app.departureGroups.get(i);
        if (ldepartures.size() == 0) {
          continue;
        }
        var departureElement = new DepartureGroupElement({
          :lineName => ldepartures.values()[0].lineName,
          :lineColor => ldepartures.values()[0].lineColor,
          :lineTextColor => ldepartures.values()[0].lineTextColor,
          :platformName => ldepartures.values()[0].platformName,
          :locX => 6,
          :locY => 67 + (i - pos) * 52,
          :departures => ldepartures,
          :destinationName => ldepartures.values()[0].destinationName,
        });
        departureElement.draw(dc);
      }

      if (verticalScrollBar != null) {
        verticalScrollBar.draw(dc);
      }
    }

    stateText.width = dc.getWidth();
    drawStateText(dc);
  }

  function updateCurrentStop() {
    var app = getApp();
    if (
      app.currentStop != null &&
      horizontalScrollBar != null &&
      app.currentStop != horizontalScrollBar.position
    ) {
      app.currentStop = horizontalScrollBar.position;
      app.departureGroups = {};
      app.groupRef = {};
      app.departures = null;
      app.appState = app.GET_DEPARTURES;
      verticalScrollBar = null;
      app.updateDepartures(true);
    }
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

  function onShow() as Void {
    initStateText();
    initDistanceText();

    Sensor.registerSensorDataListener(method(:onMag), {
      :period => 1,
      :magnetometer => {
        :enabled => true,
        :sampleRate => 4,
      },
    });
  }

  (:anyOctogonal)
  function initStateText() {
    stateText = new WatchUi.TextArea({
      :locX => WatchUi.LAYOUT_HALIGN_CENTER,
      :locY => stateLocY,
      :height => stateHeight,
      :justification => Graphics.TEXT_JUSTIFY_CENTER,
    });
  }
  (:anyRound)
  function initStateText() {
    stateText = new WatchUi.Text({
      :locX => WatchUi.LAYOUT_HALIGN_CENTER,
      :locY => WatchUi.LAYOUT_VALIGN_CENTER,
      :justification => Graphics.TEXT_JUSTIFY_CENTER |
      Graphics.TEXT_JUSTIFY_VCENTER,
    });
  }

  (:anyOctogonal)
  function drawStateText(dc as Dc) {
    stateText.draw(dc);
  }
  (:anyRound)
  function drawStateText(dc as Dc) {
    stateText.height = dc.getHeight() * 0.3;
    stateText.draw(dc);
  }

  (:smallOctogonal)
  const distanceLocX = 132;
  (:anyOctogonal)
  const distanceLocX = 140;
  (:smallOctogonal)
  const distanceLocY = 31;
  (:anyOctogonal)
  const distanceLocY = 35;

  (:anyOctogonal)
  function initDistanceText() {
    distanceText = new WatchUi.TextArea({
      :locX => distanceLocX,
      :locY => distanceLocY,
      :font => Graphics.FONT_TINY,
      :justification => Graphics.TEXT_JUSTIFY_CENTER,
      :color => Graphics.COLOR_BLACK,
      :height => 20
    });
  }
  (:anyRound)
  function initDistanceText() {
    distanceText = new WatchUi.TextArea({
      :locX => WatchUi.LAYOUT_HALIGN_CENTER,
      :locY => WatchUi.LAYOUT_VALIGN_CENTER,
      :font => Graphics.FONT_TINY,
      :justification => Graphics.TEXT_JUSTIFY_LEFT |
      Graphics.TEXT_JUSTIFY_VCENTER,
      :color => Graphics.COLOR_WHITE,
      :height => 20
    });
  }

  (:anyOctogonal)
  function drawDistanceText(dc as Dc) {
    distanceText.draw(dc);
  }
  (:anyRound)
  function drawDistanceText(dc as Dc) {
    distanceText.locY = dc.getHeight() * 0.1;
    distanceText.draw(dc);
  }

  (:smallOctogonal)
  const smallStopNameWidth = 80;
  (:anyOctogonal)
  const smallStopNameWidth = 88;
  (:smallOctogonal)
  const mediumStopNameWidth = 87;
  (:anyOctogonal)
  const mediumStopNameWidth = 95;
  (:smallOctogonal)
  const flargeStopNameWidth = 63;
  (:anyOctogonal)
  const flargeStopNameWidth = 70;
  (:smallOctogonal)
  const smallStopNameLocX = 10;
  (:anyOctogonal)
  const smallStopNameLocX = 12;
  (:smallOctogonal)
  const smallStopNameLocY = 31;
  (:anyOctogonal)
  const smallStopNameLocY = 35;
  (:smallOctogonal)
  const mediumStopNameLocX = 3;
  (:anyOctogonal)
  const mediumStopNameLocX = 5;
  (:smallOctogonal)
  const mediumStopNameLocY = 31;
  (:anyOctogonal)
  const mediumStopNameLocY = 35;
  (:smallOctogonal)
  const flargeStopNameLocX = 20;
  (:anyOctogonal)
  const flargeStopNameLocX = 25;
  (:smallOctogonal)
  const flargeStopNameLocY = 8;
  (:anyOctogonal)
  const flargeStopNameLocY = 10;

  (:anyOctogonal)
  function drawStopName(dc as Dc, stopText as String) {
    var stopTextWidth = dc.getTextWidthInPixels(stopText, Graphics.FONT_MEDIUM);
    if (stopTextWidth < smallStopNameWidth) {
      dc.drawText(
        smallStopNameLocX,
        smallStopNameLocY,
        Graphics.FONT_MEDIUM,
        stopText,
        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
      );
    } else if (stopTextWidth < mediumStopNameWidth) {
      dc.drawText(
        mediumStopNameLocX,
        mediumStopNameLocY,
        Graphics.FONT_MEDIUM,
        stopText,
        Graphics.TEXT_JUSTIFY_LEFT
      );
    } else {
      var firstPart = "";
      for (var i = 0; i < stopText.length(); i++) {
        var char = stopText.toCharArray()[i];
        if (
          dc.getTextWidthInPixels(firstPart + char, Graphics.FONT_MEDIUM) >
          flargeStopNameWidth
        ) {
          break;
        }
        firstPart += char;
        if (char == ' ' || char == '-' || char == '/') {
          var secondPart = stopText.substring(i + 1, stopText.length());
          if (
            dc.getTextWidthInPixels(secondPart, Graphics.FONT_MEDIUM) <
            mediumStopNameWidth
          ) {
            break;
          }
        }
      }
      dc.drawText(
        flargeStopNameLocX,
        flargeStopNameLocY,
        Graphics.FONT_MEDIUM,
        firstPart,
        Graphics.TEXT_JUSTIFY_LEFT
      );
      var secondPart = stopText.substring(
        firstPart.length(),
        stopText.length()
      );
      dc.drawText(
        mediumStopNameLocX,
        mediumStopNameLocY,
        Graphics.FONT_MEDIUM,
        secondPart,
        Graphics.TEXT_JUSTIFY_LEFT
      );
    }
  }
  (:anyRound)
  function drawStopName(dc as Dc, stopText as String) {
    dc.drawText(
      WatchUi.LAYOUT_HALIGN_CENTER,
      dc.getHeight() * 0.3,
      Graphics.FONT_MEDIUM,
      stopText,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function onHide() as Void {
    Sensor.unregisterSensorDataListener();
  }
}
