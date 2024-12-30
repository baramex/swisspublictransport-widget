import Toybox.Lang;
import Toybox.Time;

class Departure {
    public var tripRef as String;
    public var stopRef as Number;
    public var realtimeDepartureTime as Moment;
    public var platformName as String;
    public var lineName as String;
    public var destinationName as String;
    public var cancelled as Boolean;
    public var unplanned as Boolean;
    public var deviation as Boolean;

    public function initialize(tripRef as String, stopRef as Number, realtimeDepartureTime as Moment, platformName as String, lineName as String, destinationName as String, cancelled as Boolean, unplanned as Boolean, deviation as Boolean) {
        self.tripRef = tripRef;
        self.stopRef = stopRef;
        self.realtimeDepartureTime = realtimeDepartureTime;
        self.platformName = platformName;
        self.lineName = lineName;
        self.destinationName = destinationName;
        self.cancelled = cancelled;
        self.unplanned = unplanned;
        self.deviation = deviation;
    }
}