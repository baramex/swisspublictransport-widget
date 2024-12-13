import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Position;

class swisspublictransportView extends WatchUi.View {

    enum AppState {
        GET_LOCATION,
        GET_STOPS,
        GET_DEPARTURES,
        DISPLAY
    }

    var position as Position.Location or Null;
    var appState as AppState = GET_LOCATION;
    var currentStop as Number or Null; // stop ref
    var stops = {} as Dictionary<Number, Stop>;
    var departures = {} as Dictionary<String, Departure>;
    
    function initialize() {
        View.initialize();
        // create layers
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.GettingStops(dc));
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        
        // display according to states (either loc getting, stop getting, departure getting or displaying)
        // draw progress bars etc
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        if(stops.size == 0) {
            appState = GET_LOCATION;
        } else if(departures.size == 0) {
            appState = GET_DEPARTURES;
        } else {
            appState = DISPLAY;
        }
        Position.enableLocationEvents( Position.LOCATION_CONTINUOUS, method( :onPosition ) );
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        Position.enableLocationEvents( Position.LOCATION_DISABLE, method( :onPosition ) );
    }

    function onStops(responseCode as Number, data as Dictionary?) as Void {
        if(responseCode != 200) {
            System.println("Error getting stops");
            return;
        }
        stops = Formatter.getStopsFromData(data);
        if(currentStop != null && stops[currentStop] == null) {
            currentStop = null;
        }
        if(currentStop == null) {
            currentStop = stops.keys[0];
        }
        if(appState == GET_STOPS) {
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
        if(appState == GET_LOCATION) {
            appState = GET_STOPS;
            requestUpdate();
        }
        JsonTransaction.makeRequest("/stops/nearby", { "lat" => position.lat, "lon" => position.lon }, method( :onStops ) );
    }
}
