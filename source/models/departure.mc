import Toybox.Lang;
import Toybox.Time;

class Departure {
    public var tripRef as String;
    public var stopRef as Number;
    public var realtimeDepartureTime as Moment;
    public var platform as String;
    public var line as String;
    public var destination as String;
    public var cancelled as Boolean;
    public var unplanned as Boolean;
    public var deviation as Boolean;

    public function initialize(tripRef as String, stopRef as Number, realtimeDepartureTime as Moment, platform as String, line as String, destination as String, cancelled as Boolean, unplanned as Boolean, deviation as Boolean) {
        self.tripRef = tripRef;
        self.stopRef = stopRef;
        self.realtimeDepartureTime = realtimeDepartureTime;
        self.platform = platform;
        self.line = line;
        self.destination = destination;
        self.cancelled = cancelled;
        self.unplanned = unplanned;
        self.deviation = deviation;
    }
}