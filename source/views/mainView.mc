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
  var currentStop as Number?; // stop ref
  var stops = ({}) as Dictionary<Number, Stop>;
  var departures = ({}) as Dictionary<String, Departure>;

  var stopName;
  var stateText;
  var progressBar;

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
    // Call the parent onUpdate function to redraw the layout
    View.onUpdate(dc);

    if (appState == GET_LOCATION) {
      stateText.setText("Récupération de la position...");
    } else if (appState == GET_STOPS) {
      stateText.setText("Récupération des arrêts...");
    } else if (appState == GET_DEPARTURES) {
      stateText.setText("Récupération des départs...");
    } else if (appState == DISPLAY) {
      stateText.setText("Affichage des départs...");
    }

    if (currentStop && stops[currentStop]) {
      var stop = stops[currentStop];
      var stopText = stop.name;
      var stopLocation = new Position.Location({
        :latitude => stop.lat,
        :longitude => stop.lon,
        :format => :degrees,
      });

      var distance = PositionUtils.getDistance(position, stopLocation);

      var angle = PositionUtils.getAngle(position, stopLocation);
      /*if (departures.size() > 0) {
        var departure = departures.values()[0];
        stopText += "\n" + departure.lineName + " " + departure.destinationName;
      }*/
      stopName.setText(
        Lang.format("$1$\n$2$m", [stopText, Math.round(distance).toNumber()])
      );
      stopName.draw(dc);

      var x1 = 144 + 20 * Math.cos(angle);
      var y1 = 32 + 20 * Math.sin(angle);
      var x2 = 144 - 20 * Math.cos(angle);
      var y2 = 32 - 20 * Math.sin(angle);
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
      dc.setPenWidth(3);
      dc.drawLine(x1, y1, x2, y2);
      // arrow head
      var x3 = 144 - 15 * Math.cos(angle + Math.PI / 4);
      var y3 = 32 - 15 * Math.sin(angle + Math.PI / 4);
      var x4 = 144 - 15 * Math.cos(angle - Math.PI / 4);
      var y4 = 32 - 15 * Math.sin(angle - Math.PI / 4);
      dc.drawLine(x2, y2, x3, y3);
      dc.drawLine(x2, y2, x4, y4);
    }

    stateText.draw(dc);
    // display according to states (either loc getting, stop getting, departure getting or displaying)
    // draw progress bars etc
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
    stopName = new WatchUi.TextArea({
      :locX => 12,
      :locY => 20,
      :width => 100,
      :height => 51,
      :font => Graphics.FONT_SMALL,
    });
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {
    Position.enableLocationEvents(
      Position.LOCATION_DISABLE,
      method(:onPosition)
    );
  }

  function onStops(responseCode as Number, data as Dictionary?) as Void {
    if (responseCode != 200) {
      System.println("Error getting stops");
      return;
    }
    stops = Formatter.getStopsFromData(data);
    if (currentStop != null && stops[currentStop] == null) {
      currentStop = null;
    }
    if (currentStop == null) {
      currentStop = stops.keys()[0];
    }
    if (appState == GET_STOPS) {
      appState = GET_DEPARTURES;
    }
    requestUpdate();

    System.println("got stops");

    // get departures
    /*if(appState == GET_DEPARTURES) {
            appState = DISPLAY;
        }
        requestUpdate();*/
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
