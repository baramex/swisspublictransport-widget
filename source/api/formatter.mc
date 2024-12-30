import Toybox.Lang;

class Formatter {
    static function getStopsFromData(data as Dictionary?) as Dictionary<Number, Stop> {
        var stops = {} as Dictionary<Number, Stop>;
        if(data != null) {
            for(var i = 0; i < data.size(); i++) {
                var stop = new Stop(data[i].get("ref"), data[i].get("name"), data[i].get("lat"), data[i].get("lon"), data[i].get("probability"));
                stops[stop.ref] = stop;
            }
        }
        return stops;
    }

    static function getDeparturesFromData(data as Dictionary?) as Dictionary<String, Departure> {
        var departures = {} as Dictionary<String, Departure>;
        if(data != null) {
            for(var i = 0; i < data.size(); i++) {
                var departure = new Departure(data[i].get("tripRef"), data[i].get("stopRef"), data[i].get("realtimeDepartureTime"), data[i].get("platformName"), data[i].get("lineName"), data[i].get("destinationName"), data[i].get("cancelled"), data[i].get("unplanned"), data[i].get("deviation"));
                departures[departure.tripRef] = departure;
            }
        }
        return departures;
    }
}