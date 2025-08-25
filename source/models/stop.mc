import Toybox.Lang;
import Toybox.Position;

(:glance)
class Stop {
    public var ref as Number;
    public var name as String;
    public var lat as Number;
    public var lon as Number;
    public var favorite as Boolean;

    public function initialize(ref as Number, name as String, lat as Number, lon as Number, favorite as Boolean) {
        self.ref = ref;
        self.name = name;
        self.lat = lat;
        self.lon = lon;
        self.favorite = favorite;
    }

    function toDictionary() as StorageUtils.StopObject {
        return ({
            "ref" => ref,
            "name" => name,
            "lat" => lat,
            "lon" => lon,
            "favorite" => favorite
        });
    }

    function getLocation() as Position.Location {
        return new Position.Location({
            :latitude => lat,
            :longitude => lon,
            :format => :degrees
        });
    }

    static function fromDictionary(data as StorageUtils.StopObject) as Stop {
        return new Stop(
            data.get("ref") as Number,
            data.get("name") as String,
            data.get("lat") as Number,
            data.get("lon") as Number,
            data.get("favorite") as Boolean
        );
    }
}