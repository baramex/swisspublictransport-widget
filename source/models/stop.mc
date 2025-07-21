import Toybox.Lang;

class Stop {
    public var ref as Number;
    public var name as String;
    public var lat as Number;
    public var lon as Number;

    public function initialize(ref as Number, name as String, lat as Number, lon as Number) {
        self.ref = ref;
        self.name = name;
        self.lat = lat;
        self.lon = lon;
    }
}