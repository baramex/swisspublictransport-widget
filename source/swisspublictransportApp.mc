import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Position;

class swisspublictransportApp extends Application.AppBase {
    
    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new swisspublictransportView();
        var delegate = new NavDelegate(view);
        return [ view, delegate ];
    }

    /*(:glance)
    function getGlanceView() as [GlanceView] or [GlanceView, GlanceViewDelegate] or Null {
        // delegates: other stops
        return [ new glanceView() ];
    }*/

    function onActive(state) as Void {
    }

    function onInactive(state) as Void {
    }
}

function getApp() as swisspublictransportApp {
    return Application.getApp() as swisspublictransportApp;
}