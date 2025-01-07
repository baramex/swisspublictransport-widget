import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Position;

class swisspublictransportApp extends Application.AppBase {
    enum AppState {
    GET_LOCATION,
    GET_STOPS,
    GET_DEPARTURES,
    DISPLAY,
  }

  var view;

  var timer;
  var loading = false;

    var heading as Float?;
  var position as Position.Location?;
  var appState as AppState = GET_LOCATION;
  var stops = ({}) as Dictionary<Number, Stop>;
  var departures = ({}) as Dictionary<Number, Departure>;
  var currentStop as Number?;

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
    onPosition(Position.getInfo());
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        System.println("App inactive");
        loading = false;
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
        return [ view, delegate ];
    }

    /*(:glance)
    function getGlanceView() as [GlanceView] or [GlanceView, GlanceViewDelegate] or Null {
        // delegates: other stops
        return [ new glanceView() ];
    }*/

    function onActive(state) as Void {
        
    }

    function onInactive(state) as Void {
        
    }

    function onTimer() as Void {
    if (currentStop == null) {
      return;
    }
    loading = true;
    JsonTransaction.makeRequest(
      "/stops/" + stops[currentStop].ref + "/departures",
      null,
      method(:onDepartures)
    );
  }

    function onDepartures(responseCode as Number, data as Dictionary?) as Void {
    loading = false;
    if (responseCode != 200) {
      System.println("Error getting departures");
      return;
    }
    departures = Formatter.getDeparturesFromData(data);

    if (departureGroups.size() > 0) {
      for (var i = 0; i < departureGroups.size(); i++) {
        departureGroups[i] = {};
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
      var el = departureGroups[pos];
      if (el == null) {
        var nextIndex = pos + 1;
        while (departureGroups[nextIndex] == null) {
          nextIndex++;
        }
        departureGroups[pos] = departureGroups[nextIndex];
        groupRef[groupRef.keys()[groupRef.values().indexOf(nextIndex)]] = pos;
        departureGroups.remove(nextIndex);
      }
      pos++;
    }

    if (departureGroups.size() > 2) {
      var currentPosition = 0;
      if (view != null && view.verticalScrollBar != null) {
        currentPosition = view.verticalScrollBar.position;
      }

      if (currentPosition > departureGroups.size() - 2) {
        currentPosition = departureGroups.size() - 2;
      }
      if (currentPosition < 0) {
        currentPosition = 0;
      }

        if(view != null) {
      view.verticalScrollBar = new VerticalScrollBar({
        :length => departureGroups.size() - 1,
        :position => currentPosition,
      });
        }
    } else if(view != null) {
      view.verticalScrollBar = null;
    }

    if (appState == GET_DEPARTURES) {
      appState = DISPLAY;
      if (timer == null) {
        timer = new Timer.Timer();
        timer.start(self.method(:onTimer), 15000, true);
      }
    }
    if(view != null) {
    view.requestUpdate();
    }

    System.println("got departures");
  }

  function onStops(responseCode as Number, data as Dictionary?) as Void {
    loading = false;
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

if(view != null) {
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

    onTimer();
  }

  function onPosition(info as Position.Info) as Void {
    System.println("updated position");
    position = info.position;
    heading = info.heading;
    if (position == null) {
      return;
    }
    if (appState == GET_LOCATION) {
      appState = GET_STOPS;
      if(view != null) {
      view.requestUpdate();
      }
    }
    loading = true;
    JsonTransaction.makeRequest(
      "/stops/nearby",
      { "lat" => position.toDegrees()[0], "lon" => position.toDegrees()[1] },
      method(:onStops)
    );
  }
}

function getApp() as swisspublictransportApp {
    return Application.getApp() as swisspublictransportApp;
}