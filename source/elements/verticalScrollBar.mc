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

  (:smallOctogonal)
  const y = 49;
  (:largeOctogonal)
  const y = 51;
  (:smallOctogonal)
  const height = 59;
  (:largeOctogonal)
  const height = 75;

  (:anyOctogonal)
  public function draw(dc as Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
    var gap = 1;
    var size = (height - gap * (length - 1)) / length;
    for (var i = 0; i < length; i++) {
      if (i == position) {
        dc.fillRectangle(1, y + i * size + i * gap, 3, size);
      } else {
        dc.drawRectangle(1, y + i * size + i * gap, 3, size);
      }
    }
  }

  (:anyRound)
  public function draw(dc as Dc) as Void {
    var x = dc.getWidth() / 2;
    var y = dc.getHeight() / 2;
    var r = dc.getWidth() / 2 - 6;
    var gap = 4;
    var size = (70 - gap * (length - 1)) / length;
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.setPenWidth(4);
    dc.drawArc(x, y, r, Graphics.ARC_CLOCKWISE, 35, -35);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
    for (var i = 0; i < length; i++) {
      if (i == position) {
        dc.setPenWidth(4);
        dc.drawArc(
          x,
          y,
          r,
          Graphics.ARC_CLOCKWISE,
          35 - size * i - gap * i,
          35 - size * (i + 1) - gap * i
        );
      } else {
        var a1 = 35 - size * i - gap * i;
        var a2 = 35 - size * (i + 1) - gap * i;
        dc.setPenWidth(1);
        dc.drawArc(x, y, r + 1.5, Graphics.ARC_CLOCKWISE, a1, a2);
        dc.drawArc(x, y, r - 1.5, Graphics.ARC_CLOCKWISE, a1, a2);
        var ra1 = Math.toRadians(-a1);
        var ra2 = Math.toRadians(-a2);
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
