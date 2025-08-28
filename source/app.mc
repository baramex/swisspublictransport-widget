import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Position;
import Toybox.Time;

class App extends Application.AppBase {
  enum AppState {
    GET_LOCATION,
    GET_STOPS,
    GET_DEPARTURES,
    DISPLAY,
  }

  var view;
  var timer;

  var position as Position.Location?;
  var appState as AppState = GET_LOCATION;
  var error as Number?;
  var stops as Dictionary<Number, Stop>?;
  var departures as Dictionary<Number, Departure>?;
  var currentStop as Number?;

  var lastStopsRequest as Time.Moment?;
  var lastDeparturesRequest as Time.Moment?;

  var departureGroups =
    ({}) as Dictionary<Number, Dictionary<Number, Departure> >;
  var groupRef = ({}) as Dictionary<String, Number>;

  function initialize() {
    AppBase.initialize();
  }

  // onStart() is called on application start up
  function onStart(state as Dictionary?) as Void {
    System.println("App active");
    if (position == null) {
      appState = GET_LOCATION;
    } else if (stops == null) {
      appState = GET_STOPS;
    } else if (departures == null) {
      appState = GET_DEPARTURES;
    } else {
      appState = DISPLAY;
    }

    Position.enableLocationEvents(
      Position.LOCATION_CONTINUOUS,
      method(:onPosition)
    );
    var info = Position.getInfo();
    if (info.when != null && info.when.subtract(Time.now()).value() < 5 * 60) {
      onPosition(info);
    } else {
      Formatter.getStopsFromData(null, StorageUtils.getFavorites());
      reorderStops();
      if (currentStop == null) {
        currentStop = 0;
        appState = GET_DEPARTURES;
        updateDepartures(true);
      }
    }
  }

  // onStop() is called when your application is exiting
  function onStop(state as Dictionary?) as Void {
    System.println("App inactive");
    Position.enableLocationEvents(
      Position.LOCATION_DISABLE,
      method(:onPosition)
    );
    if (timer != null) {
      timer.stop();
      timer = null;
    }
  }

  // Return the initial view of your application here
  function getInitialView() as [Views] or [Views, InputDelegates] {
    view = new MainView();
    var delegate = new NavDelegate(view);
    return [view, delegate];
  }

  function getGlanceView() as [WatchUi.GlanceView] or
    [WatchUi.GlanceView, GlanceViewDelegate] or
    Null {
    return [new GlanceView()];
  }

  function onActive(state) as Void {
    if (timer == null) {
      timer = new Timer.Timer();
      timer.start(self.method(:onTimer), 15000, true);
    }
  }

  function onInactive(state) as Void {
    if (timer != null) {
      timer.stop();
      timer = null;
    }
  }

  function reorderStops() {
    if (position == null || stops == null) {
      return;
    }
    var currentStopRef =
      currentStop != null ? stops.get(currentStop).ref : null;
    for (var i = 0; i < stops.size(); i++) {
      for (var y = 0; y < stops.size() - i; y++) {
        var stop1 = stops.get(y);
        var stop2 = stops.get(y + 1);
        if (stop1 == null || stop2 == null) {
          continue;
        }
        var dist1 = PositionUtils.getDistance(position, stop1.getLocation());
        var dist2 = PositionUtils.getDistance(position, stop2.getLocation());
        if (dist1 > dist2) {
          stops.put(y, stop2);
          stops.put(y + 1, stop1);
          if (currentStopRef == stop1.ref) {
            currentStop = y + 1;
          } else if (currentStopRef == stop2.ref) {
            currentStop = y;
          }
        }
      }
    }
  }

  function onTimer() as Void {
    updateDepartures(false);
  }

  function updateDepartures(force as Boolean?) {
    if (currentStop == null) {
      return;
    }
    if (
      lastDeparturesRequest == null ||
      Time.now().subtract(lastDeparturesRequest).value() > 10 ||
      force == true
    ) {
      lastDeparturesRequest = Time.now();
      JsonTransaction.makeRequest(
        "/stops/" + stops.get(currentStop).ref + "/departures",
        null,
        method(:onDepartures)
      );
    } else {
      WatchUi.requestUpdate();
    }
  }

  function onDepartures(responseCode as Number, data as Dictionary?) as Void {
    if (responseCode != 200) {
      System.println("Error getting departures");
      error = responseCode;
      return;
    }
    error = null;
    departures = Formatter.getDeparturesFromData(data);

    if (departureGroups.size() > 0) {
      for (var i = 0; i < departureGroups.size(); i++) {
        departureGroups.put(i, {});
      }
    }
    for (var i = 0; i < departures.size(); i++) {
      var departure = departures.get(i) as Departure;
      if (departure.cancelled || departure.deviation) {
        continue;
      }
      var index = groupRef.get(
        departure.lineName + departure.destinationName + departure.platformName
      );
      if (index == null) {
        index = departureGroups.size();
        groupRef.put(
          departure.lineName +
            departure.destinationName +
            departure.platformName,
          index
        );
        departureGroups.put(index, {});
      }
      departureGroups.get(index).put(departure.order, departure);
    }
    for (var i = 0; i < departureGroups.size(); i++) {
      if (departureGroups.get(i).size() == 0) {
        groupRef.remove(groupRef.keys()[groupRef.values().indexOf(i)]);
        departureGroups.remove(i);
        if (view != null) {
          if (view.verticalScrollBar != null) {
            if (i < view.verticalScrollBar.position) {
              view.verticalScrollBar.position--;
            }
          }
        }
      }
    }
    var pos = 0;
    while (pos < departureGroups.size()) {
      var el = departureGroups.get(pos);
      if (el == null) {
        var nextIndex = pos + 1;
        while (departureGroups.get(nextIndex) == null) {
          nextIndex++;
        }
        departureGroups.put(pos, departureGroups.get(nextIndex));
        groupRef.put(
          groupRef.keys()[groupRef.values().indexOf(nextIndex)],
          pos
        );
        departureGroups.remove(nextIndex);
      }
      pos++;
    }

    if (view != null) {
      if (departureGroups.size() > 2) {
        var currentPosition = 0;
        if (view.verticalScrollBar != null) {
          currentPosition = view.verticalScrollBar.position;
        }

        if (currentPosition > departureGroups.size() - 2) {
          currentPosition = departureGroups.size() - 2;
        }
        if (currentPosition < 0) {
          currentPosition = 0;
        }

        view.verticalScrollBar = new VerticalScrollBar({
          :length => departureGroups.size() - 1,
          :position => currentPosition,
        });
      } else {
        view.verticalScrollBar = null;
      }
    }

    if (appState == GET_DEPARTURES) {
      appState = DISPLAY;
      if (timer == null) {
        timer = new Timer.Timer();
        timer.start(self.method(:onTimer), 15000, true);
      }
    }
    WatchUi.requestUpdate();

    System.println("got departures");
  }

  function onStops(responseCode as Number, data as Dictionary?) as Void {
    if (responseCode != 200) {
      System.println("Error getting stops");
      error = responseCode;
      return;
    }
    error = null;
    var oldStopRef = null;
    if (currentStop != null) {
      oldStopRef = stops.get(currentStop);
    }
    stops = Formatter.getStopsFromData(data, StorageUtils.getFavorites());
    if (oldStopRef != null) {
      var found = false;
      for (var i = 0; i < stops.size(); i++) {
        if (stops.get(i).ref == oldStopRef.ref) {
          currentStop = i;
          found = true;
          break;
        }
      }
      if (!found) {
        currentStop = null;
        departures = null;
        departureGroups = {};
        groupRef = {};
      }
    }

    if (StorageUtils.getFavoriteCount() > 0) {
      reorderStops();
    }

    if (currentStop == null && stops.size() > 0) {
      currentStop = 0;
      appState = GET_DEPARTURES;
      updateDepartures(true);
    }

    if (view != null) {
      if (stops.size() > 1) {
        view.horizontalScrollBar = new HorizontalScrollBar({
          :length => stops.size(),
          :position => currentStop,
        });
      } else {
        view.horizontalScrollBar = null;
      }
    }

    WatchUi.requestUpdate();

    System.println("got stops");
  }

  function onPosition(info as Position.Info) as Void {
    System.println("updated position");
    position = info.position;
    if (position == null || position.toDegrees().size() < 2) {
      return;
    }
    if (appState == GET_LOCATION) {
      appState = GET_STOPS;
      WatchUi.requestUpdate();
    }
    if (
      lastStopsRequest == null ||
      Time.now().subtract(lastStopsRequest).value() > 10
    ) {
      lastStopsRequest = Time.now();
      JsonTransaction.makeRequest(
        "/stops/nearby",
        { "lat" => position.toDegrees()[0], "lon" => position.toDegrees()[1] },
        method(:onStops)
      );
    } else {
      WatchUi.requestUpdate();
    }
  }
}

function getApp() as App {
  return Application.getApp() as App;
}
