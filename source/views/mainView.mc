import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Position;
import Toybox.Math;

class swisspublictransportView extends WatchUi.View {
  enum AppState {
    GET_LOCATION,
    GET_STOPS,
    GET_DEPARTURES,
    DISPLAY,
  }

  var position as Position.Location?;
  var appState as AppState = GET_LOCATION;
  var currentStop as Number?;
  var stops = ({}) as Dictionary<Number, Stop>;
  var departures = ({}) as Dictionary<Number, Departure>;

  var departureGroups =
    ({}) as Dictionary<Number, Dictionary<Number, Departure> >;
  var groupRef = ({}) as Dictionary<String, Number>;

  var verticalScrollBar;

  var stateText;
  var progressBar;
  var distanceText;

  var timer;

  function initialize() {
    View.initialize();
    // create layers
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    System.println("layout");
    setLayout(Rez.Layouts.MainLayout(dc));
  }

  // Update the view
  function onUpdate(dc as Dc) as Void {
    System.println("update");
    View.onUpdate(dc);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    if (appState == GET_LOCATION) {
      stateText.setText("Récupération de la position...");
    } else if (appState == GET_STOPS) {
      stateText.setText("Récupération des arrêts...");
    } else if (appState == GET_DEPARTURES) {
      stateText.setText("Récupération des départs...");
    } else if (appState == DISPLAY) {
      stateText.setText("");
    }

    if (currentStop != null && stops.hasKey(currentStop)) {
      var stop = stops[currentStop];
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

      var distance = PositionUtils.getDistance(position, stopLocation);
      distanceText.setText(Math.round(distance).toNumber() + "m");
      distanceText.draw(dc);

      var angle = PositionUtils.getAngle(position, stopLocation);

      var x1 = 144 + 20 * Math.cos(angle);
      var y1 = 20 + 12 * Math.sin(angle);
      var x2 = 144 - 20 * Math.cos(angle);
      var y2 = 20 - 12 * Math.sin(angle);
      dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
      dc.setPenWidth(3);
      dc.drawLine(x1, y1, x2, y2);
      // arrow head
      var x3 = 144 - 10 * Math.cos(angle + Math.PI / 2);
      var y3 = 20 - 6 * Math.sin(angle + Math.PI / 2);
      var x4 = 144 - 10 * Math.cos(angle - Math.PI / 2);
      var y4 = 20 - 6 * Math.sin(angle - Math.PI / 2);
      dc.drawLine(x2, y2, x3, y3);
      dc.drawLine(x2, y2, x4, y4);
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    }

    if (appState == DISPLAY) {
      if (departures.size() < 1) {
        stateText.setText("Aucun départ trouvé");
      } else {
        for (
          var i = verticalScrollBar.position;
          i < verticalScrollBar.position + 2;
          i++
        ) {
          if (i >= departureGroups.size()) {
            break;
          }
          var ldepartures = departureGroups[i];
          var departureElement = new DepartureGroupElement({
            :lineName => ldepartures.values()[0].lineName,
            :platformName => ldepartures.values()[0].platformName,
            :locX => 6,
            :locY => 67 + (i - verticalScrollBar.position) * 52,
            :departures => ldepartures.values(),
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

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {
    if (stops.size() == 0) {
      appState = GET_LOCATION;
    } else if (departures.size() == 0) {
      appState = GET_DEPARTURES;
    } else {
      appState = DISPLAY;
    }
    Position.enableLocationEvents(
      Position.LOCATION_CONTINUOUS,
      method(:onPosition)
    );
    onPosition(Position.getInfo());

    stateText = new WatchUi.TextArea({
      :locX => WatchUi.LAYOUT_HALIGN_CENTER,
      :locY => 75,
      :width => 176,
      :height => 70,
      :justification => Graphics.TEXT_JUSTIFY_CENTER,
    });
    distanceText = new WatchUi.Text({
      :locX => 144,
      :locY => 35,
      :font => Graphics.FONT_TINY,
      :justification => Graphics.TEXT_JUSTIFY_CENTER,
      :color => Graphics.COLOR_BLACK,
    });
  }

  function onTimer() as Void {
    if (currentStop == null) {
      return;
    }
    JsonTransaction.makeRequest(
      "/stops/" + stops[currentStop].ref + "/departures",
      null,
      method(:onDepartures)
    );
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {
    Position.enableLocationEvents(
      Position.LOCATION_DISABLE,
      method(:onPosition)
    );
    if (timer) {
      timer.stop();
      timer = null;
    }
  }

  function onDepartures(responseCode as Number, data as Dictionary?) as Void {
    if (responseCode != 200) {
      System.println("Error getting departures");
      return;
    }
    departures = Formatter.getDeparturesFromData(data);

    if (departureGroups.size() > 0) {
      for (var i = 0; i < departureGroups.size(); i++) {
        departureGroups[i].clear();
      }
    }
    for (var i = 0; i < departures.size(); i++) {
      var departure = departures[i];
      if (departure.cancelled || departure.deviation) {
        continue;
      }
      var index =
        groupRef[
          departure.lineName +
            departure.destinationName +
            departure.platformName
        ];
      if (index == null) {
        index = departureGroups.size();
        groupRef[
          departure.lineName +
            departure.destinationName +
            departure.platformName
        ] = index;
        departureGroups[index] = {};
      }
      departureGroups[index].put(departure.order, departure);
    }
    for (var i = 0; i < departureGroups.size(); i++) {
      if (departureGroups[i].size() == 0) {
        groupRef.remove(
          departureGroups[i].values()[0].lineName +
            departureGroups[i].values()[0].destinationName +
            departureGroups[i].values()[0].platformName
        );
        departureGroups.remove(i);
        if (i < verticalScrollBar.position) {
          verticalScrollBar.position--;
        }
      }
    }
    var pos = 0;
    while (pos < departureGroups.size()) {
      var el = departureGroups[pos];
      if (el == null) {
        var nextIndex = pos + 1;
        while (departureGroups[nextIndex] == null) {
          nextIndex++;
        }
        el[pos] = departureGroups[nextIndex];
        groupRef[
          departureGroups[nextIndex].values()[0].lineName +
            departureGroups[nextIndex].values()[0].destinationName +
            departureGroups[nextIndex].values()[0].platformName
        ] = pos;
        departureGroups.remove(nextIndex);
      }
      pos++;
    }

    if (departureGroups.size() > 2) {
      var currentPosition = 0;
      if (verticalScrollBar != null) {
        currentPosition = verticalScrollBar.position;
      }

      if (currentPosition > departureGroups.size() - 2) {
        currentPosition = departureGroups.size() - 2;
      }
      if (currentPosition < 0) {
        currentPosition = 0;
      }

      verticalScrollBar = new VerticalScrollBar({
        :length => departureGroups.size(),
        :position => currentPosition,
      });
    } else {
      verticalScrollBar = null;
    }

    if (appState == GET_DEPARTURES) {
      appState = DISPLAY;
      timer = new Timer.Timer();
      timer.start(self.method(:onTimer), 15000, true);
    }
    requestUpdate();

    System.println("got departures");
  }

  function getDepartureGroupsSize() {
    var size = 0;
    for (var i = 0; i < departureGroups.size(); i++) {
      if (departureGroups[i].size() > 0) {
        size++;
      }
    }
    return size;
  }

  function onStops(responseCode as Number, data as Dictionary?) as Void {
    if (responseCode != 200) {
      System.println("Error getting stops");
      return;
    }
    var oldStopRef = null;
    if (currentStop != null) {
      oldStopRef = stops[currentStop];
    }
    stops = Formatter.getStopsFromData(data);
    if (oldStopRef != null) {
      var found = false;
      for (var i = 0; i < stops.size(); i++) {
        if (stops[i].ref == oldStopRef) {
          currentStop = i;
          found = true;
          break;
        }
      }
      if (!found) {
        currentStop = null;
      }
    }
    if (currentStop == null && stops.size() > 0) {
      currentStop = 0;
    }
    if (appState == GET_STOPS) {
      appState = GET_DEPARTURES;
    }
    requestUpdate();

    System.println("got stops");

    if (currentStop != null) {
      JsonTransaction.makeRequest(
        "/stops/" + stops[currentStop].ref + "/departures",
        null,
        method(:onDepartures)
      );
    }
  }

  function onPosition(info as Position.Info) as Void {
    System.println("updated position");
    position = info.position;
    if (position == null) {
      return;
    }
    if (appState == GET_LOCATION) {
      appState = GET_STOPS;
      requestUpdate();
    }
    JsonTransaction.makeRequest(
      "/stops/nearby",
      { "lat" => position.toDegrees()[0], "lon" => position.toDegrees()[1] },
      method(:onStops)
    );
  }
}
