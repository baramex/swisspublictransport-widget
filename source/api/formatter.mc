import Toybox.Lang;

class Formatter {
    function getStopsFromData(data as Dictionary?) as Dictionary<Number, Stop> {
        var stops = {} as Dictionary<Number, Stop>;
        if(data != null) {
            for(var i = 0; i < data.size; i++) {
                var stop = new Stop(data[i].ref, data[i].name, data[i].lat, data[i].lon, data[i].probability);
                stops[stop.ref] = stop;
            }
        }
        return stops;
    }

    function getDeparturesFromData(data as Dictionary?) as Dictionary<String, Departure> {
        var departures = {} as Dictionary<String, Departure>;
        if(data != null) {
            for(var i = 0; i < data.size; i++) {
                var departure = new Departure(data[i].tripRef, data[i].stopRef, data[i].realtimeDepartureTime, data[i].platformName, data[i].lineName, data[i].destinationName, data[i].cancelled, data[i].unplanned, data[i].deviation);
                departures[departure.tripRef] = departure;
            }
        }
        return departures;
    }
}