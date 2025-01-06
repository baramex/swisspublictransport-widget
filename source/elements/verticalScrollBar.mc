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
    for (var i = 0; i < length; i++) {
      if (i == position) {
        dc.fillRectangle(
          1,
          y + i * (height / (length + 1) + 1),
          3,
          height / (length + 1)
        );
      } else {
        dc.drawRectangle(
          1,
          y + i * (height / (length + 1) + 1),
          3,
          height / (length + 1)
        );
      }
    }
  }
}
