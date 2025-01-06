import Toybox.Math;
import Toybox.Position;

class PositionUtils {
  static function getDistance(loc1 as Location, loc2 as Location) {
    var lat1 = loc1.toRadians()[0];
    var lon1 = loc1.toRadians()[1];
    var lat2 = loc2.toRadians()[0];
    var lon2 = loc2.toRadians()[1];

    var dy = lat2 - lat1;
    var dx = lon2 - lon1;

    var sy = Math.sin(dy / 2);
    sy *= sy;

    var sx = Math.sin(dx / 2);
    sx *= sx;

    var a = sy + Math.cos(lat1) * Math.cos(lat2) * sx;

    // you'll have to implement atan2
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    var R = 6371000; // radius of earth in meters
    return R * c;
  }

  static function getAngle(loc1 as Location, loc2 as Location) {
    var lat1 = loc1.toRadians()[0];
    var lon1 = loc1.toRadians()[1];
    var lat2 = loc2.toRadians()[0];
    var lon2 = loc2.toRadians()[1];

    var dx = lon2 - lon1;

    var y = Math.sin(dx) * Math.cos(lat2);
    var x =
      Math.cos(lat1) * Math.sin(lat2) -
      Math.sin(lat1) * Math.cos(lat2) * Math.cos(dx);

    var angle = Math.atan2(y, x);
    return angle;
  }
}
