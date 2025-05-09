import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

class DepartureGroupElement {
  var lineName as String;
  var lineColor as String?;
  var lineTextColor as String?;
  var platformName as String?;
  var locX as Number;
  var locY as Number;
  var height as Number;
  var width as Number;
  var departures as Dictionary<Number, Departure>;
  var destinationName as String;

  public function initialize(params as Dictionary) {
    lineName = params.get(:lineName) as String;
    lineColor = params.get(:lineColor) as String;
    lineTextColor = params.get(:lineTextColor) as String;
    locX = params.get(:locX) as Number;
    locY = params.get(:locY) as Number;
    height = params.get(:height) as Number;
    width = params.get(:width) as Number;
    departures = params.get(:departures) as Dictionary<Number, Departure>;
    platformName = params.get(:platformName) as String;
    destinationName = params.get(:destinationName) as String;
  }

  public function draw(dc as Dc) as Void {
    var lineElement = new LineElement({
      :lineName => lineName,
      :lineColor => lineColor,
      :lineTextColor => lineTextColor,
      :locX => locX,
      :locY => locY,
    });
    lineElement.draw(dc);

    dc.drawText(
      locX + lineElement.getWidth(dc) + 4,
      locY + lineElement.getHeight(dc) / 2,
      Graphics.FONT_XTINY,
      destinationName,
      Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );

    var depText = "";
    var j = 0;
    var i = 0;
    while (j < departures.size()) {
      var dep = null;
      while (dep == null) {
        dep = departures.get(i);
        i++;
      }
      var time = dep.departureTime;
      var relative = time.compare(Time.now());
      if (relative < 20) {
        if (relative >= 0) {
          depText += "🚌  ";
        } else {
          depText += "💨  ";
        }
      } else {
        depText += Math.ceil(relative / 60.0).toNumber() + "'  ";
      }
      j++;
    }
    dc.drawText(
      locX + lineElement.getWidth(dc) + 4,
      locY + height / 2,
      Graphics.FONT_TINY,
      depText,
      Graphics.TEXT_JUSTIFY_LEFT
    );

    if (platformName != null) {
      var platformElement = new PlatformElement({
        :platformName => platformName,
        :locX => width -
        dc.getTextWidthInPixels(platformName, Graphics.FONT_TINY) -
        8,
        :locY => locY + height / 2,
      });
      platformElement.draw(dc);
    }
  }
}
