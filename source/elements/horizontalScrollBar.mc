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

  (:anyOctogonal)
  const angle = 100;
  (:anyRound)
  const angle = 50;
  (:anyOctogonal)
  const startAngle = 0;
  (:anyRound)
  const startAngle = -90;

  public function draw(dc as Dc) as Void {
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    var x = getX(dc);
    var y = getY(dc);
    var r = getRadius(dc);
    var gap = 4;
    var size = (angle - gap * (length - 1)) / length;
    for (var i = 0; i < length; i++) {
      if (i == position) {
        dc.setPenWidth(4);
        dc.drawArc(
          x,
          y,
          r,
          Graphics.ARC_CLOCKWISE,
          startAngle + angle / 2 - size * i - gap * i,
          startAngle + angle / 2 - size * (i + 1) - gap * i
        );
      } else {
        var a1 = startAngle + angle / 2 - size * i - gap * i;
        var a2 = startAngle + angle / 2 - size * (i + 1) - gap * i;
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

  (:smallOctogonal)
  function getX(dc) {
    return 136;
  }
  (:anyOctogonal)
  function getX(dc) {
    return 144;
  }
  (:anyRound)
  function getX(dc) {
    return dc.getWidth() / 2;
  }

  (:smallOctogonal)
  function getY(dc) {
    return 27;
  }
  (:anyOctogonal)
  function getY(dc) {
    return 31;
  }
  (:anyRound)
  function getY(dc) {
    return dc.getHeight() / 2;
  }

  (:smallOctogonal)
  function getRadius(dc) {
    return 24;
  }
  (:anyOctogonal)
  function getRadius(dc) {
    return 28;
  }
  (:anyRound)
  function getRadius(dc) {
    return dc.getWidth() / 2 - 4;
  }
}
