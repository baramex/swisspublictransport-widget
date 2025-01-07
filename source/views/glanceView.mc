import Toybox.WatchUi;

(:glance)
class glanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.Glance(dc));
    }

    function onUpdate(dc) {
        GlanceView.onUpdate(dc);
    }

    function onShow() {
    }

    function onHide() {
    }
}