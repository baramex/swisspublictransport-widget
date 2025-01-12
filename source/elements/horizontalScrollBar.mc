import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

class HorizontalScrollBar {
  var position as Number;
  var length as Number;

  public function initialize(params as Dictionary) {
    length = params.get(:length) as Number;
    position = params.get(:position) as Number;
  }

  public function draw(dc as Dc) as Void {
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    var x = 144;
    var y = 31;
    var r = 28;
    var gap = 4;
    var size = (100 - gap * (length - 1)) / length;
    for (var i = 0; i < length; i++) {
      if (i == position) {
        dc.setPenWidth(4);
        dc.drawArc(
          x,
          y,
          r,
          Graphics.ARC_CLOCKWISE,
          50 - size * i - gap * i,
          50 - size * (i + 1) - gap * i
        );
      } else {
        var a1 = 50 - size * i - gap * i;
        var a2 = 50 - size * (i + 1) - gap * i;
        dc.setPenWidth(1);
        dc.drawArc(x, y, r + 1.5, Graphics.ARC_CLOCKWISE, a1, a2);
        dc.drawArc(x, y, r - 1.5, Graphics.ARC_CLOCKWISE, a1, a2);
        var ra1 = Math.toRadians(a1);
        var ra2 = Math.toRadians(a2);
        dc.drawLine(
          x + Math.cos(ra1) * (r - 1.5),
          y + Math.sin(ra1) * (r - 1.5),
          x + Math.cos(ra1) * (r + 1.5),
          y + Math.sin(ra1) * (r + 1.5)
        );
        dc.drawLine(
          x + Math.cos(ra2) * (r - 1.5),
          y + Math.sin(ra2) * (r - 1.5),
          x + Math.cos(ra2) * (r + 1.5),
          y + Math.sin(ra2) * (r + 1.5)
        );
      }
    }
  }
}
