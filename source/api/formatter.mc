import Toybox.Lang;
import Toybox.Time;

(:glance)
class Formatter {
    static function getStopsFromData(data as Dictionary?) as Dictionary<Number, Stop> {
        var stops = {} as Dictionary<Number, Stop>;
        if(data != null) {
            for(var i = 0; i < data.size(); i++) {
                var stop = new Stop(data[i].get("ref"), data[i].get("name"), data[i].get("lat"), data[i].get("lon"), data[i].get("probability"));
                stops[data[i].get("order")] = stop;
            }
        }
        return stops;
    }

    static function getDeparturesFromData(data as Dictionary?) as Dictionary<Number, Departure> {
        var departures = {} as Dictionary<Number, Departure>;
        if(data != null) {
            for(var i = 0; i < data.size(); i++) {
                var time = data[i].get("realtimeDepartureTime");
                if(time == null) {
                    time = data[i].get("scheduledDepartureTime");
                }
                time = new Time.Moment(time);
                var departure = new Departure({
                    "tripRef" => data[i].get("tripRef"),
                    "order" => data[i].get("order"),
                    "stopRef" => data[i].get("stopRef"),
                    "departureTime" => time,
                    "platformName" => data[i].get("platformName"),
                    "lineName" => data[i].get("lineName"),
                    "destinationName" => data[i].get("destinationName"),
                    "cancelled" => data[i].get("cancelled"),
                    "unplanned" => data[i].get("unplanned"),
                    "deviation" => data[i].get("deviation")
                });
                departures[departure.order] = departure;
            }
        }
        return departures;
    }
}