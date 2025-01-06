import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

class DepartureGroupElement {
  var lineName as String;
  var platformName as String;
  var locX as Number;
  var locY as Number;
  var departures as Array<Departure>;
  var destinationName as String;

  public function initialize(params as Dictionary) {
    lineName = params.get(:lineName) as String;
    locX = params.get(:locX) as Number;
    locY = params.get(:locY) as Number;
    departures = params.get(:departures) as Array<Departure>;
    platformName = params.get(:platformName) as String;
    destinationName = params.get(:destinationName) as String;
  }

  public function draw(dc as Dc) as Void {
    var lineElement = new LineElement({
      :lineName => lineName,
      :locX => locX,
      :locY => locY,
    });
    lineElement.draw(dc);
    
    dc.drawText(
      locX + lineElement.getWidth(dc) + 4,
      locY + lineElement.getHeight(dc) / 2,
      Graphics.FONT_TINY,
      destinationName,
      Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );

    var depText = "";
    for (var j = 0; j < departures.size(); j++) {
      var dep = departures[j];
      var time = dep.departureTime;
      var relative = time.subtract(Time.now());
      if (relative.value() < 15) {
        depText += "🚌  ";
      } else {
        depText += Math.ceil(relative.value() / 60.0).toNumber() + "'  ";
      }
    }
    dc.drawText(
      locX + lineElement.getWidth(dc) + 4,
      locY + 26,
      Graphics.FONT_SMALL,
      depText,
      Graphics.TEXT_JUSTIFY_LEFT
    );

    var offset = 0;
    if(locY > 100) {
        offset = 20;
    }
    var platformElement = new PlatformElement({
      :platformName => platformName,
      :locX => 176 - dc.getTextWidthInPixels(platformName, Graphics.FONT_TINY) - 8 - offset,
      :locY => locY + 26,
    });
    platformElement.draw(dc);
  }
}
