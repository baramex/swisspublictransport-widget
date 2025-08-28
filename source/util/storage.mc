import Toybox.Lang;
import Toybox.Application;

(:glance)
class StorageUtils {
  typedef StopObject as Dictionary<String, Number or String or Boolean>;

  static function getFavorites() as Dictionary<Number, StopObject> {
    var favorites =
      Application.Storage.getValue("favorites") as
      Dictionary<Number, StopObject>?;
    if (favorites == null) {
      return {};
    }
    return favorites;
  }

  static function addToFavorites(stop as Stop) {
    var favorites = getFavorites();
    if (!favorites.hasKey(stop.ref)) {
      favorites.put(stop.ref, stop.toDictionary());
      Application.Storage.setValue("favorites", favorites);
    }
  }

  static function removeFromFavorites(stopRef as Number) {
    var favorites = getFavorites();
    if (favorites.hasKey(stopRef)) {
      favorites.remove(stopRef);
      Application.Storage.setValue("favorites", favorites);
    }
  }

  static function setGlanceStop(stop as Stop) {
    Application.Storage.setValue("glanceStop", stop.toDictionary());
  }

  static function getFavoriteCount() as Number {
    var favorites = getFavorites();
    return favorites.size();
  }
}
