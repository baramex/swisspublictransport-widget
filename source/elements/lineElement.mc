import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

class LineElement {
  var lineName as String;
  var locX as Number;
  var locY as Number;

  public function initialize(params as Dictionary) {
    lineName = params.get(:lineName) as String;
    locX = params.get(:locX) as Number;
    locY = params.get(:locY) as Number;
  }

  public function draw(dc as Dc) as Void {
    var w = dc.getTextWidthInPixels(lineName, Graphics.FONT_MEDIUM);
    var h = dc.getFontHeight(Graphics.FONT_MEDIUM);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
    dc.fillRoundedRectangle(locX, locY, w + 6, h + 2, 5);
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      locX + 3 + w / 2,
      locY + 1,
      Graphics.FONT_MEDIUM,
      lineName,
      Graphics.TEXT_JUSTIFY_CENTER
    );
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
  }

  public function getWidth(dc as Dc) as Number {
    return dc.getTextWidthInPixels(lineName, Graphics.FONT_MEDIUM) + 6;
  }

  public function getHeight(dc as Dc) as Number {
    return dc.getFontHeight(Graphics.FONT_MEDIUM) + 2;
  }
}
