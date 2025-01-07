import Toybox.WatchUi;
import Toybox.Graphics;

(:glance)
class glanceView extends WatchUi.GlanceView {
    var type = "glance";

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc) {
        GlanceView.onUpdate(dc);
        System.println("glance update");
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        var app = getApp();

        dc.drawText(0, 0, Graphics.FONT_XTINY, "Transports publics", Graphics.TEXT_JUSTIFY_LEFT);

        var stateText = null;
        if (app.appState == app.GET_LOCATION) {
        stateText = "Récupération de la position...";
        } else if (app.appState == app.GET_STOPS) {
        stateText = "Récupération des arrêts...";
        } else if (app.appState == app.GET_DEPARTURES) {
        stateText = "Récupération des départs...";
        } else if (app.appState == app.DISPLAY) {
        stateText = null;
        }

        if (app.currentStop != null && app.stops.hasKey(app.currentStop)) {
            var stop = app.stops.get(app.currentStop);
            var stopText = stop.name;

            dc.drawText(dc.getTextWidthInPixels("Transports publics", Graphics.FONT_XTINY), 3, Graphics.FONT_XTINY, stopText, Graphics.TEXT_JUSTIFY_LEFT);
        }

        if (app.appState == app.DISPLAY) {
            if (app.departures.size() < 1) {
                stateText = "Aucun départ trouvé";
            } else {
                for (var i = 0; i < 2; i++) {
                    if(i >= app.departures.size()) {
                        break;
                    }
                    var departure = app.departures.get(i);
                    var y = 10 + i * 10;
                    var time = departure.departureTime;
                    var relative = time.subtract(Time.now());
                    var depText = "";
                    if (relative.value() < 15) {
                        depText += "🚌";
                    } else {
                        depText += Math.ceil(relative.value() / 60.0).toNumber() + "'";
                    }
                    dc.drawText(0, y, Graphics.FONT_SMALL, depText, Graphics.TEXT_JUSTIFY_LEFT);
                    var x = 0 + dc.getTextWidthInPixels(depText, Graphics.FONT_SMALL);
                    var lineElement = new LineElement({
                        :lineName => departure.lineName,
                        :locX => x,
                        :locY => y,
                    });
                    lineElement.draw(dc);
                    dc.drawText(x + lineElement.getWidth(dc), y, Graphics.FONT_TINY, departure.destinationName, Graphics.TEXT_JUSTIFY_LEFT);
                }
            }
        }

        if(stateText != null) {
            dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Graphics.FONT_XTINY, stateText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    function onShow() {
    }

    function onHide() {
    }
}