import Toybox.Lang;

(:glance)
class Stop {
    public var ref as Number;
    public var name as String;
    public var lat as Number;
    public var lon as Number;
    public var probability as Float;

    public function initialize(ref as Number, name as String, lat as Number, lon as Number, probability as Float) {
        self.ref = ref;
        self.name = name;
        self.lat = lat;
        self.lon = lon;
        self.probability = probability;
    }
}