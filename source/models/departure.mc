import Toybox.Lang;
import Toybox.Time;

class Departure {
  public var tripRef as String;
  public var order as Number;
  public var stopRef as Number;
  public var departureTime as Moment;
  public var platformName as String;
  public var lineName as String;
  public var destinationName as String;
  public var cancelled as Boolean;
  public var unplanned as Boolean;
  public var deviation as Boolean;

  public function initialize(params as Dictionary) {
    tripRef = params.get("tripRef") as String;
    order = params.get("order") as Number;
    stopRef = params.get("stopRef") as Number;
    departureTime = params.get("departureTime") as Time.Moment;
    platformName = params.get("platformName") as String;
    lineName = params.get("lineName") as String;
    destinationName = params.get("destinationName") as String;
    cancelled = params.get("cancelled") as Boolean;
    unplanned = params.get("unplanned") as Boolean;
    deviation = params.get("deviation") as Boolean;
  }
}
