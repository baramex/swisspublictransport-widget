import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Position;
import Toybox.Math;

class swisspublictransportView extends WatchUi.View {
  var stateText;
  var distanceText;

  var verticalScrollBar;
  var horizontalScrollBar;

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

    if (app.currentStop != null && app.stops.hasKey(app.currentStop)) {
      var stop = app.stops.get(app.currentStop);
      var stopText = stop.name;
      var stopLocation = new Position.Location({
        :latitude => stop.lat,
        :longitude => stop.lon,
        :format => :degrees,
      });

      var stopTextWidth = dc.getTextWidthInPixels(
        stopText,
        Graphics.FONT_MEDIUM
      );
      if (stopTextWidth < 88) {
        dc.drawText(
          12,
          35,
          Graphics.FONT_MEDIUM,
          stopText,
          Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
      } else if (stopTextWidth < 95) {
        dc.drawText(
          5,
          35,
          Graphics.FONT_MEDIUM,
          stopText,
          Graphics.TEXT_JUSTIFY_LEFT
        );
      } else {
        var firstPart = "";
        for (var i = 0; i < stopText.length(); i++) {
          var char = stopText.toCharArray()[i];
          if (
            dc.getTextWidthInPixels(firstPart + char, Graphics.FONT_MEDIUM) > 70
          ) {
            break;
          }
          firstPart += char;
          if (char == ' ' || char == '-' || char == '/') {
            var secondPart = stopText.substring(i + 1, stopText.length());
            if (
              dc.getTextWidthInPixels(secondPart, Graphics.FONT_MEDIUM) < 95
            ) {
              break;
            }
          }
        }
        dc.drawText(
          25,
          10,
          Graphics.FONT_MEDIUM,
          firstPart,
          Graphics.TEXT_JUSTIFY_LEFT
        );
        var secondPart = stopText.substring(
          firstPart.length(),
          stopText.length()
        );
        dc.drawText(
          5,
          35,
          Graphics.FONT_MEDIUM,
          secondPart,
          Graphics.TEXT_JUSTIFY_LEFT
        );
      }

      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
      dc.fillCircle(144, 31, 32);

      var distance = PositionUtils.getDistance(app.position, stopLocation);
      distanceText.setText(Math.round(distance).toNumber() + "m");
      distanceText.draw(dc);

      if (app.heading == null) {
        app.heading = 0.0;
      }
      var angle = PositionUtils.getAngle(app.position, stopLocation) + app.heading;

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

    if (app.appState == app.DISPLAY) {
      if (app.departureGroups.size() < 1) {
        stateText.setText("Aucun départ trouvé");
      } else {
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
    }

    stateText.draw(dc);
  }

  function updateCurrentStop() {
    var app = getApp();
        if (
            app.currentStop != null &&
            horizontalScrollBar != null &&
            app.currentStop != horizontalScrollBar.position
            ) {
            app.currentStop = horizontalScrollBar.position;
            app.appState = app.GET_DEPARTURES;
            app.departureGroups = {};
            app.groupRef = {};
            app.departures = {};
            app.onTimer();
        }
    }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {
    stateText = new WatchUi.TextArea({
      :locX => WatchUi.LAYOUT_HALIGN_CENTER,
      :locY => 75,
      :width => 176,
      :height => 70,
      :justification => Graphics.TEXT_JUSTIFY_CENTER,
    });
    distanceText = new WatchUi.Text({
      :locX => 140,
      :locY => 35,
      :font => Graphics.FONT_TINY,
      :justification => Graphics.TEXT_JUSTIFY_CENTER,
      :color => Graphics.COLOR_BLACK,
    });
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {
    
  }
}
