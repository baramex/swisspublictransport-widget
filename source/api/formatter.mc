import Toybox.Lang;
import Toybox.Time;

class Formatter {
  static function getStopsFromData(
    data as Dictionary?,
    favorites as Dictionary<Number, StorageUtils.StopObject>
  ) as Dictionary<Number, Stop> {
    var stops = ({}) as Dictionary<Number, Stop>;
    if (data != null) {
      var count = 0;
      for (var i = 0; i < favorites.size(); i++) {
        var exists = false;
        for (var a = 0; a < data.size(); a++) {
          if (favorites.values()[i].get("ref") == data[a].get("ref")) {
            exists = true;
            break;
          }
        }
        if (!exists) {
          count++;
        }
      }

      for (var i = 0; i < data.size(); i++) {
        var exists = false;
        for (var a = 0; a < favorites.size(); a++) {
          if (favorites.values()[a].get("ref") == data[i].get("ref")) {
            exists = true;
            stops[data[i].get("order")] = Stop.fromDictionary(
              favorites.values()[a]
            );
            break;
          }
        }
        if (data[i].get("order") + count >= 5 || exists) {
          continue;
        }
        var stop = new Stop(
          data[i].get("ref"),
          data[i].get("name"),
          data[i].get("lat"),
          data[i].get("lon"),
          false
        );
        stops[data[i].get("order")] = stop;
      }
    }
    for (var i = 0; i < favorites.size(); i++) {
      var exists = false;
      for (var a = 0; a < data.size(); a++) {
        if (favorites.values()[i].get("ref") == data[a].get("ref")) {
          exists = true;
          break;
        }
      }
      if (!exists) {
        for (var a = 0; a < 5; a++) {
          if (stops.hasKey(a)) {
            continue;
          }
          stops[a] = Stop.fromDictionary(favorites.values()[i]);
          break;
        }
      }
    }
    return stops;
  }

    (:glance)
  static function getDeparturesFromData(
    data as Dictionary?
  ) as Dictionary<Number, Departure> {
    var departures = ({}) as Dictionary<Number, Departure>;
    if (data != null) {
      for (var i = 0; i < data.size(); i++) {
        var time = data[i].get("realtimeDepartureTime");
        if (time == null) {
          time = data[i].get("scheduledDepartureTime");
        }
        time = new Time.Moment(time);
        var departure = new Departure({
          "order" => data[i].get("order"),
          "stopRef" => data[i].get("stopRef"),
          "departureTime" => time,
          "platformName" => data[i].get("platformName"),
          "lineName" => data[i].get("lineName"),
          "destinationName" => data[i].get("destinationName"),
          "cancelled" => data[i].get("cancelled"),
          "unplanned" => data[i].get("unplanned"),
          "deviation" => data[i].get("deviation"),
          "lineColor" => data[i].get("lineColor"),
          "lineTextColor" => data[i].get("lineTextColor"),
        });
        departures[departure.order] = departure;
      }
    }
    return departures;
  }
}
