import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Position;
import Toybox.Time;

class swisspublictransportApp extends Application.AppBase {
  enum AppState {
    GET_LOCATION,
    GET_STOPS,
    GET_DEPARTURES,
    DISPLAY,
  }

  var view;

  var timer;

  var heading as Float?;
  var position as Position.Location?;
  var appState as AppState = GET_LOCATION;
  var stops = ({}) as Dictionary<Number, Stop>;
  var departures = ({}) as Dictionary<Number, Departure>;
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
  }

  // onStop() is called when your application is exiting
  function onStop(state as Dictionary?) as Void {
    System.println("App inactive");
    Position.enableLocationEvents(
      Position.LOCATION_DISABLE,
      method(:onPosition)
    );
    if (timer) {
      timer.stop();
      timer = null;
    }
  }

  // Return the initial view of your application here
  function getInitialView() as [Views] or [Views, InputDelegates] {
    view = new swisspublictransportView();
    var delegate = new NavDelegate(view);
    return [view, delegate];
  }

  function onActive(state) as Void {}

  function onInactive(state) as Void {}

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
    }
  }

  function onDepartures(responseCode as Number, data as Dictionary?) as Void {
    if (responseCode != 200) {
      System.println("Error getting departures");
      return;
    }
    departures = Formatter.getDeparturesFromData(data);

    if (view != null) {
      if (departureGroups.size() > 0) {
        for (var i = 0; i < departureGroups.size(); i++) {
          departureGroups[i] = {};
        }
      }
      for (var i = 0; i < departures.size(); i++) {
        var departure = departures.get(i) as Departure;
        if (departure.cancelled || departure.deviation) {
          continue;
        }
        var index = groupRef.get(
          departure.lineName +
            departure.destinationName +
            departure.platformName
        );
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
        if (departureGroups.get(i).size() == 0) {
          groupRef.remove(groupRef.keys()[groupRef.values().indexOf(i)]);
          departureGroups.remove(i);
          if (view.verticalScrollBar != null) {
            if (i < view.verticalScrollBar.position) {
              view.verticalScrollBar.position--;
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
          departureGroups[pos] = departureGroups.get(nextIndex);
          groupRef[groupRef.keys()[groupRef.values().indexOf(nextIndex)]] = pos;
          departureGroups.remove(nextIndex);
        }
        pos++;
      }

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
    if (view != null) {
      view.requestUpdate();
    }

    System.println("got departures");
  }

  function onStops(responseCode as Number, data as Dictionary?) as Void {
    if (responseCode != 200) {
      System.println("Error getting stops");
      return;
    }
    var oldStopRef = null;
    if (currentStop != null) {
      oldStopRef = stops.get(currentStop);
    }
    stops = Formatter.getStopsFromData(data);
    if (oldStopRef != null) {
      var found = false;
      for (var i = 0; i < stops.size(); i++) {
        if (stops.get(i).ref == oldStopRef) {
          currentStop = i;
          found = true;
          break;
        }
      }
      if (!found) {
        currentStop = null;
        departures = {};
        departureGroups = {};
        groupRef = {};
      }
    }
    if (currentStop == null && stops.size() > 0) {
      currentStop = 0;
      updateDepartures(true);
    }
    if (appState == GET_STOPS) {
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

      view.requestUpdate();
    }

    System.println("got stops");
  }

  function onPosition(info as Position.Info) as Void {
    System.println("updated position");
    position = info.position;
    heading = info.heading;
    if (position == null || position.toDegrees().size() < 2) {
      return;
    }
    if (appState == GET_LOCATION) {
      appState = GET_STOPS;
      if (view != null) {
        view.requestUpdate();
      }
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
    }
  }
}

function getApp() as swisspublictransportApp {
  return Application.getApp() as swisspublictransportApp;
}
