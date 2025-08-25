import Toybox.WatchUi;
import Toybox.Application;

class SettingsDelegate extends WatchUi.MenuInputDelegate {
  protected var stop as Stop;

  function initialize(stop as Stop) {
    MenuInputDelegate.initialize();

    self.stop = stop;
  }

  function onMenuItem(item) {
    if (item == :favorite) {
      if (!stop.favorite && StorageUtils.getFavoriteCount() >= 4) {
        if (WatchUi has :showToast) {
          WatchUi.showToast(Rez.Strings.FavoritesLimitReached, null);
        } else {
          WatchUi.pushView(
            new WatchUi.Confirmation(
              Application.loadResource(Rez.Strings.FavoritesLimitReached)
            ),
            null,
            WatchUi.SLIDE_IMMEDIATE
          );
        }
        return;
      }
      stop.favorite = !stop.favorite;
      if (stop.favorite) {
        StorageUtils.addToFavorites(stop);
      } else {
        StorageUtils.removeFromFavorites(stop.ref);
      }
    } else if (item == :glance) {
      StorageUtils.setGlanceStop(stop);
    } else if (item == :map) {
      var location = stop.getLocation();
      var map = new WatchUi.MapView();
      map.setMapVisibleArea(
        location.getProjectedLocation((3 * Math.PI) / 4, 100),
        location.getProjectedLocation(-Math.PI / 4, 100)
      );
      map.setScreenVisibleArea(0, 0, 1, 1);
      map.setMapMode(WatchUi.MAP_MODE_BROWSE);
      var marker = new WatchUi.MapMarker(location);
      marker.setLabel(stop.name);
      map.setMapMarker(marker);
      WatchUi.pushView(map, null, WatchUi.SLIDE_IMMEDIATE);
    }
  }
}
