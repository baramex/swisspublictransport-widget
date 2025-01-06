import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

class PlatformElement {
  var platformName as String;
  var locX as Number;
  var locY as Number;

  public function initialize(params as Dictionary) {
    platformName = params.get(:platformName) as String;
    locX = params.get(:locX) as Number;
    locY = params.get(:locY) as Number;
  }

  public function draw(dc as Dc) as Void {
    var w = dc.getTextWidthInPixels(platformName, Graphics.FONT_TINY);
    var h = dc.getFontHeight(Graphics.FONT_TINY);
    dc.setPenWidth(1);
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
    dc.fillRoundedRectangle(locX, locY, w + 4, h, 5);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
    dc.drawRoundedRectangle(locX, locY, w + 4, h, 5);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      locX + 2 + w / 2,
      locY,
      Graphics.FONT_TINY,
      platformName,
      Graphics.TEXT_JUSTIFY_CENTER
    );
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
  }
}
