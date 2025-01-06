import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

class VerticalScrollBar {
  var position as Number;
  var length as Number;

  public function initialize(params as Dictionary) {
    length = params.get(:length) as Number;
    position = params.get(:position) as Number;
  }

  public function draw(dc as Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
    var y = 51;
    var height = 75;
    var gap = 1;
    var size = (height - gap * (length - 1)) / length;
    for (var i = 0; i < length; i++) {
      if (i == position) {
        dc.fillRectangle(
          1,
          y + i * size + i * gap,
          3,
          size
        );
      } else {
        dc.drawRectangle(
          1,
          y + i * size + i * gap,
          3,
          size
        );
      }
    }
  }
}
